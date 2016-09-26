@isTest
private class SurveyManagerController_Test {
    @isTest(seeAllData=True)
    private static void doTest(){
        PageReference pageRef = Page.SurveyManagerPage;
        Test.setCurrentPage(pageRef);

        Survey__c s = new Survey__c();
        s.Name = 'test survey';
        insert s;
        ApexPages.StandardController sc = new ApexPages.StandardController(s);

        SurveyManagerController con = new SurveyManagerController(sc);
        System.assertEquals(con.surveyId, s.Id);
        //String url = con.getResults().getUrl();
        //System.assertEquals(url, '/'+con.reportId + '?pv0='  + con.surveyId);
    }
}