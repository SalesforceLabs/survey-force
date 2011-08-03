/*
Copyright (c) 2011, salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, 
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, 
    this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, 
    this list of conditions and the following disclaimer in the documentation 
    and/or other materials provided with the distribution.
    * Neither the name of the salesforce.com, Inc. nor the names of its contributors 
    may be used to endorse or promote products derived from this software 
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
OF THE POSSIBILITY OF SUCH DAMAGE.

*/
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
	static Webservice String addUser(String userId, String sId, String caId) {
		String CaseId;
	
		if(caId.toUpperCase() =='NONE'|| caId.length()<5)
		  caseId = null;
		else  
		  caseId = caId;  	
		
		if(userId.toUpperCase() == 'NONE'|| userId.length()<5)
		  userId = null;
		  
		List<SurveyTaker__c> check = [Select Contact__c, Survey__c, Case__c From SurveyTaker__c Where Contact__c=:userId and Survey__c=:sId and Case__c = :caseId];
		if(check != null && check.size()>0){
			return 'false';
			/* Check to see if contact is not already in the database */
  		}
		/* Add the contact to the database otherwise */
		SurveyTaker__c st = new SurveyTaker__c();
		List <Contact> c = [Select Id, FirstName, LastName, email From Contact Where Id=:userId];
		if(c == null || c.size()==0)
		  return 'false';
		st.Contact__c = userId;
		st.Survey__c = sId;
		st.Taken__c = 'false';
		st.Case__c = caseId;
		insert st;
		return 'true';
	}

//------------------------------------------------------------------------------//	
  	private static TestMethod void testAddUser(){
    	SurveyTestingUtil tu = new SurveyTestingUtil();
    	System.assert(AddUsersController.addUser(tu.contactId2, tu.surveyId, 'none') == 'true');
    	System.assert(AddUsersController.addUser('arf','arf','arf')== 'false');
    	System.assert(AddUsersController.addUser(tu.contactId, tu.surveyId, 'none') == 'false');
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
    	System.assert(AddUsersController.addUser(tu.contactId2, tu.surveyId, 'none') == 'true');
    	System.assert(AddUsersController.removeUser(tu.contactId) == 'true');	
	}
//------------------------------------------------------------------------------//	
  public void InsertNewSurveyTaker(String contactId, String surveyId, String taken, String caseId){
    SurveyTaker__c st = new SurveyTaker__c();
    st.Contact__c = contactId;
    st.Survey__c = surveyId;
    st.Taken__c = taken;
    st.Case__c = caseId;
    insert st;
  }
  //------------------------------------------------------------------------------//
}