/**
 * Test class for ViewSurveyController
 */
@IsTest
private class ViewSurveyController_Test{

	@TestSetup
	static void makeData(){
		User u = SurveyTestingUtil.createNewAdminPermissionSetUser();
	}

	@IsTest
	private static void testViewSurveyController_contact() {
		User u = [SELECT Id FROM User WHERE Username LIKE '%@testorg.com' LIMIT 1];
		System.runAs(u){
			SurveyTestingUtil tu = new SurveyTestingUtil();

			Contact c = new Contact();
			c.FirstName = 'John';
			c.LastName = 'Doe';
			insert c;

			Test.startTest();

			Test.setCurrentPage(Page.TakeSurvey);

			//Apexpages.currentPage().getParameters().put('id', tu.surveyId);
			Apexpages.Standardcontroller stc = new ApexPages.StandardController(tu.survey);
			Apexpages.currentPage().getParameters().put('id',tu.surveyId);
			Apexpages.currentPage().getParameters().put('cId',c.Id);
			ViewSurveyController vsc = new ViewSurveyController(stc);

			System.assertEquals( SurveyTestingUtil.QUESTION_TYPES, vsc.allQuestions.size() );
			System.debug(vsc.allQuestions);

			for (SFQuestion q : vsc.allQuestions){

				if(!q.responseOptions.isEmpty()){
					q.selectedOption = q.responseOptions.get(2).getValue();
					q.selectedOptions.add(q.responseOptions.get(2).getValue());
				} else {
					q.inputText = 'text response';
				}
			}
			vsc.submitResults();
			System.assertEquals(true, vsc.ThankYouRendered);

			//Run again to hit an exception for code coverage
			//There is no return value as this is void method
			List<SurveyTaker__c> check = [SELECT Contact__c, Survey__c, Case__c, User__c FROM SurveyTaker__c WHERE Survey__c=:tu.surveyId and
			((Contact__c != null and Contact__c=:c.Id))];
			System.debug('Check:' + check);

			vsc.init();
			for (SFQuestion q : vsc.allQuestions)
			{
				if(!q.responseOptions.isEmpty()){
					q.selectedOption = q.responseOptions.get(1).getValue();
					q.selectedOptions.add(q.responseOptions.get(1).getValue());
				} else {
					q.inputText = 'text response';
				}
			}
			vsc.submitResults();

			check = [SELECT Contact__c, Survey__c, Case__c, User__c FROM SurveyTaker__c WHERE Survey__c=:tu.surveyId and
			((Contact__c != null and Contact__c=:c.Id))];
			System.debug('Check:' + check);
			Test.stopTest();
		}

	}

	@IsTest
	private static void testViewSurveyController_case() {
		User u = [SELECT Id FROM User WHERE Username LIKE '%@testorg.com' LIMIT 1];
		System.runAs(u){
			SurveyTestingUtil tu = new SurveyTestingUtil();

			Case c = new Case(Status = Case.Status.getDescribe().getDefaultValue().toString());
			insert c;

			Test.startTest();
			Test.setCurrentPage(Page.TakeSurvey);
			ApexPages.currentPage().getParameters().put('caId', c.Id);
			Apexpages.Standardcontroller stc = new ApexPages.StandardController(tu.survey);

			ViewSurveyController vsc = new ViewSurveyController(stc);
			for (SFQuestion q : vsc.allQuestions)
			{
				if(!q.responseOptions.isEmpty()){
					q.selectedOption = q.responseOptions.get(1).getValue();
					q.selectedOptions.add(q.responseOptions.get(1).getValue());
				} else {
					//q.choices = 'text response';
					q.inputText = 'text response';
				}
			}
			System.assertEquals(SurveyTestingUtil.QUESTION_TYPES, vsc.allQuestions.size());

			vsc.submitResults();
			Test.stopTest();
			System.assertEquals(true, vsc.ThankYouRendered);

		}
	}

	@IsTest
	private static void testViewSurveyController() {
		User u = [SELECT Id FROM User WHERE Username LIKE '%@testorg.com' LIMIT 1];
		System.runAs(u){
			SurveyTestingUtil tu = new SurveyTestingUtil();

			Test.startTest();
			Test.setCurrentPage(Page.TakeSurvey);

			//Apexpages.currentPage().getParameters().put('id', tu.surveyId);
			Apexpages.Standardcontroller stc = new ApexPages.StandardController(tu.survey);
			ViewSurveyController vsc = new ViewSurveyController(stc);
			vsc.getAnonymousOrUser();
			System.assert(vsc.getIsInternal());
			Test.stopTest();
			System.assertEquals(false, vsc.ThankYouRendered);
		}
	}

	@IsTest
	private static void testThankYouLinkRedirect() {
		User u = [SELECT Id FROM User WHERE Username LIKE '%@testorg.com' LIMIT 1];
		System.runAs(u){
			SurveyTestingUtil tu = new SurveyTestingUtil();
			tu.survey.Thank_You_Link__c = 'www.google.com';
			update tu.survey;

			System.debug('tu survey ' + tu.survey);

			Test.startTest();
			Test.setCurrentPage(Page.TakeSurvey);

			//Apexpages.currentPage().getParameters().put('id', tu.surveyId);
			Apexpages.Standardcontroller stc = new ApexPages.StandardController(tu.survey);
			ViewSurveyController vsc = new ViewSurveyController(stc);
			//System.assertEquals(null, vsc.submitResults());
			for (SFQuestion q : vsc.allQuestions)
			{
				if(!q.responseOptions.isEmpty()){
					q.selectedOption = q.responseOptions[1].getValue();
					q.selectedOptions.add(q.responseOptions[1].getValue());
				} else {
					//q.choices = 'text response';
					q.inputText = 'text response';
				}
			}
			Test.stopTest();
			System.assertNotEquals(null, vsc.submitResults());
		}
	}

	@IsTest
	private static void testSubmitSurvey() {
		User u = [SELECT Id FROM User WHERE Username LIKE '%@testorg.com' LIMIT 1];
		System.runAs(u){
			SurveyTestingUtil tu = new SurveyTestingUtil();
			Test.startTest();
			Test.setCurrentPage(Page.TakeSurvey);

			Apexpages.Standardcontroller stc = new ApexPages.StandardController(tu.survey);
			ViewSurveyController vsc = new ViewSurveyController(stc);
			System.assertEquals( SurveyTestingUtil.QUESTION_TYPES, vsc.allQuestions.size() );
			System.assert(tu.surveyId != null);

			System.debug('Evaluating ' + vsc.allQuestions.size() + ' responses');
			for (SFQuestion q : vsc.allQuestions)
			{
				if(!q.responseOptions.isEmpty()){
					q.selectedOption = q.responseOptions[1].getValue();
					q.selectedOptions.add(q.responseOptions[1].getValue());
				} else {
					//q.choices = 'text response';
					q.inputText = 'text response';
				}
			}
			vsc.submitResults();
			Test.stopTest();
			System.assertEquals(true, vsc.ThankYouRendered);
		}
	}

	@IsTest
	private static void testBad_Values() {
		User u = [SELECT Id FROM User WHERE Username LIKE '%@testorg.com' LIMIT 1];
		System.runAs(u){
			SurveyTestingUtil tu = new SurveyTestingUtil();
			Test.startTest();
			Test.setCurrentPage(Page.TakeSurvey);

			Apexpages.Standardcontroller stc = new ApexPages.StandardController(tu.survey);
			ViewSurveyController vsc = new ViewSurveyController(stc);
			//vsc.init();
			System.assertEquals( SurveyTestingUtil.QUESTION_TYPES, vsc.allQuestions.size() );
			System.assert(tu.surveyId != null);

			System.debug('Evaluating ' + vsc.allQuestions.size() + ' responses');

			System.assertEquals(null, vsc.submitResults());

			for (SFQuestion q : vsc.allQuestions)
			{
				if(!q.responseOptions.isEmpty()){
					q.selectedOption = q.responseOptions[1].getValue();
					q.selectedOptions.add(q.responseOptions[1].getValue());
				} else {
					//q.choices = 'text response';
					q.inputText = 'text response';
				}
				if(q.renderRadioVertical || q.renderRadioVertical){
					q.selectedOption = '';
				}
			}
			System.assertEquals(null, vsc.submitResults());
			vsc.getAQuestion();

			for (SFQuestion q : vsc.allQuestions)
			{
				if(!q.responseOptions.isEmpty()){
					q.selectedOption = q.responseOptions[1].getValue();
					q.selectedOptions.add(q.responseOptions[1].getValue());
				} else {
					//q.choices = 'text response';
					q.inputText = 'text response';
				}
				if(q.renderMultiCheckboxes){
					q.selectedOptions = new List<String>();
				}
			}
			System.assertEquals(null, vsc.submitResults());
			vsc.getAQuestion();

			for (SFQuestion q : vsc.allQuestions)
			{
				if(!q.responseOptions.isEmpty()){
					q.selectedOption = q.responseOptions[1].getValue();
					q.selectedOptions.add(q.responseOptions[1].getValue());
				} else {
					q.inputText = 'text response';
				}
				if(q.renderFreeText){
					q.inputText = '';
				}
			}
			System.assertEquals(null, vsc.submitResults());
			System.assertEquals(false, vsc.ThankYouRendered);

			vsc.getAQuestion();
			for (SFQuestion q : vsc.allQuestions)
			{
				if(!q.responseOptions.isEmpty()){
					q.selectedOption = q.responseOptions[1].getValue();
					q.selectedOptions.add(q.responseOptions[1].getValue());
				} else {
					q.inputText = 'text response';
				}
			}

			Pagereference pr = vsc.submitResults();
			Test.stopTest();
			System.assertEquals(null, pr); // no thank you link
			System.assertEquals(true, vsc.ThankYouRendered);
		}
	}

	@IsTest
	static void testAnonymousSurvey(){

		User u = [SELECT Id FROM User WHERE Username LIKE '%@testorg.com' LIMIT 1];
		System.runAs(u){
			SurveyTestingUtil tu = new SurveyTestingUtil();
			tu.survey.All_Responses_Anonymous__c = true;
			tu.survey.Thank_You_Text__c = null;
			update tu.survey;

			Test.startTest();
			Test.setCurrentPage(Page.TakeSurvey);
			Apexpages.Standardcontroller stc = new ApexPages.StandardController(tu.survey);
			ViewSurveyController vsc = new ViewSurveyController(stc);
			vsc.init();
			System.assert(tu.surveyId != null);

			for (SFQuestion q : vsc.allQuestions)
			{
				if(!q.responseOptions.isEmpty()){
					q.selectedOption = q.responseOptions.get(1).getValue();
					q.selectedOptions.add(q.responseOptions.get(1).getValue());
				} else {
					q.inputText = 'text response';
				}
			}
			Pagereference pr = vsc.submitResults();
			System.assertEquals('Anonymous', vsc.anonymousAnswer);
			Test.stopTest();
			System.assertEquals(null, pr);
			System.assertEquals(true, vsc.ThankYouRendered);
		}

	}
}