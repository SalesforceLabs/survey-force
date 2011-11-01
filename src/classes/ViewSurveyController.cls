/* Controller associated with pages rendering the survey.
 * Used by SurveyPage, ResultsPage, TakeSurvey
 */
global virtual with sharing class ViewSurveyController {
	public String  qQuestion                      {get; set;}
  public Boolean qRequired                      {get; set;}
  public String  qChoices                       {get; set;}
	public String surveyName			            {get; set;}
	public String surveyHeader                {get; set;}
	public String surveyId 				            {get; 
		set{
			this.surveyId = value;
			init();
		}
	}	
	public String renderSurveyPreview	        {get; set;}  
	public String questionName			          {get; set;}  
	public String questionType			          {get; set;}
	public Boolean questionRequired		        {get; set;}
  public List<SelectOption> singleOptions   {get; set;}	
	public List<question> allQuestions        {get; set;}
	public List<String> responses			        {get; set;}
	public Integer allQuestionsSize			      {get; set;}
	public String  templateURL                {get; set;}
	public String  surveyThankYouText         {get; set;}
	public String  surveyThankYouURL          {get; set;}
  public String  caseId                     {get; set;}
  	public String anonymousAnswer {get;set;}
  	public List<SelectOption> anonymousOrUser {get;set;}
  	public Boolean isInternal {get;set;}
  	public String baseURL {get;set;}
  	
  	public String userId{get;set;}
  	public String userName{get;set;}
  	
    /* Retrieves the list of questions, the survey name, after retrieving the 
       necessary parameters from the url.
    */
 //------------------------------------------------------------------------------// 
	public ViewSurveyController(ApexPages.StandardController stdController) {
		// Get url parameters
		surveyId = Apexpages.currentPage().getParameters().get('id');
    caseId   = Apexpages.currentPage().getParameters().get('caId');
		if(caseId ==null || caseId.length()<5){
			caseId = 'none';
		}
		// By default the preview is not showing up
		renderSurveyPreview = 'false';

		init();
	} 
	
	public ViewSurveyController(viewShareSurveyComponentController controller)
	{
		surveyId = Apexpages.currentPage().getParameters().get('id');
    	caseId   = Apexpages.currentPage().getParameters().get('caId');
		if(caseId ==null || caseId.length()<5){
			caseId = 'none';
		}
		// By default the preview is not showing up
		renderSurveyPreview = 'false';
		init();
	}
	
	
	public void init()
	{
		if (surveyId != null){ 
			// Retrieve all necessary information to be displayed on the page
			allQuestions = new List<question>();
			setSurveyNameAndThankYou(surveyId);
			anonymousOrUser = new List<SelectOption>();
			anonymousOrUser.add(new SelectOption('Anonymous','Anonymous'));
			anonymousOrUser.add(new SelectOption('User','User ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName()));
			anonymousAnswer = 'Anonymous';
			isInternal =true;
			String urlBase = URL.getSalesforceBaseUrl().toExternalForm();
			baseURL = urlBase;
			
			userId = UserInfo.getUserId();
			userName = UserInfo.getName();
			
			String profileId = UserInfo.getProfileId();
			try
			{
				Profile p = [select Id, UserType from Profile where Id=:profileId];
				if (p.UserType == 'Guest')
				{
					isInternal = false;
				}
				else
				{
					isInternal = true;
				}
			}
			catch (Exception e){
				isInternal = false;
			}
			
			
			
			
			
			//allQuestionsSize = setupQuestionList();
		}		
	}
	
	
	

//------------------------------------------------------------------------------//	
	private static Testmethod void testViewSurveyController() {
  		SurveyTestingUtil tu = new SurveyTestingUtil();
  		Apexpages.currentPage().getParameters().put('id',tu.surveyId);	
  		Apexpages.Standardcontroller stc;	
  		ViewSurveyController vsc = new ViewSurveyController(stc);
  		vsc.getAQuestion();
  		System.assert(vsc.allQuestionsSize == 4);
  		System.assert(tu.surveyId != null);
	}
//----------------------------------------------------------------------------//	
	
	/* Called during the setup of the page. 
	   Retrieve questions and responses from DB and inserts them in 2 lists. */
	public Integer setupQuestionList(){
		/*allQuestions.clear();
		List<Survey_Question__c> allQuestionsObject = 
										[Select Type__c, Id, Survey__c, Required__c, 
										Question__c, OrderNumber__c, Name, Choices__c
										From Survey_Question__c  
										WHERE Survey__c =: surveyId
										order by OrderNumber__c];
		for (Survey_Question__c q : allQuestionsObject){
			question theQ = new question(q);
			allQuestions.add(theQ);
		}
		//responses = getResponses();//taken out because it was SOQL heavy//*/
		getAQuestion();
		return allQuestions.size();
	}
	
	
   /** Sets the survey's name variable
	*  param: sID	The survey ID as specified in the DB
	*/
	public void setSurveyNameAndThankYou(String sId){
		Survey__c s = [SELECT Name, Id, URL__c, Thank_You_Text__c, thankYouText__c, thankYouLink__c, Survey_Header__c FROM Survey__c WHERE Id =:sId];
		surveyName = s.Name;
		surveyHeader = s.Survey_Header__c;
		templateURL = s.URL__c+'id='+sId;//+'&cId={!Contact.Id}'+'&caId='+'{!Case.id}';
		surveyThankYouText = s.Thank_You_Text__c;
		if (surveyThankYouText == null)
		{
			surveyThankYouText = 'Thank you for responding to this survey.';
		}
		surveyThankYouURL = s.thankYouLink__c;
	}
	
//------------------------------------------------------------------------------//   
  public Pagereference updateSurveyName(){
	  Survey__c s = [SELECT Name, Id, URL__c, thankYouText__c, thankYouLink__c FROM Survey__c WHERE Id =:surveyId];
	  s.Name = surveyName;
	  try{
	  	update s;
	  }catch (Exception e){
	  	Apexpages.addMessages(e);
	  }
	  return null;
  } 
  
  private static Testmethod void testUpdateSurveyName() {
      SurveyTestingUtil tu = new SurveyTestingUtil();
      Apexpages.currentPage().getParameters().put('id',tu.surveyId);  
      Apexpages.Standardcontroller stc; 
      ViewSurveyController vsc = new ViewSurveyController(stc);
      vsc.surveyName = 'new name';
      system.assert(vsc.updateSurveyName() == null);
      
  }
//------------------------------------------------------------------------------//		
	public Pagereference updateSurveyThankYouAndLink(){
		Survey__c s = [SELECT Name, Id, URL__c, thankYouText__c, thankYouLink__c FROM Survey__c WHERE Id =:surveyId];
		s.thankYouText__c = surveyThankYouText;
		s.thankYouLink__c = surveyThankYouURL;
		try{
			update s;
		}catch(Exception e){
			Apexpages.addMessages(e);
		}
		return null;
	}
  
  private static Testmethod void testupdateSurveyThankYouAndLink() {
    SurveyTestingUtil tu = new SurveyTestingUtil();
    Apexpages.currentPage().getParameters().put('id',tu.surveyId);  
    Apexpages.Standardcontroller stc; 
    ViewSurveyController vsc = new ViewSurveyController(stc);
    vsc.surveyThankYouText = 'new stuff';
    vsc.surveyThankYouURL = 'more new stff';
    system.assert(vsc.updateSurveyThankYouAndLink()==null);
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
	private static Testmethod void testRefreshQuestionList() {
  		SurveyTestingUtil tu = new SurveyTestingUtil();
    	Apexpages.currentPage().getParameters().put('id',tu.surveyId);
  		Apexpages.Standardcontroller stc;	
  		ViewSurveyController vsc = new ViewSurveyController(stc);
  		vsc.getAQuestion();
  		
  		// Retrieve questions for this survey
  		List<Survey_Question__c> sq = new List<Survey_Question__c>();
  		sq = [Select id, orderNumber__c from Survey_Question__c];
  		
  		// get question with orderNumber 1
  		Survey_Question__c first = [Select id, orderNumber__c from Survey_Question__c Where orderNumber__c =: 1 and Survey__c =: tu.surveyId];
  		System.assert(first.orderNumber__c == 1 );  	
  		
  		// Specify the new order	
  		List<String> newOrder = new List<String>();
  		newOrder.add(vsc.allQuestions[2].id);
  		newOrder.add(vsc.allQuestions[0].id);
  		newOrder.add(vsc.allQuestions[1].id);
  		newOrder.add(vsc.allQuestions[3].id);
  		
  		ViewSurveyController.updateQuestionOrder(newOrder);
  		
  		// Verify that the question with order 1 is not the same as the one retrieved previously
  		Survey_Question__c second = [Select id, orderNumber__c from Survey_Question__c Where orderNumber__c =: 1 and Survey__c =: tu.surveyId];
  		System.assert(second.id != first.id);
  		
  		// update the question list, and make sure it has been modified as well
  		vsc.refreshQuestionList();
 		System.assert(vsc.allQuestions[1].id != first.id);
  		
	}
//------------------------------------------------------------------------------//		

	public static Webservice String getResponses(List<String> resp) {
    
    if(resp.size()<=2)
      return 'false';
 		
 		String userId = resp.get(resp.size()-5);
 		String surveyId = resp.get(resp.size()-4);
 		String caseId = resp.get(resp.size()-3);
 		String rUserId = resp.get(resp.size()-2);
 		String anonOrUser = resp.get(resp.size()-1);
 		System.debug('***userID' + userId);
 		System.debug('***anonOrUser' + anonOrUser);
 		
 		if(caseId.toUpperCase()=='NONE'||caseId == null || caseId.length()<3)
 		 caseId = null;
 		
 		if(userId.toUpperCase() == 'NONE')
      userId = null;
      
      	if(rUserId.toUpperCase() == 'NONE')
      		rUserId = null;
  	List <SurveyTaker__c> stList;
    /*
 		if (userId == null || userId.length() < 10){
 			st = new SurveyTaker__c();
 			st.Case__c = null;
 			st.Contact__c = null;
 			try{  
 			  insert st;
	 		}catch(Exception e){
	        return 'contact';
      }
 		}*/
 		
 		 
	 	try{
	 	 	stList = [Select id, contact__c, Taken__c, User__c from SurveyTaker__c where Contact__c=:userId AND Survey__c= :surveyId AND Case__c= :caseId and User__c=:rUserId];
	 	}catch(Exception e){
	 		return 'problem';
	 	}
 		
 		SurveyTaker__c st;
 		if(stList == null || stList.size()==0)
 		 return 'problem';
 		else
 		{
 		 st = stList[0];
 		
 		}
 		
 		resp.remove(resp.size()-1);
 		resp.remove(resp.size()-1);
 		resp.remove(resp.size()-1);
 		resp.remove(resp.size()-1);
 		resp.remove(resp.size()-1);
 		
 		List<Survey_Question__c> allQuestions = [Select Id, Type__c, Required__c from Survey_Question__c Where Survey__c=:surveyId ORDER BY OrderNumber__c];
		 
		List<String> questionsId = new List<String>();
		
		for (Survey_Question__c q : allQuestions)
 			questionsId.add(q.Id);
 		
 		//new response list  
 		List <SurveyQuestionResponse__c> sqrList = new List<SurveyQuestionResponse__c>();
 		
		Integer i = 0;
		for(String r:resp) {
			if(!checkRequired(r, allQuestions[i])){
        return 'false';				
			}
			if(allQuestions[i].Type__c=='Multi-Select--Vertical'){
				sqrList.addAll(handleMultiSelectResponse(r, String.valueOf(st.Id), questionsId[i]));
			}
			else{
				SurveyQuestionResponse__c sqr = new SurveyQuestionResponse__c();
				sqr.SurveyTaker__c = st.Id;
				sqr.Response__c = r;
				sqr.Survey_Question__c = questionsId[i];
				sqrList.add(sqr);
			}
			i++;
			//insert sqr;
		  
		}
		
		try{
			insert sqrList;
		}catch(exception e){
			return 'false';
		}
		
		return 'true';
	}
//------------------------------------------------------------------------------// 
  private static List<SurveyQuestionResponse__c> handleMultiSelectResponse(String response, String surveyTakerId, String questionId){
	 List <String> responses = response.split('&@');
	 List<SurveyQuestionResponse__c> sqrList = new List<SurveyQuestionResponse__c>();
	 for( String r:responses){
	 	SurveyQuestionResponse__c sqr = new SurveyQuestionResponse__c();
	 	sqr.Response__c = r;
	 	sqr.SurveyTaker__c = surveyTakerId;
	 	sqr.Survey_Question__c = questionId;
	 	sqrList.add(sqr);
	 }
   return sqrList;
  }
//------------------------------------------------------------------------------//    
  private static boolean checkRequired(String response, Survey_Question__c question){
  	if(question.Required__c == true){
  		if(response == null || response =='NO RESPONSE')
  		  return false;
  	}
    return true;
  }	
//------------------------------------------------------------------------------//		
	private static TestMethod void testGetResponses() {
  		SurveyTestingUtil tu = new SurveyTestingUtil();
    	Apexpages.currentPage().getParameters().put('id',tu.surveyId);
  		Apexpages.Standardcontroller stc;	
  		ViewSurveyController vsc = new ViewSurveyController(stc);
  		vsc.getAQuestion();

		List<String> resp = new List<String>();
		resp.add('one');
		resp.add('two');
		resp.add(tu.contactId);
		resp.add(tu.surveyId);
		resp.add('NONE');
		resp.add('NONE');
		resp.add('User');
		System.assert('true'==ViewSurveyController.getResponses(resp));
		
	}
//------------------------------------------------------------------------------//		
	
	
	

   /** Redirects the page that displays the detailed results of the survey, 
   	   from all users who took the survey.
    */
  	public PageReference resultPage() {
  		return new PageReference('/apex/ResultsPage?id='+surveyId);
  	}

   /** Redirects the page that displays the thank you note 
    */
  	public PageReference thankYouPage() {
  		return new PageReference('http://surveysite-developer-edition.na7.force.com/ThankYouPage');
  	}

    private static testmethod void testResultAndThankYouPage(){
    	SurveyTestingUtil tu = new SurveyTestingUtil();
      Apexpages.currentPage().getParameters().put('id',tu.surveyId);  
      Apexpages.Standardcontroller stc; 
      ViewSurveyController vsc = new ViewSurveyController(stc);
      vsc.getAQuestion();
      System.assert(vsc.resultPage() != null);
      System.assert(vsc.thankYouPage() != null);
    	
    }
  	
   /** Called from a VisualForce page to delete a question from the DB
  	*  param: question ID	The Id of the question as specified in the DB
  	*  returns 'true' on success
  	*/
	public static webservice String deleteQuestion(String questionID){
		Survey_Question__c sq = [Select Id, Name FROM Survey_Question__c WHERE Id =: questionID];
		delete sq;
		
		return 'true'; 
	}
//------------------------------------------------------------------------------//    	
	public Pagereference deleteRefresh(){
		 allQuestions.clear();
		 Double j = 0.0;
    List<Survey_Question__c> allQuestionsObject = 
                    [Select Type__c, Id, Survey__c, Required__c, 
                    Question__c, OrderNumber__c, Name, Choices__c
                    From Survey_Question__c  
                    WHERE Survey__c =: surveyId
                    order by OrderNumber__c];
    for (Integer i =0; i< allQuestionsObject.size(); i++){
      allQuestionsObject[i].OrderNumber__c= j;
      question theQ = new question(allQuestionsObject[i]);
      allQuestions.add(theQ);
      j = j+1.0;
    }
    responses = getResponses();
    try{
    	update allQuestionsObject;
    }catch(Exception e){
    	Apexpages.addMessages(e);
    }
	  return null;
	}
	//------------------------------------------------------------------------------//   
  private static testmethod void testDeleteRefresh(){
  	SurveyTestingUtil tu = new SurveyTestingUtil();
      Apexpages.currentPage().getParameters().put('id',tu.surveyId);  
      Apexpages.Standardcontroller stc; 
      ViewSurveyController vsc = new ViewSurveyController(stc);
      System.assert(null==vsc.deleteRefresh());
  }
//------------------------------------------------------------------------------//		
	private static TestMethod void testDeleteQuestion() {
  		SurveyTestingUtil tu = new SurveyTestingUtil();
    	Apexpages.currentPage().getParameters().put('id',tu.surveyId);
  		Apexpages.Standardcontroller stc;	
  		ViewSurveyController vsc = new ViewSurveyController(stc);
  		vsc.getAQuestion();
  		
  		// Get a question to delete
  		Survey_Question__c sq = [Select id, orderNumber__c from Survey_Question__c Where orderNumber__c =: 1 and Survey__c =: tu.surveyId];
  		ViewSurveyController.deleteQuestion(sq.id);
  		List<Survey_Question__c> sqs = [Select id, orderNumber__c from Survey_Question__c Where Survey__c =: tu.surveyId];
  		for (Survey_Question__c s: sqs)
  			System.assert(s.OrderNumber__c != 1);
  		List<question> listQ = new List<question>();
  		listQ = vsc.getAQuestion();
	}
//------------------------------------------------------------------------------//	

  /** Called from a VisualForce page to update the order number of the questions
   *  in the DB.
   *  param qOrder:	List of String to specify the new order of the questions
   *  returns 'true' on success
   */	
   public static webservice String updateQuestionOrder(List <String> qOrder){
    Integer i;
    String qId;
    Survey_Question__c q;
    for(i=0; i<qOrder.size(); i++){
    	qId = qOrder[i];
    	System.debug('First ID is '+qId+ '  order '+ i );
    	q = [select OrderNumber__c, id from Survey_Question__c where id = :qId];
    	q.OrderNumber__c = i;
    	update q;
    	q = [select OrderNumber__c, id from Survey_Question__c where id = :qId];
    	System.debug('Second ID is '+q.Id+ '  order '+ q.OrderNumber__c );
    	
    }
    return 'true';
  }
//------------------------------------------------------------------------------//  

   /** 
    */
	public List<String> getResponses() {
		List<SurveyQuestionResponse__c> qr = [Select Survey_Question__c, SurveyTaker__c, Response__c, Name From SurveyQuestionResponse__c limit 100];
		List<String> resp = new List<String>();
		for (SurveyQuestionResponse__c r : qr) {
			resp.add(r.Response__c);
		}
		
		return resp;
	}  

   /** Class: question
    *  Retrieves the question information and puts it in the question object
    */		
	public class question{
  	  public String   name                   {get; set;}
  	  public String   id			               {get; set;}
      public String   question	             {get; set;}
      public String   orderNumber            {get; set;}
      public String   choices                {get; set;}
      public List<SelectOption> singleOptions{get; set;}
      public List<SelectOption> multiOptions {get; set;}
      public Boolean  required               {get; set;}
      public String   questionType           {get; set;}	
      public String   surveyName	           {get; set;}
      public String   renderFreeText		     {get; set;}
	    public String   renderSelectRadio 	   {get; set;}
	    public String   renderSelectCheckboxes {get; set;} 
	    public String   renderSelectRow        {get; set;}
      public List<String> responses			     {get; set;}
      public String   singleOptionsForChart	 {get; set;}
      public String   qResultsForChart		   {get; set;} 
  	  public List<String> strList	           {get; set;} // The question's option as a list of string
      public List<Integer> resultsCounts 	   {get; set;} // The count of each response to a question's choices
      public List<SelectOption> rowOptions   {get; set;}
      public boolean  noData                 {get; set;}
      
	  /** Fills up the question object
	   *  param:	Survey_Question__c 
   	   */  	  
  	 public question(Survey_Question__c sq) {
      	name = sq.Name;
      	id = sq.Id;
      	System.debug('in Question found one with id '+id);
      	question = sq.Question__c;
      	orderNumber = String.valueOf(sq.OrderNumber__c+1);
      	choices = sq.Choices__c;
      	required = sq.Required__c;
      	questionType = sq.Type__c;
      	singleOptionsForChart = ' ';
     if (sq.Type__c=='Single Select--Vertical'){
				renderSelectRadio='true';
				singleOptions = stringToSelectOptions(choices);
				renderSelectCheckboxes='false';
				renderFreeText='false';
				renderSelectRow = 'false';
      }
     else if (sq.Type__c=='Multi-Select--Vertical'){		
				renderSelectCheckboxes='true';
				multiOptions = stringToSelectOptions(choices);
				renderSelectRadio='false';
				renderFreeText='false';
	      renderSelectRow = 'false';
      }
     else if (sq.Type__c=='Single Select--Horizontal'){   
	      renderSelectCheckboxes='false';
	      rowOptions = stringToSelectOptions(choices);
	      renderSelectRadio='false';
	      renderFreeText='false';
	      renderSelectRow = 'true';
      }
     else if (sq.Type__c=='Free Text'){
	  		renderFreeText='true';
	  		renderSelectRadio='false';
	  		renderSelectCheckboxes='false';
	  	  renderSelectRow = 'false';
      }
      	//responses= getResponses();
      }
      
	   /** Splits up the string as given by the user and adds each option
	    *  to a list to be displayed as option on the Visualforce page
	    *  param: str	String as submitted by the user
	    *  returns the List of SelectOption for the visualforce page
   	    */  
      private List<SelectOption> stringToSelectOptions(String str){
	  	strList = str.split('\n');
	  
	  	List<SelectOption> returnVal = new List<SelectOption>();
	  	for(String s: strList){
	  		if (s!='') {
	  			returnVal.add(new SelectOption(s,s));
	  			if (s != 'null' && s!= null) {
	  				String sBis = s.replace(' ', '%20');
	  				singleOptionsForChart += s.trim()+'|';
	  			}
	  		}
	  	}
	  	singleOptionsForChart = singleOptionsForChart.substring(0, singleOptionsForChart.length()-1);
	  	return returnVal;
	  }	
	}
	
  /** Fills up the List of questions to be displayed on the Visualforce page
   */	
	public List<question> getAQuestion() {
			qQuestion = '';
			qChoices ='';
		
		List<Survey_Question__c> allQuestionsObject = 
										[Select s.Type__c, s.Id, s.Survey__c, s.Required__c, s.Question__c, 
										s.OrderNumber__c, s.Name, s.Choices__c 
										From Survey_Question__c s 
										WHERE s.Survey__c =: surveyId ORDER BY s.OrderNumber__c];
		allQuestions = new List<question>();
		
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
			question theQ = new question(q);
			allQuestions.add(theQ);
		}
		allQuestionsSize = allQuestions.size();
		return allQuestions;
	}	
}