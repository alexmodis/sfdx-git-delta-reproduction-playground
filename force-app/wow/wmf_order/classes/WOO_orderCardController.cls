public with sharing class WOO_orderCardController {
    private static list<WOO_WMF_Order_Line_Item__c> orderLineItem;
    private static WOO_WMF_Orders__c order;

    @AuraEnabled(cacheable=false)
    public static string getSimulateCall(id orderId) {
        System.debug('----- WOO_orderCardController.getSimulateCall: ' + orderId);

        initOrderAndLineItems(orderId);

        WOO_orderSimulateSoapWrapper.ESALES_BAPIITEMIN_TAB sapOrderlineItem = generateSAPOrderLineItem(
            orderLineItem
        );

        String docType = order.WOO_Order_Type__c == 'Finished products' ? 'K1TA' : 'K1TS';

        String todayMonth;
        if (Date.today().month() < 10) {
            todayMonth = '0' + String.valueOf(Date.today().month());
        } else {
            todayMonth = String.valueOf(Date.today().month());
        }

        String todayDay;
        if (Date.today().day() < 10) {
            todayDay = '0' + String.valueOf(Date.today().day());
        } else {
            todayDay = String.valueOf(Date.today().day());
        }

        String todayDate = Date.today().year() + '-' + todayMonth + '-' + todayDay;

        WOO_orderSimulateSoapWrapper.Simulate simulate = new WOO_orderSimulateSoapWrapper.Simulate();
        WOO_orderSimulateSoapWrapper.Z_Z_B_ORDER_SIMULATE_WSResponse_element response = simulate.Z_Z_B_ORDER_SIMULATE_WS(
            null, // String COMPL_DLV,
            '01', // String DISTR_CHAN,
            '01', // String DIVISION,
            null, // String DLV_BLOCK,
            docType, // String DOC_TYPE,
            null, // WOO_orderSimulate.BAPIRET2_T MESSAGETABLE,
            null, // WOO_orderSimulate.CMP_T_COND ORDER_CONDITION_EX,
            sapOrderlineItem, // WOO_orderSimulate.ESALES_BAPIITEMIN_TAB ORDER_ITEMS_IN,
            null, // WOO_orderSimulate.ZZBBAPIITEMEX_TAB ORDER_ITEMS_OUT,
            null, // WOO_orderSimulate.BAPISDHEDUTAB ORDER_SCHEDULE_EX,
            null, // WOO_orderSimulate.CMP_T_SCHDL ORDER_SCHEDULE_IN,
            'SFAP', // String PO_METHOD,
            todayDate, // String PRICE_DATE,
            order.WOO_WMF_Order_Number__c, // String PURCH_NO,
            order.WOO_Commercial_organization__c, // String SALES_ORG,
            order.WOO_CPD_client_code__c, // String SHIP_TO,
            order.WOO_CPD_client_code__c // String SOLD_TO
        );

        return saveSAPResponse(response);
    }

    @AuraEnabled
    public static string setAddress(id orderId) {
        Map<Id, WOO_WMF_Orders__c> orders = new Map<Id, WOO_WMF_Orders__c>(
            [SELECT Id FROM WOO_WMF_Orders__c WHERE Id = :orderId]
        );
        try {
            WOO_WMFOrdersHandler.fillSapOrderAccountField(orders);
        } catch (Exception e) {
            return e.getMessage();
        }
        return 'ok';
    }

    private static void initOrderAndLineItems(id orderId) {
        orderLineItem = [
            SELECT
                WOO_EAN__c,
                WOO_WMF_Order__r.WOO_WMF_Order_Number__c,
                WOO_WMF_Order__r.WOO_Error_Message__c,
                WOO_WMF_Order__r.WOO_Commercial_organization__c,
                WOO_WMF_Order__r.WOO_CPD_client_code__c,
                WOO_Product_CMMF__c,
                WOO_Requested_quantity__c
            FROM WOO_WMF_Order_Line_Item__c
            WHERE WOO_WMF_Order__c = :orderId
        ];
        order = new WOO_WMF_Orders__c(
            id = orderId,
            WOO_Error_Message__c = orderLineItem[0].WOO_WMF_Order__r.WOO_Error_Message__c,
            WOO_CPD_client_code__c = orderLineItem[0].WOO_WMF_Order__r.WOO_CPD_client_code__c,
            WOO_Commercial_organization__c = orderLineItem[0]
                .WOO_WMF_Order__r.WOO_Commercial_organization__c
        );
    }

    private static WOO_orderSimulateSoapWrapper.ESALES_BAPIITEMIN_TAB generateSAPOrderLineItem(
        list<WOO_WMF_Order_Line_Item__c> orderLineItem
    ) {
        System.debug('----- mapSfWithSAP ');

        WOO_orderSimulateSoapWrapper.ESALES_BAPIITEMIN_TAB sapOrderlineItem = new WOO_orderSimulateSoapWrapper.ESALES_BAPIITEMIN_TAB();
        system.debug(sapOrderlineItem);
        sapOrderlineItem.item = new List<WOO_orderSimulateSoapWrapper.BAPIITEMIN>();

        for (integer i = 0; i < orderLineItem.size(); i++) {
            WOO_orderSimulateSoapWrapper.BAPIITEMIN currItem = new WOO_orderSimulateSoapWrapper.BAPIITEMIN();
            currItem.PO_ITM_NO = String.valueOf(i + 1);
            currItem.MATERIAL = orderLineItem[i].WOO_Product_CMMF__c;
            currItem.TARGET_QTY = String.valueOf(orderLineItem[i].WOO_Requested_quantity__c);
            sapOrderlineItem.item.add(currItem);
        }

        return sapOrderlineItem;
    }

    private static string saveSAPResponse(
        WOO_orderSimulateSoapWrapper.Z_Z_B_ORDER_SIMULATE_WSResponse_element response
    ) {
        System.debug('----- saveSAPResponse ');

        updateOrderLineItemsInSuccess(response);
        updateOrderWhenInError(response);
        if (order.WOO_Error_Message__c <> null) {
            return 'ko';
        }
        update orderLineItem;
        return 'ok';
    }

    private static void updateOrderLineItemsInSuccess(
        WOO_orderSimulateSoapWrapper.Z_Z_B_ORDER_SIMULATE_WSResponse_element response
    ) {
        System.debug('----- updateOrderLineItemsInSuccess ');
        if (response.ORDER_ITEMS_OUT <> null) {
            if (response.ORDER_ITEMS_OUT.item <> null) {
                putPriceInCorrectOrderLineItem(response);
            }
        }
        WOO_orderSimulateSoapWrapper.BAPISDHEDU[] schedulesOut = response.ORDER_SCHEDULE_EX?.item;
        if (schedulesOut != null) {
            putEcheanceFieldsInCorrectOrderLineItem(schedulesOut);
        }
    }
    private static void updateOrderWhenInError(
        WOO_orderSimulateSoapWrapper.Z_Z_B_ORDER_SIMULATE_WSResponse_element response
    ) {
        System.debug('----- updateOrderWhenInError ');
        order.WOO_Error_Message__c = null;

        if (response.MESSAGETABLE.item <> null && response.MESSAGETABLE <> null) {
            order.WOO_Error_Message__c = response.MESSAGETABLE.item[0].MESSAGE;
            order.WOO_SAP_status__c = 'Simulated with errors';
        } else {
            order.WOO_SAP_status__c = 'Simulated Ok';
        }
        upsert order;
    }

    private static void putEcheanceFieldsInCorrectOrderLineItem(
        WOO_orderSimulateSoapWrapper.BAPISDHEDU[] schedulesOut
    ) {
        // - orderLineItem(list d'index [0..N-1]) => input WS : ESALES_BAPIITEMIN_TAB(list avec PO_ITM_NO = [1..N])
        // - output WS => autre listes, BAPISDHEDUTAB(schedulesOut list)
        // - le WS renvoi les index fourni en entré.ESALES_BAPIITEMIN_TAB[i].PO_ITM_NO dans la reponse.BAPISDHEDUTAB[i].ITM_NUMBER
        // - BAPISDHEDUTAB(list de taille 2*N avec 2 elems pour chaque ITM_NUMBER [1*10..2*10..N*10])

        // donc pour lier un BAPISDHEDU à son orderLineItem[i] orginal
        //  => orderLineItem[(BAPISDHEDU.ITM_NUMBER / 10) - 1]

        //schedulesOut[i].ITM_NUMBER = 10 * ESALES_BAPIITEMIN_TAB[i].PO_ITM_NO = 10 * ("index orderLineItem" + 1 )

        Map<Integer, List<WOO_orderSimulateSoapWrapper.BAPISDHEDU>> mapOrderLineIndexToSchedulOuts = new Map<Integer, List<WOO_orderSimulateSoapWrapper.BAPISDHEDU>>();
        for (WOO_orderSimulateSoapWrapper.BAPISDHEDU schedule : schedulesOut) {
            Integer orderLineIndex = Integer.valueOf(schedule.ITM_NUMBER) / 10 - 1;
            if (orderLineIndex < 0 || orderLineIndex >= orderLineItem.size()) {
                System.debug(
                    'The code for WOO_orderSimulateSoapWrapper WS has a problem (scheduleOut index out of range)'
                );
                return;
            }
            List<WOO_orderSimulateSoapWrapper.BAPISDHEDU> matchingSchedulesOut = mapOrderLineIndexToSchedulOuts.get(
                orderLineIndex
            );
            if (matchingSchedulesOut == null) {
                matchingSchedulesOut = new List<WOO_orderSimulateSoapWrapper.BAPISDHEDU>();
                mapOrderLineIndexToSchedulOuts.put(orderLineIndex, matchingSchedulesOut);
            }
            matchingSchedulesOut.add(schedule);
        }
        for (Integer orderLineIndex : mapOrderLineIndexToSchedulOuts.keySet()) {
            List<WOO_orderSimulateSoapWrapper.BAPISDHEDU> matchingSchedulesOut = mapOrderLineIndexToSchedulOuts.get(
                orderLineIndex
            );
            if (matchingSchedulesOut.size() != 2) {
                System.Debug(
                    'The code for WOO_orderSimulateSoapWrapper WS has a problem (There should be 2 scheduleOut for an orderLine.)'
                );
            }
            // matchingSchedulesOut is expected to have 2 schedulesOut and we discard the one that has a REQ_QTY = 0
            for (WOO_orderSimulateSoapWrapper.BAPISDHEDU scheduleOut : matchingSchedulesOut) {
                Integer confirmQty = Integer.valueOf(scheduleOut.CONFIR_QTY);
                if (confirmQty != 0) {
                    WOO_WMF_Order_Line_Item__c orderLine = orderLineItem[orderLineIndex];
                    orderLine.WOO_Confirmed_quantity__c = confirmQty;
                    orderLine.WOO_Returned_delivery_date__c = Date.valueOf(scheduleOut.REQ_DATE);
                }
            }
        }
    }

    private static void putPriceInCorrectOrderLineItem(
        WOO_orderSimulateSoapWrapper.Z_Z_B_ORDER_SIMULATE_WSResponse_element response
    ) {
        System.debug('----- putPriceInCorrectOrderLineItem ');
        for (WOO_WMF_Order_Line_Item__c oli : orderLineItem) {
            oli.WOO_Unitary_price__c = 0;
        }
        for (Integer i = 0; i < response.ORDER_ITEMS_OUT.item.size(); i++) {
            for (WOO_WMF_Order_Line_Item__c oli : orderLineItem) {
                if (
                    oli.WOO_Product_CMMF__c ==
                    response.ORDER_ITEMS_OUT.item[i].MAT_ENTRD.substring(8)
                ) {
                    oli.WOO_Unitary_price__c =
                        Decimal.valueOf(response.ORDER_ITEMS_OUT.item[i].NET_VALUE1) /
                        oli.WOO_Requested_quantity__c;
                    if (response.ORDER_ITEMS_OUT.item[i].MATERIAL <> null) {
                        oli.WOO_CMMF_in_case_of_replacement__c = response.ORDER_ITEMS_OUT.item[i]
                            .MATERIAL.substring(8);
                    }
                    break;
                }
            }
        }
        for (WOO_WMF_Order_Line_Item__c oli : orderLineItem) {
            System.debug(
                'CMMF: ' +
                oli.WOO_Product_CMMF__c +
                ' price: ' +
                oli.WOO_Unitary_price__c +
                ' quantity: ' +
                oli.WOO_Requested_quantity__c
            );
        }
    }
}