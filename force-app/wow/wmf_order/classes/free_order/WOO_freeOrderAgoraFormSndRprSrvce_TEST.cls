@IsTest
public with sharing class WOO_freeOrderAgoraFormSndRprSrvce_TEST {
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
    static void makeData() {
        WOO_freeOrderAgoraFormController_TEST.makeData();
    }

    private static WOO_freeOrderAgoraFrontEndDTO.SendOrderBase buildFrontBaseOrder(
        WOO_freeOrderAgoraFormController_TEST.TestData testData
    ) {
        WOO_freeOrderAgoraFrontEndDTO.SendOrderBase orderFrontBase = new WOO_freeOrderAgoraFrontEndDTO.SendOrderBase();
        orderFrontBase.mainOrderId = testData.order.Id;

        orderFrontBase.consumerAddress = new WOO_freeOrderAgoraFrontEndDTO.Address();
        orderFrontBase.consumerAddress.city = 'city';
        orderFrontBase.consumerAddress.country = 'FR';
        orderFrontBase.consumerAddress.postalCode = 'postalCode';
        orderFrontBase.consumerAddress.street = 'street';
        orderFrontBase.consumerAddress.title = 'title';
        return orderFrontBase;
    }
    private static WOO_freeOrderAgoraFrontEndDTO.SendOrderMain buildFrontMainOrder(
        WOO_freeOrderAgoraFormController_TEST.TestData testData
    ) {
        WOO_freeOrderAgoraFrontEndDTO.SendOrderMain frontOrderMain = new WOO_freeOrderAgoraFrontEndDTO.SendOrderMain();
        frontOrderMain.orderProduct = new WOO_freeOrderAgoraFrontEndDTO.AgoraProductResult();
        frontOrderMain.orderProduct.agoraKey = 'agoraKey';
        frontOrderMain.orderProduct.manufactoryDate = 'manufactoryDate';
        frontOrderMain.orderProduct.name = 'name';
        frontOrderMain.orderProduct.referenceCommercial = 'referenceCommercial';
        frontOrderMain.orderProduct.referenceTechnique = 'referenceTechnique';
        frontOrderMain.bomList = new List<WOO_freeOrderAgoraFrontEndDTO.TableRow>();
        WOO_freeOrderAgoraFrontEndDTO.TableRow sparePart1 = new WOO_freeOrderAgoraFrontEndDTO.TableRow();
        sparePart1.name = 'name';
        sparePart1.pru = 1.5;
        sparePart1.quantity = 2;
        sparePart1.quantitySelected = 1;
        sparePart1.reference = 'reference';
        sparePart1.type = 'BOM';
        frontOrderMain.bomList.add(sparePart1);
        frontOrderMain.bomList.add(sparePart1);
        return frontOrderMain;
    }

    private static WOO_freeOrderAgoraFrontEndDTO.SendRepairGoodwillSpareParts buildFrontGwSparePartsOrder(
        WOO_freeOrderAgoraFormController_TEST.TestData testData
    ) {
        WOO_freeOrderAgoraFrontEndDTO.SendRepairGoodwillSpareParts frontOrderGwSpareParts = new WOO_freeOrderAgoraFrontEndDTO.SendRepairGoodwillSpareParts();
        frontOrderGwSpareParts.goodwillSpareParts = new List<WOO_freeOrderAgoraFrontEndDTO.TableRow>();
        WOO_freeOrderAgoraFrontEndDTO.TableRow sparePart1 = new WOO_freeOrderAgoraFrontEndDTO.TableRow();
        sparePart1.name = 'name';
        sparePart1.pru = 1.5;
        sparePart1.quantity = 2;
        sparePart1.quantitySelected = 1;
        sparePart1.reference = 'reference';
        sparePart1.type = 'BOM';
        frontOrderGwSpareParts.goodwillSpareParts.add(sparePart1);

        frontOrderGwSpareParts.orderProduct = new WOO_freeOrderAgoraFrontEndDTO.AgoraProductResult();
        frontOrderGwSpareParts.orderProduct.agoraKey = 'agoraKey';
        frontOrderGwSpareParts.orderProduct.manufactoryDate = 'manufactoryDate';
        frontOrderGwSpareParts.orderProduct.name = 'name';
        frontOrderGwSpareParts.orderProduct.referenceCommercial = 'referenceCommercial';
        frontOrderGwSpareParts.orderProduct.referenceTechnique = 'referenceTechnique';
        return frontOrderGwSpareParts;
    }

    private static WOO_freeOrderAgoraFrontEndDTO.SendRepairGoodwillProduct buildFrontGwProdOrder(
        WOO_freeOrderAgoraFormController_TEST.TestData testData
    ) {
        WOO_freeOrderAgoraFrontEndDTO.SendRepairGoodwillProduct frontOrderGwProd = new WOO_freeOrderAgoraFrontEndDTO.SendRepairGoodwillProduct();
        WOO_freeOrderAgoraFrontEndDTO.TableRow goodwillProd1 = new WOO_freeOrderAgoraFrontEndDTO.TableRow();
        goodwillProd1.name = 'name';
        goodwillProd1.pru = 0;
        goodwillProd1.quantity = 1;
        goodwillProd1.quantitySelected = 1;
        goodwillProd1.reference = 'reference';
        goodwillProd1.type = 'PROD';
        goodwillProd1.sfProductId = testData.prodGoowWillLine.Id;

        frontOrderGwProd.goodwillProduct = goodwillProd1;
        return frontOrderGwProd;
    }

    @IsTest
    static void sendMainOrder() {
        WOO_freeOrderAgoraFormController_TEST.TestData testData = new WOO_freeOrderAgoraFormController_TEST.TestData();
        WOO_freeOrderAgoraFrontEndDTO.SendOrderBase frontOrderBase = buildFrontBaseOrder(testData);
        WOO_freeOrderAgoraFrontEndDTO.SendOrderMain frontOrderMain = buildFrontMainOrder(testData);
        WOO_WS_Agora_Orders.InterfaceDef mockedWsLayer = new WsAgoraMockService();
        WOO_freeOrderAgoraFrontEndDTO.CreateRepairFrontResponse response;
        System.runAs(testData.cccAgent) {
            Test.startTest();
            response = new WOO_freeOrderAgoraFormSendRepairService(mockedWsLayer, frontOrderBase)
                .sendMainOrder(frontOrderMain);
            Test.stopTest();
        }
        System.assertNotEquals(null, response, 'Null Response');
        System.assertEquals(true, response.isValid, 'Response should be valid');
        WOO_WMF_Orders__c order = WOO_freeOrderAgoraFormSendRepairUtil.getOrderAndCheckFields(
            testData.order.Id
        );
        System.assertEquals(
            PicklistWoo_wmf_orders_c.WOO_SAP_STATUS_C_SENT,
            order.WOO_SAP_status__c,
            'Wrong order status.'
        );
        List<WOO_WMF_Order_Line_Item__c> childrenLines = [
            SELECT Id
            FROM WOO_WMF_Order_Line_Item__c
            WHERE WOO_WMF_Order__c = :testData.order.Id
        ];
        System.assertEquals(
            2,
            childrenLines.size(),
            'Should have 2 order Line Items for 2 spare Part lines.'
        );
    }

    @IsTest
    static void sendGoodwillSparePartsOrder() {
        WOO_freeOrderAgoraFormController_TEST.TestData testData = new WOO_freeOrderAgoraFormController_TEST.TestData();
        WOO_freeOrderAgoraFrontEndDTO.SendOrderBase frontOrderBase = buildFrontBaseOrder(testData);
        WOO_freeOrderAgoraFrontEndDTO.SendRepairGoodwillSpareParts frontOrderGwSpareParts = buildFrontGwSparePartsOrder(
            testData
        );
        WOO_WS_Agora_Orders.InterfaceDef mockedWsLayer = new WsAgoraMockService();
        WOO_freeOrderAgoraFrontEndDTO.CreateRepairFrontResponse response;
        System.runAs(testData.cccAgent) {
            Test.startTest();
            response = new WOO_freeOrderAgoraFormSendRepairService(mockedWsLayer, frontOrderBase)
                .sendGoodwillSparePartsOrder(frontOrderGwSpareParts);
            Test.stopTest();
        }
        System.assertNotEquals(null, response, 'Null Response');
        System.assertEquals(true, response.isValid, 'Response should be valid');

        WOO_freeOrderAgoraFrontEndDTO.SubOrdersAndLines subOrderAndLines = WOO_freeOrderAgoraFormController.getSubOrdersAndLines(
            testData.order.Id
        );
        System.assertEquals(
            1,
            subOrderAndLines.subOrdersAndLines.size(),
            'Should have only 1 subsidiary order.'
        );
        System.assertEquals(
            PicklistWoo_wmf_orders_c.WOO_SAP_STATUS_C_SENT,
            subOrderAndLines.subOrdersAndLines[0].WOO_SAP_STATUS__C,
            'subsidiary order should have status "Sent".'
        );
        System.assertEquals(
            PicklistWoo_wmf_orders_c.WOO_ORDER_TYPE_C_GOODWILL_SPAREPARTS,
            subOrderAndLines.subOrdersAndLines[0].WOO_ORDER_TYPE__C,
            'Should have a subsidiary order of type GOODWILL_SPAREPARTS.'
        );
        System.assertEquals(
            1,
            subOrderAndLines.subOrdersAndLines[0].WMF_Order_Line_Items__r.size(),
            'Should have 1 Line on the subsidiary order.'
        );
    }
    @IsTest
    static void sendGoodwillProductOrder() {
        WOO_freeOrderAgoraFormController_TEST.TestData testData = new WOO_freeOrderAgoraFormController_TEST.TestData();
        WOO_freeOrderAgoraFrontEndDTO.SendOrderBase frontOrderBase = buildFrontBaseOrder(testData);
        WOO_freeOrderAgoraFrontEndDTO.SendRepairGoodwillProduct inputGoodwillProductOrder = buildFrontGwProdOrder(
            testData
        );
        WOO_WS_Agora_Orders.InterfaceDef mockedWsLayer = new WsAgoraMockService();
        WOO_freeOrderAgoraFrontEndDTO.CreateRepairFrontResponse response;
        System.runAs(testData.cccAgent) {
            Test.startTest();
            response = new WOO_freeOrderAgoraFormSendRepairService(mockedWsLayer, frontOrderBase)
                .sendGoodwillProductOrder(inputGoodwillProductOrder);
            Test.stopTest();
        }
        System.assertNotEquals(null, response, 'Null Response');
        System.assertEquals(true, response.isValid, 'Response should be valid');

        WOO_freeOrderAgoraFrontEndDTO.SubOrdersAndLines subOrderAndLines = WOO_freeOrderAgoraFormController.getSubOrdersAndLines(
            testData.order.Id
        );
        System.assertEquals(
            1,
            subOrderAndLines.subOrdersAndLines.size(),
            'Should have only 1 subsidiary order.'
        );
        System.assertEquals(
            PicklistWoo_wmf_orders_c.WOO_SAP_STATUS_C_SENT,
            subOrderAndLines.subOrdersAndLines[0].WOO_SAP_STATUS__C,
            'subsidiary order should have status "Sent".'
        );
        System.assertEquals(
            PicklistWoo_wmf_orders_c.WOO_ORDER_TYPE_C_GOODWILL_PRODUCT,
            subOrderAndLines.subOrdersAndLines[0].WOO_ORDER_TYPE__C,
            'Should have a subsidiary order of type WOO_ORDER_TYPE_C_GOODWILL_PRODUCT.'
        );
        System.assertEquals(
            0,
            subOrderAndLines.subOrdersAndLines[0].WMF_Order_Line_Items__r.size(),
            'Should have 0 Line on the subsidiary order.'
        );
    }
}