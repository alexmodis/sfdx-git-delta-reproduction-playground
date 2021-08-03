public without sharing class WOO_freeOrderAgoraFormSendRepairUtil {
    public static final List<String> ORDER_FIELDS_RELATED_OBJ = new List<String>{
        'WOO_WMF_Orders__c.WOO_Case__r.AccountId',
        'WOO_WMF_Orders__c.WOO_Case__r.Exchange_Agreement_Number__c',
        'WOO_WMF_Orders__c.WOO_Case__r.Purchase_Date__c',
        'WOO_WMF_Orders__c.WOO_Case__r.caseNumber',
        'WOO_WMF_Orders__c.WOO_Case__r.AgoraId_Counter__c',
        'WOO_WMF_Orders__c.WOO_Account__r.Title_2__c',
        'WOO_WMF_Orders__c.WOO_Account__r.Salutation',
        'WOO_WMF_Orders__c.WOO_Account__r.LastName',
        'WOO_WMF_Orders__c.WOO_Account__r.FirstName',
        'WOO_WMF_Orders__c.WOO_Account__r.Phone',
        'WOO_WMF_Orders__c.WOO_Account__r.PersonOtherPhone',
        'WOO_WMF_Orders__c.WOO_Account__r.PersonMobilePhone',
        'WOO_WMF_Orders__c.WOO_Product__c'
    };
    public static final List<Schema.SObjectField> ORDER_FIELDS = new List<Schema.SObjectField>{
        WOO_WMF_Orders__c.WOO_Order_Type__c,
        WOO_WMF_Orders__c.WOO_Agora_Order_Ref__c,
        WOO_WMF_Orders__c.WOO_Agora_ProductRefCom__c,
        WOO_WMF_Orders__c.WOO_Comment__c,
        WOO_WMF_Orders__c.WOO_SAP_status__c,
        WOO_WMF_Orders__c.WOO_Agora_TechJsonState__c,
        WOO_WMF_Orders__c.WOO_Retailer__c,
        WOO_WMF_Orders__c.WOO_Agora_Retailer_City__c,
        WOO_WMF_Orders__c.Product_Country__c,
        WOO_WMF_Orders__c.WOO_Agora_Retailer_Zipcode__c,
        WOO_WMF_Orders__c.WOO_Agora_Symptoms__c,
        WOO_WMF_Orders__c.WOO_Agora_Submission_Datetime__c,
        WOO_WMF_Orders__c.WOO_AgoraManufacturingDate__c,
        WOO_WMF_Orders__c.WOO_Case__c,
        WOO_WMF_Orders__c.WOO_Account__c
    };
    public static final List<Schema.SObjectField> ORDER_LINES_FIELDS = new List<Schema.SObjectField>{
        WOO_WMF_Order_Line_Item__c.WOO_WMF_Order__c,
        WOO_WMF_Order_Line_Item__c.WOO_Comment__c,
        WOO_WMF_Order_Line_Item__c.WOO_Name__c,
        WOO_WMF_Order_Line_Item__c.WOO_Requested_quantity__c,
        WOO_WMF_Order_Line_Item__c.WOO_Unitary_price__c,
        WOO_WMF_Order_Line_Item__c.WOO_Reference__c
    };

    public static String fieldsStringForQuery(List<String> fields) {
        return String.join(fields, ', ');
    }
    public static String fieldsStringForQuery(List<Schema.SObjectField> fields) {
        List<String> orderFieldsAsStrings = new List<String>();
        for (Schema.SObjectField orderField : fields) {
            orderFieldsAsStrings.add(orderField.getDescribe().name);
        }
        return fieldsStringForQuery(orderFieldsAsStrings);
    }
    public static WOO_WMF_Orders__c getOrderAndCheckFields(Id orderId) {
        assertEqualsFalse(String.isBlank(orderId), 'OrderId is required for method sendMainOrder');
        WOO_WMF_Orders__c order = Database.query(
            String.escapeSingleQuotes(
                'SELECT ' +
                '    (' +
                '        SELECT ' +
                fieldsStringForQuery(ORDER_FIELDS) +
                ', ' +
                fieldsStringForQuery(ORDER_FIELDS_RELATED_OBJ) +
                '        FROM Subsidiary_Orders__r' +
                '    ),' +
                fieldsStringForQuery(ORDER_FIELDS) +
                ', ' +
                fieldsStringForQuery(ORDER_FIELDS_RELATED_OBJ) +
                ' FROM WOO_WMF_Orders__c' +
                ' WHERE Id = :orderId' +
                ' LIMIT 1'
            )
        );
        assertEqualsFalse(order.WOO_Account__c == null, Label.AgoraOrder_Error_ConsumerRequired);
        assertEqualsFalse(
            String.isBlank(order.WOO_Account__r.LastName) ||
            String.isBlank(order.WOO_Account__r.FirstName),
            Label.AgoraOrder_Error_ConsumerName
        );
        assertEqualsFalse(
            String.isBlank(order.WOO_Account__r.Phone) &&
            String.isBlank(order.WOO_Account__r.PersonOtherPhone),
            Label.AgoraOrder_Error_ConsumerPhone
        );
        assertEqualsFalse(
            String.isBlank(order.WOO_Account__r.Title_2__c) &&
            String.isBlank(order.WOO_Account__r.Salutation),
            Label.AgoraOrder_Error_ConsumerSalutation
        );
        assertEqualsFalse(
            order.WOO_Case__r.Exchange_Agreement_Number__c == null,
            Label.AgoraOrder_Error_CaseExchangeAgreementNumber
        );
        assertEqualsFalse(
            order.WOO_Case__r.Purchase_Date__c == null,
            Label.AgoraOrder_Error_CasePurchaseDate
        );
        assertEqualsFalse(
            String.isBlank(order.WOO_AgoraManufacturingDate__c),
            Label.AgoraOrder_Error_OrderManufacturingDate
        );
        assertEqualsFalse(
            String.isBlank(order.WOO_Agora_Symptoms__c),
            Label.AgoraOrder_Error_OrderSymptom
        );
        assertEqualsFalse(
            String.isBlank(order.WOO_Retailer__c) ||
            String.isBlank(order.WOO_Agora_Retailer_City__c) ||
            String.isBlank(order.WOO_Agora_Retailer_Zipcode__c) ||
            String.isBlank(order.Product_Country__c),
            Label.AgoraOrder_Error_OrderRetailer
        );
        return order;
    }

    private static void assertEqualsFalse(Boolean isThrowing, String message) {
        if (isThrowing) {
            throw new HandledException(message);
        }
    }

    public enum InterventionTypeOptions {
        REPAIR_UNDER_MANUFACTURER_WARRANTY,
        REPAIR_UNDER_WARRANTY_FOLLOWING_WARRANTY_EXTENSION_AGREEMENT,
        PRODUCT_EXCHANGE_UNDER_PRODUCT_WARRANTY_PEM,
        EXCHANGE_OPERATION_WITHOUT_PRODUCT_WARRANTY_PEM_NO_ISG_RETURN_IN_AGORA,
        OUT_OF_WARRANTY_REPAIR_WITH_LABOR_COSTS_COVERED_BY_MANUFACTURER,
        OUT_OF_WARRANTY_REPAIR_WITH_PARTS_COSTS_COVERED_BY_MANUFACTURER,
        OUT_OF_WARRANTY_REPAIR_WITH_NO_COSTS_COVERED_BY_MANUFACTURER,
        OUT_OF_WARRANTY_REPAIR_WITH_ALL_COSTS_COVERED_BY_MANUFACTURER,
        DEVICE_ACTIVATION_OPERATION,
        SUB_CONTRACT
    }

    public static Integer symptomTypeInteger(InterventionTypeOptions option) {
        Map<InterventionTypeOptions, Integer> mapToNumber = new Map<InterventionTypeOptions, Integer>{
            InterventionTypeOptions.SUB_CONTRACT => 100,
            InterventionTypeOptions.REPAIR_UNDER_MANUFACTURER_WARRANTY => 1,
            InterventionTypeOptions.REPAIR_UNDER_WARRANTY_FOLLOWING_WARRANTY_EXTENSION_AGREEMENT => 2,
            InterventionTypeOptions.PRODUCT_EXCHANGE_UNDER_PRODUCT_WARRANTY_PEM => 3,
            InterventionTypeOptions.EXCHANGE_OPERATION_WITHOUT_PRODUCT_WARRANTY_PEM_NO_ISG_RETURN_IN_AGORA => 4,
            InterventionTypeOptions.OUT_OF_WARRANTY_REPAIR_WITH_LABOR_COSTS_COVERED_BY_MANUFACTURER => 5,
            InterventionTypeOptions.OUT_OF_WARRANTY_REPAIR_WITH_PARTS_COSTS_COVERED_BY_MANUFACTURER => 6,
            InterventionTypeOptions.OUT_OF_WARRANTY_REPAIR_WITH_NO_COSTS_COVERED_BY_MANUFACTURER => 7,
            InterventionTypeOptions.OUT_OF_WARRANTY_REPAIR_WITH_ALL_COSTS_COVERED_BY_MANUFACTURER => 8,
            InterventionTypeOptions.DEVICE_ACTIVATION_OPERATION => 9,
            InterventionTypeOptions.SUB_CONTRACT => 10
        };
        return mapToNumber.get(option);
    }

    public static WOO_WS_Agora_Orders.InterventionDTO buildIntervention(
        String symptom,
        String exchangeAgreementNumber
    ) {
        WOO_WS_Agora_Orders.InterventionDTO interventionDef = new WOO_WS_Agora_Orders.InterventionDTO();
        interventionDef.InterventionType = WOO_freeOrderAgoraFormSendRepairUtil.symptomTypeInteger(
            InterventionTypeOptions.REPAIR_UNDER_MANUFACTURER_WARRANTY
        );
        interventionDef.RepairOriginCode = 'CONSUMER';
        interventionDef.ReplaceRef = exchangeAgreementNumber;
        WOO_Agora_InterventionIrisMapping__mdt matchingMapping = CustomMetadataCache.getAgoraIrisMappingByDeveloperName()
            .get(symptom);
        if (matchingMapping == null) {
            throw new HandledException(
                'Symptom "' +
                symptom +
                '" not found in the cache. It should be configured by an administrator.'
            );
        }
        interventionDef.IRISSymptom = matchingMapping.Iris_Symptom__c;
        interventionDef.IRISSection = matchingMapping.Iris_Section__c;
        interventionDef.IRISDefault = matchingMapping.Iris_Default__c;
        interventionDef.IRISRepair = matchingMapping.Iris_Repair__c;
        return interventionDef;
    }

    public static Integer mapTitleField(String title) {
        Integer mrs = 1;
        Integer ms = 2;
        Integer mr = 3;
        Integer company = 4;
        Map<String, Integer> mapping = new Map<String, Integer>{
            // Salutation
            'Mr' => mr,
            'Ms' => mrs,
            // Title_2__c
            'Ms' => mrs,
            'Prof.' => mr,
            'Dr' => mr,
            'Miss' => ms,
            'Father' => mr,
            'Lady' => mrs,
            'Lord' => mr,
            'Madam' => mrs,
            'Major' => mr,
            'Master' => mr,
            'Rev' => mr,
            'Sir' => mr,
            'Sister' => mrs,
            'Professor' => mr,
            'Doktor' => mr,
            'Magister' => mr,
            'Firma' => company
        };
        if (mapping.get(title) == null) {
            return mr;
        }
        return mapping.get(title);
    }

    public static WOO_WS_Agora_Orders.ConsumerDTO fillConsumerDTO(
        WOO_freeOrderAgoraFrontEndDTO.Address address,
        Account consumer
    ) {
        WOO_WS_Agora_Orders.ConsumerDTO consDTO = new WOO_WS_Agora_Orders.ConsumerDTO();

        consDTO.Title = WOO_freeOrderAgoraFormSendRepairUtil.mapTitleField(consumer.Title_2__c);
        if (String.isNotBlank(consumer.Salutation)) {
            consDTO.Title = WOO_freeOrderAgoraFormSendRepairUtil.mapTitleField(consumer.Salutation);
        }

        consDTO.LastName = consumer.LastName;
        consDTO.FirstName = consumer.FirstName;
        if (String.isNotBlank(consumer.Phone)) {
            consDTO.Phone = consumer.Phone;
        } else {
            consDTO.Phone = consumer.PersonOtherPhone;
        }
        if (String.isNotBlank(consumer.PersonMobilePhone)) {
            consDTO.SMSCode = consumer.PersonMobilePhone;
        }
        consDTO.Town = address.city;
        consDTO.Country = Integer.valueOf(
            WOO_WS_Agora_Orders.mapAlpha2ToNumberCountryISO(address.country)
        );
        consDTO.Zip = address.postalCode;
        consDTO.Address1 = address.street;
        return consDTO;
    }

    public static WOO_WS_Agora_Orders.AddressDTO buildResetailer(WOO_WMF_Orders__c order) {
        WOO_WS_Agora_Orders.AddressDTO reseller = new WOO_WS_Agora_Orders.AddressDTO();
        reseller.Name = order.WOO_Retailer__c;
        reseller.Town = order.WOO_Agora_Retailer_City__c;
        reseller.Country = Integer.valueOf(
            WOO_WS_Agora_Orders.mapAlpha2ToNumberCountryISO(order.Product_Country__c)
        );
        reseller.Zip = order.WOO_Agora_Retailer_Zipcode__c;
        return reseller;
    }

    public static WOO_WS_Agora_Orders.DeliveryAddressDTO fillDeliveryAddress(
        WOO_freeOrderAgoraFrontEndDTO.Address address,
        Account consumer
    ) {
        WOO_WS_Agora_Orders.DeliveryAddressDTO addressDTO = new WOO_WS_Agora_Orders.DeliveryAddressDTO();
        addressDTO.DeliveryMode = 1;
        addressDTO.DeliveryCode = 'Consumer address';
        addressDTO.LastName = consumer.LastName;
        if (String.isNotBlank(consumer.Phone)) {
            addressDTO.Phone = consumer.Phone;
        } else {
            addressDTO.Phone = consumer.PersonOtherPhone;
        }
        addressDTO.Town = address.city;
        addressDTO.Country = Integer.valueOf(
            WOO_WS_Agora_Orders.mapAlpha2ToNumberCountryISO(address.country)
        );
        addressDTO.Zip = address.postalCode;
        addressDTO.Address1 = address.street;
        return addressDTO;
    }

    public static String getAgoraLanguage() {
        Map<String, String> sfToAgoraMapping = new Map<String, String>{
            'ru_UA' => 'русский', // Russian (Ukraine)
            'ru_MD' => 'русский', // Russian (Moldova)
            'ru_BY' => 'русский', // Russian (Belarus)
            'ru_KG' => 'русский', // Russian (Kyrgyzstan)
            'ru_KZ' => 'русский', // Russian (Kazakhstan)
            'ru_AM' => 'русский', // Russian (Armenia)
            'ru_PL' => 'русский', // Russian (Poland)
            'ru_LT' => 'русский', // Russian (Lithuania)
            'zh_MY' => '', // Chinese (Malaysia)
            'haw' => '', // Hawaiian
            'sm' => '', // Samoan
            'ht' => '', // Haitian Creole
            'kk' => '', // Kazakh
            'am' => '', // Amharic
            'km' => '', // Khmer
            'fa' => '', // Farsi
            'my' => '', // Burmese
            'mi' => '', // Te reo
            'en_NZ' => 'English', // English (New Zealand)
            'gu' => '', // Gujarati
            'mr' => '', // Marathi
            'kn' => '', // Kannada
            'ml' => '', // Malayalam
            'te' => '', // Telugu
            'xh' => '', // Xhosa
            'zu' => '', // Zulu
            'sw' => '', // Swahili
            'af' => '', // Afrikaans
            'ca' => '', // Catalan
            'es_VE' => 'Español', // Spanish (Venezuela)
            'es_UY' => 'Español', // Spanish (Uruguay)
            'es_US' => 'Español', // Spanish (United States)
            'es_PR' => 'Español', // Spanish (Puerto Rico)
            'es_PE' => 'Español', // Spanish (Peru)
            'es_PY' => 'Español', // Spanish (Paraguay)
            'es_PA' => 'Español', // Spanish (Panama)
            'es_NI' => 'Español', // Spanish (Nicaragua)
            'es_HN' => 'Español', // Spanish (Honduras)
            'es_GT' => 'Español', // Spanish (Guatemala)
            'es_SV' => 'Español', // Spanish (El Salvador)
            'es_EC' => 'Español', // Spanish (Ecuador)
            'es_DO' => 'Español', // Spanish (Dominican Republic)
            'es_CR' => 'Español', // Spanish (Costa Rica)
            'es_CO' => 'Español', // Spanish (Colombia)
            'es_CL' => 'Español', // Spanish (Chile)
            'es_BO' => 'Español', // Spanish (Bolivia)
            'es_AR' => 'Español', // Spanish (Argentina)
            'nl_BE' => 'Nederlands', // Dutch (Belgium)
            'it_CH' => 'Italiano', // Italian (Switzerland)
            'de_LU' => 'Deutsch', // German (Luxembourg)
            'de_BE' => 'Deutsch', // German (Belgium)
            'fr_CH' => 'Français', // French (Switzerland)
            'fr_LU' => 'Français', // French (Luxembourg)
            'fr_BE' => 'Français', // French (Belgium)
            'en_ZA' => 'English', // English (South Africa)
            'en_SG' => 'English', // English (Singapore)
            'en_IE' => 'English', // English (Ireland)
            'en_HK' => 'English', // English (Hong Kong)
            'zh_HK' => '', // Chinese (Hong Kong)
            'zh_SG' => '', // Chinese (Singapore)
            'ar_YE' => '', // Arabic (Yemen)
            'ar_AE' => '', // Arabic (United Arab Emirates)
            'ar_TN' => '', // Arabic (Tunisia)
            'ar_SY' => '', // Arabic (Syria)
            'ar_SD' => '', // Arabic (Sudan)
            'ar_SA' => '', // Arabic (Saudi Arabia)
            'ar_QA' => '', // Arabic (Qatar)
            'ar_OM' => '', // Arabic (Oman)
            'ar_MA' => '', // Arabic (Morocco)
            'ar_LY' => '', // Arabic (Libya)
            'ar_LB' => '', // Arabic (Lebanon)
            'ar_KW' => '', // Arabic (Kuwait)
            'ar_JO' => '', // Arabic (Jordan)
            'ar_IQ' => '', // Arabic (Iraq)
            'ar_EG' => '', // Arabic (Egypt)
            'ar_BH' => '', // Arabic (Bahrain)
            'ar_DZ' => '', // Arabic (Algeria)
            'ta' => '', // Tamil
            'de_CH' => 'Deutsch', // German (Switzerland)
            'de_AT' => 'Deutsch', // German (Austria)
            'bn' => '', // Bengali
            'ur' => '', // Urdu
            'hi' => '', // Hindi
            'hy' => '', // Armenian
            'rm' => '', // Romansh
            'lb' => '', // Luxembourgish
            'tl' => '', // Tagalog
            'ms' => '', // Malay
            'is' => '', // Icelandic
            'cy' => '', // Welsh
            'eu' => '', // Basque
            'ga' => '', // Irish
            'mt' => '', // Maltese
            'sh_ME' => '', // Montenegrin
            'sq' => '', // Albanian
            'et' => 'Eesti', // Estonian
            'lt' => 'Lietuva', // Lithuanian
            'lv' => 'Latvija', // Latvian
            'mk' => '', // Macedonian
            'bs' => '', // Bosnian
            'ro_MD' => 'Română', // Romanian (Moldova)
            'en_CA' => 'English', // English (Canadian)
            'en_PH' => 'English', // English (Phillipines)
            'en_IN' => 'English', // English (Indian)
            'en_MY' => 'English', // English (Malaysian)
            'en_AU' => 'English', // English (Australian)
            'sh' => '', // Serbian (Latin)
            'sr' => '', // Serbian (Cyrillic)
            'ka' => '', // Georgian
            'fr_CA' => 'Français', // French (Canadian)
            'sl' => 'Slovenščina', // Slovene
            'hr' => 'Hrvatski', // Croatian
            'pt_PT' => 'Português', // Portuguese (European)
            'sk' => 'Slovenský', // Slovak
            'ar' => '', // Arabic
            'en_GB' => 'English', // English (UK)
            'bg' => 'български', // Bulgarian
            'el' => '', // Greek
            'iw' => '', // Hebrew
            'uk' => '', // Ukrainian
            'vi' => '', // Vietnamese
            'ro' => 'Română', // Romanian
            'in' => '', // Indonesian
            'tr' => '', // Turkish
            'cs' => 'český', // Czech
            'pl' => 'Polski', // Polish
            'hu' => 'Magyar', // Hungarian
            'no' => '', // Norwegian
            'es_MX' => 'Español', // Spanish (Mexico)
            'ru' => '', // Russian
            'fi' => '', // Finnish
            'th' => '', // Thai
            'da' => '', // Danish
            'nl_NL' => 'Nederlands', // Dutch
            'pt_BR' => 'Português', // Portuguese (Brazil)
            'zh_CN' => '', // Chinese (Simplified)
            'zh_TW' => '', // Chinese (Traditional)
            'ko' => '', // Korean
            'sv' => '', // Swedish
            'ja' => '', // Japanese
            'it' => 'Italiano', // Italian
            'fr' => 'Français', // French
            'es' => 'Español', // Spanish
            'de' => 'Deutsch', // German
            'en_US' => '' // English
        };
        String sfLanguage = UserInfo.getLanguage();
        if (String.isBlank(sfToAgoraMapping.get(sfLanguage))) {
            return 'English';
        }
        return sfToAgoraMapping.get(sfLanguage);
    }
    public static List<WOO_WMF_Order_Line_Item__c> generateOrderLines(
        List<WOO_freeOrderAgoraFrontEndDTO.TableRow> rows,
        Id orderId
    ) {
        //gboTODO ne pas supprimer pour garder comment
        delete [SELECT Id FROM WOO_WMF_Order_Line_Item__c WHERE WOO_WMF_Order__c = :orderId];
        List<WOO_WMF_Order_Line_Item__c> orderLines = new List<WOO_WMF_Order_Line_Item__c>();
        for (WOO_freeOrderAgoraFrontEndDTO.TableRow line : rows) {
            if (line.type == 'PROD') {
                continue;
            }
            orderLines.add(
                new WOO_WMF_Order_Line_Item__c(
                    WOO_WMF_Order__c = orderId,
                    WOO_Comment__c = line.name,
                    WOO_Name__c = line.name,
                    WOO_Requested_quantity__c = line.quantitySelected,
                    WOO_Unitary_price__c = line.pru,
                    WOO_Reference__c = line.reference
                )
            );
        }
        return orderLines;
    }
}