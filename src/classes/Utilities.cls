/**
 * Using without sharing as need to run query on Organization table
 */
public without sharing class Utilities {

    //Get instance from INSTANCE.visual.force.com page so we can build
    public Static String getInstance(){
        String instance = '';

        //There is no CRUD/FLS on Organization table
        Organization o = [SELECT OrganizationType, InstanceName FROM Organization limit 1];
        instance = o.InstanceName + '.';
        return instance.toLowerCase();
    }
    //Needed in cases if current org is sandbox
    public static String getSubdomainPrefix(){
        //There is no CRUD/FLS on Organization table
        Organization o = [SELECT OrganizationType, InstanceName FROM Organization limit 1];
        String orgType = o.OrganizationType;
        String insName = o.InstanceName;
        if(insName.startsWithIgnoreCase('cs')){
            return UserInfo.getUserName().substringAfterLast('.')+ '-';
        }
        return '';
    }
}