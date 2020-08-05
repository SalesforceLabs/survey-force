public with sharing class ViewSurveyResultsComponentController {

    public String mysurveyId {get;set;}


    public String reportId {get;set;}
    public PageReference results;

    public ViewSurveyResultsComponentController(){
        reportId = SurveyForceUtil.findReportId('Survey with Questions and Responses');

    }


    public pageReference getResults(){
        mysurveyId = mysurveyId.substring(0,15);
        return new PageReference('/' + reportId + '?pv0=' + mysurveyId);
    }

}
