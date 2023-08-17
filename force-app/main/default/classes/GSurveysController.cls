public with sharing class GSurveysController {
	@TestVisible
	private Survey__c survey;
	/**
	 * Controller
	 *
	 * @param stdController Standard controller for `Survey__c` record
	 */
	public GSurveysController(ApexPages.StandardController stdController) {
		survey = (Survey__c) stdController.getRecord();
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

	public Pagereference save() {
		if (survey.Id != null || survey.Name == null) {
			return null;
		}
		try {
			List<Schema.SobjectField> fields = new List<Schema.SobjectField>{ Schema.Survey__c.fields.Name };
			SurveyForceUtil.accessController.assertAuthorizedToCreate(Schema.Survey__c.getSobjectType(), fields);

			insert survey;
			return redirectToManager(survey.Id);
		} catch (Exception e) {
			pageMessage.setMessage(e.getMessage(), 'error');
			ApexPages.addMessages(e);
			return null;
		}
	}

	/**
	 * onLoad allows DML or page redirects that are not possible in a constructor
	 *
	 * @return  `PageReference` Actions to perform on page load
	 */
	public PageReference onLoad() {
		if (survey.Id != null) {
			return redirectToManager(survey.Id);
		} else {
			return null;
		}
	}

	private PageReference redirectToManager(Id surveyId) {
		Pagereference retVal = Page.SurveyManagerPage;
		retVal.getParameters().put('id', surveyid);
		retVal = retVal.setRedirect(true);
		return retVal;
	}

	/**
	 * TODO: Investigate if this method is necessary, as it is not called by any code
	 *
	 * @return  `Boolean` Is there an existing Force.com Site (with a subdomain?)
	 */
	public Boolean getHasExistingSite() {
		return [SELECT Name FROM Site WHERE Subdomain != ''].size() > 0;
	}
}