@IsTest
public with sharing class WOO_WMFOrdersTriggerHandler_TEST {
    @TestSetup
    static void makeData() {
        User agent = (User) TestFactory.createSObjectAndInsert(
            new User(UserName = 'agentWithOrderPermissions@modis.test.com'),
            TestFactoryUser.CCCFrontAgent.class
        );
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'WOO_WMF_Order'];
        PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = agent.Id,
            PermissionSetId = ps.id
        );
        insert psa;
        System.runAs((User) TestFactory.createSObject(
            new User(bypass_Triggers__c = TestFactoryUser.bypassAll.replace(';WOO_FreeOrder', '')),
            TestFactoryUser.AdminUserBypassAll.class
        )) {
            Account acc = (Account) TestFactory.createSObjectAndInsert(
                new Account(
                    PersonMailingCity = 'Berlin',
                    PersonMailingPostalCode = '12359',
                    PersonMailingStreet = 'Johannisthaler Chaussee 169'
                ),
                TestFactoryAccount.WOWConsumer.class
            );
            Product2 prodGb = (Product2) TestFactory.createSObjectAndInsert(
                new Product2(
                    CMMF__c = 'cmmf',
                    Country__c = 'GB',
                    Reference_commerciale__c = 'longRef'
                )
            );
            TestFactory.createSObjectAndInsert(
                new Product2(
                    Name = 'prodFR',
                    CMMF__c = 'cmmfFR',
                    Country__c = 'FR',
                    Reference_commerciale__c = 'longRefFR',
                    SebUniqueId__c = 'SebUniqueId__cFR'
                )
            );
            Case aCase = (Case) TestFactory.createSObjectAndInsert(
                new Case(
                    Exchange_Agreement_Number__c = '1234567890',
                    ContactId = [SELECT PersonContactId FROM Account WHERE Id = :acc.Id]
                    .PersonContactId,
                    ProductId = prodGb.Id,
                    Purchase_Date__c = Date.today(),
                    Case_Country__c = 'FR',
                    Product_Country__c = 'GB',
                    Manufacturing_Date__c = '0121',
                    Retailer__c = 'AMAZON'
                )
            );
            TestFactory.createSObjectAndInsert(
                new WOO_WMF_Orders__c(
                    RecordTypeId = CustomMetadataCache.getRecordTypeMapByName()
                        .get('Free_Orders')
                        ?.Id,
                    WOO_Case__c = aCase.Id,
                    WOO_Order_Type__c = 'FOC',
                    WOO_Agora_Symptoms__c = 'MissingOrRecipeBookDefect',
                    WOO_External_Id__c = 'Free_Orders'
                )
            );
            TestFactory.createSObjectAndInsert(
                new WOO_WMF_Orders__c(
                    WOO_Account__c = acc.Id,
                    WOO_Case__c = aCase.id,
                    WOO_Order_Type__c = 'Spare part',
                    WOO_External_Id__c = 'billable order',
                    WOO_Requested_delivery_date__c = Datetime.now().addDays(7).date()
                )
            );
        }
    }

    public class TestData {
        public User cccAgent = [
            SELECT Id
            FROM User
            WHERE UserName = 'agentWithOrderPermissions@modis.test.com'
            LIMIT 1
        ];
        public Case aCase = [
            SELECT Id, Case_CCC__c, AccountId, ProductId, Product_Country__c
            FROM Case
            LIMIT 1
        ];
        public Product2 prodGb = [
            SELECT Id, CMMF__c, Reference_commerciale__c, Country__c
            FROM Product2
            WHERE Country__c = 'GB'
            LIMIT 1
        ];
        public Product2 prodFr = [
            SELECT Id, CMMF__c, Reference_commerciale__c, Country__c
            FROM Product2
            WHERE Country__c = 'FR'
            LIMIT 1
        ];
        public WOO_WMF_Orders__c freeOrder = [
            SELECT Id, WOO_Case__c, Woo_Product__c, WOO_Agora_Order_Ref__c, WOO_Case__r.CaseNumber
            FROM WOO_WMF_Orders__c
            WHERE WOO_External_Id__c = 'Free_Orders'
            LIMIT 1
        ];
        public WOO_WMF_Orders__c billableOrder = [
            SELECT Id, WOO_Case__c, Woo_Product__c
            FROM WOO_WMF_Orders__c
            WHERE WOO_External_Id__c = 'billable order'
            LIMIT 1
        ];
    }

    @IsTest
    static void initBillableOrderFields() {
        Test.startTest();
        TestData testData = new TestData();
        String status = [
            SELECT WOO_SAP_status__c
            FROM WOO_WMF_Orders__c
            WHERE Id = :testData.billableOrder.Id
            LIMIT 1
        ]
        .WOO_SAP_status__c;
        System.assertEquals('Draft', status, 'Wrong status, init value should be "Draft".');
    }

    @IsTest
    static void initFreeOrderFields() {
        Test.startTest();
        TestData testData = new TestData();
        WOO_WMF_Orders__c orderCreatedByAgent;
        System.runAs(testData.cccAgent) {
            orderCreatedByAgent = (WOO_WMF_Orders__c) TestFactory.createSObjectAndInsert(
                new WOO_WMF_Orders__c(
                    RecordTypeId = CustomMetadataCache.getRecordTypeMapByName()
                        .get('Free_Orders')
                        ?.Id,
                    WOO_Case__c = testData.aCase.Id,
                    WOO_Order_Type__c = 'FEX',
                    WOO_Agora_Symptoms__c = 'DefectiveProduct'
                )
            );
        }
        orderCreatedByAgent = [
            SELECT
                WOO_Account__c,
                Woo_Product__c,
                WOO_AgoraManufacturingDate__c,
                Product_Country__c,
                WOO_Retailer__c
            FROM WOO_WMF_Orders__c
            WHERE Id = :orderCreatedByAgent.Id
        ];
        System.assertEquals(
            testData.aCase.AccountId,
            orderCreatedByAgent.WOO_Account__c,
            'Field WOO_Account__c should have been copied from case.'
        );
        System.assertEquals(
            testData.aCase.ProductId,
            orderCreatedByAgent.Woo_Product__c,
            'Field Woo_Product__c should have been copied from case.'
        );
        System.assertEquals(
            '0121',
            orderCreatedByAgent.WOO_AgoraManufacturingDate__c,
            'Field WOO_AgoraManufacturingDate__c should have been copied from case.'
        );
        System.assertEquals(
            'GB',
            orderCreatedByAgent.Product_Country__c,
            'Field Product_Country__c should have been copied from case.'
        );
        System.assertEquals(
            'AMAZON',
            orderCreatedByAgent.WOO_Retailer__c,
            'Field WOO_Retailer__c should have been copied from case.'
        );
        Test.stopTest();
    }

    @IsTest
    static void buildAgoraRef() {
        Test.startTest();
        TestData testData = new TestData();
        WOO_WMF_Orders__c orderFOC;
        WOO_WMF_Orders__c orderFEX;
        WOO_WMF_Orders__c orderFocGoodwillProduct;
        WOO_WMF_Orders__c orderFocGoodwillSpareParts;
        System.runAs(testData.cccAgent) {
            orderFOC = (WOO_WMF_Orders__c) TestFactory.createSObjectAndInsert(
                new WOO_WMF_Orders__c(
                    RecordTypeId = CustomMetadataCache.getRecordTypeMapByName()
                        .get('Free_Orders')
                        ?.Id,
                    WOO_Case__c = testData.aCase.Id,
                    WOO_Order_Type__c = 'FOC',
                    WOO_Agora_Symptoms__c = 'MissingOrRecipeBookDefect'
                )
            );
            orderFEX = (WOO_WMF_Orders__c) TestFactory.createSObjectAndInsert(
                new WOO_WMF_Orders__c(
                    RecordTypeId = CustomMetadataCache.getRecordTypeMapByName()
                        .get('Free_Orders')
                        ?.Id,
                    WOO_Case__c = testData.aCase.Id,
                    WOO_Order_Type__c = 'FEX',
                    WOO_Agora_Symptoms__c = 'DefectiveProduct'
                )
            );
            orderFocGoodwillProduct = (WOO_WMF_Orders__c) TestFactory.createSObject(
                new WOO_WMF_Orders__c(
                    RecordTypeId = CustomMetadataCache.getRecordTypeMapByName()
                        .get('Free_Orders_Subsidiary')
                        ?.Id,
                    WOO_Case__c = testData.aCase.Id,
                    Main_Order__c = orderFOC.Id,
                    WOO_Order_Type__c = 'Goodwill_Product',
                    WOO_Agora_Symptoms__c = 'GoodwillGesture'
                )
            );
            orderFocGoodwillSpareParts = (WOO_WMF_Orders__c) TestFactory.createSObject(
                new WOO_WMF_Orders__c(
                    RecordTypeId = CustomMetadataCache.getRecordTypeMapByName()
                        .get('Free_Orders_Subsidiary')
                        ?.Id,
                    WOO_Case__c = testData.aCase.Id,
                    Main_Order__c = orderFOC.Id,
                    WOO_Order_Type__c = 'Goodwill_SpareParts',
                    WOO_Agora_Symptoms__c = 'GoodwillGesture'
                )
            );
            insert new List<WOO_WMF_Orders__c>{
                orderFocGoodwillProduct,
                orderFocGoodwillSpareParts
            };
        }
        orderFOC = [
            SELECT WOO_Agora_Order_Ref__c, WOO_Case__r.CaseNumber
            FROM WOO_WMF_Orders__c
            WHERE Id = :orderFOC.Id
        ];
        orderFEX = [
            SELECT WOO_Agora_Order_Ref__c, WOO_Case__r.CaseNumber
            FROM WOO_WMF_Orders__c
            WHERE Id = :orderFEX.Id
        ];
        orderFocGoodwillProduct = [
            SELECT WOO_Agora_Order_Ref__c, WOO_Case__r.CaseNumber
            FROM WOO_WMF_Orders__c
            WHERE Id = :orderFocGoodwillProduct.Id
        ];
        orderFocGoodwillSpareParts = [
            SELECT WOO_Agora_Order_Ref__c, WOO_Case__r.CaseNumber
            FROM WOO_WMF_Orders__c
            WHERE Id = :orderFocGoodwillSpareParts.Id
        ];

        System.assertEquals(
            'FOC' + testData.freeOrder.WOO_Case__r.CaseNumber,
            testData.freeOrder.WOO_Agora_Order_Ref__c,
            'Field WOO_Agora_Order_Ref__c has an error.'
        );
        System.assertEquals(
            'FOC' +
            orderFOC.WOO_Case__r.CaseNumber +
            '-1',
            orderFOC.WOO_Agora_Order_Ref__c,
            'Field WOO_Agora_Order_Ref__c has an error.'
        );
        System.assertEquals(
            'FEX' +
            orderFEX.WOO_Case__r.CaseNumber +
            '-2',
            orderFEX.WOO_Agora_Order_Ref__c,
            'Field WOO_Agora_Order_Ref__c has an error.'
        );
        System.assertEquals(
            'GW' +
            orderFocGoodwillProduct.WOO_Case__r.CaseNumber +
            '-3',
            orderFocGoodwillProduct.WOO_Agora_Order_Ref__c,
            'Field WOO_Agora_Order_Ref__c has an error.'
        );
        System.assertEquals(
            'GW' +
            orderFocGoodwillSpareParts.WOO_Case__r.CaseNumber +
            '-4',
            orderFocGoodwillSpareParts.WOO_Agora_Order_Ref__c,
            'Field WOO_Agora_Order_Ref__c has an error.'
        );
    }

    @IsTest
    static void copyOrderFieldsToCase() {
        TestData testData = new TestData();
        System.runAs(testData.cccAgent) {
            Test.startTest();
            testData.freeOrder.Product_Country__c = 'FR';
            testData.freeOrder.Woo_Product__c = testData.prodFr.Id;
            testData.freeOrder.WOO_AgoraManufacturingDate__c = '0219';
            testData.freeOrder.WOO_Retailer__c = 'GROUPE SEB WEBSITE';
            update testData.freeOrder;
            Test.stopTest();
            String orderProdCountry = [
                SELECT Product_Country__c
                FROM WOO_WMF_Orders__c
                WHERE Id = :testData.freeOrder.Id
                LIMIT 1
            ]
            .Product_Country__c;
            System.assertEquals(
                'FR',
                orderProdCountry,
                'The Product country should have been copied to Product_Country__c.'
            );
            Case parentCase = [
                SELECT ProductId, Manufacturing_Date__c, Retailer__c, Product_Country__c
                FROM Case
                WHERE Id = :testData.aCase.Id
            ];
            System.assertEquals('FR', parentCase.Product_Country__c, 'Error Product_Country__c');
            System.assertEquals(testData.prodFr.Id, parentCase.ProductId, 'Error ProductId');
            System.assertEquals(
                '0219',
                parentCase.Manufacturing_Date__c,
                'Error Manufacturing_Date__c'
            );
            System.assertEquals('GROUPE SEB WEBSITE', parentCase.Retailer__c, 'Error Retailer__c');
        }
    }

    @IsTest
    static void preventDeletionOfFreeOrderSentToAgora() {
        TestData testData = new TestData();
        Boolean hasDeletionBeenPrevented = false;
        System.runAs(testData.cccAgent) {
            testData.freeOrder.WOO_SAP_status__c = 'SentWithErrors';
            update testData.freeOrder;
            Test.startTest();
            try {
                delete testData.freeOrder;
            } catch (Exception e) {
                hasDeletionBeenPrevented = true;
            }
            Test.stopTest();
        }
        System.assertEquals(true, hasDeletionBeenPrevented, 'Deletion should have been prevented');
    }

    @IsTest
    static void initOrderAccountAddressField() {
        TestData testData = new TestData();
        System.runAs(testData.cccAgent) {
            Test.startTest();
            TestFactory.createSObjectAndInsert(
                new WOO_WMF_Orders__c(
                    WOO_Case__c = TestData.aCase.Id,
                    WOO_External_Id__c = 'testOrder'
                )
            );
            Test.stopTest();
        }
        WOO_WMF_Orders__c order = [
            SELECT
                WOO_Account__c,
                WOO_Account_City__c,
                WOO_Account_Postal_Code__c,
                WOO_Account_Street__c
            FROM WOO_WMF_Orders__c
            WHERE WOO_External_Id__c = 'testOrder'
        ];
        Account acc = [
            SELECT Id, PersonMailingCity, PersonMailingPostalCode, PersonMailingStreet
            FROM Account
            WHERE PersonMailingCity = 'Berlin'
        ];
        System.assertEquals(
            acc.Id,
            order.WOO_Account__c,
            'Account should be retrieved when order created'
        );
        System.assertEquals(
            acc.PersonMailingCity,
            order.WOO_Account_City__c,
            'Account main address city should be retrieved when order created'
        );
        System.assertEquals(
            acc.PersonMailingPostalCode,
            order.WOO_Account_Postal_Code__c,
            'Account main address postal code should be retrieved when order created'
        );
        System.assertEquals(
            acc.PersonMailingStreet,
            order.WOO_Account_Street__c,
            'Account main address street should be retrieved when order created'
        );
    }
}