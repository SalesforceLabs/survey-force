@isTest
private class GSurveysController_Test {

    private static TestMethod void testGSurveysController(){
        SurveyTestingUtil tu = new SurveyTestingUtil();

		Test.setCurrentPage(Page.GSurveys);
        Survey__c s = new Survey__c(Name = 'test survey');
        Apexpages.Standardcontroller stc = new ApexPages.StandardController(s);
        GSurveysController sc = new GSurveysController(stc);
		sc.getHasExistingSite();
        String saveUrl = sc.save().getUrl();

        String surveyUrl = '/apex/SurveyManagerPage?id=' + sc.survey.Id;
        System.assertEquals(surveyUrl.toLowerCase(), saveUrl.toLowerCase());

        List<Survey__c> listSurveys = [SELECT Id from Survey__c WHERE name='test survey'];
        System.assertEquals(1, listSurveys.size());

        System.assertEquals(null, sc.pageMessage.message);

        System.assertNotEquals(null, sc.onLoad());
    }

}