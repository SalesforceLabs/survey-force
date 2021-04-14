public with sharing class SurveySitesUtil {



	public Boolean hasSites() {
		return Schema.getGlobalDescribe().keySet().contains('site');
	}

	public List<SurveySiteInfo> getSiteList() {

		List<SurveySiteInfo> ret = new List<SurveySiteInfo>();

		if (!hasSites()) {
			return ret;
		}

		List<Sobject> sitesResults = Database.query('SELECT Name, Subdomain, UrlPathPrefix FROM Site WHERE SiteType = \'Visualforce\' AND Status = \'Active\'');

		for (Sobject current : sitesResults) {
			ret.add(new SurveySiteInfo((String)current.get('Name'), (String)current.get('UrlPathPrefix'), (String)current.get('Subdomain')));
		}

		return ret;

	}

	public class SurveySiteInfo {
		public String name { get; set; }
		public String prefix { get; set; }
		public String subdomain {get; set; }

		public SurveySiteInfo(String name, String prefix, String subdomain) {
			this.name = name;
			this.prefix = prefix;
			this.subdomain = subdomain;
		}
	}

}