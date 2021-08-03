public with sharing class WOO_WMFOrdersLineItemHandler {
    public static final string REQUESTED_QUANTITY_ERROR_MESSAGE = 'Requested quantity is required for finished product or spare part order type';
    public static final string MISMATCHED_TYPE_ERROR = 'Order and OrderLineItem type doesn\'t match';

    public static void checkIfRequestedQuantityRequired(
        List<WOO_WMF_Order_Line_Item__c> orderLineItems
    ) {
        Map<String, RecordType> recordTypes = CustomMetadataCache.getRecordTypeMapByName();

        for (WOO_WMF_Order_Line_Item__c oli : orderLineItems) {
            if (
                oli.recordTypeId == recordTypes.get('Finished_products_Spare_part').Id &&
                (oli.WOO_Requested_quantity__c == null ||
                oli.WOO_Requested_quantity__c == 0)
            ) {
                oli.addError(REQUESTED_QUANTITY_ERROR_MESSAGE);
            }
        }
    }

    public static void checkIfOrderTypeMatch(List<WOO_WMF_Order_Line_Item__c> orderLineItems) {
        List<Id> ordersId = new List<Id>();
        for (WOO_WMF_Order_Line_Item__c oli : orderLineItems) {
            ordersId.add(oli.WOO_WMF_Order__c);
        }

        Map<String, RecordType> recordTypes = CustomMetadataCache.getRecordTypeMapByName();

        Map<Id, WOO_WMF_Orders__c> orders = new Map<Id, WOO_WMF_Orders__c>(
            [SELECT Id, WOO_Order_Type__c FROM WOO_WMF_Orders__c WHERE Id IN :ordersId]
        );
        for (WOO_WMF_Order_Line_Item__c oli : orderLineItems) {
            if (
                oli.recordTypeId == recordTypes.get('Finished_products_Spare_part').Id &&
                (orders.get(oli.WOO_WMF_Order__c).WOO_Order_Type__c != 'Finished products' &&
                orders.get(oli.WOO_WMF_Order__c).WOO_Order_Type__c != 'Spare part')
            ) {
                oli.addError(MISMATCHED_TYPE_ERROR);
            } else if (
                oli.recordTypeId == recordTypes.get('Repair').Id &&
                orders.get(oli.WOO_WMF_Order__c).WOO_Order_Type__c != 'Repair'
            ) {
                oli.addError(MISMATCHED_TYPE_ERROR);
            }
        }
    }
}