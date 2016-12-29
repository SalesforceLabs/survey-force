public with sharing class SurveyManagerController {
    private ApexPages.StandardController stdControl;
    public Boolean editCSS {get; set;}

    public String surveyId {get;set;}
    public String reportId {get;set;}
    public Survey__c survey {get;set;}

    public Message pageMessage {
        get {
            if (pageMessage == null) {
                pageMessage = new Message();
            }
            return pageMessage;
        }
        set;
    }

    public SurveyManagerController(ApexPages.StandardController stdController){
        this.stdControl = stdController;
        if(!test.isRunningTest()){stdController.addFields(new List<String>{'Hide_Survey_Name__c', 'Survey_Header__c', 'Thank_You_Text__c', 'Survey_Container_CSS__c'});}
        survey = (Survey__c)stdController.getRecord();

        try {

            List<User> res = [SELECT Profile.PermissionsAuthorApex FROM User WHERE id = :Userinfo.getUserId()];
            User u = res[0];
            if (u.Profile.PermissionsAuthorApex) {
                this.editCSS = true;
            } else {
                this.editCSS = false;
            }

            surveyId = stdController.getRecord().Id;
            surveyId = surveyId.substring(0,15);
            String reportName = 'Survey with Questions and Responses';
            Sobject myReport = [select Id, Name From Report Where Name = :reportName];
            reportId = myReport.Id;
        }catch(Exception e){
            pageMessage.setMessage(e.getMessage(), 'error');
            ApexPages.addMessages(e);
        }
    }
    /*
    //Generate report link for Report tab
    public pageReference getResults(){
        //String params = 'drilldown=1&drillcol=072i0000006VZRd&drillval=a03i000000S9W0C&drillop=equals

        //return new PageReference('/' + reportId + '?pv0=' + surveyId);
        return new PageReference('/' + reportId);
    }
    */

    public Pagereference save(){
        //Adding default CSS to add some space around survey
        //But this is changeable
        try {
            survey.Survey_Container_CSS__c = (String.isEmpty(survey.Survey_Container_CSS__c))?'':survey.Survey_Container_CSS__c.replaceAll('<[^>]+>',' ');
            update survey;
        }catch(Exception e){pageMessage.setMessage(e.getMessage(), 'error');ApexPages.addMessages(e);}
        return null;
    }
    /*

    Public String reportChartFilter;
    public String getReportChartFilter(){
        Reports.ReportDescribeResult descRes = Reports.ReportManager.describeReport(reportId);

        List<ColumnFilter> availableColumnFilters = new List<ColumnFilter>();

        for (Reports.ReportTypeColumnCategory category : descRes.getReportTypeMetadata().getCategories()) {
            for (Reports.ReportTypeColumn col : category.getColumns().values()) {
                if (col.getFilterable()) {
                    ColumnFilter cf = new ColumnFilter(
                            col.getLabel(),
                            col.getName(),
                            col.getDataType().name()
                    );
                    availableColumnFilters.add(cf);
                    System.debug('cf::' + cf);
                }
            }
        }
        List<ColumnFilter> selectedFilters = new List<ColumnFilter>();
        for (ColumnFilter cf : availableColumnFilters) {
            if (String.isNotBlank(cf.operator)) {
                selectedFilters.add(cf);
            }
        }
        return JSON.serialize(selectedFilters);
    }

    public class ColumnFilter {
        public ColumnFilter(String lab, String col, String dt) {
            label = lab;
            column = col;
            dataType = dt;
        }

        // Values needed for apex:analytics component
        public String column { get; set; }
        public String operator { get; set; }
        public String value { get; set; }

        // Values need for display and operator select list
        public String label { get; set; }
        public String dataType { get; set; }

    }
    */
}