public with sharing class WOO_ProcessOrdersWhoseFileIsCreated implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable {
    public Database.QueryLocator start(Database.BatchableContext info) {
        String query = 'SELECT Id,Name,WOO_SAP_status__c FROM WOO_WMF_Orders__c WHERE WOO_Is_File_Created__c = true AND WOO_SAP_status__c = \'Ready to be sent\'';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> sObjectList) {
        HttpResponse response = getFilesInAzureStorageServicesBlob();
        if (response.getStatusCode() == 200) {
            Map<String, WOO_WMF_Orders__c> mapOrderNameToOrder = createOrderMap(sObjectList);
            List<String> keyList = new List<String>(mapOrderNameToOrder.keySet());
            List<String> names = getFilesName(response.getBody());
            for (String key : keyList) {
                if (!names.contains('WoW_ORDER_' + key)) {
                    mapOrderNameToOrder.get(key).WOO_SAP_status__c = 'Sent';
                }
            }
            Database.update(sObjectList, false);
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Batch Finish method');
    }

    public void execute(SchedulableContext sc) {
        WOO_ProcessOrdersWhoseFileIsCreated batch = new WOO_ProcessOrdersWhoseFileIsCreated();
        Database.executeBatch(batch);
    }

    public static void run() {
        WOO_ProcessOrdersWhoseFileIsCreated batch = new WOO_ProcessOrdersWhoseFileIsCreated();
        Database.executeBatch(batch);
    }

    private static HttpResponse getFilesInAzureStorageServicesBlob() {
        String url = buildEndpointURL();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('GET');
        Http h = new Http();
        HttpResponse response = h.send(request);
        return response;
    }

    private static String buildEndpointURL() {
        String typeOfOrg = CustomMetadataCache.getIsSandbox() ? 'Sandbox' : 'Prod';
        WOO_AzureKey__mdt azureKey = [
            SELECT Create__c, Folder_name__c
            FROM WOO_AzureKey__mdt
            WHERE DeveloperName = :typeOfOrg
        ];
        final String urlParameters =
            azureKey.Folder_name__c +
            '?si=MODIS&sv=2019-02-02&comp=list&restype=container&sr=c&sig=' +
            azureKey.Create__c;
        final String azureStorageServicesBlobEndpoint = 'callout:Azure_Storage_Services_Blob'; //Named Credential
        return azureStorageServicesBlobEndpoint + urlParameters;
    }

    private static List<String> getFilesName(String responseBody) {
        List<String> names = new List<String>();
        DOM.Document document = new DOM.Document();
        document.load(responseBody);
        for (Dom.XmlNode fluxNode : document.getRootElement().getChildElements()) {
            for (Dom.XmlNode fluxChildNode : fluxNode.getChildElements()) {
                if (fluxChildNode.getName() == 'Blob') {
                    String fileName = fluxChildNode.getChildElement('Name', null).getText();
                    List<String> parts = filename.split('/');
                    if (parts[0] == 'IN') {
                        names.add(parts[1].substringBefore('.'));
                    }
                }
            }
        }
        return names;
    }

    private static Map<String, WOO_WMF_Orders__c> createOrderMap(List<sObject> sObjectList) {
        Map<String, WOO_WMF_Orders__c> mapOrderNameToOrder = new Map<String, WOO_WMF_Orders__c>();
        for (Sobject so : sObjectList) {
            WOO_WMF_Orders__c order = (WOO_WMF_Orders__c) so;
            mapOrderNameToOrder.put(order.name, order);
        }
        return mapOrderNameToOrder;
    }
}