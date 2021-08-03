import { api, LightningElement, track, wire } from "lwc";
import addresses from "@salesforce/apex/WOO_freeOrderAgoraFormController.addresses";
import { errorHandler, showErrorToast, errorMessage } from "c/woo_freeOrderAgoraSharedJs";
import channelWooFreeOrderAgora__c from "@salesforce/messageChannel/channelWooFreeOrderAgora__c";
import channelWooFreeOrderAgoraRefreshAddress__c from "@salesforce/messageChannel/channelWooFreeOrderAgoraRefreshAddress__c";
import {
    publish,
    MessageContext,
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE
} from "lightning/messageService";
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import COUNTRY_CODE from "@salesforce/schema/Consumer_Address__c.CountryCode__c";
import OBJECT_CONSUMER_ADDRESS from "@salesforce/schema/Consumer_Address__c";

import ALLLoading from "@salesforce/label/c.ALLLoading";
import AgoraOrder_Addr_CardTitle from "@salesforce/label/c.AgoraOrder_Addr_CardTitle";
import AgoraOrder_Addr_PicklistLabel from "@salesforce/label/c.AgoraOrder_Addr_PicklistLabel";
import AgoraOrder_Addr_OtherAddr from "@salesforce/label/c.AgoraOrder_Addr_OtherAddr";
import AgoraOrder_Addr_MainAddr from "@salesforce/label/c.AgoraOrder_Addr_MainAddr";
import AgoraOrder_Addr_SecondaryAddr from "@salesforce/label/c.AgoraOrder_Addr_SecondaryAddr";
import AgoraOrder_Addr_ErrorRequiredField from "@salesforce/label/c.AgoraOrder_Addr_ErrorRequiredField";
import AgoraOrder_Valid_Tooltip from "@salesforce/label/c.AgoraOrder_Valid_Tooltip";
import AgoraOrder_Invalid_Tooltip from "@salesforce/label/c.AgoraOrder_Invalid_Tooltip";

export default class Woo_freeOrderAgoraAddress extends LightningElement {
    isLoading = false;
    @track
    labels = {
        ALLLoading,
        AgoraOrder_Addr_CardTitle,
        AgoraOrder_Addr_PicklistLabel,
        AgoraOrder_Addr_OtherAddr,
        AgoraOrder_Addr_MainAddr,
        AgoraOrder_Addr_SecondaryAddr,
        AgoraOrder_Addr_ErrorRequiredField,
        AgoraOrder_Valid_Tooltip,
        AgoraOrder_Invalid_Tooltip
    };

    @wire(MessageContext)
    messageContext;

    @wire(getObjectInfo, { objectApiName: OBJECT_CONSUMER_ADDRESS })
    wiringAdressMetadata({ error, data }) {
        if (!data) {
            return;
        }
        this.labels.city = data.fields["City__c"].label;
        this.labels.country = data.fields["CountryCode__c"].label;
        this.labels.province = data.fields["State_Province__c"].label;
        this.labels.postalCode = data.fields["PostalCode__c"].label;
        this.labels.street = data.fields["Street__c"].label;
        this.metadataObjConsumerAddress = data;
    }

    metadataObjConsumerAddress;

    @wire(getPicklistValues, {
        fieldApiName: COUNTRY_CODE,
        recordTypeId: "$metadataObjConsumerAddress.defaultRecordTypeId"
    })
    picklistValuesCountryCode;

    get countryOptions() {
        return (
            this.picklistValuesCountryCode &&
            this.picklistValuesCountryCode.data &&
            this.picklistValuesCountryCode.data.values
        );
    }

    @api recordId;

    /**
     * @type {{label:string; value:string}[]}
     */
    @track
    addressPicklist = [];

    /**
     * @type {string | null | undefined}
     */
    @track
    errorMessage;

    /**
     * @type {{[key:string]:Consumer_Address__c}}
     */
    addressMap = {};

    /**
     * @type {AddressPicked}
     */
    @track
    addressPicked = {
        disabled: true,
        isValid: false
    };
    @track
    iconAddress = {
        name: "utility:error",
        variant: "error",
        title: AgoraOrder_Invalid_Tooltip,
        setValidity(isValid) {
            if (isValid) {
                this.name = "utility:check";
                this.variant = "success";
                this.title = AgoraOrder_Valid_Tooltip;
            } else {
                this.name = "utility:error";
                this.variant = "error";
                this.title = AgoraOrder_Invalid_Tooltip;
            }
        }
    };

    goToAddressCmp() {
        const header = document.querySelector('[data-id="address-header"]');
        if (header) {
            header.focus();
        }
    }

    publishAddress() {
        this.checkAddrValidity();
        if (this.addressPicked) {
            const message = {
                addressPicked: JSON.parse(JSON.stringify(this.addressPicked))
            };
            publish(this.messageContext, channelWooFreeOrderAgora__c, message);
        }
    }

    subscribeToRefreshMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                channelWooFreeOrderAgoraRefreshAddress__c,
                () => {
                    this.publishAddress();
                },
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    unsubscribeToRefreshMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    connectedCallback() {
        this.isLoading = true;
        this.subscribeToRefreshMessageChannel();
        addresses({ orderId: this.recordId })
            .then(
                (
                    /**
                     * @type {Consumer_Address__c[]}
                     */
                    addresses
                ) => {
                    let addressPicklist = [];
                    for (const address of addresses) {
                        this.addressMap[address.Id] = address;
                        addressPicklist.push({
                            value: address.Id,
                            label: address.Label__c
                        });
                        if (address.MainAddress__c) {
                            //@ts-ignore
                            const addrPicklist = this.template.querySelector(
                                "lightning-combobox.address-picker"
                            );
                            addrPicklist.value = address.Id;
                            setTimeout(() => {
                                // safe async assumption
                                this.changedSelectAdr({ detail: { value: address.Id } });
                            }, 200);
                        }
                    }
                    this.addressMap["OTHER"] = {};
                    addressPicklist.push({
                        value: "OTHER",
                        label: this.labels.AgoraOrder_Addr_OtherAddr
                    });
                    this.addressPicklist = addressPicklist;
                }
            )
            .catch((error) => {
                this.errorMessage = errorMessage(error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    disconnectedCallback() {
        this.unsubscribeToRefreshMessageChannel();
    }

    checkAddrValidity() {
        const addrCmp = this.template.querySelector("lightning-input-address");
        const requiredFields = ["country", "street", "city", "postalCode"];
        this.addressPicked.isValid = true;
        for (const requiredField of requiredFields) {
            if (!this.addressPicked[requiredField]) {
                addrCmp.setCustomValidityForField(
                    this.labels.AgoraOrder_Addr_ErrorRequiredField,
                    requiredField
                );
                this.addressPicked.isValid = false;
            } else {
                addrCmp.setCustomValidityForField("", requiredField);
            }
        }
        addrCmp.reportValidity();
        this.iconAddress.setValidity(this.addressPicked.isValid);
    }

    handleAddrChange(event) {
        this.addressPicked.city = event.detail.city;
        this.addressPicked.street = event.detail.street;
        this.addressPicked.country = event.detail.country;
        this.addressPicked.postalCode = event.detail.postalCode;
        this.publishAddress();
    }

    /* -------------------------------------------------------------------------- */
    /*                                    sepa                                    */
    /* -------------------------------------------------------------------------- */
    changedSelectAdr(event) {
        const selectedVal = event.detail.value;
        if (selectedVal == "OTHER") {
            this.addressPicked = {
                title: this.labels.AgoraOrder_Addr_OtherAddr,
                street: "",
                city: "",
                postalCode: "",
                country: "",
                disabled: false,
                showAddressLookup: true
            };
        } else {
            const addr = this.addressMap[selectedVal];
            const buildStreet = (addr) => {
                const street = [addr.Ligne_1__c, addr.Ligne_2__c, addr.Ligne_3__c]
                    .filter((field) => !!field)
                    .join("\n");
                return street;
            };
            this.addressPicked = {
                title: addr.AddressTitle__c,
                street: buildStreet(addr),
                city: addr.City__c,
                postalCode: addr.PostalCode__c,
                country: addr.CountryCode__c,
                disabled: false,
                showAddressLookup: false
            };
        }
        this.publishAddress();
    }
}
