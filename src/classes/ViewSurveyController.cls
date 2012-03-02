/* Controller associated with pages rendering the survey.
 * Used by SurveyPage, ResultsPage, TakeSurvey
 */
global virtual with sharing class ViewSurveyController {
    public String  qQuestion                      {get; set;}
  public Boolean qRequired                      {get; set;}
  public String  qChoices                       {get; set;}
    public String surveyName                        {get; set;}
    public String surveyHeader                {get; set;}
    public String surveyId                          {get; 
        set{
            this.surveyId = value;
            init();
        }
    }   
    public String renderSurveyPreview           {get; set;}  
    public String questionName                    {get; set;}  
    public String questionType                    {get; set;}
    public Boolean questionRequired             {get; set;}
  public List<SelectOption> singleOptions   {get; set;} 
    public List<question> allQuestions        {get; set;}
    public List<String> responses                   {get; set;}
    public Integer allQuestionsSize               {get; set;}
    public String  templateURL                {get; set;}
    public String  surveyThankYouText         {get; set;}
    public String surveyContainerCss {get; set;}
    public String  surveyThankYouURL          {get; set;}
  public String  caseId                     {get; set;}
  public String contactId {get;set;}
    public String anonymousAnswer {get;set;}
    public List<SelectOption> anonymousOrUser {get;set;}
    public Boolean isInternal {get;set;}
    public String baseURL {get;set;}
    
    public String userId{get;set;}
    public String userName{get;set;}
    public String surveyTakerId {get;set;}
    public Boolean thankYouRendered{get;set;}
    public List<String> newOrder {get;set;}
    
    /* Retrieves the list of questions, the survey name, after retrieving the 
       necessary parameters from the url.
    */
 //------------------------------------------------------------------------------// 
    public ViewSurveyController(ApexPages.StandardController stdController) {
        // Get url parameters
        surveyId = Apexpages.currentPage().getParameters().get('id');
        caseId   = Apexpages.currentPage().getParameters().get('caId');
        contactId = Apexpages.currentPage().getParameters().get('cId'); 
    
        if(caseId ==null || caseId.length()<5){
            caseId = 'none';
        }
        if(contactId ==null || contactId.length()<5){
            contactId = 'none';
        }           
        // By default the preview is not showing up
        renderSurveyPreview = 'false';

        init();
    } 
    
    public ViewSurveyController(viewShareSurveyComponentController controller)
    {
        surveyId = Apexpages.currentPage().getParameters().get('id');
        caseId   = Apexpages.currentPage().getParameters().get('caId');
        contactId = Apexpages.currentPage().getParameters().get('cId'); 
        if(caseId ==null || caseId.length()<5){
            caseId = 'none';
        }
        if(contactId ==null || contactId.length()<5){
            contactId = 'none';
        }       
        // By default the preview is not showing up
        renderSurveyPreview = 'false';
        init();
    }
    
    
    public void init()
    {
        if (surveyId != null){ 
            // Retrieve all necessary information to be displayed on the page
            allQuestions = new List<question>();
            setupQuestionList();
            setSurveyNameAndThankYou(surveyId);
            anonymousOrUser = new List<SelectOption>();
            anonymousOrUser.add(new SelectOption('Anonymous',System.Label.LABS_SF_Anonymous));
            anonymousOrUser.add(new SelectOption('User','User ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName()));
            anonymousAnswer = 'Anonymous';
            isInternal =true;
            newOrder = new List<String>();
            String urlBase = URL.getSalesforceBaseUrl().toExternalForm();
            baseURL = urlBase;
            
            userId = UserInfo.getUserId();
            userName = UserInfo.getName();
            
            String profileId = UserInfo.getProfileId();
            try
            {
                Profile p = [select Id, UserType from Profile where Id=:profileId];
                if (p.UserType == 'Guest')
                {
                    isInternal = false;
                }
                else
                {
                    isInternal = true;
                }
            }
            catch (Exception e){
                isInternal = false;
            }
            
            
            thankYouRendered=false;
            
            
        }       
    }
    
    
    

//------------------------------------------------------------------------------//  
    private static Testmethod void testViewSurveyController() {
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id',tu.surveyId);  
        Apexpages.Standardcontroller stc;   
        ViewSurveyController vsc = new ViewSurveyController(stc);
        vsc.init();
        System.assert(vsc.allQuestionsSize == 4);
        System.assert(tu.surveyId != null);
        
        
        vsc.submitResults();
        for (question q : vsc.allQuestions)
        {
            q.selectedOption = String.valueof(2);
            q.choices = String.valueof(2);
            q.selectedOptions = new List<String>();
            q.selectedOptions.add(String.valueof(2));
            vsc.submitResults();            
        }
        System.assertEquals(true, vsc.thankYouRendered);
        
        
        //test something
    }
//----------------------------------------------------------------------------//    
    
    /* Called during the setup of the page. 
       Retrieve questions and responses from DB and inserts them in 2 lists. */
    public Integer setupQuestionList(){

        getAQuestion();
        return allQuestions.size();
    }
    
    
   /** Sets the survey's name variable
    *  param: sID   The survey ID as specified in the DB
    */
    public void setSurveyNameAndThankYou(String sId){
        Survey__c s = [SELECT Name, Id, URL__c, Thank_You_Text__c, thankYouText__c, thankYouLink__c, Survey_Header__c, Survey_Container_CSS__c FROM Survey__c WHERE Id =:sId];
        surveyName = s.Name;
        surveyHeader = s.Survey_Header__c;
        templateURL = s.URL__c+'id='+sId;//+'&cId={!Contact.Id}'+'&caId='+'{!Case.id}';
        surveyThankYouText = s.Thank_You_Text__c;
        if (surveyThankYouText == null)
        {
            surveyThankYouText = System.Label.LABS_SF_Survey_Submitted_Thank_you;
        }
        surveyThankYouURL = s.thankYouLink__c;
        surveyContainerCss = s.Survey_Container_CSS__c;
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
      ViewSurveyController vsc = new ViewSurveyController(stc);
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
    ViewSurveyController vsc = new ViewSurveyController(stc);
    vsc.surveyThankYouText = 'new stuff';
    vsc.surveyThankYouURL = 'more new stff';
    system.assert(vsc.updateSurveyThankYouAndLink()==null);
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
  private static boolean checkRequired(String response, Survey_Question__c question){
    if(question.Required__c == true){
        if(response == null || response =='NO RESPONSE')
          return false;
    }
    return true;
  } 

   /** Redirects the page that displays the detailed results of the survey, 
       from all users who took the survey.
    */
    public PageReference resultPage() {
        return new PageReference('/apex/ResultsPage?id='+surveyId);
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
      public String   id                           {get; set;}
      public String   question               {get; set;}
      public String   orderNumber            {get; set;}
      public String   choices                {get; set;}
      public String   selectedOption         {get;set;}
      public List<String> selectedOptions {get;set;}
      public List<SelectOption> singleOptions{get; set;}
      public List<SelectOption> multiOptions {get; set;}
      public Boolean  required               {get; set;}
      public String   questionType           {get; set;}    
      public String   surveyName               {get; set;}
      public String   renderFreeText             {get; set;}
        public String   renderSelectRadio      {get; set;}
        public String   renderSelectCheckboxes {get; set;} 
        public String   renderSelectRow        {get; set;}
      public List<String> responses              {get; set;}
      public String   singleOptionsForChart  {get; set;}
      public String   qResultsForChart         {get; set;} 
      public List<String> strList              {get; set;} // The question's option as a list of string
      public List<Integer> resultsCounts       {get; set;} // The count of each response to a question's choices
      public List<SelectOption> rowOptions   {get; set;}
      public boolean  noData                 {get; set;}
      
      /** Fills up the question object
       *  param:    Survey_Question__c 
       */     
     public question(Survey_Question__c sq) {
        name = sq.Name;
        id = sq.Id;
        question = sq.Question__c;
        orderNumber = String.valueOf(sq.OrderNumber__c+1);
        choices = sq.Choices__c;
        required = sq.Required__c;
        questionType = sq.Type__c;
        singleOptionsForChart = ' ';
        selectedOption = '';
        selectedOptions = new List<String>();
     if (sq.Type__c=='Single Select--Vertical'){
                renderSelectRadio='true';
                singleOptions = stringToSelectOptions(choices);
            
                renderSelectCheckboxes='false';
                renderFreeText='false';
                renderSelectRow = 'false';
        selectedOption = '';
        selectedOptions = new List<String>();                               
      }
     else if (sq.Type__c=='Multi-Select--Vertical'){        
                renderSelectCheckboxes='true';
                multiOptions = stringToSelectOptions(choices);
                renderSelectRadio='false';
                renderFreeText='false';
              renderSelectRow = 'false';
        selectedOption = '';
        selectedOptions = new List<String>();
      }
     else if (sq.Type__c=='Single Select--Horizontal'){   
          renderSelectCheckboxes='false';
          rowOptions = stringToSelectOptions(choices);
          renderSelectRadio='false';
          renderFreeText='false';
          renderSelectRow = 'true';
        selectedOption = '';
        selectedOptions = new List<String>();     
      }
     else if (sq.Type__c=='Free Text'){
            renderFreeText='true';
            renderSelectRadio='false';
            renderSelectCheckboxes='false';
          renderSelectRow = 'false';
          choices='';
      }
        //responses= getResponses();
      }
      
       /** Splits up the string as given by the user and adds each option
        *  to a list to be displayed as option on the Visualforce page
        *  param: str   String as submitted by the user
        *  returns the List of SelectOption for the visualforce page
        */  
      private List<SelectOption> stringToSelectOptions(String str){
        if (str == '')
        {
            return new List<SelectOption>();
        }
        strList = str.split('\n');
      
        List<SelectOption> returnVal = new List<SelectOption>();
        Integer i = 0;
        for(String s: strList){
            if (s!='') {    
                if (s != 'null' && s!= null) {
                    String sBis = s.replace(' ', '%20');
                    singleOptionsForChart += s.trim()+'|';
                    
                    /*RSC2012-02-20
                    String st = s.replace (' ', '&nbsp;');
                    returnVal.add(new SelectOption(String.valueOf(i),st));
                    */
                    returnVal.add(new SelectOption(String.valueOf(i),s));
                    System.debug('*****VALUES: ' + s);
                    i++;
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
            qQuestion = '';
            qChoices ='';
        
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
    
    public void submitResults()
    {
        List <SurveyQuestionResponse__c> sqrList = new List<SurveyQuestionResponse__c>();
        
        for (question q : allQuestions)
        {
            SurveyQuestionResponse__c sqr = new SurveyQuestionResponse__c();
            if (q.renderSelectRadio == 'true')
            {
                
                if (q.required &&  (q.selectedOption == null || q.selectedOption == ''))
                {
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out all required fields'));
                    return;
                }
                
                if (q.selectedOption == null || q.selectedOption == '')
                {
                    sqr.Response__c = '';
                }
                else
                {
                    sqr.Response__c = q.singleOptions.get(Integer.valueOf(q.selectedOption)).getLabel();
                }
                sqr.Survey_Question__c = q.Id;
                sqrList.add(sqr);
            }
            else if (q.renderFreeText == 'true')
            {
                if (q.required && q.choices == '')
                {
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out all required fields'));
                    return;
                }
                System.debug('*****Select Radio ' + q.choices);
                
                sqr.Response__c = q.choices;
                sqr.Survey_Question__c = q.Id;
                sqrList.add(sqr);
            }
            else if (q.renderSelectCheckboxes == 'true')
            {
                if (q.required && (q.selectedOptions == null || q.selectedOptions.size() == 0))
                {
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out all required fields'));
                    return;
                }
                
                for (String opt : q.selectedOptions)
                {
                    sqr = new SurveyQuestionResponse__c();
                    if (opt == '' || opt == null)
                    {
                        sqr.Response__c = '';
                    }               
                    else
                    {   
                        sqr.Response__c = q.multiOptions.get(Integer.valueOf(opt)).getLabel();
                    }
                    sqr.Survey_Question__c = q.Id;
                    sqrList.add(sqr);
                }
            }
            else if (q.renderSelectRow == 'true')
            {
                if (q.required && (q.selectedOption == null || q.selectedOption == ''))
                {
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out all required fields'));
                    return;
                }
                
                if (q.selectedOption == null || q.selectedOption == '')
                {
                    sqr.Response__c = '';
                }
                else
                {
                    sqr.Response__c = q.rowOptions.get(Integer.valueOf(q.selectedOption)).getLabel();
                }
                sqr.Survey_Question__c = q.Id;
                sqrList.add(sqr);
            }
            
             
        }
        if(AddSurveyTaker())
        {
            for (SurveyQuestionResponse__c sqr : sqrList)
            {
                sqr.SurveyTaker__c = surveyTakerId;
            }
            insert sqrList;
            thankYouRendered=true;      
        }

        
    }
    
    
    private Boolean AddSurveyTaker()
    {
        String userId;
        
        if (surveyId == null)
        {
            return false;
        }
        if(caseId.toUpperCase() =='NONE'|| caseId.length()<5)
          caseId = null;    
        if(contactId.toUpperCase() =='NONE'|| contactId.length()<5)
          contactId = null;         
        if (anonymousAnswer != 'Anonymous')
        {
            userId = UserInfo.getUserId();
        }
        else
        {
            userId = null;
        }
        
        if(anonymousAnswer != 'Anonymous' && (contactId != null || caseId != null))
        {
            List<SurveyTaker__c> check = [Select Contact__c, Survey__c, Case__c, User__c From SurveyTaker__c Where Contact__c=:contactId and Survey__c=:surveyId and Case__c = :caseId and User__c=:UserId];
            if(check != null && check.size()>0){
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.LABS_SF_You_have_already_taken_this_survey));
                
                return false;       
            }
        }
        
     
        
        SurveyTaker__c st = new SurveyTaker__c();
        st.Contact__c = contactId;
        st.Survey__c = surveyId;
        st.Taken__c = 'false';
        st.Case__c = caseId;
        st.User__c = userId;
        insert st;  
        surveyTakerId = st.Id;
        return true;    
    }
        

}