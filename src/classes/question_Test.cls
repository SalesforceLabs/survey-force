@isTest
private class question_Test {
    @isTest
    private static void testQuestionController(){
        Survey_Question__c sq= new Survey_Question__c();
        sq.Name =  'Test';
        sq.Question__c = 'Question';
        sq.Choices__c = 'Test1\nTest2';
        sq.Type__c = 'Single Select--Vertical';
        sq.Required__c = True;
        sq.OrderNumber__c = 2;

        question q = new Question(sq);
        System.assertEquals(q.singleOptions.size(), 2);
    }
}