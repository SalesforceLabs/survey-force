/* Controller associated with page rendering the survey.
* Used by TakeSurvey
*/
global virtual with sharing class ViewSurveyController {
	//public String qQuestion                        {get; set;}
	//public Boolean qRequired                       {get; set;}
	//public String qChoices                         {get; set;}

	//public String questionName                     {get; set;}
	//public String questionType                     {get; set;}
	//public Boolean questionRequired                {get; set;}
	//public List<SelectOption> responseOptions        {get; set;}
	public List<SFQuestion> allQuestions           {get; set;}
	//public List<String> responses                  {get; set;}
	//public Integer allQuestionsSize                {get; set;}
	public String surveyThankYouText               {get; set;}

	public String caseId                           {get; set;}
	public String contactId                        {get; set;}
	public String anonymousAnswer                  {get; set;}

	public String baseURL                          {get; private set;}

	private String surveyTakerId;
	public Boolean thankYouRendered                {get; set;}

	private Survey__c mySurvey;
	public String surveyId {get; private set;}

	private String runningUserString = 'User ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName();



	/* Retrieves the list of questions, the survey name, after retrieving the
	necessary parameters from the url.
	*/
	//------------------------------------------------------------------------------//
	public ViewSurveyController(ApexPages.StandardController stdController) {
		// Get url parameters
		if(!Test.isRunningTest()){ stdController.addFields(new List<String>{'Thank_You_Link__c', 'Thank_You_Text__c','All_Responses_Anonymous__c'});}
		mySurvey = (Survey__c)stdController.getRecord();
		surveyId = mySurvey.Id != null ? mySurvey.Id : Apexpages.currentPage().getParameters().get('id');
		init();
	}

	/* public ViewSurveyController(ViewShareSurveyComponentController controller)
	{
		surveyId = Apexpages.currentPage().getParameters().get('id');
		mySurvey = [SELECT Id, Thank_You_Link__c, Thank_You_Text__c, All_Responses_Anonymous__c FROM Survey__c WHERE Id = :surveyId WITH SECURITY_ENFORCED LIMIT 1];
		init();
	} */

	public void init()
	{
		caseId   = Apexpages.currentPage().getParameters().get('caId');
		contactId = Apexpages.currentPage().getParameters().get('cId');

		if(caseId == null || !(caseId instanceof Id)){
			caseId = 'none';
		}
		if(contactId == null || !(contactId instanceof Id)){
			contactId = 'none';
		}
		surveyId = String.escapeSingleQuotes(surveyId);
		caseId = String.escapeSingleQuotes(caseId);
		contactId = String.escapeSingleQuotes(contactId);

		// Retrieve all necessary information to be displayed on the page
		getAQuestion();

		anonymousAnswer = (userInfo.getUserType() == 'Guest' || mySurvey.All_Responses_Anonymous__c) ? 'Anonymous': 'User';

		baseURL = URL.getSalesforceBaseUrl().toExternalForm();

		thankYouRendered = false;

		surveyThankYouText = mysurvey?.Thank_You_Text__c;
		if (surveyThankYouText == null) {
			surveyThankYouText = System.Label.LABS_SF_Survey_Submitted_Thank_you;
		}

	}

	public Boolean getIsInternal(){
		return (userInfo.getUserType() == 'Guest') ? false : true;
	}

	public List<SelectOption> getAnonymousOrUser(){
		List<SelectOption> anonymousOrUser = new List<SelectOption>();
		anonymousOrUser.add(new SelectOption('Anonymous', System.Label.LABS_SF_Anonymous));
		anonymousOrUser.add(new SelectOption('User', runningUserString));
		return anonymousOrUser;
	}


	//----------------------------------------------------------------------------//

	/* Called during the setup of the page.
	Retrieve questions and responses from DB and inserts them in 2 lists. */
	/* public Integer setupQuestionList(){
		getAQuestion();
		return allQuestions.size();
	} */

	//------------------------------------------------------------------------------//
	/** When requested from the page - when the user clicks on 'Update Order' -
	this function will reorganize the list so that it is displayed in the new order
	*/
	/* public Pagereference refreshQuestionList(){
		//setupQuestionList();
		return null;
	} */

	//------------------------------------------------------------------------------//

	/**
	* Why is this here?
	*/
	/* public List<String> getResponses() {
		List<SurveyQuestionResponse__c> qr = [SELECT Survey_Question__c, SurveyTaker__c, Response__c, Name FROM SurveyQuestionResponse__c limit 100];
		List<String> resp = new List<String>();
		for (SurveyQuestionResponse__c r : qr) {
			resp.add(r.Response__c);
		}
		return resp;
	} */

	/** Fills up the List of questions to be displayed on the Visualforce page
	*/
	public List<SFQuestion> getAQuestion() {
		System.debug('Accessible field: ' + Schema.Survey_Question__c.fields.Required__c.getDescribe().isAccessible());
		//qQuestion = '';
		//qChoices ='';
		//List<Schema.SobjectField> fields = new List<Schema.SobjectField>{
		//	Schema.Survey_Question__c.fields.Type__c,Schema.Survey_Question__c.fields.Survey__c,
		//	Schema.Survey_Question__c.fields.Required__c,Schema.Survey_Question__c.fields.Question__c,
		//	Schema.Survey_Question__c.fields.OrderNumber__c,Schema.Survey_Question__c.fields.Choices__c
		//};
		//SurveyForceUtil.AccessController.assertAuthorizedToView(Schema.Survey_Question__c.getSobjectType(), fields);
		List<Survey_Question__c> allQuestionsObject =
			[SELECT Type__c, Id, Survey__c, Required__c, Question__c, OrderNumber__c, Name, Choices__c
			FROM Survey_Question__c
			WHERE Survey__c =: surveyId WITH SECURITY_ENFORCED  ORDER BY OrderNumber__c ASC NULLS LAST];

		allQuestions = new List<SFQuestion>();

		Double old_OrderNumber = 0;
		Double new_OrderNumber;
		Double difference = 0;
		/* Make sure that the order number follow each other (after deleting a question, orders might not do so) */
		for (Survey_Question__c q : allQuestionsObject){
			new_OrderNumber = q.OrderNumber__c;
			difference = new_OrderNumber - old_OrderNumber - 1;
			if (difference > 0) {
				Double dd = double.valueOf(difference);
				Integer newOrderInt = dd.intValue();
				q.OrderNumber__c -= Integer.valueOf(newOrderInt);
			}
			old_OrderNumber = q.OrderNumber__c;
			SFQuestion theQ = new SFQuestion(q);
			allQuestions.add(theQ);
		}
		//allQuestionsSize = allQuestions.size();
		return allQuestions;
	}

	public PageReference submitResults()
	{
		System.debug('anonymousAnswer:' + anonymousAnswer );

		List <SurveyQuestionResponse__c> sqrList = new List<SurveyQuestionResponse__c>();
		try {

			List<Schema.SobjectField> fields = new List<Schema.SobjectField>{
				Schema.SurveyQuestionResponse__c.fields.Response__c,Schema.SurveyQuestionResponse__c.fields.Survey_Question__c,
				Schema.SurveyQuestionResponse__c.fields.SurveyTaker__c
			};
			SurveyForceUtil.AccessController.assertAuthorizedToCreate(Schema.SurveyQuestionResponse__c.getSobjectType(), fields);

			for (SFQuestion q : allQuestions) {

				System.debug('SFQuestion: ' + q);
				System.debug('Question type ' + q.questionType);
				System.debug('options ' + q.responseOptions);
				System.debug('survey answer ' + q.selectedOption);


				SurveyQuestionResponse__c sqr = new SurveyQuestionResponse__c();

				if (q.renderRadioVertical == true || q.renderRadioHorizontal == true) {
					if (q.required && (String.isBlank(q.selectedOption))) {
						Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out all required radio fields'));
						return null;
					}
					if (String.isNotBlank(q.selectedOption)) {
						sqr.Response__c = q.responseOptions[Integer.valueOf(q.selectedOption)].getLabel();
						sqr.Survey_Question__c = q.Id;
						sqrList.add(sqr);
					}
				}

				else if (q.renderMultiCheckboxes == true) {
					if (q.required && (q.selectedOptions == null || q.selectedOptions.isEmpty())) {
						Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out all required multi-select fields'));
						return null;
					}
					for (String opt : q.selectedOptions) {
						sqr = new SurveyQuestionResponse__c();
						if ( String.isNotBlank(opt) ) {
							sqr.Response__c = q.responseOptions[Integer.valueOf(opt)].getLabel();
							sqr.Survey_Question__c = q.Id;
							sqrList.add(sqr);
						}
					}
				}

				else if (q.renderFreeText == true) {
					if (q.required && String.isBlank(q.inputText)) {
						Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out all required text fields'));
						return null;
					}
					if ( String.isNotBlank(q.inputText) ) {
						sqr.Response__c = q.inputText;
						sqr.Survey_Question__c = q.Id;
						sqrList.add(sqr);
					}
				}
				System.debug('inserting response ' + sqr);
			}
			surveyTakerId = addSurveyTaker();
			System.debug('surveyTakerId ' + surveyTakerId);
			if(surveyTakerId != null){
				for (SurveyQuestionResponse__c sqr : sqrList)
				{
					sqr.SurveyTaker__c = surveyTakerId;
				}
				ViewSurveyControllerWithoutSharing.createSurveyQuestionResponse(sqrList);
				thankYouRendered = true;
				System.debug('setting thankyourendered to true');
			} else {
				System.debug('Setting thankyourendered to false and returning');
				thankYouRendered = false;
				return null;
			}
		}catch(SFDCAccessControlException e){ SurveyForceUtil.log('ViewSurveyController:submitResults():SFDCAccessControlException' + e.getMessage()); Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'An error occured while saving response'));
			if(getIsInternal()) { ApexPages.addMessages(e);	}
		}catch(Exception e){ SurveyForceUtil.log('ViewSurveyController:submitResults():Exception' + e.getMessage());
			if(getIsInternal()) { Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'An error occured while saving response')); ApexPages.addMessages(e);
			}
		}

		if(mysurvey.Thank_You_Link__c != null && mysurvey.Thank_You_Link__c != 'Undefined' && !String.isBlank(mysurvey.Thank_You_Link__c)){
			Pagereference pr = new Pagereference(mysurvey.Thank_You_Link__c);
			return pr;
		} else {
			return null;
		}
	}


	private Id addSurveyTaker() {
		SurveyTaker__c st = new SurveyTaker__c();

		Id retVal = null;

		if (surveyId == null && mySurvey.Id == null) { return null; }
		if( caseId.equalsIgnoreCase('None') || !(caseId instanceof Id) ){
			caseId = null;
		}
		if( contactId.equalsIgnoreCase('None') || !(contactId instanceof Id) ){
			contactId = null;
		}

		st.Contact__c  = (contactId == null) ? null : String.escapeSingleQuotes(contactId);
		st.Survey__c = (surveyId == null) ? mySurvey.id : surveyId;
		st.Completed__c = true;
		st.Case__c = (caseId == null) ? null : String.escapeSingleQuotes(caseId);

		/**
		* For noting the running user:
		* If is guest user, always store running user in User field
		* If is internal and forced anonymous, do not fill user field
		* If is internal, not forced anonymous, default to filling user
		*/

		// May uncomment this based on tracking and uniqueness requirements gathering
		/* if( st.Contact__c != null || st.Case__c != null) {
			st.User__c = UserInfo.getUserId();
		} else */
		if( UserInfo.getUserType() == 'Guest'){
			st.User__c = UserInfo.getUserId();
		} else if( mySurvey.All_Responses_Anonymous__c || anonymousAnswer == 'Anonymous' ){
			st.User__c = null;
		} else {
			st.User__c = UserInfo.getUserId();
			System.debug('else getuserid');
		}

		try {
			List<Schema.SobjectField> fields = new List<Schema.SobjectField>{
				Schema.SurveyTaker__c.fields.Survey__c, Schema.SurveyTaker__c.fields.Completed__c, Schema.SurveyTaker__c.fields.User__c
			};
			SurveyForceUtil.AccessController.assertAuthorizedToView(Schema.SurveyTaker__c.getSobjectType(), fields);

			SurveyForceUtil.AccessController.assertAuthorizedToCreate(Schema.SurveyTaker__c.getSobjectType(), fields);

			/**
			* note: there is a feature request to add a field to prevent duplicate surveys for guests on case/contact combination
			*/
			if(anonymousAnswer != 'Anonymous' && System.Site.getName() == null){
				//If survey is taken by Contact OR Case already then no need to take it again
				List<SurveyTaker__c> check = [SELECT Id, Contact__c, Survey__c, Case__c, User__c FROM SurveyTaker__c WHERE Survey__c = :surveyId AND
				((Contact__c != null AND Contact__c = :contactId) OR (Case__c != null AND Case__c = :caseId)
				) AND (User__c != null AND User__c = :st.User__c AND User__r.UserType != 'Guest') WITH SECURITY_ENFORCED ];
				if(check != null && check.size()>0){
					Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ' ' + System.Label.LABS_SF_You_have_already_taken_this_survey));
					System.debug('FOUND existing surveytaker');
					return retVal;
				}
			}

			//insert st;
			ViewSurveyControllerWithoutSharing.createSurveyTaken(st);
			retVal = st.Id;
			System.debug('surveytaker retval ' + retVal);

		}catch(SFDCAccessControlException e){ SurveyForceUtil.log('ViewSurveyController:AddSurveyTaker():SFDCAccessControlException' + e.getMessage());
		}catch(Exception e){ SurveyForceUtil.log('ViewSurveyController:AddSurveyTaker():Exception' + e.getMessage()); Apexpages.addMessages(e);
		}
		return retVal;
	}
}