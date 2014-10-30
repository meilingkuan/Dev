@isTest(SeeAllData=true)
public class Hapara_OppportunityCreateRenewal_Test {
	public static Account reseller;
	public static Contact resellerRep;
	public static Account acc;
	public static Contact con;
	public static Reseller_Tier__c tier;
	public static Product2 prod;
	public static list<PricebookEntry> prices;
	public static Account acc2;
	
	static testMethod void testCreateRenewalOpportunity(){
		testCreateOpportunityRenewalRecords();
		//test no renewal
		Hapara_OppportunityCreateRenewal create = new Hapara_OppportunityCreateRenewal();
		create.createRenewalOpportunityTest30();
		//test existing renewal
		TD_Domain__c td1 = new TD_Domain__c();
		td1.SIS_Enabled__c = 'true';
		td1.RC_Enabled__c='true';
		td1.Number_Students__c='150';
		td1.Created_By__c = 'test';
		td1.Account__c  = acc.Id;
		insert td1;
		acc.No_Students_Sign_Up__c = 150;
		update acc;
		create.createRenewalOpportunityTest30();
	}
	
	static testMethod void testCreateOpportunityRenewalRecords() {
		//account
		acc = new Account();
        acc.Name = 'test Company';
        acc.BillingCity = 'test street';
        acc.BillingCountry = 'United States';
        acc.BillingState = 'Washington';
        acc.CurrencyIsoCode='USD';
        acc.Type = 'Customer Direct';
       
        
        con = new Contact();
        con.FirstName= 'f';
        con.LastName = 'l';
        con.Email = 'mkua001@gmail.com';
        insert con;
        acc.Invoice_Contact__c = con.Id;
        insert acc;
        
        
        //reseller
        tier = new Reseller_Tier__c ();
		tier.Name = 'tier 1';
		tier.Description__c = 'tier 1';
		tier.IsActive__c = true;
		tier.Product_Code_Pre_Fix__c = 'RS20';
		insert tier;
		
		reseller = new Account();
	 	reseller.Name = 'Test Reseller';
	 	reseller.Type = 'Reseller';
	 	reseller.Reseller_s_Email_Domain__c ='test.com';
	 	reseller.Reseller_Tier__c =tier.Id;
	 	reseller.CurrencyIsoCode = 'USD';
	 	reseller.Can_Submit_Purchase_Order__c = true;
	 	reseller.BillingCountry = 'United States';
	 	reseller.Invoice_Contact__c = con.Id;
	 	insert reseller;
	 	
	 	resellerRep = new Contact();
	 	resellerRep.FirstName = 'test';
	 	resellerRep.LastName = 'test last';
	 	resellerRep.AccountId = reseller.Id;
	 	resellerRep.Email='test@test.com';
	 	resellerRep.MailingState = 'California';
		resellerRep.MailingCountry =  'United States';
	 	insert resellerRep;
	 	
	 	acc2 = new Account();
        acc2.Name = 'test Reseller customer';
        acc2.BillingCity = 'test street';
        acc2.BillingCountry = 'United States';
        acc2.BillingState = 'Washington';
        acc2.CurrencyIsoCode='USD';
        acc2.Type = 'Customer of Reseller';
        acc2.Invoice_Contact__c = con.Id;
        acc2.Referral__c = reseller.id;
        acc2.Referral_Contact__c = resellerRep.id;
        insert acc2;
	 	
	 	//product and pricing
		list<Product2> prodOrig = [Select p.Xero_Product_Code__c, p.Subscription_Type__c, p.Subscription_Period__c, p.Reseller_Tier__c, 
				p.Reseller_Product_Code_del__c, p.Reseller_Account_del__c, p.ProductCode, p.Name, p.IsActive, p.Family, 
				p.Description, 
				(Select Pricebook2Id, Product2Id, CurrencyIsoCode, UnitPrice, IsActive From PricebookEntries) 
				From Product2 p	where p.Xero_Product_Code__c ='RS20TD1Y'  and p.IsActive = true limit 1];
		
		prod = new Product2();
		prod.Xero_Product_Code__c=prodOrig[0].Xero_Product_Code__c;
		prod.Subscription_Type__c=prodOrig[0].Subscription_Type__c;
		prod.Subscription_Period__c=prodOrig[0].Subscription_Period__c;
		prod.Reseller_Product_Code_del__c=prodOrig[0].Reseller_Product_Code_del__c;
		prod.Reseller_Account_del__c=prodOrig[0].Reseller_Account_del__c;
		prod.ProductCode=prodOrig[0].ProductCode;
		prod.Name=prodOrig[0].Name;
		prod.IsActive=prodOrig[0].IsActive;
		prod.Family=prodOrig[0].Family;
		prod.Description =prodOrig[0].Description;
		prod.Reseller_Tier__c = tier.id;
		prod.Is_Reseller_Portal_Enabled__c = true;
		insert prod;
		prices = new list<PricebookEntry>();
		for(PricebookEntry p :prodOrig[0]. PricebookEntries){
			PricebookEntry newpb = new PricebookEntry();
			newpb.Pricebook2Id=p.Pricebook2Id;
			newpb.Product2Id =prod.id;
			newpb.CurrencyIsoCode=p.CurrencyIsoCode;
			newpb.UnitPrice=p.UnitPrice;
			newpb.IsActive= p.IsActive;
			prices.add(newpb);
		}
		
		insert prices;
		
		
		// create invoice record
		Hapara_Invoice__c inv = new Hapara_Invoice__c();
		inv.Account__c = acc.Id;
		inv.Status__c = 'Sent to Customer';
	    inv.CurrencyIsoCode = acc.CurrencyIsoCode;
	    inv.Invoice_Date__c =Date.today();
	    inv.Due_Date__c = Date.today().addDays(45);
	    inv.Invoice_To_Contact__c = con.id;
	    inv.Xero_Invoice_No__c='INV-10001';
	    inv.Xero_Id__c = 'xxx';
	    insert inv;
	    
		Account_Products__c lineItem = new Account_Products__c();
		lineItem.Hapara_Invoice__c = inv.Id;
		lineItem.Account__c = acc.Id;
		lineItem.CurrencyIsoCode = acc.CurrencyIsoCode;
		Date endDate = Hapara_UtilityCommonRecordAccess.CalculateProductEndSubscriptionDate(prod,Date.today());
		lineItem.Subscription_Start_Date__c = Date.today();
		lineItem.Subscription_End_Date__c = endDate;
		lineItem.Description__c = Hapara_UtilityCommonRecordAccess.BuildInvoiceLineDescription(prod.Description,acc.name, 
    		lineItem.Subscription_Start_Date__c,  lineItem.Subscription_End_Date__c);
		lineItem.Invoice_Date__c = Date.today();
		lineItem.Product__c = prod.Id;
		lineItem.Quantity__c = 20;
		lineItem.Unit_Price__c =4.00;
		lineItem.Product_Family__c= prod.family;
		lineItem.Invoice_No__c = inv.Xero_Invoice_No__c;
		insert lineItem;
		
		Hapara_Invoice__c inv2 = new Hapara_Invoice__c();
		inv2.Account__c = reseller.Id;
		inv2.Status__c = 'Sent to Customer';
	    inv2.CurrencyIsoCode = reseller.CurrencyIsoCode;
	    inv2.Invoice_Date__c =Date.today();
	    inv2.Due_Date__c = Date.today().addDays(45);
	    inv2.Invoice_To_Contact__c = con.id;
	    inv2.Xero_Invoice_No__c='INV-10001';
	    inv2.Xero_Id__c = 'xxx';
	    insert inv2;
	    
		Account_Products__c lineItem2 = new Account_Products__c();
		lineItem2.Hapara_Invoice__c = inv2.Id;
		lineItem2.Account__c = acc2.Id;
		lineItem2.CurrencyIsoCode = reseller.CurrencyIsoCode;
		Date endDate2 = Hapara_UtilityCommonRecordAccess.CalculateProductEndSubscriptionDate(prod,Date.today());
		lineItem2.Subscription_Start_Date__c = Date.today();
		lineItem2.Subscription_End_Date__c = endDate2;
		lineItem2.Description__c = Hapara_UtilityCommonRecordAccess.BuildInvoiceLineDescription(prod.Description,acc2.name, 
    		lineItem2.Subscription_Start_Date__c,  lineItem2.Subscription_End_Date__c);
		lineItem2.Invoice_Date__c = Date.today();
		lineItem2.Product__c = prod.Id;
		lineItem2.Quantity__c = 20;
		lineItem2.Unit_Price__c =4.00;
		lineItem2.Product_Family__c= prod.family;
		lineItem2.Invoice_No__c = inv.Xero_Invoice_No__c;
		insert lineItem2;
		
		//TD record 
		TD_Domain__c td1 = new TD_Domain__c();
		td1.SIS_Enabled__c = 'true';
		td1.RC_Enabled__c='false';
		td1.Number_Students__c='100';
		td1.Created_By__c = 'test';
		td1.Account__c  = acc.Id;
		insert td1;
		
		TD_Domain__c td2 = new TD_Domain__c();
		td2.SIS_Enabled__c = 'true';
		td2.RC_Enabled__c='false';
		td2.Number_Students__c='100';
		td2.Created_By__c = 'test';
		td2.Account__c  = acc2.id;
		insert td2;
	}
}