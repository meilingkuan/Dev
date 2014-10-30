public class HaparaResellerUtilityCommon {
	public static boolean ValidateResellerMinimumOrder(list<Account_Products__c> orderLine,Contact resellerRep, 
		Account reseller, Account acc, Hapara_Invoice__c invoice,User accountManager	){
		boolean result = true;
		if(!acc.Type.contains('Customer')){
			if(HAPARA_CONST.SETTING_RESELLER.Check_Minimum_Order_Quantity__c){
				list<string> cc = new list<string>(); 
				cc.add('rspurchaseorder@hapara.com');
				
				decimal quantity = 0;
				for(Account_Products__c line: orderLine){
					if(line.Product_Family__c.contains('TD') && line.Quantity__c> quantity)
						quantity =  line.Quantity__c;
				}
				
				if(quantity < 15 ){
					if(acc.TD_Setup_Date__c == null && !reseller.Reseller_Low_Order_Send_to_Customer__c){
						HaparaSendEmailNotification.SendContactEmailwithBCCNSender(resellerRep,
							HAPARA_CONST.SETTING_RESELLER.Minimum_Order_Rep_Email__c,
							acc, null,cc,accountManager.Name, accountManager.email);
						result = false;
					}
				}
			}
		}
		return result;
	}
	
	public static String getResellerSalesEmail(Account reseller){
    	String email = 'resellersales@hapara.com';
    	if(reseller != null)
    		if(reseller.Internal_Reseller_Sales_Email__c != null)
    			email = reseller.Internal_Reseller_Sales_Email__c;
    	return email;
    }
	
	public static void createTaskforSetup(Account acc, Contact con, Account reseller,list<string> cc ){
		if(acc.TD_Setup_Date__c == null){
			///List<Task> setupTask = [Select t.Subject, t.AccountId From Task t
			///					where (t.subject  like '%Teacher Dashboard Setup Preparation Information%' 
			//					or  t.subject  like 'Schedule Setup for%' )
			//					and t.AccountId =: acc.Id limit 1];
			System.debug('****createTaskforSetup: account= '+acc.Name);
			//if(setupTask.isEmpty()){
			//	Task setup = new Task();
			//	setup.ActivityDate = Date.today().addDays(5);
			//	setup.OwnerId =HAPARA_CONST.SETTING_RESELLER.Reseller_Scheduling_User_Id__c;
			//	setup.WhatId = acc.Id;
			//	setup.WhoId = con.Id;
			//	setup.Subject = 'Schedule Setup for ' + acc.Name;
			//	setup.priority= 'High';
			//	setup.status = 'Not Started';
				
				 // The following 3 lines of code control whether the task notification is sent when the task is inserted
           //     Database.DMLOptions dmlo = new Database.DMLOptions();
           //     dmlo.EmailHeader.triggerUserEmail = true;
           //     database.insert(setup, dmlo);
				
			string setupEmail =acc.No_of_Students__c > 15 ?HAPARA_CONST.SETTING_RESELLER.RESELLER_SETUP_EMAIL_TEMPLATE__c:
				HAPARA_CONST.SETTING_RESELLER.Reseller_Setup_Email_Temp_Name_Low_No__c; 
			
			if(acc.No_of_Students__c <15 && ! string.isBlank( reseller.Reseller_Setup_Email_Temp_Name_Low_No__c)){
				setupEmail = reseller.Reseller_Setup_Email_Temp_Name_Low_No__c;
			}else if(reseller.Reseller_Setup_Email_Template_Name__c != null)
				setupEmail =reseller.Reseller_Setup_Email_Template_Name__c ; 
			
			HaparaSendEmailNotification.SendContactEmailwithBCC(con,
				setupEmail,acc, null,cc);
			//}
			
		}else{
			HaparaSendEmailNotification.SendContactEmailwithBCC(con,HAPARA_CONST.SETTING_RESELLER.Customer_Order_Processed_Email__c,acc, null,cc);
		}
	}
	
	public static void sendRSAdministratorEmail(Opportunity opportunity,String sendToEmail,
		string subject, string additionalLine ){
   		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses;
		String salesforceURL = Hapara_Utility.isRunningInSandbox()?Hapara_Utility.GetSandboxURL():Hapara_Utility.GetProductionURL();
		
										
		System.debug('Email sent to Reseller Sales at ' + sendToEmail);
					
		mail.setSenderDisplayName('Reseller Sales');
		toAddresses = new String[] {sendToEmail};
		mail.setToAddresses(toAddresses);
   
		// set the subject on the email
		mail.setSubject('New '+ subject+' added to Salesforce from ' + opportunity.Name);
			      
		// set the body of the email
		mail.setHTMLBody('<p>*** NEW '+subject+' *** </p>' 
				   		+ '<p>The following '+subject+' has been added to Salesforce </p>'
				   		+ '<p>Opportunity: ' + opportunity.Name +'</p>'
				   		+ '<p>Size of Opportunity: ' + opportunity.Size_of_Opportunity__c +'</p>'
				   		+ '<p>Registration Closed Date: ' + opportunity.CloseDate +'</p>'
				   		+ '<p>Registration Notes: ' + opportunity.Description +'</p>'
				   		+ additionalLine
				   		+ '<p>Click on the link to access the reseller '+subject+' directly: ' 
				   		+ salesforceURL	+'/'+ opportunity.id+'</p>'
				   	);
			  				   
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
   }
	
   public static string getResellerCustomerCurrencyCode(string LeadCountry, string ResellerCurrencyCode){
		string currencyCode ='USD'; 
		if(!string.isEmpty(LeadCountry)){
    		currencyCode = Hapara_UtilityCommonRecordAccess.setCurrencyCode(LeadCountry, true);
    	}else{
    		currencyCode =ResellerCurrencyCode;
    	}
    	return  currencyCode; 
	}
}