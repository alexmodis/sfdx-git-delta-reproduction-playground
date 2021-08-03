@isTest
public class WOO_orderSimulateSoapWrapperMock {
    public class SuccessOneLine implements WebServiceMock {
        //salesforce standard method
        @SuppressWarnings('PMD.ExcessiveParameterList')
        public void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType
        ) {
            WOO_orderSimulateSoapWrapper.Z_Z_B_ORDER_SIMULATE_WSResponse_element responseX = new WOO_orderSimulateSoapWrapper.Z_Z_B_ORDER_SIMULATE_WSResponse_element();
            responseX.ORDER_ITEMS_OUT = new WOO_orderSimulateSoapWrapper.ZZBBAPIITEMEX_TAB();
            responseX.ORDER_ITEMS_OUT.item = new List<WOO_orderSimulateSoapWrapper.ZZBBAPIITEMEX>();
            responseX.MESSAGETABLE = new WOO_orderSimulateSoapWrapper.BAPIRET2_T();

            WOO_orderSimulateSoapWrapper.ZZBBAPIITEMEX lineOne = new WOO_orderSimulateSoapWrapper.ZZBBAPIITEMEX();
            lineOne.NET_VALUE1 = '50.00';
            lineOne.MAT_ENTRD = '00000000P1';
            lineOne.MATERIAL = '000000001234567890';
            responseX.ORDER_ITEMS_OUT.Item.add(lineOne);
            response.put('response_x', responseX);
        }
    }
    public class SuccessTwoLine implements WebServiceMock {
        //salesforce standard method
        @SuppressWarnings('PMD.ExcessiveParameterList')
        public void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType
        ) {
            WOO_orderSimulateSoapWrapper.Z_Z_B_ORDER_SIMULATE_WSResponse_element responseX = new WOO_orderSimulateSoapWrapper.Z_Z_B_ORDER_SIMULATE_WSResponse_element();
            responseX.ORDER_ITEMS_OUT = new WOO_orderSimulateSoapWrapper.ZZBBAPIITEMEX_TAB();
            responseX.ORDER_ITEMS_OUT.item = new List<WOO_orderSimulateSoapWrapper.ZZBBAPIITEMEX>();
            responseX.MESSAGETABLE = new WOO_orderSimulateSoapWrapper.BAPIRET2_T();

            WOO_orderSimulateSoapWrapper.ZZBBAPIITEMEX lineOne = new WOO_orderSimulateSoapWrapper.ZZBBAPIITEMEX();
            WOO_orderSimulateSoapWrapper.ZZBBAPIITEMEX lineTwo = new WOO_orderSimulateSoapWrapper.ZZBBAPIITEMEX();
            lineOne.NET_VALUE1 = '10.00';
            lineOne.MAT_ENTRD = '00000000P2';
            lineTwo.NET_VALUE1 = '20.00';
            lineTwo.MAT_ENTRD = '00000000P3';
            responseX.ORDER_ITEMS_OUT.Item.add(lineOne);
            responseX.ORDER_ITEMS_OUT.Item.add(lineTwo);
            response.put('response_x', responseX);
        }
    }

    public class ErrorLine implements WebServiceMock {
        //salesforce standard method
        @SuppressWarnings('PMD.ExcessiveParameterList')
        public void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType
        ) {
            WOO_orderSimulateSoapWrapper.Z_Z_B_ORDER_SIMULATE_WSResponse_element responseX = new WOO_orderSimulateSoapWrapper.Z_Z_B_ORDER_SIMULATE_WSResponse_element();
            responseX.MESSAGETABLE = new WOO_orderSimulateSoapWrapper.BAPIRET2_T();
            responseX.MESSAGETABLE.item = new List<WOO_orderSimulateSoapWrapper.BAPIRET2>();
            WOO_orderSimulateSoapWrapper.BAPIRET2 errorMessageTest = new WOO_orderSimulateSoapWrapper.BAPIRET2();
            errorMessageTest.MESSAGE = 'Error, bad value';
            responseX.MESSAGETABLE.item.add(errorMessageTest);
            response.put('response_x', responseX);
        }
    }

    public class AllLine implements WebServiceMock {
        //salesforce standard method
        @SuppressWarnings('PMD.ExcessiveParameterList')
        public void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType
        ) {
            WOO_orderSimulateSoapWrapper.Z_Z_B_ORDER_SIMULATE_WSResponse_element responseX = new WOO_orderSimulateSoapWrapper.Z_Z_B_ORDER_SIMULATE_WSResponse_element();

            responseX.MESSAGETABLE = new WOO_orderSimulateSoapWrapper.BAPIRET2_T();
            responseX.MESSAGETABLE.item = null;
            new WOO_orderSimulateSoapWrapper.BAPIRET2();

            responseX.ORDER_CONDITION_EX = new WOO_orderSimulateSoapWrapper.CMP_T_COND();
            responseX.ORDER_CONDITION_EX.item = new List<WOO_orderSimulateSoapWrapper.BAPICOND>();
            WOO_orderSimulateSoapWrapper.BAPICOND oceTest = new WOO_orderSimulateSoapWrapper.BAPICOND();
            responseX.ORDER_CONDITION_EX.item.add(oceTest);

            responseX.ORDER_ITEMS_IN = new WOO_orderSimulateSoapWrapper.ESALES_BAPIITEMIN_TAB();
            responseX.ORDER_ITEMS_IN.item = new List<WOO_orderSimulateSoapWrapper.BAPIITEMIN>();
            WOO_orderSimulateSoapWrapper.BAPIITEMIN oiiTest = new WOO_orderSimulateSoapWrapper.BAPIITEMIN();
            responseX.ORDER_ITEMS_IN.item.add(oiiTest);

            responseX.ORDER_ITEMS_OUT = new WOO_orderSimulateSoapWrapper.ZZBBAPIITEMEX_TAB();
            responseX.ORDER_ITEMS_OUT.item = new List<WOO_orderSimulateSoapWrapper.ZZBBAPIITEMEX>();
            WOO_orderSimulateSoapWrapper.ZZBBAPIITEMEX oioTest = new WOO_orderSimulateSoapWrapper.ZZBBAPIITEMEX();
            oioTest.NET_VALUE1 = '50.00';
            oioTest.MAT_ENTRD = '00000000P1';
            oioTest.MATERIAL = '000000001234567890';
            responseX.ORDER_ITEMS_OUT.Item.add(oioTest);

            responseX.ORDER_SCHEDULE_EX = new WOO_orderSimulateSoapWrapper.BAPISDHEDUTAB();
            responseX.ORDER_SCHEDULE_EX.item = new List<WOO_orderSimulateSoapWrapper.BAPISDHEDU>();
            WOO_orderSimulateSoapWrapper.BAPISDHEDU oseTest = new WOO_orderSimulateSoapWrapper.BAPISDHEDU();
            oseTest.ITM_NUMBER = '000010';
            oseTest.REQ_DATE = '2010-01-10';
            oseTest.CONFIR_QTY = '10.0';
            responseX.ORDER_SCHEDULE_EX.item.add(oseTest);

            responseX.ORDER_SCHEDULE_IN = new WOO_orderSimulateSoapWrapper.CMP_T_SCHDL();
            responseX.ORDER_SCHEDULE_IN.item = new List<WOO_orderSimulateSoapWrapper.BAPISCHDL>();
            WOO_orderSimulateSoapWrapper.BAPISCHDL osiTest = new WOO_orderSimulateSoapWrapper.BAPISCHDL();
            osiTest.ITM_NUMBER = '000020';
            oseTest.REQ_DATE = '2010-01-20';
            oseTest.CONFIR_QTY = '20.0';
            responseX.ORDER_SCHEDULE_IN.item.add(osiTest);

            response.put('response_x', responseX);
        }
    }

    public class SuccessTwoLineWithSchedulesOut implements WebServiceMock {
        //salesforce standard method
        @SuppressWarnings('PMD.ExcessiveParameterList')
        public void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType
        ) {
            WOO_orderSimulateSoapWrapper.Z_Z_B_ORDER_SIMULATE_WSResponse_element responseX = new WOO_orderSimulateSoapWrapper.Z_Z_B_ORDER_SIMULATE_WSResponse_element();
            responseX.ORDER_ITEMS_OUT = new WOO_orderSimulateSoapWrapper.ZZBBAPIITEMEX_TAB();
            responseX.ORDER_ITEMS_OUT.item = new List<WOO_orderSimulateSoapWrapper.ZZBBAPIITEMEX>();
            responseX.MESSAGETABLE = new WOO_orderSimulateSoapWrapper.BAPIRET2_T();

            WOO_orderSimulateSoapWrapper.ZZBBAPIITEMEX lineOne = new WOO_orderSimulateSoapWrapper.ZZBBAPIITEMEX();
            WOO_orderSimulateSoapWrapper.ZZBBAPIITEMEX lineTwo = new WOO_orderSimulateSoapWrapper.ZZBBAPIITEMEX();
            lineOne.NET_VALUE1 = '10.00';
            lineOne.MAT_ENTRD = '00000000P2';
            lineTwo.NET_VALUE1 = '20.00';
            lineTwo.MAT_ENTRD = '00000000P3';
            responseX.ORDER_ITEMS_OUT.Item.add(lineOne);
            responseX.ORDER_ITEMS_OUT.Item.add(lineTwo);

            responseX.ORDER_SCHEDULE_EX = new WOO_orderSimulateSoapWrapper.BAPISDHEDUTAB();
            WOO_orderSimulateSoapWrapper.BAPISDHEDU schedule1 = new WOO_orderSimulateSoapWrapper.BAPISDHEDU();
            schedule1.ITM_NUMBER = '000010';
            schedule1.REQ_DATE = '2020-07-21';
            schedule1.CONFIR_QTY = '1.0';

            WOO_orderSimulateSoapWrapper.BAPISDHEDU schedule1bis = new WOO_orderSimulateSoapWrapper.BAPISDHEDU();
            schedule1bis.ITM_NUMBER = '000010';
            schedule1bis.REQ_DATE = '2020-07-22';
            schedule1bis.CONFIR_QTY = '0.0';

            WOO_orderSimulateSoapWrapper.BAPISDHEDU schedule2 = new WOO_orderSimulateSoapWrapper.BAPISDHEDU();
            schedule2.ITM_NUMBER = '000020';
            schedule2.REQ_DATE = '2020-07-23';
            schedule2.CONFIR_QTY = '2.0';

            WOO_orderSimulateSoapWrapper.BAPISDHEDU schedule2bis = new WOO_orderSimulateSoapWrapper.BAPISDHEDU();
            schedule2bis.ITM_NUMBER = '000020';
            schedule2bis.REQ_DATE = '2020-07-24';
            schedule2bis.CONFIR_QTY = '0.0';

            responseX.ORDER_SCHEDULE_EX.item = new List<WOO_orderSimulateSoapWrapper.BAPISDHEDU>{
                schedule1,
                schedule1bis,
                schedule2,
                schedule2bis
            };
            response.put('response_x', responseX);
        }
    }
}