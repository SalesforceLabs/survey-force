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
  public List<question> allQuestions        {get; set;}
  public List<String> responses             {get; set;}
  public Integer allQuestionsSize           {get; set;}
  public String  templateURL                {get; set;}
  public String  surveyThankYouText         {get; set;}
  public String  surveyThankYouURL          {get; set;}
  public String  caseId                     {get; set;}
    public List<String> newOrder {get;set;}
    public String newOrderW {get;set;}
  
   
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
      allQuestions = new List<question>();
      setSurveyNameAndThankYou(surveyId);
    }
    /**/
    surveyRef = surveyId;
    setupQuestionTypeOptions();
    resetViewsToFalse(true);
    showSelectQuestionType = 'False';
    ReportFinderUtil rfu = new ReportFinderUtil();
    reportId = rfu.findReportId('Survey with Questions and Responses');
   
  }
  
  //test constructor and calls within it
  private static TestMethod void testCreateQuestionController(){
    SurveyTestingUtil tu = new SurveyTestingUtil();
    Apexpages.currentPage().getParameters().put('id',tu.surveyId);
    Apexpages.Standardcontroller std;
    SurveyAndQuestionController cqc = new SurveyAndQuestionController(std);
    cqc.addQuestion();
    cqc.getNewQuestionNum();
    cqc.makeNewQuestionLink();
    System.assert(cqc.surveyId == tu.surveyId);
  }
  
  
  //if you are using a developement org you will need to manually add your Pod.
  /* legacy
  public Pagereference updateUrl(){
    Survey__c survey = [select Name, Id, URL__c from Survey__c where id = :surveyId];  
    Site subSite = [select Subdomain, id from Site limit 1];
    if(survey.URL__c.contains(subSite.Subdomain))
      return null;
    else
      return updateDomain(survey, subSite);
  }
  */
  /*
  legacy
  private Pagereference updateDomain(Survey__c survey, Site subSite){
    String surveyUrl = survey.URL__c;
    String subdomainReplace = 'http://'+subSite.Subdomain;
    //surveyUrl = surveyUrl.replaceFirst('*.', subdomainReplace);
    surveyUrl = surveyUrl.substring(surveyUrl.indexOf('.'), surveyUrl.length());
    surveyUrl = subdomainReplace + surveyUrl;
    try{
        survey.URL__c = surveyUrl;
        update survey;
    }catch(Exception e){
        system.debug(e);
    }
    setSurveyNameAndThankYou(surveyId);
    return null;
  }
  */
  
  public Pagereference makeNewQuestionLink(){
    questionReference = null;
    resetViewsToFalse(true);
    return null;
  }
  
  public Pagereference editQuestion(){
    if (questionReference == null)
     return null;
    setupEditQuestion();
    showSelectQuestionType = 'True';
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
 
  //test constructor and calls within it
  private static TestMethod void testEditQuestion(){
    SurveyTestingUtil tu = new SurveyTestingUtil();
    Apexpages.currentPage().getParameters().put('id',tu.surveyId);
    Apexpages.Standardcontroller std;
    SurveyAndQuestionController cqc = new SurveyAndQuestionController(std);
    cqc.editQuestion();
    cqc.questionReference = tu.questionIds[0];
    cqc.editQuestion();
    cqc.questionReference = tu.questionIds[1];
    cqc.editQuestion();
    cqc.questionReference = tu.questionIds[2];
    cqc.editQuestion();
    cqc.questionReference = tu.questionIds[3];
    System.assert(cqc.editQuestion()==null);
    
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
    resetViewsToFalse(false);
    if(questionType=='Multi-Select--Vertical'){
     showMultiSelect='True';
    }
    else if(questionType == 'Single Select--Vertical'){
      showSingleSelect = 'True';
    }
    else if(questionType == 'Free Text'){
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
  
  
  //test the saving of new questions
  private static TestMethod void testsaveAndNewQuestion(){
    SurveyTestingUtil tu = new SurveyTestingUtil();
    Apexpages.currentPage().getParameters().put('id',tu.surveyId);
    Apexpages.Standardcontroller std;
    SurveyAndQuestionController cqc = new SurveyAndQuestionController(std);
    //test saving new question
    cqc.qQuestion = 'THIS IS A NEW QUESTION';
    cqc.qChoices = '1\\n2\\n3\\3';
    cqc.qRequired=true;
    cqc.questionType='Single Select--Vertical';
    cqc.saveAndNewQuestion();
    System.assertEquals(5, cqc.getNewQuestionNum());
    //edit existing question
    SurveyAndQuestionController cqcI = new SurveyAndQuestionController(std);
    cqcI.questionReference = tu.questionIds[0];
    cqcI.editQuestion();
    cqcI.qQuestion = 'THIS IS A NEW QUESTION THAT IS EXTRA LONG SO THE NAME SHORTENING CALL WILL BE USED, THIS SHOULD BE LONG ENOUGH NOW THIS IS A NEW';
    cqcI.qChoices = '1\\n2\\n3\\3';
    cqcI.qRequired=true;
    cqcI.questionType='Single Select--Vertical';
    cqcI.saveAndNewQuestion();
    System.assertEquals(5, cqcI.getNewQuestionNum());
  }
  
  public Pagereference controllerSavQuestion(){
    if(questionReference == null || questionReference.length() <5){
      return saveNewQuestion();
    }
    else{ 
      return updateQuestion();
    }
  }
  
 
  
  private static TestMethod void testsavesaveQuestion(){
    SurveyTestingUtil tu = new SurveyTestingUtil();
    Apexpages.currentPage().getParameters().put('id',tu.surveyId);
    Apexpages.Standardcontroller std;
    SurveyAndQuestionController cqc = new SurveyAndQuestionController(std);
    //test saving new question
    cqc.qQuestion = 'THIS IS A NEW QUESTION';
    cqc.qChoices = '1\\n2\\n3\\3';
    cqc.qRequired=true;
    cqc.questionType='Single Select--Vertical';
    cqc.controllerSavQuestion();
    System.assertEquals(5, cqc.getNewQuestionNum());
    //edit existing question
    SurveyAndQuestionController cqcI = new SurveyAndQuestionController(std);
    cqcI.questionReference = tu.questionIds[0];
    cqcI.editQuestion();
    cqcI.qQuestion = 'THIS IS A NEW QUESTION THAT IS EXTRA LONG SO THE NAME SHORTENING CALL WILL BE USED, THIS SHOULD BE LONG ENOUGH NOW';
    cqcI.qChoices = '1\\n2\\n3\\3';
    cqcI.qRequired=true;
    cqcI.questionType='Single Select--Vertical';
    cqcI.controllerSavQuestion();
    System.assertEquals(5, cqcI.getNewQuestionNum());
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
    }catch(Exception e){
      System.debug(e);
      Apexpages.addMessages(e);
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

  private Integer getNewQuestionNum(){
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
    }catch(Exception e){
      System.debug(e);
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
    else if(questionType =='Free Text'){
      showFreeTextPreview = 'True';
    }
    else if(questionType == 'Single Select--Horizontal'){
      showRowQuestionPreview = 'True';
      rowOptions = stringToSelectOptions(qChoices);
    }
    return null;
  }


   //test constructor and calls within it
  private static TestMethod void testPreviewQuestion(){
    SurveyTestingUtil tu = new SurveyTestingUtil();
    Apexpages.currentPage().getParameters().put('id',tu.surveyId);
    Apexpages.Standardcontroller std;
    SurveyAndQuestionController cqc = new SurveyAndQuestionController(std);
    
    cqc.questionReference = tu.questionIds[0];
    cqc.editQuestion();
    cqc.previewQuestion();

    cqc.questionReference = tu.questionIds[1];
    cqc.editQuestion();
    cqc.previewQuestion();
    
    cqc.questionReference = tu.questionIds[2];
    cqc.editQuestion();
    System.assert(cqc.previewQuestion()==null);
    
    cqc.questionReference = tu.questionIds[3];
    cqc.editQuestion();
    System.assert(cqc.previewQuestion()==null);
    
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
    }
    return null;
  } 
  
  private static Testmethod void testUpdateSurveyName() {
      SurveyTestingUtil tu = new SurveyTestingUtil();
      Apexpages.currentPage().getParameters().put('id',tu.surveyId);  
      Apexpages.Standardcontroller stc; 
      SurveyAndQuestionController vsc = new SurveyAndQuestionController(stc);
      vsc.surveyName = 'new name';
      system.assert(vsc.updateSurveyName() == null);
      
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
    }
    return null;
  }
  
  private static Testmethod void testupdateSurveyThankYouAndLink() {
    SurveyTestingUtil tu = new SurveyTestingUtil();
    Apexpages.currentPage().getParameters().put('id',tu.surveyId);  
    Apexpages.Standardcontroller stc; 
    SurveyAndQuestionController vsc = new SurveyAndQuestionController(stc);
    vsc.surveyThankYouText = 'new stuff';
    vsc.surveyThankYouURL = 'more new stff';
    system.assert(vsc.updateSurveyThankYouAndLink()==null);
  }
  
   public PageReference updateOrderList()
  {
    if(newOrderW.length() <= 0)
    {
        return null;
    }
    
    newOrderW = newOrderW.substring(0, newOrderW.length() -1);
    
    List<String> idsToUpdate = newOrderW.split(',',-1);
    List<Survey_Question__c> qsToUpdate = new List<Survey_Question__c>();
    
    Map<Id,Survey_Question__c> questionMap = new Map<Id,Survey_Question__c>([select Id, OrderNumber__c from Survey_Question__c where Id in :idsToUpdate]);
    Survey_Question__c sqToUpdate;
    
    for (Integer i = 0; i < idsToUpdate.size(); i++)
    {
        sqToUpdate = questionMap.get(idsToUpdate.get(i));
        sqToUpdate.OrderNumber__c = i;
        qsToUpdate.add(sqToUpdate);
    }
    
    update qsToUpdate;
    
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
  private static Testmethod void testRefreshQuestionList() {
      SurveyTestingUtil tu = new SurveyTestingUtil();
      Apexpages.currentPage().getParameters().put('id',tu.surveyId);
      Apexpages.Standardcontroller stc; 
      SurveyAndQuestionController vsc = new SurveyAndQuestionController(stc);
      vsc.getAQuestion();
      
      // Retrieve questions for this survey
      List<Survey_Question__c> sq = new List<Survey_Question__c>();
      sq = [Select id, orderNumber__c from Survey_Question__c];
      
      // get question with orderNumber 1
      Survey_Question__c first = [Select id, orderNumber__c from Survey_Question__c Where orderNumber__c =: 1 and Survey__c =: tu.surveyId];
      System.assert(first.orderNumber__c == 1 );    
     
      // Specify the new order
      vsc.newOrderW = vsc.allQuestions[2].id + ',' +
      vsc.allQuestions[0].id + ',' +
      vsc.allQuestions[1].id + ',' +
      vsc.allQuestions[3].id + ',';
      
      vsc.updateOrderList();
            
      // Verify that the question with order 1 is not the same as the one retrieved previously
      Survey_Question__c second = [Select id, orderNumber__c from Survey_Question__c Where orderNumber__c =: 1 and Survey__c =: tu.surveyId];
      System.assert(second.id != first.id);
      
      // update the question list, and make sure it has been modified as well
      vsc.refreshQuestionList();
    System.assert(vsc.allQuestions[1].id != first.id);
      
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
    if (questionReference!= null )
    {
         Survey_Question__c sq = [Select Id, Name FROM Survey_Question__c WHERE Id =: questionReference];
         delete sq;  
         questionReference = null;  
    }
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
      question theQ = new question(allQuestionsObject[i]);
      allQuestions.add(theQ);
      j = j+1.0;
    }
    responses = getResponses();
    try{
      update allQuestionsObject;
    }catch(Exception e){
      Apexpages.addMessages(e);
    }
      return saveOrUpdateReturn();
  }

//------------------------------------------------------------------------------//    
  private static TestMethod void testDeleteQuestion() {
      SurveyTestingUtil tu = new SurveyTestingUtil();
      Apexpages.currentPage().getParameters().put('id',tu.surveyId);
      Apexpages.Standardcontroller stc; 
      SurveyAndQuestionController vsc = new SurveyAndQuestionController(stc);
      
      
      // Get a question to delete
      Survey_Question__c sq = [Select id, orderNumber__c from Survey_Question__c Where orderNumber__c =: 1 and Survey__c =: tu.surveyId];
      vsc.questionReference = sq.Id;
      vsc.deleteRefresh();
      
      Survey_Question__c sq2 = [Select id, orderNumber__c from Survey_Question__c Where orderNumber__c =: 1 and Survey__c =: tu.surveyId];
      System.assert(sq.Id != sq2.Id);

      
  }
//------------------------------------------------------------------------------//  

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

   /** Class: question
    *  Retrieves the question information and puts it in the question object
    */    
  public class question{
      public String   name                   {get; set;}
      public String   id                     {get; set;}
      public String   question               {get; set;}
      public String   orderNumber            {get; set;}
      public String   choices                {get; set;}
      public List<SelectOption> singleOptions{get; set;}
      public List<SelectOption> multiOptions {get; set;}
      public Boolean  required               {get; set;}
      public String   questionType           {get; set;}  
      public String   surveyName             {get; set;}
      public String   renderFreeText         {get; set;}
      public String   renderSelectRadio      {get; set;}
      public String   renderSelectCheckboxes {get; set;} 
      public String   renderSelectRow        {get; set;}
      public List<String> responses          {get; set;}
      public String   singleOptionsForChart  {get; set;}
      public String   qResultsForChart       {get; set;} 
      public List<String> strList            {get; set;} // The question's option as a list of string
      public List<Integer> resultsCounts     {get; set;} // The count of each response to a question's choices
      public List<SelectOption> rowOptions   {get; set;}
      public boolean  noData                 {get; set;}
      
    /** Fills up the question object
     *  param:  Survey_Question__c 
       */     
     public question(Survey_Question__c sq) {
        name = sq.Name;
        id = sq.Id;
        System.debug('in Question found one with id '+id);
        question = sq.Question__c;
        orderNumber = String.valueOf(sq.OrderNumber__c+1);
        choices = sq.Choices__c;
        required = sq.Required__c;
        questionType = sq.Type__c;
        singleOptionsForChart = ' ';
     if (sq.Type__c=='Single Select--Vertical'){
        renderSelectRadio='true';
        singleOptions = stringToSelectOptions(choices);
        renderSelectCheckboxes='false';
        renderFreeText='false';
        renderSelectRow = 'false';
      }
     else if (sq.Type__c=='Multi-Select--Vertical'){    
        renderSelectCheckboxes='true';
        multiOptions = stringToSelectOptions(choices);
        renderSelectRadio='false';
        renderFreeText='false';
        renderSelectRow = 'false';
      }
     else if (sq.Type__c=='Single Select--Horizontal'){   
        renderSelectCheckboxes='false';
        rowOptions = stringToSelectOptions(choices);
        renderSelectRadio='false';
        renderFreeText='false';
        renderSelectRow = 'true';
      }
     else if (sq.Type__c=='Free Text'){
        renderFreeText='true';
        renderSelectRadio='false';
        renderSelectCheckboxes='false';
        renderSelectRow = 'false';
      }
        //responses= getResponses();
      }
      
     /** Splits up the string as given by the user and adds each option
      *  to a list to be displayed as option on the Visualforce page
      *  param: str String as submitted by the user
      *  returns the List of SelectOption for the visualforce page
        */  
      private List<SelectOption> stringToSelectOptions(String str){
      if (str == '')
      {
        return new List<SelectOption>();
      }
      strList = str.split('\n');
    
      List<SelectOption> returnVal = new List<SelectOption>();
      for(String s: strList){
        if (s!='') {
          returnVal.add(new SelectOption(s,s));
          if (s != 'null' && s!= null) {
            String sBis = s.replace(' ', '%20');
            singleOptionsForChart += s.trim()+'|';
          }
        }
      }
      singleOptionsForChart = singleOptionsForChart.substring(0, singleOptionsForChart.length()-1);
      return returnVal;
    } 
  }
  
  /** Fills up the List of questions to be displayed on the Visualforce page
   */ 
  public List<question> getAQuestion() {
    List<Survey_Question__c> allQuestionsObject = 
                    [Select s.Type__c, s.Id, s.Survey__c, s.Required__c, s.Question__c, 
                    s.OrderNumber__c, s.Name, s.Choices__c 
                    From Survey_Question__c s 
                    WHERE s.Survey__c =: surveyId ORDER BY s.OrderNumber__c];
    allQuestions = new List<question>();
    
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
      question theQ = new question(q);
      allQuestions.add(theQ);
    }
    allQuestionsSize = allQuestions.size();
    return allQuestions;
  } 

}