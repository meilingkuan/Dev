@isTest(SeeAllData=true)
public with sharing class NewOpportunityExtension {

    public NewOpportunityExtension(ApexPages.StandardController controller) {}
    
    public PageReference onload() {   	
        PageReference redirect = new PageReference('/006/e');
        redirect.getParameters().put('nooverride', '1');
        redirect.getParameters().put('opp3', '-- Not Required --');
       	redirect.getParameters().put('RecordType',  ApexPages.currentPage().getParameters().get('RecordType'));
        if (ApexPages.currentPage().getParameters().containsKey('retUrl')) {
            redirect.getParameters().put('retUrl', ApexPages.currentPage().getParameters().get('retUrl'));
        }
        if (ApexPages.currentPage().getParameters().containsKey('accid')) {
        	string accid = ApexPages.currentPage().getParameters().get('accid');
            redirect.getParameters().put('accid', accid);
            Account acc = [Select a.Reseller_Tier__r.Name,a.Reseller_Tier__r.Combination_Tier__c, a.Reseller_Tier__c, a.CurrencyIsoCode,
            a.Invoice_Contact__c,a.Invoice_Contact__r.name
            From Account a where a.Id = :accid ];
            redirect.getParameters().put('opp16', acc.CurrencyIsoCode);
             redirect.getParameters().put('CF00N90000007rmcf_lkid', acc.Invoice_Contact__c);
		     redirect.getParameters().put('CF00N90000007rmcf', acc.Invoice_Contact__r.name);
            if(acc.Reseller_Tier__c != null){
            	boolean combination=acc.Reseller_Tier__r.Combination_Tier__c;
            	if(!combination){
		            redirect.getParameters().put('CF00N90000007Il3f_lkid', acc.Reseller_Tier__c);
		            redirect.getParameters().put('CF00N90000007Il3f', acc.Reseller_Tier__r.Name);
            	}
            }
        }
        
        return redirect;
    }

    private static testmethod void selfTest() {
        // Set the test page
        Account acc = new Account();
		acc.Name = 'Account';
		acc.Type = 'Customer';
		acc.BillingStreet = 'test street';
		acc.BillingCity = 'test city';
		acc.BillingState = '';
		acc.BillingPostalCode = 'test zip code';
		acc.BillingCountry = 'New Zealand';		
		 
		insert acc;
        PageReference page = new PageReference('/apex/NewOpportunityButtonOverride?retUrl=006&accId=' + acc.Id);
        Test.setCurrentPage(page);
        ApexPages.StandardController controller = new ApexPages.StandardController(new Opportunity());
        NewOpportunityExtension extension = new NewOpportunityExtension(controller);
        PageReference redirect = extension.onload();
        System.assertNotEquals(null, redirect, 'Expected to be redirected');
    }
}