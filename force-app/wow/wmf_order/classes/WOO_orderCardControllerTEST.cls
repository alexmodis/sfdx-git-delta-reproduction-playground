@IsTest
public with sharing class WOO_orderCardControllerTEST {
    private static User agentSetupTestUser;
    private static User agentUser;

    static {
        agentSetupTestUser = (User) TestFactory.createSObject(
            new User(),
            TestFactoryUser.CCCBackAgent.class
        );
        agentUser = (User) TestFactory.createSObject(
            new User(Username = 'AgentWMF@example.com.' + UserInfo.getOrganizationId()),
            TestFactoryUser.CCCBackAgent.class
        );
    }

    @TestSetup
    static void setup() {
        System.runAs(agentSetupTestUser) {
            Account acc = (Account) TestFactory.createSObjectAndInsert(
                new Account(
                    PersonMailingCity = 'Berlin',
                    PersonMailingPostalCode = '12359',
                    PersonMailingStreet = 'Johannisthaler Chaussee 169'
                )
            );
            acc = [
                SELECT id, personcontactid
                FROM Account
                WHERE PersonEmail = 'email@testtest.com'
            ];
            Case c = (Case) TestFactory.createSObjectAndInsert(
                new Case(AccountId = acc.id, ContactId = acc.personcontactid)
            );

            Id finishedProductRecordType = [
                SELECT Id
                FROM RecordType
                WHERE sObjectType = 'Product2' AND Name = 'Spare parts'
                LIMIT 1
            ]
            .Id;

            list<Product2> p = new List<Product2>();
            p.add(
                (Product2) TestFactory.createSObject(
                    new Product2(CMMF__c = 'P1', RecordTypeId = finishedProductRecordType),
                    TestFactoryProduct2.wooSparPart.class
                )
            );
            p.add(
                (Product2) TestFactory.createSObject(
                    new Product2(CMMF__c = 'P2', RecordTypeId = finishedProductRecordType),
                    TestFactoryProduct2.wooSparPart.class
                )
            );
            p.add(
                (Product2) TestFactory.createSObject(
                    new Product2(CMMF__c = 'P3', RecordTypeId = finishedProductRecordType),
                    TestFactoryProduct2.wooSparPart.class
                )
            );

            insert p;

            list<WOO_WMF_Orders__c> order = new List<WOO_WMF_Orders__c>();
            order.add(
                (WOO_WMF_Orders__c) TestFactory.createSObject(
                    new WOO_WMF_Orders__c(
                        WOO_Account__c = acc.Id,
                        WOO_Case__c = c.id,
                        WOO_Order_Type__c = 'Spare part',
                        WOO_External_Id__c = 'onOrderLine',
                        WOO_Requested_delivery_date__c = Datetime.now().addDays(7).date(),
                        WOO_Error_Message__c = 'Past simulation error'
                    )
                )
            );
            order.add(
                (WOO_WMF_Orders__c) TestFactory.createSObject(
                    new WOO_WMF_Orders__c(
                        WOO_Account__c = acc.Id,
                        WOO_Case__c = c.id,
                        WOO_Order_Type__c = 'Spare part',
                        WOO_External_Id__c = 'twoOrderLine',
                        WOO_Requested_delivery_date__c = Datetime.now().addDays(7).date()
                    )
                )
            );
            insert order;

            list<WOO_WMF_Order_Line_Item__c> orderLineItem = new List<WOO_WMF_Order_Line_Item__c>();
            orderLineItem.add(
                (WOO_WMF_Order_Line_Item__c) TestFactory.createSObject(
                    new WOO_WMF_Order_Line_Item__c(
                        WOO_WMF_Order__r = new WOO_WMF_Orders__c(
                            WOO_External_Id__c = 'onOrderLine'
                        ),
                        WOO_Product__c = p[0].Id,
                        WOO_Requested_quantity__c = 1
                    )
                )
            );
            orderLineItem.add(
                (WOO_WMF_Order_Line_Item__c) TestFactory.createSObject(
                    new WOO_WMF_Order_Line_Item__c(
                        WOO_WMF_Order__r = new WOO_WMF_Orders__c(
                            WOO_External_Id__c = 'twoOrderLine'
                        ),
                        WOO_Product__c = p[1].Id,
                        WOO_Requested_quantity__c = 1
                    )
                )
            );
            orderLineItem.add(
                (WOO_WMF_Order_Line_Item__c) TestFactory.createSObject(
                    new WOO_WMF_Order_Line_Item__c(
                        WOO_WMF_Order__r = new WOO_WMF_Orders__c(
                            WOO_External_Id__c = 'twoOrderLine'
                        ),
                        WOO_Product__c = p[2].Id,
                        WOO_Requested_quantity__c = 1
                    )
                )
            );
            upsert orderLineItem;
        }
    }

    @IsTest
    static void successSimulateOneLine() {
        WOO_WMF_Orders__c order = [
            SELECT Id
            FROM WOO_WMF_Orders__c
            WHERE WOO_External_Id__c = 'onOrderLine'
        ];
        Test.setMock(WebServiceMock.class, new WOO_orderSimulateSoapWrapperMock.SuccessOneLine());

        System.runAs(agentUser) {
            Test.startTest();
            string result = WOO_orderCardController.getSimulateCall(order.id);
            Test.stopTest();
        }
        order = [
            SELECT Id, WOO_SAP_Status__c, WOO_Total_Amount__c
            FROM WOO_WMF_Orders__c
            WHERE WOO_External_Id__c = 'onOrderLine'
        ];
        WOO_WMF_Order_Line_Item__c orderLineItem = [
            SELECT WOO_CMMF_in_case_of_replacement__c
            FROM WOO_WMF_Order_Line_Item__c
            WHERE WOO_WMF_Order__c = :order.Id
        ];

        System.assertEquals(
            '1234567890',
            orderLineItem.WOO_CMMF_in_case_of_replacement__c,
            'Field should be filled if SAP send a replacment CMMF without first eight char'
        );
        System.assertEquals(
            'Simulated OK',
            order.WOO_SAP_Status__c,
            'SAP status must be Simulated Ok when no errors are returned'
        );
        System.assertEquals(
            50.00,
            order.WOO_Total_Amount__c,
            'The price must be updated after call'
        );
    }

    @IsTest
    static void successSimulateTwoLine() {
        WOO_WMF_Orders__c order = [
            SELECT Id
            FROM WOO_WMF_Orders__c
            WHERE WOO_External_Id__c = 'twoOrderLine'
        ];
        Test.setMock(WebServiceMock.class, new WOO_orderSimulateSoapWrapperMock.SuccessTwoLine());

        System.runAs(agentUser) {
            Test.startTest();
            string result = WOO_orderCardController.getSimulateCall(order.id);
            Test.stopTest();
        }
        order = [
            SELECT Id, WOO_SAP_Status__c, WOO_Total_Amount__c
            FROM WOO_WMF_Orders__c
            WHERE WOO_External_Id__c = 'twoOrderLine'
        ];
        System.assertEquals(
            'Simulated OK',
            order.WOO_SAP_Status__c,
            'SAP status must be Simulated Ok when no errors are returned'
        );
        System.assertEquals(
            30.00,
            order.WOO_Total_Amount__c,
            'The price must be updated after call'
        );
    }

    @IsTest
    static void successSimulateTwoLineWithSchedulesOut() {
        WOO_WMF_Orders__c order = [
            SELECT Id
            FROM WOO_WMF_Orders__c
            WHERE WOO_External_Id__c = 'twoOrderLine'
        ];
        Test.setMock(
            WebServiceMock.class,
            new WOO_orderSimulateSoapWrapperMock.SuccessTwoLineWithSchedulesOut()
        );

        System.runAs(agentUser) {
            Test.startTest();
            WOO_orderCardController.getSimulateCall(order.id);
            Test.stopTest();
        }
        order = [
            SELECT Id, WOO_SAP_Status__c, WOO_Total_Amount__c
            FROM WOO_WMF_Orders__c
            WHERE WOO_External_Id__c = 'twoOrderLine'
        ];
        System.assertEquals(
            'Simulated OK',
            order.WOO_SAP_Status__c,
            'SAP status must be Simulated Ok when no errors are returned'
        );
        System.assertEquals(
            30.00,
            order.WOO_Total_Amount__c,
            'The price must be updated after call'
        );

        List<WOO_WMF_Order_Line_Item__c> relatedOrderLines = [
            SELECT WOO_Confirmed_quantity__c, WOO_Returned_delivery_date__c
            FROM WOO_WMF_Order_Line_Item__c
            WHERE WOO_WMF_Order__c = :order.Id
            ORDER BY WOO_Confirmed_quantity__c ASC
        ];
        System.assertEquals(2, relatedOrderLines.size(), 'Should be 2.');

        System.assertEquals(
            1,
            relatedOrderLines[0].WOO_Confirmed_quantity__c,
            'There is a problem with the scheduled line 1'
        );
        System.assertEquals(
            Date.newInstance(2020, 7, 21),
            relatedOrderLines[0].WOO_Returned_delivery_date__c,
            'There is a problem with the scheduled line 1'
        );

        System.assertEquals(
            2,
            relatedOrderLines[1].WOO_Confirmed_quantity__c,
            'There is a problem with the scheduled line 2'
        );
        System.assertEquals(
            Date.newInstance(2020, 7, 23),
            relatedOrderLines[1].WOO_Returned_delivery_date__c,
            'There is a problem with the scheduled line 2'
        );
    }

    @IsTest
    static void errorSimulateOneLine() {
        WOO_WMF_Orders__c order = [
            SELECT Id
            FROM WOO_WMF_Orders__c
            WHERE WOO_External_Id__c = 'onOrderLine'
        ];
        Test.setMock(WebServiceMock.class, new WOO_orderSimulateSoapWrapperMock.ErrorLine());

        System.runAs(agentUser) {
            Test.startTest();
            string result = WOO_orderCardController.getSimulateCall(order.id);
            Test.stopTest();
        }
        order = [
            SELECT Id, WOO_SAP_Status__c, WOO_Total_Amount__c, WOO_Error_Message__c
            FROM WOO_WMF_Orders__c
            WHERE WOO_External_Id__c = 'onOrderLine'
        ];
        System.assertEquals(
            'Error, bad value',
            order.WOO_Error_Message__c,
            'Error message should be filled with responge error'
        );
        System.assertEquals(
            'Simulated with errors',
            order.WOO_SAP_Status__c,
            'SAP status must be Simulated with errors when errors are returned'
        );
        System.assertEquals(
            0.00,
            order.WOO_Total_Amount__c,
            'The price must not be updated after call if error'
        );
    }

    @IsTest
    static void emptyErrorMessageWhenSimulatedOkAfterSimulatedError() {
        WOO_WMF_Orders__c order = [
            SELECT Id
            FROM WOO_WMF_Orders__c
            WHERE WOO_External_Id__c = 'onOrderLine'
        ];

        Test.setMock(WebServiceMock.class, new WOO_orderSimulateSoapWrapperMock.SuccessOneLine());

        System.runAs(agentUser) {
            Test.startTest();
            string result = WOO_orderCardController.getSimulateCall(order.id);
            Test.stopTest();
        }
        order = [
            SELECT WOO_Error_Message__c
            FROM WOO_WMF_Orders__c
            WHERE WOO_External_Id__c = 'onOrderLine'
        ];
        System.assertEquals(
            null,
            order.WOO_Error_Message__c,
            'Error message should be emptied if simulated Ok after simulated with error'
        );
    }

    @IsTest
    static void codeCoverage() {
        WOO_WMF_Orders__c order = [
            SELECT Id
            FROM WOO_WMF_Orders__c
            WHERE WOO_External_Id__c = 'onOrderLine'
        ];

        Test.setMock(WebServiceMock.class, new WOO_orderSimulateSoapWrapperMock.AllLine());

        System.runAs(agentUser) {
            Test.startTest();
            string result = WOO_orderCardController.getSimulateCall(order.id);
            Test.stopTest();
        }
        System.assert(true, 'Not a test');
    }
}