@istest
private class SurveyAndQuestionController_Test {

    //test constructor and calls within it
    @isTest(SeeAllData='true')
    private static void testCreateQuestionController(){
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id',tu.surveyId);
        Apexpages.Standardcontroller std;
        SurveyAndQuestionController cqc = new SurveyAndQuestionController(std);
        cqc.addQuestion();
        cqc.getNewQuestionNum();
        cqc.makeNewQuestionLink();
        System.assert(cqc.surveyId == tu.surveyId);
    }

    @isTest(SeeAllData='true')
    //test constructor and calls within it
    private static void testEditQuestion(){
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id',tu.surveyId);
        Apexpages.Standardcontroller std;
        SurveyAndQuestionController cqc = new SurveyAndQuestionController(std);
        cqc.editQuestion();
        cqc.questionReference = tu.questionIds[0];
        cqc.editQuestion();
        cqc.questionReference = tu.questionIds[1];
        cqc.editQuestion();
        cqc.questionReference = tu.questionIds[2];
        cqc.editQuestion();
        cqc.questionReference = tu.questionIds[3];
        System.assert(cqc.editQuestion()==null);

    }

    @isTest(SeeAllData='true')
    //test the saving of new questions
    private static void testsaveAndNewQuestion(){
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id',tu.surveyId);
        Apexpages.Standardcontroller std;
        SurveyAndQuestionController cqc = new SurveyAndQuestionController(std);
        //test saving new question
        cqc.qQuestion = 'THIS IS A NEW QUESTION';
        cqc.qChoices = '1\\n2\\n3\\3';
        cqc.qRequired=true;
        cqc.questionType='Single Select--Vertical';
        cqc.saveAndNewQuestion();
        System.assertEquals(5, cqc.getNewQuestionNum());
        //edit existing question
        SurveyAndQuestionController cqcI = new SurveyAndQuestionController(std);
        cqcI.questionReference = tu.questionIds[0];
        cqcI.editQuestion();
        cqcI.qQuestion = 'THIS IS A NEW QUESTION THAT IS EXTRA LONG SO THE NAME SHORTENING CALL WILL BE USED, THIS SHOULD BE LONG ENOUGH NOW THIS IS A NEW';
        cqcI.qChoices = '1\\n2\\n3\\3';
        cqcI.qRequired=true;
        cqcI.questionType='Single Select--Vertical';
        cqcI.saveAndNewQuestion();
        System.assertEquals(5, cqcI.getNewQuestionNum());
    }

    @isTest(SeeAllData='true')
    private static void testsavesaveQuestion(){
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id',tu.surveyId);
        Apexpages.Standardcontroller std;
        SurveyAndQuestionController cqc = new SurveyAndQuestionController(std);
        //test saving new question
        cqc.qQuestion = 'THIS IS A NEW QUESTION';
        cqc.qChoices = '1\\n2\\n3\\3';
        cqc.qRequired=true;
        cqc.questionType='Single Select--Vertical';
        cqc.controllerSavQuestion();
        System.assertEquals(5, cqc.getNewQuestionNum());
        //edit existing question
        SurveyAndQuestionController cqcI = new SurveyAndQuestionController(std);
        cqcI.questionReference = tu.questionIds[0];
        cqcI.editQuestion();
        cqcI.qQuestion = 'THIS IS A NEW QUESTION THAT IS EXTRA LONG SO THE NAME SHORTENING CALL WILL BE USED, THIS SHOULD BE LONG ENOUGH NOW';
        cqcI.qChoices = '1\\n2\\n3\\3';
        cqcI.qRequired=true;
        cqcI.questionType='Single Select--Vertical';
        cqcI.controllerSavQuestion();
        System.assertEquals(5, cqcI.getNewQuestionNum());
    }

    @isTest(SeeAllData='true')
    //test constructor and calls within it
    private static void testPreviewQuestion(){
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id',tu.surveyId);
        Apexpages.Standardcontroller std;
        SurveyAndQuestionController cqc = new SurveyAndQuestionController(std);

        cqc.questionReference = tu.questionIds[0];
        cqc.editQuestion();
        cqc.previewQuestion();

        cqc.questionReference = tu.questionIds[1];
        cqc.editQuestion();
        cqc.previewQuestion();

        cqc.questionReference = tu.questionIds[2];
        cqc.editQuestion();
        System.assert(cqc.previewQuestion()==null);

        cqc.questionReference = tu.questionIds[3];
        cqc.editQuestion();
        System.assert(cqc.previewQuestion()==null);



    }


    @isTest(SeeAllData='true')
    private static void testUpdateSurveyName() {
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id',tu.surveyId);
        Apexpages.Standardcontroller stc;
        SurveyAndQuestionController vsc = new SurveyAndQuestionController(stc);
        vsc.surveyName = 'new name';
        system.assert(vsc.updateSurveyName() == null);

    }


    @isTest(SeeAllData='true')
    private static void testupdateSurveyThankYouAndLink() {
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id',tu.surveyId);
        Apexpages.Standardcontroller stc;
        SurveyAndQuestionController vsc = new SurveyAndQuestionController(stc);
        vsc.surveyThankYouText = 'new stuff';
        vsc.surveyThankYouURL = 'more new stff';
        system.assert(vsc.updateSurveyThankYouAndLink()==null);
    }

    //------------------------------------------------------------------------------//

    @isTest(SeeAllData='true')
    private static void testRefreshQuestionList() {
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id',tu.surveyId);
        Apexpages.Standardcontroller stc;
        SurveyAndQuestionController vsc = new SurveyAndQuestionController(stc);
        vsc.getAQuestion();

        // Retrieve questions for this survey
        List<Survey_Question__c> sq = new List<Survey_Question__c>();
        sq = [Select id, orderNumber__c from Survey_Question__c];

        // get question with orderNumber 1
        Survey_Question__c first = [Select id, orderNumber__c from Survey_Question__c Where orderNumber__c =: 1 and Survey__c =: tu.surveyId];
        System.assert(first.orderNumber__c == 1 );

        // Specify the new order
        vsc.newOrderW = vsc.allQuestions[2].id + ',' +
                vsc.allQuestions[0].id + ',' +
                vsc.allQuestions[1].id + ',' +
                vsc.allQuestions[3].id + ',';

        vsc.updateOrderList();

        // Verify that the question with order 1 is not the same as the one retrieved previously
        Survey_Question__c second = [Select id, orderNumber__c from Survey_Question__c Where orderNumber__c =: 1 and Survey__c =: tu.surveyId];
        System.assert(second.id != first.id);

        // update the question list, and make sure it has been modified as well
        vsc.refreshQuestionList();
        System.assert(vsc.allQuestions[1].id != first.id);

    }

//------------------------------------------------------------------------------//

    @isTest(SeeAllData='true')
    private static void testDeleteQuestion() {
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id',tu.surveyId);
        Apexpages.Standardcontroller stc;
        SurveyAndQuestionController vsc = new SurveyAndQuestionController(stc);


        // Get a question to delete
        Survey_Question__c sq = [Select id, orderNumber__c from Survey_Question__c Where orderNumber__c =: 1 and Survey__c =: tu.surveyId];
        vsc.questionReference = sq.Id;
        vsc.deleteRefresh();

        Survey_Question__c sq2 = [Select id, orderNumber__c from Survey_Question__c Where orderNumber__c =: 1 and Survey__c =: tu.surveyId];
        System.assert(sq.Id != sq2.Id);


    }
//------------------------------------------------------------------------------//


/**/
}