trigger SFSurveyQuestionTrigger on Survey_Question__c(before insert, before update) { //NOPMD
	for (Survey_Question__c sq : Trigger.new) {

		//Don't need single q
		sq.Name = (String.escapeSingleQuotes(sq.Question__c).length() > 80) ? sq.Question__c.substring(0, 79) : sq.Question__c;
	}
}