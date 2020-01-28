public with sharing class Util {
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
}