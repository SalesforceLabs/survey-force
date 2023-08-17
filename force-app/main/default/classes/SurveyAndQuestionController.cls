@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class SurveyAndQuestionController {
	public Boolean showRadioVertical { get; set; }
	public Boolean showMultiCheckboxes { get; set; }
	public Boolean showFreeText { get; set; }
	public Boolean showRadioHorizontal { get; set; }
	public Boolean showPicklist { get; set; }
	public Id questionReference { get; set; }
	public String reportId { get; set; }

	public String qQuestion { get; set; }
	public Boolean qRequired { get; set; }
	public String qChoices { get; set; }
	public String questionType { get; set; }

	public String surveyThankYouText { get; set; }
	public String caseId { get; set; }
	public String newOrderW { get; set; }

	public SFMessage pageMessage {
		get {
			if (pageMessage == null) {
				pageMessage = new SFMessage();
			}
			return pageMessage;
		}
		set;
	}
	private List<Survey_Question__c> questionsList;
	private List<Survey_Question__c> queryQuestionsList(Boolean forceQuery) {
		if (questionsList == null || forceQuery) {
			questionsList = [
				SELECT Id, Type__c, Question__c, Choices__c, Required__c, OrderNumber__c, Survey__c, Name, Hide_on_Survey__c
				FROM Survey_Question__c
				WHERE Survey__c = :theSurvey.Id
				WITH USER_MODE
				ORDER BY OrderNumber__c ASC NULLS LAST
			];
		}
		return questionsList;
	}

	@TestVisible
	private List<SFQuestion> allQuestions {
		get {
			if (allQuestions == null) {
				allQuestions = getAQuestion();
			}
			return allQuestions;
		}
		set;
	}

	public Survey_Question__c theQuestion {
		get {
			if (theQuestion == null) {
				theQuestion = new Survey_Question__c(Required__c = true);
			}
			if (theQuestion.Survey__c == null) {
				theQuestion.Survey__c = theSurvey.Id;
			}
			return theQuestion;
		}
		set;
	}

	private Map<Id, Survey_Question__c> queryQuestionsMap(Boolean forceQuery) {
		return new Map<Id, Survey_Question__c>(queryQuestionsList(forceQuery));
	}

	@TestVisible
	private Survey__c theSurvey;

	public SurveyAndQuestionController(ApexPages.StandardController stdController) {
		theSurvey = (Survey__c) stdController.getRecord();
		surveyThankYouText = theSurvey.Thank_You_Text__c;

		/* if(Apexpages.currentPage().getParameters().containsKey('caId')) {
			caseId = String.escapeSingleQuotes(Apexpages.currentPage().getParameters().get('caId'));
		}

		if (caseId == null || caseId.length() < 5) {
			caseId = 'none';
		} */
		allQuestions = new List<SFQuestion>();

		qRequired = true;
		resetViewsToFalse();

		try {
			reportId = SurveyForceUtil.findReportId('Survey with Questions and Responses');
		} catch (SFDCAccessControlException e) {
			SurveyForceUtil.log('SurveyAndQuestionController:SurveyAndQuestionController():SFDCAccessControlException' + e.getMessage());
			pageMessage.setMessage(e.getMessage(), 'error');
			ApexPages.addMessages(e);
		} catch (Exception e) {
			SurveyForceUtil.log('SurveyAndQuestionController:SurveyAndQuestionController():Exception' + e.getMessage());
			pageMessage.setMessage(e.getMessage(), 'error');
			ApexPages.addMessages(e);
		}
	}

	public Pagereference makeNewQuestionLink() {
		theQuestion = null;
		questionReference = null;
		questionType = '';
		resetViewsToFalse();
		return null;
	}

	public Pagereference editQuestion() {
		if (questionReference == null) {
			return null;
		}
		setupEditQuestion();
		return null;
	}

	public Pagereference addQuestion() {
		resetViewsToFalse();
		return null;
	}

	private void setupEditQuestion() {
		List<Schema.SobjectField> fields = new List<Schema.SobjectField>{
			Schema.Survey_Question__c.fields.Type__c,
			Schema.Survey_Question__c.fields.Question__c,
			Schema.Survey_Question__c.fields.Choices__c,
			Schema.Survey_Question__c.fields.Required__c,
			Schema.Survey_Question__c.fields.OrderNumber__c,
			Schema.Survey_Question__c.fields.Survey__c,
			Schema.Survey_Question__c.fields.Name
		};
		SurveyForceUtil.AccessController.assertAuthorizedToView(Schema.Survey_Question__c.getSobjectType(), fields);

		if (queryQuestionsMap(false).containsKey(questionReference)) {
			theQuestion = queryQuestionsMap(false).get(questionReference);
		} else {
			theQuestion = null; // TODO - check if this works, since we have a lazy load getter
		}

		questionType = theQuestion.Type__c;
		setupQuestionFields();
	}

	public List<SelectOption> getQuestionTypeOptions() {
		//get picklist values
		Schema.DescribeFieldResult fieldResult = Survey_Question__c.Type__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

		//set/add them to selectOption list
		List<SelectOption> questionTypeOptions = new List<SelectOption>();
		questionTypeOptions.add(new SelectOption('', System.Label.LABS_SF_Default_Option_Label));
		for (Schema.PicklistEntry pe : ple) {
			questionTypeOptions.add(new SelectOption(pe.getValue(), pe.getLabel()));
		}
		return questionTypeOptions;
	}

	private void resetViewsToFalse() {
		showRadioVertical = false;
		showMultiCheckboxes = false;
		showFreeText = false;
		showRadioHorizontal = false;
		showPicklist = false; // future functionality
	}

	public Pagereference setupQuestionFields() {
		resetViewsToFalse();

		switch on questionType {
			when 'Multi-Select--Vertical' {
				showMultiCheckboxes = true;
			}
			when 'Single Select--Vertical' {
				showRadioVertical = true;
			}
			when 'Free Text', 'Free Text - Single Row Visible' {
				showFreeText = true;
			}
			when 'Single Select--Horizontal' {
				showRadioHorizontal = true;
			}
			when else {
				//future picklist functionality
				System.debug('Unknown question type');
			}
		}

		return null;
	}

	public Pagereference saveAndNewQuestion() {
		//saveAndNew = true;
		if (questionReference == null) {
			return saveNewQuestion();
		} else {
			return updateQuestion();
		}
	}

	public Pagereference controllerSavQuestion() {
		Pagereference pageRef;
		try {
			if (questionReference == null) {
				pageRef = saveNewQuestion();
			} else {
				pageRef = updateQuestion();
			}
		} catch (SFDCAccessControlException e) {
			SurveyForceUtil.log('SurveyAndQuestionController:controllerSavQuestion():SFDCAccessControlException' + e.getMessage());
			pageMessage.setMessage(e.getMessage(), 'error');
			ApexPages.addMessages(e);
		} catch (Exception e) {
			SurveyForceUtil.log('SurveyAndQuestionController:controllerSavQuestion():Exception' + e.getMessage());
			pageMessage.setMessage(e.getMessage(), 'error');
			ApexPages.addMessages(e);
		}
		questionType = '';

		return pageRef;
	}

	private Pagereference updateQuestion() {
		List<Schema.SobjectField> fields = new List<Schema.SobjectField>{
			Schema.Survey_Question__c.fields.Type__c,
			Schema.Survey_Question__c.fields.Choices__c,
			Schema.Survey_Question__c.fields.Choices__c,
			Schema.Survey_Question__c.fields.Required__c,
			Schema.Survey_Question__c.fields.OrderNumber__c,
			Schema.Survey_Question__c.fields.Name,
			Schema.Survey_Question__c.fields.Question__c
		};
		SurveyForceUtil.AccessController.assertAuthorizedToUpdate(Schema.Survey_Question__c.getSobjectType(), fields);

		//theQuestion is set up in an earlier call to editQuestion()

		//Don't need to use String.escapeSingleQuotes as we are using update, not dynamic update
		// theQuestion.Name = String.escapeSingleQuotes(theQuestion.Question__c);
		theQuestion.Name = theQuestion.Question__c;

		//Name is 80 characters long and cannot be changed. When survey question is more than that then it fails with following error
		//data value too large: ******** (max length=80):
		theQuestion.Name = (theQuestion.Name.length() > 80) ? theQuestion.Name.substring(0, 79) : theQuestion.Name;

		//Don't need to use String.escapeSingleQuotes as we are using update, not dynamic update
		// theQuestion.Choices__c = String.escapeSingleQuotes(theQuestion.Choices__c); //(String.isBlank(qChoices)) ? '' : qChoices;
		theQuestion.Choices__c = theQuestion.Choices__c; //(String.isBlank(qChoices)) ? '' : qChoices;

		//theQuestion.Required__c = qRequired;
		//theQuestion.Type__c = String.escapeSingleQuotes(questionType);
		theQuestion.Type__c = questionType;

		//theQuestion.Question__c = String.escapeSingleQuotes(theQuestion.Question__c);
		theQuestion.Question__c = theQuestion.Question__c;

		System.debug('theQuestion:' + theQuestion);
		try {
			update theQuestion;
			resetViewsToFalse();
			deleteOldResponses(theQuestion.id);
			questionReference = null;
			pageMessage.setMessage('Question was updated!', 'success');
		} catch (Exception e) {
			Apexpages.addMessages(e);
			pageMessage.setMessage(e.getMessage(), 'error');
			System.debug('Error: ' + e.getMessage() + ':' + e.getLineNumber() + ':' + e.getCause());
			SurveyForceUtil.log('SurveyAndQuestionController:updateQuestion():Exception ' + e.getMessage());
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Some error occured'));
		}

		theQuestion = null;

		return saveOrUpdateReturn();
	}

	/**
	 * TODO: Find a way to prevent deletion of questions with responses unless we delete the whole survey
	 * Why are we deleting all responses when we just updated a question?
	 * We now have a checkbox for hiding on a survey
	 */
	private void deleteOldResponses(Id qId) {
		//Delete doesn't need to check any fields
		SurveyForceUtil.AccessController.assertAuthorizedToDelete(Schema.SurveyQuestionResponse__c.getSobjectType());

		List<SurveyQuestionResponse__c> sResponses = [SELECT Id, Survey_Question__c FROM SurveyQuestionResponse__c WHERE Survey_Question__c = :qId];
		if (sResponses != null) {
			delete sResponses;
		}
	}

	private Pagereference saveOrUpdateReturn() {
		getAQuestion();
		PageReference pr = Page.SurveyPage;
		pr.getParameters().put('id', theSurvey.Id);
		questionType = '';
		return pr;
	}

	public Integer getNewQuestionNum() {
		return allQuestions.size();
	}

	private Pagereference saveNewQuestion() {
		//System.debug('in SaveNewQuestion');
		List<Schema.SobjectField> fields = new List<Schema.SobjectField>{
			Schema.Survey_Question__c.fields.Type__c,
			Schema.Survey_Question__c.fields.Choices__c,
			Schema.Survey_Question__c.fields.Choices__c,
			Schema.Survey_Question__c.fields.Required__c,
			Schema.Survey_Question__c.fields.OrderNumber__c,
			Schema.Survey_Question__c.fields.Survey__c,
			Schema.Survey_Question__c.fields.Name,
			Schema.Survey_Question__c.fields.Question__c
		};

		SurveyForceUtil.AccessController.assertAuthorizedToCreate(Schema.Survey_Question__c.getSobjectType(), fields);
		//System.debug('authorized');
		theQuestion.Survey__c = theSurvey.Id;

		//Don't need to use String.escapeSingleQuotes as we are using insert, not dynamic insert
		//theQuestion.Choices__c = (String.isBlank(theQuestion.Choices__c)) ? '' : String.escapeSingleQuotes(theQuestion.Choices__c);
		theQuestion.Choices__c = (String.isBlank(theQuestion.Choices__c)) ? '' : theQuestion.Choices__c;

		//System.debug('questionType ' + questionType);
		//System.debug('theQuestion.Type__c ' + theQuestion.Type__c);
		// theQuestion.Type__c = String.escapeSingleQuotes(questionType);
		theQuestion.Type__c = questionType;

		theQuestion.OrderNumber__c = getNewQuestionNum();

		//Don't need to use String.escapeSingleQuotes as we are using insert, not dynamic insert
		//theQuestion.Question__c = (String.isBlank(theQuestion.Question__c)) ? '' : String.escapeSingleQuotes(theQuestion.Question__c);
		theQuestion.Question__c = (String.isBlank(theQuestion.Question__c)) ? '' : theQuestion.Question__c;

		//Name is 80 characters long and cannot be changed. When survey question is more than that then it fails with following error
		//data value too large: ******** (max length=80):
		theQuestion.Name = (theQuestion.Question__c.length() > 80) ? theQuestion.Question__c.substring(0, 79) : theQuestion.Question__c;

		//System.debug('about to reset views');
		resetViewsToFalse();
		//System.debug('theQuestion: ' + theQuestion);
		try {
			insert theQuestion;
			pageMessage.setMessage(System.Label.LABS_SF_NewQAdded, 'success');
		} catch (Exception e) {
			pageMessage.setMessage(e.getMessage(), 'error');
			SurveyForceUtil.log('SurveyAndQuestionController:saveNewQuestion():Exception ' + e.getMessage());
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Some error occured'));
		}

		theQuestion = null;
		//theQuestion = new Survey_Question__c(Survey__c = theSurvey.Id);
		return saveOrUpdateReturn();
	}

	public PageReference updateOrderList() {
		if (newOrderW.length() <= 0) {
			return null;
		}
		System.debug('newOrderW ' + newOrderW);
		try {
			newOrderW = newOrderW.substring(0, newOrderW.length() - 1); // remove trailing comma

			List<String> idsToUpdate = newOrderW.split(',', -1);
			List<Survey_Question__c> qsToUpdate = new List<Survey_Question__c>();

			List<Schema.SobjectField> fields = new List<Schema.SobjectField>{ Schema.Survey_Question__c.fields.OrderNumber__c };
			//SurveyForceUtil.AccessController.assertAuthorizedToView(Schema.Survey_Question__c.getSobjectType(), fields);
			SurveyForceUtil.AccessController.assertAuthorizedToUpdate(Schema.Survey_Question__c.getSobjectType(), fields);

			Map<Id, Survey_Question__c> questionMap = new Map<Id, Survey_Question__c>([SELECT Id, OrderNumber__c FROM Survey_Question__c WHERE Id IN :idsToUpdate WITH USER_MODE]);

			for (Integer i = 0; i < idsToUpdate.size(); i++) {
				Survey_Question__c sqToUpdate = questionMap.get(idsToUpdate.get(i));
				sqToUpdate.OrderNumber__c = i;
				qsToUpdate.add(sqToUpdate);
			}

			update qsToUpdate;
			System.debug('Successfully updated question order?');
			pageMessage.setMessage('Question Order was successfully updated!', 'success');
		} catch (Exception e) {
			Apexpages.addMessages(e);
			pageMessage.setMessage(e.getMessage(), 'error');
			SurveyForceUtil.log('SurveyAndQuestionController:updateOrderList():Exception ' + e.getMessage());
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Some error occured'));
		}

		return null;
	}

	//------------------------------------------------------------------------------//
	public Pagereference deleteRefresh() {
		if (questionReference == null) {
			return null;
		}
		try {
			SurveyForceUtil.AccessController.assertAuthorizedToDelete(Schema.Survey_Question__c.getSobjectType());

			Survey_Question__c sq = [SELECT Id FROM Survey_Question__c WHERE Id = :questionReference WITH USER_MODE];
			delete sq;
			questionReference = null;

			allQuestions.clear();

			List<Schema.SobjectField> fields = new List<Schema.SobjectField>{
				Schema.Survey_Question__c.fields.Name,
				Schema.Survey_Question__c.fields.Type__c,
				Schema.Survey_Question__c.fields.Required__c,
				Schema.Survey_Question__c.fields.Question__c,
				Schema.Survey_Question__c.fields.OrderNumber__c,
				Schema.Survey_Question__c.fields.Choices__c
			};
			SurveyForceUtil.AccessController.assertAuthorizedToView(Schema.Survey_Question__c.getSobjectType(), fields);
			SurveyForceUtil.AccessController.assertAuthorizedToUpdate(Schema.Survey_Question__c.getSobjectType(), fields);

			List<Survey_Question__c> allQuestionsObject = queryQuestionsList(true);
			for (Integer i = 0; i < allQuestionsObject.size(); i++) {
				allQuestionsObject[i].OrderNumber__c = i;
				SFQuestion theQ = new SFQuestion(allQuestionsObject[i]);
				allQuestions.add(theQ);
			}
			//responses = getResponses();
			update allQuestionsObject;
		} catch (Exception e) {
			Apexpages.addMessages(e);
			pageMessage.setMessage(e.getMessage(), 'error');
		}
		return saveOrUpdateReturn();
	}

	//------------------------------------------------------------------------------//

	/** Fills up the List of questions to be displayed on the Visualforce page
	 */
	public List<SFQuestion> getAQuestion() {
		List<Schema.SobjectField> fields = new List<Schema.SobjectField>{
			Schema.Survey_Question__c.fields.Type__c,
			Schema.Survey_Question__c.fields.Survey__c,
			Schema.Survey_Question__c.fields.Required__c,
			Schema.Survey_Question__c.fields.Question__c,
			Schema.Survey_Question__c.fields.OrderNumber__c,
			Schema.Survey_Question__c.fields.Name,
			Schema.Survey_Question__c.fields.Choices__c
		};

		try {
			SurveyForceUtil.AccessController.assertAuthorizedToView(Schema.Survey_Question__c.getSobjectType(), fields);

			List<Survey_Question__c> allQuestionsObject = queryQuestionsList(true);
			allQuestions = new List<SFQuestion>();

			Double old_OrderNumber = 0;
			Double new_OrderNumber;
			Double difference = 0;
			/* Make sure that the order numbers follow each other (after deleting a question, orders might not do so) */
			for (Survey_Question__c q : allQuestionsObject) {
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
		} catch (SFDCAccessControlException e) {
			SurveyForceUtil.log('SurveyAndQuestionController:getAQuestion():SFDCAccessControlException' + e.getMessage());
		} catch (Exception e) {
			SurveyForceUtil.log('SurveyAndQuestionController:getAQuestion():Exception' + e.getMessage());
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Some error occured'));
		}
		return allQuestions;
	}
}