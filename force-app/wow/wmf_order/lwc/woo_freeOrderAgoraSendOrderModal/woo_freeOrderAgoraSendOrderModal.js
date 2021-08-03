import { api, LightningElement, track } from "lwc";
//@ts-ignore
import { errorHandler, showErrorToast } from "c/woo_freeOrderAgoraSharedJs";
import ALLLoading from "@salesforce/label/c.ALLLoading";
import AgoraOrder_Close from "@salesforce/label/c.AgoraOrder_Close";
import AgoraOrder_Cancel from "@salesforce/label/c.AgoraOrder_Cancel";
import AgoraOrder_Validate from "@salesforce/label/c.AgoraOrder_Validate";
import AgoraOrder_OrderValidation from "@salesforce/label/c.AgoraOrder_OrderValidation";
import AgoraOrder_OrderOverview from "@salesforce/label/c.AgoraOrder_OrderOverview";
import AgoraOrder_OrderValidationBomQuantitySpareParts from "@salesforce/label/c.AgoraOrder_OrderValidationBomQuantitySpareParts";
import AgoraOrder_OrderValidationGwQuantitySpareParts from "@salesforce/label/c.AgoraOrder_OrderValidationGwQuantitySpareParts";
import AgoraOrder_OrderValidationBomTotalPriceSpareParts from "@salesforce/label/c.AgoraOrder_OrderValidationBomTotalPriceSpareParts";
import AgoraOrder_OrderValidationGwTotalPriceSpareParts from "@salesforce/label/c.AgoraOrder_OrderValidationGwTotalPriceSpareParts";
import AgoraOrder_OrderValidationGwQuantityProducts from "@salesforce/label/c.AgoraOrder_OrderValidationGwQuantityProducts";
import AgoraOrder_SelectedProductTitle from "@salesforce/label/c.AgoraOrder_SelectedProductTitle";

export default class Woo_freeOrderAgoraSendOrderModal extends LightningElement {
    labels = {
        ALLLoading,
        AgoraOrder_Close,
        AgoraOrder_Cancel,
        AgoraOrder_Validate,
        AgoraOrder_OrderValidation,
        AgoraOrder_OrderOverview,
        AgoraOrder_OrderValidationBomQuantitySpareParts,
        AgoraOrder_OrderValidationGwQuantitySpareParts,
        AgoraOrder_OrderValidationBomTotalPriceSpareParts,
        AgoraOrder_OrderValidationGwTotalPriceSpareParts,
        AgoraOrder_SelectedProductTitle,
        AgoraOrder_OrderValidationGwQuantityProducts
    };

    @track
    isModalOpened = false;

    /** @type { AgoraProductResult } */
    @track
    product;

    get productInformation() {
        if (!this.product) {
            return "";
        }
        return this.labels.AgoraOrder_SelectedProductTitle.replace(
            "{0}",
            this.product.name
        ).replace("{1}", this.product.referenceCommercial);
    }

    @track
    totalPriceBom;
    @track
    quantityBomSpareParts;
    @track
    totalPriceGwSpareParts;
    @track
    quantityGwSpareParts;
    @track
    quantityGwProducts;

    @track
    isModalOpened = false;

    @track
    isFoc = false;
    @track
    isFex = false;
    @track
    isGoodwill = false;

    @api
    openModal(
        /**
         * @type {Function}
         */
        callBackProductChosen,
        /** @type { ModalSendOrderArgs } */ modalArgs
    ) {
        this.callBackProductChosen = callBackProductChosen;
        this.isModalOpened = true;
        if (modalArgs.type == "FEX") {
            this.isFex = true;
        } else if (modalArgs.type == "FOC") {
            this.isFoc = true;
        } else if (modalArgs.type == "Goodwill") {
            this.isGoodwill = true;
        }
        this.calculateNumbers(modalArgs);
    }

    calculateNumbers(/** @type { ModalSendOrderArgs } */ modalArgs) {
        this.product = modalArgs.product;
        let totalPriceBom = 0;
        let quantityBomSpareParts = 0;
        let totalPriceGwSpareParts = 0;
        let quantityGwSpareParts = 0;
        let quantityGwProducts = 0;
        if (modalArgs.bomList && modalArgs.bomList.length) {
            for (const bomElem of modalArgs.bomList) {
                //type = "BOM"
                quantityBomSpareParts += bomElem.quantitySelected;
                totalPriceBom += bomElem.pru * bomElem.quantitySelected;
            }
        }
        if (modalArgs.goodwillList && modalArgs.goodwillList.length) {
            for (const gwElem of modalArgs.goodwillList) {
                if (gwElem.type == "BOM") {
                    quantityGwSpareParts += gwElem.quantitySelected;
                    totalPriceGwSpareParts += gwElem.pru * gwElem.quantitySelected;
                } else if (gwElem.type == "PROD") {
                    quantityGwProducts += gwElem.quantitySelected;
                }
            }
        }
        this.totalPriceBom = totalPriceBom;
        this.quantityBomSpareParts = quantityBomSpareParts;
        this.totalPriceGwSpareParts = totalPriceGwSpareParts;
        this.quantityGwSpareParts = quantityGwSpareParts;
        this.quantityGwProducts = quantityGwProducts;
    }

    @api
    closeModal() {
        this.isModalOpened = false;
    }

    stopClick(event) {
        event.stopPropagation();
    }

    confirmSendOrder() {
        this.callBackProductChosen();
        this.closeModal();
    }
}
