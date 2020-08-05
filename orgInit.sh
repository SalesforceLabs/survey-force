sfdx force:org:create -f config/project-scratch-def.json -a SurveyForceScratchOrg2 -s

sfdx force:source:push

sfdx force:user:permset:assign -n Survey_Force_Admin

sfdx force:org:open

#Version Increase Comment


#Convert sfdx source to mdapi as we still have src folder
#sfdx force:source:convert -d src
#Deploy to Survey force Dev/Packaging Org: Use -c to check only first
#sfdx force:mdapi:deploy -d src -u SurveyForceDevOrg -w 100
