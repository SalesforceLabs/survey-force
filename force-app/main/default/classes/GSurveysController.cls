global with sharing class GSurveysController {

    public Survey__c survey {get;set;}
    public GSurveysController(ApexPages.StandardController stdController){
        survey = (Survey__c)stdController.getRecord();
    }
    public Message pageMessage {
        get {
            if (pageMessage == null) {
                pageMessage = new Message();
            }
            return pageMessage;
        }
        set;
    }

    public Pagereference save(){
        Pagereference retVal = null;
        //Adding default CSS to add some space around survey
        //But this is changeable
        try {
            survey.Survey_Container_CSS__c = '#survey_container{margin: 10px}';

            insert survey;
            
            retVal = new Pagereference('/apex/SurveyManagerPage?id=' + survey.Id);
        }catch(Exception e){pageMessage.setMessage(e.getMessage(), 'error');ApexPages.addMessages(e);}
        return retVal;
  }
}