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
        System.assertEquals(false, linf.isDateTime);
        System.assertEquals(false, linf.isLookup);
        System.assertEquals(false, linf.isDateTime);
        System.assertEquals('Survey__c', linf.objectName);
    }
    @isTest
    private static void doTest_getFieldDescribe(){
        LexInputFieldCompCtrl linf = new LexInputFieldCompCtrl();

        System.assertEquals(null, linf.getFieldDescribe());
        System.assertEquals('', linf.objectName);
    }
    @isTest
    private static void doTest_isLookup(){
        LexInputFieldCompCtrl linf = new LexInputFieldCompCtrl();
        linf.inputObject = (sObject)new Survey__c();
        linf.fieldName = 'OwnerId';

        System.assertEquals(true, linf.isLookup);
        System.assertEquals('Lookup', linf.fieldType);
    }
    @isTest
    private static void doTest_textArea(){
        LexInputFieldCompCtrl linf = new LexInputFieldCompCtrl();
        linf.inputObject = (sObject)new Survey__c();
        linf.fieldName = 'Thank_You_Text__c';

        System.assertEquals(true, linf.isTextarea);
        System.assertEquals('TextArea', linf.fieldType);
    }
    @isTest
    private static void doTest_notIsInput(){
        LexInputFieldCompCtrl linf = new LexInputFieldCompCtrl();
        linf.inputObject = (sObject)new Survey__c();
        linf.fieldName = 'CreatedDate';

        System.assertNotEquals(true, linf.isInput);
        System.assertNotEquals('Input', linf.fieldType);
    }
    @isTest
    private static void doTest_isCheckbox(){
        LexInputFieldCompCtrl linf = new LexInputFieldCompCtrl();
        linf.inputObject = (sObject)new Survey__c();
        linf.fieldName = 'Hide_Survey_Name__c';

        System.assertEquals(true, linf.isCheckbox);
        System.assertEquals('Checkbox', linf.fieldType);
    }
    @isTest
    private static void doTest_isDateTime(){
        LexInputFieldCompCtrl linf = new LexInputFieldCompCtrl();
        linf.inputObject = (sObject)new Survey__c();
        linf.fieldName = 'CreatedDate';

        System.assertEquals(true, linf.isDateTime);
        System.assertEquals('DateTime', linf.fieldType);
    }

    @isTest
    private static void doTest_isPicklist(){
        LexInputFieldCompCtrl linf = new LexInputFieldCompCtrl();
        linf.inputObject = (sObject)new Account();
        linf.fieldName = 'Type';

        System.assertEquals(true, linf.isPicklist);
        System.assertEquals('Picklist', linf.fieldType);
    }
}