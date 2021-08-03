import { api, LightningElement, track } from "lwc";
import AgoraOrder_HeadCol_Name from "@salesforce/label/c.AgoraOrder_HeadCol_Name";
import AgoraOrder_HeadCol_Reference from "@salesforce/label/c.AgoraOrder_HeadCol_Reference";
import AgoraOrder_HeadCol_Brand from "@salesforce/label/c.AgoraOrder_HeadCol_Brand";
import AgoraOrder_HeadCol_LongRef from "@salesforce/label/c.AgoraOrder_HeadCol_LongRef";
import AgoraOrder_ConfirmSelection from "@salesforce/label/c.AgoraOrder_ConfirmSelection";
import AgoraOrder_NoProductsFound from "@salesforce/label/c.AgoraOrder_NoProductsFound";
import ALLLoading from "@salesforce/label/c.ALLLoading";
import { errorHandler, showErrorToast } from "c/woo_freeOrderAgoraSharedJs";

const labels = {
    AgoraOrder_HeadCol_Name,
    AgoraOrder_HeadCol_LongRef,
    AgoraOrder_HeadCol_Reference,
    AgoraOrder_HeadCol_Brand,
    AgoraOrder_ConfirmSelection,
    AgoraOrder_NoProductsFound,
    ALLLoading,
};

export default class Woo_freeOrderAgoraProductSelectionFromAgora extends LightningElement {
    labels = labels;

    @api
    isConfirmedButtonHidden = false;

    /**
     * @type {'PRODUCT_TO_SELECT' | 'PRODUCT_SELECTED' | 'PRODUCT_CONFIRMED'}
     */
    _currentStep = "PRODUCT_TO_SELECT";

    set currentStep(currentStep) {
        this._currentStep = currentStep;
        this.dispatchEvent(
            new CustomEvent("currentstepchange", {
                detail: {
                    currentStep,
                },
            })
        );
    }
    get currentStep() {
        return this._currentStep;
    }

    /**
     * @type {AgoraProductResult | null}
     */
    selectedProduct;
    /**
     * @type {boolean}
     */
    isLoading = false;

    /**
     * @type {ProductTable<AgoraProductResult>}
     */
    @track
    products = {
        data: undefined,
        columns: [
            { label: this.labels.AgoraOrder_HeadCol_Name, fieldName: "name" },
            { label: this.labels.AgoraOrder_HeadCol_LongRef, fieldName: "referenceCommercial" },
            { label: this.labels.AgoraOrder_HeadCol_Reference, fieldName: "referenceTechnique" },
            { label: this.labels.AgoraOrder_HeadCol_Brand, fieldName: "brand" },
        ],
        isEmpty: false,
        keyField: "agoraKey",
        pagingText: "",
    };

    /**
     * @type {(productList: AgoraProductResult[]) => void}
     */
    @api
    displayAgoraProductList(productList) {
        this.currentStep = "PRODUCT_TO_SELECT";
        this.selectedProduct = null;
        this.products.data = productList;
        this.products.isEmpty = !productList || productList.length == 0;
    }

    //@ts-ignore
    get confirmProductDisabled() {
        return this.currentStep == "PRODUCT_TO_SELECT";
    }
    handleProductSelection(event) {
        const selectedRows = event.detail.selectedRows;
        this.selectedProduct = selectedRows[0];
        this.currentStep = "PRODUCT_SELECTED";
    }

    @api
    handleConfirmProduct() {
        if (!this.selectedProduct) {
            throw Error("The should be a selected product.");
        }
        this.currentStep = "PRODUCT_CONFIRMED";
        this.dispatchEvent(
            new CustomEvent("productselected", {
                detail: {
                    selectedProduct: this.selectedProduct,
                },
            })
        );
    }
}
