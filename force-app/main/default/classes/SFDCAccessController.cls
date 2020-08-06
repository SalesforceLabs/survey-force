/**
 * OWASP Enterprise Security API (ESAPI)
 *
 * This file is part of the Open Web Application Security Project (OWASP)
 * Enterprise Security API (ESAPI) project. For details, please see
 * <a href="http://www.owasp.org/index.php/ESAPI">http://www.owasp.org/index.php/ESAPI</a>.
 *
 * Copyright (c) 2010 - Salesforce.com
 *
 * The Apex ESAPI implementation is published by Salesforce.com under the New BSD license. You should read and accept the
 * LICENSE before you use, modify, and/or redistribute this software.
 *
 * @author Yoel Gluck (securecloud .at. salesforce.com) <a href="http://www.salesforce.com">Salesforce.com</a>
 * @created 2010
 */

/**
 * This class provides access control functionality to enforce CRUD/FLS and sharing in the force.com platform.
 */
public with sharing class SFDCAccessController {

	/**
	 * OperationMode - this enum defines the DB operations mode to be used.
	 * <br>
	 * You can set the operation mode in the constructor or later using the setOperatoinMode() method.
	 * If you use the default constructor, we will set it to ALL_OR_NONE.
	 */
	public enum OperationMode {
		/**
		 * Will make sure all required fields have the proper permissions before any operation takes place.
		 */
		ALL_OR_NONE,
		/**
		 * Will only set fields that are allowed. Other fields will be omitted from operation, but operation will continue.
		 */
		BEST_EFFORT
	}


	public OperationMode omode {get;set;} // the current operation mode of this instance.

	public SFDCAccessController() {
		omode = OperationMode.ALL_OR_NONE; // defaults to all or none
	}

	// Shortcut function
	public Map<String,Schema.SObjectField> getFieldMap(SObjectType someType){
		return someType.getDescribe().fields.getMap();
	}


	/* Return a list of sobject fields that are viewable by this user
	 * (i.e. isAccessible() returns true)
	 * This is the optimized version when the fieldMap is already available
	 */
	public List<Schema.SObjectField> getViewableFields(Map<String,Schema.SObjectField> fieldsMap) {
		List<Schema.SObjectField> fields = new List<Schema.SObjectField>{};
		for(String key:fieldsMap.keySet()) {
			if(fieldsMap.get(key).getDescribe().isAccessible()) {
				fields.add(fieldsMap.get(key));
			}
		}
		return fields;
	}

	/* Return a list of sobject fields that are viewable by this user
	 */
	public List<Schema.SObjectField> getViewableFields(SObjectType someType) {
		Map<String,Schema.SObjectField> fieldsMap = getFieldMap(someType);
		return getViewableFields(fieldsMap);
	}

	public List<Schema.SObjectField> getViewableFields(SObject sobj) {
	    return getViewableFields(sobj.getSObjectType());
	}

	public void assertAuthorizedToView(Schema.SObjectType someType, List<Schema.SObjectField> fields) {
	    checkAuthorizedToView(someType, fields, true);
	}

	public void assertAuthorizedToCreate(Schema.SObjectType someType, List<Schema.SObjectField> fields) {
	    checkAuthorizedToCreate(someType, fields, true);
	}

	public void assertAuthorizedToUpdate(Schema.SObjectType someType, List<Schema.SObjectField> fields) {
	    checkAuthorizedToUpdate(someType, fields, true);
	}


	public void assertAuthorizedToCreate(Schema.SObjectType someType, List<String> fields) {
	    checkAuthorizedToCreate(someType, fields, true);
	}

	public void assertAuthorizedToUpdate(Schema.SObjectType someType, List<String> fields) {
	    checkAuthorizedToUpdate(someType, fields, true);
	}


	public Boolean isAuthorizedToView(Schema.SObjectType someType, List<Schema.SObjectField> fields) {
	    return checkAuthorizedToView(someType, fields, false);
	}

	public Boolean isAuthorizedToView(Schema.SObjectType someType, List<String> fieldNames) {
	    return checkAuthorizedToView(someType, fieldNames, false);
	}

	public Boolean isAuthorizedToUpdate(Schema.SObjectType someType, List<String> fieldNames) {
	    return checkAuthorizedToUpdate(someType, fieldNames, false);
	}

	public Boolean isAuthorizedToUpdate(Schema.SObjectType someType, List<Schema.SObjectField> fields) {
	    return checkAuthorizedToUpdate(someType, fields, false);
	}

	public Boolean isAuthorizedToCreate(Schema.SObjectType someType, List<String> fieldNames) {
	    return checkAuthorizedToCreate(someType, fieldNames, false);
	}

	public Boolean isAuthorizedToCreate(Schema.SObjectType someType, List<Schema.SObjectField> fields) {
	    return checkAuthorizedToCreate(someType, fields, false);
	}

	Boolean checkAuthorizedToCreate(Schema.SObjectType someType, List<String> fieldNames, Boolean throwException) {
        Schema.DescribeSObjectResult objDesc = someType.getDescribe();
		if (!objDesc.isCreateable()){
		    //SurveyForceUtil.log('checkAuthorizedToCreate - Object: ' + someType + ' is not createable');
			if (throwException) {
		        throw new SFDCAccessControlException('Access Violation',
														SFDCAccessControlException.ExceptionType.OBJECT_ACCESS_VIOLATION,
														SFDCAccessControlException.ExceptionReason.NO_CREATE,
														someType.getDescribe().getName(),
														null);
		    } else {
			    return false;
		    }
		}
		Map<String, Schema.SObjectField> fMap = someType.getDescribe().fields.getMap();

		//SurveyForceUtil.log('checkAuthorizedToCreate - FieldMap: ' +  fMap.keySet());

		for (String f : fieldNames) {
			Schema.SObjectField sObjectFld = fMap.get(f);
			if (sObjectFld == null) {
			    //SurveyForceUtil.log('checkAuthorizedToCreate - Field: ' + f + ' is  null');
				throw new SFDCAccessControlException('Field not found',
														SFDCAccessControlException.ExceptionType.FIELD_NOT_FOUND,
														SFDCAccessControlException.ExceptionReason.GENERIC,
														objDesc.getName(),
														f);
			}
			if (!sObjectFld.getDescribe().isCreateable()){
			    //SurveyForceUtil.log('checkAuthorizedToCreate - Field: ' + f + ' is  not createable');
				if (throwException) {
			        throw new SFDCAccessControlException('Access Violation',
															SFDCAccessControlException.ExceptionType.FIELD_ACCESS_VIOLATION,
															SFDCAccessControlException.ExceptionReason.NO_CREATE,
															someType.getDescribe().getName(),
															sObjectFld.getDescribe().getName());
			    } else {
				    return false;
			    }
			}
		}
		//SurveyForceUtil.log('checkAuthorizedToCreate - Type: ' + someType + ' fieldNames ' + fieldNames +  ' are createable');
		return true;
	}

	public Boolean checkAuthorizedToCreate(Schema.SObjectType someType, List<Schema.SObjectField> fields, Boolean throwException) {
		// check at object-level first
		if (!someType.getDescribe().isCreateable()){
		    //SurveyForceUtil.log('checkAuthorizedToCreate - Object: ' + someType + ' is not createable');
			if (throwException) {
		        throw new SFDCAccessControlException('Access Violation',
														SFDCAccessControlException.ExceptionType.OBJECT_ACCESS_VIOLATION,
														SFDCAccessControlException.ExceptionReason.NO_CREATE,
														someType.getDescribe().getName(),
														null);
		    } else {
			    return false;
		    }
		}

		// check each field
		for (Schema.SObjectField f : fields) {
		    //SurveyForceUtil.log('checkAuthorizedToCreate - Field: ' + f );
			if (!f.getDescribe().isCreateable()){
			    //SurveyForceUtil.log('checkAuthorizedToCreate - Field: ' + f + ' is  not createable');
				if (throwException) {
			        throw new SFDCAccessControlException('Access Violation',
															SFDCAccessControlException.ExceptionType.FIELD_ACCESS_VIOLATION,
															SFDCAccessControlException.ExceptionReason.NO_CREATE,
															someType.getDescribe().getName(),
															f.getDescribe().getName());
			    } else {
				    return false;
			    }
			}
		}
		//SurveyForceUtil.log('checkAuthorizedToCreate - Type: ' + someType + ' fields ' + fields +  ' are createable');
		return true;
	}


	/* Returns a list of sobject fields that are updateable by this user.
	 * This is the optimized version when the fieldMap is already available
	 */
	public List<Schema.SObjectField> getUpdateableFields(Map<String,Schema.SObjectField> fieldsMap) {
		List<Schema.SObjectField> fields = new List<Schema.SObjectField>{};
		for(String key:fieldsMap.keySet()) {
			if(fieldsMap.get(key).getDescribe().isUpdateable()) {
				fields.add(fieldsMap.get(key));
			}
		}
		return fields;
	}

	/* Returns a list of sobject fields that are updateable by this user.
	 */
	public List<Schema.SObjectField> getUpdateableFields(SObjectType someType) {
		Map<String,Schema.SObjectField> fieldsMap = getFieldMap(someType);
		return getUpdateableFields(fieldsMap);
	}

	public List<Schema.SObjectField> getUpdateableFields(SObject sobj) {
	    return getUpdateableFields(sobj.getSObjectType());
	}

	/* Returns a list of sobject fields that are createable by this user
	 * This is the optimized version when the fieldMap is already available
	 */
	public List<Schema.SObjectField> getCreatableFields(Map<String,Schema.SObjectField> fieldsMap) {
		List<Schema.SObjectField> fields = new List<Schema.SObjectField>{};
		for(String key:fieldsMap.keySet()) {
			if(fieldsMap.get(key).getDescribe().isCreateable()) {
				fields.add(fieldsMap.get(key));
			}
		}
		return fields;
	}

	public List<Schema.SObjectField> getCreatableFields(SObject sobj) {
	    return getCreatableFields(sobj.getSObjectType());
	}

	public List<Schema.SObjectField> getCreatableFields(SObjectType someType) {
		Map<String,Schema.SObjectField> fieldsMap = getFieldMap(someType);
		return getCreatableFields(fieldsMap);
	}


	/*
	 * Check to see if the user can delete this object type.
	 */
	public Boolean isAuthorizedToDelete(Schema.SObjectType someType) {
		// we only need to check CRUD
		return someType.getDescribe().isDeletable();
	}
	public Boolean assertAuthorizedToDelete(Schema.SObjectType someType) {
		if(!someType.getDescribe().isDeletable()) {
			throw new SFDCAccessControlException('Access Violation',
					SFDCAccessControlException.ExceptionType.OBJECT_ACCESS_VIOLATION,
					SFDCAccessControlException.ExceptionReason.NO_DELETE,
					someType.getDescribe().getName(),
					null);
		}
		return true;
	}
	public Boolean checkAuthorizedToView(Schema.SObjectType someType, List<Schema.SObjectField> fields, Boolean throwException) {
		// check at object-level first
		if (!someType.getDescribe().isAccessible()){
		    if (throwException) {		        throw new SFDCAccessControlException('Access Violation',
														SFDCAccessControlException.ExceptionType.OBJECT_ACCESS_VIOLATION,
														SFDCAccessControlException.ExceptionReason.NO_READ,
														someType.getDescribe().getName(),
														null);
		    } else { return false;
		    }
		}

		// check each field
		for (Schema.SObjectField f : fields) {
			if (!f.getDescribe().isAccessible()){
			    if (throwException) { throw new SFDCAccessControlException('Access Violation',
															SFDCAccessControlException.ExceptionType.FIELD_ACCESS_VIOLATION,
															SFDCAccessControlException.ExceptionReason.NO_READ,
															someType.getDescribe().getName(),
															f.getDescribe().getName());
			    } else { return false; }
			}
		}
		return true;
	}

	public Boolean checkAuthorizedToView(Schema.SObjectType someType, List<String> fieldNames, Boolean throwException) {
		Schema.DescribeSObjectResult objDesc = someType.getDescribe();
		if (!objDesc.isAccessible()){
			if (throwException) { throw new SFDCAccessControlException('Access Violation',
														SFDCAccessControlException.ExceptionType.OBJECT_ACCESS_VIOLATION,
														SFDCAccessControlException.ExceptionReason.NO_READ,
														someType.getDescribe().getName(),
														null);
		    } else { return false; }
		}

		Map<String, Schema.SObjectField> fMap = someType.getDescribe().fields.getMap();
		for (String f : fieldNames) {
			Schema.SObjectField sObjectFld = fMap.get(f);
			if (sObjectFld == null) {
				throw new SFDCAccessControlException('Field not found',
														SFDCAccessControlException.ExceptionType.FIELD_NOT_FOUND,
														SFDCAccessControlException.ExceptionReason.GENERIC,
														objDesc.getName(),
														f);
			}
			if (!sObjectFld.getDescribe().isAccessible()){
				if (throwException) { throw new SFDCAccessControlException('Access Violation',
															SFDCAccessControlException.ExceptionType.FIELD_ACCESS_VIOLATION,
															SFDCAccessControlException.ExceptionReason.NO_READ,
															someType.getDescribe().getName(),
															sObjectFld.getDescribe().getName());
			    } else { return false;
			    }
			}
		}
		return true;
	}

	Boolean checkAuthorizedToUpdate(Schema.SObjectType someType, List<Schema.SObjectField> fields, Boolean throwException) {
		// check at object-level first
		if (!someType.getDescribe().isUpdateable()){
			if (throwException) {
		        throw new SFDCAccessControlException('Access Violation',
														SFDCAccessControlException.ExceptionType.OBJECT_ACCESS_VIOLATION,
														SFDCAccessControlException.ExceptionReason.NO_UPDATE,
														someType.getDescribe().getName(),
														null);
		    } else {
			    return false;
		    }
		}

		// check each field
		for (Schema.SObjectField f : fields) {
			if (!f.getDescribe().isUpdateable()){
				if (throwException) {
			        throw new SFDCAccessControlException('Access Violation',
															SFDCAccessControlException.ExceptionType.FIELD_ACCESS_VIOLATION,
															SFDCAccessControlException.ExceptionReason.NO_UPDATE,
															someType.getDescribe().getName(),
															f.getDescribe().getName());
			    } else {
				    return false;
			    }
			}
		}
		return true;
	}

	Boolean checkAuthorizedToUpdate(Schema.SObjectType someType, List<String> fieldNames, Boolean throwException) {
		Schema.DescribeSObjectResult objDesc = someType.getDescribe();
		if(!objDesc.isUpdateable()){
			if (throwException) {
		        throw new SFDCAccessControlException('Access Violation',
														SFDCAccessControlException.ExceptionType.OBJECT_ACCESS_VIOLATION,
														SFDCAccessControlException.ExceptionReason.NO_UPDATE,
														someType.getDescribe().getName(),
														null);
		    } else {
			    return false;
		    }
		}
		Map<String, Schema.SObjectField> fMap = someType.getDescribe().fields.getMap();
		for (String f : fieldNames) {
			Schema.SObjectField sObjectFld = fMap.get(f);
			if (sObjectFld == null) {
				throw new SFDCAccessControlException('Field not found',
														SFDCAccessControlException.ExceptionType.FIELD_NOT_FOUND,
														SFDCAccessControlException.ExceptionReason.GENERIC,
														objDesc.getName(),
														f);
			}
			if (!sObjectFld.getDescribe().isUpdateable()){
				if (throwException) {
			        throw new SFDCAccessControlException('Access Violation',
															SFDCAccessControlException.ExceptionType.FIELD_ACCESS_VIOLATION,
															SFDCAccessControlException.ExceptionReason.NO_UPDATE,
															someType.getDescribe().getName(),
															sObjectFld.getDescribe().getName());
			    } else {
				    return false;
			    }
			}
		}
		return true;
	}


}