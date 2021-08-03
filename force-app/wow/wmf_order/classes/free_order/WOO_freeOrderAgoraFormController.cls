@SuppressWarnings('PMD.ExcessivePublicCount')
public without sharing class WOO_freeOrderAgoraFormController {
    public static WOO_WS_Agora_Orders.InterfaceDef webServce = new WOO_WS_Agora_Orders();

    /* -------------------------------------------------------------------------- */
    /*                            AgoraUserCode check                             */
    /* -------------------------------------------------------------------------- */
    @AuraEnabled(cacheable=false)
    public static void checkIfAgoraUserCode() {
        String agoraUserCode = [
            SELECT AgoraUserCode__c
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ]
        .AgoraUserCode__c;
        if (String.isBlank(agoraUserCode)) {
            throw new AuraHandledException(Label.AgoraOrder_Error_AgoraUserCode);
        }
    }

    /* -------------------------------------------------------------------------- */
    /*                               sub order list                               */
    /* -------------------------------------------------------------------------- */
    @AuraEnabled(cacheable=false)
    public static WOO_freeOrderAgoraFrontEndDTO.SubOrdersAndLines getSubOrdersAndLines(Id orderId) {
        if (String.isBlank(orderId)) {
            throw new HandledException('orderId cannot be null.');
        }
        WOO_freeOrderAgoraFrontEndDTO.SubOrdersAndLines returnObj = new WOO_freeOrderAgoraFrontEndDTO.SubOrdersAndLines();

        returnObj.subOrdersAndLines = Database.query(
            String.escapeSingleQuotes(
                'SELECT ' +
                '    (' +
                '        SELECT ' +
                WOO_freeOrderAgoraFormSendRepairUtil.fieldsStringForQuery(
                    WOO_freeOrderAgoraFormSendRepairUtil.ORDER_LINES_FIELDS
                ) +
                '        FROM WMF_Order_Line_Items__r' +
                '    ), ' +
                WOO_freeOrderAgoraFormSendRepairUtil.fieldsStringForQuery(
                    WOO_freeOrderAgoraFormSendRepairUtil.ORDER_FIELDS
                ) +
                ', ' +
                WOO_freeOrderAgoraFormSendRepairUtil.fieldsStringForQuery(
                    WOO_freeOrderAgoraFormSendRepairUtil.ORDER_FIELDS_RELATED_OBJ
                ) +
                ' FROM WOO_WMF_Orders__c' +
                ' WHERE Main_Order__c = :orderId'
            )
        );
        returnObj.mainOrderLines = Database.query(
            String.escapeSingleQuotes(
                'SELECT ' +
                WOO_freeOrderAgoraFormSendRepairUtil.fieldsStringForQuery(
                    WOO_freeOrderAgoraFormSendRepairUtil.ORDER_LINES_FIELDS
                ) +
                ' FROM WOO_WMF_Order_Line_Item__c' +
                ' WHERE WOO_WMF_Order__c = :orderId'
            )
        );
        return returnObj;
    }
    /* -------------------------------------------------------------------------- */
    /*                                product list                                */
    /* -------------------------------------------------------------------------- */

    @AuraEnabled(cacheable=false)
    public static List<WOO_freeOrderAgoraFrontEndDTO.AgoraProductResult> getProducts(
        String cccGroup,
        String longRef,
        String country
    ) {
        webServce.loadApiKey(cccGroup);
        List<WOO_freeOrderAgoraFrontEndDTO.AgoraProductResult> productRows = new List<WOO_freeOrderAgoraFrontEndDTO.AgoraProductResult>();
        for (WOO_WS_Agora_Orders.ProductDTO productDto : webServce.getProducts(longRef, country)) {
            WOO_freeOrderAgoraFrontEndDTO.AgoraProductResult row = new WOO_freeOrderAgoraFrontEndDTO.AgoraProductResult();
            row.referenceCommercial = productDto.Refcom;
            row.referenceTechnique = productDto.Reftech;
            row.name = productDto.Description;
            row.agoraKey = productDto.AGORAProductKey;
            row.brand = productDto.BrandLabel;
            productRows.add(row);
        }
        return productRows;
    }

    /* -------------------------------------------------------------------------- */
    /*                                  BOM list                                  */
    /* -------------------------------------------------------------------------- */

    @AuraEnabled(cacheable=false)
    public static List<WOO_freeOrderAgoraFrontEndDTO.TableRow> getBomList(
        String cccGroup,
        String agoraKey
    ) {
        webServce.loadApiKey(cccGroup);
        List<WOO_freeOrderAgoraFrontEndDTO.TableRow> bomRows = new List<WOO_freeOrderAgoraFrontEndDTO.TableRow>();
        for (WOO_WS_Agora_Orders.PartDTO partDTO : webServce.getBomList(agoraKey)) {
            WOO_freeOrderAgoraFrontEndDTO.TableRow row = new WOO_freeOrderAgoraFrontEndDTO.TableRow();
            row.reference = partDTO.PartRef;
            row.name = partDTO.Description;
            row.quantity = Integer.valueOf(partDTO.Quantity);
            row.availability = partDTO.Availability;
            row.deliveryDelay = partDTO.DeliveryDelay;
            row.type = WOO_freeOrderAgoraFrontEndDTO.RowType.BOM.name();
            row.pru = partDTO.PublicPrice;
            bomRows.add(row);
        }
        return bomRows;
    }

    /* -------------------------------------------------------------------------- */
    /*                               sf product list                              */
    /* -------------------------------------------------------------------------- */
    @AuraEnabled(cacheable=false)
    public static List<WOO_freeOrderAgoraFrontEndDTO.SfProduct> searchSfProducts(
        String searchString,
        String country
    ) {
        List<WOO_freeOrderAgoraFrontEndDTO.SfProduct> sfProducts = new List<WOO_freeOrderAgoraFrontEndDTO.SfProduct>();
        List<List<SObject>> soslResult = [
            FIND :searchString
            IN ALL FIELDS
            RETURNING
                Product2(
                    Id,
                    Reference_commerciale__c,
                    CMMF__c,
                    Name,
                    Marque__c,
                    Univers__c,
                    Sousfamille__c,
                    Country__c
                    WHERE Country__c = :country AND Reference_commerciale__c != NULL)
        ];
        for (Product2 prod : (List<Product2>) soslResult[0]) {
            WOO_freeOrderAgoraFrontEndDTO.SfProduct sfProduct = new WOO_freeOrderAgoraFrontEndDTO.SfProduct();
            sfProduct.sfId = prod.Id;
            sfProduct.longRef = prod.Reference_commerciale__c;
            sfProduct.cmmf = prod.CMMF__c;
            sfProduct.name = prod.Name;
            sfProduct.brand = prod.Marque__c;
            sfProduct.universe = prod.Univers__c;
            sfProduct.subFamily = prod.Sousfamille__c;
            sfProduct.country = prod.Country__c;
            sfProducts.add(sfProduct);
        }
        return sfProducts;
    }

    /* -------------------------------------------------------------------------- */
    /*                                  addresses                                 */
    /* -------------------------------------------------------------------------- */
    @AuraEnabled
    public static List<Consumer_Address__c> addresses(Id orderId) {
        if (String.isBlank(orderId)) {
            throw new HandledException('OrderId is required for method addresses');
        }
        WOO_WMF_Orders__c order = [
            SELECT WOO_Case__r.AccountId, WOO_Account__c
            FROM WOO_WMF_Orders__c
            WHERE Id = :orderId
            LIMIT 1
        ];
        if (order.WOO_Case__r.AccountId == null && order.WOO_Account__c == null) {
            throw new AuraHandledException(Label.AgoraOrder_Addr_ErrorNoAccount);
        }
        Id accountId = order.WOO_Account__c != null
            ? order.WOO_Account__c
            : order.WOO_Case__r.AccountId;

        List<Consumer_Address__c> addresses = [
            SELECT
                AddressTitle__c,
                City__c,
                CountryCode__c,
                PostalCode__c,
                Ligne_1__c,
                Ligne_2__c,
                Ligne_3__c,
                MainAddress__c,
                Secondary_Address__c,
                Label__c
            FROM Consumer_Address__c
            WHERE AccountAddress__c = :accountId
        ];
        return addresses;
    }
}