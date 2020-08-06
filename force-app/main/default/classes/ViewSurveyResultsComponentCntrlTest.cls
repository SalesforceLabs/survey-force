@IsTest
private class ViewSurveyResultsComponentCntrlTest {
    private static testmethod void testResultController() {
        Survey__c mySurvey = new Survey__c();
        mySurvey.Thank_You_Text__c = 'empty';
        insert mySurvey;

        ViewSurveyResultsComponentController vsr = new ViewSurveyResultsComponentController();
        vsr.mysurveyId = mySurvey.Id;

        String mySurveyId = mySurvey.Id;
        PageReference pageRef = new PageReference ('/' + vsr.reportId + '?pv0=' + mySurveyId.substring(0,15));
        System.assertEquals(pageRef.getURL(),vsr.getResults().getURL());

    }
}