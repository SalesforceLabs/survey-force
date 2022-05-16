# Post Install Guide - Public Facing Surveys

## Instalation & Setup

- ["Install Survey Force"](https://appexchange.salesforce.com/appxListingDetail?listingId=a0N30000003I2gDEAS)
- Assign "Survey Force - SuperAdmin" permission set to system administrator
- Assign "Survey Force - Admin" to anyone who will administer specific surveys
- Assign "Survey Force - Guest" permission set to Force.com Site guest user (Complete steps on Force.com Site configuration below)

For detailed SFDX installation instructions that do not require installing a package, see the [Installation Instructions](./INSTALLATION.md)

## General Surveys

1. Go to "Survey Force App"
   ![Survey Force App](assets/images/SF_App.png)
1. Open "Getting Started" page
   ![Getting Started Page](assets/images/SF_Page_GettingStarted.png)
1. Click "Make a Sample Survey"
1. Click "View Sample Survey"

You should be able to see the survey, add questions, edit CSS, share survey with users and see results. Test this survey by sending it to users. In case of errors, check user permissions to appropriate survey objects. There are 4 Survey objets that you need to check.

Make sure that you check access for Force.com site guest user if you plan to embed this survey in Force.com site.

- Survey
- Survey Question Response
- Survey Taker
- Survey Question

## Surveys in Force.com sites

1. Create a Force.com Site. [Details, including "Creating a Force.com Site"](https://help.salesforce.com/articleView?id=sites_setup_overview.htm&type=5)
1. You can assign "Survey Force - Guest" permission set to this site's guest user
   - You need to activate the Site otherwise guest user will not be activated and you cannot assign permission set
   - You will get "Your account has been disabled" error
   1. Go to the Sites list (https://yourdomain.lightning.force.com/lightning/setup/CustomDomain/home)
   1. Click on the Site Label
   1. Click Public Access Settings
   1. Click View Users
   1. Click the Site user
   1. Add the Survey Force - Guest permission set to that user
   1. If desired, rename the user to something more user-friendly. Do not change other fields.
1. OR you can manually assign all the permission to Guest user profile or create a new permission set
   1. Modify your Site's ["Public Access Settings"](https://help.salesforce.com/articleView?id=sites_public_access_settings.htm&type=5)
   1. Check "Read" access to "Survey" and "Survey Question" object.
   1. Check "Read" and "Create" access for "Surveys Taken" and "Survey Question Responses"
   1. Check "Read" and "Create" access for "Surveys Taken" and "Survey Question Responses"
   1. Make sure to provide Read/Edit access (as applicable) to all fields in above objects. Otherwise guest users may see "Unauthorized Error" because of field access violation.
1. Add the Visualforce page, "Take Survey" to the list of enabled Visualforce pages.
1. Add the Apex Classes
   - SFDCAccessControlException
   - SFDCAccessController
   - SFMessage
   - SFQuestion
   - SurveySitesUtil
   - ViewSurveyController
   - ViewSurveyControllerWithoutSharing
1. Create a Sharing Rule for "Survey" in Setup->Sharing Settings. Allow Read access to "Guest" user where "Publicly Available" (Field:Survey\_\_c.Share_with_Guest_User\_\_c) is true (or any other criteria)
   - Without this, Guest user cannot see Survey object becasue of new Guest user restrictions
   - See below for details

## Survey Connecting to Contact or Case Records

1. Complete "General Surveys" steps.
1. Check "Read" access for "Contact" object.
1. Check "Read" access for "Case" object.
1. Private OWD for Case and Contact?
   1. Create a public group and add the survey site user.
   1. Grant read access to case and contact to this group by creating 2 sharing rules
   1. [Check this thread for further information.](http://boards.developerforce.com/t5/Force-com-Labs-Development-and/Survey-Force-Question/m-p/407457#M1197)

## Extra Notes

Following notes were posted by "Cynthia Chen" on https://appexchange.salesforce.com/listingDetail?listingId=a0N30000003I2gDEAS&revId=a0S3A00000Jk9SvUAJ&tab=r

1. Error on viewing the report results of the survey: error messages "The report ID and the developer name are not defined. Provide either the report ID or the developer name for the report that contains the chart." and "List has no rows for assignment to SObject"

   - It is because the user has no permission to see the report "Survey with Questions and Responses“, share the report folder to the user will solve this error. If want to share this report to all internal users, create a Public Group and add All Internal Users will be OK. (Enable automatic access to records using role hierarchies for public groups by selecting Grant Access Using Hierarchies when creating the group. However, don’t use this option if you’re creating a public group with All Internal Users as members.) (The all internal user group is created only after portals/community are enabled.)

2. If want to put an image in the survey title and let the survey taker see the image,

   - Sites > [PublicSiteName] > Public Access Settings > Field-Level Security > look for the survey object > view > give reading permissions to the header： Survey Header
     (This permission is included in the Guest permission set, so if you use that, this step is not necessary.)

3. "Secure guest user record access": Enabling this will stop Guest user access to Salesforce org data. Enabling this may result in Guest user not having access to Survey Force records. More details are at: https://help.salesforce.com/articleView?id=networks_secure_guest_user_sharing.htm&type=5. Be careful when enabling this feature.
   - For this to work, DML code for Guest user has been moved to a without sharing class (ViewSurveyControllerWithoutSharing.cls)
   - Create a sharing rule to allow read access to Survey object (and all child objects that includes Survey Questions)
     - This is for the Guest user to be able to view Survey and Survey Questions
       ![SurveyForce Guest User Sharing Rule](assets/images/SurveyForce_GuestUser_SharingRule.png)
   - This sharing rule is based on a new field added to Survey\_\_c object which is true by default. To remove access from Guest user, you can change the default value option OR create a Process Builder process, Flow, or trigger to remove it conditionally based on data
   - Do NOT assign Guest user as Owner of Sharing rule (only sharing rule is needed)

## Latest Changes

1. After updating to latest version on the main branch, the ONLY SurveyForce static resources needed are the SurveyForce folder and the UserGuide pdf. All other resources have been removed.
2. A new field has been added to allow hiding a specific question on the survey. This allows you to modify and "remove" questions without losing response data.

## Upgrade Options

### Upgrading the package

Unfortunately, Survey Force is un-managed package and cannot be upgraded as per standard package upgrade process. To use this, you need to uninstall existing package and install the latest version. However, you will lose any customizations to code and existing data for included objects.

### Upgrading the source code

Because this is an unmanaged package, you have to upgrade your source code directly. This is one way you can upgrade with source code; however, extensive testing is highly recommended.

#### GitHub Repo

- Pull source from this GitHub repo from "main" branch
- Push this code to a sandbox
  - Keep track of any custom changes you may have made to this application and implement those changes again
- Test all the new changes
- Once testing is complete, push those changes to production and re-test

#### Package Installation

- In sandbox, you can uninstall older package version (note that this will delete all data if you are using a full sandbox, so do this in a developer sandbox)
- Install latest package from AppExchange
  - Keep track of any custom changes you may have made to this application and implement those changes again
- Test all the new changes
- Once testing is complete, push those changes to production or the next sandbox in your promotion chain and re-test
- Delete unnecessary metadata (see below)

#### Metadata to delete if upgrading

There are some metadata items that have been removed from the repository because they were unnecessary. Please manually delete these from your org if upgrading the package. This will be necessary when pushing the metadata from your dev sandbox/scratch org to your full/partial sandbox. If your promotion tools do not include destructive changes, you will need to delete these items in Production as well.

- The ONLY Static Resources now used are SurveyForce (an archive/zip file) and SurveyForce_UserGuide.pdf. Delete the following:
  - SurveyForce_SLDS
  - SurveyForce_jquery_ui
  - SurveyForce_jquery.js
  - SurveyForce_svg4everybody.js

## Issues

### Error in Class.SFDCAccessControllerTest.testAccessControl: line 141, column 1 (RESOLVED April 2021)

- This is because "Create Audit Field" feature has been enabled; https://help.salesforce.com/articleView?id=000328426&type=1&mode=1
- https://github.com/SalesforceLabs/survey-force/issues/94
- You can temporairly disable that permission in production OR Remove that test code in https://github.com/SalesforceLabs/survey-force/blob/master/force-app/main/default/classes/SFDCAccessControllerTest.cls (line#141 and 142)
