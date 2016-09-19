public with sharing class SurveyManagerController {
    private ApexPages.StandardController stdControl;
    public Boolean editCSS {get; set;}

    public String surveyId {get;set;}
    public String reportId {get;set;}
    public Survey__c survey {get;set;}

    public Message pageMessage {
        get {
            if (pageMessage == null) {
                pageMessage = new Message();
            }
            return pageMessage;
        }
        set;
    }
    
    public SurveyManagerController(ApexPages.StandardController stdController){
        this.stdControl = stdController;
        if(!test.isRunningTest()){stdController.addFields(new List<String>{'Hide_Survey_Name__c', 'Survey_Header__c', 'Thank_You_Text__c', 'Survey_Container_CSS__c'});}
        survey = (Survey__c)stdController.getRecord();

        try {

            List<User> res = [SELECT Profile.PermissionsAuthorApex FROM User WHERE id = :Userinfo.getUserId()];
            User u = res[0];
            if (u.Profile.PermissionsAuthorApex) {
                this.editCSS = true;
            } else {
                this.editCSS = false;
            }

            surveyId = stdController.getRecord().Id;
            String reportName = 'Survey with Questions and Responses';
            Sobject myReport = [select Id, Name From Report Where Name = :reportName];
            reportId = myReport.Id;
        }catch(Exception e){
            pageMessage.setMessage(e.getMessage(), 'error');
            ApexPages.addMessages(e);
        }
    }
    //Generate report link for Report tab
    public pageReference getResults(){
        surveyId = surveyId.substring(0,15);
        return new PageReference('/' + reportId + '?pv0=' + surveyId);
    }

    public Pagereference save(){
        //Adding default CSS to add some space around survey
        //But this is changeable
        try {
            survey.Survey_Container_CSS__c = survey.Survey_Container_CSS__c.replaceAll('<[^>]+>',' ');
            update survey;
        }catch(Exception e){pageMessage.setMessage(e.getMessage(), 'error');ApexPages.addMessages(e);}
        return null;
    }
}