@isTest
private class SurveyManagerController_Test {
    @isTest
    private static void doTest_runAs2(){
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
         UserName=uniqueUserName);

		insert u;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Survey_Force_Guest'];
        insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
             
        
        System.runAs(u) {
            //Assign Permission set to this user as we need to allow access to suvery__c in this context to do additional testing
            //Without it, testing of standard controller will fail as we can't even run getRecord() method
            //System.VisualforceException: Read access denied for Survey__c, controller action methods may not execute.
            PageReference pageRef = Page.SurveyManagerPage;
            Test.setCurrentPage(pageRef);
            
            Survey__c s = new Survey__c();
            s.Name = 'test survey';
            insert s;
            
            ApexPages.StandardController sc = new ApexPages.StandardController(s);                 
            
            SurveyManagerController con = new SurveyManagerController(sc);
            System.assertEquals(con.surveyId, s.Id);
            
            con.save();
            //String url = con.getResults().getUrl();
            //System.assertEquals(url, '/'+con.reportId + '?pv0='  + con.surveyId);
        }
    }
    
    @isTest
    private static void doTest_runAs(){
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
         UserName=uniqueUserName);

		insert u;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Survey_Force_Admin'];
        insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
             
        
        System.runAs(u) {
            //Assign Permission set to this user as we need to allow access to suvery__c in this context to do additional testing
            //Without it, testing of standard controller will fail as we can't even run getRecord() method
            //System.VisualforceException: Read access denied for Survey__c, controller action methods may not execute.
            PageReference pageRef = Page.SurveyManagerPage;
            Test.setCurrentPage(pageRef);
            
            Survey__c s = new Survey__c();
            s.Name = 'test survey';
            insert s;
            
            ApexPages.StandardController sc = new ApexPages.StandardController(s);                 
            
            SurveyManagerController con = new SurveyManagerController(sc);
            System.assertEquals(con.surveyId, s.Id);
            
            con.save();
            //String url = con.getResults().getUrl();
            //System.assertEquals(url, '/'+con.reportId + '?pv0='  + con.surveyId);
        }
    }
    @isTest
    private static void doTest(){
        PageReference pageRef = Page.SurveyManagerPage;
        Test.setCurrentPage(pageRef);

        Survey__c s = new Survey__c();
        s.Name = 'test survey';
        insert s;
        ApexPages.StandardController sc = new ApexPages.StandardController(s);
        
        SurveyManagerController con = new SurveyManagerController(sc);
        System.assertEquals(con.surveyId, s.Id);
        
        con.save();
    }
    
    //Using seeALlData is NOT a good idea. However, there is no way to create reports in tests
    //So we need to use this to be able to access a report so it can be tested
    @isTest(seeAllData=true)
    private static void doTest_withData(){
        PageReference pageRef = Page.SurveyManagerPage;
        Test.setCurrentPage(pageRef);

        Survey__c s = new Survey__c();
        s.Name = 'test survey';
        insert s;
        ApexPages.StandardController sc = new ApexPages.StandardController(s);
        
        SurveyManagerController con = new SurveyManagerController(sc);
        System.assertEquals(con.surveyId, s.Id);
        
        con.save();
    }
}