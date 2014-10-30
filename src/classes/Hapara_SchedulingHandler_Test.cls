@isTest(SeeAllData=true)
public class  Hapara_SchedulingHandler_Test {
	public static Campaign testCampaign ;
	public static Account testAccount;
	public static Contact testContact;
	public static User custService;
	public static Lead testLead;
	public static CampaignMember member;
	
	
	static testMethod void testCreateSchedulingCampaigns(){
		createTestSchedulingRecord();
		System.runAs(custService){
			Hapara_SchedulingHandler.CreateSchedulingCampaigns(); 
		}
	}
	 
	static testMethod void testSendEmailReminderOnDemoCampaign(){
		createTestSchedulingRecord();
		Hapara_SchedulingHandler.SendEmailReminderOnDemoCampaign(testCampaign.Id, HAPARA_CONST.SETTING_SCHEDULE.X1_Hour_Reminder_Email__c);
	}
	 
	static testMethod void testSendEmailOnDemoCampaign(){
		createTestSchedulingRecord();
		Hapara_SchedulingHandler.SendEmailOnDemoCampaign(testCampaign.Id,HAPARA_CONST.SETTING_SCHEDULE.Schedule_Confirmation_Email_Template__c,member.Id);
	}
	
	static testMethod void testScheduleContactForDemo(){
		createTestSchedulingRecord();
		
		Hapara_SchedulingHandler.ScheduleContactForDemo(testContact.Id); 
	}
	
	static testMethod void testSendInviteWithICSfile(){
		createTestSchedulingRecord();
		Datetime dt = testCampaign.Demo_Date_and_Time__c;
		Hapara_SchedulingHandler.SendInviteWithICSfile(testCampaign.id, HAPARA_CONST.CAMPAIGNMEMBER_STATUS_CONFIRMED,dt,dt.addhours(1), 
				testCampaign.Calendar_Group__c,testContact,testContact.Contact_Date_Time_Demo__c,
				testCampaign.Schedule_Meeting_Connection_Details__c,testCampaign.Calendar_Subject__c,'HaparaDemoBooking.ics'  );
	
	}
	
	static testMethod void testLeadAfterConvertAndUpdate(){
		createTestSchedulingRecord();
		Hapara_SchedulingHandler.SendInternalLeadRegistrationEmail(testLead);
		
		Database.LeadConvert lc = new Database.LeadConvert();
		lc.setLeadId(testLead.Id);
        lc.setConvertedStatus(HAPARA_CONST.LEAD_CONVERTED_STATUS);

        lc.setOwnerId(HAPARA_CONST.SETTING_RESELLER.Reseller_Scheduling_User_Id__c);
        lc.setOpportunityName(HAPARA_CONST.LEAD_DEFAULT_OPP_STATE);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        if (lcr.opportunityId != null && opportunity.StageName != null) {
        	Hapara_SchedulingHandler.updateOpportunityAfterConvert(lcr.opportunityId,  testLead, lcr.ContactId,  HAPARA_CONST.OPPORTUNITY_STAGE_DEMONSTRATION, 
	            			 HAPARA_CONST.LEAD_DEFAULT_OPP_STATE);
        }
        
        Hapara_SchedulingHandler.updateAccountAfterConvert( lcr.AccountId,testLead);
        
	}
	
	public static testMethod void createTestSchedulingRecord(){
		custService = [Select u.Username, u.TimeZoneSidKey, u.LocaleSidKey, u.LastName, u.LanguageLocaleKey, u.FirstName, u.EmailEncodingKey, u.Email, u.Alias 
			From User u where u.Alias = 'custserv' limit 1];
			
		System.runAs(custService){
			Date now = Date.today().addDays(1);
			DateTime d = DateTime.newInstance(now.day(), now.month(), now.year());
			testCampaign= new Campaign();
			testCampaign.Name = 'test';
			testCampaign.RecordTypeId = HAPARA_CONST.SETTING_SCHEDULE.Campaign_Record_Type_Id__c;
			testCampaign.StartDate = now;
			testCampaign.EndDate=now;
			testCampaign.Demo_Days__c = d.format('E');
			testCampaign.Demo_Time__c = '16:00:00';
			testCampaign.Demo_Time_Zone__c  = 'America/Los_Angeles';
			testCampaign.Type='Demonstration';
			testCampaign.Status = 'In Progress';
			testCampaign.IsActive = true;
			testCampaign.Calendar_Group__c = 'meetings3@hapara.com';
			testCampaign.Calendar_Subject__c ='Teacher Demo Test reminder';
			testCampaign.Demo_Date_and_Time__c = HaparaTimeConversions.convertDateTimeToGMT( 'America/Los_Angeles', now,'16:00:00');
			testCampaign.Demo_Presenter__c = custService.id;
			testCampaign.Schedule_Meeting_Connection_Details__c='Meeting Details '
					+'\n------------------------- '
					+'\n 1.  Please join our Hapara Demo session. The session will run for 60 ms, during this session we\'d like to learn a bit more about how you are using Google Apps at your school, go over the basics of Teacher Dashboard and answer any questions you may have.' 
					+'\n https://www3.gotomeeting.com/join/768900990 '
					+'\n 2.  Use your microphone and speakers (VoIP) - a headset is recommended. Or, call in using your telephone.  '
					+'\n Australia: +61 2 8355 1031 '
					+'\n New Zealand: +64 (0) 9 925 0481 '
					+'\n United States: +1 (213) 493-0619 '
					+'\n Access Code: 768-900-990 '
					+'\n Audio PIN: Shown after joining the meeting '
					+'\n Meeting ID: 768-900-990';
			
			insert testCampaign;
			
			CampaignMemberStatus n = new CampaignMemberStatus();		
			n.SortOrder= 3;
			n.Label= HAPARA_CONST.CAMPAIGNMEMBER_STATUS_CONFIRMED;
			n.IsDefault= false;
			n.HasResponded=true;
			n.CampaignId = testCampaign.Id;
			insert n;
			
			CampaignMemberStatus n2 = new CampaignMemberStatus();		
			n2.SortOrder= 4;
			n2.Label= 'test 2';
			n2.IsDefault= false;
			n2.HasResponded=true;
			n2.CampaignId = testCampaign.Id;
			insert n2;
			
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
			
			Contact testContact2 = new Contact();
			testContact2.firstName = 'test';
			testContact2.lastName = 'Contact2';
			testContact2.email = 'testcontact2@gmail.com';
			testContact2.accountid = testAccount.id;
			testContact2.Contact_Date_Time_Demo__c = '6:00 PM Wednesday, February 26th 2014';
			insert testContact2;
			
			testLead = new Lead(); 
			testLead.FirstName = 'test';
			testLead.LastName= 'lead';
			testlead.Email = 'testlead@gmail.com';
			testlead.Website = 'domain';
			testLead.Company = 'test school';
			testLead.How_did_you_hear_about_us__c = 'Conference';
			testLead.How_did_you_hear_about_us2__c='Campaign test';
			insert testLead;
			
			member = new CampaignMember();
			member.Status = HAPARA_CONST.CAMPAIGNMEMBER_STATUS_CONFIRMED;
			member.ContactId = testContact.Id;
			member.CampaignId = testCampaign.Id;
			insert member;
			
			CampaignMember member2 = new CampaignMember();
			member2.Status = HAPARA_CONST.CAMPAIGNMEMBER_STATUS_CONFIRMED;
			member2.ContactId = testContact2.Id;
			member2.CampaignId = testCampaign.Id;
			insert member2;
		}
		
	}
}