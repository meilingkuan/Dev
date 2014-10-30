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
private class Hapara_Test_Quote_Update {
	static Account acc;
	static Contact c;
	static Opportunity opp;

    static testMethod void testQuoteAfterUpdate() {
    	testCreateQuoteRecords();
       	Quote q = new Quote();
       	q.OpportunityId = opp.Id;
       	q.Name = opp.Name;
		q.ContactId = c.Id;
		q.BillingCountry = 'United States';
		q.BillingStreet = 'test';
		q.BillingCity='city';
		q.BillingState = 'California';
		q.BillingPostalCode = 'pc';
		insert q;
		
		opp = [Select o.Account.Invoice_Contact__c, o.Account.BillingCountry, o.Account.BillingPostalCode,
	 			 o.Account.BillingState, o.Account.BillingCity, o.Account.BillingStreet, 
	 			 o.AccountId ,o.Primary_Contact__c
	 			 From Opportunity o where o.Id = :q.OpportunityId limit 1];
	 	acc = opp.account;
		
		system.assertEquals(q.contactId, acc.Invoice_Contact__c);
		system.assertEquals(q.BillingCountry,acc.BillingCountry);
		system.assertEquals(q.BillingStreet ,acc.BillingStreet);
		system.assertEquals(q.BillingCity,acc.BillingCity);
		system.assertEquals(q.BillingState,acc.BillingState);
		system.assertEquals(q.BillingPostalCode ,acc.BillingPostalCode);
		system.assertEquals(q.ContactId ,opp.Primary_Contact__c);
    }
    
    static testMethod void testCreateQuoteRecords() {
        acc = new Account();
		acc.Name = 'Account';
		acc.Type = 'Prospect';
		acc.CurrencyIsoCode = 'USD';
		
		insert acc;
		
		c = new Contact();
		c.FirstName = 'test';
		c.LastName = 'testLate';
		c.AccountId = acc.Id ;
		c.Email = 'test@gmail.com';
		insert c;
		
		opp = new Opportunity();
       	opp.AccountId= acc.Id;
       	opp.Primary_Contact__c = acc.Invoice_Contact__c;
       	opp.StageName ='Prospecting';
       	opp.CloseDate = Date.today();
       	opp.Opportunity_Name_Template__c = 'Getting STarted';
       	opp.Name='test';
       	insert opp;
		
    	
    }
    
   
}