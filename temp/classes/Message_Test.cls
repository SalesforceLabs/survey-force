@isTest
private class Message_Test {
    @istest
    private static void doTest(){
        Message m = new Message();
        m.setMessage('Message', 'error');
        System.assertEquals(m.message, 'Message');
        System.assertEquals(m.severity, 'error');
        
    }
}