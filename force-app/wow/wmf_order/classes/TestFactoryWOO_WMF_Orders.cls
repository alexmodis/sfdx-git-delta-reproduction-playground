public class TestFactoryWOO_WMF_Orders implements TestFactory.FieldDefaults {
    public Map<Schema.SObjectField, Object> getFieldDefaults() {
        return new Map<Schema.SObjectField, Object>{
            WOO_WMF_Orders__c.WOO_Order_Type__c => 'Finished products',
            WOO_WMF_Orders__c.WOO_Requested_delivery_date__c => Datetime.now().addDays(7)
        };
    }

    public Map<Schema.SObjectField, Object> getFieldDefaultsForMetaData(String masterLabel) {
        throw new TestFactory.TestFactoryException(
            'You cannot build an order by calling a custom metadata.'
        );
    }
}