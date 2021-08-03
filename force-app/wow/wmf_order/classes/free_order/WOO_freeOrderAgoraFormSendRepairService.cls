@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class WOO_freeOrderAgoraFormSendRepairService {
    private static final String GOODWILL_PRODUCT_ID_FORMAT = '{0}-gw-p-{1}';
    private static final String GOODWILL_SPARE_PARTS_ID_FORMAT = '{0}-gw-sp';
    private static final String GOODWILL_SYMPTOM_FINISHED_PRODUCT = 'GoodwillGestureFinishedProduct';
    private static final String GOODWILL_SYMPTOM_SPARE_PARTS = 'GoodwillGestureSpareParts';
    private WOO_WS_Agora_Orders.InterfaceDef webServce;
    private WOO_WMF_Orders__c order;
    private WOO_freeOrderAgoraFrontEndDTO.SendOrderBase inputOrderBase;

    public WOO_freeOrderAgoraFormSendRepairService(
        WOO_WS_Agora_Orders.InterfaceDef webServce,
        WOO_freeOrderAgoraFrontEndDTO.SendOrderBase inputOrderBase
    ) {
        if (webServce == null || inputOrderBase == null) {
            throw new HandledException('Required Param WOO_freeOrderAgoraFormSendRepairService');
        }
        this.webServce = webServce;
        this.inputOrderBase = inputOrderBase;
        this.order = WOO_freeOrderAgoraFormSendRepairUtil.getOrderAndCheckFields(
            inputOrderBase.mainOrderId
        );
    }

    public WOO_freeOrderAgoraFrontEndDTO.CreateRepairFrontResponse sendMainOrder(
        WOO_freeOrderAgoraFrontEndDTO.SendOrderMain inputMainOrder
    ) {
        WOO_freeOrderAgoraFrontEndDTO.CreateRepairFrontResponse responseFront;
        WOO_WS_Agora_Orders.CompleteRepairDTO mainCreateRepairBody = buildMainBody(inputMainOrder);
        if (
            this.order.WOO_Order_Type__c == PicklistWoo_wmf_orders_c.WOO_ORDER_TYPE_C_FOC ||
            this.order.WOO_Order_Type__c == PicklistWoo_wmf_orders_c.WOO_ORDER_TYPE_C_FEX
        ) {
            responseFront = callWs(mainCreateRepairBody, this.order.WOO_SAP_status__c);
        } else {
            // For Goodwill Orders mainCreateRepairBody is not sent but
            // it is used a model for goodwill products subcalls
            responseFront = new WOO_freeOrderAgoraFrontEndDTO.CreateRepairFrontResponse();
            responseFront.isValid = true;
        }

        if (responseFront.isValid) {
            this.order.WOO_SAP_status__c = 'Sent';
        } else {
            this.order.WOO_SAP_status__c = 'SentWithErrors';
        }
        if (
            this.order.WOO_Order_Type__c == PicklistWoo_wmf_orders_c.WOO_ORDER_TYPE_C_FOC ||
            this.order.WOO_Order_Type__c == PicklistWoo_wmf_orders_c.WOO_ORDER_TYPE_C_FEX
        ) {
            this.order.WOO_Agora_Submission_Datetime__c = System.now();
        }
        if (inputMainOrder.orderProduct != null) {
            // goodwill don't have an orderProduct
            this.order.WOO_Agora_ProductRefCom__c = inputMainOrder.orderProduct.referenceCommercial;
        }
        PAD.bypassAll = true;
        update order;
        insert WOO_freeOrderAgoraFormSendRepairUtil.generateOrderLines(
            inputMainOrder.bomList,
            order.Id
        );
        PAD.bypassAll = false;
        return responseFront;
    }

    public WOO_freeOrderAgoraFrontEndDTO.CreateRepairFrontResponse sendGoodwillSparePartsOrder(
        WOO_freeOrderAgoraFrontEndDTO.SendRepairGoodwillSpareParts inputSparePartsOrder
    ) {
        if (inputSparePartsOrder == null || inputSparePartsOrder.goodwillSpareParts.isEmpty()) {
            throw new HandledException(
                'Method goodwillSparePartsCall should not be used without a non-empty list goodwillSpareParts.'
            );
        }
        WOO_WMF_Orders__c sparePartSubOrder = null;
        for (WOO_WMF_Orders__c subOrder : this.order.Subsidiary_Orders__r) {
            if (subOrder.WOO_Order_Type__c == 'Goodwill_SpareParts') {
                sparePartSubOrder = subOrder;
                break;
            }
        }
        sparePartSubOrder = initSuborderIfNull(sparePartSubOrder, 'Goodwill_SpareParts');
        WOO_WS_Agora_Orders.CompleteRepairDTO orderBody = generateGoodwillSparePartsBody(
            inputSparePartsOrder
        );
        orderBody.MissionOrder = sparePartSubOrder.WOO_Agora_Order_Ref__c;
        WOO_freeOrderAgoraFrontEndDTO.CreateRepairFrontResponse orderResponse = callWs(
            orderBody,
            sparePartSubOrder.WOO_SAP_status__c
        );
        setSubOrderFields(sparePartSubOrder, orderResponse.isValid);

        PAD.bypassAll = true;
        update this.order.WOO_Case__r; // buildAgoraRef might have updated agoraCounterId on case
        upsert sparePartSubOrder;
        insert WOO_freeOrderAgoraFormSendRepairUtil.generateOrderLines(
            inputSparePartsOrder.goodwillSpareParts,
            sparePartSubOrder.Id
        );
        PAD.bypassAll = false;
        return orderResponse;
    }

    public WOO_freeOrderAgoraFrontEndDTO.CreateRepairFrontResponse sendGoodwillProductOrder(
        WOO_freeOrderAgoraFrontEndDTO.SendRepairGoodwillProduct inputGoodwillProductOrder
    ) {
        if (
            inputGoodwillProductOrder == null ||
            inputGoodwillProductOrder.goodwillProduct == null
        ) {
            throw new HandledException('parameter goodwillProduct cannot be null.');
        }
        if (
            String.isBlank(inputGoodwillProductOrder.goodwillProduct.sfProductId) ||
            String.isBlank(inputGoodwillProductOrder.goodwillProduct.reference)
        ) {
            throw new HandledException(
                'parameter goodwillProduct needs a sfProductId and a reference field.'
            );
        }
        WOO_WMF_Orders__c productSubOrder = null;
        for (WOO_WMF_Orders__c subOrder : this.order.Subsidiary_Orders__r) {
            if (
                subOrder.WOO_Order_Type__c == 'Goodwill_Product' &&
                String.isNotBlank(subOrder.WOO_Product__c) &&
                subOrder.WOO_Product__c == inputGoodwillProductOrder.goodwillProduct.sfProductId
            ) {
                productSubOrder = subOrder;
                break;
            }
        }
        productSubOrder = initSuborderIfNull(productSubOrder, 'Goodwill_Product');

        WOO_WS_Agora_Orders.CompleteRepairDTO orderBody = initCreateRepairBody();
        orderBody.MissionOrder = productSubOrder.WOO_Agora_Order_Ref__c;
        orderBody.CommercialRef = inputGoodwillProductOrder.goodwillProduct.reference;
        orderBody.Intervention = WOO_freeOrderAgoraFormSendRepairUtil.buildIntervention(
            GOODWILL_SYMPTOM_FINISHED_PRODUCT,
            this.order.WOO_Case__r.Exchange_Agreement_Number__c
        );
        WOO_freeOrderAgoraFrontEndDTO.CreateRepairFrontResponse orderResponse = callWs(
            orderBody,
            productSubOrder.WOO_SAP_status__c
        );
        setSubOrderFields(productSubOrder, orderResponse.isValid);
        productSubOrder.WOO_Comment__c = inputGoodwillProductOrder.goodwillProduct.name;
        // WOO_Comment__c stock ici un nom dans une certaine langue, bug de traduction potentiel si
        // on change de langue après avoir stocké car le back-end n'est pas rappellé
        productSubOrder.WOO_Product__c = inputGoodwillProductOrder.goodwillProduct.sfProductId;
        productSubOrder.WOO_Agora_ProductRefCom__c = inputGoodwillProductOrder.goodwillProduct.reference;

        PAD.bypassAll = true;
        update this.order.WOO_Case__r; // buildAgoraRef might have updated agoraCounterId on case
        upsert productSubOrder;
        PAD.bypassAll = false;
        return orderResponse;
    }

    private WOO_WS_Agora_Orders.CompleteRepairDTO buildMainBody(
        WOO_freeOrderAgoraFrontEndDTO.SendOrderMain inputMainOrder
    ) {
        WOO_WS_Agora_Orders.CompleteRepairDTO mainCreateRepairBody;
        if (this.order.WOO_Order_Type__c == PicklistWoo_wmf_orders_c.WOO_ORDER_TYPE_C_FOC) {
            mainCreateRepairBody = createRepairFoc(inputMainOrder.bomList);
        } else if (this.order.WOO_Order_Type__c == PicklistWoo_wmf_orders_c.WOO_ORDER_TYPE_C_FEX) {
            mainCreateRepairBody = createRepairFex();
        } else if (
            this.order.WOO_Order_Type__c == PicklistWoo_wmf_orders_c.WOO_ORDER_TYPE_C_GOODWILL
        ) {
            mainCreateRepairBody = createRepairGoodwill();
        }
        mainCreateRepairBody.CommercialRef = inputMainOrder.orderProduct?.referenceCommercial;
        mainCreateRepairBody.TechnicalRef = inputMainOrder.orderProduct?.referenceTechnique;
        return mainCreateRepairBody;
    }

    private WOO_WS_Agora_Orders.CompleteRepairDTO initCreateRepairBody() {
        WOO_WS_Agora_Orders.CompleteRepairDTO createRepairBody = new WOO_WS_Agora_Orders.CompleteRepairDTO();
        createRepairBody.UserCode = [
            SELECT AgoraUserCode__c
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ]
        .AgoraUserCode__c;
        createRepairBody.CallDate = System.now();
        createRepairBody.Consumer = WOO_freeOrderAgoraFormSendRepairUtil.fillConsumerDTO(
            this.inputOrderBase.consumerAddress,
            this.order.WOO_Account__r
        );

        if (this.order.WOO_Agora_Symptoms__c != 'GoodwillGesture') {
            // There is no mapping for 'GoodwillGesture' on it's own
            createRepairBody.Intervention = WOO_freeOrderAgoraFormSendRepairUtil.buildIntervention(
                this.order.WOO_Agora_Symptoms__c,
                this.order.WOO_Case__r.Exchange_Agreement_Number__c
            );
        }
        createRepairBody.PurchaseDate = this.order.WOO_Case__r.Purchase_Date__c;
        createRepairBody.ManufacturingCode = this.order.WOO_AgoraManufacturingDate__c;
        createRepairBody.ManufacturerId = WOO_WS_Agora_Orders.MANUFACTURER_ID;
        createRepairBody.MissionOrder = this.order.WOO_Agora_Order_Ref__c;
        createRepairBody.Reseller = WOO_freeOrderAgoraFormSendRepairUtil.buildResetailer(order);
        createRepairBody.DeliveryAddress = WOO_freeOrderAgoraFormSendRepairUtil.fillDeliveryAddress(
            this.inputOrderBase.consumerAddress,
            this.order.WOO_Account__r
        );
        createRepairBody.TimeZoneId = ''; // see class definition for more info
        return createRepairBody;
    }
    private WOO_WS_Agora_Orders.CompleteRepairDTO createRepairFoc(
        List<WOO_freeOrderAgoraFrontEndDTO.TableRow> bomList
    ) {
        WOO_WS_Agora_Orders.CompleteRepairDTO createRepairBody = initCreateRepairBody();
        createRepairBody.Intervention.IRISCondition = 1;
        createRepairBody.Intervention.IRISConditionEX = 'X1X';
        if (bomList != null && !bomList.isEmpty()) {
            createRepairBody.Parts = partsMapping(bomList);
        }
        return createRepairBody;
    }

    private List<WOO_WS_Agora_Orders.CreateRepairPartDTO> partsMapping(
        List<WOO_freeOrderAgoraFrontEndDTO.TableRow> parts
    ) {
        if (parts == null || parts.isEmpty()) {
            return null;
        }
        List<WOO_WS_Agora_Orders.CreateRepairPartDTO> partsMapped = new List<WOO_WS_Agora_Orders.CreateRepairPartDTO>();
        for (WOO_freeOrderAgoraFrontEndDTO.TableRow part : parts) {
            WOO_WS_Agora_Orders.CreateRepairPartDTO partMapped = new WOO_WS_Agora_Orders.CreateRepairPartDTO();
            partMapped.Quantity = part.quantitySelected;
            partMapped.ToBeOrdered = true; //TODO is it always the case ?
            partMapped.Reference = part.reference;
            partsMapped.add(partMapped);
        }
        return partsMapped;
    }

    private WOO_WS_Agora_Orders.CompleteRepairDTO createRepairFex() {
        WOO_WS_Agora_Orders.CompleteRepairDTO createRepairBody = initCreateRepairBody();
        return createRepairBody;
    }

    private WOO_WS_Agora_Orders.CompleteRepairDTO createRepairGoodwill() {
        WOO_WS_Agora_Orders.CompleteRepairDTO createRepairBody = initCreateRepairBody();
        return createRepairBody;
    }

    private WOO_WMF_Orders__c initSuborderIfNull(WOO_WMF_Orders__c subOrder, String orderType) {
        if (subOrder == null) {
            subOrder = new WOO_WMF_Orders__c(
                Main_Order__c = this.order.Id,
                WOO_Case__c = this.order.WOO_Case__c,
                WOO_Order_Type__c = orderType,
                RecordTypeId = CustomMetadataCache.getRecordTypeMapByName()
                    .get('Free_Orders_Subsidiary')
                    .Id,
                WOO_Agora_Symptoms__c = 'GoodwillGesture',
                WOO_Agora_Order_Ref__c = WOO_WMFOrdersHandler.buildAgoraRef(
                    orderType,
                    this.order.WOO_Case__r
                ),
                WOO_SAP_status__c = PicklistWoo_wmf_orders_c.WOO_SAP_STATUS_C_NOTSENT
            );
        }
        return subOrder;
    }
    private void setSubOrderFields(WOO_WMF_Orders__c subOrder, Boolean isSuccess) {
        for (Schema.SObjectField field : WOO_freeOrderAgoraFormSendRepairUtil.ORDER_FIELDS) {
            if (
                new List<String>{
                        'WOO_Order_Type__c',
                        'WOO_Agora_Order_Ref__c',
                        'WOO_Agora_Symptoms__c',
                        'WOO_Case__c'
                    }
                    .contains(field.getDescribe().name)
            ) {
                continue;
            }
            subOrder.put(field, this.order.get(field));
        }
        if (isSuccess) {
            subOrder.WOO_SAP_status__c = 'Sent';
        } else {
            subOrder.WOO_SAP_status__c = 'SentWithErrors';
        }
    }

    private WOO_WS_Agora_Orders.CompleteRepairDTO generateGoodwillSparePartsBody(
        WOO_freeOrderAgoraFrontEndDTO.SendRepairGoodwillSpareParts inputSparePartsOrder
    ) {
        WOO_WS_Agora_Orders.CompleteRepairDTO goodwillBodySpareParts = initCreateRepairBody();
        goodwillBodySpareParts.Parts = partsMapping(inputSparePartsOrder.goodwillSpareParts);
        goodwillBodySpareParts.Intervention = WOO_freeOrderAgoraFormSendRepairUtil.buildIntervention(
            GOODWILL_SYMPTOM_SPARE_PARTS,
            this.order.WOO_Case__r.Exchange_Agreement_Number__c
        );
        goodwillBodySpareParts.CommercialRef = inputSparePartsOrder.orderProduct
            ?.referenceCommercial;
        goodwillBodySpareParts.TechnicalRef = inputSparePartsOrder.orderProduct?.referenceTechnique;
        return goodwillBodySpareParts;
    }

    private WOO_freeOrderAgoraFrontEndDTO.CreateRepairFrontResponse initiateFrontResponse(
        WOO_WS_Agora_Orders.SendRepairResponseData responseCreateOrUpdate,
        Boolean isValid,
        String missionOrderId
    ) {
        WOO_freeOrderAgoraFrontEndDTO.CreateRepairFrontResponse responseFront = new WOO_freeOrderAgoraFrontEndDTO.CreateRepairFrontResponse();
        responseFront.isValid = isValid;
        if (!responseFront.isValid) {
            responseFront.errorMessage = responseCreateOrUpdate.ErrorMessage;
            for (
                WOO_WS_Agora_Orders.ValidationError valErr : responseCreateOrUpdate.ValidationErrors
            ) {
                WOO_freeOrderAgoraFrontEndDTO.ValidationErrorFront valErrFront = new WOO_freeOrderAgoraFrontEndDTO.ValidationErrorFront();
                valErrFront.errorMessage = valErr.errorMessage;
                valErrFront.field = valErr.field;
                valErrFront.messageType = valErr.messageType;
                responseFront.validationErrors.add(valErrFront);
            }
        }
        return responseFront;
    }
    private WOO_freeOrderAgoraFrontEndDTO.CreateRepairFrontResponse callWsCreate(
        WOO_WS_Agora_Orders.CompleteRepairDTO createRepairBody,
        String language
    ) {
        WOO_WS_Agora_Orders.CreateRepairResponseData responseCreate = webServce.createRepair(
            createRepairBody,
            language
        );
        return initiateFrontResponse(
            responseCreate,
            responseCreate.IsValid,
            createRepairBody.MissionOrder
        );
    }
    private WOO_freeOrderAgoraFrontEndDTO.CreateRepairFrontResponse callWsUpdate(
        WOO_WS_Agora_Orders.CompleteRepairDTO createRepairBody,
        String language
    ) {
        WOO_WS_Agora_Orders.CompleteRepairStateDTO updateRepairBody = (WOO_WS_Agora_Orders.CompleteRepairStateDTO) JSON.deserialize(
            JSON.serialize(createRepairBody),
            WOO_WS_Agora_Orders.CompleteRepairStateDTO.class
        );
        WOO_WS_Agora_Orders.UpdateRepairResponseData responseUpate = webServce.updateRepair(
            updateRepairBody,
            language
        );
        return initiateFrontResponse(
            responseUpate,
            responseUpate.IsRepairFileValid,
            updateRepairBody.MissionOrder
        );
    }
    private WOO_freeOrderAgoraFrontEndDTO.CreateRepairFrontResponse callWs(
        WOO_WS_Agora_Orders.CompleteRepairDTO createRepairBody,
        String orderStatus
    ) {
        String language = WOO_freeOrderAgoraFormSendRepairUtil.getAgoraLanguage();
        if (orderStatus == 'NotSent') {
            try {
                return callWsCreate(createRepairBody, language);
            } catch (WOO_WS_Agora_Orders.OrderAlreadyExistsException e) {
                return callWsUpdate(createRepairBody, language);
            }
        }
        return callWsUpdate(createRepairBody, language);
    }
}