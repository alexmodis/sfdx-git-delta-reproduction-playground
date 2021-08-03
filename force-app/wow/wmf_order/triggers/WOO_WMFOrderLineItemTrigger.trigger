trigger WOO_WMFOrderLineItemTrigger on WOO_WMF_Order_Line_Item__c(
    before update,
    before insert,
    after update,
    after insert,
    before delete,
    after delete,
    after undelete
) {
    new WOO_WMFOrdersLineItemTriggerHandler().run();
}