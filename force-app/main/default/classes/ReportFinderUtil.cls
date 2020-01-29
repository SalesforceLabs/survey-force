public with sharing class ReportFinderUtil {

  public ReportFinderUtil(){}
  
  public String findReportId(String reportName){
    
    List<Report> myReport = [select Id,Name From Report Where Name=:reportName];
    if(myReport.size() > 0) {
      return myReport[0].Id;
    }
    return null;
  }
  
  
}