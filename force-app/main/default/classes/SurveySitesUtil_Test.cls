@IsTest
public without sharing class SurveySitesUtil_Test {
    	static testmethod void testSurveySiteInfo() {
		SurveySitesUtil.SurveySiteInfo info = new SurveySitesUtil.SurveySiteInfo('one', 'two', 'three');
		System.assertEquals(info.name, 'one');
		System.assertEquals(info.prefix, 'two');
		System.assertEquals(info.subdomain, 'three');
	}

	static testmethod void testHasSites() {
		SurveySitesUtil ssutil = new SurveySitesUtil();

		if (Schema.getGlobalDescribe().keySet().contains('site')) {
			System.assert(ssutil.hasSites());
		} else {
			System.assert(!ssutil.hasSites());
		}
	}

	static testmethod void testGetInfo() {
		SurveySitesUtil ssutil = new SurveySitesUtil();
		System.assert(ssutil.getSiteList() != null);
		if (ssutil.hasSites()) {
			if (ssutil.getSiteList().size() > 0) {
				SurveySitesUtil.SurveySiteInfo current = ssutil.getSiteList()[0];
				System.assert(current != null);
			}
		}
	}
}