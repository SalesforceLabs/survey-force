@isTest
private class GSurveysController_Test {

    private static TestMethod void testGSurveysController(){
        SurveyTestingUtil tu = new SurveyTestingUtil();

        Survey__c s = new Survey__c(Name = 'test survey');
        Apexpages.Standardcontroller stc = new ApexPages.StandardController(s);
        GSurveysController sc = new GSurveysController(stc);
        String saveUrl = sc.save().getUrl();

        String surveyUrl = '/apex/SurveyManagerPage?id='+sc.survey.Id;
        System.assertEquals(surveyUrl, saveUrl);

        List<Survey__c> listSurveys = [select id from survey__c where name='test survey'];
        System.assertEquals(listSurveys.size(), 1);

        System.assertEquals(null, sc.pageMessage.message);
    }

}