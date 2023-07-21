#sfdx force:org:create -f config/project-scratch-def.json -a SurveyForceScratchOrg -s

sfdx org create scratch -f config/project-scratch-def.json -a SurveyForceScratchOrg -d 

#sfdx force:source:push
sfdx project deploy start

sfdx force:user:permset:assign -n Survey_Force_SuperAdmin

#sfdx force:org:open
sfdx org open

#Version Increase Comment


#Deploy to Survey force Dev/Packaging Org: Use -c to check only first
#
#sfdx force:source:deploy -u SurveyForceDevOrg -w 100 -p force-app/main/default
