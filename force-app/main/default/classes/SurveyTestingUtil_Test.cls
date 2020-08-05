@IsTest
private class SurveyTestingUtil_Test {

  private static TestMethod void testConstructor(){
    SurveyTestingUtil tu = new SurveyTestingUtil();
    System.assert(tu.surveyId != null);
  }
}