global virtual with sharing class SurveyAndQuestionController{// extends SurveyAndQuestionController{
  
  public List<SelectOption> questionTypeOptions {get; set;}
  public String  showBasicValues                {get; set;}
  public String  showSingleSelect               {get; set;}
  public String  showSingleSelectPreview        {get; set;}
  public String  showMultiSelect                {get; set;}
  public String  showMultiSelectPreview         {get; set;}
  public String  showFreeText                   {get; set;}
  public String  showFreeTextPreview            {get; set;}
  public String  showRowQuestion                {get; set;}
  public String  showRowQuestionPreview         {get; set;}
  public String  showSelectQuestionType         {get; set;}
  public List<SelectOption> singleOptions       {get; set;}
  public List<SelectOption> multiOptions        {get; set;}
  public List<SelectOption> rowOptions          {get; set;}
  public String  questionReference              {get; set;}
  public String  reportId                       {get; set;}
  private Boolean saveAndNew;
  private String  surveyRef;
  private String surveyOrderNumber;
  private Survey_Question__c questionToUpdate;
  /***/
  public String  qQuestion                      {get; set;}
  public Boolean qRequired                      {get; set;}
  public String  qChoices                       {get; set;}
  public String surveyName                  {get; set;}
  public String surveyHeader                {get; set;}
  public String surveyId                    {get; set;} 
  public String renderSurveyPreview         {get; set;}  
  public String questionName                {get; set;}  
  public String questionType                {get; set;}
  public Boolean questionRequired           {get; set;}
  public List<SFQuestion> allQuestions        {get; set;}
  public List<String> responses             {get; set;}
  public Integer allQuestionsSize           {get; set;}
  public String  templateURL                {get; set;}
  public String  surveyThankYouText         {get; set;}
  public String  surveyThankYouURL          {get; set;}
  public String  caseId                     {get; set;}
  public List<String> newOrder {get;set;}
  public String newOrderW {get;set;}
  public Message pageMessage {
      get{
          if(pageMessage == null){
              pageMessage = new Message();
          }
          return pageMessage;
      }
      set;
  }
   
  public  SurveyAndQuestionController (ApexPages.StandardController stdController){
     /**/
    // Get url parameters
    surveyId = Apexpages.currentPage().getParameters().get('id');
    caseId   = Apexpages.currentPage().getParameters().get('caId');
    newOrder = new List<String>();
    if(caseId ==null || caseId.length()<5){
      caseId = 'none';
    }
    // By default the preview is not showing up
    renderSurveyPreview = 'false';

    if (surveyId != null){ 
      // Retrieve all necessary information to be displayed on the page
      allQuestions = new List<SFQuestion>();
      setSurveyNameAndThankYou(surveyId);
    }
    /**/
    surveyRef = surveyId;
    setupQuestionTypeOptions();
    resetViewsToFalse(true);
    showSelectQuestionType = 'True';
    ReportFinderUtil rfu = new ReportFinderUtil();
    reportId = rfu.findReportId('Survey with Questions and Responses');
   
  }

  
  public Pagereference makeNewQuestionLink(){
    questionReference = null;
    resetViewsToFalse(true);
    return null;
  }
  
  public Pagereference editQuestion(){
    if (questionReference == null)
     return null;
    setupEditQuestion();
    //Disable question type drop down as it's an older question
    showSelectQuestionType = 'False';
    return null;
  }
  
  public Pagereference addQuestion(){
    showSelectQuestionType = 'True';
    resetViewsToFalse(true);
    return null;
  }
  
  private void setupEditQuestion(){
    questionToUpdate =     [Select Type__c, Question__c, Id, Choices__c, Required__c, 
                           OrderNumber__c, Survey__c, Name
                           From Survey_Question__c 
                           where Id = :questionReference];
    questionType = questionToUpdate.Type__c;
    setupQuestionFields();
    setupEditFields(questionToUpdate);
  }

  private void setupEditFields(Survey_Question__c q){
    qQuestion = q.Question__c;
    qRequired = q.Required__c;
    qChoices = q.Choices__c;
    surveyRef = q.Survey__c;    
  }

  private void setupQuestionTypeOptions(){
  
    //get picklist values
    Schema.DescribeFieldResult fieldResult = Survey_Question__c.Type__c.getDescribe();
    List<Schema.PicklistEntry>  ple = fieldResult.getPicklistValues();
  
    //set/add them to selectOption list
    questionTypeOptions = new List<SelectOption>();
    questionTypeOptions.add(new SelectOption('--SELECT--', System.Label.LABS_SF_SELECTTYPE));
    for(Schema.PicklistEntry pe: ple){
      questionTypeOptions.add(new SelectOption(pe.getLabel(), pe.getValue()));
    }
  }
 

  
  
  private void resetViewsToFalse(Boolean clearFields){
    showSingleSelect =        'False';
    showSingleSelectPreview = 'False';
    showMultiSelect =         'False';
    showMultiSelectPreview=   'False';
    showFreeText =            'False';
    showFreeTextPreview=      'False';
    showRowQuestion=          'False';
    showRowQuestionPreview=   'False';
    qRequired =                true;
    if(clearFields){
      qChoices =                 '';
      qQuestion =                '';
      }
    }

  public Pagereference setupQuestionFields(){
    resetViewsToFalse(true);
    showSelectQuestionType = 'True';
    if(questionType=='Multi-Select--Vertical'){
     showMultiSelect='True';
    }
    else if(questionType == 'Single Select--Vertical'){
      showSingleSelect = 'True';
    }
    else if(questionType == 'Free Text' || questionType == 'Free Text - Single Row Visible'){
      showFreeText = 'True';
    }
    else if(questionType == 'Single Select--Horizontal'){
      showRowQuestion = 'True';
    }
    return null;
  }  
 
  public Pagereference saveAndNewQuestion(){
    saveAndNew = True;
    if(questionReference == null || questionReference.length() <5)
      return saveNewQuestion();
    else 
      return updateQuestion();  
  }
  
  

  
  public Pagereference controllerSavQuestion(){
    if(questionReference == null || questionReference.length() <5){
      return saveNewQuestion();
    }
    else{ 
      return updateQuestion();
    }
  }
  


  
  private Pagereference updateQuestion(){
    //questionToUpdate is setup in an earlier call to editQuestion()
    questionToUpdate.Name = questionToName(qQuestion);
    questionToUpdate.Choices__c = qChoices;
    questionToUpdate.Required__c = qRequired;
    questionToUpdate.Type__c = questionType;
    questionToUpdate.Question__c = qQuestion;
    try{
      update questionToUpdate;
      resetViewsToFalse(true);
      deleteOldResponses(questionToUpdate.id);
      questionReference = null;
        pageMessage.setMessage('Question was updated!', 'success');
    }catch(Exception e){
      Apexpages.addMessages(e);
      pageMessage.setMessage(e.getMessage(), 'error');
    }
    
    return saveOrUpdateReturn();
  }
  
  private void deleteOldResponses(String qId){
    List <SurveyQuestionResponse__c> sResponses = [select id, Survey_Question__c from SurveyQuestionResponse__c where Survey_Question__c = :qId];
    if(sResponses != null)
     delete sResponses;
  }
  
  private Pagereference saveOrUpdateReturn(){
    setupQuestionList();
    Pagereference pr = new Pagereference('/apex/SurveyPage?id='+surveyRef);
    questionType = '--SELECT--';
    if(saveAndNew != null  && saveAndNew == true){
      saveAndNew = False;
      showSelectQuestionType = 'True';      
      return pr;
    }
    else{  
      showSelectQuestionType = 'False';      
      return pr; 
    }
  }

  public Integer getNewQuestionNum(){
    if(allQuestions == null)
     return 0;
    else{
     return allQuestions.size();
    }    
  }

  private Pagereference saveNewQuestion(){ 
    Survey_Question__c newQuestion = new Survey_Question__c();
    newQuestion.Survey__c = surveyRef;
    newQuestion.Name = questionToName(qQuestion);
    newQuestion.Choices__c = qChoices;
    newQuestion.Required__c = qRequired;
    newQuestion.Type__c = questionType;
    newQuestion.OrderNumber__c = getNewQuestionNum();
    newQuestion.Question__c = qQuestion;
    resetViewsToFalse(true);
    try{
        insert newQuestion;
        pageMessage.setMessage('New question was added!', 'success');
    }catch(Exception e){
        pageMessage.setMessage(e.getMessage(), 'error');
    }
    return saveOrUpdateReturn();
  }
  
  private String questionToName(String q){
    if(q.length()<75)
     return q;
    else
     return q.substring(0, 75)+'...';
  }
  
  public Pagereference previewQuestion(){
    if(questionType  == 'Multi-Select--Vertical'){
      showMultiSelectPreview = 'True';
      multiOptions = stringToSelectOptions(qChoices);
    }
    else if(questionType == 'Single Select--Vertical'){
     showSingleSelectPreview = 'True';
     singleOptions = stringToSelectOptions(qChoices);
    }
    else if(questionType =='Free Text' || questionType == 'Free Text - Single Row Visible'){
      showFreeTextPreview = 'True';
    }
    else if(questionType == 'Single Select--Horizontal'){
      showRowQuestionPreview = 'True';
      rowOptions = stringToSelectOptions(qChoices);
    }
    return null;
  }



  
  private List<SelectOption> stringToSelectOptions(String str){
    List<String> strList = str.split('\\r|\n');
    List<SelectOption> returnVal = new List<SelectOption>();
    for(String s: strList){
      returnVal.add(new SelectOption(s,s));
    }
    return returnVal;
    
  }
/****/

  /* Called during the setup of the page. 
     Retrieve questions and responses from DB and inserts them in 2 lists. */
  public Integer setupQuestionList(){
    /*allQuestions.clear();
    List<Survey_Question__c> allQuestionsObject = 
                    [Select Type__c, Id, Survey__c, Required__c, 
                    Question__c, OrderNumber__c, Name, Choices__c
                    From Survey_Question__c  
                    WHERE Survey__c =: surveyId
                    order by OrderNumber__c];
    for (Survey_Question__c q : allQuestionsObject){
      question theQ = new question(q);
      allQuestions.add(theQ);
    }
    //responses = getResponses();//taken out because it was SOQL heavy//*/
    getAQuestion();
    return allQuestions.size();
  }
  
  
   /** Sets the survey's name variable
  *  param: sID The survey ID as specified in the DB
  */
  public void setSurveyNameAndThankYou(String sId){
    Survey__c s = [SELECT Name, Id, URL__c, thankYouText__c, thankYouLink__c, Survey_Header__c FROM Survey__c WHERE Id =:sId];
    surveyName = s.Name;
    surveyHeader = s.Survey_Header__c;
    templateURL = s.URL__c+'id='+sId;//+'&cId={!Contact.Id}'+'&caId='+'{!Case.id}';
    surveyThankYouText = s.thankYouText__c;
    surveyThankYouURL = s.thankYouLink__c;
  }
  
//------------------------------------------------------------------------------//   
  public Pagereference updateSurveyName(){
    Survey__c s = [SELECT Name, Id, URL__c, thankYouText__c, thankYouLink__c FROM Survey__c WHERE Id =:surveyId];
    s.Name = surveyName;
    try{
      update s;
    }catch (Exception e){
      Apexpages.addMessages(e);
      pageMessage.setMessage(e.getMessage(), 'error');
    }
    return null;
  } 

//------------------------------------------------------------------------------//    
  public Pagereference updateSurveyThankYouAndLink(){
    Survey__c s = [SELECT Name, Id, URL__c, thankYouText__c, thankYouLink__c FROM Survey__c WHERE Id =:surveyId];
    s.thankYouText__c = surveyThankYouText;
    s.thankYouLink__c = surveyThankYouURL;
    try{
      update s;
    }catch(Exception e){
      Apexpages.addMessages(e);

        pageMessage.setMessage(e.getMessage(), 'error');
    }
    return null;
  }

  
   public PageReference updateOrderList()
  {
    if(newOrderW.length() <= 0)
    {
        return null;
    }

      try {
          newOrderW = newOrderW.substring(0, newOrderW.length() - 1);

          List<String> idsToUpdate = newOrderW.split(',', -1);
          List<Survey_Question__c> qsToUpdate = new List<Survey_Question__c>();

          Map<Id, Survey_Question__c> questionMap = new Map<Id, Survey_Question__c>([select Id, OrderNumber__c from Survey_Question__c where Id in :idsToUpdate]);
          Survey_Question__c sqToUpdate;

          for (Integer i = 0; i < idsToUpdate.size(); i++) {
              sqToUpdate = questionMap.get(idsToUpdate.get(i));
              sqToUpdate.OrderNumber__c = i;
              qsToUpdate.add(sqToUpdate);
          }

          update qsToUpdate;
          pageMessage.setMessage('Question Order was successfully updated!', 'success');
      }catch(Exception e){
          Apexpages.addMessages(e);
          pageMessage.setMessage(e.getMessage(), 'error');

      }
    
    return null;
  } 
  
  //------------------------------------------------------------------------------//  
  /** When requested from the page - when the user clicks on 'Update Order' -
      this function will reorganize the list so that it is displayed in the new order
   */
   public Pagereference refreshQuestionList(){
    setupQuestionList();
    return null;
   }


//------------------------------------------------------------------------------//    


//------------------------------------------------------------------------------//    
  

   /** Redirects the page that displays the detailed results of the survey, 
       from all users who took the survey.
    */
    public PageReference resultPage() {
      return new PageReference('/apex/ResultsPage?id='+surveyId);
    }

   
    
  
//------------------------------------------------------------------------------//      
    public Pagereference deleteRefresh(){
        if (questionReference == null ){
            return null;
        }
      try{
        Survey_Question__c sq = [Select Id, Name FROM Survey_Question__c WHERE Id =: questionReference];
        delete sq;
         questionReference = null;

         allQuestions.clear();
         Double j = 0.0;
        List<Survey_Question__c> allQuestionsObject =
                        [Select Type__c, Id, Survey__c, Required__c,
                        Question__c, OrderNumber__c, Name, Choices__c
                        From Survey_Question__c
                        WHERE Survey__c =: surveyId
                        order by OrderNumber__c];
        for (Integer i =0; i< allQuestionsObject.size(); i++){
          allQuestionsObject[i].OrderNumber__c= j;
            SFQuestion theQ = new SFQuestion(allQuestionsObject[i]);
          allQuestions.add(theQ);
          j = j+1.0;
        }
        responses = getResponses();
        update allQuestionsObject;
    }catch(Exception e){
      Apexpages.addMessages(e);
      pageMessage.setMessage(e.getMessage(), 'error');
    }
      return saveOrUpdateReturn();
  }



//------------------------------------------------------------------------------//  

   /** 
    */
  public List<String> getResponses() {
    List<SurveyQuestionResponse__c> qr = [Select Survey_Question__c, SurveyTaker__c, Response__c, Name From SurveyQuestionResponse__c limit 100];
    List<String> resp = new List<String>();
    for (SurveyQuestionResponse__c r : qr) {
      resp.add(r.Response__c);
    }
    
    return resp;
  }  

   
  
  /** Fills up the List of questions to be displayed on the Visualforce page
   */ 
  public List<SFQuestion> getAQuestion() {
    List<Survey_Question__c> allQuestionsObject = 
                    [Select s.Type__c, s.Id, s.Survey__c, s.Required__c, s.Question__c, 
                    s.OrderNumber__c, s.Name, s.Choices__c 
                    From Survey_Question__c s 
                    WHERE s.Survey__c =: surveyId ORDER BY s.OrderNumber__c];
    allQuestions = new List<SFQuestion>();
    
    Double old_OrderNumber = 0;
    Double new_OrderNumber;
    Double difference = 0;
    /* Make sure that the order number follow each other (after deleting a question, orders might not do so) */
    for (Survey_Question__c q : allQuestionsObject){ 
      new_OrderNumber = q.OrderNumber__c;
      difference = new_OrderNumber - old_OrderNumber - 1;
      if (difference > 0) {
        Double dd = double.valueOf(difference);
        Integer newOrderInt = dd.intValue();
        q.OrderNumber__c -= Integer.valueOf(newOrderInt); 
      }
      old_OrderNumber = q.OrderNumber__c;
        SFQuestion theQ = new SFQuestion(q);
      allQuestions.add(theQ);
    }
    allQuestionsSize = allQuestions.size();
    return allQuestions;
  } 

}