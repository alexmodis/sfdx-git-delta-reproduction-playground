public without sharing class WOO_WMFOrdersHandler {
    public static final String STATUS_NOT_SENT = 'NotSent';
    public static void initFreeOrderFields(List<WOO_WMF_Orders__c> newList) {
        ParentObjMaps parentMaps = new ParentObjMaps(newList);
        for (WOO_WMF_Orders__c order : newList) {
            if (parentMaps.mapIdtoCase.get(order.WOO_Case__c)?.AccountId == null) {
                order.addError(Label.AgoraOrder_RequiredCaseConsumer);
            }
            Case parentCase = parentMaps.mapIdtoCase.get(order.WOO_Case__c);
            order.WOO_Agora_Order_Ref__c = buildAgoraRef(order.WOO_Order_Type__c, parentCase);
            cpyFieldsFromObjectToAnother(
                parentMaps.mapIdtoCase.get(order.WOO_Case__c),
                order,
                new Map<Schema.SObjectField, Schema.SObjectField>{
                    Case.AccountId => WOO_WMF_Orders__c.WOO_Account__c,
                    Case.ProductId => WOO_WMF_Orders__c.Woo_Product__c,
                    Case.Manufacturing_Date__c => WOO_WMF_Orders__c.WOO_AgoraManufacturingDate__c,
                    Case.Product_Country__c => WOO_WMF_Orders__c.Product_Country__c,
                    Case.Retailer__c => WOO_WMF_Orders__c.WOO_Retailer__c
                }
            );
        }
        PAD.bypassAll = true;
        update parentMaps.mapIdtoCase.values(); // updating the AgoraId_Counter__c changed by buildAgoraRef
        PAD.bypassAll = false;
    }

    public static void copyOrderFieldsToCase(List<WOO_WMF_Orders__c> newList) {
        ParentObjMaps parentMaps = new ParentObjMaps(newList);
        for (WOO_WMF_Orders__c order : newList) {
            cpyFieldsFromObjectToAnother(
                order,
                parentMaps.mapIdtoCase.get(order.WOO_Case__c),
                new Map<Schema.SObjectField, Schema.SObjectField>{
                    WOO_WMF_Orders__c.Woo_Product__c => Case.ProductId,
                    WOO_WMF_Orders__c.WOO_AgoraManufacturingDate__c => Case.Manufacturing_Date__c,
                    WOO_WMF_Orders__c.Product_Country__c => Case.Product_Country__c,
                    WOO_WMF_Orders__c.WOO_Retailer__c => Case.Retailer__c
                }
            );
        }

        PAD.bypassAll = true;
        update parentMaps.mapIdtoCase.values();
        PAD.bypassAll = false;
    }

    public static void preventDeletionOfFreeOrderSentToAgora(List<WOO_WMF_Orders__c> oldList) {
        for (WOO_WMF_Orders__c order : oldList) {
            if (
                String.isNotBlank(order.WOO_SAP_status__c) &&
                order.WOO_SAP_status__c != STATUS_NOT_SENT
            ) {
                order.addError(Label.AgoraOrder_Error_DeletionOrderSent);
            }
        }
    }

    public static String buildAgoraRef(String orderType, Case parentCase) {
        String prefix = '';
        if (
            orderType == PicklistWoo_wmf_orders_c.WOO_ORDER_TYPE_C_GOODWILL ||
            orderType == PicklistWoo_wmf_orders_c.WOO_ORDER_TYPE_C_GOODWILL_PRODUCT ||
            orderType == PicklistWoo_wmf_orders_c.WOO_ORDER_TYPE_C_GOODWILL_SPAREPARTS
        ) {
            prefix = 'GW';
        } else if (orderType == PicklistWoo_wmf_orders_c.WOO_ORDER_TYPE_C_FOC) {
            prefix = PicklistWoo_wmf_orders_c.WOO_ORDER_TYPE_C_FOC;
        } else if (orderType == PicklistWoo_wmf_orders_c.WOO_ORDER_TYPE_C_FEX) {
            prefix = PicklistWoo_wmf_orders_c.WOO_ORDER_TYPE_C_FEX;
        }

        String agoraRef = '';
        if (parentCase.AgoraId_Counter__c == null) {
            parentCase.AgoraId_Counter__c = 0;
        }
        if (Integer.valueOf(parentCase.AgoraId_Counter__c) == 0) {
            agoraRef = prefix + parentCase.CaseNumber;
        } else {
            agoraRef =
                prefix +
                parentCase.caseNumber +
                '-' +
                Integer.valueOf(parentCase.AgoraId_Counter__c);
        }
        parentCase.AgoraId_Counter__c++;
        return agoraRef;
    }

    private static void cpyFieldsFromObjectToAnother(
        Sobject sourceObj,
        Sobject targetObj,
        Map<Schema.SObjectField, Schema.SObjectField> fieldMapping /* source => target */
    ) {
        if (sourceObj == null || targetObj == null) {
            return;
        }
        for (Schema.SObjectField sourceField : fieldMapping.keySet()) {
            String fieldValue = (String) sourceObj.get(sourceField);
            if (String.isBlank(fieldValue)) {
                continue;
            }
            targetObj.put(fieldMapping.get(sourceField), fieldValue);
        }
    }

    private class ParentObjMaps {
        ParentObjMaps(List<WOO_WMF_Orders__c> newList) {
            List<Id> caseIds = new List<Id>();
            List<Id> productIds = new List<Id>();
            List<Id> mainOrderIds = new List<Id>();
            for (WOO_WMF_Orders__c newRecord : newList) {
                caseIds.add(newRecord.WOO_Case__c);
                productIds.add(newRecord.WOO_Product__c);
            }
            this.mapIdtoCase = getMapIdtoCase(caseIds);
            this.mapIdtoProduct = getMapIdtoProduct(productIds);
        }
        public Map<Id, Case> mapIdtoCase;
        public Map<Id, Product2> mapIdtoProduct;
    }

    private static Map<Id, Case> getMapIdtoCase(List<Id> caseIds) {
        Map<Id, Case> mapIdtoCase = new Map<Id, Case>(
            [
                SELECT
                    AccountId,
                    ProductId,
                    CaseNumber,
                    Manufacturing_Date__c,
                    Retailer__c,
                    Product_Country__c,
                    AgoraId_Counter__c
                FROM Case
                WHERE Id IN :caseIds
            ]
        );
        return mapIdtoCase;
    }

    private static Map<Id, Product2> getMapIdtoProduct(List<Id> productIds) {
        Map<Id, Product2> mapIdtoProduct = new Map<Id, Product2>(
            [SELECT Country__c FROM Product2 WHERE Id IN :productIds]
        );
        return mapIdtoProduct;
    }

    public static void fillSapOrderAccountField(Map<Id, WOO_WMF_Orders__c> newMap) {
        List<WOO_WMF_Orders__c> orders = [
            SELECT
                WOO_Case__r.AccountId,
                WOO_Case__r.Account.PersonMailingCity,
                WOO_Case__r.Account.PersonMailingPostalCode,
                WOO_Case__r.Account.PersonMailingStreet
            FROM WOO_WMF_Orders__c
            WHERE Id IN :newMap.keySet()
        ];
        for (WOO_WMF_Orders__c order : orders) {
            String orderAccount = order.WOO_Case__r.AccountId;
            String orderAccountCity = order.WOO_Case__r.Account?.PersonMailingCity?.left(35);
            String orderAccountPostalCode = order
                .WOO_Case__r
                .Account
                ?.PersonMailingPostalCode
                ?.left(10);
            String orderAccountStreet = order.WOO_Case__r.Account?.PersonMailingStreet?.left(35);
            if (orderAccount == null) {
                newMap.get(order.Id).addError('An account must be attached to the case');
            } else if (
                orderAccountCity == null ||
                orderAccountPostalCode == null ||
                orderAccountStreet == null
            ) {
                newMap.get(order.Id)
                    .addError('The account must have an address, postal code and town');
            } else {
                order.WOO_Account__c = orderAccount;
                order.WOO_Account_City__c = orderAccountCity;
                order.WOO_Account_Postal_Code__c = orderAccountPostalCode;
                order.WOO_Account_Street__c = orderAccountStreet;
            }
        }
        update orders;
    }

    public static void preventUpdateFreeOrderSentSuccess(
        Map<Id, WOO_WMF_Orders__c> newMap,
        Map<Id, WOO_WMF_Orders__c> oldMap
    ) {
        for (WOO_WMF_Orders__c newOrder : newMap.values()) {
            WOO_WMF_Orders__c oldOrder = oldMap.get(newOrder.Id);
            if (oldOrder.WOO_SAP_status__c == PicklistWoo_wmf_orders_c.WOO_SAP_STATUS_C_SENT) {
                newOrder.addError(Label.AgoraOrder_Error_SentOrderUpdate);
            }
        }
    }
}