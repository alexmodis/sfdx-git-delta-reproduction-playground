public with sharing class WOO_OrderCreateWrapper {
    @TestVisible
    private static Integer numberOfCharacters(Map<String, Integer> mapSAPfieldSize) {
        List<integer> i = mapSAPfieldSize.values();
        Integer sum = 0;
        for (integer j : i) {
            sum = sum + j;
        }
        return sum;
    }

    @TestVisible
    public static String formatFieldValue(String fieldValue, Integer maxLength) {
        if (fieldValue.length() >= maxLength) {
            return fieldValue.left(maxLength);
        } else {
            String spaceString = '';
            for (Integer i = 1; i <= maxLength - fieldValue.length(); i++) {
                spaceString = spaceString + ' ';
            }
            return fieldValue + spaceString;
        }
    }

    public class Header {
        public String headerLine {
            get {
                return headerLine == null ? '' : headerline;
            }
            private set;
        }
        public Map<String, Integer> mapSAPfieldSize = new Map<String, Integer>{
            'SART' => 3,
            'AUART' => 4,
            'VBELN' => 10,
            'VKORG' => 4,
            'KNDNR' => 10,
            'KUNWE' => 10,
            'KUNRG' => 10,
            'KUNRE' => 10,
            'BSTKD' => 35,
            'BSTDK' => 8,
            'ANRAG' => 35,
            'NA1AG' => 35,
            'NA2AG' => 35,
            'NA3AG' => 35,
            'NA4AG' => 35,
            'PLZAG' => 10,
            'ORTAG' => 35,
            'STRAG' => 35,
            'HNUAG' => 10,
            'EMAILAG' => 60,
            'ANRWE' => 35,
            'NA1WE' => 35,
            'NA2WE' => 35,
            'NA3WE' => 35,
            'NA4WE' => 35,
            'PLZWE' => 10,
            'ORTWE' => 35,
            'STRWE' => 35,
            'HNUWE' => 10,
            'EMAILWE' => 60,
            'ANRRE' => 35,
            'NA1RE' => 35,
            'NA2RE' => 35,
            'NA3RE' => 35,
            'NA4RE' => 35,
            'PLZRE' => 10,
            'ORTRE' => 35,
            'STRRE' => 35,
            'HNURE' => 10,
            'EMAILRE' => 60,
            'ANRRG' => 35,
            'NA1RG' => 35,
            'NA2RG' => 35,
            'NA3RG' => 35,
            'NA4RG' => 35,
            'PLZRG' => 10,
            'ORTRG' => 35,
            'STRRG' => 35,
            'HNURG' => 10,
            'EMAILRG' => 60,
            'KOMPV' => 1,
            'VERTR4' => 8,
            'ZZSNDNR' => 35
        };
        List<String> sapFields = new List<String>(mapSAPfieldSize.keySet());

        public Header() {
            for (integer i = 0; i < numberOfCharacters(this.mapSAPfieldSize); i++) {
                this.headerLine = this.headerLine + ' ';
            }
        }

        public void fillHeader(Case c, WOO_WMF_Orders__c order) {
            fillHeaderWithFixedValues(order);
            fillHeaderWithData(c, order);
        }

        @TestVisible
        private void fillHeaderWithFixedValues(WOO_WMF_Orders__c order) {
            String orderType = '';
            switch on order.WOO_Order_Type__c {
                when 'Finished products' {
                    orderType = 'K1TA';
                }
                when 'Spare part' {
                    orderType = 'K1TS';
                }
                when 'Repair' {
                    orderType = 'K1RR';
                }
            }
            this.headerline = 'AKO' + this.headerline.right(this.headerline.length() - 3);
            this.headerline =
                this.headerline.left(3) +
                orderType +
                this.headerline.right(this.headerline.length() - 7);
        }

        private void fillHeaderWithData(Case c, WOO_WMF_Orders__c order) {
            Map<String, String> mapSAPsalesforce = new Map<String, String>{
                'VBELN' => 'CaseNumber',
                'VKORG' => 'WOO_Commercial_organization__c',
                'KNDNR' => 'WOO_CPD_client_code__c',
                'KUNWE' => 'WOO_CPD_client_code__c',
                'KUNRE' => 'WOO_CPD_client_code__c',
                'KUNRG' => 'WOO_CPD_client_code__c',
                'BSTKD' => 'WOO_WMF_Order_Number__c',
                'BSTDK' => 'WOO_Requested_delivery_date_sap_format__c',
                'ANRAG' => 'Salutation',
                'NA1AG' => 'Name',
                'PLZAG' => 'WOO_Account_Postal_Code__c',
                'ORTAG' => 'WOO_Account_City__c',
                'STRAG' => 'WOO_Account_Street__c',
                'EMAILAG' => 'PersonEmail',
                'ANRWE' => 'Salutation',
                'NA1AG' => 'Name',
                'PLZWE' => 'WOO_Account_Postal_Code__c',
                'ORTWE' => 'WOO_Account_City__c',
                'STRWE' => 'WOO_Account_Street__c',
                'EMAILWE' => 'PersonEmail',
                'ANRRE' => 'Salutation',
                'NA1RE' => 'Name',
                'PLZRE' => 'WOO_Account_Postal_Code__c',
                'ORTRE' => 'WOO_Account_City__c',
                'STRRE' => 'WOO_Account_Street__c',
                'EMAILRE' => 'PersonEmail',
                'ANRRG' => 'Salutation',
                'NA1RG' => 'Name',
                'PLZRG' => 'WOO_Account_Postal_Code__c',
                'ORTRG' => 'WOO_Account_City__c',
                'STRRG' => 'WOO_Account_Street__c',
                'EMAILRG' => 'PersonEmail',
                'ZZSNDNR' => 'WOO_Shipment_number__c'
            };
            Integer indexPositionInHeaderline = 7;

            for (Integer j = 2; j < sapFields.size(); j++) {
                Integer fieldLength = mapSAPfieldSize.get(sapFields[j]);
                String fieldName = mapSAPsalesforce.get(sapFields[j]);
                String fieldValue = getFieldsValues(fieldName, c, order);
                if (fieldValue == null) {
                    indexPositionInHeaderline = indexPositionInHeaderline + fieldLength;
                    continue;
                } else {
                    String fieldToInsert = WOO_OrderCreateWrapper.formatFieldValue(
                        fieldValue,
                        fieldLength
                    );
                    this.headerLine =
                        this.headerLine.left(indexPositionInHeaderline) +
                        fieldToInsert +
                        this.headerline.right(
                            this.headerLine.length() - (indexPositionInHeaderline + fieldLength)
                        );
                    indexPositionInHeaderline = indexPositionInHeaderline + fieldLength;
                }
            }
        }

        private String getFieldsValues(String fieldName, Case c, WOO_WMF_Orders__c order) {
            String fieldValue;
            Map<String, Object> orderFieldsValues = order.getPopulatedFieldsAsMap();
            Map<String, Object> caseFieldsValues = c.getPopulatedFieldsAsMap();
            Account acc = (Account) caseFieldsValues.get('Account');
            Map<String, Object> accountFieldsValues = acc.getPopulatedFieldsAsMap();
            if (accountFieldsValues.containsKey(fieldName)) {
                // The account map must be parsed before the order map because of the duplicate key "Name"
                fieldValue = '' + accountFieldsValues.get(fieldName);
            } else if (orderFieldsValues.containsKey(fieldName)) {
                fieldValue = '' + orderFieldsValues.get(fieldName);
            } else if (caseFieldsValues.containsKey(fieldName)) {
                fieldValue = '' + caseFieldsValues.get(fieldName);
            }
            return fieldValue;
        }
    }

    public class OrderLine {
        public String orderLine {
            get {
                return orderLine == null ? '' : orderLine;
            }
            private set;
        }
        public Map<String, Integer> mapSAPfieldSize = new Map<String, Integer>{
            'SART' => 3,
            'VBELN' => 10,
            'BSTKD' => 35,
            'MATNR' => 18,
            'MENGE' => 14,
            'POSNR' => 6,
            'POTYP' => 4,
            'PREIS' => 14,
            'PEINH' => 14,
            'LGORT' => 4,
            'Wunschlieferdatum' => 10,
            'ZUORD' => 3,
            'FEORT' => 3,
            'FEART' => 3,
            'RPINS' => 3
        };
        List<String> sapFields = new List<String>(mapSAPfieldSize.keySet());

        public OrderLine() {
            for (integer i = 0; i < numberOfCharacters(this.mapSAPfieldSize); i++) {
                this.orderLine = this.orderLine + ' ';
            }
        }

        public void fillOrderLine(WOO_WMF_Order_Line_Item__c orderLineItem) {
            fillOrderLineWithFixedValues();
            fillOrderLineWithData(orderLineItem);
        }

        private void fillOrderLineWithFixedValues() {
            this.orderLine = 'APO' + this.orderLine.right(this.orderLine.length() - 3);
        }

        private void fillOrderLineWithData(WOO_WMF_Order_Line_Item__c orderLineItem) {
            Map<String, String> mapSAPsalesforce = new Map<String, String>{
                'VBELN' => 'WOO_WMF_Order_Number__c',
                'BSTKD' => 'WOO_WMF_Order_Number__c',
                'MATNR' => 'WOO_Product_CMMF__c',
                'MENGE' => 'WOO_Requested_quantity__c',
                'ZUORD' => 'WOO_Assigment__c',
                'FEORT' => 'WOO_Defect_Location__c',
                'FEART' => 'WOO_Defect_type__c',
                'RPINS' => 'WOO_Repair_instructions__c'
            };
            Integer indexPositionInOrderline = 3;

            for (Integer j = 1; j < sapFields.size(); j++) {
                Integer fieldLength = mapSAPfieldSize.get(sapFields[j]);
                String fieldName = mapSAPsalesforce.get(sapFields[j]);
                String fieldValue = getFieldsValues(fieldName, orderLineItem);
                if (fieldValue == null) {
                    indexPositionInOrderline = indexPositionInOrderline + fieldLength;
                    continue;
                } else {
                    String fieldToInsert = WOO_OrderCreateWrapper.formatFieldValue(
                        fieldValue,
                        fieldLength
                    );
                    this.orderLine =
                        this.orderLine.left(indexPositionInOrderline) +
                        fieldToInsert +
                        this.orderLine.right(
                            this.orderLine.length() - (indexPositionInOrderline + fieldLength)
                        );
                    indexPositionInOrderline = indexPositionInOrderline + fieldLength;
                }
            }
        }

        private String getFieldsValues(String fieldName, WOO_WMF_Order_Line_Item__c orderLineItem) {
            String fieldValue;
            Map<String, Object> orderLineItemFieldsValues = orderLineItem.getPopulatedFieldsAsMap();
            WOO_WMF_Orders__c order = (WOO_WMF_Orders__c) orderLineItemFieldsValues.get(
                'WOO_WMF_Order__r'
            );
            Map<String, Object> orderFieldsValues = order.getPopulatedFieldsAsMap();
            if (orderFieldsValues.containsKey(fieldName)) {
                fieldValue = '' + orderFieldsValues.get(fieldName);
            } else if (orderLineItemFieldsValues.containsKey(fieldName)) {
                fieldValue = '' + orderLineItemFieldsValues.get(fieldName);
            }
            return fieldValue;
        }
    }

    public class HeaderText {
        public String headerText {
            get {
                return headerText == null ? '' : headerText;
            }
            private set;
        }
        public Map<String, Integer> mapSAPfieldSize = new Map<String, Integer>{
            'SART' => 3,
            'VBELN' => 10,
            'BSTKD' => 35,
            'POSNR' => 6,
            'TEXT' => 70
        };
        List<String> sapFields = new List<String>(mapSAPfieldSize.keySet());

        public HeaderText() {
            for (integer i = 0; i < numberOfCharacters(this.mapSAPfieldSize); i++) {
                this.headerText = this.headerText + ' ';
            }
        }

        public void fillHeaderText(WOO_WMF_Orders__c order) {
            fillHeaderTextWithFixedValues();
            fillHeaderTextWithData(order);
        }

        private void fillHeaderTextWithFixedValues() {
            this.headerText = 'ATX' + this.headerText.right(this.headerText.length() - 3);
            String posnr = WOO_OrderCreateWrapper.formatFieldValue('0000', 6);
            this.headerText =
                this.headerText.left(48) +
                posnr +
                this.headerText.right(this.headerText.length() - 54);
        }

        private void fillHeaderTextWithData(WOO_WMF_Orders__c order) {
            Map<String, String> mapSAPsalesforce = new Map<String, String>{
                'VBELN' => 'WOO_WMF_Order_Number__c',
                'TEXT' => 'WOO_Comment__c'
            };
            Integer indexPositionInHeaderText = 3;

            for (Integer j = 1; j < sapFields.size(); j++) {
                Integer fieldLength = mapSAPfieldSize.get(sapFields[j]);
                String fieldName = mapSAPsalesforce.get(sapFields[j]);
                String fieldValue = getFieldsValues(fieldName, order);
                if (fieldValue == null) {
                    indexPositionInHeaderText = indexPositionInHeaderText + fieldLength;
                    continue;
                } else {
                    String fieldToInsert = WOO_OrderCreateWrapper.formatFieldValue(
                        fieldValue,
                        fieldLength
                    );
                    this.headerText =
                        this.headerText.left(indexPositionInHeaderText) +
                        fieldToInsert +
                        this.headerText.right(
                            this.headerText.length() - (indexPositionInHeaderText + fieldLength)
                        );
                    indexPositionInHeaderText = indexPositionInHeaderText + fieldLength;
                }
            }
        }

        private String getFieldsValues(String fieldName, WOO_WMF_Orders__c order) {
            String fieldValue;
            Map<String, Object> orderFieldsValues = order.getPopulatedFieldsAsMap();
            if (orderFieldsValues.containsKey(fieldName)) {
                fieldValue = '' + orderFieldsValues.get(fieldName);
            }
            return fieldValue;
        }
    }

    public class OrderText {
        public String orderText {
            get {
                return orderText == null ? '' : orderText;
            }
            private set;
        }
        public Map<String, Integer> mapSAPfieldSize = new Map<String, Integer>{
            'SART' => 3,
            'VBELN' => 10,
            'BSTKD' => 35,
            'POSNR' => 6,
            'TEXT' => 70
        };
        List<String> sapFields = new List<String>(mapSAPfieldSize.keySet());

        public OrderText() {
            for (integer i = 0; i < numberOfCharacters(this.mapSAPfieldSize); i++) {
                this.orderText = this.orderText + ' ';
            }
        }

        public void fillOrderText(WOO_WMF_Order_Line_Item__c orderLineItem) {
            fillOrderTextWithFixedValues();
            fillOrderTextWithData(orderLineItem);
        }

        private void fillOrderTextWithFixedValues() {
            this.orderText = 'ATX' + this.orderText.right(this.orderText.length() - 3);
            String posnr = WOO_OrderCreateWrapper.formatFieldValue('0', 6);
            this.orderText =
                this.orderText.left(48) +
                posnr +
                this.orderText.right(this.orderText.length() - 54);
        }

        private void fillOrderTextWithData(WOO_WMF_Order_Line_Item__c orderLineItem) {
            Map<String, String> mapSAPsalesforce = new Map<String, String>{
                'VBELN' => 'WOO_WMF_Order_Number__c',
                'TEXT' => 'WOO_Comment__c'
            };
            Integer indexPositionInOrderText = 3;

            for (Integer j = 1; j < sapFields.size(); j++) {
                Integer fieldLength = mapSAPfieldSize.get(sapFields[j]);
                String fieldName = mapSAPsalesforce.get(sapFields[j]);
                String fieldValue = getFieldsValues(fieldName, orderLineItem);
                if (fieldValue == null) {
                    indexPositionInOrderText = indexPositionInOrderText + fieldLength;
                    continue;
                } else {
                    String fieldToInsert = WOO_OrderCreateWrapper.formatFieldValue(
                        fieldValue,
                        fieldLength
                    );
                    this.orderText =
                        this.orderText.left(indexPositionInOrderText) +
                        fieldToInsert +
                        this.orderText.right(
                            this.orderText.length() - (indexPositionInOrderText + fieldLength)
                        );
                    indexPositionInOrderText = indexPositionInOrderText + fieldLength;
                }
            }
        }

        private String getFieldsValues(String fieldName, WOO_WMF_Order_Line_Item__c orderLineItem) {
            String fieldValue;
            Map<String, Object> orderLineItemFieldsValues = orderLineItem.getPopulatedFieldsAsMap();
            WOO_WMF_Orders__c order = (WOO_WMF_Orders__c) orderLineItemFieldsValues.get(
                'WOO_WMF_Order__r'
            );
            Map<String, Object> orderFieldsValues = order.getPopulatedFieldsAsMap();
            if (orderFieldsValues.containsKey(fieldName)) {
                fieldValue = '' + orderFieldsValues.get(fieldName);
            } else if (orderLineItemFieldsValues.containsKey(fieldName)) {
                fieldValue = '' + orderLineItemFieldsValues.get(fieldName);
            }
            return fieldValue;
        }
    }
}