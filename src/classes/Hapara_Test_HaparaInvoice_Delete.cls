@isTest(SeeAllData=true)
public with sharing class Hapara_Test_HaparaInvoice_Delete {
	static testMethod void testHaparaInvoiceDelete(){
		Hapara_Invoice__c inv = Hapara_XeroHandlerTest.CreateTestInvoice();
		try{
			delete inv;
		}catch(Exception e){}
		
		system.assertEquals(inv.isDeleted, false);
		Hapara_Invoice__c inv2 = Hapara_XeroHandlerTest.CreateTestInvoice();
		Id invId2 = inv2.Id;
		inv2.Xero_Invoice_No__c = null;
		update inv2;
		delete inv2 ;

		list<Hapara_Invoice__c> invs = [select Id from Hapara_Invoice__c where id=:invId2];
		system.assertEquals(invs.size(), 0);
		
	}
}