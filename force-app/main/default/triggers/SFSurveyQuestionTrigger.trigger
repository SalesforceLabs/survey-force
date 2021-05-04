trigger SFSurveyQuestionTrigger on Survey_Question__c (before insert, before update) {
	for(Survey_Question__c sq : Trigger.new){
		sq.Name = (String.escapeSingleQuotes(sq.Question__c).length() > 80) ? String.escapeSingleQuotes(sq.Question__c).substring(0,79) : String.escapeSingleQuotes(sq.Question__c);
	}
}