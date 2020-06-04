public with sharing class viewShareSurveyComponentController {
    
    public Id surveyId { get; set; }
    public List < SelectOption > urlType {get;set;}
    public String selectedURLType {get;set;}
    
    public String surveyURL {
        get {
            if (selectedURLType == 'Email Link, Anonymous' || selectedURLType == 'Chatter') {
                return 'id=' + surveyId + '&cId=none&caId=none';
            } else if (selectedURLType == 'Email Link w/ Contact Merge') {
                return 'id=' + surveyId + '&cId={!Contact.Id}&caId=none';
            } else {
                return 'id=' + surveyId + '&cId={!Contact.Id}&caId={!Case.id}';
            }
        }
        
        set;
    }
    
    public String surveySite {
        get{
            if(surveySite == null){
                surveySite = getVFUrl();
            }
            return surveySite;
        }
        set;
    }
    public String surveyURLBase {
        get {
            if (selectedURLType == 'Chatter') {
                surveyURLBase = getVFUrl();
            }else{
                surveyURLBase = surveySite;//Updated when select list is changed
            }
            return surveyURLBase;
        }
        set;
    }
    public viewShareSurveyComponentController() {
        urlType = new List < SelectOption > ();
        urlType.add(new SelectOption('Email Link w/ Contact Merge', System.Label.LABS_SF_Email_Link_w_Contact_Merge));
        urlType.add(new SelectOption('Email Link w/ Contact & Case Merge', System.Label.LABS_SF_Email_Link_w_Contact_Case_Merge));
        urlType.add(new SelectOption('Email Link, Anonymous', System.Label.LABS_SF_Email_Link_Anonymous));
        urlType.add(new SelectOption('Chatter', System.Label.LABS_SF_Chatter));
        selectedURLType = 'Chatter';
    }
    
    public String getVFUrl(){
        return 'https://' + ApexPages.currentPage().getHeaders().get('Host') + Page.TakeSurvey.getUrl() + '?';
    }
    
    
    
    public List < Selectoption > sitesPicklist {
        get{
            sitesPicklist = new List < Selectoption > ();
            try{
                sitesPicklist.add(new Selectoption(getVFUrl(), 'Internal'));
                
                //Site is standard object and there is no CRUD/FLS check for this as it can not be changed
                List<Site> siteList = [Select Name, Status,  Subdomain, UrlPathPrefix, SiteType, OptionsRequireHttps from Site where Subdomain != ''];
                
                
                //Use SiteDetail object to get Site URL. This way we don't have to generate URL ourselves
                //https://salesforce.stackexchange.com/questions/7639/get-site-url-from-apex
                List<String> idList = new List<String>();
                for(Site s: siteList){
                    idList.add(s.Id);
                }
                List<SiteDetail> siteDetailsList = [select DurableId, SecureUrl from SiteDetail where DurableId in :idList];
                Map<Id, String> siteDetailsMap = new Map<Id, String>();
                for(SiteDetail sd: siteDetailsList){
                    siteDetailsMap.put(sd.DurableId, sd.SecureUrl);
                }

                for(Site s: siteList){
                    if(siteDetailsMap.containsKey(s.Id)){
                        sitesPicklist.add(new Selectoption(siteDetailsMap.get(s.Id) + '/TakeSurvey?', s.Name));
                    }
                }
            }catch(Exception e){ System.debug('Exception:' + e.getMessage());
                               }
            return sitesPicklist;
        }
        set;
    }
}