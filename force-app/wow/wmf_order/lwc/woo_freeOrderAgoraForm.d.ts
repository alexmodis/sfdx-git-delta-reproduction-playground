type Consumer_Address__c = {
    Id: string;
    AddressTitle__c: string;
    City__c: string;
    CountryCode__c: string;
    PostalCode__c: string;
    Ligne_1__c: string;
    Ligne_2__c: string;
    Ligne_3__c: string;
    MainAddress__c: boolean;
    Secondary_Address__c: boolean;
    Label__c: string;
};

type AddressPicked = {
    title: string;
    street: string;
    city: string;
    country: string;
    postalCode: string;
    showAddressLookup: boolean;
    editable: boolean;
};

type AgoraProductResult = {
    name: string;
    referenceCommercial: string;
    referenceTechnique: string;
    brand: string;
    agoraKey: string;
};

type TableRow = {
    name: string;
    reference: string;
    quantity: number;
    quantitySelected: number;
    pru?: number;
    type: "BOM" | "PROD";
    availability?: boolean;
    isSentWithSuccess?: boolean;
    orderStatus?: "Sent" | "SentWithErrors" | "NotSent";
    deliveryDelay?: string;
    sfProductId?: string;
};

type SfProduct = {
    longRef: string;
    cmmf: string;
    name: string;
    brand: string;
    universe: string;
    subFamily: string;
    country: string;
};

type ProductTable<T> = {
    columns: Array<{
        label: string;
        fieldName: keyof T;
        type?: string;
        typeAttributes?: any;
        editable?: boolean;
        cellAttributes?: any;
    }>;
    data?: T[];
    availableData?: T[];
    isEmpty: boolean;
    keyField: keyof T;
    pagingText: string;
    suppressBottomBar: boolean;
    enableInfiniteLoading?: boolean;
    errors?: {
        rows?: {
            [keyField: string]: {
                title: string;
                messages: string[];
                fieldNames: Array<keyof T>;
            };
        };
        table?: {
            title: string;
            messages: string[];
        };
    };
    hideCheckboxColumn?: boolean;
};

type CreateRepairFront = {
    orderId: string;
    orderProduct: AgoraProductResult;
    bomList: TableRow[];
    goodwillList: TableRow[];
    consumerAddress: AddressPicked;
    cccGroup: string;
};

type SendOrderBase = {
    mainOrderId: string;
    consumerAddress: AddressPicked;
    cccGroup: string;
};
type SendOrderMain = {
    orderProduct: AgoraProductResult;
    bomList: TableRow[];
};
type SendOrderGoodwillSpareParts = {
    orderProduct: AgoraProductResult;
    goodwillSpareParts: TableRow[];
};
type SendOrderGoodwillProduct = {
    goodwillProduct: TableRow;
};
type EventType<T> = {
    detail: T;
};

type OnCellChangeEvent = EventType<{
    draftValues: Array<{ quantitySelected: string; reference: string }>;
}>;

type OnRowSelectionEvent<T> = EventType<{
    selectedRows: T[];
}>;

type ValidationError = { field: string; errorMessage: string; messageType: "E" | "W" };
type CreateRepairFrontResponse = {
    isValid: boolean;
    errorMessage: string;
    validationErrors: Array<ValidationError>;
};

type ModalSendOrderArgs = {
    type: "FOC" | "FEX" | "Goodwill";
    bomList?: TableRow[];
    goodwillList?: TableRow[];
    product?: AgoraProductResult;
};

type ModelSfProductCallback = (selectedProduct: AgoraProductResult, sfId: string) => void;

/* -------------------------------------------------------------------------- */
/*      types generated with https://jsonformatter.org/json-to-typescript     */
/* -------------------------------------------------------------------------- */
type SubOrdersAndLines = {
    mainOrderLines: WMFOrderLineItemsR[];
    subOrdersAndLines: SubOrdersAndLine[];
};

type SubOrdersAndLine = {
    WOO_Retailer__c: string;
    WOO_Account__r: WOOAccountR;
    WOO_Case__r: WOOCaseR;
    WOO_SAP_status__c: "Sent" | "SentWithErrors" | "NotSent";
    WOO_Agora_Submission_Datetime__c: Date;
    WOO_Agora_Symptoms__c: string;
    WOO_Agora_Retailer_City__c: string;
    WOO_Account__c: string;
    WOO_AgoraManufacturingDate__c: string;
    WOO_Order_Type__c: string;
    WMF_Order_Line_Items__r?: WMFOrderLineItemsR[];
    WOO_Case__c: string;
    WOO_Agora_Retailer_Zipcode__c: string;
    Id: string;
    WOO_Agora_ProductRefCom__c: string;
    WOO_Agora_Order_Ref__c: string;
    Product_Country__c: string;
    WOO_Comment__c?: string;
    WOO_Product__c?: string;
};

type WMFOrderLineItemsR = {
    WOO_Reference__c: string;
    WOO_Requested_quantity__c: number;
    WOO_WMF_Order__c: string;
    WOO_Comment__c: string;
    WOO_Name__c: string;
    Id: string;
    WOO_Unitary_price__c: number;
};

type WOOAccountR = {
    LastName: string;
    Id: string;
    Salutation: string;
    FirstName: string;
    Phone: string;
};

type WOOCaseR = {
    CaseNumber: string;
    AgoraId_Counter__c: number;
    AccountId: string;
    Purchase_Date__c: Date;
    Id: string;
    Exchange_Agreement_Number__c: string;
};
