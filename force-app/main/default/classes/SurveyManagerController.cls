public with sharing class SurveyManagerController {

	public String reportId {get;set;}
	@TestVisible private Survey__c survey;

	public SFMessage pageMessage {
		get {
			if (pageMessage == null) {
				pageMessage = new SFMessage();
			}
			return pageMessage;
		}
		set;
	}

	public SurveyManagerController(ApexPages.StandardController stdController){
		if(!Test.isRunningTest()){stdController.addFields(new List<String>{'Hide_Survey_Name__c', 'All_Responses_Anonymous__c', 'Share_with_Guest_User__c', 'Survey_Header__c', 'Thank_You_Link__c', 'Thank_You_Text__c', 'Survey_Container_CSS__c'});}
		survey = (Survey__c)stdController.getRecord();
		try {

			//reportId will be passed to <analytics:reportChart> tag in SurveyManagerPage.page
			//Filter for current survey will also be added via that tag
			String reportName = 'Survey with Questions and Responses';
			List<Schema.SobjectField> fields = new List<Schema.SobjectField>{Schema.Report.fields.Name};
			SurveyForceUtil.AccessController.assertAuthorizedToView(Schema.Report.getSobjectType(), fields);

			Report myReport = [SELECT Id, Name FROM Report WHERE Name = :reportName LIMIT 1];
			reportId = myReport.Id;

		} catch (SFDCAccessControlException e){
			SurveyForceUtil.log('SurveyManagerController:SurveyManagerController():SFDCAccessControlException' + e.getMessage());
		} catch (Exception e){
			pageMessage.setMessage(e.getMessage(), 'error'); ApexPages.addMessages(e);
		}
	}

	public Pagereference save(){
		try {
			List<Schema.SobjectField> fields = new List<Schema.SobjectField>{Schema.Survey__c.fields.Name};
			SurveyForceUtil.AccessController.assertAuthorizedToUpdate(Schema.Survey__c.getSobjectType(), fields);

			//Make sure CSS is safe, remove HTML tags
			survey.Survey_Container_CSS__c = (String.isEmpty(survey.Survey_Container_CSS__c))?'':survey.Survey_Container_CSS__c.replaceAll('<[^>]+>',' ');
			update survey;
		} catch(SFDCAccessControlException e){
			SurveyForceUtil.log('SurveyManagerController:save():SFDCAccessControlException' + e.getMessage());
		} catch(Exception e){
			pageMessage.setMessage(e.getMessage(), 'error');ApexPages.addMessages(e);
		}
		return null;
	}
}