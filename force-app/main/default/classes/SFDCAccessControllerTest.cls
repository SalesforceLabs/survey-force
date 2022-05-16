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
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class SFDCAccessControllerTest {
	static SFDCAccessController accessController = new SFDCAccessController();

	@isTest
	private static void testAccessControlRunAs() {
		String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
		// This code runs as the system user
		Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
		User u = new User(
			Alias = 'standt',
			Email = 'standarduser@testorg.com',
			EmailEncodingKey = 'UTF-8',
			LastName = 'Testing',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US',
			ProfileId = p.Id,
			TimeZoneSidKey = 'America/Los_Angeles',
			UserName = uniqueUserName
		);

		System.runAs(u) {
			try {
				System.debug(Schema.Survey__c.SobjectType.getDescribe().isAccessible());

				accessController.assertAuthorizedToCreate(Schema.Survey__c.SobjectType, new List<Schema.SObjectField>{ Schema.Survey__c.fields.Name });
				System.assert(false, 'Should not succeed as Survey__c  is not accessible to standard user');
			} catch (SFDCAccessControlException ex) {
				System.assert(!String.isBlank(ex.getText()));
				System.assertEquals(SFDCAccessControlException.ExceptionType.OBJECT_ACCESS_VIOLATION, ex.getExceptionType());
				System.assertEquals(SFDCAccessControlException.ExceptionReason.NO_Create, ex.getExceptionReason());
				System.assertEquals('Survey__c', ex.getExceptionObject());
			}
			try {
				System.debug(Schema.Survey__c.SobjectType.getDescribe().isAccessible());

				Boolean retVal = accessController.checkAuthorizedToCreate(Schema.Survey__c.SobjectType, new List<Schema.SObjectField>{ Schema.Survey__c.fields.Name }, false);
				System.assertEquals(false, retVal);
			} catch (SFDCAccessControlException ex) {
				System.assert(!String.isBlank(ex.getText()));
				System.assertEquals(SFDCAccessControlException.ExceptionType.OBJECT_ACCESS_VIOLATION, ex.getExceptionType());
				System.assertEquals(SFDCAccessControlException.ExceptionReason.NO_Create, ex.getExceptionReason());
				System.assertEquals('Survey__c', ex.getExceptionObject());
			}
			try {
				System.debug(Schema.Survey__c.SobjectType.getDescribe().isAccessible());

				accessController.assertAuthorizedToView(Schema.Survey__c.SobjectType, new List<Schema.SObjectField>{ Schema.Survey__c.fields.Name });
				System.assert(false, 'Should not succeed as Survey__c  is not accessible to standard user');
			} catch (SFDCAccessControlException ex) {
				System.assert(!String.isBlank(ex.getText()));
				System.assertEquals(SFDCAccessControlException.ExceptionType.OBJECT_ACCESS_VIOLATION, ex.getExceptionType());
				System.assertEquals(SFDCAccessControlException.ExceptionReason.NO_READ, ex.getExceptionReason());
				System.assertEquals('Survey__c', ex.getExceptionObject());
			}
			try {
				System.debug(Schema.Survey__c.SobjectType.getDescribe().isAccessible());

				Boolean retVal = accessController.checkAuthorizedToView(Schema.Survey__c.SobjectType, new List<Schema.SObjectField>{ Schema.Survey__c.fields.Name }, false);
				System.assertEquals(false, retVal);
			} catch (SFDCAccessControlException ex) {
				System.assert(!String.isBlank(ex.getText()));
				System.assertEquals(SFDCAccessControlException.ExceptionType.OBJECT_ACCESS_VIOLATION, ex.getExceptionType());
				System.assertEquals(SFDCAccessControlException.ExceptionReason.NO_READ, ex.getExceptionReason());
				System.assertEquals('Survey__c', ex.getExceptionObject());
			}
			try {
				System.debug(Schema.Survey__c.SobjectType.getDescribe().isAccessible());

				Boolean retVal = accessController.checkAuthorizedToView(Schema.Survey__c.SobjectType, new List<String>{ 'Name' }, false);
				System.assertEquals(false, retVal);
			} catch (SFDCAccessControlException ex) {
				System.assert(!String.isBlank(ex.getText()));
				System.assertEquals(SFDCAccessControlException.ExceptionType.OBJECT_ACCESS_VIOLATION, ex.getExceptionType());
				System.assertEquals(SFDCAccessControlException.ExceptionReason.NO_READ, ex.getExceptionReason());
				System.assertEquals('Survey__c', ex.getExceptionObject());
			}
			try {
				System.debug(Schema.Survey__c.SobjectType.getDescribe().isAccessible());

				Boolean retVal = accessController.checkAuthorizedToView(Schema.Survey__c.SobjectType, new List<String>{ 'Name' }, true);
				System.assertEquals(false, retVal);
			} catch (SFDCAccessControlException ex) {
				System.assert(!String.isBlank(ex.getText()));
				System.assertEquals(SFDCAccessControlException.ExceptionType.OBJECT_ACCESS_VIOLATION, ex.getExceptionType());
				System.assertEquals(SFDCAccessControlException.ExceptionReason.NO_READ, ex.getExceptionReason());
				System.assertEquals('Survey__c', ex.getExceptionObject());
			}
		}
	}

	@isTest
	private static void testAccessControl() {
		Contact c = new Contact();

		List<Schema.SObjectField> contactLastModifiedDate = new List<Schema.SobjectField>{ Schema.Contact.fields.LastModifiedDate };

		Boolean setAuditFieldsEnabled = Schema.SObjectType.Profile.fields.getMap().containsKey('PermissionsCreateAuditFields');

		// if permission is available, it might be possible to set LastModifiedDate on create
		if (!setAuditFieldsEnabled) {
			System.assertEquals(false, accessController.isAuthorizedToCreate(Schema.Contact.SobjectType, contactLastModifiedDate));
			System.assertEquals(false, accessController.isAuthorizedToCreate(Schema.Contact.SobjectType, new List<String>{ 'LastModifiedDate' }));

			try {
				accessController.assertAuthorizedToCreate(Schema.Contact.SobjectType, contactLastModifiedDate);
				System.assert(false, 'Should not succeed in saving as LastModified date is not creatable');
			} catch (SFDCAccessControlException ex) {
				System.assert(!String.isBlank(ex.getText()));
				System.assertEquals(SFDCAccessControlException.ExceptionType.FIELD_ACCESS_VIOLATION, ex.getExceptionType());
				System.assertEquals(SFDCAccessControlException.ExceptionReason.NO_CREATE, ex.getExceptionReason());
				System.assertEquals('Contact', ex.getExceptionObject());
				System.assertEquals('LastModifiedDate', ex.getExceptionField());
			}
		}

		// can never modify lastmodified date
		System.assertEquals(false, accessController.isAuthorizedToUpdate(Schema.Contact.SobjectType, contactLastModifiedDate));
		System.assertEquals(false, accessController.isAuthorizedToUpdate(Schema.Contact.SobjectType, new List<String>{ 'LastModifiedDate' }));

		try {
			accessController.assertAuthorizedToUpdate(Schema.Contact.SobjectType, contactLastModifiedDate);
			System.assert(false, 'Should not succeed in saving as Lastmodified date is not updateable');
		} catch (SFDCAccessControlException ex) {
			System.assert(!String.isBlank(ex.getText()));
			System.assertEquals(SFDCAccessControlException.ExceptionType.FIELD_ACCESS_VIOLATION, ex.getExceptionType());
			System.assertEquals(SFDCAccessControlException.ExceptionReason.NO_UPDATE, ex.getExceptionReason());
			System.assertEquals('Contact', ex.getExceptionObject());
			System.assertEquals('LastModifiedDate', ex.getExceptionField());
		}

		try {
			accessController.assertAuthorizedToUpdate(Schema.Contact.SobjectType, new List<String>{ 'LastModifiedDate' });
			System.assert(false, 'Should not succeed in saving as Lastmodified date is not updateable');
		} catch (SFDCAccessControlException ex) {
			System.assert(!String.isBlank(ex.getText()));
			System.assertEquals(SFDCAccessControlException.ExceptionType.FIELD_ACCESS_VIOLATION, ex.getExceptionType());
			System.assertEquals(SFDCAccessControlException.ExceptionReason.NO_UPDATE, ex.getExceptionReason());
			System.assertEquals('Contact', ex.getExceptionObject());
			System.assertEquals('LastModifiedDate', ex.getExceptionField());
		}
		try {
			accessController.assertAuthorizedToDelete(Schema.Contact.SobjectType);
			System.assert(true, 'Should succeed in deleting contact object');
		} catch (SFDCAccessControlException ex) {
			System.assert(!String.isBlank(ex.getText()));
			System.assertEquals(SFDCAccessControlException.ExceptionType.OBJECT_ACCESS_VIOLATION, ex.getExceptionType());
			System.assertEquals(SFDCAccessControlException.ExceptionReason.NO_DELETE, ex.getExceptionReason());
			System.assertEquals('Contact', ex.getExceptionObject());
		}
		try {
			accessController.assertAuthorizedToDelete(Schema.ApexLog.SobjectType);
			System.assert(false, 'Should not succeed as ApexLog  is not deletable');
		} catch (SFDCAccessControlException ex) {
			System.assert(!String.isBlank(ex.getText()));
			System.assertEquals(SFDCAccessControlException.ExceptionType.OBJECT_ACCESS_VIOLATION, ex.getExceptionType());
			System.assertEquals(SFDCAccessControlException.ExceptionReason.NO_DELETE, ex.getExceptionReason());
			System.assertEquals('ApexLog', ex.getExceptionObject());
		}

		try {
			accessController.assertAuthorizedToCreate(Schema.Contact.SobjectType, new List<String>{ 'LastModifiedDate' });
			System.assert(false, 'Should not succeed in saving as Lastmodified date is not creatable');
		} catch (SFDCAccessControlException ex) {
			System.assert(!String.isBlank(ex.getText()));
			System.assertEquals(SFDCAccessControlException.ExceptionType.FIELD_ACCESS_VIOLATION, ex.getExceptionType());
			System.assertEquals(SFDCAccessControlException.ExceptionReason.NO_CREATE, ex.getExceptionReason());
			System.assertEquals('Contact', ex.getExceptionObject());
			System.assertEquals('LastModifiedDate', ex.getExceptionField());
		}

		try {
			accessController.assertAuthorizedToCreate(Schema.ApexLog.SobjectType, new List<Schema.SObjectField>{ Schema.ApexLog.fields.Status });
			System.assert(false, 'Should not succeed in saving as ApexLog  is not creatable');
		} catch (SFDCAccessControlException ex) {
			System.assert(!String.isBlank(ex.getText()));
			System.assertEquals(SFDCAccessControlException.ExceptionType.OBJECT_ACCESS_VIOLATION, ex.getExceptionType());
			System.assertEquals(SFDCAccessControlException.ExceptionReason.NO_CREATE, ex.getExceptionReason());
			System.assertEquals('ApexLog', ex.getExceptionObject());
			System.assertEquals(null, ex.getExceptionField());
		}

		try {
			accessController.assertAuthorizedToUpdate(Schema.ApexLog.SobjectType, new List<Schema.SObjectField>{ Schema.ApexLog.fields.Status });
			System.assert(false, 'Should not succeed in saving as ApexLog  is not updateable');
		} catch (SFDCAccessControlException ex) {
			System.assert(!String.isBlank(ex.getText()));
			System.assertEquals(SFDCAccessControlException.ExceptionType.OBJECT_ACCESS_VIOLATION, ex.getExceptionType());
			System.assertEquals(SFDCAccessControlException.ExceptionReason.NO_UPDATE, ex.getExceptionReason());
			System.assertEquals('ApexLog', ex.getExceptionObject());
			System.assertEquals(null, ex.getExceptionField());
		}

		try {
			accessController.assertAuthorizedToCreate(Schema.ApexLog.SobjectType, new List<String>{ 'Status' });
			System.assert(false, 'Should not succeed in saving as ApexLog  is not creatable');
		} catch (SFDCAccessControlException ex) {
			System.assert(!String.isBlank(ex.getText()));
			System.assertEquals(SFDCAccessControlException.ExceptionType.OBJECT_ACCESS_VIOLATION, ex.getExceptionType());
			System.assertEquals(SFDCAccessControlException.ExceptionReason.NO_CREATE, ex.getExceptionReason());
			System.assertEquals('ApexLog', ex.getExceptionObject());
			System.assertEquals(null, ex.getExceptionField());
		}

		try {
			accessController.assertAuthorizedToUpdate(Schema.ApexLog.SobjectType, new List<String>{ 'Status' });
			System.assert(false, 'Should not succeed in saving as ApexLog  is not updateable');
		} catch (SFDCAccessControlException ex) {
			System.assert(!String.isBlank(ex.getText()));
			System.assertEquals(SFDCAccessControlException.ExceptionType.OBJECT_ACCESS_VIOLATION, ex.getExceptionType());
			System.assertEquals(SFDCAccessControlException.ExceptionReason.NO_UPDATE, ex.getExceptionReason());
			System.assertEquals('ApexLog', ex.getExceptionObject());
			System.assertEquals(null, ex.getExceptionField());
		}

		System.assertEquals(false, accessController.isAuthorizedToCreate(Schema.ApexLog.SobjectType, new List<Schema.SObjectField>{ Schema.ApexLog.fields.Status }));

		System.assertEquals(false, accessController.isAuthorizedToCreate(Schema.ApexLog.SobjectType, new List<String>{ 'Status' }));

		System.assertEquals(false, accessController.isAuthorizedToUpdate(Schema.ApexLog.SobjectType, new List<Schema.SObjectField>{ Schema.ApexLog.fields.Status }));

		System.assertEquals(false, accessController.isAuthorizedToUpdate(Schema.ApexLog.SobjectType, new List<String>{ 'Status' }));

		System.assertEquals(Contact.SobjectType.getDescribe().isDeletable(), accessController.isAuthorizedToDelete(Schema.Contact.SobjectType));

		List<Schema.SobjectField> createableFields = accessController.getCreatableFields(c);
		List<Schema.SobjectField> updateableFields = accessController.getUpdateableFields(c);
		List<Schema.SobjectField> viewableFields = accessController.getViewableFields(c);

		System.assertEquals(createableFields, accessController.getCreatableFields(Contact.getSObjectType()));
		System.assertEquals(updateableFields, accessController.getUpdateableFields(Contact.getSObjectType()));
		System.assertEquals(viewableFields, accessController.getViewableFields(Contact.getSObjectType()));

		// will throw exception if in bad state
		accessController.assertAuthorizedToView(Schema.Contact.SobjectType, viewableFields);
		accessController.assertAuthorizedToCreate(Schema.Contact.SobjectType, createableFields);
		accessController.assertAuthorizedToUpdate(Schema.Contact.SobjectType, updateableFields);

		System.assert(accessController.isAuthorizedToView(Schema.Contact.SobjectType, viewableFields), 'should be able to view');
		System.assert(accessController.isAuthorizedToCreate(Schema.Contact.SobjectType, createableFields), 'should be able to view');
		System.assert(accessController.isAuthorizedToUpdate(Schema.Contact.SobjectType, updateableFields), 'should be able to update');

		System.assert(accessController.isAuthorizedToView(Schema.Contact.SobjectType, new List<String>{ 'LastName' }), 'should be able to view');
		System.assert(accessController.isAuthorizedToCreate(Schema.Contact.SobjectType, new List<String>{ 'LastName' }), 'should be able to create');
		System.assert(accessController.isAuthorizedToUpdate(Schema.Contact.SobjectType, new List<String>{ 'LastName' }), 'should be able to update');

		String badFieldName = 'SomeCrazyBadFieldName';
		try {
			System.assert(accessController.isAuthorizedToView(Schema.Contact.SobjectType, new List<String>{ 'LastName', badFieldName }), 'should be able to view');
			System.assert(false, 'Should not come here');
		} catch (SFDCAccessControlException ex) {
			System.assert(!String.isBlank(ex.getText()));
			System.assertEquals(SFDCAccessControlException.ExceptionType.FIELD_NOT_FOUND, ex.getExceptionType());
			System.assertEquals(SFDCAccessControlException.ExceptionReason.GENERIC, ex.getExceptionReason());
			System.assertEquals('Contact', ex.getExceptionObject());
			System.assertEquals(badFieldName, ex.getExceptionField());
		}

		try {
			System.assert(accessController.isAuthorizedToCreate(Schema.Contact.SobjectType, new List<String>{ 'LastName', badFieldName }), 'should be able to view');
			System.assert(false, 'Should not come here');
		} catch (SFDCAccessControlException ex) {
			System.assert(!String.isBlank(ex.getText()));
			System.assertEquals(SFDCAccessControlException.ExceptionType.FIELD_NOT_FOUND, ex.getExceptionType());
			System.assertEquals(SFDCAccessControlException.ExceptionReason.GENERIC, ex.getExceptionReason());
			System.assertEquals('Contact', ex.getExceptionObject());
			System.assertEquals(badFieldName, ex.getExceptionField());
		}

		try {
			System.assert(accessController.isAuthorizedToUpdate(Schema.Contact.SobjectType, new List<String>{ 'LastName', badFieldName }), 'should be able to view');
			System.assert(false, 'Should not come here');
		} catch (SFDCAccessControlException ex) {
			System.assert(!String.isBlank(ex.getText()));
			System.assertEquals(SFDCAccessControlException.ExceptionType.FIELD_NOT_FOUND, ex.getExceptionType());
			System.assertEquals(SFDCAccessControlException.ExceptionReason.GENERIC, ex.getExceptionReason());
			System.assertEquals('Contact', ex.getExceptionObject());
			System.assertEquals(badFieldName, ex.getExceptionField());
		}
	}
	/**/
}