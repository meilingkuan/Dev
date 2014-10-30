@isTest(SeeAllData=true)
public class  Hapara_SchedulingSetup_Test {
	public static Hapara_Weekly_Scheduling__c testSchedule;
	public static Hapara_Engineer_Scheduled_Times__c testEngineerSchedule1;
	public static Hapara_Engineer_Scheduled_Times__c testEngineerSchedule2;
	public static Hapara_Scheduling_Type__c testSchduleType;
	public static Account testAccount;
	public static Contact testContact;
	
	static testMethod void testHapara_Invite_Controller(){
		//test contact setup invite
		createTestHapara_SchedulingSetupRecords();
		PageReference page = new PageReference('/apex/Hapara_SendInviteContact');
		page.getParameters().put('Id', testContact.Id);
		page.getParameters().put('inviteType','SETUP');
		Test.setCurrentPage(page);
		ApexPages.StandardController controller = new ApexPages.StandardController(testContact);
		Hapara_Invite_Controller contr = new Hapara_Invite_Controller(controller);
		//****************test get method************/
		list<SelectOption> templates = contr.getEmailTemplates();
		list<SelectOption> scheduleTypes = contr.getScheduleTypes();
		system.assert(templates.size()>0);
		system.assert(scheduleTypes.size()>0);
		//****************send setup invite**********/
		contr.selectedEmailTemplate =templates[0].getValue() ;
		contr.selectedScheduleType = scheduleTypes[0].getValue();
		contr.sendInvite();
		contr.sendInvite();
		contr.sendInvite();
		contr.cancel();
		
		//test lead demo invite
		Lead testLead = new Lead();
		testLead.FirstName = 'test';
		testLead.LastName= 'lead';
		testlead.Email = 'testlead@gmail.com';
		testlead.Website = 'domain';
		testLead.Company = 'test school';
		testLead.How_did_you_hear_about_us__c = 'Conference';
		testLead.How_did_you_hear_about_us2__c='Campaign test';
		insert testLead;
		
		page = new PageReference('/apex/Hapara_SendInviteContact');
		page.getParameters().put('Id', testLead.Id);
		page.getParameters().put('inviteType','DEMO'); 
		Test.setCurrentPage(page);
		controller = new ApexPages.StandardController(testContact);
		contr = new Hapara_Invite_Controller(controller);
		//****************test get method************/
		templates = contr.getEmailTemplates();
		system.assert(templates.size()>0);
		//****************send setup invite**********/
		contr.selectedEmailTemplate =templates[0].getValue() ;
		contr.sendInvite();
		contr.sendInvite();
		contr.sendInvite();
		
	}
	
	static testMethod void testHaparaSchedulingSetupController(){
		createTestHapara_SchedulingSetupRecords();
		testContact.Hapara_Scheduling_Type__c=testSchduleType.Id;
		update testContact;
		
		Hapara_SchedulingSetupHandler.generateEventsFromScheduledTimes(testSchedule.Id);
		
		PageReference page = new PageReference(Hapara_const.CUSTOMER_PORTAL_SCHEDULINGSETUPBOOKING_URL);
        Test.setCurrentPage(page);
        Hapara_SchedulingSetupController controller = new Hapara_SchedulingSetupController();
         //**********test checkContactId()**************/
        system.assertEquals(controller.checkContactId().getUrl(),HAPARA_CONST.CUSTOMER_PORTAL_UNAUTHOIZE_URL );
        page.getParameters().put('id', testContact.Id);
        system.assertEquals(controller.checkContactId(),null );
        //*********test get details***********/
        system.assert(controller.getAccountDetails()!= null);
        system.assert(controller.getBookedSessionTime1().length()==0);
        system.assert(controller.strScheduledSessions.length()>0);
        system.assert(controller.getSchduleTypeDuration().length()>0);
        system.assert(controller.getCampaignEvents().size()>0);
        system.assertEquals(controller.step , '1');
        //******non-essential events*******/
        system.assertEquals(controller.refreshCalendarEvents() , null);
        system.assert(controller.cancelBookedSession()!=null);
        system.assert(controller.backToConfirmPage() !=null);
        //********book session*****//
        list<Hapara_Scheduling_Session__c> events = [Select h.Status__c, h.Start_Datetime__c, h.Id, h.Hapara_Scheduling_Type__c, 
								h.Engineer_Name__c,h.Engineer__c, h.End_Datetime__c, h.Customer_Contact__c 
								From Hapara_Scheduling_Session__c h
								where h.Customer_Contact__c = null and h.Hapara_Scheduling_Type__c =: testSchduleType.Id
								and h.Start_Datetime__c>today
								and h.Hapara_Weekly_Scheduling__c in
								(select Id
								From Hapara_Weekly_Scheduling__c h 
								where h.Status__c=: HAPARA_CONST.HAPARA_WEEKLYSCHEDULING_STATUS_CONFIRMED  and 
								h.Is_Active__c = true and h.End_Date__c >Today)
								order by h.Start_Datetime__c,h.End_Datetime__c  limit 1
								];
        controller.selectedContactTimeZone = 'America/Los_Angeles' ;
        controller.selectedEventId = events[0].Id;
        system.assert(controller.bookEventSession().getUrl().contains('eventId'));
        
        controller.getAccountDetails().Type_of_Setup__c = 'Immediate Deployment';
        controller.getAccountDetails().No_of_Student_licenses__c = 100;
        controller.getAccountDetails().Need_a_Quote__c = 'Yes';
        controller.referredContact1Name	='contact 1';
        controller.referredContact1Email= 'contact1@test.com';
        controller.referredContact1Title = 'title1';
        controller.referredContact2Name = 'contact 2';
        controller.referredContact2Email = 'contact2@test.com';
        controller.referredContact2Title = 'title2';
        controller.referredContact3Name = 'contact 3';
        controller.referredContact3Email= 'contact3@test.com';
        controller.referredContact3Title = 'title3';
        
        controller.getAccountDetails().How_did_you_hear_about_us__c = 'Collegue';
        controller.selectedCountry = 'United States';
        controller.selectedState = 'California';
        controller.getAccountDetails().Phone = '8909809';
        controller.getAccountDetails().MailingStreet = 'tri';
        controller.getAccountDetails().MailingCity = 'palo alto';
        controller.getAccountDetails().MailingPostalCode = '2387';
        string url = controller.updateAccountDetails().getUrl();
        system.debug('***testHaparaSchedulingSetupController: survey url=' +url );
        system.assert(url.contains('TakeSurvey'));
	}
	
	static testMethod void testGenerateEventsFromScheduledTimes(){
		createTestHapara_SchedulingSetupRecords();
		Hapara_SchedulingSetupHandler.generateEventsFromScheduledTimes(testSchedule.Id);
		list<Hapara_Scheduling_Session__c> sessions =[ Select h.Hapara_Weekly_Scheduling__c 
					From Hapara_Scheduling_Session__c h
					where h.Hapara_Weekly_Scheduling__c = : testSchedule.Id];
		system.assert(sessions.size()>0);
		testSchedule = [select id,h.Status__c from Hapara_Weekly_Scheduling__c h 
				where id =: testSchedule.Id];
		testSchedule.Status__c = 'Pending Confirmation';
		update testSchedule;
		Hapara_SchedulingSetupHandler.generateEventsFromScheduledTimes(testSchedule.Id);
		system.assert(sessions.size()>0);
	}
	
	static testMethod void createTestHapara_SchedulingSetupRecords(){
		list<User> users = [select id from User u where u.IsActive = true limit 2];
		testSchduleType = new Hapara_Scheduling_Type__c(
			Minimum_Minutes__c = 90, 
			Is_Default__c = true, 
			Is_Active__c = true, 
			Duration_of_Event_Scheduled__c = 2);
		insert testSchduleType;
		
		testSchedule = new Hapara_Weekly_Scheduling__c(
			Timezone__c ='America/Los_Angeles' , 
			Status__c = 'Pending Confirmation', 
			Start_Date__c = date.today(),  
			End_Date__c = date.today().addDays(7),
			Is_Active__c = true);
		insert testSchedule;
		
		testEngineerSchedule1 = new Hapara_Engineer_Scheduled_Times__c (
			Engineer__c = users[0].id, 
			Date_Available_from__c = date.today().addDays(1),
			Hapara_Scheduling_Type__c = testSchduleType.id,
			Data_Available_To__c = date.today().addDays(1), 
			Time_Available_From__c = '09:00:00', 
			Time_Available_To__c = '18:00:00',
			Goto_Meeting_Acess__c = '1. Please join my meeting.'
					+ '\nhttps://www3.gotomeeting.com/join/294482110'
					+ '\n2. Use your microphone and speakers (VoIP) - a headset is recommended. Or, call in using your telephone.'
					+ '\n'
					+ '\nAustralia: +61 2 8355 1036'
					+ '\nUnited Kingdom: +44 (0) 330 221 0098'
					+ '\nNew Zealand: +64 (0) 4 974 7243'
					+ '\nUnited States: +1 (213) 493-0618'
					+ '\nAccess Code: 294-482-110'
					+ '\nAudio PIN: Shown after joining the meeting'
					+ '\nMeeting ID: 294-482-110'
					+ '\n'
					+ '\nGoToMeeting®'
					+ '\nOnline Meetings Made Easy®'
					+ '\nNot at your computer? Click the link to join this meeting from your iPhone®, iPad® or Android® device via the GoToMeeting app.',
			Status__c = 'Pending', 
		    Goto_Meeting_ID__c  = 'meetings5@hapara.com',
		    Hapara_Weekly_Scheduling__c = testSchedule.id);
		insert testEngineerSchedule1;
		    
		testEngineerSchedule2 = new Hapara_Engineer_Scheduled_Times__c (
			Engineer__c = users[0].id, 
			Date_Available_from__c = date.today().addDays(1),
			Hapara_Scheduling_Type__c = testSchduleType.id,
			Data_Available_To__c = date.today().addDays(3), 
			Time_Available_From__c = '09:00:00', 
			Time_Available_To__c = '16:00:00',
			Goto_Meeting_Acess__c = '1. Please join my meeting.'
					+ '\nhttps://www3.gotomeeting.com/join/294482110'
					+ '\n2. Use your microphone and speakers (VoIP) - a headset is recommended. Or, call in using your telephone.'
					+ '\n'
					+ '\nAustralia: +61 2 8355 1036'
					+ '\nUnited Kingdom: +44 (0) 330 221 0098'
					+ '\nNew Zealand: +64 (0) 4 974 7243'
					+ '\nUnited States: +1 (213) 493-0618'
					+ '\nAccess Code: 294-482-110'
					+ '\nAudio PIN: Shown after joining the meeting'
					+ '\nMeeting ID: 294-482-110'
					+ '\n'
					+ '\nGoToMeeting®'
					+ '\nOnline Meetings Made Easy®'
					+ '\nNot at your computer? Click the link to join this meeting from your iPhone®, iPad® or Android® device via the GoToMeeting app.',
			Status__c = 'Pending', 
		    Goto_Meeting_ID__c  = 'meetings5@hapara.com',
		    Hapara_Weekly_Scheduling__c = testSchedule.id);
		insert testEngineerSchedule2;
		
		testAccount = new Account();
			testAccount.name = 'test company';
			testAccount.Requested_Demo_Session_Date__c = '11:00 AM Wednesday, January 15th 2014 (America/New_York) / 4pm Wednesday, January 15th 2014 (Europe/London)';
			testAccount.BillingCountry = 'United States';
		insert testAccount;
			
		testContact = new Contact();
			testContact.firstName = 'test';
			testContact.lastName = 'Contact';
			testContact.email = 'testcontact@gmail.com';
			testContact.accountid = testAccount.id;
			testContact.Contact_Date_Time_Demo__c = '6:00 PM Wednesday, February 26th 2014';
		insert testContact;
			
	}
}