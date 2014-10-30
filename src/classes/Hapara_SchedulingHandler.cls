public class Hapara_SchedulingHandler {
	public static void SendInternalLeadRegistrationEmail(Lead lead){
		system.debug('***SendInternalLeadRegistrationEmail - lead=' + lead.name);
		string siteUrl = Hapara_Utility.isRunningInSandbox() ? Hapara_Utility.GetSandboxURL():Hapara_Utility.GetProductionURL();
		string emailSubject = 'New lead added to Salesforce for ' + lead.Lead_Queue__c +': ' + lead.firstName + ' '+ lead.LastName + ' from ' + lead.Company;
		string emailcontent = '*** NEW LEAD NOTIFICATION ***'
			+'<p>'
			+'The following lead has been added to Salesforce:' 
			+'<br/>'+'School/Organization: ' + lead.Company
			+'<br/>'+'Organization Type: ' + lead.Industry
			+'<br/>'+'Country: '+ lead.Country
			+'<br/>'+'State: ' +lead.State
			+'<br/>'+'Lead Name: ' + lead.firstName + ' '+ lead.LastName
			+'<br/>'+'Job Title: '+lead.Title
			+'<br/>'+'Lead Email: '+lead.Email
			+'<br/>'+'Lead Question: '+lead.Question_from_Lead__c
			+'<br/>'+'Lead Description: '+lead.description
			+'</p>'
			+'<br/>'
			+'<p>'+'Lead SF Link: ' + siteUrl +'/'+ lead.Id + '</p>';
			HaparaSendEmailNotification.SentNonTemplateEmail(emailSubject,  emailcontent, HAPARA_CONST.SETTING_SCHEDULE.Web_To_Lead_Nofications_Email__c );			
	}
	
	public static void SendEmailReminderOnDemoCampaign(Id campaignId,string templateName){
		Campaign camp = [select id,Demo_Presenter__c, Demo_Presenter_Email__c from Campaign where id =:campaignId];
		list<CampaignMember> members = [Select c.Id, c.Contact_Local_Date_Time__c, c.Status, 
				c.Contact.Timezone__c, c.Contact.FirstName,c.Contact.LastName, c.ContactId,c.Contact.Email,c.Contact.Name,
				c.Contact.Hapara_Demo_Scheduling_URL__c,
				c.Campaign.Demo_Date_and_Time__c, c.Campaign.Demo_Presenter__c, c.CampaignId ,c.Campaign.Calendar_Subject__c,
				c.Campaign.Schedule_Meeting_Connection_Details__c,
				c.Campaign.Calendar_Group__c
				From CampaignMember c WHERE c.CampaignId =: campaignId and status!=: HAPARA_CONST.CAMPAIGNMEMBER_STATUS_CANCELLED ];
		list<id> contactIds =new list<string>();
		map<id, Messaging.EmailFileAttachment[]> attachments = new map<id, Messaging.EmailFileAttachment[]>();
		for(CampaignMember m: members){
			contactIds.add(m.Contact.Id);
			DateTime dt = m.Campaign.Demo_Date_and_Time__c;
			Messaging.EmailFileAttachment[] attach = SendInviteWithICSfile(m.id ,HAPARA_CONST.CAMPAIGNMEMBER_STATUS_CONFIRMED,
				dt,dt.addhours(1), 
				m.Campaign.Calendar_Group__c,m.Contact,m.Contact_Local_Date_Time__c,
				m.Campaign.Schedule_Meeting_Connection_Details__c,m.Campaign.Calendar_Subject__c,'HaparaDemoBooking.ics'  );
			attachments.put(m.id, attach);
		}
		system.debug('***Hapara_SchedulingHandler:templateName = ' + templateName + ' campaignId=' + campaignId 
			+ ' Demo_Presenter=' + camp.Demo_Presenter_Email__c + ' contactIds='+contactIds );
				
		HaparaSendEmailNotification.SendMassContactEmails( templateName, campaignId,'Campaign', contactIds,  
			'Hapara Team','customer.service@hapara.com',attachments);
		HaparaSendEmailNotification.SendUserWithTemplate(HAPARA_CONST.SETTING_SCHEDULE.Demo_Internal_Reminder_Notification__c, 
				campaignId, camp.Demo_Presenter_Email__c);
	}
	
	public static void SendEmailOnDemoCampaign(Id campaignId,string templateName,string memberId){
		list<CampaignMember>  members;
		try{
		if( string.IsEmpty(memberId))
			members = [Select c.Id, c.Contact_Local_Date_Time__c, c.Status, 
				c.Contact.Timezone__c, c.Contact.FirstName,c.Contact.LastName, c.ContactId,c.Contact.Email,c.Contact.Name,
				c.Contact.Hapara_Demo_Scheduling_URL__c,
				c.Campaign.Demo_Date_and_Time__c, c.Campaign.Demo_Presenter__c, c.CampaignId ,c.Campaign.Calendar_Subject__c,
				c.Campaign.Schedule_Meeting_Connection_Details__c,
				c.Campaign.Calendar_Group__c
				From CampaignMember c WHERE c.CampaignId =: campaignId and status!=: HAPARA_CONST.CAMPAIGNMEMBER_STATUS_CANCELLED ];
		else
			members = [Select c.Id, c.Contact_Local_Date_Time__c,  c.Status, 
				c.Contact.Timezone__c, c.Contact.FirstName,c.Contact.LastName, c.ContactId ,c.Contact.Email,c.Contact.Name,
				c.Contact.Hapara_Demo_Scheduling_URL__c,
				c.Campaign.Demo_Date_and_Time__c, c.Campaign.Demo_Presenter__c, c.CampaignId ,c.Campaign.Calendar_Subject__c,
				c.Campaign.Schedule_Meeting_Connection_Details__c,
				c.Campaign.Calendar_Group__c
				From CampaignMember c WHERE c.Id =: memberId  and status!=: HAPARA_CONST.CAMPAIGNMEMBER_STATUS_CANCELLED ];
			
		for(CampaignMember m : members){
			DateTime dt = m.Campaign.Demo_Date_and_Time__c;
			Messaging.EmailFileAttachment[] attach = SendInviteWithICSfile(m.id ,HAPARA_CONST.CAMPAIGNMEMBER_STATUS_CONFIRMED,
				dt,dt.addhours(1), 
				m.Campaign.Calendar_Group__c,m.Contact,m.Contact_Local_Date_Time__c,
				m.Campaign.Schedule_Meeting_Connection_Details__c,m.Campaign.Calendar_Subject__c,'HaparaDemoBooking.ics'  );
			system.debug('***SendEmailOnDemoCampaign: attach= ' + attach.size());
			HaparaSendEmailNotification.SendContactEmailwithBCCNSetWhatIdNAttachment(m.contact,
								templateName, m.CampaignId,null,attach);								
		}
		}catch(Exception e){
			string error ='***Hapara_SchedulSendEmailOnDemoCampaigningHandler: '+  e.getMessage() + '\n\n//-- Stack Trace --//\n' + e.getStackTraceString();
			HaparaSendEmailNotification.SendAdminErrorEmail('Hapara_SchedulingHandler SendEmailOnDemoCampaign process', error, '');
			System.debug(error);
		}
	}
	
	public static Messaging.EmailFileAttachment[] SendInviteWithICSfile(Id whatId, string status,DateTime startDateTime, DateTime endDateTime,
		string fromEmail,Contact recipient, string demotime,string connectionDetails,string calendarsubject, string fileName){
		string subject = calendarsubject + ' at ' + demotime;
		string tempConnectionDetails = connectionDetails;
		tempConnectionDetails = Hapara_Utility.replaceLineBreakWithLineChar( tempConnectionDetails);
		DateTime createdDate = DateTime.Now();
		string format = 'yyyyMMdd\'T\'HHmmss\'Z\'';
		string recipientFN = string.isEmpty(recipient.firstName)?'':recipient.firstName;
		string recipientLN = string.isEmpty(recipient.lastName)?'':recipient.lastName;
		String vCal = 'BEGIN:VCALENDAR'+'\n'
	    + 'PRODID:-//Hapara Inc//EN'+'\n'
	    + 'VERSION:2.0'+'\n'
	    + 'METHOD:PUBLISH'+'\n'
	    + 'BEGIN:VEVENT'+'\n'
	    + 'DTSTART:'+startDateTime.format(format)+'\n'
	    + 'DTEND:'+endDateTime.format(format) + '\n'
	    + 'UID:'+whatId+recipient.Id +'@hapara.com\n'
	    + 'ORGANIZER;CN=HAPARA INC:MAILTO:'+fromEmail+'\n'
	    + 'ATTENDEE;ROLE=REQ-PARTICIPANT;PARTSTAT=NEEDS-ACTION;RSVP=TRUE;CN='
	    +  recipientFN +' '+ recipientLN+' ('+recipient.email+'):MAILTO:'+recipient.email +'\n'
	    + 'DTSTAMP:'+createdDate.format(format)+'\n'
	    + 'DESCRIPTION;ENCODING=QUOTED-PRINTABLE:'+tempConnectionDetails+'\n'
	    + 'STATUS:'+status+'\n'
	    + 'SUMMARY;ENCODING=QUOTED-PRINTABLE:' +subject +'\n'
	    + 'PRIORITY:5'+'\n'
	    + 'BEGIN:VALARM'+'\n'
	    + 'TRIGGER:-PT1H'+'\n'
	    + 'ACTION:DISPLAY'+'\n'
	    + 'DESCRIPTION:Reminder'+'\n'
	    + 'END:VALARM'+'\n' 
	    + 'END:VEVENT'+'\n'
	    + 'END:VCALENDAR';
	    
		system.debug('***SendInviteWithICSfile: vCal= ' + vCal);
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName(fileName);
      
        efa.setBody(blob.valueOf(vCal));
      
        efa.setContentType('text/calendar');
        return new Messaging.EmailFileAttachment[] {efa};
	}

	
	public static string ScheduleContactForDemo(string contactId){
		string result = '';	
		CampaignMember cam = null;
		try{
			
			system.debug('***ScheduleContactForDemo contact id='+ contactId);
			Contact c = [Select c.Timezone__c, c.LastName, c.Id, c.FirstName, c.Email, c.Account.Timezone__c, 
				c.Account.Requested_Demo_Session_Date__c, c.Hapara_Demo_Scheduling_URL__c,
				c.AccountId,c.Account.Name
				From Contact c where id = : contactId];
				
			if(!string.isEmpty(c.Account.Requested_Demo_Session_Date__c)){
				system.debug('***ScheduleContactForDemo Requested_Demo_Session_Date__c='+ c.Account.Requested_Demo_Session_Date__c);
				//11:00 AM Wednesday, January 15th 2014 (America/New_York) / 4pm Wednesday, January 15th 2014 (Europe/London)
				string requestedDemoDateTime= c.Account.Requested_Demo_Session_Date__c;
				String datetimevalue = requestedDemoDateTime.substringAfterLast(') / ');
				
				if(datetimevalue.length()>0){
					string[] values = datetimevalue.split(' ');
					//4pm, Wednesday,, March, 26th, 2014, (Europe/London)
					system.debug('***ScheduleContactForDemo values='+ values + ' size=' + values.size());
					if(values.size()>5){
						string timeValue = values[0].trim() =='4pm'? '16:00:00': '';
						string timeZone = values[5].replace('(','').replace(')','').trim();
						integer dateValue =integer.valueOf( values[3].replace('th','').replace('st','').replace('nd','').trim());
						integer year =integer.valueOf(values[4].trim());
						integer monthvalue =Hapara_Utility.getMonthValuefromString( values[2].trim());
						date bookingDate = Date.newInstance(year, monthvalue, dateValue);
						system.debug('***ScheduleContactForDemo timeValue='+ timeValue +' timeZone='+timeZone + ' year='+year
								+ ' monthvalue=' +monthvalue +' dateValue='+dateValue);
						list<Campaign> demos = [ Select c.IsActive, c.EndDate, c.Demo_Time__c, c.Demo_Time_Zone__c, c.Demo_Day__c, 
									c.Demo_Date_and_Time__c ,c.Id
									From Campaign c where c.IsActive = true and c.Demo_Time_Zone__c =: timezone
									and c.EndDate=:bookingDate and c.Demo_Time__c =:timevalue ];
						if(demos.size()>0){
							//create campaign booking
							cam = new CampaignMember();
							cam.CampaignId = demos[0].Id;
							cam.ContactId = c.Id;
							cam.Status = HAPARA_CONST.CAMPAIGNMEMBER_STATUS_UNCONFIRMED;
							insert cam;
							
							result = HAPARA_CONST.SETTING_SCHEDULE.Schedule_Unconfirm_Email_Template2__c;
						}
					}
				}
			}
			if(cam == null){
			   result = HAPARA_CONST.SETTING_SCHEDULE.Schedule_Unconfirm_Email_Template__c;
			}
		}catch(Exception e){
			string error ='***ScheduleContactForDemo: '+  e.getMessage() + '\n\n//-- Stack Trace --//\n' + e.getStackTraceString();
			HaparaSendEmailNotification.SendAdminErrorEmail('Hapara_SchedulingHandler ScheduleContactForDemo process', error, '');
			System.debug(error);
		}
		return result;
		
	}
	
	public static void CreateSchedulingCampaigns(){
		Date next2weeks = Date.today().addDays(5*7);
		system.debug('***CreateSchedulingCampaigns:next2weeks =' + next2weeks.format());
		list<Campaign> campaigns = [Select c.Type, c.Status, c.StartDate,
			c.Schedule_Meeting_Connection_Details__c, 
			c.RecordTypeId, c.Next_Scheduled__c, c.Name, c.IsDeleted, c.IsActive, c.Id, c.EndDate, c.Demo_Time__c, 
			c.Demo_Time_Zone__c, c.Demo_Presenter__c, c.Demo_Day__c, c.Create_Next_Demo__c, c.Copied_From_Campaign__c ,
			c.Calendar_Subject__c,c.Calendar_Group__c
			From Campaign c where c.IsActive = true and c.Next_Scheduled__c = null
			and c.RecordTypeId =:  HAPARA_CONST.SETTING_SCHEDULE.Campaign_Record_Type_Id__c
			and c.EndDate >: Date.today() and c.EndDate <=: next2weeks
			];
		list<Campaign> tobeInserted = new list<Campaign>();
		map<Id,Campaign> updateParentCampaign = new map<Id,Campaign>();
		for(Campaign r : campaigns){
			updateParentCampaign.put(r.Id, r);
			Date demoDate = r.StartDate.addDays(7);
			DateTime demoDateTime = DateTime.newInstance(demoDate.year(), demoDate.month(), demoDate.day());
		    system.debug('***CreateSchedulingCampaigns:Creating a new campaign');
			Campaign nextCampaign = new Campaign();
			nextCampaign.RecordTypeId = HAPARA_CONST.SETTING_SCHEDULE.Campaign_Record_Type_Id__c;
			
			nextCampaign.StartDate =  demoDate; 
			nextCampaign.EndDate = demoDate; 
			nextCampaign.Demo_Time__c = r.Demo_Time__c; 
			nextCampaign.Demo_Time_Zone__c = r.Demo_Time_Zone__c; 
			nextCampaign.Create_Next_Demo__c = false;
			nextCampaign.Schedule_Meeting_Connection_Details__c= r.Schedule_Meeting_Connection_Details__c;
			nextCampaign.Demo_Presenter__c = r.Demo_Presenter__c;
			nextCampaign.Status=r.Status;
			nextCampaign.IsActive= true;
			nextCampaign.Type = r.Type;
			nextcampaign.Copied_From_Campaign__c = r.id;
			nextCampaign.Calendar_Subject__c = r.Calendar_Subject__c;
			nextCampaign.Calendar_Group__c = r.Calendar_Group__c;
						
			nextCampaign.Name = r.Demo_Time_Zone__c + ','+ r.Demo_Day__c+', '+r.Demo_Time__c+', '+demoDateTime.format('yyyy-MM-dd');
			nextCampaign.Demo_Date_and_Time__c = HaparaTimeConversions.convertDateTimeToGMT(r.Demo_Time_Zone__c, demoDate,r.Demo_Time__c );
			tobeInserted.add( nextCampaign);
					
		}
		system.debug('***CreateSchedulingCampaigns:tobeInserted =' + tobeInserted.size());
		list<Event> newEvents = new list<Event>();
		if(tobeInserted.size()>0){
			insert tobeInserted;
			
			for(Campaign c: tobeInserted){
				Campaign parent = updateParentCampaign.get(c.Copied_From_Campaign__c);
				system.debug('***CreateSchedulingCampaigns:new campaign= '+ c.Id +' parent = '+ parent.Id);
				system.debug('***CreateSchedulingCampaigns:new campaign= '+ c.NAme +' parent = '+ parent.Name);
				parent.Next_Scheduled__c = c.Id;
				list<CampaignMemberStatus> newCampaignStatuses = [Select c.SystemModstamp, c.SortOrder, c.LastModifiedDate, 
					c.LastModifiedById, c.Label, c.IsDefault, c.Id, c.HasResponded, c.CreatedDate, c.CreatedById, c.CampaignId 
					From CampaignMemberStatus c where c.CampaignId =:c.Id and  c.IsDeleted !=true 
					order by c.IsDefault desc NULLS LAST
					];
					
				integer sortOrder = 0;
				for(CampaignMemberStatus s : newCampaignStatuses){
					if(s.SortOrder >sortOrder)
						sortOrder = s.SortOrder;
				}
									   
							
				list<CampaignMemberStatus> newStatuses = new list< CampaignMemberStatus>();
				
				newStatuses.add(new CampaignMemberStatus(SortOrder= sortOrder+1,
							Label= HAPARA_CONST.CAMPAIGNMEMBER_STATUS_UNCONFIRMED ,
							IsDefault= true,
							HasResponded=false,
							CampaignId = c.Id));
				newStatuses.add(new CampaignMemberStatus(SortOrder= sortOrder+2,
							Label= HAPARA_CONST.CAMPAIGNMEMBER_STATUS_CONFIRMED ,
							IsDefault= false,
							HasResponded=true,
							CampaignId = c.Id));			
				newStatuses.add(new CampaignMemberStatus(SortOrder= sortOrder+3,
							Label= HAPARA_CONST.CAMPAIGNMEMBER_STATUS_ATTENDED ,
							IsDefault= false,
							HasResponded=true,
							CampaignId = c.Id));
				newStatuses.add(new CampaignMemberStatus(SortOrder= sortOrder+4,
							Label= HAPARA_CONST.CAMPAIGNMEMBER_STATUS_NONATTENDANCE ,
							IsDefault= false,
							HasResponded=false,
							CampaignId = c.Id));
				newStatuses.add(new CampaignMemberStatus(SortOrder= sortOrder+5,
							Label= HAPARA_CONST.CAMPAIGNMEMBER_STATUS_CANCELLED ,
							IsDefault= false,
							HasResponded=true,
							CampaignId = c.Id));
	   	
				
				system.debug('***CreateSchedulingCampaigns:Inserting new statuses= '+ newStatuses.size());	
				insert newStatuses;
				
				system.debug('***CreateSchedulingCampaigns:deleting old statuses= '+ newCampaignStatuses.size());
				if(newCampaignStatuses.size()>0 && newStatuses.size()>0)
					delete newCampaignStatuses;
					
				//create task for the presenter
				Event event = new Event(
		            OwnerId = c.Demo_Presenter__c ,
		            WhatId = c.Id,
		            StartDateTime = c.Demo_Date_and_Time__c,
		            EndDateTime =c.Demo_Date_and_Time__c.addHours(1),
		            Subject = c.Name,
		            IsReminderSet = true,
					ReminderDateTime = c.Demo_Date_and_Time__c.addHours(-1)
		        );
		        newEvents.add(event) ;      
			}
		}
		if(campaigns.size()>0)
			update campaigns;
		if(newEvents.size()>0)
			insert newEvents;
	
	}
	
	
	public static void updateOpportunityAfterConvert(Id opportunityId, Lead lead, Id contactId, string stageName, string opportunityNameTemplate){
		system.debug('***updateOpportunityAfterConvert- opportunityId='+ opportunityId +' lead='+ lead.Name+ ' contactId='+contactId);
		Opportunity opportunityUpdate = [SELECT Id FROM Opportunity WHERE Id =: opportunityId];
        opportunityUpdate.StageName = stageName;
        opportunityUpdate.Opportunity_Name_Template__c = opportunityNameTemplate;
        opportunityUpdate.RecordTypeId = HAPARA_CONST.SETTING_OPPORTUNITY_CONFIG.Record_Type_Standard__c;
        opportunityUpdate.Name = lead.Company +' - '+ opportunityNameTemplate;
       
        if(!string.isEmpty(lead.How_did_you_hear_about_us__c))
        	opportunityUpdate.How_did_you_hear_about_us__c= lead.How_did_you_hear_about_us__c + '-'+lead.How_did_you_hear_about_us2__c;
        	
        opportunityUpdate.Primary_Contact__c = ContactId;
        if(lead.CampaignMembers.size()>0)
        	opportunityUpdate.campaignId = lead.CampaignMembers[0].campaignId;
        else if(lead.How_did_you_hear_about_us__c =='Conference'){
        	if(lead.How_did_you_hear_about_us2__c != null){
        		list<Campaign> campaignls = [select Id from Campaign where name =:lead.How_did_you_hear_about_us2__c order by CreatedDate desc limit 1];
        		if(campaignls.size() >0)
        			opportunityUpdate.campaignId = campaignls[0].id;
        		else
        			opportunityUpdate.campaignId = HAPARA_CONST.SETTING_SCHEDULE.Default_Conference_Campaign_Id__c ;
        	}
        	else
        		opportunityUpdate.campaignId = HAPARA_CONST.SETTING_SCHEDULE.Default_Conference_Campaign_Id__c ;
        }
        update opportunityUpdate;
	}
	
	public static void updateAccountAfterConvert(string AccountId, Lead lead){
		system.debug('***updateAccountAfterConvert- AccountId='+ AccountId +' lead='+ lead.Name);
		Account updateAccount = [select Id,CurrencyIsoCode from Account where id =:AccountId];
		updateAccount.How_did_you_hear_about_us__c = lead.How_did_you_hear_about_us__c;
		updateAccount.How_did_you_hear_about_us_2__c = lead.How_did_you_hear_about_us2__c;
		update updateAccount;
	}
	
}