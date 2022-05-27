@isTest
private class GSurveysController_Test {
	@IsTest
	private static void testGSurveysControllerExisting() {
		SurveyTestingUtil tu = new SurveyTestingUtil();

		Test.setCurrentPage(Page.GSurveys);
		//Survey__c s = new Survey__c(Name = 'test survey');
		Apexpages.Standardcontroller stc = new ApexPages.StandardController(tu.survey);
		GSurveysController sc = new GSurveysController(stc);
		System.assertNotEquals(null, sc.onLoad());
		System.assertEquals(null, sc.pageMessage.message);
	}

	@IsTest
	private static void testGSurveysControllerNew() {
		//SurveyTestingUtil tu = new SurveyTestingUtil();

		Test.setCurrentPage(Page.GSurveys);
		Survey__c s = new Survey__c(Name = 'test survey');
		Apexpages.Standardcontroller stc = new ApexPages.StandardController(s);
		GSurveysController sc = new GSurveysController(stc);
		System.assertEquals(null, sc.onLoad());
		sc.getHasExistingSite();
		String saveUrl = sc.save().getUrl();

		String surveyUrl = '/apex/SurveyManagerPage?id=' + sc.survey.Id;
		System.assertEquals(surveyUrl.toLowerCase(), saveUrl.toLowerCase());

		List<Survey__c> listSurveys = [SELECT Id FROM Survey__c WHERE Name = 'test survey'];
		System.assertEquals(1, listSurveys.size());

		System.assertEquals(null, sc.pageMessage.message);
	}

	@IsTest
	private static void testGSurveysControllerError() {
		Test.setCurrentPage(Page.GSurveys);
		Survey__c s = new Survey__c();
		Apexpages.Standardcontroller stc = new ApexPages.StandardController(s);
		GSurveysController sc = new GSurveysController(stc);
		System.assertEquals(null, sc.onLoad());
		sc.survey.Name = null;
		PageReference pr = sc.save();
		System.assertEquals(null, pr);
	}
}