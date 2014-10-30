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
@isTest(SeeAllData=true)
private class  Hapara_Test_Update_Opportunity {
	static RecordType resellerType ;
	static Lead resellerLead ;
	static Reseller_Tier__c t;
	static Account repAccount;
	static Contact rep ;
	static Account customerAccount;
	static List <Campaign> campaign ;
	static testMethod void createTestOpportunityRecords(){
		resellerType = [SELECT Id FROM RecordType where DeveloperName = 'Reseller_Opportunity'];
		
		resellerLead = new Lead();
    	resellerLead.FirstName = 'Test';
		resellerLead.LastName = 'Last';
		resellerLead.Email = 'test@gmail.com';
		resellerLead.Title = 'job';
		resellerLead.Company =  'company';
		resellerLead.State = 'state';
		resellerLead.Country =  'United States';
		resellerLead.Website = 'domain';
		insert resellerLead;
		
		t = [Select r.Id, r.Combination_Tier__c From Reseller_Tier__c r limit 1];
		
		repAccount = new Account();
		repAccount.Name = 'Rep Account';
		repAccount.Type = 'Reseller';
		repAccount.Reseller_s_Email_Domain__c = 'gmail.com';
		repAccount.Reseller_Tier__c = t.Id;
        repAccount.BillingCountry = 'United States';
		insert repAccount;
		 
		rep = new Contact();
		rep.FirstName = 'Rep';
		rep.LastName = 'Last';
		rep.AccountId = repAccount.Id;
		insert rep;
		
		customerAccount = new Account();
		customerAccount.Name = 'Customer of Reseller';
		customerAccount.Type = 'Customer of Reseller';
        customerAccount.BillingCountry = 'United States';
		insert customerAccount;
		
		campaign = [select id, name from Campaign where name = 'Reseller/ Referral' limit 1];
	}
	static testMethod void testOpportunityInsert() {
		createTestOpportunityRecords();
		system.debug('***testOpportunityInsert start');
	 	/*** test insert and process fee creation**/
		Opportunity opportunity3 = new Opportunity();
        opportunity3.StageName= 'Prospecting';
        string opportunityName = 'CDW - test - Teacher Dashboard';
        opportunity3.Opportunity_Name_Template__c = 'Teacher Dashboard';
		opportunity3.Name =opportunityName;
		opportunity3.CloseDate= Date.Today().addDays(90);
		opportunity3.Probability=0;		
		opportunity3.CampaignId=campaign[0].Id;
		opportunity3.LeadSource= 'Reseller Deal Registration';		
		opportunity3.Reseller_s_Rep__c = rep.Id;	
		opportunity3.CurrencyIsoCode= repAccount.CurrencyIsoCode;
		opportunity3.AccountId= customerAccount.Id;
		opportunity3.RecordTypeId = HAPARA_CONST.SETTING_OPPORTUNITY_CONFIG.Record_Type_Standard__c;
	    insert opportunity3;
	  //  list<OpportunityLineItem> line = [select Id from OpportunityLineItem where OpportunityId =: opportunity3.Id];
		//system.assertEquals(line.size(),1);
	}
	
	static testMethod void testOpportunityLeadLinkedUpdate() {
		createTestOpportunityRecords();
		system.debug('***testOpportunityLeadLinkedUpdate start');
		/*** test lead link only***/
		Opportunity opportunity = new Opportunity();
        opportunity.StageName= 'New Registration';
        String opportunityName = 'CDW - test - Teacher Dashboard';
        opportunity.Opportunity_Name_Template__c = 'Teacher Dashboard';
		opportunity.Name =opportunityName;
		opportunity.CloseDate= Date.Today().addDays(90);
		opportunity.Probability=0;		
		opportunity.CampaignId=campaign[0].Id;
		opportunity.LeadSource= 'Reseller Deal Registration';		
		opportunity.Reseller_s_Rep__c = rep.Id;	
		opportunity.CurrencyIsoCode= repAccount.CurrencyIsoCode;
		opportunity.Resellers_Lead__c = resellerLead.Id;
		opportunity.AccountId= repAccount.Id;
		opportunity.RecordTypeId = resellerType.Id;
	    insert opportunity;
		System.assertEquals( opportunity.Resellers_Account__c,null );
		//system.test.startTest();
		
		opportunity.StageName= HAPARA_CONST.OPPORTUNITY_STAGE_APROVEREGISTRATION;
		update opportunity;
		//system.Test.stopTest();
		
    }
    
    static testMethod void testOpportunityAccountLinkedUpdate() {
		createTestOpportunityRecords();
		system.debug('***testOpportunityAccountLinkedUpdate start');
   	    /*** test account link only**/
	    Opportunity opportunity2 = new Opportunity();
        opportunity2.StageName= 'New Registration';
        string opportunityName = 'CDW - ' + customerAccount.Name  +' - Teacher Dashboard';
        opportunity2.Opportunity_Name_Template__c = 'Teacher Dashboard';
		opportunity2.Name =opportunityName;
		opportunity2.CloseDate= Date.Today().addDays(90);
		opportunity2.Probability=0;		
		opportunity2.CampaignId=campaign[0].Id;
		opportunity2.LeadSource= 'Reseller Deal Registration';		
		opportunity2.Reseller_s_Rep__c = rep.Id;	
		opportunity2.CurrencyIsoCode= repAccount.CurrencyIsoCode;
		opportunity2.Resellers_Account__c = customerAccount.Id;
		opportunity2.AccountId= repAccount.Id;
	    insert opportunity2;
	    

		
		opportunity2.RecordTypeId = resellerType.Id;
		opportunity2.StageName= HAPARA_CONST.OPPORTUNITY_STAGE_APROVEREGISTRATION;
		update opportunity2;
		System.assertEquals( opportunity2.Resellers_Lead__c,null );
		
		opportunity2.StageName= HAPARA_CONST.OPPORTUNITY_STAGE_DECLINEDREGISTRATION;
		update opportunity2;
		System.assertEquals( opportunity2.Resellers_Lead__c,null );
    }
	
}