public with sharing class WOO_WMFOrdersLineItemTriggerHandler extends TriggerHandler {
    public without sharing class OrderLineSplitter {
        public List<WOO_WMF_Order_Line_Item__c> sapLines;
        public List<WOO_WMF_Order_Line_Item__c> freeLines;

        public OrderLineSplitter(List<WOO_WMF_Order_Line_Item__c> lines) {
            Set<Id> orderIds = new Set<Id>();
            this.sapLines = new List<WOO_WMF_Order_Line_Item__c>();
            this.freeLines = new List<WOO_WMF_Order_Line_Item__c>();
            for (WOO_WMF_Order_Line_Item__c line : lines) {
                orderIds.add(line.WOO_WMF_Order__c);
            }
            Map<Id, WOO_WMF_Orders__c> parentOrders = new Map<Id, WOO_WMF_Orders__c>(
                [SELECT Id, RecordType.DeveloperName FROM WOO_WMF_Orders__c WHERE Id IN :orderIds]
            );
            for (WOO_WMF_Order_Line_Item__c line : lines) {
                String recordName = parentOrders.get(line.WOO_WMF_Order__c)
                    .RecordType.DeveloperName;
                if (String.isBlank(recordName)) {
                    throw new HandledException('recordName should not be empty.');
                }
                if (recordName == 'SAP_Orders') {
                    this.sapLines.add(line);
                } else {
                    this.freeLines.add(line);
                }
            }
        }
    }
    private Map<Id, WOO_WMF_Order_Line_Item__c> oldMap;
    private Map<Id, WOO_WMF_Order_Line_Item__c> newMap;
    private List<WOO_WMF_Order_Line_Item__c> oldList;
    private List<WOO_WMF_Order_Line_Item__c> newList;

    public WOO_WMFOrdersLineItemTriggerHandler() {
        this.oldMap = (Map<Id, WOO_WMF_Order_Line_Item__c>) Trigger.oldMap;
        this.newMap = (Map<Id, WOO_WMF_Order_Line_Item__c>) Trigger.newMap;
        this.oldList = (List<WOO_WMF_Order_Line_Item__c>) Trigger.Old;
        this.newList = (List<WOO_WMF_Order_Line_Item__c>) Trigger.New;

        Map<String, RecordType> recordTypes = CustomMetadataCache.getRecordTypeMapByName();
    }

    public override void beforeInsert() {
        if (PAD.canTrigger(PicklistUser.BYPASS_TRIGGERS_C_ORDERLINEITEM)) {
            OrderLineSplitter splittedLists = new OrderLineSplitter(newList);
            if (PAD.canTrigger(PicklistUser.BYPASS_TRIGGERS_C_ORDERLINEITEM_SAP)) {
                WOO_WMFOrdersLineItemHandler.checkIfRequestedQuantityRequired(
                    splittedLists.sapLines
                );
                WOO_WMFOrdersLineItemHandler.checkIfOrderTypeMatch(splittedLists.sapLines);
            }
        }
    }

    public override void beforeUpdate() {
        if (PAD.canTrigger(PicklistUser.BYPASS_TRIGGERS_C_ORDERLINEITEM)) {
            OrderLineSplitter splittedLists = new OrderLineSplitter(newList);
            if (PAD.canTrigger(PicklistUser.BYPASS_TRIGGERS_C_ORDERLINEITEM_SAP)) {
                WOO_WMFOrdersLineItemHandler.checkIfRequestedQuantityRequired(
                    splittedLists.sapLines
                );
                WOO_WMFOrdersLineItemHandler.checkIfOrderTypeMatch(splittedLists.sapLines);
            }
        }
    }
}