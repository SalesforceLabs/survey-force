sfdx force:org:create -f config/project-scratch-def.json -a SurveyForceScratchOrgPkgTest -s

sfdx force:package:install -p 04t0H000001E2KJ -w 10

sfdx force:user:permset:assign -n Survey_Force_Admin

sfdx force:org:open

#Version Increase Comment


#Deploy to Survey force Dev/Packaging Org: Use -c to check only first
#
#sfdx force:source:deploy -u SurveyForceDevOrg -w 100 -p force-app/main/default
