public with sharing class SurveyForceUtil {
    /**
    * @return the current ESAPI SFDCAccessController object being used to maintain the access control rules for this application.
    */
    public static SFDCAccessController AccessController {
        get {
            if (AccessController == null) {
                AccessController = new SFDCAccessController();
            }
            return AccessController;
        } private set;
    }

    public static void log(String message){
        System.debug(message);
    }

    /**
     * Moved from old ReportFinderUtil class to consolidate utilities
     */
    public static String findReportId(String reportName){

        List<Report> myReport = [SELECT Id,Name FROM Report WHERE Name= :reportName];
        if(myReport.size() > 0) {
            return myReport[0].Id;
        }
        return null;
    }
}