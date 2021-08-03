import { api, LightningElement } from "lwc";

export default class Woo_freeOrderAgoraErrorLine extends LightningElement {
    /**
     * @type {ValidationError}
     */
    @api
    errorLine;

    get lineClass() {
        if (this.errorLine && this.errorLine.messageType === "E") {
            return "slds-text-color_error";
        } else {
            return "warning-color";
        }
    }
}
