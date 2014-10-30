@isTest(SeeAllData=true)
private with sharing class HaparaSendEmailNotification_Test {
	static testmethod void testSendContactEmail(){
		Account a = new Account();
		a.RecordTypeId = '01290000000ONfs';
		a.Name='TEst account';
		insert a;
		Contact c = new Contact();
		c.FirstName = 'test';
		c.LastName='last';
		c.Email='test@gmail.com';
		c.AccountId= a.Id;
		insert c;
		System.assertEquals(HaparaSendEmailNotification.SendContactEmail(c, 'Contact_Reseller_Registration_Confirmation',a,null), true);
		HaparaSendEmailNotification.SendEmailInThefuture(c.Id,a.Id,'Contact_Reseller_Registration_Confirmation','Hapara Team','customerservices@hapara.com');	
		HaparaSendEmailNotification.SendContactEmailwithBCCNSetWhatId(c,'Contact_Reseller_Registration_Confirmation',a.id,
		new list<string>{'test@gmail.com'});
		Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName('HaparaDemoBooking.ics');
      
        efa.setBody(blob.valueOf('Some Text'));
		HaparaSendEmailNotification.SendContactEmailwithBCCNSetWhatIdNAttachment(c,'Contact_Reseller_Registration_Confirmation',a.id,
					new list<string>{'test@gmail.com'},  new Messaging.EmailFileAttachment[] {efa});
	}
	
	static testmethod void testSendContactEmailwithBCC(){
		Account a = new Account();
		a.RecordTypeId = '01290000000ONfs';
		a.Name='TEst account';
		insert a;
		Contact c = new Contact();
		c.FirstName = 'test';
		c.LastName='last';
		c.Email='test@gmail.com';
		c.AccountId= a.Id;
		insert c;
		list<string> bcc = new list<string>();
		bcc.add('test@email.com');
		System.assertEquals(HaparaSendEmailNotification.SendContactEmailwithBCC(c, 'Contact_Reseller_Registration_Confirmation',a,null,bcc), true);
		
		
	}
	
	static testmethod void testHaparaSendContactSandboxEmail(){
		Account a = new Account();
		a.RecordTypeId = '01290000000ONfs';
		a.Name='TEst account';
		insert a;
		Contact c = new Contact();
		c.FirstName = 'test';
		c.LastName='last';
		c.Email='test@gmail.com';
		c.AccountId= a.Id;
		insert c;
		Sandbox_Register__c s = new Sandbox_Register__c();
		s.Account_Id__c = a.Id;
		s.Class_ID__c = 'test class';
		s.Login__c = 'test login';
		s.Password__c = 'test password';
		s.Customer_Contact__c = c.id;
		System.assertEquals(HaparaSendEmailNotification.SendContactSandboxEmail(c, 'SandboxRegister_Login_Details',s), true);
			
	}
	
	static testmethod void testHaparaSendAdminErrorEmail(){
		String salesforceURL = Hapara_Utility.isRunningInSandbox()?Hapara_Utility.GetSandboxURL():Hapara_Utility.GetProductionURL();
		System.assertEquals(HaparaSendEmailNotification.SendAdminErrorEmail('testHaparaSendAdminErrorEmail', 'test',salesforceURL), true);
			
	}
	
	static testmethod void testSendMassContactEmails(){
		Account a = new Account();
		a.RecordTypeId = '01290000000ONfs';
		a.Name='TEst account';
		insert a;
		Contact c = new Contact();
		c.FirstName = 'test';
		c.LastName='last';
		c.Email='test@gmail.com';
		c.AccountId= a.Id;
		insert c;
		Contact c1 = new Contact();
		c1.FirstName = 'test2';
		c1.LastName='last';
		c1.Email='test2@gmail.com';
		c1.AccountId= a.Id;
		insert c1;
	
		Id[] contactId = new Id[]{c.Id,c1.Id};
		System.assertEquals(HaparaSendEmailNotification.SendMassContactEmails('Contact_Reseller_Registration_Confirmation',
			 a.Id,'Account',contactId ,'Test', 'customer.services@hapara.com',null),true);
	}
	
	static testmethod void testSendUserWithTemplate(){
		Campaign testCampaign = new Campaign();
		testCampaign.Name='test campaign';
		testCampaign.Type='Demonstration';
		testCampaign.Status = 'In Progress';
		testCampaign.IsActive = true;
		insert testCampaign;
		
		System.assertEquals(HaparaSendEmailNotification.SendUserWithTemplate('Schedule_Internal_Demo_reminder',
			 testCampaign.id, 'meiling.kuan@hapara.com'),true);
		
	}
	
	
}