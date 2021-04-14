public with sharing class GSurveysController {

    @TestVisible private Survey__c survey;
    public GSurveysController(ApexPages.StandardController stdController){
        survey = (Survey__c)stdController.getRecord();

    }
    public SFMessage pageMessage {
        get {
            if (pageMessage == null) {
                pageMessage = new SFMessage();
            }
            return pageMessage;
        }
        set;
    }

    public Pagereference save(){
        Pagereference retVal = null;

        try {

            upsert survey;

            retVal = Page.SurveyManagerPage;
            retVal.getParameters().put('id', survey.id);
            retVal = retVal.setRedirect(true);
            // new Pagereference('/apex/SurveyManagerPage?id=' + survey.Id);
        } catch(Exception e){
            pageMessage.setMessage(e.getMessage(), 'error');
            ApexPages.addMessages(e);
            return null;
        }
        return retVal;
    }

    public PageReference onLoad(){
        if(survey.Id != null){
            Pagereference retVal = Page.SurveyManagerPage;
            retVal.getParameters().put('id', survey.id);
            retVal = retVal.setRedirect(true);
            return retVal;
        } else {
            return null;
        }
    }

	public Boolean getHasExistingSite(){
		return [SELECT Name FROM Site WHERE Subdomain != ''].size() > 0;
	}
}