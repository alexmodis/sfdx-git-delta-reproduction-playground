public with sharing class WOO_freeOrderAgoraFormControllerRepair {
    public static WOO_WS_Agora_Orders.InterfaceDef webServce = new WOO_WS_Agora_Orders();

    @AuraEnabled(cacheable=false)
    public static WOO_freeOrderAgoraFrontEndDTO.CreateRepairFrontResponse sendMainOrder(
        WOO_freeOrderAgoraFrontEndDTO.SendOrderBase inputOrderBase,
        WOO_freeOrderAgoraFrontEndDTO.SendOrderMain inputOrderMain
    ) {
        webServce.loadApiKey(inputOrderBase.cccGroup);
        WOO_freeOrderAgoraFrontEndDTO.CreateRepairFrontResponse responseFront = new WOO_freeOrderAgoraFormSendRepairService(
                webServce,
                inputOrderBase
            )
            .sendMainOrder(inputOrderMain);
        return responseFront;
    }

    @AuraEnabled(cacheable=false)
    public static WOO_freeOrderAgoraFrontEndDTO.CreateRepairFrontResponse sendGoodwillSparePartsOrder(
        WOO_freeOrderAgoraFrontEndDTO.SendOrderBase inputOrderBase,
        WOO_freeOrderAgoraFrontEndDTO.SendRepairGoodwillSpareParts inputSparePartsOrder
    ) {
        webServce.loadApiKey(inputOrderBase.cccGroup);
        WOO_freeOrderAgoraFrontEndDTO.CreateRepairFrontResponse responseFront = new WOO_freeOrderAgoraFormSendRepairService(
                webServce,
                inputOrderBase
            )
            .sendGoodwillSparePartsOrder(inputSparePartsOrder);
        return responseFront;
    }

    @AuraEnabled(cacheable=false)
    public static WOO_freeOrderAgoraFrontEndDTO.CreateRepairFrontResponse sendGoodwillProductOrder(
        WOO_freeOrderAgoraFrontEndDTO.SendOrderBase inputOrderBase,
        WOO_freeOrderAgoraFrontEndDTO.SendRepairGoodwillProduct inputGoodwillProductOrder
    ) {
        webServce.loadApiKey(inputOrderBase.cccGroup);
        WOO_freeOrderAgoraFrontEndDTO.CreateRepairFrontResponse responseFront = new WOO_freeOrderAgoraFormSendRepairService(
                webServce,
                inputOrderBase
            )
            .sendGoodwillProductOrder(inputGoodwillProductOrder);
        return responseFront;
    }

    @AuraEnabled(cacheable=false)
    public static void savePreviousErrors(String orderId, String errors) {
        PAD.bypassAll = true;
        update new WOO_WMF_Orders__c(Id = orderId, WOO_Order_Previous_Errors__c = errors);
        PAD.bypassAll = false;
    }
}