@IsTest
public with sharing class WOO_OrderCreateWrapperTEST {
    public static User setupUser;
    static {
        setupUser = (User) TestFactory.createSObject(new user(), TestFactoryUser.UserSetup.class);
    }

    @TestSetup
    static void setup() {
        System.runAs(setupUser) {
            Account acc = (Account) TestFactory.createSObject(
                new Account(
                    LastName = 'toto',
                    PersonMailingCity = 'Berlin',
                    PersonMailingPostalCode = '12359',
                    PersonMailingStreet = 'Johannisthaler Chaussee 169'
                )
            );
            insert acc;
            acc = [SELECT Id, personContactId FROM Account WHERE LastName = 'toto'];
            Case c = (Case) TestFactory.createSObject(
                new Case(
                    Case_Country__c = 'DE',
                    AccountId = acc.Id,
                    ContactId = acc.personContactId
                )
            );
            insert c;
            WOO_WMF_Orders__c order = new WOO_WMF_Orders__c(
                WOO_Order_Type__c = 'Finished products',
                WOO_Case__c = c.Id,
                WOO_Requested_delivery_date__c = Date.newInstance(2050, 2, 17)
            );
            insert order;
            WOO_WMF_Order_Line_Item__c oli = new WOO_WMF_Order_Line_Item__c(
                WOO_WMF_Order__c = order.Id,
                WOO_Country__c = 'DE'
            );
            insert oli;
        }
    }

    @IsTest
    private static void orderWrapperHeader() {
        WOO_OrderCreateWrapper.header h = new WOO_OrderCreateWrapper.header();
        System.assertEquals(53, h.mapSAPfieldSize.size(), 'The number of fields is incorrect');
        List<integer> i = h.mapSAPfieldSize.values();
        Integer sum = 0;
        for (integer j : i) {
            sum = sum + j;
        }
        System.assertEquals(1448, sum, 'The number of characters is incorrect');
    }

    @IsTest
    private static void checkFieldValueNotAboveMaxLength() {
        String result = WOO_OrderCreateWrapper.formatFieldValue('blabla', 10); // 'VBELN'
        System.assert(
            result.contains('    '),
            'The field does not have the correct number of spaces'
        );
        System.assertEquals(10, result.length(), 'The length is incorrect');
    }

    @IsTest
    private static void checkFieldValueAboveMaxLength() {
        new WOO_OrderCreateWrapper.header();
        String result = WOO_OrderCreateWrapper.formatFieldValue('blablablabla', 10); // 'VBELN'
        System.assertEquals(10, result.trim().length(), 'The length is incorrect');
    }

    @IsTest
    private static void checkFirst2FieldsInHeaderLine() {
        WOO_OrderCreateWrapper.header h = new WOO_OrderCreateWrapper.header();
        h.fillHeaderWithFixedValues(new WOO_WMF_Orders__c(WOO_Order_Type__c = 'Finished products'));
        System.assertEquals(
            'AKOK1TA',
            h.headerLine.left(7),
            'The first characters 7 are incorrect for finished products type'
        );
        h = new WOO_OrderCreateWrapper.header();
        h.fillHeaderWithFixedValues(new WOO_WMF_Orders__c(WOO_Order_Type__c = 'Spare part'));
        System.assertEquals(
            'AKOK1TS',
            h.headerLine.left(7),
            'The first 7 characters are incorrect for spare parts type'
        );
    }

    @IsTest
    private static void checkHeaderFieldIsAtTheCorrectPosition() {
        WOO_OrderCreateWrapper.header h = new WOO_OrderCreateWrapper.header();
        WOO_WMF_Orders__c order = new WOO_WMF_Orders__c(
            WOO_Order_Type__c = 'Finished products',
            WOO_CPD_client_code__c = '98001021'
        );
        Case c = [
            SELECT id, caseNumber, Account.Title_2__c, Account.PersonEmail, Account.Name
            FROM Case
            WHERE Case_Country__c = 'DE'
        ];
        h.fillHeader(c, order);
        System.assertEquals(
            '98001021  ',
            h.headerLine.substring(31, 41),
            'The field is not correctly inserted'
        );
    }

    @IsTest
    private static void orderWrapperOrderLine() {
        WOO_OrderCreateWrapper.OrderLine ol = new WOO_OrderCreateWrapper.OrderLine();
        System.assertEquals(15, ol.mapSAPfieldSize.size(), 'The number of fields is incorrect');
        List<integer> i = ol.mapSAPfieldSize.values();
        Integer sum = 0;
        for (integer j : i) {
            sum = sum + j;
        }
        System.assertEquals(144, sum, 'The number of characters is incorrect');
    }

    @IsTest
    private static void checkOrderLineItemFieldIsAtTheCorrectPosition() {
        WOO_OrderCreateWrapper.OrderLine ol = new WOO_OrderCreateWrapper.OrderLine();
        WOO_WMF_Order_Line_Item__c oli = [
            SELECT
                Id,
                WOO_Product_CMMF__c,
                WOO_Requested_quantity__c,
                WOO_WMF_Order__r.WOO_WMF_Order_Number__c
            FROM WOO_WMF_Order_Line_Item__c
            LIMIT 1
        ];
        ol.fillOrderLine(oli);
        System.assert(ol.orderLine.left(3) == 'APO', 'The first 3 characters are wrong');
        System.assertEquals(
            oli.WOO_Requested_quantity__c + '             ',
            ol.orderLine.substring(66, 80),
            'The field is not correctly inserted'
        );
    }

    @IsTest
    private static void orderWrapperHeaderText() {
        WOO_OrderCreateWrapper.HeaderText ht = new WOO_OrderCreateWrapper.HeaderText();
        System.assertEquals(5, ht.mapSAPfieldSize.size(), 'The number of fields is incorrect');
        List<integer> i = ht.mapSAPfieldSize.values();
        Integer sum = 0;
        for (integer j : i) {
            sum = sum + j;
        }
        System.assertEquals(124, sum, 'The number of characters is incorrect');
    }

    @IsTest
    private static void checkHeaderTextFieldIsAtTheCorrectPosition() {
        WOO_OrderCreateWrapper.HeaderText ht = new WOO_OrderCreateWrapper.HeaderText();
        WOO_WMF_Orders__c order = [
            SELECT Id, WOO_WMF_Order_Number__c
            FROM WOO_WMF_Orders__c
            LIMIT 1
        ];
        ht.fillHeaderText(order);
        System.assert(ht.headerText.left(3) == 'ATX', 'The first 3 characters are wrong');
        System.assertEquals(
            order.WOO_WMF_Order_Number__c + '    ',
            ht.headerText.substring(3, 13),
            'The field is not correctly inserted'
        );
    }

    @IsTest
    private static void orderWrapperOrderText() {
        WOO_OrderCreateWrapper.OrderText ot = new WOO_OrderCreateWrapper.OrderText();
        System.assertEquals(5, ot.mapSAPfieldSize.size(), 'The number of fields is incorrect');
        List<integer> i = ot.mapSAPfieldSize.values();
        Integer sum = 0;
        for (integer j : i) {
            sum = sum + j;
        }
        System.assertEquals(124, sum, 'The number of characters is incorrect');
    }

    @IsTest
    private static void checkOrderTextFieldIsAtTheCorrectPosition() {
        WOO_OrderCreateWrapper.OrderText ht = new WOO_OrderCreateWrapper.OrderText();
        WOO_WMF_Order_Line_Item__c oli = [
            SELECT id, WOO_Comment__c, WOO_WMF_Order__r.WOO_WMF_Order_Number__c
            FROM WOO_WMF_Order_Line_Item__c
            LIMIT 1
        ];
        ht.fillOrderText(oli);
        System.assert(ht.OrderText.left(3) == 'ATX', 'The first 3 characters are wrong');
        System.assertEquals(
            oli.WOO_WMF_Order__r.WOO_WMF_Order_Number__c + '    ',
            ht.OrderText.substring(3, 13),
            'The field is not correctly inserted'
        );
    }
}