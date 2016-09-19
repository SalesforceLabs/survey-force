@isTest
private with sharing class viewShareSurveyComponentController_Test {
    private static testmethod void testShareSurvey()
    {
        Survey__c mySurvey = new Survey__c();
        mySurvey.Submit_Response__c = 'empty';
        insert mySurvey;

        viewShareSurveyComponentController vss = new viewShareSurveyComponentController();
        vss.surveyId = mySurvey.Id;

        vss.selectedURLType = 'Chatter';
        System.assertEquals(vss.getVFUrl(), vss.surveyURLBase);
        System.assertEquals('id=' + mySurvey.Id + '&cId=none&caId=none', vss.surveyURL);

        vss.selectedURLType = 'Email Link w/ Contact Merge';
        System.assertEquals('id=' + mySurvey.Id + '&cId={!Contact.Id}&caId=none', vss.surveyURL);

        vss.selectedURLType = 'Email Link w/ Contact & Case Merge';
        System.assertEquals('id=' + mySurvey.Id +  '&cId={!Contact.Id}&caId={!Case.id}', vss.surveyURL);

    }
}