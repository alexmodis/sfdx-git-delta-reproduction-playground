//@ts-check
import { LightningElement, api, track, wire } from "lwc";
import checkIfAgoraUserCode from "@salesforce/apex/WOO_freeOrderAgoraFormController.checkIfAgoraUserCode";
import getBomList from "@salesforce/apex/WOO_freeOrderAgoraFormController.getBomList";
import sendMainOrder from "@salesforce/apex/WOO_freeOrderAgoraFormControllerRepair.sendMainOrder";
import sendGoodwillSparePartsOrder from "@salesforce/apex/WOO_freeOrderAgoraFormControllerRepair.sendGoodwillSparePartsOrder";
import sendGoodwillProductOrder from "@salesforce/apex/WOO_freeOrderAgoraFormControllerRepair.sendGoodwillProductOrder";
import getSubOrdersAndLines from "@salesforce/apex/WOO_freeOrderAgoraFormController.getSubOrdersAndLines";
import getProducts from "@salesforce/apex/WOO_freeOrderAgoraFormController.getProducts";
import savePreviousErrors from "@salesforce/apex/WOO_freeOrderAgoraFormControllerRepair.savePreviousErrors";

import ALLLoading from "@salesforce/label/c.ALLLoading";
import AgoraOrder_Error_DeselectLineSent from "@salesforce/label/c.AgoraOrder_Error_DeselectLineSent";
import AgoraOrder_GetProducts from "@salesforce/label/c.AgoraOrder_GetProducts";
import AgoraOrder_NoProductsFound from "@salesforce/label/c.AgoraOrder_NoProductsFound";
import AgoraOrder_ConfirmSelection from "@salesforce/label/c.AgoraOrder_ConfirmSelection";
import AgoraOrder_AddSfProduct from "@salesforce/label/c.AgoraOrder_AddSfProduct";
import AgoraOrder_HeadCol_Name from "@salesforce/label/c.AgoraOrder_HeadCol_Name";
import AgoraOrder_HeadCol_Brand from "@salesforce/label/c.AgoraOrder_HeadCol_Brand";
import AgoraOrder_HeadCol_Reference from "@salesforce/label/c.AgoraOrder_HeadCol_Reference";
import AgoraOrder_HeadCol_Quantity from "@salesforce/label/c.AgoraOrder_HeadCol_Quantity";
import AgoraOrder_HeadCol_Price from "@salesforce/label/c.AgoraOrder_HeadCol_Price";
import AgoraOrder_HeadCol_Availability from "@salesforce/label/c.AgoraOrder_HeadCol_Availability";
import AgoraOrder_HeadCol_SendingStatus from "@salesforce/label/c.AgoraOrder_HeadCol_SendingStatus";
import AgoraOrder_HeadCol_DeliveryDelay from "@salesforce/label/c.AgoraOrder_HeadCol_DeliveryDelay";
import AgoraOrder_SelectedProductTitle from "@salesforce/label/c.AgoraOrder_SelectedProductTitle";
import AgoraOrder_Back from "@salesforce/label/c.AgoraOrder_Back";
import AgoraOrder_BomListTitle from "@salesforce/label/c.AgoraOrder_BomListTitle";
import AgoraOrder_GoodWillTitle from "@salesforce/label/c.AgoraOrder_GoodWillTitle";
import AgoraOrder_CreateRepairOrder from "@salesforce/label/c.AgoraOrder_CreateRepairOrder";
import AgoraOrder_SendOrderButtonGW from "@salesforce/label/c.AgoraOrder_SendOrderButtonGW";
import AgoraOrder_Error_SelectProduct from "@salesforce/label/c.AgoraOrder_Error_SelectProduct";
import AgoraOrder_Error_ProductCountry from "@salesforce/label/c.AgoraOrder_Error_ProductCountry";
import AgoraOrder_Error_ProductRef from "@salesforce/label/c.AgoraOrder_Error_ProductRef";
import AgoraOrder_Error_TableRowQuantity from "@salesforce/label/c.AgoraOrder_Error_TableRowQuantity";
import AgoraOrder_Success from "@salesforce/label/c.AgoraOrder_Success";
import AgoraOrder_OrderSent from "@salesforce/label/c.AgoraOrder_OrderSent";
import AgoraOrder_Error from "@salesforce/label/c.AgoraOrder_Error";
import AgoraOrder_FexPoductSectionTitle from "@salesforce/label/c.AgoraOrder_FexPoductSectionTitle";
import AgoraOrder_InfoSelectAddress from "@salesforce/label/c.AgoraOrder_InfoSelectAddress";
import AgoraOrder_OrderSentSuccess from "@salesforce/label/c.AgoraOrder_OrderSentSuccess";
//@ts-ignore
import { errorHandler, showErrorToast, ToastError } from "c/woo_freeOrderAgoraSharedJs";
//@ts-ignore
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import {
    publish,
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext,
} from "lightning/messageService";
import channelWooFreeOrderAgora__c from "@salesforce/messageChannel/channelWooFreeOrderAgora__c";
import channelWooFreeOrderAgoraRefreshAddress__c from "@salesforce/messageChannel/channelWooFreeOrderAgoraRefreshAddress__c";

import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import orderWOO_SAP_status__c from "@salesforce/schema/WOO_WMF_Orders__c.WOO_SAP_status__c";
import orderProduct_Country__c from "@salesforce/schema/WOO_WMF_Orders__c.Product_Country__c";
import orderWoo_Order_Type__c from "@salesforce/schema/WOO_WMF_Orders__c.WOO_Order_Type__c";
//@ts-ignore
import orderWOO_Case__rCase_CCC__c from "@salesforce/schema/WOO_WMF_Orders__c.WOO_Case__r.Case_CCC__c";
//@ts-ignore
import orderWoo_Product__c from "@salesforce/schema/WOO_WMF_Orders__c.Woo_Product__c";
//@ts-ignore
import orderWoo_Product__rReference_commerciale__c from "@salesforce/schema/WOO_WMF_Orders__c.Woo_Product__r.Reference_commerciale__c";
//@ts-ignore
import orderWoo_Product__rCountry__c from "@salesforce/schema/WOO_WMF_Orders__c.Woo_Product__r.Country__c";
//@ts-ignore
import orderWOO_Agora_ProductRefCom__c from "@salesforce/schema/WOO_WMF_Orders__c.WOO_Agora_ProductRefCom__c";
//@ts-ignore
import orderWOO_Order_Previous_Errors__c from "@salesforce/schema/WOO_WMF_Orders__c.WOO_Order_Previous_Errors__c";

const labels = {
    ALLLoading,
    AgoraOrder_Error_DeselectLineSent,
    AgoraOrder_GetProducts,
    AgoraOrder_NoProductsFound,
    AgoraOrder_ConfirmSelection,
    AgoraOrder_AddSfProduct,
    AgoraOrder_HeadCol_Name,
    AgoraOrder_HeadCol_Brand,
    AgoraOrder_HeadCol_Reference,
    AgoraOrder_HeadCol_Quantity,
    AgoraOrder_HeadCol_Price,
    AgoraOrder_HeadCol_Availability,
    AgoraOrder_HeadCol_SendingStatus,
    AgoraOrder_HeadCol_DeliveryDelay,
    AgoraOrder_SelectedProductTitle,
    AgoraOrder_Back,
    AgoraOrder_BomListTitle,
    AgoraOrder_GoodWillTitle,
    AgoraOrder_Error_SelectProduct,
    AgoraOrder_Error_ProductCountry,
    AgoraOrder_Error_ProductRef,
    AgoraOrder_Error_TableRowQuantity,
    AgoraOrder_CreateRepairOrder,
    AgoraOrder_SendOrderButtonGW,
    AgoraOrder_Success,
    AgoraOrder_OrderSent,
    AgoraOrder_Error,
    AgoraOrder_FexPoductSectionTitle,
    AgoraOrder_OrderSentSuccess,
    AgoraOrder_InfoSelectAddress,
};
export default class Woo_freeOrderAgoraForm extends LightningElement {
    labels = labels;
    isLoading = false;
    /** @type {string} */
    @api recordId;

    /** @type {import("lightning/uiRecordApi").RecordRepresentation} */
    order;
    /** @type {SubOrdersAndLines} */
    subOrdersAndLines;
    /** @type {string} */
    caseCccGroup;

    //@ts-ignore
    get orderStatus() {
        const status = getFieldValue(this.order, orderWOO_SAP_status__c);
        if (status == "Sent" || status == "NotSent" || status == "SentWithErrors") {
            return status;
        }
        return null;
    }
    //@ts-ignore
    get orderRetailerCountry() {
        const retailer = getFieldValue(this.order, orderProduct_Country__c);
        return retailer;
    }

    initVars() {
        this.isLoading = false;
        this.currentStep = "PRODUCT_TO_SELECT";
        this.mainAgoraProduct = null;
        this.selectedBomRows = [];
        this.selectedGoodwillRows = [];
    }

    initTables() {
        this.bomList = {
            data: undefined,
            columns: [
                {
                    label: this.labels.AgoraOrder_HeadCol_SendingStatus,
                    fieldName: "isSentWithSuccess",
                    type: "boolean",
                },
                {
                    label: this.labels.AgoraOrder_HeadCol_Quantity,
                    fieldName: "quantitySelected",
                    editable: true,
                    type: "number",
                    typeAttributes: {
                        minimumIntegerDigits: 1,
                        minimumFractionDigits: 0,
                        maximumFractionDigits: 0,
                        minimumSignificantDigits: 1,
                        maximumSignificantDigits: 2,
                    },
                },
                { label: this.labels.AgoraOrder_HeadCol_Reference, fieldName: "reference" },
                { label: this.labels.AgoraOrder_HeadCol_Name, fieldName: "name" },
                {
                    label: this.labels.AgoraOrder_HeadCol_Price,
                    fieldName: "pru",
                    type: "currency",
                    typeAttributes: { currencyCode: "EUR", step: "0.001" },
                    cellAttributes: { alignment: "left" },
                },
                {
                    label: this.labels.AgoraOrder_HeadCol_Availability,
                    fieldName: "availability",
                    type: "boolean",
                },
                { label: this.labels.AgoraOrder_HeadCol_DeliveryDelay, fieldName: "deliveryDelay" },
            ],
            isEmpty: false,
            keyField: "reference",
            pagingText: "",
            suppressBottomBar: true,
        };
        this.goodWillList = {
            data: [],
            columns: this.bomList.columns.filter((col) => {
                return !(
                    !this.isFoc &&
                    (col.fieldName === "availability" ||
                        col.fieldName === "deliveryDelay" ||
                        col.fieldName === "pru")
                );
            }),
            isEmpty: false,
            keyField: "reference",
            pagingText: "",
            suppressBottomBar: true,
        };
        this.selectedGoodWillsKeys = [];
        this.selectedBomKeys = [];
    }

    rebootCmpConf = {
        hasDataLoadedOnce: false,
        fieldsThatReboot: [
            {
                reference: orderWoo_Product__c,
                previousValue: undefined,
            },
        ],
    };

    isRebootNeeded() {
        let shouldReboot = false;
        if (this.rebootCmpConf.hasDataLoadedOnce) {
            for (const stateRebootElem of this.rebootCmpConf.fieldsThatReboot) {
                if (
                    getFieldValue(this.order, stateRebootElem.reference) !==
                    stateRebootElem.previousValue
                ) {
                    shouldReboot = true;
                    break;
                }
            }
        } else {
            shouldReboot = true;
        }
        for (const stateRebootElem of this.rebootCmpConf.fieldsThatReboot) {
            stateRebootElem.previousValue = getFieldValue(this.order, stateRebootElem.reference);
        }
        this.rebootCmpConf.hasDataLoadedOnce = true;
        return shouldReboot;
    }

    @wire(getRecord, {
        recordId: "$recordId",
        fields: [
            orderWoo_Order_Type__c,
            orderWoo_Product__rReference_commerciale__c,
            orderWoo_Product__c,
            orderWOO_Case__rCase_CCC__c,
            orderWoo_Product__rCountry__c,
            orderWOO_SAP_status__c,
            orderProduct_Country__c,
            orderWOO_Agora_ProductRefCom__c,
            orderWOO_Order_Previous_Errors__c,
        ],
    })
    wiringOrder({ error, data }) {
        if (error) {
            errorHandler(error, this);
        } else if (data) {
            this.order = data;
            if (!this.isRebootNeeded()) {
                return;
            }
            this.initVars();
            this.initTables();
            this.caseCccGroup = "" + (getFieldValue(this.order, orderWOO_Case__rCase_CCC__c) || "");
            if (!this.caseCccGroup) {
                showErrorToast("Case order needs to have a CCC Country", this);
            }
            this.isLoading = true;
            Promise.all([checkIfAgoraUserCode(), getSubOrdersAndLines({ orderId: this.recordId })])
                .then(([, subOrdersAndLines]) => {
                    this.subscribeToMessageChannel();
                    this.subOrdersAndLines = subOrdersAndLines || [];
                    if (this.areAllOrdersSuccessful()) {
                        this.currentStep = "ORDER_SENT_WITH_SUCCESS";
                        return;
                    }
                    if (this.isGoodwill) {
                        this.currentStep = "PRODUCT_CONFIRMED";
                        this.mainProductSelected(null);
                        return;
                    }
                    this.loadAgoraProductList();
                })
                .catch((error) => {
                    errorHandler(error, this);
                })
                .finally(() => {
                    this.isLoading = false;
                });
        }
    }

    /* -------------------------------------------------------------------------- */
    /*                               State for steps                              */
    /* -------------------------------------------------------------------------- */
    /**
     * @type {'PRODUCT_TO_SELECT' | 'PRODUCT_CONFIRMED' | 'ORDER_SENT_WITH_SUCCESS'}
     */
    currentStep;
    //@ts-ignore
    get productSelectionStep() {
        return this.currentStep == "PRODUCT_TO_SELECT";
    }
    //@ts-ignore
    get bomAndGoodWillStep() {
        return this.currentStep == "PRODUCT_CONFIRMED";
    }
    //@ts-ignore
    get orderSentSuccessStep() {
        return this.currentStep == "ORDER_SENT_WITH_SUCCESS";
    }

    goPreviousStep() {
        if (this.bomAndGoodWillStep) {
            this.mainAgoraProduct = null;
            this.currentStep = "PRODUCT_TO_SELECT";
            this.loadAgoraProductList();
            this.initTables();
        }
    }

    /* -------------------------------------------------------------------------- */
    /*                              Load Product List                             */
    /* -------------------------------------------------------------------------- */

    loadAgoraProductList() {
        const country = getFieldValue(this.order, orderWoo_Product__rCountry__c);
        const prodRef = getFieldValue(this.order, orderWoo_Product__rReference_commerciale__c);
        if (!this.order.fields.WOO_Product__r.value) {
            showErrorToast(labels.AgoraOrder_Error_SelectProduct, this, {
                mode: "sticky",
            });
            return;
        } else if (!country || typeof country != "string") {
            showErrorToast(labels.AgoraOrder_Error_ProductCountry, this, {
                mode: "sticky",
            });
            return;
        } else if (!prodRef || typeof prodRef != "string") {
            showErrorToast(labels.AgoraOrder_Error_ProductRef, this, {
                mode: "sticky",
            });
            return;
        }
        setTimeout(() => {
            // setTimeout to be sure that the component has been instanciated
            //@ts-ignore
            const agoraProdSelectCmp = this.template.querySelector(
                "c-woo_free-order-agora-product-selection-from-agora"
            );
            if (agoraProdSelectCmp && agoraProdSelectCmp.displayAgoraProductList) {
                this.isLoading = true;
                this.queryAgoraProdList(country, prodRef)
                    .then((productList) => {
                        if (productList) {
                            this.agoraProductList = productList;
                        }
                        agoraProdSelectCmp.displayAgoraProductList(productList);
                        const selectedProdRefCom = getFieldValue(
                            this.order,
                            orderWOO_Agora_ProductRefCom__c
                        );
                        if (selectedProdRefCom) {
                            this.autoFillMainProductSelection(selectedProdRefCom);
                            // the child cmp will trigger an event that will call this.mainProductSelected()
                        }
                    })
                    .catch((error) => {
                        errorHandler(error, this);
                    })
                    .finally(() => {
                        this.isLoading = false;
                    });
            } else {
                throw new Error(
                    'component "c-woo_free-order-agora-product-selection-from-agora" has not been instanciated before it was used.'
                );
            }
        });
    }
    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

    /**
     *
     * @param {string} country
     * @param {string} prodRef
     */
    queryAgoraProdList(country, prodRef) {
        return getProducts({ country, longRef: prodRef, cccGroup: this.caseCccGroup }).then(
            (
                /**
                 * @type {AgoraProductResult[]}
                 */
                result
            ) => {
                return result;
            }
        );
    }

    //@ts-ignore
    get isFoc() {
        const typeString = "" + getFieldValue(this.order, orderWoo_Order_Type__c);
        if (typeString) {
            return typeString.trim() === "FOC";
        }
        return false;
    }
    //@ts-ignore
    get isFex() {
        const typeString = "" + getFieldValue(this.order, orderWoo_Order_Type__c);
        if (typeString) {
            return typeString.trim() === "FEX";
        }
        return false;
    }
    //@ts-ignore
    get isGoodwill() {
        const typeString = "" + getFieldValue(this.order, orderWoo_Order_Type__c);
        if (typeString) {
            return typeString.trim() === "Goodwill";
        }
        return false;
    }

    //@ts-ignore
    get createRepairButtonDisabled() {
        return !(
            this.bomAndGoodWillStep &&
            this.addressPicked &&
            this.addressPicked.isValid &&
            !this.bomList.errors &&
            !this.goodWillList.errors &&
            (this.isFex ||
                (this.isGoodwill && this.selectedGoodwillRows.length > 0) ||
                (this.isFoc && this.selectedBomRows.length > 0))
        );
    }

    goToAddressCmp() {}

    /* -------------------------------------------------------------------------- */
    /*                           Product Selection Step                           */
    /* -------------------------------------------------------------------------- */

    /**
     * @type {AgoraProductResult[]}
     */
    agoraProductList;
    /**
     * @type {AgoraProductResult}
     */
    mainAgoraProduct;
    /**
     * @param {EventType<{
     *       selectedProduct:AgoraProductResult;
     *    }> | null} event
     **/
    mainProductSelected(event) {
        this.askForAddressMessage();
        this.mainAgoraProduct = event?.detail?.selectedProduct;
        const previousErrors = "" + getFieldValue(this.order, orderWOO_Order_Previous_Errors__c);
        if (previousErrors) {
            this.repairResponse = JSON.parse(previousErrors);
        }
        const loadTableRows = () => {
            if (this.isFex || this.isGoodwill) {
                this.currentStep = "PRODUCT_CONFIRMED";
                if (this.isFex) {
                    this.fexProdReplacement = {
                        data: [
                            {
                                ...this.mainAgoraProduct,
                                quantity: 1,
                                isSentWithSuccess: this.orderStatus == "Sent",
                            },
                        ],
                        columns: [
                            {
                                label: this.labels.AgoraOrder_HeadCol_SendingStatus,
                                fieldName: "isSentWithSuccess",
                                type: "boolean",
                            },
                            {
                                label: this.labels.AgoraOrder_HeadCol_Quantity,
                                fieldName: "quantity",
                            },
                            {
                                label: this.labels.AgoraOrder_HeadCol_Reference,
                                fieldName: "referenceCommercial",
                            },
                            { label: this.labels.AgoraOrder_HeadCol_Name, fieldName: "name" },
                            { label: this.labels.AgoraOrder_HeadCol_Brand, fieldName: "brand" },
                        ],
                        keyField: "agoraKey",
                        isEmpty: false,
                        pagingText: "",
                        suppressBottomBar: true,
                        hideCheckboxColumn: true,
                    };
                }
                return Promise.resolve();
            } else if (this.isFoc) {
                return getBomList({
                    agoraKey: this.mainAgoraProduct && this.mainAgoraProduct.agoraKey,
                    cccGroup: this.caseCccGroup,
                }).then(
                    (
                        /**
                         * @type {TableRow[]}
                         */ result
                    ) => {
                        this.bomList.data = result.map((bomRow) => {
                            return { ...bomRow, quantitySelected: bomRow.quantity };
                        });
                        this.bomList.isEmpty = !result || result.length == 0;
                        this.goodWillList.data = JSON.parse(JSON.stringify(this.bomList.data));
                        this.goodWillList.isEmpty = !result || result.length == 0;
                        this.currentStep = "PRODUCT_CONFIRMED";
                    }
                );
            }
        };

        const putTablesAsLeftByUser = () => {
            const checkBomTableRows = () => {
                for (const mainOrderLine of this.subOrdersAndLines.mainOrderLines) {
                    const matchingRow = this.bomList.data.find(
                        (row) => row.reference == mainOrderLine.WOO_Reference__c
                    );

                    if (matchingRow) {
                        matchingRow.orderStatus = this.orderStatus;
                        if (this.orderStatus == "Sent") {
                            matchingRow.isSentWithSuccess = true;
                        }
                        matchingRow.quantitySelected = mainOrderLine.WOO_Requested_quantity__c;
                        this.selectedBomKeys = [matchingRow.reference, ...this.selectedBomKeys];
                        this.selectedBomRows.push(matchingRow);
                    }
                }
                this.bomList.data = [...this.bomList.data]; // trigger re-rendering
            };
            if (this.isFoc) {
                checkBomTableRows();
            }

            const addProductRowsToGoodwillTable = () => {
                for (const subOrder of this.subOrdersAndLines.subOrdersAndLines) {
                    if (subOrder.WOO_Order_Type__c == "Goodwill_Product") {
                        this.goodWillList.data?.unshift({
                            type: "PROD",
                            name: subOrder.WOO_Comment__c,
                            quantity: 1,
                            quantitySelected: 1,
                            reference: subOrder.WOO_Agora_ProductRefCom__c,
                            sfProductId: subOrder.WOO_Product__c,
                            isSentWithSuccess: subOrder.WOO_SAP_status__c == "Sent",
                            orderStatus: subOrder.WOO_SAP_status__c,
                        });
                        this.selectedGoodWillsKeys = [
                            subOrder.WOO_Agora_ProductRefCom__c,
                            ...this.selectedGoodWillsKeys,
                        ];
                        this.selectedGoodwillRows.push(this.goodWillList.data[0]);
                    }
                }
                this.goodWillList.data = [...this.goodWillList.data]; // trigger re-rendering
            };
            addProductRowsToGoodwillTable();

            const checkSparePartsRowsInGoodwillTable = () => {
                const goodwillSparePartsOrder = this.subOrdersAndLines.subOrdersAndLines.find(
                    (subOrder) => subOrder.WOO_Order_Type__c == "Goodwill_SpareParts"
                );
                if (!goodwillSparePartsOrder || !goodwillSparePartsOrder.WMF_Order_Line_Items__r) {
                    return;
                }
                for (const orderLine of goodwillSparePartsOrder.WMF_Order_Line_Items__r) {
                    const matchingRow = this.goodWillList.data.find(
                        (row) => row.reference == orderLine.WOO_Reference__c
                    );

                    matchingRow.orderStatus = goodwillSparePartsOrder.WOO_SAP_status__c;
                    if (goodwillSparePartsOrder.WOO_SAP_status__c == "Sent") {
                        matchingRow.isSentWithSuccess = true;
                    }
                    if (matchingRow) {
                        matchingRow.quantitySelected = orderLine.WOO_Requested_quantity__c;
                        this.selectedGoodWillsKeys = [
                            matchingRow.reference,
                            ...this.selectedGoodWillsKeys,
                        ];
                        this.selectedGoodwillRows.push(matchingRow);
                    }
                }
                this.goodWillList.data = [...this.goodWillList.data]; // trigger re-rendering
            };
            if (this.isFoc) {
                checkSparePartsRowsInGoodwillTable();
            }
        };

        this.isLoading = true;
        loadTableRows()
            .then(() => {
                putTablesAsLeftByUser();
            })
            .catch((error) => {
                errorHandler(error, this);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
    autoFillMainProductSelection(selectedProdRefCom) {
        if (typeof selectedProdRefCom != "string") {
            throw new Error("Error with the type of orderWOO_Agora_ProductRefCom__c.");
        }
        const matchingProduct = this.agoraProductList?.find(
            (prod) => prod.referenceCommercial == selectedProdRefCom
        );
        if (matchingProduct) {
            this.mainProductSelected({
                detail: {
                    selectedProduct: matchingProduct,
                },
            });
        }
    }

    //@ts-ignore
    get isBackButtonDisplayed() {
        return !this.isGoodwill && this.orderStatus == "NotSent";
    }

    /* -------------------------------------------------------------------------- */
    /*                               BOM & GoodWill Step                          */
    /* -------------------------------------------------------------------------- */

    /**
     * @type {ProductTable<TableRow>}
     */
    @track
    bomList;

    /**
     * @type {TableRow[]}
     */
    @track
    selectedBomRows;

    /**
     * @type {ProductTable<TableRow>}
     */
    @track
    goodWillList;

    /**
     * @type {TableRow[]}
     */
    @track
    selectedGoodwillRows;

    /**
     * @type {ProductTable<AgoraProductResult & {quantity: number; isSentWithSuccess: boolean;}>}
     */
    @track
    fexProdReplacement;

    updateSelectedBomRows(
        /**
         * @type {OnRowSelectionEvent<TableRow>}
         */
        event
    ) {
        const tickReturn = this.tickRowsAlreadySent(event.detail.selectedRows, this.bomList.data);
        this.selectedBomRows = tickReturn.selectedRows;
        this.selectedBomKeys = tickReturn.keys;
    }

    updateSelectedGwRows(
        /**
         * @type {OnRowSelectionEvent<TableRow>}
         */
        event
    ) {
        const tickReturn = this.tickRowsAlreadySent(
            event.detail.selectedRows,
            this.goodWillList.data
        );
        this.selectedGoodwillRows = tickReturn.selectedRows;
        this.selectedGoodWillsKeys = tickReturn.keys;
    }

    /**
     * @param  selectedRows { TableRow[] }
     * @param  rows { TableRow[] }
     */
    tickRowsAlreadySent(selectedRows, rows) {
        selectedRows = [...selectedRows];
        const keys = selectedRows.map((row) => row.reference);
        let showPreventUnselectWarning = false;
        rows.filter(
            (row) => row.orderStatus == "Sent" || row.orderStatus == "SentWithErrors"
        ).forEach((row) => {
            if (!keys.includes(row.reference) /* == is not in selectedBomRows */) {
                keys.push(row.reference);
                selectedRows.push(row);
                showPreventUnselectWarning = true;
            }
        });
        if (showPreventUnselectWarning) {
            this.dispatchEvent(
                new ShowToastEvent({
                    message: labels.AgoraOrder_Error_DeselectLineSent,
                    variant: "warning",
                })
            );
        }
        return { keys, selectedRows };
    }

    //@ts-ignore
    get productTitle() {
        if (!this.mainAgoraProduct) {
            return "";
        }
        return this.labels.AgoraOrder_SelectedProductTitle.replace(
            "{0}",
            this.mainAgoraProduct.name
        ).replace("{1}", this.mainAgoraProduct.referenceCommercial);
    }

    //@ts-ignore
    get sendOrderButtonlabel() {
        if (this.isGoodwill) {
            return this.labels.AgoraOrder_SendOrderButtonGW;
        }
        return this.labels.AgoraOrder_CreateRepairOrder;
    }

    /** @type {string[]} */
    @track
    selectedGoodWillsKeys;

    /** @type {string[]} */
    @track
    selectedBomKeys;

    sfProductModal() {
        if (!this.orderRetailerCountry) {
            errorHandler(
                new ToastError("Fill the order field Retailer Country before adding a product."),
                this
            );
            return;
        }
        /**
         * @type {ModelSfProductCallback}
         */
        const modelSfProductCallback = (selectedProduct, sfId) => {
            if (this.goodWillList.data && selectedProduct) {
                /** @type {TableRow} */
                let prodLine = {
                    name: selectedProduct.name,
                    reference: selectedProduct.referenceCommercial,
                    type: "PROD",
                    quantity: 1,
                    quantitySelected: 1,
                    sfProductId: sfId,
                };
                this.goodWillList.data = [prodLine, ...(this.goodWillList.data || [])];
                this.selectedGoodwillRows = [prodLine, ...this.selectedGoodwillRows];
                this.selectedGoodWillsKeys = this.selectedGoodwillRows.map((row) => {
                    return "" + row[this.goodWillList.keyField];
                });
            }
        };
        this.template
            //@ts-ignore
            .querySelector("c-woo_free-order-agora-find-sf-products-modal")
            .openModal(modelSfProductCallback);
    }

    /* -------------------------------------------------------------------------- */
    /*                                   Address                                  */
    /* -------------------------------------------------------------------------- */
    subscription = null;
    @wire(MessageContext)
    messageContext;

    askForAddressMessage() {
        publish(this.messageContext, channelWooFreeOrderAgoraRefreshAddress__c);
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                channelWooFreeOrderAgora__c,
                (message) => {
                    this.iconAddress.setValidity(message.addressPicked.isValid);
                    this.addressPicked = message.addressPicked;
                },
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    @track
    iconAddress = {
        name: "utility:error",
        variant: "error",
        setValidity(isValid) {
            if (isValid) {
                this.name = "utility:check";
                this.variant = "success";
            } else {
                this.name = "utility:error";
                this.variant = "error";
            }
        },
    };

    /** @type {AddressPicked & {isValid:boolean;}} */
    addressPicked;

    /** @type {CreateRepairFrontResponse} */
    repairResponse;

    //@ts-ignore
    get isErrorDisplayed() {
        return this.repairResponse && !this.repairResponse.isValid;
    }

    openSendOrderModal() {
        /** @type { ModalSendOrderArgs } */
        const modalArgs = {
            //@ts-ignore
            type: "" + getFieldValue(this.order, orderWoo_Order_Type__c),
            product: this.mainAgoraProduct,
            bomList: this.selectedBomRows,
            goodwillList: this.selectedGoodwillRows,
        };
        this.template
            //@ts-ignore
            .querySelector("c-woo_free-order-agora-send-order-modal")
            .openModal(() => {
                this.sendOrder();
            }, modalArgs);
    }
    sendOrder() {
        this.isLoading = true;
        /** @type { SendOrderBase} */
        const inputOrderBase = {
            mainOrderId: this.recordId,
            consumerAddress: this.addressPicked,
            cccGroup: this.caseCccGroup,
        };

        /** @type { SendOrderMain} */
        const inputOrderMain = {
            orderProduct: this.mainAgoraProduct,
            bomList: [],
        };

        /** @type { SendOrderGoodwillProduct[]} */
        const inputGoodwillProductOrderList = [];

        if (this.isFoc) {
            inputOrderMain.bomList = this.selectedBomRows;
        }

        const sparePartRows = [];
        for (const tableRow of this.selectedGoodwillRows) {
            if (tableRow.type == "BOM") {
                sparePartRows.push(tableRow);
            } else {
                inputGoodwillProductOrderList.push({
                    goodwillProduct: tableRow,
                });
            }
        }
        /** @type { SendOrderGoodwillSpareParts} */
        const inputSparePartsOrder = {
            orderProduct: this.mainAgoraProduct,
            goodwillSpareParts: sparePartRows,
        };

        const updateValidationErrors = (
            /**
             * @type {CreateRepairFrontResponse | null}
             */
            sendOrderResponse
        ) => {
            if (!sendOrderResponse) {
                //the promise handler calling this function is handling the
                // sendMainOrder which has no results to pass on.
                return;
            }
            if (!sendOrderResponse.isValid) {
                this.repairResponse.isValid = false;
                for (const newValidationError of sendOrderResponse.validationErrors) {
                    const isDuplicateError = !!this.repairResponse.validationErrors.find(
                        (oldValError) => oldValError.errorMessage == newValidationError.errorMessage
                    );
                    if (!isDuplicateError) {
                        this.repairResponse.validationErrors.push(newValidationError);
                    }
                }
            }
        };

        /**
         * @type {Promise<CreateRepairFrontResponse | void>}
         */
        let promiseChain = sendMainOrder({ inputOrderBase, inputOrderMain }).then(
            (
                /**
                 * @type {CreateRepairFrontResponse}
                 */ result
            ) => {
                this.repairResponse = result;
                if (this.repairResponse.isValid) {
                    if (this.isFex) {
                        this.fexProdReplacement.data[0].isSentWithSuccess = true;
                        this.fexProdReplacement.data = [...this.fexProdReplacement.data]; //re-render
                    }
                    return Promise.resolve();
                } else {
                    return savePreviousErrors({
                        orderId: this.order.id,
                        errors: JSON.stringify(this.repairResponse),
                    }).then(() => {
                        throw new ToastError(this.labels.AgoraOrder_Error);
                    });
                }
            }
        );
        if (this.isFoc && inputSparePartsOrder.goodwillSpareParts.length) {
            promiseChain = promiseChain.then(() => {
                return sendGoodwillSparePartsOrder({ inputOrderBase, inputSparePartsOrder });
            });
        }
        for (const inputGoodwillProductOrder of inputGoodwillProductOrderList) {
            promiseChain = promiseChain.then(
                (
                    /**
                     * @type {CreateRepairFrontResponse | null}
                     */
                    result
                ) => {
                    updateValidationErrors(result);
                    return sendGoodwillProductOrder({
                        inputOrderBase,
                        inputGoodwillProductOrder,
                    });
                }
            );
        }
        promiseChain = promiseChain.then(
            (
                /**
                 * @type {CreateRepairFrontResponse | null}
                 */
                lastResult
            ) => {
                updateValidationErrors(lastResult);
                if (this.repairResponse.isValid) {
                    this.currentStep = "ORDER_SENT_WITH_SUCCESS";
                    const event = new ShowToastEvent({
                        title: this.labels.AgoraOrder_Success,
                        message: this.labels.AgoraOrder_OrderSent,
                        variant: "success",
                    });
                    this.dispatchEvent(event);
                } else {
                    const event = new ShowToastEvent({
                        title: this.labels.AgoraOrder_Error,
                        message: this.labels.AgoraOrder_Error,
                        variant: "error",
                    });
                    this.dispatchEvent(event);
                }
                savePreviousErrors({
                    orderId: this.order.id,
                    errors: JSON.stringify(this.repairResponse),
                }).then(() => {
                    eval("$A.get('e.force:refreshView').fire();"); //soft refresh
                });
            }
        );

        promiseChain
            .catch((error) => {
                errorHandler(error, this);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    onCellChange(
        dataTableCmp,
        /** @type {OnCellChangeEvent} */ event,
        /** @type {ProductTable<TableRow>} */ dataTable
    ) {
        for (const draftRow of event.detail.draftValues) {
            const matchingRow = dataTable.data.find((row) => row.reference == draftRow.reference);
            matchingRow.quantitySelected = Number.parseInt(draftRow.quantitySelected);
            dataTable.errors = null;
            if (matchingRow.type == "PROD") {
                matchingRow.quantitySelected = 1;
            } else if (
                matchingRow.type == "BOM" &&
                matchingRow.quantitySelected > matchingRow.quantity
            ) {
                dataTable.errors = {
                    rows: {
                        [draftRow.reference]: {
                            title: "",
                            fieldNames: ["quantitySelected"],
                            messages: [
                                labels.AgoraOrder_Error_TableRowQuantity + matchingRow.quantity,
                            ],
                        },
                    },
                };
            }
        }
        dataTableCmp.draftValues = [];
    }
    goodWillOnCellChange(/** @type {OnCellChangeEvent} */ event) {
        //@ts-ignore
        const dataTableGoodwill = this.template.querySelector("lightning-datatable.goodwill-table");
        this.onCellChange(dataTableGoodwill, event, this.goodWillList);
    }
    bomOnCellChange(/** @type {OnCellChangeEvent} */ event) {
        //@ts-ignore
        const dataTableBom = this.template.querySelector("lightning-datatable.bom-table");
        this.onCellChange(dataTableBom, event, this.bomList);
    }

    areAllOrdersSuccessful() {
        let areAllSubordersSuccess = false;
        if (this.orderStatus == "Sent") {
            areAllSubordersSuccess = true;
            for (const subOrder of this.subOrdersAndLines.subOrdersAndLines) {
                if (subOrder.WOO_SAP_status__c != "Sent") {
                    areAllSubordersSuccess = false;
                    break;
                }
            }
        }
        return areAllSubordersSuccess;
    }
}
