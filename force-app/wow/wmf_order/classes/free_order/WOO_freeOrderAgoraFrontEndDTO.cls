@SuppressWarnings('PMD.ExcessivePublicCount')
public without sharing class WOO_freeOrderAgoraFrontEndDTO {
    /* -------------------------------------------------------------------------- */
    /*                                product list                                */
    /* -------------------------------------------------------------------------- */

    public class AgoraProductResult {
        @AuraEnabled
        public String referenceCommercial { get; set; }
        @AuraEnabled
        public String referenceTechnique { get; set; }
        @AuraEnabled
        public String name { get; set; }
        @AuraEnabled
        public String version { get; set; }
        @AuraEnabled
        public String manufactoryDate { get; set; }
        @AuraEnabled
        public String brand { get; set; }
        @AuraEnabled
        public String agoraKey { get; set; }
    }

    /* -------------------------------------------------------------------------- */
    /*                                  BOM list                                  */
    /* -------------------------------------------------------------------------- */

    public enum RowType {
        BOM,
        PROD
    }
    public class TableRow {
        @AuraEnabled
        public String name { get; set; }
        @AuraEnabled
        public String reference { get; set; }
        @AuraEnabled
        public String sfProductId { get; set; } // for 'PROD'
        @AuraEnabled
        public Integer quantity { get; set; }
        @AuraEnabled
        public Integer quantitySelected { get; set; }
        @AuraEnabled
        public Boolean availability { get; set; }
        @AuraEnabled
        public String deliveryDelay { get; set; }
        @AuraEnabled
        public Double pru { get; set; } // prix de revien unitaire for 'BOM'
        @AuraEnabled
        public String type { get; set; } // 'BOM' | 'PROD'
    }

    /* -------------------------------------------------------------------------- */
    /*                               sf product list                              */
    /* -------------------------------------------------------------------------- */
    public class SfProduct {
        @AuraEnabled
        public String sfId { get; set; }
        @AuraEnabled
        public String longRef { get; set; }
        @AuraEnabled
        public String cmmf { get; set; }
        @AuraEnabled
        public String name { get; set; }
        @AuraEnabled
        public String brand { get; set; }
        @AuraEnabled
        public String universe { get; set; }
        @AuraEnabled
        public String subFamily { get; set; }
        @AuraEnabled
        public String country { get; set; }
    }

    /* -------------------------------------------------------------------------- */
    /*                             SubOrders and Lines                            */
    /* -------------------------------------------------------------------------- */
    public class SubOrdersAndLines {
        @AuraEnabled
        public List<WOO_WMF_Order_Line_Item__c> mainOrderLines { get; set; }
        @AuraEnabled
        public List<WOO_WMF_Orders__c> subOrdersAndLines { get; set; }
    }

    /* -------------------------------------------------------------------------- */
    /*                                  addresses                                 */
    /* -------------------------------------------------------------------------- */
    public class Address {
        @AuraEnabled
        public String title { get; set; }
        @AuraEnabled
        public String street { get; set; }
        @AuraEnabled
        public String city { get; set; }
        @AuraEnabled
        public String country { get; set; }
        @AuraEnabled
        public String postalCode { get; set; }
    }

    /* -------------------------------------------------------------------------- */
    /*                                 Send Repair                                */
    /* -------------------------------------------------------------------------- */

    public class SendOrderBase {
        @AuraEnabled
        public Id mainOrderId { get; set; }
        @AuraEnabled
        public WOO_freeOrderAgoraFrontEndDTO.Address consumerAddress { get; set; }
        @AuraEnabled
        public String cccGroup { get; set; }
    }

    public class SendOrderMain {
        @AuraEnabled
        public WOO_freeOrderAgoraFrontEndDTO.AgoraProductResult orderProduct { get; set; }
        @AuraEnabled
        public List<WOO_freeOrderAgoraFrontEndDTO.TableRow> bomList { get; set; }
    }

    public class SendRepairGoodwillSpareParts {
        @AuraEnabled
        public WOO_freeOrderAgoraFrontEndDTO.AgoraProductResult orderProduct { get; set; }
        @AuraEnabled
        public List<WOO_freeOrderAgoraFrontEndDTO.TableRow> goodwillSpareParts { get; set; }
    }

    public class SendRepairGoodwillProduct {
        @AuraEnabled
        public WOO_freeOrderAgoraFrontEndDTO.TableRow goodwillProduct { get; set; }
    }

    public class ValidationErrorFront {
        @AuraEnabled
        public String field { get; set; }
        @AuraEnabled
        public String errorMessage { get; set; }
        @AuraEnabled
        public String messageType { get; set; }
    }

    public class CreateRepairFrontResponse {
        public CreateRepairFrontResponse() {
            this.validationErrors = new List<ValidationErrorFront>();
        }
        @AuraEnabled
        public Boolean isValid { get; set; }
        @AuraEnabled
        public List<ValidationErrorFront> validationErrors { get; set; }
        @AuraEnabled
        public String errorMessage { get; set; }
    }
}