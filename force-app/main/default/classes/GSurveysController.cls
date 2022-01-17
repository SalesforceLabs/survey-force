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
		if(survey.Id != null || survey.Name == null){return null;}
        try {
            List<Schema.SobjectField> fields = new List<Schema.SobjectField>{
                Schema.Survey__c.fields.Name
            };
            SurveyForceUtil.AccessController.assertAuthorizedToCreate(Schema.Survey__c.getSobjectType(), fields);
            
            insert survey;
			return redirectToManager(survey.Id);
        } catch(Exception e){
            pageMessage.setMessage(e.getMessage(), 'error');
            ApexPages.addMessages(e);
            return null;
        }
    }

    public PageReference onLoad(){
        if(survey.Id != null){
            return redirectToManager(survey.Id);
        } else {
            return null;
        }
    }

	private PageReference redirectToManager(Id surveyId){
		Pagereference retVal = Page.SurveyManagerPage;
            retVal.getParameters().put('id', surveyid);
            retVal = retVal.setRedirect(true);
            return retVal;
	}

	public Boolean getHasExistingSite(){
		return [SELECT Name FROM Site WHERE Subdomain != ''].size() > 0;
	}
}