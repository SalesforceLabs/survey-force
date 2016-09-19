@isTest
private class LexInputFieldCompCtrl_Test {
    @isTest
    private static void doTest(){
        LexInputFieldCompCtrl linf = new LexInputFieldCompCtrl();
        linf.inputObject = (sObject)new Survey__c();
        linf.fieldName = 'Name';

        System.assertEquals(false, linf.isReadOnly);
        System.assertEquals(true, linf.isInput);
        System.assertEquals(false, linf.isTextarea);
        System.assertEquals(false, linf.isMultiPicklist);
        System.assertEquals(false, linf.isPicklist);
        System.assertEquals(false, linf.isCheckbox);
        System.assertEquals(false, linf.isDatetime);
        System.assertEquals(false, linf.isLookup);
        System.assertEquals(false, linf.isDatetime);
        System.assertEquals('Survey__c', linf.objectName);
    }
}