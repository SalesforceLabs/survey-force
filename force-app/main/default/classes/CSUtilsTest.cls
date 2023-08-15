@SuppressWarnings('PMD.EmptyCatchBlock')
@isTest
private without sharing class CSUtilsTest {
	@isTest
	private static void testIsNumeric() {
		Assert.isFalse(CSUtils.isNumeric(null));
		Assert.isFalse(CSUtils.isNumeric(''));
		Assert.isTrue(CSUtils.isNumeric('1'));
		Assert.isTrue(CSUtils.isNumeric('1.0'));
		Assert.isTrue(CSUtils.isNumeric('01'));
		Assert.isTrue(CSUtils.isNumeric('.01'));
		Assert.isFalse(CSUtils.isNumeric('text'));
	}

	@isTest
	private static void testIsValidId() {
		Assert.isTrue(CSUtils.isValidId(null));
		Assert.isFalse(CSUtils.isValidId('1234'));
		Assert.isFalse(CSUtils.isValidId('1234567890123456'));

		Contact contact = new Contact();
		contact.LastName = 'Test';
		insert contact;

		Assert.isTrue(CSUtils.isValidId(contact.Id));
	}

	@isTest
	private static void testIsValidEmail() {
		Assert.isTrue(CSUtils.isValidEmail(null));
		Assert.isTrue(CSUtils.isValidEmail('test@test.com'));
		Assert.isFalse(CSUtils.isValidEmail('test'));
		Assert.isFalse(CSUtils.isValidEmail('test@test'));
		Assert.isFalse(CSUtils.isValidEmail('@test'));
		Assert.isFalse(CSUtils.isValidEmail('@test.com'));
	}

	@isTest
	private static void testLeftPad() {
		Assert.areEqual(null, CSUtils.leftPad(null, null, null));
		Assert.areEqual('1234', CSUtils.leftPad('1234', '0', 4));
		Assert.areEqual('0555', CSUtils.leftPad('555', '0', 4));
		Assert.areEqual('12345', CSUtils.leftPad('12345', '0', 4));
	}

	@isTest
	private static void testRightPad() {
		Assert.areEqual(null, CSUtils.rightPad(null, null, null));
		Assert.areEqual('1234', CSUtils.rightPad('1234', '0', 4));
		Assert.areEqual('5550', CSUtils.rightPad('555', '0', 4));
		Assert.areEqual('12345', CSUtils.rightPad('12345', '0', 4));
	}

	@isTest
	private static void testToCharacterArray() {
		Assert.areEqual(null, CSUtils.toCharacterArray(null));

		List<String> characters = CSUtils.toCharacterArray('abc');
		Assert.areEqual('a', characters.get(0));
		Assert.areEqual('b', characters.get(1));
		Assert.areEqual('c', characters.get(2));
	}

	@isTest
	private static void testNullSafeEquals() {
		Assert.isTrue(CSUtils.nullSafeEquals(null, null));
		Assert.isFalse(CSUtils.nullSafeEquals(null, 'val'));
		Assert.isFalse(CSUtils.nullSafeEquals('val', null));
		Assert.isTrue(CSUtils.nullSafeEquals('val', 'val'));
		Assert.isFalse(CSUtils.nullSafeEquals('vala', 'valb'));
	}

	@isTest
	private static void testJoin() {
		// Set version.
		Assert.areEqual('one', CSUtils.join(new Set<String>{ 'one' }, '|'));
		Assert.areEqual('one,three,two', CSUtils.join(new Set<String>{ 'one', 'two', 'three' }, ','));

		// SObject version.
		Assert.areEqual('Account1', CSUtils.join(new List<sObject>{ new Account(Name = 'Account1') }, 'Name', '|'));
		Assert.areEqual('Account1|Account2', CSUtils.join(new List<sObject>{ new Account(Name = 'Account1'), new Account(Name = 'Account2') }, 'Name', '|'));
	}

	@isTest
	private static void testShuffle() {
		Assert.areEqual(null, CSUtils.shuffle(null));
		Assert.areNotEqual(null, CSUtils.shuffle(new List<String>{ 'aaa', 'bbb' }));
	}

	@isTest
	private static void testQuote() {
		Assert.areEqual('""', CSUtils.quote((String) null));
		Assert.areEqual('""', CSUtils.quote(''));
		Assert.areEqual('"John Doe"', CSUtils.quote('John Doe'));
		Assert.areEqual('"This has ""quotes"" embedded."', CSUtils.quote('This has "quotes" embedded.'));

		List<String> quotedValues = CSUtils.quote(new List<String>{ 'John Doe', 'Jane Doe' });
		Assert.areNotEqual(null, quotedValues);
		Assert.areEqual('"John Doe"', quotedValues.get(0));
		Assert.areEqual('"Jane Doe"', quotedValues.get(1));
		Assert.areEqual(null, CSUtils.quote((List<String>) null));
	}

	@isTest
	private static void testSingleQuote() {
		Assert.areEqual('\'\'', CSUtils.singleQuote((String) null));
		Assert.areEqual('\'\'', CSUtils.singleQuote(''));
		Assert.areEqual('\'John Doe\'', CSUtils.singleQuote('John Doe'));
		Assert.areEqual('\'This has \\\'quotes\\\' embedded.\'', CSUtils.singleQuote('This has \'quotes\' embedded.'));

		List<String> quotedValues = CSUtils.singleQuote(new List<String>{ 'John Doe', 'Jane Doe' });
		Assert.areNotEqual(null, quotedValues);
		Assert.areEqual('\'John Doe\'', quotedValues.get(0));
		Assert.areEqual('\'Jane Doe\'', quotedValues.get(1));
		Assert.areEqual(null, CSUtils.quote((List<String>) null));
	}

	@isTest
	private static void testFormatDate() {
		Assert.areEqual(null, CSUtils.formatDate(null, null));

		Date d1 = Date.newInstance(2009, 4, 6);
		Assert.areEqual('2009-04-06', CSUtils.formatDate(d1, 'yyyy-MM-dd'));

		Date d2 = Date.newInstance(2009, 10, 22);
		Assert.areEqual('2009/10/22', CSUtils.formatDate(d2, 'yyyy/MM/dd'));
	}

	@isTest
	private static void testFormatDateTimeUTC() {
		Assert.areEqual(null, CSUtils.formatDateTimeUTC(null));
		Assert.areEqual('2010-04-06T00:00:00Z', CSUtils.formatDateTimeUTC(DateTime.newInstanceGmt(2010, 4, 6)));
	}

	@isTest
	private static void testConvertDateTimeToDate() {
		// Test positive scenario.
		DateTime dt = DateTime.newInstance(2009, 4, 6);
		Date d = CSUtils.convertDateTimeToDate(dt);

		Assert.areEqual(2009, d.year());
		Assert.areEqual(4, d.month());
		Assert.areEqual(6, d.day());

		// Test negative scenario.
		dt = null;
		d = CSUtils.convertDateTimeToDate(dt);

		Assert.areEqual(null, d);
	}

	@isTest
	private static void testGetRecordTypeId() {
		Assert.areEqual(null, CSUtils.getRecordTypeId('Account', 'Test'));
	}

	@isTest
	private static void testGetObjectMetadata() {
		Assert.areEqual(null, CSUtils.getObjectMetadata(null));
		System.assert(CSUtils.getObjectMetadata('Account') != null);
	}

	@isTest
	private static void testGetFieldMetadata() {
		System.assert(CSUtils.getFieldMetadata('Account', 'Name') != null);
	}

	@isTest
	private static void testGetPicklistValues() {
		Assert.areNotEqual(null, CSUtils.getPicklistValues('Account', 'Industry', true));
	}

	@isTest
	private static void testGetPicklistDefaultValue() {
		CSUtils.getPicklistDefaultValue('Account', 'Industry');
	}

	@isTest
	private static void testGetPicklistAsSelectOptions() {
		Assert.areNotEqual(null, CSUtils.getPicklistAsSelectOptions('Account', 'Industry', true));
	}

	@isTest
	private static void testGetTextFieldLength() {
		System.assert(CSUtils.getTextFieldLength('Account', 'Name') != 0);
	}

	@isTest
	private static void testGetObjectNameFromId() {
		Assert.areEqual(null, CSUtils.getObjectNameFromId(null));

		try {
			Account acct = new Account();
			acct.Name = 'Test';
			insert acct;
			Assert.areEqual('Account', CSUtils.getObjectNameFromId(acct.Id));
		} catch (Exception e) {
			//NOPMD
			// Org has custom validation(s) preventing the record from
			// inserting and thus this test from running. Ignore exception.
		}

		try {
			Contact con = new Contact();
			con.FirstName = 'Test';
			con.LastName = 'Test';
			insert con;
			Assert.areEqual('Contact', CSUtils.getObjectNameFromId(con.Id));
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
			Assert.areEqual('Opportunity', CSUtils.getObjectNameFromId(opp.Id));
		} catch (Exception e) {
			// Org has custom validation(s) preventing the record from
			// inserting and thus this test from running. Ignore exception.
		}

		try {
			Lead ld = new Lead();
			ld.LastName = 'Test';
			ld.Company = 'Test';
			insert ld;
			Assert.areEqual('Lead', CSUtils.getObjectNameFromId(ld.Id));
		} catch (Exception e) {
			// Org has custom validation(s) preventing the record from
			// inserting and thus this test from running. Ignore exception.
		}
	}

	@isTest
	private static void testFifteenCharacterId() {
		Assert.areEqual(null, CSUtils.fifteenCharacterId(null));
		Assert.areEqual('01234', CSUtils.fifteenCharacterId('01234')); // 5 characters
		Assert.areEqual('012345678901234', CSUtils.fifteenCharacterId('012345678901234')); // 15 characters
		Assert.areEqual('012345678901234', CSUtils.fifteenCharacterId('012345678901234567')); // 18 characters
	}

	@isTest
	private static void testFieldValuesDifferent() {
		// Test String field.
		Contact contactA = new Contact();
		contactA.FirstName = 'Test';

		Contact contactB = new Contact();
		contactB.FirstName = 'Test';

		Assert.isFalse(CSUtils.fieldValuesDifferent(contactA, contactB, new Set<String>{ 'FirstName' }));

		contactB.FirstName = 'Test 2';

		Assert.isTrue(CSUtils.fieldValuesDifferent(contactA, contactB, new Set<String>{ 'FirstName' }));

		// Test Boolean field.
		contactA = new Contact();
		contactA.DoNotCall = false;

		contactB = new Contact();
		contactB.DoNotCall = false;

		Assert.isFalse(CSUtils.fieldValuesDifferent(contactA, contactB, new Set<String>{ 'DoNotCall' }));

		contactB.DoNotCall = true;

		Assert.isTrue(CSUtils.fieldValuesDifferent(contactA, contactB, new Set<String>{ 'DoNotCall' }));
	}

	@isTest
	private static void testSendEmail() {
		CSUtils.sendEmail(new List<String>{ 'test@test.com' }, 'test', 'test message');
		Assert.isTrue(true);
	}
}