@IsTest
private class SurveyAndQuestionController_Test {
	@TestSetup
	static void makeData() {
		User u = SurveyTestingUtil.createNewAdminPermissionSetUser();
	}

	//test constructor and calls within it
	@isTest
	private static void testCreateQuestionController() {
		User u = [SELECT Id FROM User WHERE Username LIKE '%@testorg.com' LIMIT 1];
		System.runAs(u) {
			SurveyTestingUtil tu = new SurveyTestingUtil();
			Test.setCurrentPage(Page.SurveyPage);
			Apexpages.currentPage().getParameters().put('id', tu.surveyId);
			Apexpages.Standardcontroller std = new ApexPages.StandardController(tu.survey);
			SurveyAndQuestionController cqc = new SurveyAndQuestionController(std);
			cqc.addQuestion();
			cqc.getNewQuestionNum();
			cqc.makeNewQuestionLink();
			cqc.getQuestionTypeOptions();
			System.assert(cqc.theSurvey.Id == tu.surveyId);
		}
	}

	@isTest
	//test constructor and calls within it
	private static void testEditQuestion() {
		User u = [SELECT Id FROM User WHERE Username LIKE '%@testorg.com' LIMIT 1];
		System.runAs(u) {
			SurveyTestingUtil tu = new SurveyTestingUtil();
			Test.setCurrentPage(Page.SurveyPage);
			Apexpages.currentPage().getParameters().put('id', tu.surveyId);
			Apexpages.Standardcontroller std = new ApexPages.StandardController(tu.survey);
			SurveyAndQuestionController cqc = new SurveyAndQuestionController(std);
			cqc.editQuestion();
			cqc.questionReference = tu.questionIds[0];
			cqc.editQuestion();
			cqc.questionReference = tu.questionIds[1];
			cqc.editQuestion();
			cqc.questionReference = tu.questionIds[2];
			cqc.editQuestion();
			cqc.questionReference = tu.questionIds[3];
			System.assert(cqc.editQuestion() == null);
		}
	}

	@isTest
	//test the saving of new questions
	private static void testsaveAndNewQuestion() {
		User u = [SELECT Id FROM User WHERE Username LIKE '%@testorg.com' LIMIT 1];
		System.runAs(u) {
			SurveyTestingUtil tu = new SurveyTestingUtil();
			Test.setCurrentPage(Page.SurveyPage);
			Apexpages.currentPage().getParameters().put('id', tu.surveyId);
			Apexpages.Standardcontroller std = new ApexPages.StandardController(tu.survey);
			SurveyAndQuestionController cqc = new SurveyAndQuestionController(std);
			//test saving new question
			cqc.qQuestion = 'THIS IS A NEW QUESTION';
			cqc.qChoices = '1\\n2\\n3\\3';
			cqc.qRequired = true;
			cqc.questionType = 'Single Select--Vertical';
			cqc.saveAndNewQuestion();
			System.assertEquals(5, cqc.getNewQuestionNum());
			//edit existing question
			SurveyAndQuestionController cqcI = new SurveyAndQuestionController(std);
			cqcI.questionReference = tu.questionIds[0];
			cqcI.editQuestion();
			cqcI.qQuestion = 'THIS IS A NEW QUESTION THAT IS EXTRA LONG SO THE NAME SHORTENING CALL WILL BE USED, THIS SHOULD BE LONG ENOUGH NOW THIS IS A NEW';
			cqcI.qChoices = '1\\n2\\n3\\3';
			cqcI.qRequired = true;
			cqcI.questionType = 'Single Select--Vertical';
			cqcI.saveAndNewQuestion();
			System.assertEquals(5, cqcI.getNewQuestionNum());
		}
	}

	@isTest
	private static void testsavesaveQuestion() {
		User u = [SELECT Id FROM User WHERE Username LIKE '%@testorg.com' LIMIT 1];
		System.runAs(u) {
			SurveyTestingUtil tu = new SurveyTestingUtil();
			Test.setCurrentPage(Page.SurveyPage);
			Apexpages.currentPage().getParameters().put('id', tu.surveyId);
			Apexpages.Standardcontroller std = new ApexPages.StandardController(tu.survey);
			SurveyAndQuestionController cqc = new SurveyAndQuestionController(std);
			//test saving new question
			cqc.qQuestion = 'THIS IS A NEW QUESTION';
			cqc.qChoices = '1\\n2\\n3\\3';
			cqc.qRequired = true;
			cqc.questionType = 'Single Select--Vertical';
			cqc.controllerSavQuestion();
			System.assertEquals(5, cqc.getNewQuestionNum());
			//edit existing question
			SurveyAndQuestionController cqcI = new SurveyAndQuestionController(std);
			cqcI.questionReference = tu.questionIds[0];
			cqcI.editQuestion();
			cqcI.qQuestion = 'THIS IS A NEW QUESTION THAT IS EXTRA LONG SO THE NAME SHORTENING CALL WILL BE USED, THIS SHOULD BE LONG ENOUGH NOW';
			cqcI.qChoices = '1\\n2\\n3\\3';
			cqcI.qRequired = true;
			cqcI.questionType = 'Single Select--Vertical';
			cqcI.controllerSavQuestion();
			System.assertEquals(5, cqcI.getNewQuestionNum());
		}
	}

	//------------------------------------------------------------------------------//

	@isTest
	private static void testRefreshQuestionList() {
		User u = [SELECT Id FROM User WHERE Username LIKE '%@testorg.com' LIMIT 1];
		System.runAs(u) {
			SurveyTestingUtil tu = new SurveyTestingUtil();
			Test.setCurrentPage(Page.SurveyPage);
			Apexpages.currentPage().getParameters().put('id', tu.surveyId);
			Apexpages.Standardcontroller std = new ApexPages.StandardController(tu.survey);
			SurveyAndQuestionController vsc = new SurveyAndQuestionController(std);
			vsc.getAQuestion();

			// Retrieve questions for this survey
			List<Survey_Question__c> sq = new List<Survey_Question__c>();
			sq = [SELECT Id, OrderNumber__c FROM Survey_Question__c];

			// get question with orderNumber 1
			Survey_Question__c first = [SELECT Id, OrderNumber__c FROM Survey_Question__c WHERE OrderNumber__c = :1 AND Survey__c = :tu.surveyId];
			System.assert(first.OrderNumber__c == 1);

			// Specify the new order
			vsc.newOrderW = vsc.allQuestions[2].id + ',' + vsc.allQuestions[0].id + ',' + vsc.allQuestions[1].id + ',' + vsc.allQuestions[3].id + ',';

			vsc.updateOrderList();

			// Verify that the question with order 1 is not the same as the one retrieved previously
			Survey_Question__c second = [SELECT Id, OrderNumber__c FROM Survey_Question__c WHERE OrderNumber__c = :1 AND Survey__c = :tu.surveyId];
			System.assert(second.id != first.id);

			// update the question list, and make sure it has been modified as well
			vsc.getAQuestion();
			System.assert(vsc.allQuestions[1].id != first.id);
		}
	}

	//------------------------------------------------------------------------------//

	@isTest
	private static void testDeleteQuestion() {
		User u = [SELECT Id FROM User WHERE Username LIKE '%@testorg.com' LIMIT 1];
		System.runAs(u) {
			SurveyTestingUtil tu = new SurveyTestingUtil();
			Test.setCurrentPage(Page.SurveyPage);
			Apexpages.currentPage().getParameters().put('id', tu.surveyId);
			Apexpages.Standardcontroller std = new ApexPages.StandardController(tu.survey);
			SurveyAndQuestionController vsc = new SurveyAndQuestionController(std);

			// Get a question to delete
			Survey_Question__c sq = [SELECT Id, OrderNumber__c FROM Survey_Question__c WHERE OrderNumber__c = :1 AND Survey__c = :tu.surveyId];
			vsc.questionReference = sq.Id;
			vsc.deleteRefresh();

			Survey_Question__c sq2 = [SELECT Id, OrderNumber__c FROM Survey_Question__c WHERE OrderNumber__c = :1 AND Survey__c = :tu.surveyId];
			System.assert(sq.Id != sq2.Id);
		}

	}
}