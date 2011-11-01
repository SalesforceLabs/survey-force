/* Used to add or remove survey takers from the database */
global with sharing class AddUsersController {
	public List<Contact> allUsers	{get; set;}
	public String theList			{get; set;}
	public String surveyRef			{get; set;}
 
   /** Fills the list of contacts who are taking the survey
       specified in the url parameter.
    */ 
	public AddUsersController() {
		surveyRef = Apexpages.currentPage().getParameters().get('sId');
	}

//------------------------------------------------------------------------------//	
  	private static TestMethod void testAddUsersController(){
	  SurveyTestingUtil tu = new SurveyTestingUtil();
      AddUsersController sc = new AddUsersController();
      System.assert(sc!=null);
  	}  
//------------------------------------------------------------------------------//	

   /** Inserts a new Survey taker in the database
       param: userId	Contact ID as specified in the url parameter
       param: sId		Survey ID as specified in the url parameter
       return: boolean 	returns 'true' if no error
    */	
	static Webservice String addUser(String userId, String sId, String caId, String rUserId) {
		String CaseId;
	
		if(caId.toUpperCase() =='NONE'|| caId.length()<5)
		  caseId = null;
		else  
		  caseId = caId;  	
		
		if(userId.toUpperCase() == 'NONE'|| userId.length()<5)
		  userId = null;
		  
		if(rUserId.toUpperCase() == 'NONE'|| rUserId.length()<5)
		  rUserId = null;
		  		  
		List<SurveyTaker__c> check = [Select Contact__c, Survey__c, Case__c, User__c From SurveyTaker__c Where Contact__c=:userId and Survey__c=:sId and Case__c = :caseId and User__c=:rUserId];
		if(check != null && check.size()>0){
			return 'false';
			/* Check to see if contact is not already in the database */
  		}
		/* Add the contact to the database otherwise */
		SurveyTaker__c st = new SurveyTaker__c();
		List <Contact> c = [Select Id, FirstName, LastName, email From Contact Where Id=:userId];
		if((c == null || c.size()==0) && rUserId == null)
		  return 'false';
		  
		st.Contact__c = userId;
		st.Survey__c = sId;
		st.Taken__c = 'false';
		st.Case__c = caseId;
		st.User__c = rUserId;
		insert st;
		return 'true';
	}

//------------------------------------------------------------------------------//	
  	private static TestMethod void testAddUser(){
    	SurveyTestingUtil tu = new SurveyTestingUtil();
    	System.assert(AddUsersController.addUser(tu.contactId2, tu.surveyId, 'none', 'none') == 'true');
    	System.assert(AddUsersController.addUser('arf','arf','arf', 'arf')== 'false');
    	System.assert(AddUsersController.addUser(tu.contactId, tu.surveyId, 'none', 'none') == 'false');
  	}
//------------------------------------------------------------------------------//	


   /** Removes a survey taker from the database
       param: userId	Contact ID as specified in the url parameter
       return: boolean 	returns 'true' if no error
    */  	
	public static Webservice String removeUser(String userId) {
		List<SurveyTaker__c> st = [Select Id, Contact__c From SurveyTaker__c Where Contact__c=:userId];
		for(SurveyTaker__c s:st) 
			delete s;
		return 'true';
	}	
	
//------------------------------------------------------------------------------//	
	private static TestMethod void testRemoveUser() {
    	SurveyTestingUtil tu = new SurveyTestingUtil();
    	AddUsersController sc = new AddUsersController();	
    	System.assert(AddUsersController.addUser(tu.contactId2, tu.surveyId, 'none','none') == 'true');
    	System.assert(AddUsersController.removeUser(tu.contactId) == 'true');	
	}
//------------------------------------------------------------------------------//	
 
}