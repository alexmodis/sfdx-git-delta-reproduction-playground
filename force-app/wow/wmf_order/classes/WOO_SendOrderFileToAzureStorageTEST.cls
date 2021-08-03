@IsTest
public with sharing class WOO_SendOrderFileToAzureStorageTEST {
    // Cannot use system.runAs() because of this error : System.CalloutException: You have uncommitted work pending. Please commit or rollback before calling out
    // API v.49
    @TestSetup
    static void setup() {
        Account acc = (Account) TestFactory.createSObjectAndInsert(
            new Account(
                LastName = 'toto',
                PersonMailingCity = 'Berlin',
                PersonMailingPostalCode = '12359',
                PersonMailingStreet = 'Johannisthaler Chaussee 169'
            )
        );
        acc = [SELECT Id, personContactId FROM Account WHERE LastName = 'toto'];
        Case c = (Case) TestFactory.createSObject(
            new Case(Case_Country__c = 'DE', AccountId = acc.Id, ContactId = acc.personContactId)
        );
        insert c;
        WOO_WMF_Orders__c order = new WOO_WMF_Orders__c(
            WOO_Order_Type__c = 'Finished products',
            WOO_Case__c = c.Id,
            WOO_Comment__c = 'Order comment',
            WOO_Requested_delivery_date__c = Date.newInstance(2050, 2, 17)
        );
        insert order;
        WOO_WMF_Order_Line_Item__c oli = new WOO_WMF_Order_Line_Item__c(
            WOO_WMF_Order__c = order.Id,
            WOO_Country__c = 'DE',
            WOO_Comment__c = 'Order line item comment'
        );
        insert oli;
    }

    @IsTest
    private static void sendFileToAzureSuccess() {
        WOO_WMF_Orders__c order = [
            SELECT Id, WOO_SAP_status__c
            FROM WOO_WMF_Orders__c
            WHERE WOO_Order_Type__c = 'Finished products'
        ];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('', 201));
        Test.startTest();
        order.WOO_SAP_status__c = 'Ready to be sent';
        update order;
        Test.stopTest();

        order = [
            SELECT Id, WOO_Is_File_Created__c
            FROM WOO_WMF_Orders__c
            WHERE WOO_Order_Type__c = 'Finished products'
        ];
        System.assertEquals(true, order.WOO_Is_File_Created__c, 'The file is not sent');
    }

    @IsTest
    private static void sendFileToAzureFail() {
        WOO_WMF_Orders__c order = [
            SELECT Id, WOO_SAP_status__c
            FROM WOO_WMF_Orders__c
            WHERE WOO_Order_Type__c = 'Finished products'
        ];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('', 500));
        Test.startTest();
        order.WOO_SAP_status__c = 'Ready to be sent';
        update order;
        Test.stopTest();

        order = [
            SELECT Id, WOO_Is_File_Created__c
            FROM WOO_WMF_Orders__c
            WHERE WOO_Order_Type__c = 'Finished products'
        ];
        System.assertEquals(false, order.WOO_Is_File_Created__c, 'The file is not sent');
    }

    @IsTest
    private static void checkFileStructure() {
        WOO_WMF_Orders__c order = [
            SELECT
                Id,
                WOO_WMF_Order_Number__c,
                WOO_Comment__c,
                WOO_Commercial_organization__c,
                WOO_CPD_client_code__c,
                WOO_Order_Type__c,
                WOO_Requested_delivery_date_sap_format__c
            FROM WOO_WMF_Orders__c
            LIMIT 1
        ];
        Case c = [
            SELECT caseNumber, Account.Title_2__c, Account.PersonEmail, Account.Name
            FROM Case
            LIMIT 1
        ];
        List<WOO_WMF_Order_Line_Item__c> oli = [
            SELECT
                WOO_Product_CMMF__c,
                WOO_Requested_quantity__c,
                WOO_Comment__c,
                WOO_WMF_Order__r.WOO_WMF_Order_Number__c
            FROM WOO_WMF_Order_Line_Item__c
        ];
        String body = WOO_AzureStorageServicesBlob.buildRequestBody(order, c, oli);
        System.assertEquals('AKO', body.left(3), 'first 3 header characters are wrong');
        System.assertEquals(4, body.countMatches('\r\n'), 'Number of lines incorrect');
        System.debug(body.length());
        System.assertEquals(
            'APO',
            body.substring(1450, 1453),
            'first 3 order characters are wrong'
        );
        System.assertEquals(
            'ATX',
            body.substring(1596, 1599),
            'first 3 header comment characters are wrong'
        );
        System.assertEquals(
            '0000  ',
            body.substring(1644, 1650),
            'POSNR field for header comment is wrong'
        );
        System.assertEquals(
            'ATX',
            body.substring(1722, 1725),
            'first 3 order comment characters are wrong'
        );
        System.assertEquals(
            '0001  ',
            body.substring(1770, 1776),
            'POSNR field for order comment is wrong'
        );
        System.assertEquals('\r\n', body.right(2), 'first 3 header characters are wrong');
    }
}