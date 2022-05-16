@IsTest
private class SFQuestion_Test {
	@IsTest
	private static void testQuestionController() {
		Survey_Question__c sq = new Survey_Question__c();
		sq.Name = 'Test';
		sq.Question__c = 'Question';
		sq.Choices__c = 'Test1\nTest2';
		sq.Type__c = 'Single Select--Vertical';
		sq.Required__c = true;
		sq.OrderNumber__c = 2;

		SFQuestion q = new SFQuestion(sq);
		System.assertEquals(q.responseOptions.size(), 2);
	}
}