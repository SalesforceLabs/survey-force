@istest
private class ViewSurveyController_Test{
    private static Testmethod void testViewSurveyController_consutructor3() {
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Contact c = new Contact();
        c.FirstName = 'John';
        c.LastName = 'Doe';
        insert c;
        
        Apexpages.currentPage().getParameters().put('id',tu.surveyId);
        Apexpages.currentPage().getParameters().put('cId',c.Id);
        Apexpages.Standardcontroller stc;
        viewShareSurveyComponentController vscc = new viewShareSurveyComponentController();
        ViewSurveyController vsc = new ViewSurveyController(vscc); 
        vsc.init();
        
        System.assert(vsc.allQuestionsSize == 4);
        System.assert(tu.surveyId != null);
		System.assertEquals('/apex/ResultsPage?id='+tu.surveyId, vsc.resultPage().getUrl());

        for (SFQuestion q : vsc.allQuestions)
        {
            q.selectedOption = String.valueof(2);
            q.choices = String.valueof(2);
            q.selectedOptions = new List<String>();
            q.selectedOptions.add(String.valueof(2));
            vsc.submitResults();
        }
        System.assertEquals(true, vsc.thankYouRendered);


        //Run again to hit an exception for code coverage
        //There is no return value as this is void method 
        List<SurveyTaker__c> check = [Select Contact__c, Survey__c, Case__c, User__c From SurveyTaker__c Where Survey__c=:tu.surveyId and 
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
        
        check = [Select Contact__c, Survey__c, Case__c, User__c From SurveyTaker__c Where Survey__c=:tu.surveyId and 
                                              ((Contact__c != null and Contact__c=:c.Id))];
        System.debug('Check:' + check);
        
        //test something
    }
    
    @istest
    private static void testgetResponses(){
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id',tu.surveyId);
        Apexpages.Standardcontroller stc;
        ViewSurveyController vsc = new ViewSurveyController(stc); 
        vsc.init();
        List<String> responses = vsc.getResponses();
        System.debug(responses);
        
    }
    
    private static Testmethod void testViewSurveyController_consutructor2() {
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id',tu.surveyId);
        Apexpages.Standardcontroller stc;
        viewShareSurveyComponentController vscc = new viewShareSurveyComponentController();
        ViewSurveyController vsc = new ViewSurveyController(vscc); 
        vsc.init();
        System.assert(vsc.allQuestionsSize == 4);
        System.assert(tu.surveyId != null);
		System.assertEquals('/apex/ResultsPage?id='+tu.surveyId, vsc.resultPage().getUrl());

        vsc.submitResults();
        for (SFQuestion q : vsc.allQuestions)
        {
            q.selectedOption = String.valueof(2);
            q.choices = String.valueof(2);
            q.selectedOptions = new List<String>();
            q.selectedOptions.add(String.valueof(2));
            vsc.submitResults();
        }
        System.assertEquals(true, vsc.thankYouRendered);


        //test something
    }
    
    private static Testmethod void testViewSurveyController() {
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id',tu.surveyId);
        Apexpages.Standardcontroller stc;
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
        System.assertEquals(true, vsc.thankYouRendered);


        //test something
    }


    private static Testmethod void testUpdateSurveyName() {
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id',tu.surveyId);
        Apexpages.Standardcontroller stc;
        ViewSurveyController vsc = new ViewSurveyController(stc);
        vsc.surveyName = 'new name';
        system.assert(vsc.updateSurveyName() == null);

    }


    private static Testmethod void testupdateSurveyThankYouAndLink() {
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id',tu.surveyId);
        Apexpages.Standardcontroller stc;
        ViewSurveyController vsc = new ViewSurveyController(stc);
        vsc.surveyThankYouText = 'new stuff';
        vsc.surveyThankYouURL = 'more new stff';
        system.assert(vsc.updateSurveyThankYouAndLink()==null);
    }

    
    private static Testmethod void testrefreshQuestionList() {
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id',tu.surveyId);
        Apexpages.Standardcontroller stc;
        ViewSurveyController vsc = new ViewSurveyController(stc);
        system.assert(vsc.refreshQuestionList() == null);
    }
	/**/

}