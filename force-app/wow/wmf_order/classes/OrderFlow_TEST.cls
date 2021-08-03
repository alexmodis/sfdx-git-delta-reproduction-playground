@isTest
public with sharing class OrderFlow_TEST {
    @TestSetup
    static void setup() {
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
        System.runAs(agentUser) {
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
            Case c = (Case) TestFactory.createSObjectAndInsert(
                new Case(ContactId = acc.PersonContactId)
            );
            Product2 p = (Product2) TestFactory.createSObjectAndInsert(
                new Product2(CMMF__c = 'P1', RecordTypeId = finishedProductRecordType)
            );
            WOO_WMF_Orders__c order = (WOO_WMF_Orders__c) TestFactory.createSObjectAndInsert(
                new WOO_WMF_Orders__c(WOO_Case__c = c.Id, WOO_External_Id__c = 'testOrder')
            );
            TestFactory.createSObjectAndInsert(
                new WOO_WMF_Order_Line_Item__c(
                    WOO_WMF_Order__c = order.id,
                    WOO_Product__c = p.Id,
                    WOO_Requested_quantity__c = 1
                )
            );
        }
    }

    @isTest
    private static void ordersUpdatePreventedWhenOrderSentTest() {
        User agentUser = [SELECT Id FROM User WHERE Username = 'AgentWMF@AgentWMF.com'];
        Boolean orderUpdatePrevented = false;
        Boolean orderLineItemUpdatePrevented = false;
        System.runAs(agentUser) {
            WOO_WMF_Orders__c order = [SELECT Id FROM WOO_WMF_Orders__c];
            WOO_WMF_Order_Line_Item__c oli = [SELECT Id FROM WOO_WMF_Order_Line_Item__c];
            order.WOO_SAP_status__c = 'Sent';
            update order;

            Test.startTest();
            try {
                order.WOO_Comment__c = 'test';
                update order;
            } catch (Exception e) {
                orderUpdatePrevented = true;
            }

            try {
                oli.WOO_Comment__c = 'test';
                update oli;
            } catch (Exception e) {
                orderLineItemUpdatePrevented = true;
            }
            Test.stopTest();

            System.assertEquals(
                orderUpdatePrevented,
                true,
                'Order delete should be prevented when order is already sent'
            );
            System.assertEquals(
                orderLineItemUpdatePrevented,
                true,
                'Order line item delete should be prevented when order is already sent'
            );
        }
    }

    @isTest
    private static void ordersDeletePreventedWhenOrderSentTest() {
        User agentUser = [SELECT Id FROM User WHERE Username = 'AgentWMF@AgentWMF.com'];
        Boolean orderDeletePrevented = false;
        Boolean orderLineItemDeletePrevented = false;
        System.runAs(agentUser) {
            WOO_WMF_Orders__c order = [SELECT Id FROM WOO_WMF_Orders__c];
            WOO_WMF_Order_Line_Item__c oli = [SELECT Id FROM WOO_WMF_Order_Line_Item__c];
            order.WOO_SAP_status__c = 'Sent';
            update order;

            Test.startTest();
            try {
                delete order;
            } catch (Exception e) {
                orderDeletePrevented = true;
            }

            try {
                delete oli;
            } catch (Exception e) {
                orderLineItemDeletePrevented = true;
            }
            Test.stopTest();

            System.assertEquals(
                orderDeletePrevented,
                true,
                'Order delete should be prevented when order is already sent'
            );
            System.assertEquals(
                orderLineItemDeletePrevented,
                true,
                'Order line item delete should be prevented when order is already sent'
            );
        }
    }

    @isTest
    private static void orderStatusResetWhenOrderLineItemDeletedTest() {
        User agentUser = [SELECT Id FROM User WHERE Username = 'AgentWMF@AgentWMF.com'];
        System.runAs(agentUser) {
            WOO_WMF_Orders__c order = [SELECT Id FROM WOO_WMF_Orders__c];
            WOO_WMF_Order_Line_Item__c oli = [SELECT Id FROM WOO_WMF_Order_Line_Item__c];
            order.WOO_SAP_status__c = 'Simulated with errors';
            update order;

            Test.startTest();
            delete oli;
            Test.stopTest();

            order = [SELECT WOO_SAP_status__c FROM WOO_WMF_Orders__c];
            System.assertEquals(
                order.WOO_SAP_status__c,
                'Draft',
                'Order which status is Simulated Ok should be reset if an orderLineItem is deleted'
            );
        }
    }

    @isTest
    private static void orderStatusResetWhenSentOrderUpdatedTest() {
        User agentUser = [SELECT Id FROM User WHERE Username = 'AgentWMF@AgentWMF.com'];
        System.runAs(agentUser) {
            WOO_WMF_Orders__c order = [SELECT Id FROM WOO_WMF_Orders__c];
            order.WOO_SAP_status__c = 'Simulated with errors';
            update order;

            Test.startTest();
            DateTime dT = System.now();
            order.WOO_Requested_delivery_date__c = date.newinstance(
                dT.year(),
                dT.month(),
                dT.day()
            );
            update order;
            Test.stopTest();

            order = [SELECT WOO_SAP_status__c FROM WOO_WMF_Orders__c];
            System.assertEquals(
                order.WOO_SAP_status__c,
                'Draft',
                'Order which status is Simulated Ok should be reset if an orderLineItem is deleted'
            );
        }
    }

    @isTest
    private static void orderAccountFieldFilledWhenSimulatedOkTest() {
        User agentUser = [SELECT Id FROM User WHERE Username = 'AgentWMF@AgentWMF.com'];
        System.runAs(agentUser) {
            WOO_WMF_Orders__c order = [SELECT Id FROM WOO_WMF_Orders__c];

            Test.startTest();
            order.WOO_SAP_status__c = 'Simulated OK';
            update order;
            Test.stopTest();

            order = [
                SELECT
                    WOO_Account__c,
                    WOO_Account_City__c,
                    WOO_Account_Postal_Code__c,
                    WOO_Account_Street__c
                FROM WOO_WMF_Orders__c
            ];
            System.assertEquals(
                String.isEmpty(order.WOO_Account__c),
                false,
                'Account should be retrieved when Status get to Simulated Ok'
            );
            System.assertEquals(
                String.isEmpty(order.WOO_Account_City__c),
                false,
                'Account City should be retrieved when Status get to Simulated Ok'
            );
            System.assertEquals(
                String.isEmpty(order.WOO_Account_Postal_Code__c),
                false,
                'Account Postal code should be retrieved when Status get to Simulated Ok'
            );
            System.assertEquals(
                String.isEmpty(order.WOO_Account_Street__c),
                false,
                'Account Street should be retrieved when Status get to Simulated Ok'
            );
        }
    }

    @isTest
    private static void orderAccountFieldGenerateErrorWhenEmpty() {
        User agentUser = [SELECT Id FROM User WHERE Username = 'AgentWMF@AgentWMF.com'];
        System.runAs(agentUser) {
            Account acc = [SELECT Id FROM Account LIMIT 1];
            Case c = [SELECT Id, AccountId FROM Case LIMIT 1];
            acc.PersonMailingCity = null;
            update acc;
            WOO_WMF_Orders__c order = (WOO_WMF_Orders__c) TestFactory.createSObject(
                new WOO_WMF_Orders__c(WOO_Case__c = c.Id)
            );
            Boolean orderError = false;
            Test.startTest();
            try {
                insert order;
            } catch (Exception e) {
                orderError = true;
            }
            Test.stopTest();
            System.assertEquals(
                true,
                orderError,
                'An error should be generated when trying to insert an order whith a case which account have no primary address'
            );
        }
    }
}