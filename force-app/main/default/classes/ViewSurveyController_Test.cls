@IsTest
private class ViewSurveyController_Test{

	@TestSetup
	static void makeData(){
		User u = SurveyTestingUtil.createNewAdminPermissionSetUser();
	}

	@IsTest
	private static void testViewSurveyController_constructor3() {
		User u = [SELECT Id FROM User WHERE Username LIKE '%@testorg.com' LIMIT 1];
		System.runAs(u){
			SurveyTestingUtil tu = new SurveyTestingUtil();
			Contact c = new Contact();
			c.FirstName = 'John';
			c.LastName = 'Doe';
			insert c;

			Test.startTest();

			Test.setCurrentPage(Page.TakeSurvey);

			Apexpages.currentPage().getParameters().put('id',tu.surveyId);
			Apexpages.currentPage().getParameters().put('cId',c.Id);
			Apexpages.Standardcontroller std = new ApexPages.StandardController(tu.survey);
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
			List<SurveyTaker__c> check = [SELECT Contact__c, Survey__c, Case__c, User__c FROM SurveyTaker__c Where Survey__c=:tu.surveyId and
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

			check = [SELECT Contact__c, Survey__c, Case__c, User__c FROM SurveyTaker__c Where Survey__c=:tu.surveyId and
			((Contact__c != null and Contact__c=:c.Id))];
			System.debug('Check:' + check);
			Test.stopTest();
		}

		//test something
	}

	@IsTest
	private static void testgetResponses(){
		User u = [SELECT Id FROM User WHERE Username LIKE '%@testorg.com' LIMIT 1];
		System.runAs(u){
			SurveyTestingUtil tu = new SurveyTestingUtil();
			Apexpages.currentPage().getParameters().put('id',tu.surveyId);
			Apexpages.Standardcontroller stc = new ApexPages.StandardController(tu.survey);
			ViewSurveyController vsc = new ViewSurveyController(stc);
			vsc.init();
			List<String> responses = vsc.getResponses();
			System.debug(responses);
		}

	}

	@IsTest
	private static void testViewSurveyController_constructor2() {
		User u = [SELECT Id FROM User WHERE Username LIKE '%@testorg.com' LIMIT 1];
		System.runAs(u){
			SurveyTestingUtil tu = new SurveyTestingUtil();

			Test.setCurrentPage(Page.TakeSurvey);
			Apexpages.currentPage().getParameters().put('id',tu.surveyId);
			//Apexpages.Standardcontroller stc;
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

		}
		//test something
	}

	@IsTest
	private static void testViewSurveyController() {
		User u = [SELECT Id FROM User WHERE Username LIKE '%@testorg.com' LIMIT 1];
		System.runAs(u){
			Test.startTest();
			SurveyTestingUtil tu = new SurveyTestingUtil();
			Apexpages.currentPage().getParameters().put('id',tu.surveyId);
			Apexpages.Standardcontroller stc = new ApexPages.StandardController(tu.survey);
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
			Test.stopTest();
			System.assertEquals(true, vsc.ThankYouRendered);
		}

		//test something
	}

	@IsTest
	private static void testrefreshQuestionList() {
		User u = [SELECT Id FROM User WHERE Username LIKE '%@testorg.com' LIMIT 1];
		System.runAs(u){
			Test.startTest();

			SurveyTestingUtil tu = new SurveyTestingUtil();
			Apexpages.currentPage().getParameters().put('id',tu.surveyId);
			Apexpages.Standardcontroller stc = new ApexPages.StandardController(tu.survey);
			ViewSurveyController vsc = new ViewSurveyController(stc);
			system.assertEquals(null, vsc.refreshQuestionList() );
		}
	}

}