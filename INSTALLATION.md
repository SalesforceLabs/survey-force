# Survey Force

## Table of Contents

-   [Direct deployment to an org](#direct-deployment-to-an-org): Quickest option to install this unmanaged code into your org

-   [Installing the app using a Scratch Org](#installing-the-app-using-a-scratch-org): This is the recommended installation option. Use this option if you are a developer who wants to experience the app and the code.

-   [Installing the app using a Developer Edition Org or a Trailhead Playground](#installing-the-app-using-a-developer-edition-org-or-a-trailhead-playground): Useful when tackling Trailhead Badges or if you want the app deployed to a more permanent environment than a Scratch org.

## Direct deployment to an org

<a href="https://githubsfdeploy.herokuapp.com?owner=SalesforceLabs&repo=survey-force&ref=main">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

## Installing the app using a Scratch Org

1. Set up your environment. Follow the steps in the [Quick Start: Lightning Web Components](https://trailhead.salesforce.com/content/learn/projects/quick-start-lightning-web-components/) Trailhead project. The steps include:

    - Enable Dev Hub in your Trailhead Playground
    - Install Salesforce CLI
    - Install Visual Studio Code

2. If you haven't already done so, authorize your hub org and provide it with an alias (**myhuborg** in the command below):

    ```
    sfdx force:auth:web:login -d -a myhuborg
    ```

3. Clone the Survey Force repository:

    ```
    git clone https://github.com/salesforcelabs/survey-Force
    cd survey-force
    ```

4. Create a scratch org and provide it with an alias (**survey-force** in the command below):

    ```
    sfdx force:org:create -s -f config/project-scratch-def.json -a survey-force
    ```

5. Push the app to your scratch org:

    ```
    sfdx force:source:push
    ```

6. Assign the `Survey_Force_SuperAdmin` permission set to the admin user.

    ```
    sfdx force:user:permset:assign -n Survey_Force_SuperAdmin
    ```

7. Open the scratch org:

    ```
    sfdx force:org:open
    ```

8. In App Launcher, click **View All** then select the **Survey Force** app.

## Installing the App using a Sandbox, Developer Edition Org, or a Trailhead Playground

Follow this set of instructions if you want to deploy the app to a more permanent environment than a Scratch org.
This includes non source-tracked orgs such as a [free Developer Edition Org](https://developer.salesforce.com/signup) or a [Trailhead Playground](https://trailhead.salesforce.com/).

Make sure to start from a brand-new environment to avoid conflicts with previous work you may have done.

1. Authorize your Sandbox, Trailhead Playground, or Developer org and provide it with an alias (**mysurveyorg** in the command below):

    ```
    sfdx force:auth:web:login -d -a mysurveyorg
    ```

1. Clone this repository:

    ```
    git clone https://github.com/salesforcelabs/survey-force
    cd survey-force
    ```

1. If you are setting up a Developer Edition: go to **Setup**, under **My Domain**, [register a My Domain](https://help.salesforce.com/articleView?id=domain_name_setup.htm&type=5).

1. Run this command in a terminal to deploy the app.

    ```
    sfdx force:source:deploy -p force-app
    ```

1. If your org isn't already open, open it now:

    ```
    sfdx force:org:open -u mysurveyorg
    ```

1. Assign the `Survey_Force_SuperAdmin` permission set to the admin user.

    ```
    sfdx force:user:permset:assign -n Survey_Force_SuperAdmin
    ```

1. In App Launcher, select the **Survey Force** app.