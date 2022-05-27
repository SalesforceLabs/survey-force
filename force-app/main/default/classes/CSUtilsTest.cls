@isTest
private class CSUtilsTest {
	@isTest
	private static void testIsNumeric() {
		System.assertEquals(false, CSUtils.isNumeric(null));
		System.assertEquals(false, CSUtils.isNumeric(''));
		System.assertEquals(true, CSUtils.isNumeric('1'));
		System.assertEquals(true, CSUtils.isNumeric('1.0'));
		System.assertEquals(true, CSUtils.isNumeric('01'));
		System.assertEquals(true, CSUtils.isNumeric('.01'));
		System.assertEquals(false, CSUtils.isNumeric('text'));
	}

	@isTest
	private static void testIsValidId() {
		System.assertEquals(true, CSUtils.isValidId(null));
		System.assertEquals(false, CSUtils.isValidId('1234'));
		System.assertEquals(false, CSUtils.isValidId('1234567890123456'));

		Contact contact = new Contact();
		contact.LastName = 'Test';
		insert contact;

		System.assertEquals(true, CSUtils.isValidId(contact.Id));
	}

	@isTest
	private static void testIsValidEmail() {
		System.assertEquals(true, CSUtils.isValidEmail(null));
		System.assertEquals(true, CSUtils.isValidEmail('test@test.com'));
		System.assertEquals(false, CSUtils.isValidEmail('test'));
		System.assertEquals(false, CSUtils.isValidEmail('test@test'));
		System.assertEquals(false, CSUtils.isValidEmail('@test'));
		System.assertEquals(false, CSUtils.isValidEmail('@test.com'));
	}

	@isTest
	private static void testLeftPad() {
		System.assertEquals(null, CSUtils.leftPad(null, null, null));
		System.assertEquals('1234', CSUtils.leftPad('1234', '0', 4));
		System.assertEquals('0555', CSUtils.leftPad('555', '0', 4));
		System.assertEquals('12345', CSUtils.leftPad('12345', '0', 4));
	}

	@isTest
	private static void testRightPad() {
		System.assertEquals(null, CSUtils.rightPad(null, null, null));
		System.assertEquals('1234', CSUtils.rightPad('1234', '0', 4));
		System.assertEquals('5550', CSUtils.rightPad('555', '0', 4));
		System.assertEquals('12345', CSUtils.rightPad('12345', '0', 4));
	}

	@isTest
	private static void testToCharacterArray() {
		System.assertEquals(null, CSUtils.toCharacterArray(null));

		List<String> characters = CSUtils.toCharacterArray('abc');
		System.assertEquals('a', characters.get(0));
		System.assertEquals('b', characters.get(1));
		System.assertEquals('c', characters.get(2));
	}

	@isTest
	private static void testNullSafeEquals() {
		System.assertEquals(true, CSUtils.nullSafeEquals(null, null));
		System.assertEquals(false, CSUtils.nullSafeEquals(null, 'val'));
		System.assertEquals(false, CSUtils.nullSafeEquals('val', null));
		System.assertEquals(true, CSUtils.nullSafeEquals('val', 'val'));
		System.assertEquals(false, CSUtils.nullSafeEquals('vala', 'valb'));
	}

	@isTest
	private static void testJoin() {
		// Set version.
		System.assertEquals('one', CSUtils.join(new Set<String>{ 'one' }, '|'));
		System.assertEquals('one,three,two', CSUtils.join(new Set<String>{ 'one', 'two', 'three' }, ','));

		// SObject version.
		System.assertEquals('Account1', CSUtils.join(new List<sObject>{ new Account(Name = 'Account1') }, 'Name', '|'));
		System.assertEquals('Account1|Account2', CSUtils.join(new List<sObject>{ new Account(Name = 'Account1'), new Account(Name = 'Account2') }, 'Name', '|'));
	}

	@isTest
	private static void testShuffle() {
		System.assertEquals(null, CSUtils.shuffle(null));
		System.assertNotEquals(null, CSUtils.shuffle(new List<String>{ 'aaa', 'bbb' }));
	}

	@isTest
	private static void testQuote() {
		System.assertEquals('""', CSUtils.quote((String) null));
		System.assertEquals('""', CSUtils.quote(''));
		System.assertEquals('"John Doe"', CSUtils.quote('John Doe'));
		System.assertEquals('"This has ""quotes"" embedded."', CSUtils.quote('This has "quotes" embedded.'));

		List<String> quotedValues = CSUtils.quote(new List<String>{ 'John Doe', 'Jane Doe' });
		System.assertNotEquals(null, quotedValues);
		System.assertEquals('"John Doe"', quotedValues.get(0));
		System.assertEquals('"Jane Doe"', quotedValues.get(1));
		System.assertEquals(null, CSUtils.quote((List<String>) null));
	}

	@isTest
	private static void testSingleQuote() {
		System.assertEquals('\'\'', CSUtils.singleQuote((String) null));
		System.assertEquals('\'\'', CSUtils.singleQuote(''));
		System.assertEquals('\'John Doe\'', CSUtils.singleQuote('John Doe'));
		System.assertEquals('\'This has \\\'quotes\\\' embedded.\'', CSUtils.singleQuote('This has \'quotes\' embedded.'));

		List<String> quotedValues = CSUtils.singleQuote(new List<String>{ 'John Doe', 'Jane Doe' });
		System.assertNotEquals(null, quotedValues);
		System.assertEquals('\'John Doe\'', quotedValues.get(0));
		System.assertEquals('\'Jane Doe\'', quotedValues.get(1));
		System.assertEquals(null, CSUtils.quote((List<String>) null));
	}

	@isTest
	private static void testFormatDate() {
		System.assertEquals(null, CSUtils.formatDate(null, null));

		Date d1 = Date.newInstance(2009, 4, 6);
		System.assertEquals('2009-04-06', CSUtils.formatDate(d1, 'yyyy-MM-dd'));

		Date d2 = Date.newInstance(2009, 10, 22);
		System.assertEquals('2009/10/22', CSUtils.formatDate(d2, 'yyyy/MM/dd'));
	}

	@isTest
	private static void testFormatDateTimeUTC() {
		System.assertEquals(null, CSUtils.formatDateTimeUTC(null));
		System.assertEquals('2010-04-06T00:00:00Z', CSUtils.formatDateTimeUTC(DateTime.newInstanceGmt(2010, 4, 6)));
	}

	@isTest
	private static void testConvertDateTimeToDate() {
		// Test positive scenario.
		DateTime dt = DateTime.newInstance(2009, 4, 6);
		Date d = CSUtils.convertDateTimeToDate(dt);

		System.assertEquals(2009, d.year());
		System.assertEquals(4, d.month());
		System.assertEquals(6, d.day());

		// Test negative scenario.
		dt = null;
		d = CSUtils.convertDateTimeToDate(dt);

		System.assertEquals(null, d);
	}

	@isTest
	private static void testGetRecordTypeId() {
		System.assertEquals(null, CSUtils.getRecordTypeId('Account', 'Test'));
	}

	@isTest
	private static void testGetObjectMetadata() {
		System.assertEquals(null, CSUtils.getObjectMetadata(null));
		System.assert(CSUtils.getObjectMetadata('Account') != null);
	}

	@isTest
	private static void testGetFieldMetadata() {
		System.assert(CSUtils.getFieldMetadata('Account', 'Name') != null);
	}

	@isTest
	private static void testGetPicklistValues() {
		System.assertNotEquals(null, CSUtils.getPicklistValues('Account', 'Industry', true));
	}

	@isTest
	private static void testGetPicklistDefaultValue() {
		CSUtils.getPicklistDefaultValue('Account', 'Industry');
	}

	@isTest
	private static void testGetPicklistAsSelectOptions() {
		System.assertNotEquals(null, CSUtils.getPicklistAsSelectOptions('Account', 'Industry', true));
	}

	@isTest
	private static void testGetTextFieldLength() {
		System.assert(CSUtils.getTextFieldLength('Account', 'Name') != 0);
	}

	@isTest
	private static void testGetObjectNameFromId() {
		System.assertEquals(null, CSUtils.getObjectNameFromId(null));

		try {
			Account acct = new Account();
			acct.Name = 'Test';
			insert acct;
			System.assertEquals('Account', CSUtils.getObjectNameFromId(acct.Id));
		} catch (Exception e) {
			// Org has custom validation(s) preventing the record from
			// inserting and thus this test from running. Ignore exception.
		}

		try {
			Contact con = new Contact();
			con.FirstName = 'Test';
			con.LastName = 'Test';
			insert con;
			System.assertEquals('Contact', CSUtils.getObjectNameFromId(con.Id));
		} catch (Exception e) {
			// Org has custom validation(s) preventing the record from
			// inserting and thus this test from running. Ignore exception.
		}

		try {
			Opportunity opp = new Opportunity();
			opp.Name = 'Test';
			opp.StageName = 'Prospecting';
			opp.CloseDate = Date.today();
			insert opp;
			System.assertEquals('Opportunity', CSUtils.getObjectNameFromId(opp.Id));
		} catch (Exception e) {
			// Org has custom validation(s) preventing the record from
			// inserting and thus this test from running. Ignore exception.
		}

		try {
			Lead ld = new Lead();
			ld.LastName = 'Test';
			ld.Company = 'Test';
			insert ld;
			System.assertEquals('Lead', CSUtils.getObjectNameFromId(ld.Id));
		} catch (Exception e) {
			// Org has custom validation(s) preventing the record from
			// inserting and thus this test from running. Ignore exception.
		}
	}

	@isTest
	private static void testFifteenCharacterId() {
		System.assertEquals(null, CSUtils.fifteenCharacterId(null));
		System.assertEquals('01234', CSUtils.fifteenCharacterId('01234')); // 5 characters
		System.assertEquals('012345678901234', CSUtils.fifteenCharacterId('012345678901234')); // 15 characters
		System.assertEquals('012345678901234', CSUtils.fifteenCharacterId('012345678901234567')); // 18 characters
	}

	@isTest
	private static void testFieldValuesDifferent() {
		// Test String field.
		Contact contactA = new Contact();
		contactA.FirstName = 'Test';

		Contact contactB = new Contact();
		contactB.FirstName = 'Test';

		System.assertEquals(false, CSUtils.fieldValuesDifferent(contactA, contactB, new Set<String>{ 'FirstName' }));

		contactB.FirstName = 'Test 2';

		System.assertEquals(true, CSUtils.fieldValuesDifferent(contactA, contactB, new Set<String>{ 'FirstName' }));

		// Test Boolean field.
		contactA = new Contact();
		contactA.DoNotCall = false;

		contactB = new Contact();
		contactB.DoNotCall = false;

		System.assertEquals(false, CSUtils.fieldValuesDifferent(contactA, contactB, new Set<String>{ 'DoNotCall' }));

		contactB.DoNotCall = true;

		System.assertEquals(true, CSUtils.fieldValuesDifferent(contactA, contactB, new Set<String>{ 'DoNotCall' }));
	}

	@isTest
	private static void testSendEmail() {
		CSUtils.sendEmail(new List<String>{ 'test@test.com' }, 'test', 'test message');
	}
}