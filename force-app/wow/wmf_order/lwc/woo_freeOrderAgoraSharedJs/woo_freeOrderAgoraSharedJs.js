//@ts-ignore
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import AgoraOrder_Error from "@salesforce/label/c.AgoraOrder_Error";

const labels = {
    AgoraOrder_Error,
};

export class ToastError extends Error {
    constructor(message) {
        super(message);
        this.name = "ToastError";
    }
}

const errorMessage = (error) => {
    let message = "Technical Error";
    if (error instanceof ToastError) {
        message = error.message;
    } else if (Array.isArray(error.body)) {
        message = error.body.map((e) => e.message).join(", ");
    } else if (error.body && typeof error.body.message === "string") {
        message = error.body.message;
    } else {
        console.error(error);
    }
    return message;
};
const errorHandler = (error, thisCmp) => {
    showErrorToast(errorMessage(error), thisCmp);
};
const showErrorToast = (
    /**
     * @type {string}
     */ message,
    thisCmp,
    /**
     * @type {null | {
     *      title?: String;
     *      message?: String;
     *      messageData?: String[] | Object;
     *      variant?: "info" | "success" | "warning" | "error";
     *      mode?: "dismissible" | "pester" | "sticky";
     *   }}
     */ overrideOptions
) => {
    //@ts-ignore
    let options = {
        title: labels.AgoraOrder_Error,
        message,
        variant: "error",
    };
    if (overrideOptions) {
        options = {
            ...options,
            ...overrideOptions,
        };
    }
    thisCmp.dispatchEvent(new ShowToastEvent(options));
};
/** @typedef{ typeof errorHandler} ErrorHandler  */
export { errorHandler, showErrorToast, errorMessage };
