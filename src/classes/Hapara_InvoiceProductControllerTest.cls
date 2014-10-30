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
private class Hapara_InvoiceProductControllerTest {

   
    static testMethod void testInvoiceProductController() {
    	Hapara_Invoice__c obj = [Select h.Invoice_To_Contact__c, h.Xero_Invoice_No__c, h.SystemModstamp, h.Status__c, h.Reseller_PO__c, h.Reseller_PO_Received_Date__c, 
			h.Reseller_Account__c, h.Process__c, h.Paid_Date__c, h.OwnerId, h.Name, h.LastModifiedDate, h.LastModifiedById, h.IsDeleted, 
			h.Invoice_Date__c, h.Id, h.HTTP_Response__c, h.Error_Message__c, h.Due_Date__c, h.Customer_PO__c, h.Customer_PO_Received_Date__c, 
			h.CurrencyIsoCode, h.CreatedDate, h.CreatedById, h.Case_Subject__c, h.Xero_Id__c,
			h.Account__r.Invoice_Contact__c, h.Account__r.CurrencyIsoCode, h.Account__r.Website, h.Account__r.BillingCountry, 
			h.Account__r.BillingPostalCode, h.Account__r.BillingState, h.Account__r.BillingCity, h.Account__r.BillingStreet, 
			h.Account__r.Name, h.Account__c, h.Account__r.Xero_Id__c
			From Hapara_Invoice__c h where h.Account__r.Invoice_Contact__c != null limit 1];
			system.debug('***testInvoiceProductController - invoiceid=' +obj.id + ' currency='+obj.CurrencyIsoCode);
			
			Product2 prod = [Select p.Subscription_Type__c, p.Name, p.Description
 						From Product2 p where p.ProductCode ='TD' limit 1];
 			PricebookEntry price = [Select Id, Name, Pricebook2Id, Product2Id, CurrencyIsoCode, UnitPrice, IsActive, 
 						UseStandardPrice, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, 
 						ProductCode, IsDeleted From PricebookEntry where IsActive = true 
 						and CurrencyIsoCode =:obj.CurrencyIsoCode and Product2Id =:prod.Id limit 1 ] ;
			system.debug('***testInvoiceProductController - price=' +price.id + ' prod='+prod.Id);
			
			PageReference page = new PageReference('/apex/Hapara_InvoiceProductSelector');
			page.getParameters().put('Id', obj.Id);
    		Test.setCurrentPage(page);
    		ApexPages.StandardController controller = new ApexPages.StandardController(obj);
    		Hapara_InvoiceProductController contr = new Hapara_InvoiceProductController(controller);
    		Account_Products__c pro =  contr.getAccountProduct();
    		System.assert(pro != null);
 			pro.Product__c = prod.Id;
    		//pro.Pricebook_Entry__c = price.Id;
    		system.assert(contr.Process().getUrl().contains('/Hapara_InvoiceProductSelector'));
    		system.assert(contr.CreateAccountProduct().getUrl()!=null);
    		system.assert(contr.cancel() != null);
    		system.assert(contr.getStep()!=null);
    		HaparaResellerUtilityCommon_Test.CreateTestResellerRecords();
    		Opportunity opp = HaparaResellerUtilityCommon_Test.opptest;
    		
    		
    		PageReference page2 = new PageReference('/apex/Hapara_OpportunityProductSelector');
			page2.getParameters().put('Id', opp.Id);
    		Test.setCurrentPage(page2);
    		ApexPages.StandardController controller2 = new ApexPages.StandardController(opp);
    		Hapara_InvoiceProductController contr2 = new Hapara_InvoiceProductController(controller2);
    		Account_Products__c pro2 =  contr2.getAccountProduct();
    		pro2.Product__c = prod.Id;
    	//	pro2.Pricebook_Entry__c = price.Id;
    		system.assert(contr2.Process().getUrl().contains('/Hapara_OpportunityProductSelector'));
    		system.assert(contr2.CreateAccountProduct().getUrl()!=null);
    		
    		Quote q = new Quote();
    		q.OpportunityId = opp.Id;
    		q.ExpirationDate = Date.today().addDays(30);
    		q.BillingStreet='test';
    		q.BillingCity = 'cit';
    		q.BillingCountry='United States';
    		q.ContactId = obj.Invoice_To_Contact__c;
    		q.Name = 'test';
    		q.Pricebook2Id = price.Pricebook2Id;
    		insert q;
    		PageReference page3 = new PageReference('/apex/Hapara_QuoteProductSelector');
			page3.getParameters().put('Id', q.Id);
    		Test.setCurrentPage(page3);
    		ApexPages.StandardController controller3 = new ApexPages.StandardController(q);
    		Hapara_InvoiceProductController contr3 = new Hapara_InvoiceProductController(controller3);
    		Account_Products__c pro3 =  contr3.getAccountProduct();
    		pro3.Product__c = prod.Id;
    		//pro3.Pricebook_Entry__c = price.Id;
    		system.assert(contr3.Process().getUrl().contains('/Hapara_QuoteProductSelector'));
    		system.assert(contr3.CreateAccountProduct().getUrl()!=null);
    		
     }
}