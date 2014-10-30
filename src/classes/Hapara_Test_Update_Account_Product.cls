@isTest(SeeAllData=true)
private class Hapara_Test_Update_Account_Product {

    static testMethod void testUpdate_Account_Product() {
        Hapara_Invoice__c inv = Hapara_XeroHandlerTest.CreateTestInvoice();
        list<Hapara_Invoice_History__c> histories = [select id from Hapara_Invoice_History__c where Hapara_Invoice__c =: inv.id];
        system.assertEquals(histories.size(),1);
        
        list<Product2> pros = [Select r.Xero_Product_Code__c, r.Reseller_Product_Code_del__c, r.Reseller_Account_del__c, 
                            r.Id ,r.Description, r.family,r.Subscription_Period__c,r.Subscription_Type__c
                            From Product2 r where Xero_Product_Code__c != null limit 2];
        Account_Products__c line = new Account_Products__c();
        line.Account__c = inv.Account__c;
        line.Hapara_Invoice__c = inv.Id;
        line.Invoice_Date__c = inv.Invoice_Date__c;
        line.Product__c = pros[0].Id;
        line.Subscription_Start_Date__c  = inv.Invoice_Date__c;
        line.Subscription_End_Date__c = inv.Invoice_Date__c.addDays(30);
        line.Description__c= pros[0].Description;
        line.Unit_Price__c =4.0;
        line.Quantity__c = 1;
        line.Product_Family__c = pros[0].Family;
        line.CurrencyIsoCode = 'USD';
        insert line;
        
        line.Quantity__c = 20;
        update line;
        
        histories = [select id from Hapara_Invoice_History__c where Hapara_Invoice__c =: inv.id];
        system.assertEquals(histories.size(),3);
        
        delete line;
        histories = [select id from Hapara_Invoice_History__c where Hapara_Invoice__c =: inv.id];
        system.assertEquals(histories.size(),4);
         
    }
}