trigger SurveyTaken on SurveyTaker__c (before insert) {
    for(SurveyTaker__c st: Trigger.new){
        //With new Guest user settings, we cannot give Edit access to Contact object to Guest user
        //Now we store Contact & Case IDs in a Text field and use trigger to update Lookup fields (in system mode)
        st.Contact__c = st.ContactText__c;
    }
}