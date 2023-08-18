#!/bin/bash

echo "Create new scratch org"
#sf force:org:create -f config/project-scratch-def.json -a SurveyForceScratchOrg -s
sf org create scratch --definition-file config/project-scratch-def.json --alias SurveyForceScratchOrg --set-default

echo "Pushing metadata"
#sf force:source:push
sf project deploy start

echo "Assigning Permissions"
sf force user permset assign --perm-set-name Survey_Force_SuperAdmin

echo "Opening Org"
sf org open --target-org SurveyForceScratchOrg

#Version Increase Comment

#Deploy to Survey force Dev/Packaging Org: Use -c to check only first
#sf org login web --alias SurveyForceDevOrg
#sf project deploy start --target-org SurveyForceDevOrg --wait 100 --source-dir force-app/main/default
