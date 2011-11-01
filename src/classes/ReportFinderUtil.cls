public with sharing class ReportFinderUtil {

  public ReportFinderUtil(){}
  
  public String findReportId(String reportName){
  	
  	Sobject myReport = [select Id,Name From Report Where Name=:reportName];
  	return myReport.Id;
  	
  	/*Pagereference pr = new Pagereference('/servlet/servlet.ReportList');
  	Dom.Document doc = getDomDocumentFromPageReference(pr);
    Dom.Xmlnode root = doc.getRootElement();
    Dom.Xmlnode reportNode = getReportNode(root, reportName);
    if (reportNode != null){
      String val = reportNode.getChildElement('id', null).getText();
      if(val != null)
        return val;
    }
    return '00O';*/
  }
  
  
}