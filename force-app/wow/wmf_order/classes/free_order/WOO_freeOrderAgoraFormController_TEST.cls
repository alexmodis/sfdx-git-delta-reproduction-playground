@IsTest
public with sharing class WOO_freeOrderAgoraFormController_TEST {
    public class WsAgoraMockService implements WOO_WS_Agora_Orders.InterfaceDef {
        public WOO_WS_Agora_Orders.InterfaceDef loadApiKey(String cccGroup) {
            return this;
        }
        public List<WOO_WS_Agora_Orders.ProductDTO> getProducts(String ref, String countryCode) {
            WOO_WS_Agora_Orders.ProductDTO prod = new WOO_WS_Agora_Orders.ProductDTO();
            prod.AGORAProductKey = 'AGORAProductKey';
            prod.Description = 'Description';
            prod.Refcom = 'Refcom';

            return new List<WOO_WS_Agora_Orders.ProductDTO>{ prod };
        }
        public List<WOO_WS_Agora_Orders.PartDTO> getBomList(String agoraKey) {
            WOO_WS_Agora_Orders.PartDTO part = new WOO_WS_Agora_Orders.PartDTO();
            part.Description = 'Description';
            part.Quantity = 1;
            part.PartRef = 'PartRef';
            part.PublicPrice = 4.51;
            return new List<WOO_WS_Agora_Orders.PartDTO>{ part };
        }
        public WOO_WS_Agora_Orders.CreateRepairResponseData createRepair(
            WOO_WS_Agora_Orders.CompleteRepairDTO createRepair,
            String language
        ) {
            WOO_WS_Agora_Orders.CreateRepairResponseData response = new WOO_WS_Agora_Orders.CreateRepairResponseData();
            response.IsValid = true;
            return response;
        }

        public WOO_WS_Agora_Orders.UpdateRepairResponseData updateRepair(
            WOO_WS_Agora_Orders.CompleteRepairStateDTO updateRepair,
            String language
        ) {
            WOO_WS_Agora_Orders.UpdateRepairResponseData response = new WOO_WS_Agora_Orders.UpdateRepairResponseData();
            response.IsRepairFileValid = true;
            return response;
        }
    }

    @TestSetup
    public static void makeData() {
        User agent = (User) TestFactory.createSObjectAndInsert(
            new User(UserName = 'agentUserNameFreeOrderTests@modis.com'),
            TestFactoryUser.CCCFrontAgent.class
        );
        User admin = (User) TestFactory.createSObjectAndInsert(
            new User(UserName = 'AdminApplicatifInterface@modis.com'),
            TestFactoryUser.AdminApplicatifInterface.class
        );
        System.runAs(admin) {
            Account acc = (Account) TestFactory.createSObjectAndInsert(
                new Account(),
                TestFactoryAccount.WOWConsumer.class
            );
            insert new AccountShare(
                AccountAccessLevel = 'Edit',
                UserOrGroupId = agent.Id,
                AccountId = acc.Id,
                OpportunityAccessLevel = 'None',
                CaseAccessLevel = 'None',
                RowCause = 'Manual'
            );
            Case aCase = (Case) TestFactory.createSObjectAndInsert(
                new Case(
                    Exchange_Agreement_Number__c = '1234567890',
                    ContactId = [SELECT PersonContactId FROM Account WHERE Id = :acc.Id]
                    .PersonContactId,
                    Purchase_Date__c = Date.today(),
                    Case_Country__c = 'FR'
                )
            );
            Product2 prod = (Product2) TestFactory.createSObjectAndInsert(
                new Product2(
                    CMMF__c = 'cmmf',
                    Country__c = 'FR',
                    Reference_commerciale__c = 'longRef'
                )
            );
            Product2 prodGoodwillLine = (Product2) TestFactory.createSObjectAndInsert(
                new Product2(
                    CMMF__c = 'prodGoowWillLine',
                    Code_CMMF__c = 'prodGoowWillLine',
                    Country__c = 'FR',
                    SebUniqueId__c = 'prodGoowWillLine',
                    Reference_commerciale__c = 'prodGoowWillLine',
                    Name = 'prodGoowWillLine'
                )
            );
            TestFactory.createSObjectAndInsert(
                new WOO_WMF_Orders__c(
                    RecordTypeId = CustomMetadataCache.getRecordTypeMapByName()
                        .get('Free_Orders')
                        ?.Id,
                    WOO_Case__c = aCase.Id,
                    Woo_Product__c = prod.Id,
                    WOO_AgoraManufacturingDate__c = '0321',
                    WOO_Order_Type__c = 'FOC',
                    WOO_Agora_Symptoms__c = 'MissingOrRecipeBookDefect',
                    WOO_Agora_Order_Ref__c = 'FOC000015',
                    WOO_Retailer__c = 'AMAZON',
                    WOO_Agora_Retailer_City__c = 'City',
                    WOO_Agora_Retailer_Zipcode__c = 'Zipcode',
                    Product_Country__c = 'FR'
                )
            );
            TestFactory.createSObjectAndInsert(
                new Consumer_Address__c(AccountAddress__c = acc.Id),
                TestFactoryConsumer_Address.MainAddress.class
            );
        }
    }

    public class TestData {
        public User cccAgent = [
            SELECT Id
            FROM User
            WHERE UserName = 'agentUserNameFreeOrderTests@modis.com'
            LIMIT 1
        ];
        public Case aCase = [SELECT Id, Case_CCC__c, AccountId FROM Case LIMIT 1];
        public Product2 prod = [
            SELECT Id, CMMF__c, Reference_commerciale__c, Country__c
            FROM Product2
            LIMIT 1
        ];
        public WOO_WMF_Orders__c order = [
            SELECT Id, WOO_Case__c, Woo_Product__c
            FROM WOO_WMF_Orders__c
            LIMIT 1
        ];
        public Product2 prodGoowWillLine = [
            SELECT Id
            FROM Product2
            WHERE CMMF__c = 'prodGoowWillLine'
            LIMIT 1
        ];
    }

    @IsTest
    static void getProducts() {
        TestData testData = new TestData();
        System.runAs(testData.cccAgent) {
            Test.startTest();
            WOO_WS_Agora_Orders.InterfaceDef mockedWsLayer = new WsAgoraMockService();
            WOO_freeOrderAgoraFormController.webServce = mockedWsLayer;
            WOO_freeOrderAgoraFrontEndDTO.AgoraProductResult prodForFront = WOO_freeOrderAgoraFormController.getProducts(
                testData.aCase.Case_CCC__c,
                testData.prod.Reference_commerciale__c,
                testData.prod.Country__c
            )[0];
            System.assertEquals('AGORAProductKey', prodForFront.agoraKey, 'Wrong value.');
            System.assertEquals('Description', prodForFront.name, 'Wrong value.');
            System.assertEquals('Refcom', prodForFront.referenceCommercial, 'Wrong value.');
        }
        Test.stopTest();
    }
    @IsTest
    static void getBomList() {
        TestData testData = new TestData();

        System.runAs(testData.cccAgent) {
            Test.startTest();
            WOO_WS_Agora_Orders.InterfaceDef mockedWsLayer = new WsAgoraMockService();
            WOO_freeOrderAgoraFormController.webServce = mockedWsLayer;
            WOO_freeOrderAgoraFrontEndDTO.TableRow bomRowForFront = WOO_freeOrderAgoraFormController.getBomList(
                testData.aCase.Case_CCC__c,
                'agoraKey'
            )[0];
            System.assertEquals(1, bomRowForFront.quantity, 'Wrong value.');
            System.assertEquals('Description', bomRowForFront.name, 'Wrong value.');
            System.assertEquals('PartRef', bomRowForFront.reference, 'Wrong value.');
        }
        Test.stopTest();
    }
    @IsTest
    static void searchSfProducts() {
        TestData testData = new TestData();

        System.runAs(testData.cccAgent) {
            List<Product2> prods = new List<Product2>{
                new Product2(
                    Name = 'aabaa',
                    Reference_commerciale__c = 'ref-aabaa',
                    Code_CMMF__c = 'ref-aabaa'
                ),
                new Product2(
                    Name = 'deee',
                    Reference_commerciale__c = 'ref-deee',
                    Code_CMMF__c = 'ref-deee'
                ),
                new Product2(
                    Name = 'rabar',
                    Reference_commerciale__c = 'ref-rabar',
                    Code_CMMF__c = 'ref-rabar'
                )
            };
            insert prods;
            Test.startTest();
            Test.setFixedSearchResults(new List<Id>{ prods[0].Id, prods[2].Id });
            WOO_WS_Agora_Orders.InterfaceDef mockedWsLayer = new WsAgoraMockService();
            WOO_freeOrderAgoraFormController.webServce = mockedWsLayer;
            List<WOO_freeOrderAgoraFrontEndDTO.SfProduct> prodRowsRes = WOO_freeOrderAgoraFormController.searchSfProducts(
                'aba'
            );
            System.assertEquals(2, prodRowsRes.size(), 'Wrong size.');
            System.assertEquals('aabaa', prodRowsRes[0].name, 'Wrong value.');
            System.assertEquals('ref-aabaa', prodRowsRes[0].longRef, 'Wrong value.');
            System.assertEquals('rabar', prodRowsRes[1].name, 'Wrong value.');
            System.assertEquals('ref-rabar', prodRowsRes[1].longRef, 'Wrong value.');
        }
        Test.stopTest();
    }

    @IsTest
    static void addresses() {
        TestData testData = new TestData();
        WOO_WS_Agora_Orders.InterfaceDef mockedWsLayer = new WsAgoraMockService();
        WOO_freeOrderAgoraFormController.webServce = mockedWsLayer;
        List<Consumer_Address__c> adresses;
        Test.startTest();
        System.runAs(testData.cccAgent) {
            adresses = WOO_freeOrderAgoraFormController.addresses(testData.order.Id);
        }
        System.assertEquals(1, adresses.size(), 'Expected 1 adress.');
        System.assertEquals(adresses[0].City__c, 'City', 'Adresse wrong City');
        Test.stopTest();
    }

    @IsTest
    static void checkIfAgoraUserCode() {
        TestData testData = new TestData();
        Test.startTest();
        System.runAs(testData.cccAgent) {
            Boolean hasExceptionBeenThrown = false;
            try {
                WOO_freeOrderAgoraFormController.checkIfAgoraUserCode();
            } catch (AuraHandledException auraException) {
                hasExceptionBeenThrown = true;
            }
            System.assert(
                hasExceptionBeenThrown,
                'AuraHandledException should have been raised because no agora User Code.'
            );
        }
        Test.stopTest();
    }
}