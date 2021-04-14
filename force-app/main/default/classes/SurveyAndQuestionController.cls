global virtual with sharing class SurveyAndQuestionController{

	public Boolean  showSingleSelect               {get; set;}
	public Boolean  showMultiSelect                {get; set;}
	public Boolean  showFreeText                   {get; set;}
	public Boolean  showRowQuestion                {get; set;}
	public Boolean  showSelectQuestionType         {get; set;}
	public String  questionReference              {get; set;}
	public String  reportId                       {get; set;}
	private Boolean saveAndNew = false;
	private String surveyOrderNumber;
	private Survey_Question__c questionToUpdate;
	public String  qQuestion                      {get; set;}
	public Boolean qRequired                      {get; set;}
	public String  qChoices                       {get; set;}
	public String questionType                {get; set;}
	public List<SFQuestion> allQuestions        {get; set;}
	public List<String> responses             {get; set;}
	public Integer allQuestionsSize           {get; set;}
	public String  surveyThankYouText         {get; set;}
	public String  caseId                     {get; set;}
	public List<String> newOrder {get;set;}
	public String newOrderW {get;set;}
	public SFMessage pageMessage {
		get{
			if(pageMessage == null){
				pageMessage = new SFMessage();
			}
			return pageMessage;
		}
		set;
	}

	@TestVisible private Survey__c theSurvey;

	public SurveyAndQuestionController (ApexPages.StandardController stdController){

		theSurvey = (Survey__c)stdController.getRecord();
		surveyThankYouText = theSurvey.Thank_You_Text__c;

		if(Apexpages.currentPage().getParameters().containsKey('caId')) {
			caseId = String.escapeSingleQuotes(Apexpages.currentPage().getParameters().get('caId'));
		}

		if (caseId == null || caseId.length() < 5) {
			caseId = 'none';
		}


		newOrder = new List<String>();

		try {
			allQuestions = new List<SFQuestion>();

			qRequired = true;
			resetViewsToFalse(true);
			showSelectQuestionType = true;

			reportId = SurveyForceUtil.findReportId('Survey with Questions and Responses');
		}  catch(SFDCAccessControlException e){
			SurveyForceUtil.log('SurveyAndQuestionController:SurveyAndQuestionController():SFDCAccessControlException' + e.getMessage());pageMessage.setMessage(e.getMessage(), 'error'); ApexPages.addMessages(e);
		} catch(Exception e) {
			SurveyForceUtil.log('SurveyAndQuestionController:SurveyAndQuestionController():Exception' + e.getMessage()); pageMessage.setMessage(e.getMessage(), 'error'); ApexPages.addMessages(e);
		}
	}

	public Pagereference makeNewQuestionLink(){
		questionReference = null;
		resetViewsToFalse(true);
		return null;
	}

	public Pagereference editQuestion(){
		if (questionReference == null)
		return null;
		setupEditQuestion();
		//Disable question type drop down as it's an older question
		showSelectQuestionType = false;
		return null;
	}

	public Pagereference addQuestion(){
		showSelectQuestionType = true;
		resetViewsToFalse(true);
		return null;
	}

	private void setupEditQuestion(){
		List<Schema.SobjectField> fields = new List<Schema.SobjectField>{
			Schema.Survey_Question__c.fields.Type__c, Schema.Survey_Question__c.fields.Question__c,
			Schema.Survey_Question__c.fields.Choices__c,Schema.Survey_Question__c.fields.Required__c,
			Schema.Survey_Question__c.fields.OrderNumber__c,Schema.Survey_Question__c.fields.Survey__c,
			Schema.Survey_Question__c.fields.Name
		};
		SurveyForceUtil.AccessController.assertAuthorizedToView(Schema.Survey_Question__c.getSobjectType(), fields);

		questionToUpdate =     [SELECT Type__c, Question__c, Id, Choices__c, Required__c, OrderNumber__c, Survey__c, Name
		FROM Survey_Question__c
		WHERE Id = :questionReference];
		questionType = questionToUpdate.Type__c;
		setupQuestionFields();
		qQuestion = questionToUpdate.Question__c;
		qRequired = questionToUpdate.Required__c;
		qChoices = questionToUpdate.Choices__c;
	}

	public List<SelectOption> getQuestionTypeOptions(){

		//get picklist values
		Schema.DescribeFieldResult fieldResult = Survey_Question__c.Type__c.getDescribe();
		List<Schema.PicklistEntry>  ple = fieldResult.getPicklistValues();

		//set/add them to selectOption list
		List<SelectOption> questionTypeOptions = new List<SelectOption>();
		questionTypeOptions.add(new SelectOption('',System.Label.LABS_SF_Default_Option_Label));
		for(Schema.PicklistEntry pe : ple){
			questionTypeOptions.add(new SelectOption(pe.getValue(), pe.getLabel()));
		}
		return questionTypeOptions;
	}

	private void resetViewsToFalse(Boolean clearFields){
		showSingleSelect =        false;
		showMultiSelect =         false;
		showFreeText =            false;
		showRowQuestion=          false;
		qRequired =                true;
		if(clearFields){
			qChoices =                 '';
			qQuestion =                '';
		}
	}

	public Pagereference setupQuestionFields(){
		showSelectQuestionType = true;
		if(questionType=='Multi-Select--Vertical'){
			showMultiSelect=true;
		}
		else if(questionType == 'Single Select--Vertical'){
			showSingleSelect = true;
		}
		else if(questionType == 'Free Text' || questionType == 'Free Text - Single Row Visible'){
			showFreeText = true;
		}
		else if(questionType == 'Single Select--Horizontal'){
			showRowQuestion = true;
		}
		return null;
	}

	public Pagereference saveAndNewQuestion(){
		saveAndNew = True;
		if(questionReference == null || questionReference.length() <5)
		{return saveNewQuestion();}
		else
		{return updateQuestion();}
	}

	public Pagereference controllerSavQuestion(){
		Pagereference pageRef;
		try{
			if(questionReference == null || questionReference.length() <5){
				pageRef = saveNewQuestion();
			}
			else{
				pageRef = updateQuestion();
			}
		}  catch(SFDCAccessControlException e){ SurveyForceUtil.log('SurveyAndQuestionController:SurveyAndQuestionController():SFDCAccessControlException' + e.getMessage());pageMessage.setMessage(e.getMessage(), 'error'); ApexPages.addMessages(e);
	} catch(Exception e) { SurveyForceUtil.log('SurveyAndQuestionController:SurveyAndQuestionController():Exception' + e.getMessage()); pageMessage.setMessage(e.getMessage(), 'error'); ApexPages.addMessages(e);
}

return pageRef;
}

private Pagereference updateQuestion(){
	List<Schema.SobjectField> fields = new List<Schema.SobjectField>{
		Schema.Survey_Question__c.fields.Type__c, Schema.Survey_Question__c.fields.Choices__c,
		Schema.Survey_Question__c.fields.Choices__c,Schema.Survey_Question__c.fields.Required__c,
		Schema.Survey_Question__c.fields.OrderNumber__c,
		Schema.Survey_Question__c.fields.Name, Schema.Survey_Question__c.fields.Question__c
	};
	SurveyForceUtil.AccessController.assertAuthorizedToUpdate(Schema.Survey_Question__c.getSobjectType(), fields);

	//questionToUpdate is setup in an earlier call to editQuestion()
	questionToUpdate.Name = String.escapeSingleQuotes(qQuestion);
	//Name is 80 characters long and cannot be changed. When survey question is more than that then it fails with following error
	//data value too large: ******** (max length=80):
	questionToUpdate.Name = (questionToUpdate.Name.length()>80) ? questionToUpdate.Name.substring(0,79) : questionToUpdate.Name;
	questionToUpdate.Choices__c = (String.isEmpty(qChoices)) ? '' : qChoices; //String.escapeSingleQuotes(qChoices);
	questionToUpdate.Required__c = qRequired;
	questionToUpdate.Type__c = String.escapeSingleQuotes(questionType);
	questionToUpdate.Question__c = String.escapeSingleQuotes(qQuestion);
	System.debug('questionToUpdate:' + questionToUpdate);
	try{
		update questionToUpdate;
		resetViewsToFalse(true);
		deleteOldResponses(questionToUpdate.id);
		questionReference = null;
		pageMessage.setMessage('Question was updated!', 'success');
	}catch(Exception e){  Apexpages.addMessages(e); pageMessage.setMessage(e.getMessage(), 'error'); System.debug('Error: ' + e.getMessage() + ':' + e.getLineNumber() + ':' + e.getCause());
}

return saveOrUpdateReturn();
}

private void deleteOldResponses(String qId){
	//Delete doesn't need to check any fields
	SurveyForceUtil.AccessController.assertAuthorizedToDelete(Schema.SurveyQuestionResponse__c.getSobjectType());

	List <SurveyQuestionResponse__c> sResponses = [SELECT Id, Survey_Question__c FROM SurveyQuestionResponse__c WHERE Survey_Question__c = :qId];
	if(sResponses != null)
	delete sResponses;
}

private Pagereference saveOrUpdateReturn(){
	setupQuestionList();
	//Pagereference pr = new Pagereference('/apex/SurveyPage?id='+surveyRef);
	Pagereference pr = new PageReference(Page.SurveyPage.getUrl() + '?id=' + theSurvey.Id);
	questionType = '--SELECT--';
	if(saveAndNew != null  && saveAndNew == true){
		saveAndNew = False;
		showSelectQuestionType = true;
		return pr;
	}
	else{
		showSelectQuestionType = false;
		return pr;
	}
}

public Integer getNewQuestionNum(){
	if(allQuestions == null) return 0;
	else{
		return allQuestions.size();
	}
}

private Pagereference saveNewQuestion(){
	List<Schema.SobjectField> fields = new List<Schema.SobjectField>{
		Schema.Survey_Question__c.fields.Type__c, Schema.Survey_Question__c.fields.Choices__c,
		Schema.Survey_Question__c.fields.Choices__c,Schema.Survey_Question__c.fields.Required__c,
		Schema.Survey_Question__c.fields.OrderNumber__c,Schema.Survey_Question__c.fields.Survey__c,
		Schema.Survey_Question__c.fields.Name, Schema.Survey_Question__c.fields.Question__c
	};
	SurveyForceUtil.AccessController.assertAuthorizedToCreate(Schema.Survey_Question__c.getSobjectType(), fields);

	Survey_Question__c newQuestion = new Survey_Question__c();
	newQuestion.Survey__c = theSurvey.Id;
	newQuestion.Name = String.escapeSingleQuotes(qQuestion);
	//Name is 80 characters long and cannot be changed. When survey question is more than that then it fails with following error
	//data value too large: ******** (max length=80):
	newQuestion.Name = (newQuestion.Name.length()>80) ? newQuestion.Name.substring(0,79) : newQuestion.Name;
	newQuestion.Choices__c = qChoices; //String.escapeSingleQuotes(qChoices);
	newQuestion.Required__c = qRequired;
	newQuestion.Type__c = String.escapeSingleQuotes(questionType);
	newQuestion.OrderNumber__c = getNewQuestionNum();
	newQuestion.Question__c = String.escapeSingleQuotes(qQuestion);
	resetViewsToFalse(true);
	try{
		insert newQuestion;
		pageMessage.setMessage('New question was added!', 'success');
	}catch(Exception e){ pageMessage.setMessage(e.getMessage(), 'error');
}
return saveOrUpdateReturn();
}

/* Called during the setup of the page.
Retrieve questions and responses from DB and inserts them in 2 lists. */
public Integer setupQuestionList(){
	getAQuestion();
	return allQuestions.size();
}

public PageReference updateOrderList()
{
	if(newOrderW.length() <= 0)
	{
		return null;
	}

	try {
		newOrderW = newOrderW.substring(0, newOrderW.length() - 1);

		List<String> idsToUpdate = newOrderW.split(',', -1);
		List<Survey_Question__c> qsToUpdate = new List<Survey_Question__c>();


		List<Schema.SobjectField> fields = new List<Schema.SobjectField>{
			Schema.Survey_Question__c.fields.OrderNumber__c
		};
		SurveyForceUtil.AccessController.assertAuthorizedToView(Schema.Survey_Question__c.getSobjectType(), fields);
		SurveyForceUtil.AccessController.assertAuthorizedToUpdate(Schema.Survey_Question__c.getSobjectType(), fields);

		Map<Id, Survey_Question__c> questionMap = new Map<Id, Survey_Question__c>([SELECT Id, OrderNumber__c FROM Survey_Question__c WHERE Id in :idsToUpdate]);
		Survey_Question__c sqToUpdate;

		for (Integer i = 0; i < idsToUpdate.size(); i++) {
			sqToUpdate = questionMap.get(idsToUpdate.get(i));
			sqToUpdate.OrderNumber__c = i;
			qsToUpdate.add(sqToUpdate);
		}

		update qsToUpdate;
		pageMessage.setMessage('Question Order was successfully updated!', 'success');
	}catch(Exception e){ Apexpages.addMessages(e); pageMessage.setMessage(e.getMessage(), 'error');

}

return null;
}

//------------------------------------------------------------------------------//
/** When requested from the page - when the user clicks on 'Update Order' -
this function will reorganize the list so that it is displayed in the new order
*/
public Pagereference refreshQuestionList(){
	setupQuestionList();
	return null;
}



//------------------------------------------------------------------------------//
public Pagereference deleteRefresh(){
	if (questionReference == null ){
		return null;
	}
	try{
		SurveyForceUtil.AccessController.assertAuthorizedToDelete(Schema.Survey_Question__c.getSobjectType());

		Survey_Question__c sq = [SELECT Id, Name FROM Survey_Question__c WHERE Id =: questionReference];
		delete sq;
		questionReference = null;

		allQuestions.clear();
		Double j = 0.0;

		List<Schema.SobjectField> fields = new List<Schema.SobjectField>{
			Schema.Survey_Question__c.fields.Name,
			Schema.Survey_Question__c.fields.Type__c,Schema.Survey_Question__c.fields.Required__c,
			Schema.Survey_Question__c.fields.Question__c, Schema.Survey_Question__c.fields.OrderNumber__c,
			Schema.Survey_Question__c.fields.Choices__c
		};
		SurveyForceUtil.AccessController.assertAuthorizedToView(Schema.Survey_Question__c.getSobjectType(), fields);
		SurveyForceUtil.AccessController.assertAuthorizedToUpdate(Schema.Survey_Question__c.getSobjectType(), fields);

		List<Survey_Question__c> allQuestionsObject =
		[SELECT Type__c, Id, Survey__c, Required__c,
		Question__c, OrderNumber__c, Name, Choices__c
		FROM Survey_Question__c
		WHERE Survey__c =: theSurvey.Id
		ORDER BY OrderNumber__c];
		for (Integer i =0; i< allQuestionsObject.size(); i++){
			allQuestionsObject[i].OrderNumber__c= j;
			SFQuestion theQ = new SFQuestion(allQuestionsObject[i]);
			allQuestions.add(theQ);
			j = j+1.0;
		}
		responses = getResponses();
		update allQuestionsObject;
	}catch(Exception e){ Apexpages.addMessages(e); pageMessage.setMessage(e.getMessage(), 'error');
}
return saveOrUpdateReturn();
}

//------------------------------------------------------------------------------//


public List<String> getResponses() {
	List<Schema.SobjectField> fields = new List<Schema.SobjectField>{
		Schema.SurveyQuestionResponse__c.fields.Survey_Question__c, Schema.SurveyQuestionResponse__c.fields.SurveyTaker__c,
		Schema.SurveyQuestionResponse__c.fields.Response__c,Schema.SurveyQuestionResponse__c.fields.Name
	};
	SurveyForceUtil.AccessController.assertAuthorizedToView(Schema.SurveyQuestionResponse__c.getSobjectType(), fields);

	List<SurveyQuestionResponse__c> qr = [SELECT Survey_Question__c, SurveyTaker__c, Response__c, Name FROM SurveyQuestionResponse__c limit 100];
	List<String> resp = new List<String>();
	for (SurveyQuestionResponse__c r : qr) {
		resp.add(r.Response__c);
	}

	return resp;
}



/** Fills up the List of questions to be displayed on the Visualforce page
*/
public List<SFQuestion> getAQuestion() {
	List<Schema.SobjectField> fields = new List<Schema.SobjectField>{
		Schema.Survey_Question__c.fields.Type__c, Schema.Survey_Question__c.fields.Survey__c,
		Schema.Survey_Question__c.fields.Required__c,Schema.Survey_Question__c.fields.Question__c,
		Schema.Survey_Question__c.fields.OrderNumber__c,Schema.Survey_Question__c.fields.Name,
		Schema.Survey_Question__c.fields.Choices__c
	};

	try{
		SurveyForceUtil.AccessController.assertAuthorizedToView(Schema.Survey_Question__c.getSobjectType(), fields);


		List<Survey_Question__c> allQuestionsObject =
		[SELECT s.Type__c, s.Id, s.Survey__c, s.Required__c, s.Question__c,
		s.OrderNumber__c, s.Name, s.Choices__c
		FROM Survey_Question__c s
		WHERE s.Survey__c =: theSurvey.Id ORDER BY s.OrderNumber__c];
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
		allQuestionsSize = allQuestions.size();
	}catch(SFDCAccessControlException e){
		SurveyForceUtil.log('ViewSurveyController:submitResults():SFDCAccessControlException' + e.getMessage());
	}catch(Exception e){
		SurveyForceUtil.log('ViewSurveyController:submitResults():SFDCAccessControlException' + e.getMessage());Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Some error occured'));}
		return allQuestions;
	}

}