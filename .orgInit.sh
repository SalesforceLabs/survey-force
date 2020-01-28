sfdx force:org:create -f config/project-scratch-def.json -a SurveyForceScratchOrg -s

sfdx force:source:push

sfdx force:user:permset:assign -n Survey_Force_Admin

sfdx force:org:open