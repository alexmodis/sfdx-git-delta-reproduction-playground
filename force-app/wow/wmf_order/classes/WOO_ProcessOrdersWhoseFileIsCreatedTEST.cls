@IsTest
public with sharing class WOO_ProcessOrdersWhoseFileIsCreatedTEST {
    // Cannot use system.runAs() because of this error : System.CalloutException: You have uncommitted work pending. Please commit or rollback before calling out
    // API v.49
    @TestSetup
    static void setup() {
        Account acc = (Account) TestFactory.createSObjectAndInsert(
            new Account(
                PersonMailingCity = 'Berlin',
                PersonMailingPostalCode = '12359',
                PersonMailingStreet = 'Johannisthaler Chaussee 169'
            )
        );
        acc = [SELECT personcontactid FROM Account WHERE PersonEmail = 'email@testtest.com'];
        Case c = (Case) TestFactory.createSObjectAndInsert(
            new Case(Case_Country__c = 'DE', ContactId = acc.personcontactid)
        );
        List<WOO_WMF_Orders__c> orders = new List<WOO_WMF_Orders__c>();
        orders.add(
            new WOO_WMF_Orders__c(
                WOO_SAP_status__c = 'Ready to be sent',
                WOO_Order_Type__c = 'Finished products',
                WOO_Case__c = c.Id,
                WOO_Is_File_Created__c = true
            )
        );
        orders.add(
            new WOO_WMF_Orders__c(
                WOO_SAP_status__c = 'Ready to be sent',
                WOO_Order_Type__c = 'Spare part',
                WOO_Case__c = c.Id,
                WOO_Is_File_Created__c = true
            )
        );
        insert orders;
    }

    @IsTest
    private static void checkIfFileHasBeenProcessed() {
        WOO_WMF_Orders__c order = [
            SELECT WOO_WMF_Order_Number__c
            FROM WOO_WMF_Orders__c
            WHERE WOO_Order_Type__c = 'Finished products'
        ];
        String responseBody =
            '<?xml version="1.0" encoding="utf-8"?>' +
            '<EnumerationResults ServiceEndpoint="https://wowsapdevwesto00.blob.core.windows.net/" ContainerName="wowsapdevweblob00">' +
            '<Blobs>' +
            '<Blob>' +
            '<Name>IN/hellome.txt</Name>' +
            '<Properties>' +
            '<Creation-Time>Tue, 13 Oct 2020 14:59:52 GMT</Creation-Time>' +
            '<Last-Modified>Tue, 13 Oct 2020 14:59:52 GMT</Last-Modified>' +
            '<Etag>0x8D86F88A37A9FB7</Etag>' +
            '<Content-Length>7</Content-Length>' +
            '<Content-Type>text/plain</Content-Type>' +
            '<Content-Encoding />' +
            '<Content-Language />' +
            '<Content-CRC64 />' +
            '<Content-MD5>E+6KS0B2pNPJ272XbG92fw==</Content-MD5>' +
            '<Cache-Control />' +
            '<Content-Disposition />' +
            '<BlobType>BlockBlob</BlobType>' +
            '<AccessTier>Hot</AccessTier>' +
            '<AccessTierInferred>true</AccessTierInferred>' +
            '<LeaseStatus>unlocked</LeaseStatus>' +
            '<LeaseState>available</LeaseState>' +
            '<ServerEncrypted>true</ServerEncrypted>' +
            '</Properties>' +
            '<OrMetadata />' +
            '</Blob>' +
            '<Blob>' +
            '<Name>IN/helloworld.txt</Name>' +
            '<Properties>' +
            '<Creation-Time>Mon, 12 Oct 2020 15:38:36 GMT</Creation-Time>' +
            '<Last-Modified>Mon, 12 Oct 2020 15:38:36 GMT</Last-Modified>' +
            '<Etag>0x8D86EC4E271BEDD</Etag>' +
            '<Content-Length>7</Content-Length>' +
            '<Content-Type>text/plain</Content-Type>' +
            '<Content-Encoding />' +
            '<Content-Language />' +
            '<Content-CRC64 />' +
            '<Content-MD5>E+6KS0B2pNPJ272XbG92fw==</Content-MD5>' +
            '<Cache-Control />' +
            '<Content-Disposition />' +
            '<BlobType>BlockBlob</BlobType>' +
            '<AccessTier>Hot</AccessTier>' +
            '<AccessTierInferred>true</AccessTierInferred>' +
            '<LeaseStatus>unlocked</LeaseStatus>' +
            '<LeaseState>available</LeaseState>' +
            '<ServerEncrypted>true</ServerEncrypted>' +
            '</Properties>' +
            '<OrMetadata />' +
            '</Blob>' +
            '<Blob>' +
            '<Name>TEST/test.txt</Name>' +
            '<Properties>' +
            '<Creation-Time>Mon, 14 Sep 2020 09:26:45 GMT</Creation-Time>' +
            '<Last-Modified>Mon, 14 Sep 2020 09:26:45 GMT</Last-Modified>' +
            '<Etag>0x8D858904C4030C3</Etag>' +
            '<Content-Length>4</Content-Length>' +
            '<Content-Type>text/plain</Content-Type>' +
            '<Content-Encoding />' +
            '<Content-Language />' +
            '<Content-CRC64 />' +
            '<Content-MD5>CY9rzUYh03PK3k6DJie09g==</Content-MD5>' +
            '<Cache-Control />' +
            '<Content-Disposition />' +
            '<BlobType>BlockBlob</BlobType>' +
            '<AccessTier>Hot</AccessTier>' +
            '<AccessTierInferred>true</AccessTierInferred>' +
            '<LeaseStatus>unlocked</LeaseStatus>' +
            '<LeaseState>available</LeaseState>' +
            '<ServerEncrypted>true</ServerEncrypted>' +
            '</Properties>' +
            '<OrMetadata />' +
            '</Blob>' +
            '</Blobs>' +
            '<NextMarker />' +
            '</EnumerationResults>';
        responseBody = responseBody.replace(
            'IN/helloworld',
            'IN/WoW_ORDER_' + order.WOO_WMF_Order_Number__c
        );
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(responseBody, 200));
        Test.startTest();
        WOO_ProcessOrdersWhoseFileIsCreated.run();
        Test.stopTest();
        Integer ordersSent = [
            SELECT COUNT()
            FROM WOO_WMF_Orders__c
            WHERE WOO_SAP_status__c = 'Sent'
        ];
        System.assertEquals(1, ordersSent, 'The number of order with status "Sent" is incorrect');
    }
}