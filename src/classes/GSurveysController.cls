/*
Copyright (c) 2011, salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, 
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, 
    this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, 
    this list of conditions and the following disclaimer in the documentation 
    and/or other materials provided with the distribution.
    * Neither the name of the salesforce.com, Inc. nor the names of its contributors 
    may be used to endorse or promote products derived from this software 
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
OF THE POSSIBILITY OF SUCH DAMAGE.

*/
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
    String pathPrefix;
    sitesPicklist = new List<Selectoption>();
    List<Site> sites = [select Name, Subdomain, TopLevelDomain, UrlPathPrefix from Site where Status = 'Active' ];
    setupDomain(sites);
    setupShowSites(sites.size());
    sitesPicklist.add(new Selectoption('--SELECT SITE--',System.Label.SELECTSITE ));
    for(Site s : sites){
      if(s.UrlPathPrefix == null)
        pathPrefix='EMPTY';
      else
        pathPrefix=s.UrlPathPrefix;
      sitesPicklist.add(new Selectoption(pathPrefix, s.Name));
    }
  }

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
     return null;
    }
    if(surveySite == '--SELECT SITE--'){
     POD='';
     return null;
    }
    
    String urlPrefix = setupUrlPrefix(surveySite);
    String domain = setupDomainForSurvey(POD);
    String urlToSave= domain+'/'+urlPrefix+'TakeSurvey?';
    
    Survey__c s = new Survey__c();
    s.Name = newSurveyName;
    s.URL__c = urlToSave;
    s.Submit_Response__c = 'empty';
    s.thankYouText__c = 'Your survey has been submitted. Thank you for taking our survey.';
    s.thankYouLink__c='http://www.salesforce.com';
    try{
     insert s;
     createAnonSurveyTaker(s.Id);
     return new Pagereference('/apex/SurveyPage?id='+s.Id);
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