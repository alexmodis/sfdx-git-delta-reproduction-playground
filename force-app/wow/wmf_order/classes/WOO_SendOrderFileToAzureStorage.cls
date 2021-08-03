public with sharing class WOO_SendOrderFileToAzureStorage implements Queueable, Database.AllowsCallouts {
    private List<WOO_WMF_Orders__c> newOrders { get; set; }

    public WOO_SendOrderFileToAzureStorage(List<WOO_WMF_Orders__c> newOrders) {
        this.newOrders = newOrders;
    }

    public void execute(QueueableContext context) {
        WOO_WMF_Orders__c order = newOrders[0];
        Case caseOrder = [
            SELECT
                Id,
                Casenumber,
                Account.Title_2__c,
                Account.Name,
                Account.PersonMailingPostalCode,
                Account.PersonMailingCity,
                Account.PersonMailingStreet,
                Account.PersonEmail,
                Account.Salutation
            FROM Case
            WHERE Id = :order.WOO_Case__c
        ];
        List<WOO_WMF_Order_Line_Item__c> orderLineItems = [
            SELECT
                Id,
                WOO_Product_CMMF__c,
                WOO_Requested_quantity__c,
                WOO_Comment__c,
                WOO_WMF_Order__r.WOO_WMF_Order_Number__c,
                WOO_Repair_instructions__c,
                WOO_Assigment__c,
                WOO_Defect_Location__c,
                WOO_Defect_type__c
            FROM WOO_WMF_Order_Line_Item__c
            WHERE WOO_WMF_Order__c = :order.Id
        ];
        HttpResponse response = WOO_AzureStorageServicesBlob.putFileInAzureStorageServicesBlob(
            order,
            caseOrder,
            orderLineItems
        );
        if (response.getStatusCode() == 201) {
            order.WOO_Is_File_Created__c = true;
            update order;
        } else {
            System.debug('An error occured :( ' + response.getStatusCode());
        }
    }

    public static List<WOO_WMF_Orders__c> getOrdersWithFileToSendToAzure(
        List<WOO_WMF_Orders__c> orders,
        Map<Id, WOO_WMF_Orders__c> oldMap
    ) {
        List<WOO_WMF_Orders__c> ordersWithFileToSendToAzure = new List<WOO_WMF_Orders__c>();
        for (WOO_WMF_Orders__c order : orders) {
            if (
                orders.size() == 1 &&
                order.WOO_SAP_status__c == 'Ready to be sent' &&
                order.WOO_SAP_status__c != oldMap.get(order.Id).WOO_SAP_status__c
            ) {
                ordersWithFileToSendToAzure.add(order);
            }
        }
        return ordersWithFileToSendToAzure;
    }
}