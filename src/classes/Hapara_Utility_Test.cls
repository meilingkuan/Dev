@isTest(SeeAllData=true)
private with sharing class Hapara_Utility_Test {
	static testmethod void testUtility(){
		 String s  =  System.URL.getSalesforceBaseUrl().getHost();
		 Boolean result = s.contains('cs');
		 System.assertEquals( Hapara_Utility.isRunningInSandbox(), result)	;
		 
		 String s2 = 'https://hapara--dev.cs6.my.salesforce.com';
		 System.assertEquals(Hapara_Utility.GetSandboxURL(), s2);
		 
		 String s3 = 'https://hapara.my.salesforce.com';
		 System.assertEquals(Hapara_Utility.GetProductionURL(), s3);
		 string mth = ' January';
		 system.assertEquals(Hapara_Utility.getMonthValuefromString(mth), 1);
		 mth = ' March';
		 system.assertEquals(Hapara_Utility.getMonthValuefromString(mth), 3);	
		 mth = ' April';
		 system.assertEquals(Hapara_Utility.getMonthValuefromString(mth), 4);	
		 mth = ' May';
		 system.assertEquals(Hapara_Utility.getMonthValuefromString(mth), 5);	
		 mth = ' August';
		 system.assertEquals(Hapara_Utility.getMonthValuefromString(mth), 8);
		 mth = ' November';
		 system.assertEquals(Hapara_Utility.getMonthValuefromString(mth), 11);		
		 mth = ' December';
		 system.assertEquals(Hapara_Utility.getMonthValuefromString(mth), 12);	
		 
		 string value = Hapara_Utility.replaceLineBreakWithLineChar('\n');
		 system.assertEquals(value, '<br/>');
		 
		system.assert(!Hapara_Utility.validatePersonalEmail('1@gmail.com'));
		system.assert(!Hapara_Utility.validatePersonalEmail('1@yahoo.com'));
		system.assert(!Hapara_Utility.validatePersonalEmail('1@aol.com'));
		system.assert(!Hapara_Utility.validatePersonalEmail('1@hotmail.com'));
	}
	
	static testmethod void testHapara_UtilityCommonRecordAccess(){
		Account acc = [select name from Account limit 1];
		Product2 pro = [Select p.Subscription_Type__c,Subscription_Period__c, p.Name, p.Description
 						From Product2 p where Subscription_Type__c = 'Yearly' limit 1
 						];
 						
 		Date startDate = Date.today();
 		Date endDate = Hapara_UtilityCommonRecordAccess.CalculateProductEndSubscriptionDate(pro, startDate);
 		system.assert(endDate >= Date.Today());
 		pro.Subscription_Type__c = 'Monthly';
 		endDate = Hapara_UtilityCommonRecordAccess.CalculateProductEndSubscriptionDate(pro, startDate);
 		system.assert(endDate >= Date.Today());
 		pro.Subscription_Type__c = 'Biannually';
 		endDate = Hapara_UtilityCommonRecordAccess.CalculateProductEndSubscriptionDate(pro, startDate);
 		system.assert(endDate >= Date.Today());
 		pro.Subscription_Type__c = 'Quarterly';
 		endDate = Hapara_UtilityCommonRecordAccess.CalculateProductEndSubscriptionDate(pro, startDate);
 		system.assert(endDate >= Date.Today());
 		pro.Subscription_Type__c = 'One Off';
 		endDate = Hapara_UtilityCommonRecordAccess.CalculateProductEndSubscriptionDate(pro, startDate);
 		system.assert(endDate == Date.Today());
 		
 		
 		string description = Hapara_UtilityCommonRecordAccess.BuildInvoiceLineDescription(pro.Description, acc.Name, startDate, endDate);
 		system.assert(description.length() >0);
 		string invalidCharacter = '~!@#$%^&*_+=<>?';
 		string newValue = Hapara_UtilityCommonRecordAccess.stripInvalidCharacter(invalidCharacter);
 		system.assertEquals(newValue,'');
 		string schoolname = 'King\'s School';
 		newValue = Hapara_UtilityCommonRecordAccess.stripInvalidCharacter(schoolname);
 		system.assertEquals(newvalue,'Kings School');
 		
 		system.assert(Hapara_UtilityCommonRecordAccess.getCountriesList()!=null);
 		system.assert(Hapara_UtilityCommonRecordAccess.getCountryStatesList('United States').size()>0);
 		system.assert(Hapara_UtilityCommonRecordAccess.getPriceEntryforTDProduct('TD','USD')!=null);
 		system.assertEquals(Hapara_UtilityCommonRecordAccess.setCurrencyCode('Australia', true),'AUD');
 		system.assertEquals(Hapara_UtilityCommonRecordAccess.setBillingInOwnCurrency('Australia', 'Customer of Reseller',false),true);
	}
}