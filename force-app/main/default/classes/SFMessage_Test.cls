@isTest
private class SFMessage_Test {
	@IsTest
	private static void doTest() {
		SFMessage m = new SFMessage();
		m.setMessage('SFMessage', 'error');
		System.assertEquals(m.message, 'SFMessage');
		System.assertEquals(m.severity, 'error');
	}
}