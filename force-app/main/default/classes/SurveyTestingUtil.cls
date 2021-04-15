public with sharing class SurveyTestingUtil {
	public Id            surveyId       {get; set;}
	public List<String>  questionIds    {get; set;}
	public String        contactId      {get; set;}
	public String        surveyTakerId  {get; set;}
	public String        contactId2     {get; set;}
	public Survey__c     survey;


	public SurveyTestingUtil(){
		questionIds = new List<String>();
		createTestSurvey();
		createTestQuestions();
		createTestContact();
		createSurveyTaker();
		createTestResponses();

	}


	private void createSurveyTaker(){
		SurveyTaker__c st = new SurveyTaker__c();
		st.Contact__c = contactId;
		st.Survey__c = surveyId;
		st.Completed__c = false;
		insert st;
		surveyTakerId = st.Id;
	}

	public void createTestSurvey(){
		Survey__c s = new Survey__c();
		s.Name = 'Testing Survey';
		s.Thank_You_Text__c = 'empty';
		insert s;
		surveyId = s.Id;
		this.survey = s;
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

	private void createTestResponses() {
		SurveyQuestionResponse__c r = new SurveyQuestionResponse__c();
		r.Response__c = 'two';
		Survey_Question__c sq = [SELECT Id FROM Survey_Question__c WHERE id=: questionIds[1] limit 1];
		r.Survey_Question__c = sq.id;
		r.SurveyTaker__c = surveyTakerId;
		insert r;
	}

	private String getType(Integer i){
		if      (i==1)
		{return 'Multi-Select--Vertical';}
		else if (i==2)
		{return 'Single Select--Vertical';}
		else if (i==3)
		{return 'Free Text';}
		else
		{return 'Single Select--Horizontal';}
	}
	private String getChoices(){
		return 'one\ntwo\nthree\n';
	}

	public static User createNewAdminPermissionSetUser(){
		/* PermissionSet p = [SELECT Id FROM PermissionSet WHERE IsOwnedByProfile = false AND Name = 'Survey_Force_SuperAdmin' LIMIT 1];
		PermissionSetAssignment psa = new PermissionSetAssignment();
		psa.AssigneeId = UserInfo.getUserId();
		psa.PermissionSetId = p.Id;
		try{
			insert psa;
		} catch (Exception e){
			System.debug('Could not assign permission set - it may already be assigned');
		} */

		String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
		// This code runs as the system user
		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
		User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
		EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
		LocaleSidKey='en_US', ProfileId = p.Id,
		TimeZoneSidKey='America/Los_Angeles',
		UserName=uniqueUserName);

		insert u;

		PermissionSet ps = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Survey_Force_Admin'];
		System.debug('Permission Set ' + ps);
		PermissionSetAssignment psa =  new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
		insert psa;

		System.debug('PERM SET ASSIGNMENT: ' + psa);

		return u;
	}

}