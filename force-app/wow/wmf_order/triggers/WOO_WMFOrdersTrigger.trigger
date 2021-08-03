trigger WOO_WMFOrdersTrigger on WOO_WMF_Orders__c(
    before update,
    before insert,
    after update,
    after insert,
    before delete,
    after delete,
    after undelete
) {
    new WOO_WMFOrdersTriggerHandler().run();
}