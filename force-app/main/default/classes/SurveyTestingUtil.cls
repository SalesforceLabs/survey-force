public with sharing class SurveyTestingUtil {
  public String        surveyId       {get; set;}
  public List<String>  questionIds    {get; set;}
  public String          contactId      {get; set;}
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