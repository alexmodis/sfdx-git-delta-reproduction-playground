public with sharing class WOO_WMFOrdersTriggerHandler extends TriggerHandler {
    public enum Rectype {
        FREE,
        FREE_SUBSIDIARY,
        SAP
    }

    private Map<Id, WOO_WMF_Orders__c> oldMap;
    private Map<Id, WOO_WMF_Orders__c> newMap;
    private List<WOO_WMF_Orders__c> oldList;
    private List<WOO_WMF_Orders__c> newList;
    private Rectype orderRecType;

    public WOO_WMFOrdersTriggerHandler() {
        this.oldMap = (Map<Id, WOO_WMF_Orders__c>) Trigger.oldMap;
        this.newMap = (Map<Id, WOO_WMF_Orders__c>) Trigger.newMap;
        this.oldList = (List<WOO_WMF_Orders__c>) Trigger.old;
        this.newList = (List<WOO_WMF_Orders__c>) Trigger.new;

        this.orderRecType = this.findRecType();
    }
    public override void beforeInsert() {
        if (
            PAD.canTrigger(PicklistUser.BYPASS_TRIGGERS_C_WOO_FREEORDER) &&
            (this.orderRecType == Rectype.FREE ||
            this.orderRecType == Rectype.FREE_SUBSIDIARY)
        ) {
            WOO_WMFOrdersHandler.initFreeOrderFields(this.newList);
        }
    }

    public override void afterInsert() {
        if (PAD.canTrigger('WOO_SAPOrder') && this.orderRecType == Rectype.SAP) {
            WOO_WMFOrdersHandler.fillSapOrderAccountField(this.newMap);
        }
    }

    public override void beforeUpdate() {
        if (PAD.canTrigger('WOO_SendOrderFileToAzureStorage') && this.orderRecType == Rectype.SAP) {
            List<WOO_WMF_Orders__c> ordersWithFileToSendToAzure = WOO_SendOrderFileToAzureStorage.getOrdersWithFileToSendToAzure(
                newList,
                oldMap
            );
            if (ordersWithFileToSendToAzure.size() > 0) {
                System.enqueueJob(new WOO_SendOrderFileToAzureStorage(ordersWithFileToSendToAzure));
            }
        }
        if (
            PAD.canTrigger(PicklistUser.BYPASS_TRIGGERS_C_WOO_FREEORDER_PREVENTUPDATESENT) &&
            (this.orderRecType == Rectype.FREE ||
            this.orderRecType == Rectype.FREE_SUBSIDIARY)
        ) {
            WOO_WMFOrdersHandler.preventUpdateFreeOrderSentSuccess(this.newMap, this.oldMap);
        }
    }

    public override void afterUpdate() {
        if (
            PAD.canTrigger(PicklistUser.BYPASS_TRIGGERS_C_WOO_FREEORDER) &&
            this.orderRecType == Rectype.FREE
        ) {
            WOO_WMFOrdersHandler.copyOrderFieldsToCase(this.newList);
        }
    }
    public override void beforeDelete() {
        if (
            PAD.canTrigger(PicklistUser.BYPASS_TRIGGERS_C_WOO_FREEORDER_DELETE) &&
            (this.orderRecType == Rectype.FREE ||
            this.orderRecType == Rectype.FREE_SUBSIDIARY)
        ) {
            WOO_WMFOrdersHandler.preventDeletionOfFreeOrderSentToAgora(this.oldList);
        }
    }

    private Rectype findRecType() {
        Map<String, RecordType> recordTypes = CustomMetadataCache.getRecordTypeMapByName();
        if (
            this.newList?.get(0)?.RecordTypeId == recordTypes.get('Free_Orders').Id ||
            this.oldList?.get(0)?.RecordTypeId == recordTypes.get('Free_Orders').Id
        ) {
            return Rectype.FREE;
        } else if (
            this.newList?.get(0)?.RecordTypeId == recordTypes.get('Free_Orders_Subsidiary').Id ||
            this.oldList?.get(0)?.RecordTypeId == recordTypes.get('Free_Orders_Subsidiary').Id
        ) {
            return Rectype.FREE_SUBSIDIARY;
        } else if (
            this.newList?.get(0)?.RecordTypeId == recordTypes.get('SAP_Orders').Id ||
            this.oldList?.get(0)?.RecordTypeId == recordTypes.get('SAP_Orders').Id
        ) {
            return Rectype.SAP;
        } else {
            throw new HandledException('ERROR trigger on the order record type.');
        }
    }
}