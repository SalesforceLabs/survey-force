public with sharing class GettingStartedController {

    public Survey__c testSurvey { get; set; }
    public Boolean testSurveyAvailable { get; set; }
    public List<String> questionIds { get; set; }
    public SFMessage pageMessage {
        get {
            if (pageMessage == null) {
                pageMessage = new SFMessage();
            }
            return pageMessage;
        }
        set;
    }

    public GettingStartedController() {
        testSurveyAvailable = false;
        // make sure getting started survey doesn't already exist
        questionIds = new List<String>();
        try {
            List<Schema.SobjectField> fields = new List<Schema.SobjectField>{Schema.Survey__c.fields.Name};
            SurveyForceUtil.AccessController.assertAuthorizedToView(Schema.Survey__c.getSobjectType(), fields);

            testSurvey = [SELECT Id, Name From Survey__c WHERE Name = 'SurveyForce Sample Survey' LIMIT 1];

            testSurveyAvailable = true;
        } catch(SFDCAccessControlException e){
            SurveyForceUtil.log('GettingStartedController:GettingStartedController():SFDCAccessControlException' + e.getMessage());
        } catch(Exception e) {
            SurveyForceUtil.log('GettingStartedController:GettingStartedController():Exception' + e.getMessage());
        }
    }

    public void makeTestSurvey() {
        testSurveyAvailable = false;
        try {
            List<Schema.SobjectField> fields = new List<Schema.SobjectField>{Schema.Survey__c.fields.Name, Schema.Survey__c.fields.Submit_Response__c, Schema.Survey__c.fields.Survey_Container_CSS__c};
            SurveyForceUtil.AccessController.assertAuthorizedToCreate(Schema.Survey__c.getSobjectType(), fields);

            testSurvey = new Survey__c();
            testSurvey.Name = 'SurveyForce Sample Survey';
            testSurvey.Submit_Response__c = 'empty';
            testSurvey.Survey_Container_CSS__c = '#survey_container{ margin: 0 auto; width: 600px; box-shadow: 0 0 14px #CCCCCC; -moz-box-shadow: 0 0 14px #CCCCCC; -webkit-box-shadow: 0 0 14px #CCCCCC; }';
            insert testSurvey;

            questionIds.add(createQuestion(0));
            questionIds.add(createQuestion(1));
            questionIds.add(createQuestion(2));
            questionIds.add(createQuestion(3));

            createResponses();

            testSurveyAvailable = true;

            pageMessage.setMessage('Sample survey was successfully created!', 'success');
        }  catch(SFDCAccessControlException e){
            SurveyForceUtil.log('GettingStartedController:GettingStartedController():SFDCAccessControlException' + e.getMessage());
        } catch(Exception e) {
            SurveyForceUtil.log('GettingStartedController:GettingStartedController():Exception' + e.getMessage()); pageMessage.setMessage(e.getMessage(), 'error'); ApexPages.addMessages(e);
        }
    }

    public PageReference ViewSurvey() {
        return new PageReference(Page.SurveyManagerPage.getUrl() + '?id=' + testSurvey.Id);

    }

    public PageReference takeSurvey() {
        return new PageReference(Page.TakeSurvey.getUrl() + '?id=' + testSurvey.Id + '&cId=none&caId=none');
    }

    private String createQuestion(Integer i) {
        List<Schema.SobjectField> fields = new List<Schema.SobjectField>{Schema.Survey_Question__c.fields.Name,
                Schema.Survey_Question__c.fields.Survey__c, Schema.Survey_Question__c.fields.Type__c,
                Schema.Survey_Question__c.fields.Choices__c, Schema.Survey_Question__c.fields.Question__c,
                Schema.Survey_Question__c.fields.OrderNumber__c, Schema.Survey_Question__c.fields.Required__c
        };
        SurveyForceUtil.AccessController.assertAuthorizedToCreate(Schema.Survey_Question__c.getSobjectType(), fields);


        Survey_Question__c q = new Survey_Question__c();
        q.Name = 'Testing Question question' + i;
        q.Survey__c = testSurvey.Id;
        q.Type__c = getType(i);
        q.Choices__c = getChoices(i);
        q.Question__c = 'Testing Question question' + i;
        q.OrderNumber__c = i;
        q.Required__c = true;
        insert q;
        return q.id;
    }

    private String getType(Integer i) {
        if (i == 1)
            return 'Multi-Select--Vertical';
        else if (i == 2)
            return 'Single Select--Vertical';
        else if (i == 3)
            return 'Free Text';
        else
            return 'Single Select--Horizontal';
    }
    private String getChoices(Integer i) {
        if (i == 0){
            return 'one\ntwo\nthree\n';
        }
        if (i == 1){
            return 'four\nfive\nsix\n';
        }
        if (i == 2){
            return 'seven\neight\nnine\n';
        }

        return '';
    }

    private void createResponses() {
        Contact c = new Contact();
        try {

            List<Schema.SobjectField> fields = new List<Schema.SobjectField>{
                    Schema.Contact.fields.LastName
            };
            SurveyForceUtil.AccessController.assertAuthorizedToView(Schema.Contact.getSobjectType(), fields);

            //Try to see if survey exists
            c = [SELECT Id, LastName From Contact WHERE Email = :'surveyForceAppUser@survey.force'];
        } catch (Exception e) {

            List<Schema.SobjectField> fields = new List<Schema.SobjectField>{
                    Schema.Contact.fields.LastName, Schema.Contact.fields.FirstName, Schema.Contact.fields.Email
            };
            SurveyForceUtil.AccessController.assertAuthorizedToCreate(Schema.Contact.getSobjectType(), fields);


            c.LastName = 'Doe';
            c.FirstName = 'Jane';
            c.Email = 'surveyForceAppUser@survey.force';
            insert c;
        }


        List<Schema.SobjectField> fields = new List<Schema.SobjectField>{
                Schema.SurveyTaker__c.fields.Contact__c,
                Schema.SurveyTaker__c.fields.Survey__c, Schema.SurveyTaker__c.fields.Taken__c
        };
        SurveyForceUtil.AccessController.assertAuthorizedToCreate(Schema.SurveyTaker__c.getSobjectType(), fields);

        SurveyTaker__c st = new SurveyTaker__c();
        st.Contact__c = c.Id;
        st.Survey__c = testSurvey.Id;
        st.Taken__c = 'false';
        insert st;


        fields = new List<Schema.SobjectField>{
                Schema.SurveyQuestionResponse__c.fields.Survey_Question__c, Schema.SurveyQuestionResponse__c.fields.SurveyTaker__c
        };
        SurveyForceUtil.AccessController.assertAuthorizedToCreate(Schema.SurveyQuestionResponse__c.getSobjectType(), fields);


        fields = new List<Schema.SobjectField>{
                Schema.Survey_Question__c.fields.Name
        };
        SurveyForceUtil.AccessController.assertAuthorizedToView(Schema.Survey_Question__c.getSobjectType(), fields);

        List<SurveyQuestionResponse__c> sqrToInsert = new List<SurveyQuestionResponse__c>();

        for (Integer i = 0; i < 4; i++) {
            SurveyQuestionResponse__c r = new SurveyQuestionResponse__c();
            if (i == 0) {
                r.Response__c = 'two';
            } else if (i == 1) {
                r.Response__c = 'four';
            } else if (i == 2) {
                r.Response__c = 'nine';
            } else {
                r.Response__c = 'This is a response.';
            }
            Survey_Question__c sq = [SELECT Id, Name FROM Survey_Question__c WHERE id = :questionIds[i] limit 1];
            r.Survey_Question__c = sq.id;
            r.SurveyTaker__c = st.Id;
            sqrToInsert.add(r);
        }
        insert sqrToInsert;

    }
}