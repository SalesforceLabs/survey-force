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
        
        try {
            this.stdControl = stdController;
            if(!test.isRunningTest()){stdController.addFields(new List<String>{'Hide_Survey_Name__c', 'Survey_Header__c', 'Thank_You_Text__c', 'Survey_Container_CSS__c'});}
            survey = (Survey__c)stdController.getRecord();


            //User is standard object and there is no CRUD/FLS check for this as it can not be changed
            List<User> res = [SELECT Profile.PermissionsAuthorApex FROM User WHERE id = :Userinfo.getUserId()];
            User u = res[0];
            if (u.Profile.PermissionsAuthorApex) {
                this.editCSS = true;
            } else {
                this.editCSS = false;
            }

            surveyId = stdController.getRecord().Id;
            surveyId = String.escapeSingleQuotes(surveyId.substring(0,15));

            //reportId will be passed to <analytics:reportChart> tag in SurveyManagerPage.page
            //Filter for current survey will also be added via that tag
            String reportName = 'Survey with Questions and Responses';
            List<Schema.SobjectField> fields = new List<Schema.SobjectField>{Schema.Report.fields.Name};
            Util.AccessController.assertAuthorizedToView(Schema.Report.getSobjectType(), fields);

            Sobject myReport = [select Id, Name From Report Where Name = :reportName];
            reportId = myReport.Id;

        }catch(SFDCAccessControlException e){ Util.log('SurveyManagerController:SurveyManagerController():SFDCAccessControlException' + e.getMessage());
        }catch(Exception e){ pageMessage.setMessage(e.getMessage(), 'error'); ApexPages.addMessages(e);
        }
    }

    public Pagereference save(){
        //Adding default CSS to add some space around survey
        //But this is changeable
        try {
            List<Schema.SobjectField> fields = new List<Schema.SobjectField>{Schema.Survey__c.fields.Name};
            Util.AccessController.assertAuthorizedToUpdate(Schema.Survey__c.getSobjectType(), fields);

            //Make sure CSS is safe, remove HTML tags
            survey.Survey_Container_CSS__c = (String.isEmpty(survey.Survey_Container_CSS__c))?'':survey.Survey_Container_CSS__c.replaceAll('<[^>]+>',' ');
            update survey;
        }catch(SFDCAccessControlException e){ Util.log('SurveyManagerController:save():SFDCAccessControlException' + e.getMessage());
        } catch(Exception e){pageMessage.setMessage(e.getMessage(), 'error');ApexPages.addMessages(e);}
        return null;
    }
}