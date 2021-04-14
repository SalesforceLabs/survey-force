@isTest
private class GettingStartedController_Test {
    private static testmethod void testGettingStarted()
    {
        User u = SurveyTestingUtil.createNewAdminPermissionSetUser();

        System.runAs(u){
            System.debug('CurrentUserName ' + UserInfo.getUserName());
            System.debug([SELECT Id, PermissionSet.Name FROM PErmissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId()]);


            List<Survey__c> surveys = [SELECT Id, Name FROM Survey__c WHERE Name='SurveyForce Sample Survey'];
            System.assertEquals(0, surveys.size(), 'Should have no sample surveys');

			Test.setCurrentPage(Page.Getting_Started_With_Survey_Force);

			ApexPages.StandardController sc = new ApexPages.StandardController(new Survey__c());

            GettingStartedController gsc = new GettingStartedController(sc);
            gsc.makeTestSurvey();

            List<Survey__c> listSurvey = [SELECT Id, Name FROM Survey__c WHERE Name = 'SurveyForce Sample Survey' LIMIT 1];
            System.assertEquals(1, listSurvey.size(), 'The sample survey was not created');

            String surveyUrl = '/apex/surveymanagerpage?id=' + gsc.testSurvey.Id;
            System.assertEquals(surveyUrl, gsc.ViewSurvey().getUrl());

            surveyUrl = '/apex/takesurvey?caId=none&cId=none&id=' + gsc.testSurvey.Id;
            System.assertEquals(surveyUrl, gsc.takeSurvey().getUrl());
        }
    }
}