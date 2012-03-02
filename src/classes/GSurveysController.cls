global with sharing class GSurveysController {
  
  public String surveyDelete                       {get; set;}
  public String newSurveyName                      {get; set;}
  public List<miniSurvey>allSurveys                {get; set;}
  public String username                           {get; set;}
  public String userId                             {get; set;}
  public String POD                                {get; set;}
  public List<Selectoption>  sitesPicklist         {get; set;} 
  public String surveySite                         {get; set;}
  public String showAddSitesMessage                {get; set;} 
  private String subdomain;
  private boolean useTopLevelDomain;
  
  public String siteInfo  {get; set;}
  
  public GSurveysController(ApexPages.StandardController stdController){
    username = System.Userinfo.getUserId();    
    setAllSurveys();
    setupSitesPicklist();
    siteInfo = Site.getDomain();
  }
  
  
  private void setupSitesPicklist(){
    List<SurveySitesUtil.SurveySiteInfo> sites = new SurveySitesUtil().getSiteList();
    if (sites.size() > 0) {
        subdomain = sites[0].Subdomain;
    }
    useTopLevelDomain=false;
    String pathPrefix;
    sitesPicklist = new List<Selectoption>();
//    List<Site> sites = [select Name, Subdomain, TopLevelDomain, UrlPathPrefix from Site where Status = 'Active' ];
    //setupDomain(sites);
    setupShowSites(sites.size());
    sitesPicklist.add(new Selectoption('--SELECT SITE--',System.Label.LABS_SF_SELECTSITE ));
    sitesPicklist.add(new Selectoption('Internal',System.Label.LABS_SF_Internal));
    for(SurveySitesUtil.SurveySiteInfo s : sites){
      if(s.prefix == null)
        pathPrefix='EMPTY';
      else
        pathPrefix=s.prefix;
      sitesPicklist.add(new Selectoption(pathPrefix, s.Name));
    }
  }

/*
  private void setupDomain(list <Site> sites){
    String subD;
    String tLevelDomain;
    useTopLevelDomain =false;
    if(sites!=null && sites.size()>0){
      if(sites[0].TopLevelDomain != null && sites[0].TopLevelDomain.length()>0){
        subdomain = sites[0].TopLevelDomain;
        useTopLevelDomain=true;
      }
      else
        subdomain = sites[0].Subdomain;
    }
  }
*/
  private void setupShowSites(Integer i){
    if(i>0){
      showAddSitesMessage = 'false';
    }
    else{
      showAddSitesMessage = 'true';
    }
  }

  private void setAllSurveys(){
   List<Survey__c> surveys = [Select Id, Name from Survey__c where IsDeleted = false order by Name];
  
   if(allSurveys == null){
      allSurveys = new List<miniSurvey>();
    }
   else{
      allSurveys.clear(); 
    }
   for(Survey__c s : surveys){
      allSurveys.add(new miniSurvey(s.Name, s.Id));
    }
  }
  
  private static TestMethod void testGSurveysController(){
    SurveyTestingUtil tu = new SurveyTestingUtil();
    Apexpages.currentPage().getParameters().put('uId', Userinfo.getUserId());
    Apexpages.Standardcontroller stc;
    GSurveysController sc = new GSurveysController(stc);
    System.assert(sc.allSurveys.size()>0);
  }  
  
  public Pagereference makeNewSurvey(){   
    if(newSurveyName==null){
     POD='';
     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.LABS_SF_Survey_Name_Is_Required));
     return null;
    }
    if(surveySite == '--SELECT SITE--'){
     POD='';
     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.LABS_SF_Survey_Site_Is_Required));
     return null;
    }
    
    
    
    String urlPrefix = setupUrlPrefix(surveySite);
    String domain = setupDomainForSurvey(POD);
    String urlToSave= domain+'/'+urlPrefix+'TakeSurvey?';
    if (surveySite == 'Internal')
    {
        urlToSave = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/' + 'TakeSurvey?';
    }
    
    Survey__c s = new Survey__c();
    s.Name = newSurveyName;
    s.URL__c = urlToSave;
    s.Submit_Response__c = 'empty';
    s.thankYouText__c = System.Label.LABS_SF_Survey_Submitted_Thank_you;
    s.thankYouLink__c='http://www.salesforce.com';
    try{
     insert s;
     createAnonSurveyTaker(s.Id);
     return new Pagereference('/apex/SurveyManagerPage?id='+s.Id);
    }catch(Exception e){
      return null;
    }
  }

  private static void createAnonSurveyTaker(String surveyId){
     list <SurveyTaker__c> sTakers = [select id from SurveyTaker__c where Survey__c = :surveyId and Contact__c = null and Case__c = null];
     if(sTakers != null && sTakers.size()>0)
       return;
     SurveyTaker__c st = new SurveyTaker__c();      
     st.Case__c = null;
     st.Survey__c = surveyId;
     st.Contact__c = null;
     insert st;
  }
  
  private String setupDomainForSurvey(String pod){
    if(pod != 'NO_POD' && !useTopLevelDomain && checkSubdomain(subdomain)){
      return 'http://'+subdomain+'.'+pod+'.force.com';
    }
    else if(pod != 'NO_POD' && useTopLevelDomain && checkSubdomain(subdomain)){
      return 'http://'+subdomain+'.'+pod;
    }
    else if(useTopLevelDomain) {
      return 'http://'+subdomain;   
    }
    else{
      return 'http://'+subdomain+'.force.com';
    }
  }
  
  private boolean checkSubdomain(String subdomain){
    if(subdomain == null)
     return false;
    else if (subdomain.contains('developer-edition'))
     return true;
    else
     return false;
  }
  
  private String setupUrlPrefix(String site){
    if(site == null || site=='EMPTY')
     return '';
    else
     return site+'/';
  }

  public Pagereference doSurveyReset(){
    setAllSurveys();
    return null;
  }

  private static TestMethod void testMakeNewSurvey(){
    SurveyTestingUtil tu = new SurveyTestingUtil();
    Apexpages.currentPage().getParameters().put('uId', Userinfo.getUserId());
    Apexpages.Standardcontroller stc;
    GSurveysController sc = new GSurveysController(stc);
    System.assert(sc.makeNewSurvey()==null);
    sc.surveySite = '--SELECT SITE--';
    sc.newSurveyName = 'TestMakeNewSurvey';
    system.assert(sc.makeNewSurvey()==null);
    sc.surveySite = 'blah';
    System.assert(sc.makeNewSurvey()!=null);
    sc.doSurveyReset();     
  }
  
  public static webservice String deleteSurvey(String deleteId){
    Survey__c s= [Select Id, Name from Survey__c where Id =:deleteId];
    delete s;
    
    return 'true';
  }
  
  private static TestMethod void testDeleteSurvey(){
    SurveyTestingUtil tu = new SurveyTestingUtil();
    Apexpages.currentPage().getParameters().put('uId', Userinfo.getUserId());
    Apexpages.Standardcontroller stc;
    GSurveysController sc = new GSurveysController(stc);
    System.assertEquals(GSurveysController.deleteSurvey(tu.surveyId),'true');
  }
  
  public Class miniSurvey{
    public String sName {get; set;}
    public String sId   {get; set;}
    
    public miniSurvey(String miniName, String miniId){
      sName = miniName;
      sId = miniId;
    } 
      
  }
}