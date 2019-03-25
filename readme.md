# Post Install Guide - Public Facing Surveys

## General Surveys

1. Create a Force.com Site. [Details, including "Creating a Force.com Site"](http://wiki.developerforce.com/page/An_Introduction_to_Force.com_Sites)
1. Modify your Site's ["Public Access Settings"](https://login.salesforce.com/help/doc/en/sites_public_access_settings.htm)
1. Check "Read" access to "Survey" and "Survey Question" object.
1. Check "Read" and "Create" access for "Surveys Taken" and "Survey Question Responses"
1. Add the Visualforce page, "Take Survey" to the list of enabled Visualforce pages.

## Survey Connecting to Contact or Case Records

1. Complete "General Surveys" steps.
1. Check "Read" access for "Contact" object.
1. Check "Read" access for "Case" object.
1. Private OWD for Case and Contact ?
     i. Create a public group and add the survey site user. 
     i. Grant read access to case and contact to this group by creating 2 sharing rules
 [Check this thread for further information.](http://boards.developerforce.com/t5/Force-com-Labs-Development-and/Survey-Force-Question/m-p/407457#M1197)
