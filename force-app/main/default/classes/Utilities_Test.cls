@isTest
private class Utilities_Test {
    @isTest
    private static void getInstance(){
        String instance = '';
        Organization o = [SELECT OrganizationType, InstanceName FROM Organization limit 1];
        String orgType = o.OrganizationType;
        String insName = o.InstanceName;

        //Set this header to test it
        ApexPages.currentPage().getHeaders().put('Host', insName+'.visual.force.com');

        if(orgType == 'Developer Edition'){
            List<String> parts = ApexPages.currentPage().getHeaders().get('Host').split('\\.');
            instance = parts[parts.size() - 4] + '.';
        }

        System.assertEquals(instance.toLowerCase(), Utilities.getInstance());
    }
    @isTest
    private static void getSubdomainPrefix(){
        String subdomainPrefix = Utilities.getSubdomainPrefix();
        //This will always be empty unless it's sandbox
        //If sandbox then check for that
        if(!Utilities.getInstance().startsWithIgnoreCase('cs')){
	        System.assertEquals('', subdomainPrefix);
        }else{
	        System.assertEquals('sandbox-', subdomainPrefix);
        }
    }

}