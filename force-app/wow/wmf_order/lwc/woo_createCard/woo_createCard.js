import { LightningElement, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getFieldValue, getRecord } from "lightning/uiRecordApi";
import { updateRecord } from "lightning/uiRecordApi";

import ACCOUNT_ADDRESS_STREET from "@salesforce/schema/WOO_WMF_Orders__c.WOO_Case__r.Account.PersonMailingStreet";
import ACCOUNT_ADDRESS_POSTALCODE from "@salesforce/schema/WOO_WMF_Orders__c.WOO_Case__r.Account.PersonMailingPostalCode";
import ACCOUNT_ADDRESS_TOWN from "@salesforce/schema/WOO_WMF_Orders__c.WOO_Case__r.Account.PersonMailingCity";

import ORDER_STATUS from "@salesforce/schema/WOO_WMF_Orders__c.WOO_SAP_status__c";
import ORDER_TYPE from "@salesforce/schema/WOO_WMF_Orders__c.WOO_Order_Type__c";
import ID_FIELD from "@salesforce/schema/WOO_WMF_Orders__c.Id";
import SUBMISSION_DATE from "@salesforce/schema/WOO_WMF_Orders__c.WOO_Agora_Submission_Datetime__c";

import getSimulate from "@salesforce/apex/WOO_orderCardController.getSimulateCall";
import setAddress from "@salesforce/apex/WOO_orderCardController.setAddress";

export default class woo_simulateOrchestration extends LightningElement {
    loaded = true;
    @api recordId;
    @wire(getRecord, {
        recordId: "$recordId",
        fields: [
            ACCOUNT_ADDRESS_STREET,
            ACCOUNT_ADDRESS_POSTALCODE,
            ACCOUNT_ADDRESS_TOWN,
            ORDER_STATUS,
            ORDER_TYPE,
        ],
    })
    WOO_WMF_Orders__c;

    get isSimulateVisible() {
        return getFieldValue(this.WOO_WMF_Orders__c.data, ORDER_TYPE) !== "Repair";
    }

    get isCreateVisible() {
        return (
            getFieldValue(this.WOO_WMF_Orders__c.data, ORDER_STATUS) === "Simulated OK" ||
            getFieldValue(this.WOO_WMF_Orders__c.data, ORDER_TYPE) === "Repair"
        );
    }

    updateRecordView(recordId) {
        updateRecord({ fields: { Id: recordId } });
    }

    simulate() {
        this.loaded = false;
        console.log("Simulate");
        console.log(this.recordId);

        var isAddressValid = this.isAccountAddressValid();
        console.log(isAddressValid);

        if (!isAddressValid) {
            return;
        }

        getSimulate({ orderId: this.recordId })
            .then((result) => {
                console.log("return getSimulate with success");
                this.loaded = true;
                eval("$A.get('e.force:refreshView').fire();");
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error during SAP call",
                        message: error.body.message,
                        variant: "error",
                    })
                );
                this.loaded = true;
                eval("$A.get('e.force:refreshView').fire();");
            });
    }

    create() {
        this.loaded = false;
        console.log("create");
        // Create the recordInput object
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[ORDER_STATUS.fieldApiName] = "Ready to be sent";
        fields[SUBMISSION_DATE.fieldApiName] = new Date().toJSON();

        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success",
                        message: "Order updated",
                        variant: "success",
                    })
                );
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error updating record",
                        message: error.body.output.errors[0].message,
                        variant: "error",
                    })
                );
            });
        this.loaded = true;
        this.updateRecordView(this.recordId);
    }

    synchronizeAccount() {
        var isAddressValid = this.isAccountAddressValid();
        console.log(isAddressValid);

        if (!isAddressValid) {
            return;
        }
        setAddress({ orderId: this.recordId })
            .then((result) => {
                eval("$A.get('e.force:refreshView').fire();");
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error Synchronizing address",
                        message: error,
                        variant: "error",
                    })
                );
                eval("$A.get('e.force:refreshView').fire();");
            });
    }

    /* -------------------------------------------------------------------------- */
    /*                                    Utils                                   */
    /* -------------------------------------------------------------------------- */

    isAccountAddressValid() {
        var result = true;

        console.log(
            "ACCOUNT_ADDRESS_STREET: ",
            getFieldValue(this.WOO_WMF_Orders__c.data, ACCOUNT_ADDRESS_STREET)
        );

        if (
            getFieldValue(this.WOO_WMF_Orders__c.data, ACCOUNT_ADDRESS_STREET) == null ||
            getFieldValue(this.WOO_WMF_Orders__c.data, ACCOUNT_ADDRESS_POSTALCODE) == null ||
            getFieldValue(this.WOO_WMF_Orders__c.data, ACCOUNT_ADDRESS_TOWN) == null
        ) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error with account address",
                    message: "The account must have an address, postal code and town",
                    variant: "error",
                })
            );

            result = false;
        }
        return result;
    }
}
