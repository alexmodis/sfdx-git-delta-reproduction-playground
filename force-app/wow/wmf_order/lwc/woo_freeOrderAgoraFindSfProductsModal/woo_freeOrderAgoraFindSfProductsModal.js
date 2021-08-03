//@ts-check
import { api, LightningElement, track } from "lwc";
import searchSfProducts from "@salesforce/apex/WOO_freeOrderAgoraFormController.searchSfProducts";
//@ts-ignore
import { errorHandler, showErrorToast } from "c/woo_freeOrderAgoraSharedJs";
import ALLLoading from "@salesforce/label/c.ALLLoading";
import AgoraOrder_Close from "@salesforce/label/c.AgoraOrder_Close";
import AgoraOrder_AddSfProduct from "@salesforce/label/c.AgoraOrder_AddSfProduct";
import AgoraOrder_SearchProducts from "@salesforce/label/c.AgoraOrder_SearchProducts";
import AgoraOrder_SearchProductsPlaceHolder from "@salesforce/label/c.AgoraOrder_SearchProductsPlaceHolder";
import AgoraOrder_Cancel from "@salesforce/label/c.AgoraOrder_Cancel";
import AgoraOrder_Validate from "@salesforce/label/c.AgoraOrder_Validate";
import AgoraOrder_HeadCol_Name from "@salesforce/label/c.AgoraOrder_HeadCol_Name";
import AgoraOrder_HeadCol_Reference from "@salesforce/label/c.AgoraOrder_HeadCol_Reference";
import AgoraOrder_HeadCol_LongRef from "@salesforce/label/c.AgoraOrder_HeadCol_LongRef";
import AgoraOrder_HeadCol_Brand from "@salesforce/label/c.AgoraOrder_HeadCol_Brand";
import AgoraOrder_HeadCol_Universe from "@salesforce/label/c.AgoraOrder_HeadCol_Universe";
import AgoraOrder_HeadCol_Subfamily from "@salesforce/label/c.AgoraOrder_HeadCol_Subfamily";
import AgoraOrder_HeadCol_Quantity from "@salesforce/label/c.AgoraOrder_HeadCol_Quantity";
import AgoraOrder_PagingText from "@salesforce/label/c.AgoraOrder_PagingText";
import AgoraOrder_Error from "@salesforce/label/c.AgoraOrder_Error";
import AgoraOrder_Error_ProductRefCountry from "@salesforce/label/c.AgoraOrder_Error_ProductRefCountry";
import getProducts from "@salesforce/apex/WOO_freeOrderAgoraFormController.getProducts";

export default class Woo_freeOrderAgoraFindSfProductsModal extends LightningElement {
    labels = {
        ALLLoading,
        AgoraOrder_Close,
        AgoraOrder_AddSfProduct,
        AgoraOrder_SearchProducts,
        AgoraOrder_SearchProductsPlaceHolder,
        AgoraOrder_Cancel,
        AgoraOrder_Validate,
        AgoraOrder_HeadCol_Name,
        AgoraOrder_HeadCol_Reference,
        AgoraOrder_HeadCol_Quantity,
        AgoraOrder_HeadCol_LongRef,
        AgoraOrder_HeadCol_Brand,
        AgoraOrder_HeadCol_Universe,
        AgoraOrder_HeadCol_Subfamily,
        AgoraOrder_Error_ProductRefCountry,
        AgoraOrder_PagingText,
    };

    initVars() {
        this.currentStep = "PICK_SF_PRODUCT";
        this.sfSearchResult = {
            data: undefined,
            columns: [
                { label: this.labels.AgoraOrder_HeadCol_LongRef, fieldName: "longRef" },
                { label: this.labels.AgoraOrder_HeadCol_Reference, fieldName: "cmmf" },
                { label: this.labels.AgoraOrder_HeadCol_Name, fieldName: "name" },
                { label: this.labels.AgoraOrder_HeadCol_Brand, fieldName: "brand" },
                { label: this.labels.AgoraOrder_HeadCol_Universe, fieldName: "universe" },
                { label: this.labels.AgoraOrder_HeadCol_Subfamily, fieldName: "subFamily" },
            ],
            isEmpty: false,
            keyField: "longRef",
            pagingText: "",
            suppressBottomBar: false,
            enableInfiniteLoading: true,
        };
        this.isModalOpened = true;
        this.isLoading = false;
        this.selectedRowsSf = [];
    }

    /* -------------------------------------------------------------------------- */
    /*                               State for steps                              */
    /* -------------------------------------------------------------------------- */
    /**
     * @type {'PICK_SF_PRODUCT' | 'PICK_AGORA_PRODUCT' | 'AGORA_PRODUCT_SELECTED'| 'AGORA_PRODUCT_PICKED' | 'ERROR'}
     */
    currentStep;
    //@ts-ignore
    get sfStep() {
        return this.currentStep == "PICK_SF_PRODUCT";
    }
    //@ts-ignore
    get agoraStep() {
        return (
            this.currentStep == "PICK_AGORA_PRODUCT" || this.currentStep == "AGORA_PRODUCT_SELECTED"
        );
    }

    agoraProdSelectStepChanged(event) {
        if (event.detail.currentStep == "PRODUCT_SELECTED") {
            this.currentStep = "AGORA_PRODUCT_SELECTED";
        }
    }

    /**
     * @type {ProductTable<SfProduct>}
     */
    @track
    sfSearchResult;
    @track
    isModalOpened = false;

    /**
     * @type {ModelSfProductCallback}
     */
    callBackProductChosen;

    /**
     * @type {string}
     */
    @api
    cccGroup;
    /**
     * @type {string}
     */
    @api
    productsCountry;

    @api
    openModal(
        /**
         * @type {ModelSfProductCallback}
         */
        callBackProductChosen
    ) {
        this.callBackProductChosen = callBackProductChosen;
        this.initVars();
    }
    /**
     * @type {boolean}
     */
    isLoading;

    @api
    closeModal() {
        this.isModalOpened = false;
    }

    /* --------------------------------- SF rows -------------------------------- */

    /** @type {SfProduct[]} */
    selectedRowsSf;
    handleRowSelectionSf(event) {
        this.selectedRowsSf = event.detail.selectedRows;
    }

    //@ts-ignore
    get validateProductDisabled() {
        return !(
            (this.currentStep == "PICK_SF_PRODUCT" &&
                this.selectedRowsSf &&
                this.selectedRowsSf.length > 0) ||
            this.currentStep == "AGORA_PRODUCT_SELECTED"
        );
    }
    validateProduct() {
        if (
            this.currentStep == "PICK_SF_PRODUCT" &&
            this.selectedRowsSf &&
            this.selectedRowsSf.length > 0
        ) {
            this.currentStep = "PICK_AGORA_PRODUCT";
            if (!this.selectedRowsSf[0].longRef || !this.selectedRowsSf[0].country) {
                showErrorToast(this.labels.AgoraOrder_Error_ProductRefCountry, this, {
                    mode: "sticky",
                });
                this.currentStep = "PICK_SF_PRODUCT";
                this.sfSearchResult.data = undefined;
                this.sfSearchResult.availableData = undefined;
                this.sfSearchResult.isEmpty = false;
                return;
            }
            this.isLoading = true;
            getProducts({
                country: this.selectedRowsSf[0].country,
                longRef: this.selectedRowsSf[0].longRef,
                cccGroup: this.cccGroup,
            })
                .then(
                    (
                        /**
                         * @type {AgoraProductResult[]}
                         */
                        result
                    ) => {
                        this.template
                            //@ts-ignore
                            .querySelector("c-woo_free-order-agora-product-selection-from-agora")
                            .displayAgoraProductList(result);
                    }
                )
                .catch((error) => {
                    errorHandler(error, this);
                })
                .finally(() => {
                    this.isLoading = false;
                });
        } else if (this.currentStep == "AGORA_PRODUCT_SELECTED") {
            this.template
                //@ts-ignore
                .querySelector("c-woo_free-order-agora-product-selection-from-agora")
                .handleConfirmProduct();
        }
    }
    stopClick(event) {
        event.stopPropagation();
    }

    searchSfProductsFront() {
        //@ts-ignore
        let sfProductSearchBar = this.template.querySelector(".sf-product-search-bar");
        if (!sfProductSearchBar) {
            console.error("Node sfProductSearchBar not found.");
            return;
        }
        let value = sfProductSearchBar.value;
        this.isLoading = true;
        searchSfProducts({ searchString: value, country: this.productsCountry })
            .then(
                (
                    /**
                     * @type {SfProduct[]}
                     */ result
                ) => {
                    this.sfSearchResult.enableInfiniteLoading = true;
                    this.sfSearchResult.availableData = result;
                    this.sfSearchResult.data = [];
                    this.sfSearchResult.pagingText = this.labels.AgoraOrder_PagingText.replace(
                        "{0}",
                        "" + this.sfSearchResult.availableData.length
                    );

                    this.loadNextRows();
                    this.sfSearchResult.isEmpty =
                        !this.sfSearchResult.data || this.sfSearchResult.data.length == 0;
                }
            )

            .catch((error) => {
                errorHandler(error, this);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
    loadNextRows(event) {
        if (!this.sfSearchResult.data || !this.sfSearchResult.availableData) {
            return;
        }
        if (event) {
            event.target.isLoading = true;
            if (this.sfSearchResult.data.length == 0) {
                event.target.enableInfiniteLoading = false;
            }
            this.sfSearchResult.data = this.sfSearchResult.data.concat(
                this.sfSearchResult.availableData.splice(this.sfSearchResult.data.length, 10)
            );
            event.target.isLoading = false;
            if (this.sfSearchResult.availableData.length == 0) {
                this.sfSearchResult.enableInfiniteLoading = false;
            }
            return;
        }
        this.sfSearchResult.data = this.sfSearchResult.data.concat(
            this.sfSearchResult.availableData.splice(this.sfSearchResult.data.length, 10)
        );
        if (this.sfSearchResult.availableData.length == 0) {
            this.sfSearchResult.enableInfiniteLoading = false;
        }
    }

    /**
     *
     * @param {EventType<{
     *    selectedProduct: AgoraProductResult;
     * }>} event
     */
    sfProductSelectedFromAgora(event) {
        const agoraProduct = event.detail.selectedProduct;
        this.currentStep = "AGORA_PRODUCT_PICKED";
        this.callBackProductChosen(
            JSON.parse(JSON.stringify(agoraProduct)),
            this.selectedRowsSf[0]?.sfId
        );
        this.closeModal();
    }

    //@ts-ignore
    get trueValue() {
        return true;
    }
}
