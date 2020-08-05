@IsTest
public without sharing class SurveySitesUtil_Test {
    	static testmethod void testSurveySiteInfo() {
		SurveySitesUtil.SurveySiteInfo info = new SurveySitesUtil.SurveySiteInfo('one', 'two', 'three');
		System.assertEquals(info.name, 'one');
		System.assertEquals(info.prefix, 'two');
		System.assertEquals(info.subdomain, 'three');
	}

	static testmethod void testHasSites() {
		SurveySitesUtil SurveyForceUtil = new SurveySitesUtil();

		if (Schema.getGlobalDescribe().keySet().contains('site')) {
			System.assert(SurveyForceUtil.hasSites());
		} else {
			System.assert(!SurveyForceUtil.hasSites());
		}
	}

	static testmethod void testGetInfo() {
		SurveySitesUtil SurveyForceUtil = new SurveySitesUtil();
		System.assert(SurveyForceUtil.getSiteList() != null);
		if (SurveyForceUtil.hasSites()) {
			if (SurveyForceUtil.getSiteList().size() > 0) {
				SurveySitesUtil.SurveySiteInfo current = SurveyForceUtil.getSiteList()[0];
				System.assert(current != null);
			}
		}
	}
}