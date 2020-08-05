@isTest
private with sharing class ViewShareSurveyComponentController_Test {
    private static testmethod void testShareSurvey()
    {
        ApexPages.currentPage().getHeaders().put('Host','https://surveyforce-dev-ed--c.na46.visual.force.com');
        Survey__c mySurvey = new Survey__c();
        mySurvey.Submit_Response__c = 'empty';
        insert mySurvey;

        ViewShareSurveyComponentController vss = new ViewShareSurveyComponentController();
        vss.surveyId = mySurvey.Id;

        vss.selectedURLType = 'Chatter';
        System.assertEquals(vss.getVFUrl(), vss.surveyURLBase);
        System.assertEquals('id=' + mySurvey.Id + '&cId=none&caId=none', vss.surveyURL);

        vss.selectedURLType = 'Email Link, Anonymous';
        System.assertEquals(vss.getVFUrl(), vss.surveyURLBase);
        System.assertEquals('id=' + mySurvey.Id + '&cId=none&caId=none', vss.surveyURL);


        vss.selectedURLType = 'Email Link w/ Contact Merge';
        System.assertEquals('id=' + mySurvey.Id + '&cId={!Contact.Id}&caId=none', vss.surveyURL);

        vss.selectedURLType = 'Email Link w/ Contact & Case Merge';
        System.assertEquals('id=' + mySurvey.Id +  '&cId={!Contact.Id}&caId={!Case.id}', vss.surveyURL);

        System.assert(vss.sitesPicklist.size()>=1);

    }
}
