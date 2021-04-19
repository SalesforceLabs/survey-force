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
		SurveyTaker__c st = (SurveyTaker__c)SurveyTaker__c.sObjectType.newSObject(null, true);
		st.Contact__c = contactId;
		st.Survey__c = surveyId;
		st.Completed__c = false;
		insert st;
		surveyTakerId = st.Id;
	}

	public void createTestSurvey(){
		Survey__c s = (Survey__c)Survey__c.sObjectType.newSObject(null, true);
		s.Name = 'Testing Survey';
		s.Thank_You_Text__c = 'empty';
		insert s;
		surveyId = s.Id;
		this.survey = s;
	}

	public static final Integer QUESTION_TYPES = Schema.sObjectType.Survey_Question__c.fields.Type__c.getPicklistValues().size();

	public void createTestQuestions(){
		for(Integer i = 0 ; i < QUESTION_TYPES; i++){
			questionIds.add(createQuestion(i).Id);
		}
	}

	private Survey_Question__c createQuestion(Integer i){
		Survey_Question__c q = (Survey_Question__c)Survey_Question__c.sObjectType.newSObject(null, true);
		q.Name = 'Testing Question';
		q.Survey__c = surveyId;
		q.Type__c = getType(i);
		q.Choices__c = getChoices();
		q.Question__c = 'Testing Question question';
		q.OrderNumber__c = i;
		insert q;
		return q;
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

	public static String getType(Integer i){
		Schema.DescribeFieldResult dfr = Schema.sObjectType.Survey_Question__c.fields.Type__c;
		List<Schema.PicklistEntry> ples = dfr.getPicklistValues();

		Integer picklistItem = math.mod(i, ples.size());
		return ples[picklistItem].getValue();

		/* if      (i==1)
		{return 'Multi-Select--Vertical';}
		else if (i==2)
		{return 'Single Select--Vertical';}
		else if (i==3)
		{return 'Free Text';}
		else
		{return 'Single Select--Horizontal';} */
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

		PermissionSet ps = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Survey_Force_SuperAdmin'];
		System.debug('Permission Set ' + ps);
		PermissionSetAssignment psa =  new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
		insert psa;

		System.debug('PERM SET ASSIGNMENT: ' + psa);

		return u;
	}

}