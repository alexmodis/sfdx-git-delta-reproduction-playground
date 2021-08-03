@isTest
public with sharing class WOO_WS_Agora_Orders_TEST {
    @IsTest
    static void mapAlpha2ToNumberCountryISO() {
        User cccAgent = (User) TestFactory.createSObject(
            new User(),
            TestFactoryUser.CCCFrontAgent.class
        );
        Test.startTest();
        System.runAs(cccAgent) {
            System.assertEquals(
                '250',
                WOO_WS_Agora_Orders.mapAlpha2ToNumberCountryISO('FR'),
                'Error with mapAlpha2ToNumberCountryISO.'
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void throwIfWSError() {
        User cccAgent = (User) TestFactory.createSObject(
            new User(),
            TestFactoryUser.CCCFrontAgent.class
        );
        HttpResponse fakeResponse = new HttpResponse();
        fakeResponse.setStatusCode(500);
        Test.startTest();
        System.runAs(cccAgent) {
            try {
                WOO_WS_Agora_Orders.throwIfWSError(fakeResponse);
            } catch (AuraHandledException exceptionAura) {
                return;
            }
            System.assert(false, 'And Aura exception should have raised and catched.');
        }
        Test.stopTest();
    }

    @IsTest
    static void requiredFieldCheck() {
        Test.startTest();
        WOO_WS_Agora_Orders.CompleteRepairDTO updateRepair = generateupdateRepair();
        System.assertEquals(
            false,
            updateRepair.hasRequiredFieldMissing(),
            'No required field should be considered as missing.'
        );
        Boolean hasExceptionHappend = false;
        try {
            updateRepair.Consumer.Phone = null;
            updateRepair.hasRequiredFieldMissing();
        } catch (Exception error) {
            hasExceptionHappend = true;
        }
        System.assert(
            hasExceptionHappend,
            'Phone field should be missing and an exception should have been raised.'
        );
        Test.stopTest();
    }

    @IsTest
    static void getProducts() {
        User cccAgent = (User) TestFactory.createSObject(
            new User(),
            TestFactoryUser.CCCFrontAgent.class
        );
        Test.setMock(
            HttpCalloutMock.class,
            new MockHttpResponseGenerator(
                '{' +
                '    "ResponseStatus": "S",' +
                '    "IsValid": true,' +
                '    "ResponseMessage": "1 products found.",' +
                '    "ResponseErrorMessage": null,' +
                '    "ResponseData": [' +
                '        {' +
                '            "ManufacturerId": 15,' +
                '            "BrandLabel": "WMF",' +
                '            "Description": "COUVERT ATRIA",' +
                '            "Refcom": "1276649990",' +
                '            "Reftech": "3201000331",' +
                '            "AGORAProductKey": "po7%2fJQ1ZMZFFSTG7wI4mrA%3d%3d"' +
                '        }' +
                '    ]' +
                '}',
                200
            )
        );

        System.runAs(cccAgent) {
            Test.startTest();
            List<WOO_WS_Agora_Orders.ProductDTO> products = new WOO_WS_Agora_Orders()
                .loadApiKey('FRANCE')
                .getProducts('ref', 'FR');
            System.assertNotEquals(null, products, 'Product DTO should have been generated');
            Test.stopTest();
        }
    }

    @IsTest
    static void getBomList() {
        Test.setMock(
            HttpCalloutMock.class,
            new MockHttpResponseGenerator(
                '{' +
                '    "ResponseStatus": "S",' +
                '    "IsValid": true,' +
                '    "ResponseMessage": "18 spare parts found.",' +
                '    "ResponseErrorMessage": null,' +
                '    "ResponseData": [' +
                '        {' +
                '            "PartRef": "792654",' +
                '            "Description": "Panier vapeur inox ø235",' +
                '            "Quantity": 1.000,' +
                '            "PublicPrice": 10.0,' +
                '            "DiscountPrice": 8.0,' +
                '            "Availability": true,' +
                '            "AvailabilityDate": null,' +
                '            "Status": "Active",' +
                '            "DeliveryDelay": null,' +
                '            "ReplacedBy": null' +
                '        }' +
                '    ]' +
                '}',
                200
            )
        );

        Test.startTest();
        List<WOO_WS_Agora_Orders.PartDTO> spareParts = new WOO_WS_Agora_Orders()
            .loadApiKey('FRANCE')
            .getBomList('AGORAProductKey');
        System.assertNotEquals(null, spareParts, 'PartDTO should have been generated');
        Test.stopTest();
    }

    @IsTest
    static void createRepair() {
        Test.setMock(
            HttpCalloutMock.class,
            new MockHttpResponseGenerator(
                '{' +
                '    "ResponseStatus": "S",' +
                '    "IsValid": true,' +
                '    "ResponseMessage": null,' +
                '    "ResponseErrorMessage": null,' +
                '    "ResponseData": {' +
                '        "MandateId": 574157,' +
                '        "RepairId": "442944",' +
                '        "IsValid": true,' +
                '        "ValidationErrors": [' +
                '            {' +
                '                "Field": "Part Id - Part ref. (Line 2 : SS-1530000222)",' +
                '                "ErrorMessage": "Pièce non disponible",' +
                '                "MessageType": "W"' +
                '            }' +
                '        ],' +
                '        "ErrorMessage": null' +
                '    }' +
                '}',
                200
            )
        );

        WOO_WS_Agora_Orders.CompleteRepairDTO createRepair = generateupdateRepair();
        Test.startTest();
        WOO_WS_Agora_Orders.CreateRepairResponseData repairResponse = new WOO_WS_Agora_Orders()
            .loadApiKey('FRANCE')
            .createRepair(createRepair, null);
        Test.stopTest();
        System.assertNotEquals(null, repairResponse, 'repairResponse should have been generated');
    }
    @IsTest
    static void updateRepair() {
        Test.setMock(
            HttpCalloutMock.class,
            new MockHttpResponseGenerator(
                '{' +
                '    "ResponseStatus": "S",' +
                '    "IsValid": true,' +
                '    "ResponseMessage": null,' +
                '    "ResponseErrorMessage": null,' +
                '    "ResponseData": {' +
                '        "MandateId": 574157,' +
                '        "RepairId": "442944",' +
                '        "IsValid": true,' +
                '        "ValidationErrors": [' +
                '            {' +
                '                "Field": "Part Id - Part ref. (Line 2 : SS-1530000222)",' +
                '                "ErrorMessage": "Pièce non disponible",' +
                '                "MessageType": "W"' +
                '            }' +
                '        ],' +
                '        "ErrorMessage": null' +
                '    }' +
                '}',
                200
            )
        );

        WOO_WS_Agora_Orders.CompleteRepairStateDTO updateRepair = (WOO_WS_Agora_Orders.CompleteRepairStateDTO) JSON.deserialize(
            JSON.serialize(generateupdateRepair()),
            WOO_WS_Agora_Orders.CompleteRepairStateDTO.class
        );
        Test.startTest();
        WOO_WS_Agora_Orders.UpdateRepairResponseData repairResponse = new WOO_WS_Agora_Orders()
            .loadApiKey('FRANCE')
            .updateRepair(updateRepair, null);
        Test.stopTest();
        System.assertNotEquals(null, repairResponse, 'repairResponse should have been generated');
    }

    /* -------------------------------------------------------------------------- */
    /*                                    Utils                                   */
    /* -------------------------------------------------------------------------- */
    public static WOO_WS_Agora_Orders.CompleteRepairDTO generateupdateRepair() {
        WOO_WS_Agora_Orders.ConsumerDTO consumer = new WOO_WS_Agora_Orders.ConsumerDTO();
        consumer.Title = 1;
        consumer.LastName = 'LastName';
        consumer.FirstName = 'FirstName';
        consumer.Address1 = 'Address1';
        consumer.Zip = 'Zip';
        consumer.Town = 'Town';
        consumer.Country = 1;
        consumer.Phone = 'Phone';

        WOO_WS_Agora_Orders.InterventionDTO intervention = new WOO_WS_Agora_Orders.InterventionDTO();
        intervention.InterventionType = 1;
        intervention.RepairOriginCode = 'A';

        WOO_WS_Agora_Orders.AddressDTO reseller = new WOO_WS_Agora_Orders.AddressDTO();

        WOO_WS_Agora_Orders.CompleteRepairDTO updateRepair = new WOO_WS_Agora_Orders.CompleteRepairDTO();
        updateRepair.CallDate = Datetime.now();
        updateRepair.ClientNumber = 'ClientNumber';
        updateRepair.CommercialRef = 'CommercialRef';
        updateRepair.Consumer = consumer;
        updateRepair.Intervention = intervention;
        updateRepair.ManufacturingCode = '0120';
        updateRepair.ManufacturerId = 1;
        updateRepair.MissionOrder = 'MissionOrder';
        updateRepair.Reseller = reseller;
        updateRepair.TimeZoneId = 'TimeZoneId';
        return updateRepair;
    }
}