@istest
private class ViewSurveyController_Test{

    @TestSetup
    static void makeData(){
        List<PermissionSet> pslist = [SELECT Id FROM PermissionSet WHERE Name LIKE 'Survey%'];
        List<PermissionSetAssignment> psalist = new List<PermissionSetAssignment>();
        for(PermissionSet p : pslist){
            psalist.add(new PermissionSetAssignment(PermissionSetId = p.Id, AssigneeId = UserInfo.getUserId()));
        }
        Database.insert(psalist, false);
    }
    private static Testmethod void testViewSurveyController_consutructor3() {
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Contact c = new Contact();
        c.FirstName = 'John';
        c.LastName = 'Doe';
        insert c;

        Apexpages.currentPage().getParameters().put('id',tu.surveyId);
        Apexpages.currentPage().getParameters().put('cId',c.Id);
        Apexpages.Standardcontroller stc;
        ViewShareSurveyComponentController vscc = new ViewShareSurveyComponentController();
        ViewSurveyController vsc = new ViewSurveyController(vscc);
        vsc.init();

        System.assert(vsc.allQuestionsSize == 4);
        System.assert(tu.surveyId != null);

        for (SFQuestion q : vsc.allQuestions)
        {
            q.selectedOption = String.valueof(2);
            q.choices = String.valueof(2);
            q.selectedOptions = new List<String>();
            q.selectedOptions.add(String.valueof(2));
            vsc.submitResults();
        }
        System.assertEquals(true, vsc.ThankYouRendered);


        //Run again to hit an exception for code coverage
        //There is no return value as this is void method
        List<SurveyTaker__c> check = [SELECT Contact__c, Survey__c, Case__c, User__c From SurveyTaker__c Where Survey__c=:tu.surveyId and
                                              ((Contact__c != null and Contact__c=:c.Id))];
        System.debug('Check:' + check);

        vsc.init();
        for (SFQuestion q : vsc.allQuestions)
        {
            q.selectedOption = String.valueof(2);
            q.choices = String.valueof(2);
            q.selectedOptions = new List<String>();
            q.selectedOptions.add(String.valueof(2));
            vsc.submitResults();
        }

        check = [SELECT Contact__c, Survey__c, Case__c, User__c From SurveyTaker__c Where Survey__c=:tu.surveyId and
                                              ((Contact__c != null and Contact__c=:c.Id))];
        System.debug('Check:' + check);

        //test something
    }

    @istest
    private static void testgetResponses(){
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id',tu.surveyId);
        Survey__c s = new Survey__c();
        Apexpages.Standardcontroller stc = new ApexPages.StandardController(s);
        ViewSurveyController vsc = new ViewSurveyController(stc);
        vsc.init();
        List<String> responses = vsc.getResponses();
        System.debug(responses);

    }

    private static Testmethod void testViewSurveyController_consutructor2() {
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id',tu.surveyId);
        Apexpages.Standardcontroller stc;
        ViewShareSurveyComponentController vscc = new ViewShareSurveyComponentController();
        ViewSurveyController vsc = new ViewSurveyController(vscc);
        vsc.init();
        System.assert(vsc.allQuestionsSize == 4);
        System.assert(tu.surveyId != null);

        vsc.submitResults();
        for (SFQuestion q : vsc.allQuestions)
        {
            q.selectedOption = String.valueof(2);
            q.choices = String.valueof(2);
            q.selectedOptions = new List<String>();
            q.selectedOptions.add(String.valueof(2));
            vsc.submitResults();
        }
        System.assertEquals(true, vsc.ThankYouRendered);


        //test something
    }

    private static Testmethod void testViewSurveyController() {
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id',tu.surveyId);
        Survey__c s = new Survey__c();
        Apexpages.Standardcontroller stc = new ApexPages.StandardController(s);
        ViewSurveyController vsc = new ViewSurveyController(stc);
        vsc.init();
        System.assert(vsc.allQuestionsSize == 4);
        System.assert(tu.surveyId != null);


        vsc.submitResults();
        for (SFQuestion q : vsc.allQuestions)
        {
            q.selectedOption = String.valueof(2);
            q.choices = String.valueof(2);
            q.selectedOptions = new List<String>();
            q.selectedOptions.add(String.valueof(2));
            vsc.submitResults();
        }
        System.assertEquals(true, vsc.ThankYouRendered);


        //test something
    }


    private static Testmethod void testUpdateSurveyName() {
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id',tu.surveyId);
        Survey__c s = new Survey__c();
        Apexpages.Standardcontroller stc = new ApexPages.StandardController(s);
        ViewSurveyController vsc = new ViewSurveyController(stc);
        vsc.surveyName = 'new name';
        system.assert(vsc.updateSurveyName() == null);

    }


    private static Testmethod void testupdateSurveyThankYouAndLink() {
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id',tu.surveyId);
        Survey__c s = new Survey__c();
        Apexpages.Standardcontroller stc = new ApexPages.StandardController(s);
        ViewSurveyController vsc = new ViewSurveyController(stc);
        vsc.surveyThankYouText = 'new stuff';
        vsc.surveyThankYouURL = 'more new stff';
        system.assert(vsc.updateSurveyThankYouAndLink()==null);
    }


    private static Testmethod void testrefreshQuestionList() {
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id',tu.surveyId);
        Survey__c s = new Survey__c();
        Apexpages.Standardcontroller stc = new ApexPages.StandardController(s);
        ViewSurveyController vsc = new ViewSurveyController(stc);
        system.assert(vsc.refreshQuestionList() == null);
    }
	/**/

}