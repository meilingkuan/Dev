@isTest (SeeAllData=true)
private class Hapara_LeadDuplicateChecker_Test {
	static testMethod void leadDuplicateCheckerTest() {
    	List<Lead> leads = [SELECT name FROM Lead where isConverted=false and createdDate> LAST_MONTH  LIMIT 100];
    	
    	ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(leads);
    	Hapara_LeadDuplicateCheckerController controller = new Hapara_LeadDuplicateCheckerController(setCtr);
		System.assert(controller.getRecordSize()>0);
		System.assert(controller.getDeDupLeads().size()>0);
		System.assertEquals('1',controller.getStep());
		System.assert(controller.cancel()!=null);
		controller.processDuplicateCheckLead();
		controller.processDuplicateCheckContact();
		controller.processDuplicateCheckAccount();
		controller.nextPage();
		controller.previousPage();
	}
}