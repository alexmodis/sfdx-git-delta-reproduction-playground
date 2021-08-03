@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class WOO_WS_Agora_Orders implements InterfaceDef {
    private ApiAgoraOrder__mdt apiParams;
    private Http http;

    public static final Integer MANUFACTURER_ID = 15;
    public static final String ROOT_URL = 'callout:Agora_Free_Order';

    public class OrderAlreadyExistsException extends Exception {
    }

    public interface InterfaceDef {
        // All other functionality excluded
        List<WOO_WS_Agora_Orders.ProductDTO> getProducts(String ref, String countryCode);
        List<WOO_WS_Agora_Orders.PartDTO> getBomList(String agoraKey);
        WOO_WS_Agora_Orders.CreateRepairResponseData createRepair(
            WOO_WS_Agora_Orders.CompleteRepairDTO createRepair,
            String language
        );
        WOO_WS_Agora_Orders.UpdateRepairResponseData updateRepair(
            WOO_WS_Agora_Orders.CompleteRepairStateDTO updateRepair,
            String language
        );
        InterfaceDef loadApiKey(String cccGroup);
    }

    public WOO_WS_Agora_Orders() {
        this.http = new Http();
    }
    public WOO_WS_Agora_Orders loadApiKey(String cccGroup) {
        if (Test.isRunningTest()) {
            this.apiParams = new ApiAgoraOrder__mdt(
                Api_Key__c = 'Api_Key__c',
                CCC_Group__c = 'FRANCE'
            );
            return this;
        }
        try {
            this.apiParams = [
                SELECT Api_Key__c
                FROM ApiAgoraOrder__mdt
                WHERE CCC_Group__c = :cccGroup
                LIMIT 1
            ];
        } catch (Exception error) {
            throw new AuraHandledException(
                String.format(
                    'An administrator should configure FreeOrder for CCC Group {0}.',
                    new List<String>{ cccGroup }
                )
            );
        }
        return this;
    }

    public List<WOO_WS_Agora_Orders.ProductDTO> getProducts(String ref, String countryCode) {
        if (String.isBlank(ref) || String.isBlank(countryCode)) {
            throw new HandledException('Input parameters are incorrect.');
        }
        HttpRequest request = new HttpRequest();
        request.setTimeout(30000);
        request.setEndpoint(
            String.format(
                '{0}/product/searchproductbyref?manufacturerid={1}&keyword={2}&countrycode={3}',
                new List<String>{
                    ROOT_URL,
                    String.valueOf(MANUFACTURER_ID),
                    ref,
                    mapAlpha2ToNumberCountryISO(countryCode)
                }
            )
        );
        request.setMethod('GET');
        request.setHeader('api_key', this.apiParams.Api_Key__c);
        System.Debug('getProducts request: ' + request);
        HttpResponse response = this.http.send(request);
        System.Debug('getProducts response Status: ' + response.getStatusCode());
        System.Debug('getProducts response Body: ' + response.getBody());
        throwIfWSError(response);

        SearchProductResponse responseProducts = (SearchProductResponse) JSON.deserialize(
            response.getBody(),
            SearchProductResponse.class
        );
        return responseProducts.ResponseData;
    }

    public List<WOO_WS_Agora_Orders.PartDTO> getBomList(String agoraKey) {
        if (String.isBlank(agoraKey)) {
            throw new HandledException('Input parameter agoraKey is incorrect.');
        }
        HttpRequest request = new HttpRequest();
        request.setTimeout(30000);
        request.setEndpoint(
            String.format(
                '{0}/product/printbomdata?AGORAProductKey={1}',
                new List<String>{ ROOT_URL, EncodingUtil.urlEncode(agoraKey, 'UTF-8') }
            )
        );
        request.setMethod('GET');
        request.setHeader('api_key', this.apiParams.Api_Key__c);
        System.Debug('getBomList request: ' + request);
        HttpResponse response = this.http.send(request);
        System.Debug('getBomList response Status: ' + response.getStatusCode());
        System.Debug('getBomList response Body: ' + response.getBody());
        throwIfWSError(response);

        BomListResponse responseBomList = (BomListResponse) JSON.deserialize(
            response.getBody(),
            BomListResponse.class
        );
        return responseBomList.ResponseData;
    }

    public WOO_WS_Agora_Orders.CreateRepairResponseData createRepair(
        CompleteRepairDTO createRepair,
        String language
    ) {
        createRepair.hasRequiredFieldMissing();
        HttpRequest request = new HttpRequest();
        if (language == null) {
            language = 'English';
        }
        request.setTimeout(30000);
        request.setEndpoint(
            String.format(
                '{0}/repair/createrepair?language={1}',
                new List<String>{ ROOT_URL, language }
            )
        );
        request.setMethod('POST');
        request.setHeader('api_key', this.apiParams.Api_Key__c);
        request.setHeader('Content-Type', 'application/json');
        request.setBody(JSON.serialize(createRepair));
        System.Debug('createRepair request: ' + request);
        System.Debug('createRepair request.getBody(): ' + request.getBody());
        System.Debug(
            'createRepair request.getBody() Pretty: ' + JSON.serializePretty(createRepair)
        );
        HttpResponse response = this.http.send(request);
        System.Debug('createRepair response Status: ' + response.getStatusCode());
        System.Debug('createRepair response Body: ' + response.getBody());
        if (response.getStatusCode() == 500 && response.getBody().contains('SO:')) {
            // "ResponseErrorMessage":"A service order already exists for SO:FOC00001"
            throw new OrderAlreadyExistsException();
        }
        throwIfWSError(response);

        CreateRepairResponse responseCreateRepair = (CreateRepairResponse) JSON.deserialize(
            response.getBody(),
            CreateRepairResponse.class
        );
        return responseCreateRepair.ResponseData;
    }

    public WOO_WS_Agora_Orders.UpdateRepairResponseData updateRepair(
        CompleteRepairStateDTO updateRepair,
        String language
    ) {
        updateRepair.hasRequiredFieldMissing();
        HttpRequest request = new HttpRequest();
        if (language == null) {
            language = 'English';
        }
        request.setTimeout(30000);
        request.setEndpoint(
            String.format(
                '{0}/repair/updaterepair?language={1}',
                new List<String>{ ROOT_URL, language }
            )
        );
        request.setMethod('POST');
        request.setHeader('api_key', this.apiParams.Api_Key__c);
        request.setHeader('Content-Type', 'application/json');
        request.setBody(JSON.serialize(updateRepair));
        System.Debug('UpdateRepair request: ' + request);
        System.Debug('UpdateRepair request.getBody(): ' + request.getBody());
        System.Debug(
            'UpdateRepair request.getBody() Pretty: ' + JSON.serializePretty(updateRepair)
        );
        HttpResponse response = this.http.send(request);
        System.Debug('UpdateRepair response Status: ' + response.getStatusCode());
        System.Debug('UpdateRepair response Body: ' + response.getBody());
        throwIfWSError(response);

        UpdateRepairResponse responseUpdateRepair = (UpdateRepairResponse) JSON.deserialize(
            response.getBody(),
            UpdateRepairResponse.class
        );
        return responseUpdateRepair.ResponseData;
    }

    /* -------------------------------------------------------------------------- */
    /*                              Api JSON Wrappers                             */
    /* -------------------------------------------------------------------------- */

    @SuppressWarnings('PMD')
    public virtual class AgoraResponse {
        public String ResponseStatus; // ("S" : Sucess, "E": Error, "W":Warning)
        public Boolean IsValid;
        public String ResponseMessage;
        public String ResponseErrorMessage;
    }

    @SuppressWarnings('PMD')
    public class AgoraError extends AgoraResponse {
        public Map<String, Object> ResponseData;
    }
    @SuppressWarnings('PMD')
    public class SearchProductResponse extends AgoraResponse {
        public List<ProductDTO> ResponseData;
    }

    @SuppressWarnings('PMD')
    public class ProductDTO {
        public Integer ManufacturerId;
        public String BrandLabel;
        public String Description;
        public String Refcom;
        public String Reftech;
        public String AGORAProductKey;
    }

    @SuppressWarnings('PMD')
    public class BomListResponse extends AgoraResponse {
        public List<PartDTO> ResponseData;
    }

    @SuppressWarnings('PMD')
    public class PartDTO {
        public String PartRef; // Part reference
        public String Description; // Part description
        public Double Quantity; // Quantity of part on the device
        public Double PublicPrice; // Public Price
        public Double DiscountPrice; // Discount Price
        public Boolean Availability; // Availability
        public String AvailabilityDate; // Availability Date
        public String Status; // Status
        public String DeliveryDelay; // DeliveryDelay
        public String ReplacedBy; // ReplacedBy
    }

    public virtual class RequiredFieldsDTO {
        public List<String> requiredFields = new List<String>();

        public virtual Boolean hasRequiredFieldMissing() {
            Map<String, Object> obj = (Map<String, Object>) JSON.deserializeUntyped(
                JSON.serialize(this)
            );
            for (String field : this.requiredFields) {
                if (obj.get(field) == null) {
                    throw new HandledException('Missing field ' + field);
                }
            }
            return false;
        }
    }

    @SuppressWarnings('PMD')
    public class CompleteRepairStateDTO extends CompleteRepairDTO {
        public StateNatureDTO StateNatures; // Repair file status (see state nature list)
        public String StatusCode; // Specific state of the repair Put value "CLOSED" (to close the repair whitout warranty claim)
    }

    @SuppressWarnings('PMD')
    public virtual class CompleteRepairDTO extends RequiredFieldsDTO {
        public CompleteRepairDTO() {
            this.requiredFields = new List<String>{
                'CallDate',
                'CommercialRef',
                'Consumer',
                'Intervention',
                'ManufacturerId',
                'ManufacturingCode',
                'MissionOrder',
                'Reseller',
                'TimeZoneId'
            };
        }

        public override Boolean hasRequiredFieldMissing() {
            return super.hasRequiredFieldMissing() |
                this.Consumer.hasRequiredFieldMissing() |
                this.Intervention.hasRequiredFieldMissing() |
                this.Reseller.hasRequiredFieldMissing();
            //Parts
        }
        public DateTime ActivationDate; // Aftersales repair file creationdate (UTC Format if timeZoneId is specified)
        public String Brand; // Product brand
        public DateTime CallDate; // (REQUIRED) Consumer call date or counter deposit date (UTC Format if timeZoneId is specified)
        public String ClientNumber; // (REQUIRED) Manufacturer client code of the service partner
        public String CommercialRef; // (REQUIRED) Product commercial reference
        public ConsumerDTO Consumer; // (REQUIRED) Consumer info object
        public String ConsumerContract; // Consumer warranty contract number
        public DeliveryAddressDTO DeliveryAddress; // Delivery adress info object
        public String Family; // Product family (e.g. Coffee machine)
        public String GCPlusContract; // Indicates if the warranty extension is a GCPlus contract
        public InterventionDTO Intervention; // (REQUIRED) Intervention info object
        public String ManufacturingCode; // (REQUIRED) Manufacturing date (4 digits): 2 digits week number[1-53] + 2 digits year
        public Integer ManufacturerId; // (REQUIRED) AGORA Manufacturer identifier
        public String MissionOrder {
            get;
            set {
                MissionOrder = value?.left(20);
            }
        } // (REQUIRED) The aftersales repair file number, (20 char max)
        public String OutOfWarAgreementNumber; // Out of warranty agreement number provided by the manufacturer
        public List<CreateRepairPartDTO> Parts; // List of spareparts needed for the repair
        public DateTime PurchaseDate; // Product purchase date (UTC Format if timeZoneId is specified)
        public AddressDTO Reseller; // (REQUIRED) Reseller info object
        public String SerialNumber; // Product serial number
        public String TechnicalRef; // Product technical reference
        public String TimeZoneId; // (REQUIRED) The timezone of the service partner. Needed to convert UTC dates to local date. Keep empty if no conversion are needed.
        public String UserCode; // Agora UserCode of service station
    }
    @SuppressWarnings('PMD')
    public virtual class ValidationError {
        public String Field; // Field assotiated to the error
        public String ErrorMessage; // Error message
        public String MessageType; // Type of the error message : (E : Error, W : Warning)
    }
    @SuppressWarnings('PMD')
    public virtual class SendRepairResponseData {
        public String RepairId; // Repair id
        public List<ValidationError> ValidationErrors; // Validation errors
        public String ErrorMessage; // Error message
    }
    @SuppressWarnings('PMD')
    public class CreateRepairResponseData extends SendRepairResponseData {
        public Integer MandateId; // Associated mandate id of repair
        public Boolean IsValid; // Validity
    }
    @SuppressWarnings('PMD')
    public class CreateRepairResponse extends AgoraResponse {
        CreateRepairResponseData ResponseData;
    }

    @SuppressWarnings('PMD')
    public class UpdateRepairResponseData extends SendRepairResponseData {
        public Integer ManufacturerId; // Manufacturer id
        public String MissionOrderNumber; // Mission order number
        public List<String> UnknowParts; // List of unknow parts
        public String Status; // Status
        public String ErrorCode; // Error code (Informations about the method)
        public Boolean IsRepairFileValid; // Validity of repair file
    }
    @SuppressWarnings('PMD')
    public class UpdateRepairResponse extends AgoraResponse {
        UpdateRepairResponseData ResponseData;
    }

    @SuppressWarnings('PMD')
    public class ConsumerDTO extends RequiredFieldsDTO {
        public ConsumerDTO() {
            this.requiredFields = new List<String>{
                'Title',
                'LastName',
                'FirstName',
                'Address1',
                'Zip',
                'Town',
                'Country',
                'Phone'
            };
        }
        public Integer ConsumerId; // Consumer ID
        public Integer ConsumerInvoice; // Flag indication if the repair should be invoiced to the consumer 0 : no / 1: Yes
        public Integer Title; // (REQUIRED) Consumer Title 1 : Mrs. ; 2 : Ms. ; 3 : Mr. ; 4 : Company
        public String LastName; // (REQUIRED) Consumer last name
        public String FirstName; // (REQUIRED) Consumer first name
        public String Address1; // (REQUIRED) Consumer address 1
        public String Address2; // Consumer address 2
        public String Address3; // Consumer address 3
        public String Zip; // (REQUIRED) Consumer zip code
        public String Town; // (REQUIRED) Consumer town
        public String State; // Consumer state (Mainly used for United States)
        public Integer Country; // (REQUIRED) Consumer country (ISO 3 digits)
        public String Phone; // (REQUIRED) Consumer Phone number
        public String PhoneType; // Information concerning the phone (e.g. phone of Madame)
        public String SMSCode; // Phone number with SMS capabilities (mobile)
        public String ProPhone; // Business phone number
        public String Email; // Email of the consumer
        public String Remarks; // Remark given by the consumer
    }
    @SuppressWarnings('PMD')
    public class InterventionDTO extends RequiredFieldsDTO {
        public InterventionDTO() {
            this.requiredFields = new List<String>{ 'InterventionType', 'RepairOriginCode' };
        }
        public Integer InterventionType; // (REQUIRED)
        // Type of intervention:
        // 1 => Repair under manufacturer warranty
        // 2 => Repair under warranty following warranty extension agreement
        // 3 => Product Exchange under product warranty(PEM)
        // 4 => Exchange operation without product warranty(PEM) (No ISG return in AGORA)
        // 5 => Out of warranty repair with labor costs covered by manufacturer
        // 6 => Out of warranty repair with parts costs covered by manufacturer
        // 7 => Out of warranty repair with no costs covered by manufacturer
        // 8 => Out of warranty repair, with all costs covered by manufacturer
        // 9 => Device activation operation
        // 100 => Sub contract
        public String RepairOriginCode; // (Required) Repair origin code. Possible values: "CONSUMER" or "RESELLER"
        public String FailureDescription; // Failure description
        public Integer IRISCondition; // IRIS Condition
        public String IRISConditionEX; // IRIS Condition EX
        public String IRISSymptom; // IRIS Symptom
        public String IRISSection; // IRIS Section
        public String IRISDefault; // IRIS Default code.
        public String IRISRepair; // IRIS Repair Code //'Z7' = "exchange" = ReplaceRef required
        public String DefaultCode; // Default code (NON-IRIS).
        public String ReplaceRef; // Product replace reference
        public String FIdent; // Failure spare part reference ,
        public DateTime InterventionStartDate; // Repair start date (UTC Format if timeZoneId is specified) ,
        public DateTime InterventionEndDate; // Repair end date (UTC Format if timeZoneId is specified) ,
        public DateTime ProductReturnDate; // Date of return of the device (UTC Format if timeZoneId is specified)
    }
    @SuppressWarnings('PMD')
    public class CreateRepairPartDTO extends RequiredFieldsDTO {
        public String Note; // Comment.
        public String OrderNumber; // Spare part order number.
        public Integer Quantity; // Quantity ordered.
        public String Reference; // Spare part reference.
        public Boolean ToBeOrdered; // To be ordered?
    }
    @SuppressWarnings('PMD')
    public class AddressDTO extends RequiredFieldsDTO {
        public Integer Country; // Reseller country (ISO 3 digits)
        public String State; // Reseller state (Mainly used for United States)
        public String Name; // Reseller name
        public String Town; // Reseller town
        public String Zip; // Reseller zip code
        public String Address1; // Reseller address 1
        public String Address2; // Reseller address 2
        public String Address3; // Reseller address 3
        public String Email; // Reseller email
        public String Phone; // Reseller phone number
    }

    @SuppressWarnings('PMD')
    public class DeliveryAddressDTO extends RequiredFieldsDTO {
        public Integer DeliveryMode; // 1:CONSUMER - 2:WOR - 3:WOS - 4: STANDARD ,
        public String DeliveryCode; // Customer delivery code ,
        public String CompanyName; // Company name ,
        public String LastName; // Consumer last name ,
        public String Address1; // Consumer address 1 ,
        public String Address2; // Consumer address 2 ,
        public String Address3; // Consumer address 3 ,
        public String Zip; // Consumer zip code ,
        public String Town; // Consumer town ,
        public String State; // Consumer state (Mainly used for United States) ,
        public Integer Country; // Consumer country (ISO 3 digits) ,
        public String Phone; // Consumer phone number ,
        public String Email; // Consumer email
    }

    @SuppressWarnings('PMD')
    public class StateNatureDTO extends RequiredFieldsDTO {
        public String Code; // Status code. For Delonghi
        // 100 - Claim open,
        // 405 - Product received,
        // 406 - Inspection(to be created);
        // 205 - Parts ordered;
        // 201 - Parts arrived;
        // 601 - Closed;
        // 602 - Delivered(to be created);
        public String Comment; // Comment
        public Integer AppointmentNumber; // Row of the appointment (1st appointment, 2nd appointment…)
        public String AppointmentDate; // Start date of the appointment (UTC Format if timeZoneId is specified in associated word order)
        public String AppointmentEndDate; // End date of the appointment (UTC Format if timeZoneId is specified in associated word order)
        public List<PartDTO> Parts; // Spare parts concerned by the status code (e.g code 200,201,202,204, 205)
    }
    /* -------------------------------------------------------------------------- */
    /*                                    Utils                                   */
    /* -------------------------------------------------------------------------- */
    @TestVisible
    private static void throwIfWSError(HttpResponse response) {
        if (
            response.getStatusCode() / 100 != 2 /*2xx*/ &&
            !response.getBody().contains('ResponseMessage')
        ) {
            System.debug(LoggingLevel.Error, 'Error Body: ' + response.getBody());
            throw new AuraHandledException('Error server when fetching informations from Agora.');
        }
        AgoraResponse responseAgora = (AgoraResponse) JSON.deserialize(
            response.getBody(),
            AgoraResponse.class
        );
        if (!responseAgora.IsValid || responseAgora.ResponseStatus == 'E') {
            throw new AuraHandledException('Error WS Agora: ' + responseAgora.ResponseErrorMessage);
        }
        if (responseAgora.ResponseStatus == 'W') {
            System.debug(LoggingLevel.WARN, 'Agora Api Warning: ');
            System.debug(LoggingLevel.WARN, '   Warning IsValid: ' + responseAgora.IsValid);
            System.debug(
                LoggingLevel.WARN,
                '   Warning ResponseMessage: ' + responseAgora.ResponseMessage
            );
            System.debug(
                LoggingLevel.WARN,
                '   Warning ResponseErrorMessage: ' + responseAgora.ResponseErrorMessage
            );
        }
    }
    @TestVisible
    public static String mapAlpha2ToNumberCountryISO(String countryIsoAlpha2) {
        if (countryIsoAlpha2 == 'IRX') {
            throw new HandledException(
                countryIsoAlpha2 +
                ' is available in the country global value set but has no matches in the iso standard and no records had that value in the product2 table.'
            );
        }
        if (countryIsoAlpha2 == 'WM') {
            countryIsoAlpha2 = 'DE';
        }
        if (String.isBlank(countryIsoAlpha2)) {
            throw new HandledException(
                'method mapAlpha2ToNumberCountryISO needs a string in input.'
            );
        }
        Map<String, String> mapAlpha2ToNumberCountryISO = new Map<String, String>{
            'AD' => '020',
            'AE' => '784',
            'AF' => '004',
            'AG' => '028',
            'AI' => '660',
            'AL' => '008',
            'AM' => '051',
            'AO' => '024',
            'AQ' => '010',
            'AR' => '032',
            'AS' => '016',
            'AT' => '040',
            'AU' => '036',
            'AW' => '533',
            'AX' => '248',
            'AZ' => '031',
            'BA' => '070',
            'BB' => '052',
            'BD' => '050',
            'BE' => '056',
            'BF' => '854',
            'BG' => '100',
            'BH' => '048',
            'BI' => '108',
            'BJ' => '204',
            'BL' => '652',
            'BM' => '060',
            'BN' => '096',
            'BO' => '068',
            'BQ' => '535',
            'BR' => '076',
            'BS' => '044',
            'BT' => '064',
            'BV' => '074',
            'BW' => '072',
            'BY' => '112',
            'BZ' => '084',
            'CA' => '124',
            'CC' => '166',
            'CD' => '180',
            'CF' => '140',
            'CG' => '178',
            'CH' => '756',
            'CI' => '384',
            'CK' => '184',
            'CL' => '152',
            'CM' => '120',
            'CN' => '156',
            'CO' => '170',
            'CR' => '188',
            'CU' => '192',
            'CV' => '132',
            'CW' => '531',
            'CX' => '162',
            'CY' => '196',
            'CZ' => '203',
            'DE' => '276',
            'DJ' => '262',
            'DK' => '208',
            'DM' => '212',
            'DO' => '214',
            'DZ' => '012',
            'EC' => '218',
            'EE' => '233',
            'EG' => '818',
            'EH' => '732',
            'ER' => '232',
            'ES' => '724',
            'ET' => '231',
            'FI' => '246',
            'FJ' => '242',
            'FK' => '238',
            'FM' => '583',
            'FO' => '234',
            'FR' => '250',
            'GA' => '266',
            'GB' => '826',
            'GD' => '308',
            'GE' => '268',
            'GF' => '254',
            'GG' => '831',
            'GH' => '288',
            'GI' => '292',
            'GL' => '304',
            'GM' => '270',
            'GN' => '324',
            'GP' => '312',
            'GQ' => '226',
            'GR' => '300',
            'GS' => '239',
            'GT' => '320',
            'GU' => '316',
            'GW' => '624',
            'GY' => '328',
            'HK' => '344',
            'HM' => '334',
            'HN' => '340',
            'HR' => '191',
            'HT' => '332',
            'HU' => '348',
            'ID' => '360',
            'IE' => '372',
            'IL' => '376',
            'IM' => '833',
            'IN' => '356',
            'IO' => '086',
            'IQ' => '368',
            'IR' => '364',
            'IS' => '352',
            'IT' => '380',
            'JE' => '832',
            'JM' => '388',
            'JO' => '400',
            'JP' => '392',
            'KE' => '404',
            'KG' => '417',
            'KH' => '116',
            'KI' => '296',
            'KM' => '174',
            'KN' => '659',
            'KP' => '408',
            'KR' => '410',
            'KW' => '414',
            'KY' => '136',
            'KZ' => '398',
            'LA' => '418',
            'LB' => '422',
            'LC' => '662',
            'LI' => '438',
            'LK' => '144',
            'LR' => '430',
            'LS' => '426',
            'LT' => '440',
            'LU' => '442',
            'LV' => '428',
            'LY' => '434',
            'MA' => '504',
            'MC' => '492',
            'MD' => '498',
            'ME' => '499',
            'MF' => '663',
            'MG' => '450',
            'MH' => '584',
            'MK' => '807',
            'ML' => '466',
            'MM' => '104',
            'MN' => '496',
            'MO' => '446',
            'MP' => '580',
            'MQ' => '474',
            'MR' => '478',
            'MS' => '500',
            'MT' => '470',
            'MU' => '480',
            'MV' => '462',
            'MW' => '454',
            'MX' => '484',
            'MY' => '458',
            'MZ' => '508',
            'NA' => '516',
            'NC' => '540',
            'NE' => '562',
            'NF' => '574',
            'NG' => '566',
            'NI' => '558',
            'NL' => '528',
            'NO' => '578',
            'NP' => '524',
            'NR' => '520',
            'NU' => '570',
            'NZ' => '554',
            'OM' => '512',
            'PA' => '591',
            'PE' => '604',
            'PF' => '258',
            'PG' => '598',
            'PH' => '608',
            'PK' => '586',
            'PL' => '616',
            'PM' => '666',
            'PN' => '612',
            'PR' => '630',
            'PS' => '275',
            'PT' => '620',
            'PW' => '585',
            'PY' => '600',
            'QA' => '634',
            'RE' => '638',
            'RO' => '642',
            'RS' => '688',
            'RU' => '643',
            'RW' => '646',
            'SA' => '682',
            'SB' => '090',
            'SC' => '690',
            'SD' => '729',
            'SE' => '752',
            'SG' => '702',
            'SH' => '654',
            'SI' => '705',
            'SJ' => '744',
            'SK' => '703',
            'SL' => '694',
            'SM' => '674',
            'SN' => '686',
            'SO' => '706',
            'SR' => '740',
            'SS' => '728',
            'ST' => '678',
            'SV' => '222',
            'SX' => '534',
            'SY' => '760',
            'SZ' => '748',
            'TC' => '796',
            'TD' => '148',
            'TF' => '260',
            'TG' => '768',
            'TH' => '764',
            'TJ' => '762',
            'TK' => '772',
            'TL' => '626',
            'TM' => '795',
            'TN' => '788',
            'TO' => '776',
            'TR' => '792',
            'TT' => '780',
            'TV' => '798',
            'TW' => '158',
            'TZ' => '834',
            'UA' => '804',
            'UG' => '800',
            'UM' => '581',
            'US' => '840',
            'UY' => '858',
            'UZ' => '860',
            'VA' => '336',
            'VC' => '670',
            'VE' => '862',
            'VG' => '092',
            'VI' => '850',
            'VN' => '704',
            'VU' => '548',
            'WF' => '876',
            'WS' => '882',
            'YE' => '887',
            'YT' => '175',
            'ZA' => '710',
            'ZM' => '894',
            'ZW' => '716'
        };
        String countryCodeNumber = mapAlpha2ToNumberCountryISO.get(countryIsoAlpha2);
        if (countryCodeNumber == null) {
            throw new HandledException('Error with mapping ISO country code Alpha2 to number.');
        }
        return countryCodeNumber;
    }
}