sfdx force:org:create -f config/project-scratch-def.json -a SurveyForceScratchOrg -s

sfdx force:source:push

sfdx force:user:permset:assign -n Survey_Force_SuperAdmin

sfdx force:org:open

#Version Increase Comment


#Deploy to Survey force Dev/Packaging Org: Use -c to check only first
#
#sfdx force:source:deploy -u SurveyForceDevOrg -w 100 -p force-app/main/default
