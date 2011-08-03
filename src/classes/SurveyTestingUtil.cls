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
public with sharing class SurveyTestingUtil {
  public String        surveyId       {get; set;}
  public List<String>  questionIds    {get; set;}
  public String 	     contactId 	    {get; set;}
  public String        surveyTakerId  {get; set;}
  public String        contactId2     {get; set;}
  
  
  public SurveyTestingUtil(){
  	questionIds = new List<String>();
  	createTestSurvey();
  	createTestQuestions();
  	createTestContact();
  	createSurveyTaker();
  	createTestResponses();
  	
  }
  
  private static TestMethod void testConstructor(){
  	SurveyTestingUtil tu = new SurveyTestingUtil();
  	System.assert(tu.surveyId != null);
  }
  
  private void createSurveyTaker(){
  	SurveyTaker__c st = new SurveyTaker__c();
  	st.Contact__c = contactId;
  	st.Survey__c = surveyId;
  	st.Taken__c = 'false';
  	insert st;
  	surveyTakerId = st.Id;
  }
  
  public void createTestSurvey(){
  	Survey__c s = new Survey__c();
  	s.Name = 'Testing Survey';
  	s.Submit_Response__c = 'empty'; 
  	insert s;
    surveyId = s.Id;
  }
  
  public void createTestQuestions(){
    questionIds.add(createQuestion(0));
    questionIds.add(createQuestion(1));
    questionIds.add(createQuestion(2));
    questionIds.add(createQuestion(3));
  }
  
  private String createQuestion(Integer i){
  	Survey_Question__c q = new Survey_Question__c();
  	q.Name = 'Testing Question';
  	q.Survey__c = surveyId;
  	q.Type__c = getType(i);
  	q.Choices__c = getChoices();
  	q.Question__c = 'Testing Question question';
  	q.OrderNumber__c = i;
  	q.Required__c = true;
  	insert q;
    return q.id;  		
  }
  
  
  private void createTestContact() {
  	Contact c = new Contact();
  	c.LastName = 'Doe';
  	c.FirstName = 'John';
  	c.Email = 'surveyAppUser@hotmail.com';
  	insert c;
  	contactId = c.Id;  	
  	
  	Contact c2 = new Contact();
    c2.LastName = 'Doe2';
    c2.FirstName = 'John2';
    c2.Email = 'surveyAppUser2@hotmail.com';
    insert c2;
    contactId2 = c2.Id;   
  }
  
  private String createTestResponses() {
  	SurveyQuestionResponse__c r = new SurveyQuestionResponse__c();
  	r.Response__c = 'two';
  	Survey_Question__c sq = [Select id from Survey_Question__c where id=: questionIds[1] limit 1];
  	r.Survey_Question__c = sq.id;
  	r.SurveyTaker__c = surveyTakerId;
  	insert r;
  	return 'true';
  }
  
  private String getType(Integer i){
  	if      (i==1)
  	 return 'Multi-Select--Vertical';
  	else if (i==2)
  	 return 'Single Select--Vertical';
  	else if (i==3)
     return 'Free Text';
    else
     return 'Single Select--Horizontal';
  }
  private String getChoices(){
  	return 'one\ntwo\nthree\n';
  }
  
}