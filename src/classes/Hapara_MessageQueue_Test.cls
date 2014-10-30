/**
 * Tests for Hapara_MessageQueue classes
 * 
 * @author Logan (Trineo)
 * @date August 2013
 */
@isTest (SeeAllData=true)
public class Hapara_MessageQueue_Test {

//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\

	static testmethod void signedUp_accountExists() {

		String email = 'uniquetest.email@hapara.com.test';
		String fullname = 'Test User';
		String startdate = '2013-06-24T00:00:00';
		String trialenddate = '2013-07-24T00:00:00';
		String referrer = 'uniquetest.referrer@hapara.com.test';
		Integer tcversion = 1;
		String notificationperference = 'PROD';

		RecordType personAccountRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = :Hapara_MessageQueue_Handler.PERSON_ACCOUNT_RECORDTYPE];
		Account existingAccount = new Account(FirstName = 'Test', LastName = 'User', PersonEmail = email, RecordTypeId = personAccountRT.Id);
		insert existingAccount;

		String json = '{"startdate": "'+startdate+'", "referrer": "'+referrer+'", "notificationperference": "'+notificationperference+'", "tcversion": '+tcversion+', "trialenddate": "'+trialenddate+'", "fullname": "'+fullname+'", "email": "'+email+'"}';

		MessageQueue__c signedUpMessage = new MessageQueue__c(
			ApplicationName__c = 'TDI',
			MessageType__c = Hapara_MessageQueue_Handler.MESSAGE_TYPE_SIGNEDUP,
			Status__c = Hapara_MessageQueue_Handler.MESSAGE_STATUS_NEW,
			OriginMsgId__c = generateGUID(),
			MessageContent__c = json
		);

		Test.startTest();
		insert signedUpMessage;
		Test.stopTest();

		signedUpMessage = [
			SELECT Id, Status__c, ErrorMessage__c, DateCompleted__c
			FROM MessageQueue__c
			WHERE Id = :signedUpMessage.Id
		];

		System.assertEquals(null, signedUpMessage.ErrorMessage__c);
		System.assertEquals(Hapara_MessageQueue_Handler.MESSAGE_STATUS_COMPLETED, signedUpMessage.Status__c);
		System.assertNotEquals(null, signedUpMessage.DateCompleted__c);

		// Check that the account looks correct

		Account a = [
			SELECT Id, FirstName, LastName, PersonEmail, Type, TD_Setup_Date__c, Trial_End_Date__c, Term_and_Condition_Version__c, Notification_Per__c, Referral_Email__c, Referral__c,
			(
				SELECT Id FROM Opportunities WHERE Opportunity_Name_Template__c = :Hapara_MessageQueue_Handler.OPPORTUNITY_NAME_TEMPLATE
			)
			FROM Account
			WHERE PersonEmail = :email
		];

		System.assertEquals(existingAccount.FirstName, a.FirstName);
		System.assertEquals(existingAccount.LastName, a.LastName);
		System.assertEquals(email, a.PersonEmail);
		System.assertEquals(Hapara_MessageQueue_Handler.ACCOUNT_TYPE_PROSPECT_OF_INNOVATOR, a.Type);
		System.assertEquals(Date.valueOf(startdate), a.TD_Setup_Date__c);
		System.assertEquals(Date.valueOf(trialenddate), a.Trial_End_Date__c);
		System.assertEquals(tcversion, a.Term_and_Condition_Version__c);
		System.assertEquals(notificationperference, a.Notification_Per__c);
		System.assertEquals(null, a.Referral__c);
		System.assertEquals(referrer, a.Referral_Email__c);
		System.assertEquals(1, a.Opportunities.size());

		// Check the opportunity looks correct
		
		Opportunity o = [
			SELECT Id, Opportunity_Name_Template__c, StageName, CloseDate, Campaign.Name,
			(
				SELECT Id, PricebookEntry.Name, Quantity FROM OpportunityLineItems
			)
			FROM Opportunity
			WHERE Id = :a.Opportunities[0].Id
		];

		System.assertEquals(Hapara_MessageQueue_Handler.OPPORTUNITY_NAME_TEMPLATE, o.Opportunity_Name_Template__c);
		System.assertEquals(Hapara_MessageQueue_Handler.OPPORTUNITY_STAGE_PROSPECTING, o.StageName);
		System.assertEquals(Date.today().addDays(Hapara_MessageQueue_Handler.OPPORTUNITY_CLOSE_DATE_INTERVAL), o.CloseDate);
		System.assertEquals(1, o.OpportunityLineItems.size());
		System.assertEquals('Teacher Dashboard Innovator', o.OpportunityLineItems[0].PricebookEntry.Name);
		System.assertEquals(1, o.OpportunityLineItems[0].Quantity);
	}

//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\

	static testmethod void signedUp_multipleAccountsExist() {

		String email = 'uniquetest.email@hapara.com.test';
		String fullname = 'Test User';
		String startdate = '2013-06-24T00:00:00';
		String trialenddate = '2013-07-24T00:00:00';
		String referrer = 'uniquetest.referrer@hapara.com.test';
		Integer tcversion = 1;
		String notificationperference = 'PROD';

		RecordType personAccountRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = :Hapara_MessageQueue_Handler.PERSON_ACCOUNT_RECORDTYPE];
		Account referrerAccount1 = new Account(FirstName = 'Test', LastName = 'User1', PersonEmail = email, RecordTypeId = personAccountRT.Id);
		Account referrerAccount2 = new Account(FirstName = 'Test', LastName = 'User2', PersonEmail = email, RecordTypeId = personAccountRT.Id);
		insert referrerAccount1;
		insert referrerAccount2;

		String json = '{"startdate": "'+startdate+'", "referrer": "'+referrer+'", "notificationperference": "'+notificationperference+'", "tcversion": '+tcversion+', "trialenddate": "'+trialenddate+'", "fullname": "'+fullname+'", "email": "'+email+'"}';

		MessageQueue__c signedUpMessage = new MessageQueue__c(
			ApplicationName__c = 'TDI',
			MessageType__c = Hapara_MessageQueue_Handler.MESSAGE_TYPE_SIGNEDUP,
			Status__c = Hapara_MessageQueue_Handler.MESSAGE_STATUS_NEW,
			OriginMsgId__c = generateGUID(),
			MessageContent__c = json
		);

		Test.startTest();
		insert signedUpMessage;
		Test.stopTest();

		signedUpMessage = [
			SELECT Id, Status__c, ErrorMessage__c, DateCompleted__c
			FROM MessageQueue__c
			WHERE Id = :signedUpMessage.Id
		];

		System.assertNotEquals(null, signedUpMessage.ErrorMessage__c);
		System.assertEquals(Hapara_MessageQueue_Handler.MESSAGE_STATUS_ERRORED, signedUpMessage.Status__c);
		System.assertEquals(null, signedUpMessage.DateCompleted__c);
	}

//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\

	static testmethod void signedUp_leadExists() {

		String email = 'uniquetest.email@hapara.com.test';
		String fullname = 'Test User';
		String startdate = '2013-06-24T00:00:00';
		String trialenddate = '2013-07-24T00:00:00';
		String referrer = 'uniquetest.referrer@hapara.com.test';
		Integer tcversion = 1;
		String notificationperference = 'PROD';

		Lead lead = new Lead(FirstName = 'Test', LastName = 'User', Company = 'Company', Email = email);
		insert lead;

		String json = '{"startdate": "'+startdate+'", "referrer": "'+referrer+'", "notificationperference": "'+notificationperference+'", "tcversion": '+tcversion+', "trialenddate": "'+trialenddate+'", "fullname": "'+fullname+'", "email": "'+email+'"}';

		MessageQueue__c signedUpMessage = new MessageQueue__c(
			ApplicationName__c = 'TDI',
			MessageType__c = Hapara_MessageQueue_Handler.MESSAGE_TYPE_SIGNEDUP,
			Status__c = Hapara_MessageQueue_Handler.MESSAGE_STATUS_NEW,
			OriginMsgId__c = generateGUID(),
			MessageContent__c = json
		);

		Test.startTest();
		insert signedUpMessage;
		Test.stopTest();

		signedUpMessage = [
			SELECT Id, Status__c, ErrorMessage__c, DateCompleted__c
			FROM MessageQueue__c
			WHERE Id = :signedUpMessage.Id
		];

		System.assertEquals(null, signedUpMessage.ErrorMessage__c);
		System.assertEquals(Hapara_MessageQueue_Handler.MESSAGE_STATUS_COMPLETED, signedUpMessage.Status__c);
		System.assertNotEquals(null, signedUpMessage.DateCompleted__c);

		// Check that the account looks correct

		Account a = [
			SELECT Id, FirstName, LastName, PersonEmail, Type, TD_Setup_Date__c, Trial_End_Date__c, Term_and_Condition_Version__c, Notification_Per__c, Referral_Email__c, Referral__c,
			(
				SELECT Id FROM Opportunities WHERE Opportunity_Name_Template__c = :Hapara_MessageQueue_Handler.OPPORTUNITY_NAME_TEMPLATE
			)
			FROM Account
			WHERE PersonEmail = :email
		];

		System.assertEquals(lead.FirstName, a.FirstName);
		System.assertEquals(lead.LastName, a.LastName);
		System.assertEquals(email, a.PersonEmail);
		System.assertEquals(Hapara_MessageQueue_Handler.ACCOUNT_TYPE_PROSPECT_OF_INNOVATOR, a.Type);
		System.assertEquals(Date.valueOf(startdate), a.TD_Setup_Date__c);
		System.assertEquals(Date.valueOf(trialenddate), a.Trial_End_Date__c);
		System.assertEquals(tcversion, a.Term_and_Condition_Version__c);
		System.assertEquals(notificationperference, a.Notification_Per__c);
		System.assertEquals(null, a.Referral__c);
		System.assertEquals(referrer, a.Referral_Email__c);
		System.assertEquals(1, a.Opportunities.size());

		// Check the opportunity looks correct
		
		Opportunity o = [
			SELECT Id, Opportunity_Name_Template__c, StageName, CloseDate, Campaign.Name,
			(
				SELECT Id, PricebookEntry.Name, Quantity FROM OpportunityLineItems
			)
			FROM Opportunity
			WHERE Id = :a.Opportunities[0].Id
		];

		System.assertEquals(Hapara_MessageQueue_Handler.OPPORTUNITY_NAME_TEMPLATE, o.Opportunity_Name_Template__c);
		System.assertEquals(Hapara_MessageQueue_Handler.OPPORTUNITY_STAGE_PROSPECTING, o.StageName);
		System.assertEquals(Date.today().addDays(Hapara_MessageQueue_Handler.OPPORTUNITY_CLOSE_DATE_INTERVAL), o.CloseDate);
		System.assertEquals(1, o.OpportunityLineItems.size());
		System.assertEquals('Teacher Dashboard Innovator', o.OpportunityLineItems[0].PricebookEntry.Name);
		System.assertEquals(1, o.OpportunityLineItems[0].Quantity);
	}

//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\

	static testmethod void signedUp_multipleLeadsExist() {

		String email = 'uniquetest.email@hapara.com.test';
		String fullname = 'Test User';
		String startdate = '2013-06-24T00:00:00';
		String trialenddate = '2013-07-24T00:00:00';
		String referrer = 'uniquetest.referrer@hapara.com.test';
		Integer tcversion = 1;
		String notificationperference = 'PROD';

		Lead lead1 = new Lead(FirstName = 'Test', LastName = 'User', Email = email);
		Lead lead2 = new Lead(FirstName = 'Test', LastName = 'User', Email = email);
		insert lead1;
		insert lead2;

		String json = '{"startdate": "'+startdate+'", "referrer": "'+referrer+'", "notificationperference": "'+notificationperference+'", "tcversion": '+tcversion+', "trialenddate": "'+trialenddate+'", "fullname": "'+fullname+'", "email": "'+email+'"}';

		MessageQueue__c signedUpMessage = new MessageQueue__c(
			ApplicationName__c = 'TDI',
			MessageType__c = Hapara_MessageQueue_Handler.MESSAGE_TYPE_SIGNEDUP,
			Status__c = Hapara_MessageQueue_Handler.MESSAGE_STATUS_NEW,
			OriginMsgId__c = generateGUID(),
			MessageContent__c = json
		);

		Test.startTest();
		insert signedUpMessage;
		Test.stopTest();

		signedUpMessage = [
			SELECT Id, Status__c, ErrorMessage__c, DateCompleted__c
			FROM MessageQueue__c
			WHERE Id = :signedUpMessage.Id
		];

		System.assertEquals(null, signedUpMessage.ErrorMessage__c);
		System.assertEquals(Hapara_MessageQueue_Handler.MESSAGE_STATUS_COMPLETED, signedUpMessage.Status__c);
		System.assertNotEquals(null, signedUpMessage.DateCompleted__c);

		System.assertEquals(false, [SELECT Id, IsConverted FROM Lead WHERE Id = :lead1.Id].IsConverted);
		System.assertEquals(false, [SELECT Id, IsConverted FROM Lead WHERE Id = :lead2.Id].IsConverted);
	}

//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\

	static testmethod void signedUp_referrerNotExists() {
		
		String email = 'uniquetest.email@hapara.com.test';
		String fullname = 'Test User';
		String startdate = '2013-06-24T00:00:00';
		String trialenddate = '2013-07-24T00:00:00';
		String referrer = 'uniquetest.referrer@hapara.com.test';
		Integer tcversion = 1;
		String notificationperference = 'PROD';

		String json = '{"startdate": "'+startdate+'", "referrer": "'+referrer+'", "notificationperference": "'+notificationperference+'", "tcversion": '+tcversion+', "trialenddate": "'+trialenddate+'", "fullname": "'+fullname+'", "email": "'+email+'"}';

		MessageQueue__c signedUpMessage = new MessageQueue__c(
			ApplicationName__c = 'TDI',
			MessageType__c = Hapara_MessageQueue_Handler.MESSAGE_TYPE_SIGNEDUP,
			Status__c = Hapara_MessageQueue_Handler.MESSAGE_STATUS_NEW,
			OriginMsgId__c = generateGUID(),
			MessageContent__c = json
		);

		Test.startTest();
		insert signedUpMessage;
		Test.stopTest();

		signedUpMessage = [
			SELECT Id, Status__c, ErrorMessage__c, DateCompleted__c
			FROM MessageQueue__c
			WHERE Id = :signedUpMessage.Id
		];

		System.assertEquals(null, signedUpMessage.ErrorMessage__c);
		System.assertEquals(Hapara_MessageQueue_Handler.MESSAGE_STATUS_COMPLETED, signedUpMessage.Status__c);
		System.assertNotEquals(null, signedUpMessage.DateCompleted__c);

		// Check that the account looks correct

		Account a = [
			SELECT Id, FirstName, LastName, PersonEmail, Type, TD_Setup_Date__c, Trial_End_Date__c, Term_and_Condition_Version__c, Notification_Per__c, Referral_Email__c, Referral__c,
			(
				SELECT Id FROM Opportunities WHERE Opportunity_Name_Template__c = :Hapara_MessageQueue_Handler.OPPORTUNITY_NAME_TEMPLATE
			)
			FROM Account
			WHERE PersonEmail = :email
		];

		System.assertEquals(null, a.FirstName);
		System.assertEquals(fullname, a.LastName);
		System.assertEquals(email, a.PersonEmail);
		System.assertEquals(Hapara_MessageQueue_Handler.ACCOUNT_TYPE_PROSPECT_OF_INNOVATOR, a.Type);
		System.assertEquals(Date.valueOf(startdate), a.TD_Setup_Date__c);
		System.assertEquals(Date.valueOf(trialenddate), a.Trial_End_Date__c);
		System.assertEquals(tcversion, a.Term_and_Condition_Version__c);
		System.assertEquals(notificationperference, a.Notification_Per__c);
		System.assertEquals(null, a.Referral__c);
		System.assertEquals(referrer, a.Referral_Email__c);
		System.assertEquals(1, a.Opportunities.size());

		// Check the opportunity looks correct
		
		Opportunity o = [
			SELECT Id, Opportunity_Name_Template__c, StageName, CloseDate, Campaign.Name,
			(
				SELECT Id, PricebookEntry.Name, Quantity FROM OpportunityLineItems
			)
			FROM Opportunity
			WHERE Id = :a.Opportunities[0].Id
		];

		System.assertEquals(Hapara_MessageQueue_Handler.OPPORTUNITY_NAME_TEMPLATE, o.Opportunity_Name_Template__c);
		System.assertEquals(Hapara_MessageQueue_Handler.OPPORTUNITY_STAGE_PROSPECTING, o.StageName);
		System.assertEquals(Date.today().addDays(Hapara_MessageQueue_Handler.OPPORTUNITY_CLOSE_DATE_INTERVAL), o.CloseDate);
		System.assertEquals(1, o.OpportunityLineItems.size());
		System.assertEquals('Teacher Dashboard Innovator', o.OpportunityLineItems[0].PricebookEntry.Name);
		System.assertEquals(1, o.OpportunityLineItems[0].Quantity);
	}

//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\

	static testmethod void signedUp_referrerExists() {
		
		RecordType personAccountRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = :Hapara_MessageQueue_Handler.PERSON_ACCOUNT_RECORDTYPE];
		Account referrerAccount = new Account(FirstName = 'The', LastName = 'Referrer', PersonEmail = 'uniquetest.referrer@hapara.com.test', RecordTypeId = personAccountRT.Id);
		insert referrerAccount;
		
		String email = 'uniquetest.email@hapara.com.test';
		String fullname = 'Test User';
		String startdate = '2013-06-24T00:00:00';
		String trialenddate = '2013-07-24T00:00:00';
		String referrer = 'uniquetest.referrer@hapara.com.test';
		Integer tcversion = 1;
		String notificationperference = 'PROD';

		String json = '{"startdate": "'+startdate+'", "referrer": "'+referrer+'", "notificationperference": "'+notificationperference+'", "tcversion": '+tcversion+', "trialenddate": "'+trialenddate+'", "fullname": "'+fullname+'", "email": "'+email+'"}';

		MessageQueue__c signedUpMessage = new MessageQueue__c(
			ApplicationName__c = 'TDI',
			MessageType__c = Hapara_MessageQueue_Handler.MESSAGE_TYPE_SIGNEDUP,
			Status__c = Hapara_MessageQueue_Handler.MESSAGE_STATUS_NEW,
			OriginMsgId__c = generateGUID(),
			MessageContent__c = json
		);

		Test.startTest();
		insert signedUpMessage;
		Test.stopTest();

		signedUpMessage = [
			SELECT Id, Status__c, ErrorMessage__c, DateCompleted__c
			FROM MessageQueue__c
			WHERE Id = :signedUpMessage.Id
		];

		System.assertEquals(null, signedUpMessage.ErrorMessage__c);
		System.assertEquals(Hapara_MessageQueue_Handler.MESSAGE_STATUS_COMPLETED, signedUpMessage.Status__c);
		System.assertNotEquals(null, signedUpMessage.DateCompleted__c);

		// Check that the account looks correct

		Account a = [
			SELECT Id, FirstName, LastName, PersonEmail, Type, TD_Setup_Date__c, Trial_End_Date__c, Term_and_Condition_Version__c, Notification_Per__c, Referral_Email__c, Referral__c,
			(
				SELECT Id FROM Opportunities WHERE Opportunity_Name_Template__c = :Hapara_MessageQueue_Handler.OPPORTUNITY_NAME_TEMPLATE
			)
			FROM Account
			WHERE PersonEmail = :email
		];

		System.assertEquals(null, a.FirstName);
		System.assertEquals(fullname, a.LastName);
		System.assertEquals(email, a.PersonEmail);
		System.assertEquals(Hapara_MessageQueue_Handler.ACCOUNT_TYPE_PROSPECT_OF_INNOVATOR, a.Type);
		System.assertEquals(Date.valueOf(startdate), a.TD_Setup_Date__c);
		System.assertEquals(Date.valueOf(trialenddate), a.Trial_End_Date__c);
		System.assertEquals(tcversion, a.Term_and_Condition_Version__c);
		System.assertEquals(notificationperference, a.Notification_Per__c);
		System.assertEquals(referrerAccount.Id, a.Referral__c);
		System.assertEquals(null, a.Referral_Email__c);
		System.assertEquals(1, a.Opportunities.size());

		// Check the opportunity looks correct
		
		Opportunity o = [
			SELECT Id, Opportunity_Name_Template__c, StageName, CloseDate, Campaign.Name,
			(
				SELECT Id, PricebookEntry.Name, Quantity FROM OpportunityLineItems
			)
			FROM Opportunity
			WHERE Id = :a.Opportunities[0].Id
		];

		System.assertEquals(Hapara_MessageQueue_Handler.OPPORTUNITY_NAME_TEMPLATE, o.Opportunity_Name_Template__c);
		System.assertEquals(Hapara_MessageQueue_Handler.OPPORTUNITY_STAGE_PROSPECTING, o.StageName);
		System.assertEquals(Date.today().addDays(Hapara_MessageQueue_Handler.OPPORTUNITY_CLOSE_DATE_INTERVAL), o.CloseDate);
		System.assertEquals(1, o.OpportunityLineItems.size());
		System.assertEquals('Teacher Dashboard Innovator', o.OpportunityLineItems[0].PricebookEntry.Name);
		System.assertEquals(1, o.OpportunityLineItems[0].Quantity);
	}

//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\

	static testmethod void signedUp_campaignNotExists() {
		
		String email = 'uniquetest.email@hapara.com.test';
		String fullname = 'Test User';
		String startdate = '2013-06-24T00:00:00';
		String trialenddate = '2013-07-24T00:00:00';
		String referrer = 'TDI-TEST-2013';
		Integer tcversion = 1;
		String notificationperference = 'PROD';

		String json = '{"startdate": "'+startdate+'", "referrer": "'+referrer+'", "notificationperference": "'+notificationperference+'", "tcversion": '+tcversion+', "trialenddate": "'+trialenddate+'", "fullname": "'+fullname+'", "email": "'+email+'"}';

		MessageQueue__c signedUpMessage = new MessageQueue__c(
			ApplicationName__c = 'TDI',
			MessageType__c = Hapara_MessageQueue_Handler.MESSAGE_TYPE_SIGNEDUP,
			Status__c = Hapara_MessageQueue_Handler.MESSAGE_STATUS_NEW,
			OriginMsgId__c = generateGUID(),
			MessageContent__c = json
		);

		Test.startTest();
		insert signedUpMessage;
		Test.stopTest();

		signedUpMessage = [
			SELECT Id, Status__c, ErrorMessage__c, DateCompleted__c
			FROM MessageQueue__c
			WHERE Id = :signedUpMessage.Id
		];

		System.assertEquals(null, signedUpMessage.ErrorMessage__c);
		System.assertEquals(Hapara_MessageQueue_Handler.MESSAGE_STATUS_COMPLETED, signedUpMessage.Status__c);
		System.assertNotEquals(null, signedUpMessage.DateCompleted__c);

		// Check campaign created
		Campaign c = [
			SELECT Id, Parent.Name FROM Campaign WHERE Name = :referrer
		];
		system.assertEquals('Teacher Dashboard Innovator', c.Parent.Name);

		// Check that the account looks correct

		Account a = [
			SELECT Id, PersonContactId, FirstName, LastName, PersonEmail, Type, TD_Setup_Date__c, Trial_End_Date__c, Term_and_Condition_Version__c, Notification_Per__c, Referral_Email__c, Referral__c,
			(
				SELECT Id FROM Opportunities WHERE Opportunity_Name_Template__c = :Hapara_MessageQueue_Handler.OPPORTUNITY_NAME_TEMPLATE
			)
			FROM Account
			WHERE PersonEmail = :email
		];

		System.assertEquals(null, a.FirstName);
		System.assertEquals(fullname, a.LastName);
		System.assertEquals(email, a.PersonEmail);
		System.assertEquals(Hapara_MessageQueue_Handler.ACCOUNT_TYPE_PROSPECT_OF_INNOVATOR, a.Type);
		System.assertEquals(Date.valueOf(startdate), a.TD_Setup_Date__c);
		System.assertEquals(Date.valueOf(trialenddate), a.Trial_End_Date__c);
		System.assertEquals(tcversion, a.Term_and_Condition_Version__c);
		System.assertEquals(notificationperference, a.Notification_Per__c);
		System.assertEquals(null, a.Referral__c);
		System.assertEquals(null, a.Referral_Email__c);
		System.assertEquals(1, a.Opportunities.size());

		// Check the opportunity looks correct
		
		Opportunity o = [
			SELECT Id, Opportunity_Name_Template__c, StageName, CloseDate, Campaign.Name, CampaignId,
			(
				SELECT Id, PricebookEntry.Name, Quantity FROM OpportunityLineItems
			)
			FROM Opportunity
			WHERE Id = :a.Opportunities[0].Id
		];

		System.assertEquals(Hapara_MessageQueue_Handler.OPPORTUNITY_NAME_TEMPLATE, o.Opportunity_Name_Template__c);
		System.assertEquals(Hapara_MessageQueue_Handler.OPPORTUNITY_STAGE_PROSPECTING, o.StageName);
		System.assertEquals(Date.today().addDays(Hapara_MessageQueue_Handler.OPPORTUNITY_CLOSE_DATE_INTERVAL), o.CloseDate);
		System.assertEquals(referrer, o.Campaign.Name);
		System.assertEquals(c.Id, o.CampaignId);
		System.assertEquals(1, o.OpportunityLineItems.size());
		System.assertEquals('Teacher Dashboard Innovator', o.OpportunityLineItems[0].PricebookEntry.Name);
		System.assertEquals(1, o.OpportunityLineItems[0].Quantity);

		// Check campaign membership
		List<CampaignMember> campaignMemberships = [
			SELECT Id 
			FROM CampaignMember 
			WHERE CampaignId = :c.ID
			AND ContactId = :a.PersonContactId
		];
		System.assertEquals(1, campaignMemberships.size());
	}

//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\

	static testmethod void signedUp_campaignExists() {

		Campaign c = new Campaign(Name = 'TDI-TEST-2013');
		insert c;
		
		String email = 'uniquetest.email@hapara.com.test';
		String fullname = 'Test User';
		String startdate = '2013-06-24T00:00:00';
		String trialenddate = '2013-07-24T00:00:00';
		String referrer = 'TDI-TEST-2013';
		Integer tcversion = 1;
		String notificationperference = 'PROD';

		String json = '{"startdate": "'+startdate+'", "referrer": "'+referrer+'", "notificationperference": "'+notificationperference+'", "tcversion": '+tcversion+', "trialenddate": "'+trialenddate+'", "fullname": "'+fullname+'", "email": "'+email+'"}';

		MessageQueue__c signedUpMessage = new MessageQueue__c(
			ApplicationName__c = 'TDI',
			MessageType__c = Hapara_MessageQueue_Handler.MESSAGE_TYPE_SIGNEDUP,
			Status__c = Hapara_MessageQueue_Handler.MESSAGE_STATUS_NEW,
			OriginMsgId__c = generateGUID(),
			MessageContent__c = json
		);

		Test.startTest();
		insert signedUpMessage;
		Test.stopTest();

		signedUpMessage = [
			SELECT Id, Status__c, ErrorMessage__c, DateCompleted__c
			FROM MessageQueue__c
			WHERE Id = :signedUpMessage.Id
		];

		System.assertEquals(null, signedUpMessage.ErrorMessage__c);
		System.assertEquals(Hapara_MessageQueue_Handler.MESSAGE_STATUS_COMPLETED, signedUpMessage.Status__c);
		System.assertNotEquals(null, signedUpMessage.DateCompleted__c);

		// Check that the account looks correct
		Account a = [
			SELECT Id, PersonContactId, FirstName, LastName, PersonEmail, Type, TD_Setup_Date__c, Trial_End_Date__c, Term_and_Condition_Version__c, Notification_Per__c, Referral_Email__c, Referral__c,
			(
				SELECT Id FROM Opportunities WHERE Opportunity_Name_Template__c = :Hapara_MessageQueue_Handler.OPPORTUNITY_NAME_TEMPLATE
			)
			FROM Account
			WHERE PersonEmail = :email
		];
		System.assertEquals(null, a.FirstName);
		System.assertEquals(fullname, a.LastName);
		System.assertEquals(email, a.PersonEmail);
		System.assertEquals(Hapara_MessageQueue_Handler.ACCOUNT_TYPE_PROSPECT_OF_INNOVATOR, a.Type);
		System.assertEquals(Date.valueOf(startdate), a.TD_Setup_Date__c);
		System.assertEquals(Date.valueOf(trialenddate), a.Trial_End_Date__c);
		System.assertEquals(tcversion, a.Term_and_Condition_Version__c);
		System.assertEquals(notificationperference, a.Notification_Per__c);
		System.assertEquals(null, a.Referral__c);
		System.assertEquals(null, a.Referral_Email__c);
		System.assertEquals(1, a.Opportunities.size());

		// Check the opportunity looks correct
		Opportunity o = [
			SELECT Id, Opportunity_Name_Template__c, StageName, CloseDate, Campaign.Name, CampaignId,
			(
				SELECT Id, PricebookEntry.Name, Quantity FROM OpportunityLineItems
			)
			FROM Opportunity
			WHERE Id = :a.Opportunities[0].Id
		];

		System.assertEquals(Hapara_MessageQueue_Handler.OPPORTUNITY_NAME_TEMPLATE, o.Opportunity_Name_Template__c);
		System.assertEquals(Hapara_MessageQueue_Handler.OPPORTUNITY_STAGE_PROSPECTING, o.StageName);
		System.assertEquals(Date.today().addDays(Hapara_MessageQueue_Handler.OPPORTUNITY_CLOSE_DATE_INTERVAL), o.CloseDate);
		System.assertEquals(referrer, o.Campaign.Name);
		System.assertEquals(c.Id, o.CampaignId);
		System.assertEquals(1, o.OpportunityLineItems.size());
		System.assertEquals('Teacher Dashboard Innovator', o.OpportunityLineItems[0].PricebookEntry.Name);
		System.assertEquals(1, o.OpportunityLineItems[0].Quantity);

		// Check campaign membership
		List<CampaignMember> campaignMemberships = [
			SELECT Id 
			FROM CampaignMember 
			WHERE CampaignId = :c.ID
			AND ContactId = :a.PersonContactId
		];
		System.assertEquals(1, campaignMemberships.size());
	}

//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\

	static testmethod void updateInfo_dry() {
		
		String city = 'BEVERLY HILLS';
		String school = 'HAWTHORNE ELEMENTARY';
		String district = 'BEVERLY HILLS UNIFIED';
		String country = 'US';
		String state = 'CA';
		String zipcode = '90210';
		String email = 'uniquetest.email@hapara.com.test';

		String json = '{"city": "'+city+'", "school": "'+school+'", "district": "'+district+'", "country": "'+country+'", "state": "'+state+'", "zipcode": "'+zipcode+'", "email": "'+email+'"}';

		MessageQueue__c updateInfoMessage = new MessageQueue__c(
			ApplicationName__c = 'TDI',
			MessageType__c = Hapara_MessageQueue_Handler.MESSAGE_TYPE_UPDATEINFO,
			Status__c = Hapara_MessageQueue_Handler.MESSAGE_STATUS_NEW,
			OriginMsgId__c = generateGUID(),
			MessageContent__c = json
		);

		Test.startTest();
		insert updateInfoMessage;
		Test.stopTest();

		updateInfoMessage = [
			SELECT Id, Status__c, ErrorMessage__c, DateCompleted__c
			FROM MessageQueue__c
			WHERE Id = :updateInfoMessage.Id
		];

		System.assertNotEquals(null, updateInfoMessage.ErrorMessage__c);
		System.assertEquals(Hapara_MessageQueue_Handler.MESSAGE_STATUS_ERRORED, updateInfoMessage.Status__c);
		System.assertEquals(null, updateInfoMessage.DateCompleted__c);
	}

//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\

	static testmethod void updateInfo_accountExists() {
		
		{
			String email = 'uniquetest.email@hapara.com.test';
			String fullname = 'Test User';
			String startdate = '2013-06-24T00:00:00';
			String trialenddate = '2013-07-24T00:00:00';
			String referrer = 'TDI-TEST-2013';
			Integer tcversion = 1;
			String notificationperference = 'PROD';

			String json = '{"startdate": "'+startdate+'", "referrer": "'+referrer+'", "notificationperference": "'+notificationperference
				+'", "tcversion": '+tcversion+', "trialenddate": "'+trialenddate+'", "fullname": "'+fullname+'", "email": "'+email+'"}';

			MessageQueue__c signedUpMessage = new MessageQueue__c(
				ApplicationName__c = 'TDI',
				MessageType__c = Hapara_MessageQueue_Handler.MESSAGE_TYPE_SIGNEDUP,
				Status__c = Hapara_MessageQueue_Handler.MESSAGE_STATUS_ERRORED,
				OriginMsgId__c = generateGUID(),
				MessageContent__c = json
			);

			insert signedUpMessage;
			Hapara_MessageQueue_Handler.process(signedUpMessage.Id);
		}

		String city = 'BEVERLY HILLS';
		String school = 'HAWTHORNE ELEMENTARY';
		String district = 'BEVERLY HILLS UNIFIED';
		String country = 'United States';
		String state = 'California';
		String zipcode = '90210';
		String email = 'uniquetest.email@hapara.com.test';

		String json = '{"city": "'+city+'", "school": "'+school+'", "district": "'+district+'", "country": "'+country+'", "state": "'+state+'", "zipcode": "'+zipcode+'", "email": "'+email+'"}';

		MessageQueue__c updateInfoMessage = new MessageQueue__c(
			ApplicationName__c = 'TDI',
			MessageType__c = Hapara_MessageQueue_Handler.MESSAGE_TYPE_UPDATEINFO,
			Status__c = Hapara_MessageQueue_Handler.MESSAGE_STATUS_NEW,
			OriginMsgId__c = generateGUID(),
			MessageContent__c = json
		);

		Test.startTest();
		insert updateInfoMessage;
		Test.stopTest();

		updateInfoMessage = [
			SELECT Id, Status__c, ErrorMessage__c, DateCompleted__c
			FROM MessageQueue__c
			WHERE Id = :updateInfoMessage.Id
		];

		System.assertEquals(null, updateInfoMessage.ErrorMessage__c);
		System.assertEquals(Hapara_MessageQueue_Handler.MESSAGE_STATUS_COMPLETED, updateInfoMessage.Status__c);
		System.assertNotEquals(null, updateInfoMessage.DateCompleted__c);

		// Check that the account looks correct
	}

//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\

	static testmethod void updatePaymentDetails_userNotExists() {

		String paymentdate = '2013-07-27T00:00:00';
		String paymentamount = '3022';
		String paymentplan = 'Yearly';
		String firstname = 'Claudia';
		String lastname = 'Constantine';
		String country = 'United States';
		String address1 = 'street1';
		String address2 = 'street2';
		String city = 'New York City';
		String state = 'NY';
		String zipcode = '0998';
		String email = 'uniquetest.email@hapara.com.test';
		String bill_country = 'New Zealand';
		String bill_address1 = 'stonefield';
		String bill_address2 = 'stonefield';
		String bill_city = 'Stonefield';
		String bill_state = 'Auckland';
		String bill_zipcode = '0998';

		String json = '{"paymentdate": "'+paymentdate+'", "paymentamount": "'+paymentamount+'", "paymentplan": "'+paymentplan
			+'", "firstname": "'+firstname+'", "lastname": "'+lastname+'", "country": "'+country+'", "address1": "'+address1
			+'", "address2": "'+address2+'", "city": "'+city+'", "state": "'+state+'", "zipcode": "'+zipcode+'", "bill_country": "'
			+bill_country+'", "bill_address1": "'+bill_address1+'", "bill_address2": "'+bill_address2+'", "bill_city": "'+bill_city
			+'", "bill_state": "'+bill_state+'", "bill_zipcode": "'+bill_zipcode+'", "email": "'+email+'"}';

		MessageQueue__c updatePaymentDetailsMessage = new MessageQueue__c(
			ApplicationName__c = 'TDI',
			MessageType__c = Hapara_MessageQueue_Handler.MESSAGE_TYPE_UPDATEPAYMENTDETAILS,
			Status__c = Hapara_MessageQueue_Handler.MESSAGE_STATUS_NEW,
			OriginMsgId__c = generateGUID(),
			MessageContent__c = json
		);

		Test.startTest();
		insert updatePaymentDetailsMessage;
		Test.stopTest();

		updatePaymentDetailsMessage = [
			SELECT Id, Status__c, ErrorMessage__c, DateCompleted__c
			FROM MessageQueue__c
			WHERE Id = :updatePaymentDetailsMessage.Id
		];

		System.assertNotEquals(null, updatePaymentDetailsMessage.ErrorMessage__c);
		System.assertEquals(Hapara_MessageQueue_Handler.MESSAGE_STATUS_ERRORED, updatePaymentDetailsMessage.Status__c);
		System.assertEquals(null, updatePaymentDetailsMessage.DateCompleted__c);
	}

//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\

	static testmethod void updatePaymentDetails_userExists() {
		
		MessageQueue__c signedUpMessage = null;
		{
			String email = 'uniquetest.email@hapara.com.test';
			String fullname = 'Test User';
			String startdate = '2013-06-24T00:00:00';
			String trialenddate = '2013-07-24T00:00:00';
			String referrer = 'TDI-TEST-2013';
			Integer tcversion = 1;
			String notificationperference = 'PROD';

			String json = '{"startdate": "'+startdate+'", "referrer": "'+referrer+'", "notificationperference": "'+notificationperference+'", "tcversion": '+tcversion+', "trialenddate": "'+trialenddate+'", "fullname": "'+fullname+'", "email": "'+email+'"}';

			signedUpMessage = new MessageQueue__c(
				ApplicationName__c = 'TDI',
				MessageType__c = Hapara_MessageQueue_Handler.MESSAGE_TYPE_SIGNEDUP,
				Status__c = Hapara_MessageQueue_Handler.MESSAGE_STATUS_ERRORED,
				OriginMsgId__c = generateGUID(),
				MessageContent__c = json
			);
			insert signedUpMessage;

			Hapara_MessageQueue_Handler.process(signedUpMessage.Id);
		}

		String paymentdate = '2013-07-27T00:00:00';
		String paymentamount = '3022';
		String paymentplan = 'Yearly';
		String firstname = 'Claudia';
		String lastname = 'Constantine';
		String country = 'United States';
		String address1 = 'street1';
		String address2 = 'street2';
		String city = 'New York City';
		String state = 'New York';
		String zipcode = '0998';
		String email = 'uniquetest.email@hapara.com.test';
		String bill_country = 'New Zealand';
		String bill_address1 = 'stonefield';
		String bill_address2 = '';
		String bill_city = 'Stonefield';
		String bill_state = 'Auckland';
		String bill_zipcode = '0998';

		String json = '{"paymentdate": "'+paymentdate+'", "paymentamount": "'+paymentamount+'", "paymentplan": "'+paymentplan
			+'", "firstname": "'+firstname+'", "lastname": "'+lastname+'", "country": "'+country+'", "address1": "'+address1
			+'", "address2": "'+address2+'", "city": "'+city+'", "state": "'+state+'", "zipcode": "'+zipcode+'", "bill_country": "'
			+bill_country+'", "bill_address1": "'+bill_address1+'", "bill_address2": "'+bill_address2+'", "bill_city": "'+bill_city
			+'", "bill_state": "'+bill_state+'", "bill_zipcode": "'+bill_zipcode+'", "email": "'+email+'"}';

		MessageQueue__c updatePaymentDetailsMessage = new MessageQueue__c(
			ApplicationName__c = 'TDI',
			MessageType__c = Hapara_MessageQueue_Handler.MESSAGE_TYPE_UPDATEPAYMENTDETAILS,
			Status__c = Hapara_MessageQueue_Handler.MESSAGE_STATUS_NEW,
			OriginMsgId__c = generateGUID(),
			MessageContent__c = json
		);

		Test.startTest();
		insert updatePaymentDetailsMessage;
		Test.stopTest();

		updatePaymentDetailsMessage = [
			SELECT Id, Status__c, ErrorMessage__c, DateCompleted__c
			FROM MessageQueue__c
			WHERE Id = :updatePaymentDetailsMessage.Id
		];
		system.debug('***updatePaymentDetails_userExists - ' +updatePaymentDetailsMessage.ErrorMessage__c );
		System.assertEquals(null, updatePaymentDetailsMessage.ErrorMessage__c);
		System.assertEquals(Hapara_MessageQueue_Handler.MESSAGE_STATUS_COMPLETED, updatePaymentDetailsMessage.Status__c);
		System.assertNotEquals(null, updatePaymentDetailsMessage.DateCompleted__c);

		// Check that the account looks correct
		Account a = [
			SELECT Id, FirstName, LastName, PersonEmail, Type, Invoice_Period__c, ShippingCountry, ShippingStreet, ShippingCity, ShippingState,
			ShippingPostalCode, BillingCountry, BillingStreet, BillingCity, BillingState, BillingPostalCode, Payment_Date__c, TD_Invoiced_Date__c, 
			(
				SELECT Id, StageName, CloseDate FROM Opportunities WHERE Opportunity_Name_Template__c = :Hapara_MessageQueue_Handler.OPPORTUNITY_NAME_TEMPLATE
			),
			(
				SELECT Id,  Description__c,Invoice_Date__c, Invoice_No__c, Product__r.Name, Quantity__c, Unit_Price__c FROM Account_Product__r
				
			)
			FROM Account
			WHERE PersonEmail = :email
		];
		System.assertEquals(Hapara_MessageQueue_Handler.ACCOUNT_TYPE_CUSTOMER_OF_INNOVATOR, a.Type);
		System.assertEquals(paymentplan, a.Invoice_Period__c);
		System.assertEquals(firstname, a.FirstName);
		System.assertEquals(lastname, a.LastName);
		System.assertEquals(country, a.ShippingCountry);
		System.assertEquals(address1 + (address2 == null || address2 == '' ? '' : '\n' + address2), a.ShippingStreet);
		System.assertEquals(city, a.ShippingCity);
		System.assertEquals(state, a.ShippingState );
		System.assertEquals(zipcode, a.ShippingPostalCode);
		System.assertEquals(bill_country, a.BillingCountry);
		System.assertEquals(bill_address1 + (bill_address2 == null || bill_address2 == '' ? '' : '\n' + bill_address2), a.BillingStreet);
		System.assertEquals(bill_city, a.BillingCity);
		System.assertEquals(bill_state, a.BillingState);
		System.assertEquals(bill_zipcode, a.BillingPostalCode);
		System.assertEquals(Date.valueOf(paymentdate), a.Payment_Date__c);
		System.assertEquals(Date.valueOf(paymentdate), a.TD_Invoiced_Date__c);

		// Check account product created
		System.assertEquals(1, a.Account_Product__r.size());
		System.assertEquals(paymentplan, a.Account_Product__r[0].Description__c);
		System.assertEquals(Date.valueOf(paymentdate), a.Account_Product__r[0].Invoice_Date__c);
		System.assertEquals('TDI', a.Account_Product__r[0].Invoice_No__c);
		System.assertEquals(Hapara_MessageQueue_Handler.TDI_PRODUCT_NAME, a.Account_Product__r[0].Product__r.Name);
		System.assertEquals(1, a.Account_Product__r[0].Quantity__c);
		System.assertEquals(Decimal.valueOf(paymentamount) / 100, a.Account_Product__r[0].Unit_Price__c);

		// Check the Opportunity
		System.assertEquals(1, a.Opportunities.size());
		System.assertEquals(Hapara_MessageQueue_Handler.OPPORTUNITY_STAGE_CLOSED_WON, a.Opportunities[0].StageName);
		System.assertEquals(Date.valueOf(paymentdate), a.Opportunities[0].CloseDate);
	}

//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\

	static testmethod void noPaymentMade_userExists_noOpportunity() {
		
		RecordType personAccountRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = :Hapara_MessageQueue_Handler.PERSON_ACCOUNT_RECORDTYPE];
		Account referrerAccount = new Account(FirstName = 'The', LastName = 'User', PersonEmail = 'test.user@hapara.com.test', RecordTypeId = personAccountRT.Id);
		insert referrerAccount;

		MessageQueue__c noPaymentMadeMessage = new MessageQueue__c(
			ApplicationName__c = 'TDI',
			MessageType__c = Hapara_MessageQueue_Handler.MESSAGE_TYPE_NOPAYMENTMADE,
			Status__c = Hapara_MessageQueue_Handler.MESSAGE_STATUS_NEW,
			OriginMsgId__c = generateGUID(),
			MessageContent__c = '{"email": "test.user@hapara.com.test"}'
		);

		Test.startTest();
		insert noPaymentMadeMessage;
		Test.stopTest();

		noPaymentMadeMessage = [
			SELECT Id, Status__c, ErrorMessage__c, DateCompleted__c
			FROM MessageQueue__c
			WHERE Id = :noPaymentMadeMessage.Id
		];

		System.assertNotEquals(null, noPaymentMadeMessage.ErrorMessage__c);
		System.assertEquals(Hapara_MessageQueue_Handler.MESSAGE_STATUS_ERRORED, noPaymentMadeMessage.Status__c);
		System.assertEquals(null, noPaymentMadeMessage.DateCompleted__c);
	}

//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\

	static testmethod void noPaymentMade_userExists_prospect() {
		
		MessageQueue__c signedUpMessage = null;
		{
			String email = 'uniquetest.email@hapara.com.test';
			String fullname = 'Test User';
			String startdate = '2013-06-24T00:00:00';
			String trialenddate = '2013-07-24T00:00:00';
			String referrer = 'TDI-TEST-2013';
			Integer tcversion = 1;
			String notificationperference = 'PROD';

			String json = '{"startdate": "'+startdate+'", "referrer": "'+referrer+'", "notificationperference": "'+notificationperference+'", "tcversion": '+tcversion+', "trialenddate": "'+trialenddate+'", "fullname": "'+fullname+'", "email": "'+email+'"}';

			signedUpMessage = new MessageQueue__c(
				ApplicationName__c = 'TDI',
				MessageType__c = Hapara_MessageQueue_Handler.MESSAGE_TYPE_SIGNEDUP,
				Status__c = Hapara_MessageQueue_Handler.MESSAGE_STATUS_ERRORED,
				OriginMsgId__c = generateGUID(),
				MessageContent__c = json
			);
			insert signedUpMessage;

			Hapara_MessageQueue_Handler.process(signedUpMessage.Id);
		}

		MessageQueue__c noPaymentMadeMessage = new MessageQueue__c(
			ApplicationName__c = 'TDI',
			MessageType__c = Hapara_MessageQueue_Handler.MESSAGE_TYPE_NOPAYMENTMADE,
			Status__c = Hapara_MessageQueue_Handler.MESSAGE_STATUS_NEW,
			OriginMsgId__c = generateGUID(),
			MessageContent__c = '{"email": "uniquetest.email@hapara.com.test"}'
		);

		Test.startTest();
		insert noPaymentMadeMessage;
		Test.stopTest();

		noPaymentMadeMessage = [
			SELECT Id, Status__c, ErrorMessage__c, DateCompleted__c
			FROM MessageQueue__c
			WHERE Id = :noPaymentMadeMessage.Id
		];

		System.assertEquals(null, noPaymentMadeMessage.ErrorMessage__c);
		System.assertEquals(Hapara_MessageQueue_Handler.MESSAGE_STATUS_COMPLETED, noPaymentMadeMessage.Status__c);
		System.assertNotEquals(null, noPaymentMadeMessage.DateCompleted__c);

		// Check the account
		Account a = [
			SELECT Id, Type,
			(
				SELECT Id, StageName FROM Opportunities WHERE Opportunity_Name_Template__c = :Hapara_MessageQueue_Handler.OPPORTUNITY_NAME_TEMPLATE
			)
			FROM Account
			WHERE PersonEmail = 'uniquetest.email@hapara.com.test'
		];
		System.assertEquals(Hapara_MessageQueue_Handler.ACCOUNT_TYPE_PROSPECT_COLD_OF_INNOVATOR, a.Type);
		System.assertEquals(1, a.Opportunities.size());
		System.assertEquals(Hapara_MessageQueue_Handler.OPPORTUNITY_STAGE_PROSPECTING, a.Opportunities[0].StageName);
	}

//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\

	static testmethod void noPaymentMade_userExists_customer() {
		
		MessageQueue__c signedUpMessage = null;
		{
			String email = 'uniquetest.email@hapara.com.test';
			String fullname = 'Test User';
			String startdate = '2013-06-24T00:00:00';
			String trialenddate = '2013-07-24T00:00:00';
			String referrer = 'TDI-TEST-2013';
			Integer tcversion = 1;
			String notificationperference = 'PROD';

			String json = '{"startdate": "'+startdate+'", "referrer": "'+referrer+'", "notificationperference": "'+notificationperference+'", "tcversion": '+tcversion+', "trialenddate": "'+trialenddate+'", "fullname": "'+fullname+'", "email": "'+email+'"}';

			signedUpMessage = new MessageQueue__c(
				ApplicationName__c = 'TDI',
				MessageType__c = Hapara_MessageQueue_Handler.MESSAGE_TYPE_SIGNEDUP,
				Status__c = Hapara_MessageQueue_Handler.MESSAGE_STATUS_ERRORED,
				OriginMsgId__c = generateGUID(),
				MessageContent__c = json
			);
			insert signedUpMessage;

			Hapara_MessageQueue_Handler.process(signedUpMessage.Id);
		}

		Account a = [SELECT Id, Type FROM Account WHERE PersonEmail = 'uniquetest.email@hapara.com.test'];
		a.Type = Hapara_MessageQueue_Handler.ACCOUNT_TYPE_CUSTOMER_OF_INNOVATOR;
		update a;

		MessageQueue__c noPaymentMadeMessage = new MessageQueue__c(
			ApplicationName__c = 'TDI',
			MessageType__c = Hapara_MessageQueue_Handler.MESSAGE_TYPE_NOPAYMENTMADE,
			Status__c = Hapara_MessageQueue_Handler.MESSAGE_STATUS_NEW,
			OriginMsgId__c = generateGUID(),
			MessageContent__c = '{"email": "uniquetest.email@hapara.com.test"}'
		);

		Test.startTest();
		insert noPaymentMadeMessage;
		Test.stopTest();

		noPaymentMadeMessage = [
			SELECT Id, Status__c, ErrorMessage__c, DateCompleted__c
			FROM MessageQueue__c
			WHERE Id = :noPaymentMadeMessage.Id
		];

		System.assertEquals(null, noPaymentMadeMessage.ErrorMessage__c);
		System.assertEquals(Hapara_MessageQueue_Handler.MESSAGE_STATUS_COMPLETED, noPaymentMadeMessage.Status__c);
		System.assertNotEquals(null, noPaymentMadeMessage.DateCompleted__c);

		// Check the account
		a = [
			SELECT Id, Type,
			(
				SELECT Id, StageName FROM Opportunities WHERE Opportunity_Name_Template__c = :Hapara_MessageQueue_Handler.OPPORTUNITY_NAME_TEMPLATE
			)
			FROM Account
			WHERE Id = :a.Id
		];
		System.assertEquals(Hapara_MessageQueue_Handler.ACCOUNT_TYPE_CUSTOMER_COLD_OF_INNOVATOR, a.Type);
		System.assertEquals(1, a.Opportunities.size());
		System.assertEquals(Hapara_MessageQueue_Handler.OPPORTUNITY_STAGE_PROSPECTING, a.Opportunities[0].StageName);
	}

//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\

	static testmethod void noPaymentMade_userNotExists() {

		MessageQueue__c noPaymentMadeMessage = new MessageQueue__c(
			ApplicationName__c = 'TDI',
			MessageType__c = Hapara_MessageQueue_Handler.MESSAGE_TYPE_NOPAYMENTMADE,
			Status__c = Hapara_MessageQueue_Handler.MESSAGE_STATUS_NEW,
			OriginMsgId__c = generateGUID(),
			MessageContent__c = '{"email": "uniquetest.email@hapara.com.test"}'
		);

		Test.startTest();
		insert noPaymentMadeMessage;
		Test.stopTest();

		noPaymentMadeMessage = [
			SELECT Id, Status__c, ErrorMessage__c, DateCompleted__c
			FROM MessageQueue__c
			WHERE Id = :noPaymentMadeMessage.Id
		];

		System.assertNotEquals(null, noPaymentMadeMessage.ErrorMessage__c);
		System.assertEquals(Hapara_MessageQueue_Handler.MESSAGE_STATUS_ERRORED, noPaymentMadeMessage.Status__c);
		System.assertEquals(null, noPaymentMadeMessage.DateCompleted__c);
	}

//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\

	static testmethod void bulkMessages() {
		// Test what happens when 2 or more messages are received
		
		List<MessageQueue__c> messages = new List<MessageQueue__c>{
			new MessageQueue__c(
				ApplicationName__c = 'TDI',
				MessageType__c = Hapara_MessageQueue_Handler.MESSAGE_TYPE_SIGNEDUP,
				Status__c = Hapara_MessageQueue_Handler.MESSAGE_STATUS_NEW,
				OriginMsgId__c = generateGUID()
			),
			new MessageQueue__c(
				ApplicationName__c = 'TDI',
				MessageType__c = Hapara_MessageQueue_Handler.MESSAGE_TYPE_SIGNEDUP,
				Status__c = Hapara_MessageQueue_Handler.MESSAGE_STATUS_NEW,
				OriginMsgId__c = generateGUID()
			)
		};

		Test.startTest();
		insert messages;
		Test.stopTest();

		messages = [
			SELECT Id, Status__c, ErrorMessage__c, DateCompleted__c
			FROM MessageQueue__c
			WHERE Id = :messages[0].Id
			OR Id = :messages[1].Id
		];

		System.assertEquals('Hapara_MessageQueue_Handler does not support bulk operations.', messages[0].ErrorMessage__c);
		System.assertEquals('Hapara_MessageQueue_Handler does not support bulk operations.', messages[1].ErrorMessage__c);
		System.assertEquals(Hapara_MessageQueue_Handler.MESSAGE_STATUS_ERRORED, messages[0].Status__c);
		System.assertEquals(Hapara_MessageQueue_Handler.MESSAGE_STATUS_ERRORED, messages[1].Status__c);
		System.assertEquals(null, messages[0].DateCompleted__c);
		System.assertEquals(null, messages[1].DateCompleted__c);
	}

//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\

	static testmethod void completedMessage() {
		// Test what happens when a message with the status Compeleted is received
		
		MessageQueue__c message = new MessageQueue__c(
			ApplicationName__c = 'TDI',
			MessageType__c = Hapara_MessageQueue_Handler.MESSAGE_TYPE_NOPAYMENTMADE,
			Status__c = Hapara_MessageQueue_Handler.MESSAGE_STATUS_COMPLETED,
			MessageContent__c = '{"email": "uniquetest.user@hapara.com.test"}',
			OriginMsgId__c = generateGUID()
		);
		insert message;

		message = [
			SELECT Id, Status__c, ErrorMessage__c, DateCompleted__c
			FROM MessageQueue__c
			WHERE Id = :message.Id
		];

		System.assertEquals(Hapara_MessageQueue_Handler.MESSAGE_STATUS_COMPLETED, message.Status__c);
		System.assertEquals(null , message.ErrorMessage__c);

		Test.startTest();
		Hapara_MessageQueue_Handler.process(message.Id);
		Test.stopTest();

		message = [
			SELECT Id, Status__c, ErrorMessage__c, DateCompleted__c
			FROM MessageQueue__c
			WHERE Id = :message.Id
		];

		System.assertEquals(Hapara_MessageQueue_Handler.MESSAGE_STATUS_COMPLETED, message.Status__c);
		System.assertEquals('Message already completed', message.ErrorMessage__c);
	}

//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\

	static testmethod void invalidMessageType() {
		// Test what happens when a message is received with a message type that isn't understood

		MessageQueue__c noPaymentMadeMessage = new MessageQueue__c(
			ApplicationName__c = 'TDI',
			MessageType__c = 'InvalidType',
			Status__c = Hapara_MessageQueue_Handler.MESSAGE_STATUS_NEW,
			OriginMsgId__c = generateGUID()
		);

		Test.startTest();
		insert noPaymentMadeMessage;
		Test.stopTest();

		noPaymentMadeMessage = [
			SELECT Id, Status__c, ErrorMessage__c, DateCompleted__c
			FROM MessageQueue__c
			WHERE Id = :noPaymentMadeMessage.Id
		];

		System.assertNotEquals(null, noPaymentMadeMessage.ErrorMessage__c);
		System.assertEquals(Hapara_MessageQueue_Handler.MESSAGE_STATUS_ERRORED, noPaymentMadeMessage.Status__c);
		System.assertEquals(null, noPaymentMadeMessage.DateCompleted__c);
	}

//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\

	//static testmethod void duplicateOriginId() {
		// Test what happens when a message is received, and there's already another message with the same origin id

	//	String email = 'uniquetest.email@hapara.com.test';
	///	String fullname = 'Test User';
	//	String startdate = '2013-06-24T00:00:00';
	//	String trialenddate = '2013-07-24T00:00:00';
	//	String referrer = 'uniquetest.referrer@hapara.com.test';
	//	Integer tcversion = 1;
	//	String notificationperference = 'PROD';

	//	String json = '{"startdate": "'+startdate+'", "referrer": "'+referrer+'", "notificationperference": "'+notificationperference+'", "tcversion": '+tcversion+', "trialenddate": "'+trialenddate+'", "fullname": "'+fullname+'", "email": "'+email+'"}';

	//	MessageQueue__c signedUpMessage1 = new MessageQueue__c(
	//		ApplicationName__c = 'TDI',
	//		MessageType__c = Hapara_MessageQueue_Handler.MESSAGE_TYPE_SIGNEDUP,
	//		Status__c = Hapara_MessageQueue_Handler.MESSAGE_STATUS_COMPLETED,
	//		OriginMsgId__c = generateGUID(),
	//		MessageContent__c = json
	//	);
	//	insert signedUpMessage1;

	//	MessageQueue__c signedUpMessage = new MessageQueue__c(
	//		ApplicationName__c = 'TDI',
	//		MessageType__c = Hapara_MessageQueue_Handler.MESSAGE_TYPE_SIGNEDUP,
	//		Status__c = Hapara_MessageQueue_Handler.MESSAGE_STATUS_NEW,
	//		OriginMsgId__c = signedUpMessage1.OriginMsgId__c,
	//		MessageContent__c = json
	//	);

	//	Test.startTest();
	//	insert signedUpMessage;
	//	Test.stopTest();

	//	signedUpMessage = [
	//		SELECT Id, Status__c, ErrorMessage__c, DateCompleted__c
	//		FROM MessageQueue__c
	//		WHERE Id = :signedUpMessage.Id
	//	];

	//	System.assertNotEquals(null, signedUpMessage.ErrorMessage__c);
	//	System.assertEquals(Hapara_MessageQueue_Handler.MESSAGE_STATUS_ERRORED, signedUpMessage.Status__c);
	//	System.assertEquals(null, signedUpMessage.DateCompleted__c);
	//}

//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\

	static testmethod void messageContentClassCoverage() {
		// These don't get coverage from JSON deserialization

		Hapara_MessageQueue_Handler.SignedUpMessage signedUpMessage = new Hapara_MessageQueue_Handler.SignedUpMessage();
		signedUpMessage.email = 't.five@zawadzki.co.nz';
		signedUpMessage.fullname = 'Test User';
		signedUpMessage.startdate = '2013-07-27T00:00:00';
		signedUpMessage.trialenddate = '2013-07-27T00:00:00';
		signedUpMessage.referrer = 'claudia.constantine@ibp.edu.mx';
		signedUpMessage.tcversion = 1;
		signedUpMessage.notificationperference = 'PROD';
		Hapara_MessageQueue_Handler.UpdateInfoMessage updateInfoMessage = new Hapara_MessageQueue_Handler.UpdateInfoMessage();
		updateInfoMessage.city = 'BEVERLY HILLS';
		updateInfoMessage.school = 'HAWTHORNE ELEMENTARY';
		updateInfoMessage.district = 'BEVERLY HILLS UNIFIED';
		updateInfoMessage.country = 'US';
		updateInfoMessage.state = 'CA';
		updateInfoMessage.zipcode = '90210';
		updateInfoMessage.email = 't.five@zawadzki.co.nz';
		Hapara_MessageQueue_Handler.UpdatePaymentDetailsMessage updatePaymentDetailsMessage = new Hapara_MessageQueue_Handler.UpdatePaymentDetailsMessage();
		updatePaymentDetailsMessage.paymentdate = '2013-07-27T00:00:00';
		updatePaymentDetailsMessage.paymentamount = '3022';
		updatePaymentDetailsMessage.paymentplan = 'Yearly';
		updatePaymentDetailsMessage.firstname = 'Claudia';
		updatePaymentDetailsMessage.lastname = 'Constantine';
		updatePaymentDetailsMessage.country = 'United States';
		updatePaymentDetailsMessage.address1 = 'street1';
		updatePaymentDetailsMessage.address2 = 'street2';
		updatePaymentDetailsMessage.city = 'New York City';
		updatePaymentDetailsMessage.state = 'NY';
		updatePaymentDetailsMessage.zipcode = '0998';
		updatePaymentDetailsMessage.email = 'claudia.constantine@ibp.edu.mx';
		updatePaymentDetailsMessage.bill_country = 'New Zealand';
		updatePaymentDetailsMessage.bill_address1 = 'stonefield';
		updatePaymentDetailsMessage.bill_address2 = '';
		updatePaymentDetailsMessage.bill_city = 'Stonefield';
		updatePaymentDetailsMessage.bill_state = 'Auckland';
		updatePaymentDetailsMessage.bill_zipcode = '0998';
		Hapara_MessageQueue_Handler.NoPaymentMadeMessage noPaymentMadeMessage = new Hapara_MessageQueue_Handler.NoPaymentMadeMessage();
		noPaymentMadeMessage.email = 'claudia.constantine@ibp.edu.mx';
	}

//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\

	static testmethod void processButton() {

		String email = 'uniquetest.email@hapara.com.test';
		String fullname = 'Test User';
		String startdate = '2013-06-24T00:00:00';
		String trialenddate = '2013-07-24T00:00:00';
		String referrer = 'TDI-TEST-2013';
		Integer tcversion = 1;
		String notificationperference = 'PROD';

		String json = '{"startdate": "'+startdate+'", "referrer": "'+referrer+'", "notificationperference": "'+notificationperference+'", "tcversion": '+tcversion+', "trialenddate": "'+trialenddate+'", "fullname": "'+fullname+'", "email": "'+email+'"}';

		MessageQueue__c signedUpMessage = new MessageQueue__c(
			ApplicationName__c = 'TDI',
			MessageType__c = Hapara_MessageQueue_Handler.MESSAGE_TYPE_SIGNEDUP,
			Status__c = Hapara_MessageQueue_Handler.MESSAGE_STATUS_ERRORED,
			OriginMsgId__c = generateGUID(),
			MessageContent__c = json
		);
		insert signedUpMessage;

		System.assertEquals(0, [SELECT Id FROM Account WHERE PersonEmail = :email].size());

		ApexPages.StandardController ctl = new ApexPages.StandardController(signedUpMessage);
		Hapara_MessageQueue_ProcessButton ext = new Hapara_MessageQueue_ProcessButton(ctl);
		
		Test.startTest();
		ext.process();
		Test.stopTest();

		System.assertEquals(1, [SELECT Id FROM Account WHERE PersonEmail = :email].size());
	}

	// TESTING UTILITIES
	// These are utilities that are only used by this test method. They therefore do not need to
	// be made available to the rest of salesforce and can remain private/static.

	/** Begin: UUID Generation */

	public static String kHexChars = '0123456789abcdef';

	public static String generateGUID() {

		String returnValue = '';
		Integer nextByte = 0;

		for (Integer i=0; i<16; i++) {

			if (i==4 || i==6 || i==8 || i==10) 
				returnValue += '-';

			nextByte = (Math.round(Math.random() * 255)-128) & 255;

			if (i==6) {
				nextByte = nextByte & 15;
				nextByte = nextByte | (4 << 4);
			}

			if (i==8) {
				nextByte = nextByte & 63;
				nextByte = nextByte | 128;
			}

			returnValue += getCharAtIndex(kHexChars, nextByte >> 4);
			returnValue += getCharAtIndex(kHexChars, nextByte & 15); 
		}

		return returnValue;
	}

	private static String getCharAtIndex(String str, Integer index) {

		if (str == null) return null;

		if (str.length() <= 0) return str;

		if (index == str.length()) return null;

		return str.substring(index, index+1);
	}

	/** Finish: UUID Generation */
}