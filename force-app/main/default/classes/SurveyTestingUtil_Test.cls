@IsTest
private class SurveyTestingUtil_Test {
	@IsTest
	private static void testConstructor() {
		SurveyTestingUtil tu = new SurveyTestingUtil();
		System.assert(tu.surveyId != null);
	}
}