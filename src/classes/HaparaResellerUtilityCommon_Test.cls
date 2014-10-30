@isTest(SeeAllData=true)
public class HaparaResellerUtilityCommon_Test {
	public static Account reseller;
	public static Contact resellerRep;
	public static Account acc;
	public static Contact con;
	public static Lead lead;
	public static Reseller_Tier__c tier;
	public static Product2 prod;
	public static Opportunity opptest;
	 
	 public static testmethod void CreateTestResellerRecords(){
	  	tier = new Reseller_Tier__c ();
		tier.Name = 'tier 1';
		tier.Description__c = 'tier 1';
		tier.IsActive__c = true;
		//tier.Combination_Tier__c = true;
		insert tier;
		list<Product2> prodOrig = [Select p.Xero_Product_Code__c, p.Subscription_Type__c, p.Subscription_Period__c, p.Reseller_Tier__c, 
				p.Reseller_Product_Code_del__c, p.Reseller_Account_del__c, p.ProductCode, p.Name, p.IsActive, p.Family, 
				p.Description, 
				(Select Pricebook2Id, Product2Id, CurrencyIsoCode, UnitPrice, IsActive From PricebookEntries) 
				From Product2 p	where p.Name like 'Teacher Dashboard%' and p.IsActive = true limit 1];
		
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
		
		for(PricebookEntry p :prodOrig[0]. PricebookEntries){
			PricebookEntry newpb = new PricebookEntry();
			newpb.Pricebook2Id=p.Pricebook2Id;
			newpb.Product2Id =prod.id;
			newpb.CurrencyIsoCode=p.CurrencyIsoCode;
			newpb.UnitPrice=p.UnitPrice;
			newpb.IsActive= p.IsActive;
			insert newpb;
		}
		
	 	reseller = new Account();
	 	reseller.Name = 'Test Reseller';
	 	reseller.Type = 'Reseller';
	 	reseller.Reseller_s_Email_Domain__c ='test.com';
	 	reseller.Reseller_Tier__c =tier.Id;
	 	reseller.CurrencyIsoCode = 'USD';
	 	reseller.Can_Submit_Purchase_Order__c = true;
	 	reseller.BillingCountry = 'United States';
	 	insert reseller;
	 	resellerRep = new Contact();
	 	resellerRep.FirstName = 'test';
	 	resellerRep.LastName = 'test last';
	 	resellerRep.AccountId = reseller.Id;
	 	resellerRep.Email='test@test.com';
	 	resellerRep.MailingState = 'California';
		resellerRep.MailingCountry =  'United States';
	 	insert resellerRep;
	 	
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
        //con.AccountId = acc.Id;
        insert con;
        acc.Invoice_Contact__c = con.Id;
        insert acc;
        
        lead =new Lead();
   		lead.FirstName = 'Test';
		lead.LastName = 'Last';
		lead.Email = 'test@gmail.com';
		lead.Title = 'job';
		lead.Company =  'company';
		lead.State = 'California';
		lead.Country =  'United States';
		lead.Website = 'domain';
		lead.CurrencyIsoCode = 'USD';
		insert lead;		
		
		List <Campaign> campaign = [select id, name from Campaign where name = :'Reseller/ Referral' limit 1];
       	RecordType resellerType = [SELECT Id FROM RecordType where DeveloperName = 'Reseller_Opportunity'];
		opptest =new Opportunity();			
		opptest.Opportunity_Name_Template__c =  'Teacher Dashboard';
		opptest.Reseller_Tier__c = tier.id;
		opptest.Size_of_Opportunity__c = 'under 2000';
		opptest.AccountId = reseller.id;	
		opptest.StageName = 'Approved Registration';
		opptest.CloseDate= Date.Today().addDays(90);
		opptest.Probability=80;		
		opptest.CampaignId=campaign[0].Id;
		opptest.LeadSource= 'Reseller Deal Registration';		
		opptest.Reseller_s_Rep__c = ResellerRep.Id;	
		opptest.CurrencyIsoCode=reseller.CurrencyIsoCode;
		opptest.RecordTypeId = resellerType.Id;
		opptest.Resellers_Account__c= acc.id;
		opptest.Reseller_s_Contact__c = con.id;
		opptest.Name = acc.Name + 'TEST';
		insert opptest;		
	 }
	 
	 private static testmethod void testHaparaResellerUtilityCommon(){
	 	HaparaResellerUtilityCommon_Test.CreateTestResellerRecords();
	 	list<string> cc = new list<string>();
		cc.add(HaparaResellerUtilityCommon_Test.resellerRep.email);
	 	HaparaResellerUtilityCommon.createTaskforSetup(HaparaResellerUtilityCommon_Test.acc,HaparaResellerUtilityCommon_Test.con,
	 		HaparaResellerUtilityCommon_Test.reseller,cc);
	 	HaparaResellerUtilityCommon.sendRSAdministratorEmail(HaparaResellerUtilityCommon_Test.opptest, 'test@gmail.com','Purchase Order','');
	 	
	 	system.assert(HaparaResellerUtilityCommon.getResellerSalesEmail(HaparaResellerUtilityCommon_Test.reseller)!=null);
	 	system.assertEquals(HaparaResellerUtilityCommon.getResellerCustomerCurrencyCode('New Zealand', 'USD'), 'NZD');  
	 }
}