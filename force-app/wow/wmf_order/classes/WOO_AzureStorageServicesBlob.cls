public with sharing class WOO_AzureStorageServicesBlob {
    public static HttpResponse putFileInAzureStorageServicesBlob(
        WOO_WMF_Orders__c order,
        Case caseOrder,
        List<WOO_WMF_Order_Line_Item__c> orderLineItems
    ) {
        String reqBody = buildRequestBody(order, caseOrder, orderLineItems);
        String fileName = 'WoW_ORDER_' + order.WOO_WMF_Order_Number__c;
        String url = buildEndpointURL(order);
        System.debug('URL : ' + url);
        System.debug('BLOB : ' + reqBody);
        return createFileInAzureStorageServicesBlob(url, reqBody);
    }

    @TestVisible
    private static String buildRequestBody(
        WOO_WMF_Orders__c order,
        Case caseOrder,
        List<WOO_WMF_Order_Line_Item__c> orderLineItems
    ) {
        WOO_OrderCreateWrapper.Header h = new WOO_OrderCreateWrapper.Header();
        WOO_OrderCreateWrapper.HeaderText ht = new WOO_OrderCreateWrapper.HeaderText();
        String reqBody = '';
        String comment = '';
        h.fillHeader(caseOrder, order);
        reqBody = h.headerLine;
        if (order.WOO_Comment__c != null) {
            ht.fillHeaderText(order);
            comment = comment + ht.headerText;
        }
        Integer i = 1;
        for (WOO_WMF_Order_Line_Item__c orderLineItem : orderLineItems) {
            reqBody = reqBody + '\r\n';

            WOO_OrderCreateWrapper.OrderLine ol = new WOO_OrderCreateWrapper.OrderLine();
            ol.fillOrderLine(orderLineItem);
            reqBody = reqBody + insertSAPFieldPOSNR(ol.orderLine, i, 80);
            if (orderLineItem.WOO_Comment__c != null) {
                comment = comment == '' ? comment : comment + '\r\n';
                WOO_OrderCreateWrapper.OrderText ot = new WOO_OrderCreateWrapper.OrderText();
                ot.fillOrderText(orderLineItem);
                comment = comment + insertSAPFieldPOSNR(ot.orderText, i, 48);
            }
            i++;
        }
        if (comment != '') {
            reqBody = reqBody + '\r\n' + comment;
        }
        return reqBody + '\r\n';
    }

    private static String insertSAPFieldPOSNR(String s, Integer index, Integer posnrPosition) {
        Integer posnrLength = 6;
        String posnr = index + '  ';
        while (posnr.length() < posnrLength) {
            posnr = '0' + posnr;
        }
        System.assert(
            posnr.length() == posnrLength,
            'POSNR should be of length ' +
            posnrLength +
            ', no more, no less. It is actualy : ' +
            posnr.length()
        );
        s = s.left(posnrPosition) + posnr + s.right(s.length() - (posnrPosition + posnrLength));
        return s;
    }

    private static String buildEndpointURL(WOO_WMF_Orders__c order) {
        String typeOfOrg = CustomMetadataCache.getIsSandbox() ? 'Sandbox' : 'Prod';
        WOO_AzureKey__mdt azureKey = [
            SELECT Create__c, Folder_name__c
            FROM WOO_AzureKey__mdt
            WHERE DeveloperName = :typeOfOrg
        ];
        final String URL_PARAMETERS = '?si=MODIS&sv=2019-02-02&&sr=c&sig=' + azureKey.Create__c;
        final String AZURE_STORAGE_SERVICES_BLOB_ENDPOINT = 'callout:Azure_Storage_Services_Blob'; //Named Credential
        final String fileRootName =
            azureKey.Folder_name__c +
            '/IN/WoW_ORDER_' +
            order.WOO_WMF_Order_Number__c +
            '.txt';
        return AZURE_STORAGE_SERVICES_BLOB_ENDPOINT + fileRootName + URL_PARAMETERS;
    }

    private static HttpResponse createFileInAzureStorageServicesBlob(String url, String body) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('PUT');
        request.setHeader('Content-Type', 'text/plain');
        request.setHeader('x-ms-blob-type', 'BlockBlob');
        request.setBody(body);

        Http h = new Http();
        HttpResponse response = h.send(request);
        return response;
    }
}