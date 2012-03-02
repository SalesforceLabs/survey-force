public with sharing class viewShareSurveyComponentController {

public Id surveyId {get;
    set{
        this.surveyId = value;
        init();
    }

}

public Survey__c mySurvey {get;set;}
public List<SelectOption> urlType {get;set;}
public String selectedURLType {get;set;}
public String POD                                {get; set;}
public List<Selectoption>  sitesPicklist         {get; set;} 
public String surveySite                         {get; set;}
public String showAddSitesMessage                {get; set;} 
private String subdomain; 
private boolean useTopLevelDomain;                        
public String siteInfo  {get; set;}

public String surveyURL{
    get{
        if (selectedURLType == 'Email Link, Anonymous' || selectedURLType == 'Chatter')
        {
            return 'id=' + surveyId + '&cId=none&caId=none';
        }
        else if (selectedURLType == 'Email Link w/ Contact Merge')
        {
            return 'id=' + surveyId + '&cId={!Contact.Id}&caId=none';
        }
        else
        {
            return 'id=' + surveyId +  '&cId={!Contact.Id}&caId={!Case.id}';
        }
    }
    
    set;
}

public String surveyURLBase{
    get{
            if(surveySite == '--SELECT SITE--'){
               POD='';
              return null;
            }
       
            String urlPrefix = setupUrlPrefix(surveySite);
            String domain = setupDomainForSurvey(POD);
            String urlToSave= domain+'/'+urlPrefix+'TakeSurvey?';
            if (surveySite == 'Internal' || selectedURLType == 'Chatter')
            {
                urlToSave = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/' + 'TakeSurvey?';
            }
            return urlToSave;
    }
    set;
}




public viewShareSurveyComponentController()
{
    urlType = new List<SelectOption>();
    urlType.add(new SelectOption('Email Link w/ Contact Merge',System.Label.LABS_SF_Email_Link_w_Contact_Merge));
    urlType.add(new SelectOption('Email Link w/ Contact & Case Merge',System.Label.LABS_SF_Email_Link_w_Contact_Case_Merge));
    urlType.add(new SelectOption('Email Link, Anonymous',System.Label.LABS_SF_Email_Link_Anonymous));
    urlType.add(new SelectOption('Chatter',System.Label.LABS_SF_Chatter)); 
    selectedURLType = 'Chatter';
    
    setupPOD();
    setupSitesPicklist();
    siteInfo = Site.getDomain();
    
    init();
}

private void setupPOD()
{
    String urlToSplit = URL.getSalesforceBaseUrl().toExternalForm();
    List<String> splitURL = urlToSplit.split('\\.');
    Integer loc = -1;
    Integer i;
    
    
    for (i = 0; i < splitURL.size(); i++)
    {
        
         if(splitURL.get(i) == 'visual' || splitURL.get(i)  == 'salesforce'){
              loc = i - 1;
                 break;
          }
    }
    
    
    if (loc == -1)
    {
        pod = 'NO_POD';
        return;
    }
    
    if(splitURL.get(loc + 1)=='visual')
    {
        pod = splitURL.get(loc);
    }
    else
    {
        pod = 'NO_POD';
    }
    
    
    
}


 private void setupSitesPicklist(){
    
    List<SurveySitesUtil.SurveySiteInfo> sites = new SurveySitesUtil().getSiteList();
    if (sites.size() > 0) {
        subdomain = sites[0].Subdomain;
    } 
    useTopLevelDomain=false;
    String pathPrefix;
    sitesPicklist = new List<Selectoption>();
    sitesPicklist.add(new Selectoption('Internal',System.Label.LABS_SF_Internal));
    for(SurveySitesUtil.SurveySiteInfo current : sites){
      if(current.prefix == null)
        pathPrefix='EMPTY';
      else
        pathPrefix=current.prefix;
        
      sitesPicklist.add(new Selectoption(pathPrefix, current.Name));
    }
    
    surveySite = 'Internal';
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




public void init()
{
    if (surveyId != null)
    {
        mySurvey = [Select Id, Name, Survey_Header__c, thankYouText__c, thankYouLink__c, URL__c FROM Survey__c where Id=:surveyId];
    }
}


private static testmethod void testShareSurvey()
{
    Survey__c mySurvey = new Survey__c();
    mySurvey.Submit_Response__c = 'empty';  
    insert mySurvey;
    
    viewShareSurveyComponentController vss = new viewShareSurveyComponentController();
    vss.surveyId = mySurvey.Id;
    
    vss.selectedURLType = 'Chatter';
    System.assertEquals(URL.getSalesforceBaseUrl().toExternalForm() + '/apex/' + 'TakeSurvey?', vss.surveyURLBase);
    System.assertEquals('id=' + mySurvey.Id + '&cId=none&caId=none', vss.surveyURL);
    
    vss.selectedURLType = 'Email Link w/ Contact Merge';
    System.assertEquals('id=' + mySurvey.Id + '&cId={!Contact.Id}&caId=none', vss.surveyURL);
    
    vss.selectedURLType = 'Email Link w/ Contact & Case Merge';
    System.assertEquals('id=' + mySurvey.Id +  '&cId={!Contact.Id}&caId={!Case.id}', vss.surveyURL);

    System.assertEquals(true, vss.checkSubdomain('test.developer-edition.salesforce'));
    System.assertEquals(false, vss.checkSubdomain(null));
    System.assertEquals(false, vss.checkSubdomain('test.salesforce.com'));
    
    System.assertEquals('', vss.setupUrlPrefix('EMPTY'));
    
    vss.surveySite = '--SELECT SITE--';
    System.assertEquals(null, vss.surveyURLBase);
    

    
}

}