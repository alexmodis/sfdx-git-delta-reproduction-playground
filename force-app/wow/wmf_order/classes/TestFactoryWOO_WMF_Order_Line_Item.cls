public class TestFactoryWOO_WMF_Order_Line_Item implements TestFactory.FieldDefaults {
    public Map<Schema.SObjectField, Object> getFieldDefaults() {
        return new Map<Schema.SObjectField, Object>{};
    }

    public Map<Schema.SObjectField, Object> getFieldDefaultsForMetaData(String masterLabel) {
        throw new TestFactory.TestFactoryException(
            'You cannot build an order line item by calling a custom metadata.'
        );
    }
}