@IsTest
public with sharing class WOO_WMFOrdersLineItemHandlerTest {
    private static User agentSetupTestUser;

    static {
        agentSetupTestUser = (User) TestFactory.createSObject(
            new User(),
            TestFactoryUser.CCCBackAgent.class
        );
    }

    @TestSetup
    static void setup() {
        System.runAs(agentSetupTestUser) {
            Id finishedProductRecordType = [
                SELECT Id
                FROM RecordType
                WHERE sObjectType = 'Product2' AND Name = 'Produit fini'
                LIMIT 1
            ]
            .Id;
            Account acc = (Account) TestFactory.createSObjectAndInsert(
                new Account(
                    PersonMailingCity = 'Berlin',
                    PersonMailingPostalCode = '12359',
                    PersonMailingStreet = 'Johannisthaler Chaussee 169'
                ),
                TestFactoryAccount.WOWConsumer.class
            );
            acc = [SELECT PersonContactId FROM Account WHERE Id = :acc.Id];
            TestFactory.createSObjectAndInsert(
                new Case(Case_Country__c = 'DE', ContactId = acc.PersonContactId)
            );
            TestFactory.createSObjectAndInsert(
                new Product2(CMMF__c = 'P1', RecordTypeId = finishedProductRecordType)
            );
            User agentUser = (User) TestFactory.createSObjectAndInsert(
                new User(Username = 'AgentWMF@AgentWMF.com'),
                TestFactoryUser.CCCBackAgent.class
            );
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'WOO_WMF_Order'];
            PermissionSetAssignment psa = new PermissionSetAssignment(
                AssigneeId = agentUser.Id,
                PermissionSetId = ps.id
            );
            insert psa;
        }
    }

    @IsTest
    private static void requiredRequestedQuantityTest() {
        User agentUser = [SELECT Id FROM User WHERE Username = 'AgentWMF@AgentWMF.com'];
        System.runAs(agentUser) {
            Case c = [SELECT Id FROM Case LIMIT 1];
            TestFactory.createSObjectAndInsert(
                new WOO_WMF_Orders__c(WOO_Case__c = c.Id, WOO_External_Id__c = 'testOrder')
            );
            Product2 p = [SELECT Id FROM Product2 WHERE CMMF__c = 'P1'];
            WOO_WMF_Order_Line_Item__c oli = (WOO_WMF_Order_Line_Item__c) TestFactory.createSObject(
                new WOO_WMF_Order_Line_Item__c(
                    WOO_WMF_Order__r = new WOO_WMF_Orders__c(WOO_External_Id__c = 'testOrder'),
                    WOO_Product__c = p.Id,
                    WOO_Requested_quantity__c = 0
                )
            );
            String error;
            Test.startTest();
            try {
                insert oli;
            } catch (DmlException e) {
                error = e.getMessage();
            }
            Test.stopTest();
            System.assertEquals(
                true,
                error.contains(WOO_WMFOrdersLineItemHandler.REQUESTED_QUANTITY_ERROR_MESSAGE),
                'RequestedQuantity is mandatory for an SAP order other than repair, and trying to create one without it should generate an exception'
            );
        }
    }

    @IsTest
    private static void sameOrderAndOrderLineItemTypeInsert() {
        User agentUser = [SELECT Id FROM User WHERE Username = 'AgentWMF@AgentWMF.com'];
        System.runAs(agentUser) {
            Case c = [SELECT Id FROM Case LIMIT 1];
            TestFactory.createSObjectAndInsert(
                new WOO_WMF_Orders__c(WOO_Case__c = c.Id, WOO_External_Id__c = 'testOrder')
            );
            Product2 p = [SELECT Id FROM Product2 WHERE CMMF__c = 'P1'];
            WOO_WMF_Order_Line_Item__c oli = (WOO_WMF_Order_Line_Item__c) TestFactory.createSObject(
                new WOO_WMF_Order_Line_Item__c(
                    WOO_WMF_Order__r = new WOO_WMF_Orders__c(WOO_External_Id__c = 'testOrder'),
                    WOO_Product__c = p.Id
                )
            );
            String error;
            Test.startTest();
            try {
                insert oli;
            } catch (DmlException e) {
                error = e.getMessage();
            }
            Test.stopTest();
            System.assertEquals(
                true,
                String.isEmpty(error),
                'finishedProduct orderLineItem ceated on finishedProduct Order should not generate an error'
            );
        }
    }

    @IsTest
    private static void differentOrderAndOrderLineItemTypeInsert() {
        User agentUser = [SELECT Id FROM User WHERE Username = 'AgentWMF@AgentWMF.com'];
        Id orderLineItemRepaiRecordType = [
            SELECT Id
            FROM RecordType
            WHERE sObjectType = 'WOO_WMF_Order_Line_Item__c' AND Name = 'Repair'
            LIMIT 1
        ]
        .Id;
        System.runAs(agentUser) {
            Case c = [SELECT Id FROM Case LIMIT 1];
            TestFactory.createSObjectAndInsert(
                new WOO_WMF_Orders__c(WOO_Case__c = c.Id, WOO_External_Id__c = 'testOrder')
            );
            Product2 p = [SELECT Id FROM Product2 WHERE CMMF__c = 'P1'];
            WOO_WMF_Order_Line_Item__c oli = (WOO_WMF_Order_Line_Item__c) TestFactory.createSObject(
                new WOO_WMF_Order_Line_Item__c(
                    WOO_WMF_Order__r = new WOO_WMF_Orders__c(WOO_External_Id__c = 'testOrder'),
                    WOO_Product__c = p.Id,
                    RecordTypeId = orderLineItemRepaiRecordType
                )
            );
            String error;
            Test.startTest();
            try {
                insert oli;
            } catch (DmlException e) {
                error = e.getMessage();
            }
            Test.stopTest();
            System.assertEquals(
                true,
                error.contains(WOO_WMFOrdersLineItemHandler.MISMATCHED_TYPE_ERROR),
                'Repair orderLineItem ceated on finishedProduct Order should generate an error. Should have the same type'
            );
        }
    }

    @IsTest
    private static void sameOrderAndOrderLineItemTypeUpdate() {
        Id orderLineItemRepaiRecordType = [
            SELECT Id
            FROM RecordType
            WHERE sObjectType = 'WOO_WMF_Order_Line_Item__c' AND Name = 'Repair'
            LIMIT 1
        ]
        .Id;
        User agentUser = [SELECT Id FROM User WHERE Username = 'AgentWMF@AgentWMF.com'];
        System.runAs(agentUser) {
            Case c = [SELECT Id FROM Case LIMIT 1];
            TestFactory.createSObjectAndInsert(
                new WOO_WMF_Orders__c(WOO_Case__c = c.Id, WOO_External_Id__c = 'testOrder')
            );
            Product2 p = [SELECT Id FROM Product2 WHERE CMMF__c = 'P1'];
            WOO_WMF_Order_Line_Item__c oli = (WOO_WMF_Order_Line_Item__c) TestFactory.createSObject(
                new WOO_WMF_Order_Line_Item__c(
                    WOO_WMF_Order__r = new WOO_WMF_Orders__c(WOO_External_Id__c = 'testOrder'),
                    WOO_Product__c = p.Id
                )
            );
            insert oli;
            oli.RecordTypeId = orderLineItemRepaiRecordType;
            String error;
            Test.startTest();
            try {
                update oli;
            } catch (DmlException e) {
                error = e.getMessage();
            }
            Test.stopTest();
            System.assertEquals(
                true,
                error.contains(WOO_WMFOrdersLineItemHandler.MISMATCHED_TYPE_ERROR),
                'Update OrderLineItem To repairType on finishedProduct Order should generate an error, they should be the same type'
            );
        }
    }
}