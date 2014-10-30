public class Hapara_SchedulingSetupController {
	private Contact currentContact;
	private Account currentContactAccount;
	private Hapara_Scheduling_Session__c currentBookedSession;
	public string selectedContactTimeZone{get;set;}
	public string step{get;set;}
	public string selectAlternativeDateTime1{get;set;}
	public string selectAlternativeDateTime2{get;set;}
	public string selectAlternativeDateTime3{get;set;}
	public string selectedEventId{get;set;}
	public string scheduleType {get;set;}
	
	public Hapara_SchedulingSetupController(){
		system.debug('***Hapara_SchedulingSetupController - initialising; ');
		step='1';
		scheduleType = ApexPages.currentPage().getParameters().get('ScheduleType');
		system.debug('***Hapara_SchedulingSetupController - initialising; scheduleType='+ scheduleType);
		getContactRecord();
		if(ApexPages.currentPage().getParameters().containsKey('eventId')){
			if(currentBookedSession != null)
			{ 
				if(currentBookedSession.id == ApexPages.currentPage().getParameters().get('eventId'))
					step='2';
			}
		}
	}
	
	public PageReference checkContactId(){
		PageReference newPage = null;
		string id = ApexPages.currentPage().getParameters().get('id');
		if(getContactRecord()==null){
			System.debug('***checkContactId() - Cannot find contact id = ' +id);
   			newPage =  new PageReference(HAPARA_CONST.CUSTOMER_PORTAL_UNAUTHOIZE_URL);
    		newPage.setRedirect(true);
	   	}else if(currentBookedSession != null && !ApexPages.currentPage().getParameters().containsKey('eventId') ){
	   		newPage =  new PageReference(getSchedulingSetupFormURL()+'&eventId='+currentBookedSession.Id);
    		newPage.setRedirect(true);
		}
	   	return newPage;
	}
	
	
	public Contact getContactRecord(){		
		string id = ApexPages.currentPage().getParameters().get('id');
		system.debug('***getContactRecord:id ='+id);
		if(currentContact == null){
			list<Contact> tempContact = [Select c.LastName, c.FirstName, c.Email, c.TimeZone__c,c.name,Contact_Date_Time_Demo__c,
					c.AccountId,c.Requested_Demo_Session__c, c.Hapara_Demo_Scheduling_URL__c,c.How_did_you_hear_about_us2__c,
					c.Account.TimeZone__c,Hapara_Scheduling_Type__c,
					 (Select Status__c, End_Datetime__c ,Start_Datetime__c
					 From Hapara_Scheduling_Sessions__r 
					 where End_Datetime__c>today order by End_Datetime__c desc limit 1) 
					From Contact c
					where id =:id ];	
			if(tempContact.size()>0){
				currentContact = tempContact[0];
				selectedContactTimeZone = string.isEmpty( currentContact.Timezone__c)? currentContact.Account.TimeZone__c:currentContact.Timezone__c;
					
				currentContactAccount= [Select a.TimeZone__c,a.BillingStreet, a.BillingState,a.BillingPostalCode, a.BillingCountry, 
					 a.BillingCity,a.Phone,a.How_did_you_hear_about_us__c,How_did_you_hear_about_us_2__c,	
					 a.Setup_Contact_4__r.Title, a.Setup_Contact_4__r.Email, a.Setup_Contact_4__r.Name,
					 a.Setup_Contact_4__c, a.Setup_Contact_3__r.Title, a.Setup_Contact_3__r.Email, a.Setup_Contact_3__r.Name, 
					 a.Setup_Contact_3__c, a.Setup_Contact_2__r.Title, a.Setup_Contact_2__r.Email, a.Setup_Contact_2__r.Name, 
					 a.Setup_Contact_2__c,
					 Type_of_Setup__c,SurveyIntial_No_of_Students__c
					 From Account a 
					 where a.Id =:currentContact.AccountId];
				
				
				if(currentContact.Hapara_Scheduling_Sessions__r.size()>0){
					currentBookedSession = currentContact.Hapara_Scheduling_Sessions__r[0];
					selectedEventId = currentBookedSession.Id;
				}
			}else
				currentContact=null;
		}
		return currentContact;
	}
	
	private Contact currentAccountDetails;
	public string referredContact1Name{get;set;}
	public string referredContact1Email{get;set;}
	public string referredContact1Title{get;set;}
	public string referredContact2Name{get;set;}
	public string referredContact2Email{get;set;}
	public string referredContact2Title{get;set;}
	public string referredContact3Name{get;set;}
	public string referredContact3Email{get;set;}
	public string referredContact3Title{get;set;}
	public Contact getAccountDetails(){
		if(currentAccountDetails == null){
			getContactRecord();
			currentAccountDetails = new Contact();
			currentAccountDetails.phone = currentContactAccount.Phone;
			currentAccountDetails.mailingstreet= currentContactAccount.BillingStreet;
			currentAccountDetails.mailingcity= currentContactAccount.BillingCity;
			currentAccountDetails.Type_of_Setup__c = currentContactAccount.Type_of_Setup__c;
			currentAccountDetails.No_of_Student_licenses__c =currentContactAccount.SurveyIntial_No_of_Students__c ;
			selectedState = currentContactAccount.BillingState;
			currentAccountDetails.mailingPostalCode = currentContactAccount.BillingPostalCode;
			selectedCountry = currentContactAccount.BillingCountry;
			selectedState = currentContactAccount.BillingState;
			currentAccountDetails.How_did_you_hear_about_us__c = currentContactAccount.How_did_you_hear_about_us__c; 
			currentAccountDetails.How_did_you_hear_about_us2__c = currentContactAccount.How_did_you_hear_about_us_2__c;
		}
		return currentAccountDetails;
	}
	
	public string getBookedSessionTime1(){
		string result ='';
		getContactRecord();
		if(currentBookedSession == null){
			if(!string.isEmpty(selectAlternativeDateTime1)){
				result = selectAlternativeDateTime1;
			}				
		}else{
			system.debug('***getBookedSessionTime1: Start_Datetime__c=' + currentBookedSession.Start_Datetime__c
				+'; TimeZone__c='+ selectedContactTimeZone)	;
			result = currentBookedSession.Start_Datetime__c.format('yyyy-MM-dd HH:mm:ss', selectedContactTimeZone);
		}
		return result;
	}
	
	public string getSchduleTypeDuration(){
		string durationMsg = 'The session will last approximately % minutes.';
		if(string.isEmpty(scheduleType)){
			return '';
		}else{
			list<Hapara_Scheduling_Type__c> schtype = [Select h.Name, h.Minimum_Minutes__c, h.Is_Active__c From Hapara_Scheduling_Type__c h where id =:scheduleType ];
			if(schtype.size()>0)
			{
				if(schtype[0].Minimum_Minutes__c>0){
					return durationMsg.replace('%',string.valueOf(schtype[0].Minimum_Minutes__c));
				}
			}	
		}
		return '';
	}
	
	public string strScheduledSessions{
		get{
			if(strScheduledSessions == null)
				getScheduledSessions();
			return strScheduledSessions;
		}
		set;
	}	
	public void getScheduledSessions(){
		try{
			string result = '';
			if(string.isEmpty(scheduleType)){
				scheduleType = currentContact.Hapara_Scheduling_Type__c;
			}
			list<Hapara_Scheduling_Session__c> events = [Select h.Status__c, h.Start_Datetime__c, h.Id, h.Hapara_Scheduling_Type__c, 
								h.Engineer_Name__c,h.Engineer__c, h.End_Datetime__c, h.Customer_Contact__c 
								From Hapara_Scheduling_Session__c h
								where h.Customer_Contact__c = null and h.Hapara_Scheduling_Type__c =: scheduleType
								and h.Start_Datetime__c>today
								and h.Hapara_Weekly_Scheduling__c in
								(select Id
								From Hapara_Weekly_Scheduling__c h 
								where h.Status__c=: HAPARA_CONST.HAPARA_WEEKLYSCHEDULING_STATUS_CONFIRMED  and 
								h.Is_Active__c = true and h.End_Date__c >Today)
								order by h.Start_Datetime__c,h.End_Datetime__c 
								];
			system.debug('***getScheduledSessions - number of events='+ events.size() + ', contactTimezone=' +selectedContactTimeZone);		
			string timezone =string.isEmpty( selectedContactTimeZone) ? 'Etc/GMT':selectedContactTimeZone;
			for(Hapara_Scheduling_Session__c e : events){
				string startTime = e.Start_Datetime__c.format('HH', timezone);
				string endTime = e.End_Datetime__c.format('HH', timezone);
				if(integer.valueOf(startTime)>=7 && integer.valueOf(endTime)<=23 && integer.valueOf(endTime) !=0){
					result =result 
							+ '{ \"date\": \"'+ e.Start_Datetime__c.format('yyyy-MM-dd HH:mm:ss', timezone)
							+'\",\"endtime\": \"' + e.End_Datetime__c.format('yyyy-MM-dd HH:mm:ss', timezone)
							+'\", \"timezone\": \"'+timezone
							+'\", \"type\": \"meeting\", \"title\": \"Presenter ' + e.Engineer_Name__c
							+'\", \"description\": \"' +
							+'\", \"urltype\": \"javascript' +
							+'\", \"url\": \"bookEventSession(\''+e.Id+'\')'
							+'\" },';
				}
			}
			if(result.length()>0)
				result = result.left(result.length()-1);
				
			strScheduledSessions ='['+ result+']';
			system.debug('***getScheduledSessions - strScheduledSessions='+strScheduledSessions);
		}catch(Exception e){
			string error ='***getScheduledSessions: timezone: ' +selectedContactTimeZone +'\n\n ERROR:'+  e.getMessage() 
			+ '\n\n//-- Stack Trace --//\n' + e.getStackTraceString();
			HaparaSendEmailNotification.SendAdminErrorEmail('getScheduledSessions', error, Apexpages.currentPage().getUrl());
			System.debug(error);    		
			throw new HaparaException(e);
   		}
	}
	
	list<Campaign> campaignEvents;
	public List<SelectOption> getCampaignEvents(){
		List<SelectOption> result =Hapara_UtilityCommonRecordAccess.getCampaignEvents(campaignEvents);
		return result;
	}
	
	public PageReference refreshCalendarEvents(){
		PageReference newPage = null;
		system.debug('***refreshCalendarEvents - refreshing; contactTimezone=' +selectedContactTimeZone);	
		getScheduledSessions();
		return newPage;
	}
	
	public PageReference bookEventSession(){
		PageReference newPage = null;

		system.debug('***bookSession: timezone: ' +selectedContactTimeZone + '; eventid='+selectedEventId);
		string id = ApexPages.currentPage().getParameters().get('id');
		if(!string.IsEmpty(selectedEventId)){
			try{
				selectAlternativeDateTime1 = null;
				selectAlternativeDateTime2 = null;
				selectAlternativeDateTime3 = null;
				//book the event
				list<Hapara_Scheduling_Session__c> evt = [Select h.Status__c, h.Start_Datetime__c, h.Id, h.Hapara_Scheduling_Type__c, 
								h.Engineer__r.Name, h.Engineer__c, h.End_Datetime__c, h.Customer_Contact__c 
								From Hapara_Scheduling_Session__c h
								where h.Customer_Contact__c = null and h.Id =:selectedEventId];
				if(evt.size()>0){
					evt[0].Customer_Contact__c = id;
					evt[0].Status__c= HAPARA_CONST.CAMPAIGNMEMBER_STATUS_CONFIRMED;
					update evt[0];
					
					currentContact.Timezone__c = selectedContactTimeZone;
					update currentContact;
					step='2';
					newPage =  new PageReference(getSchedulingSetupFormURL()+'&eventId='+selectedEventId);
    				newPage.setRedirect(true);
				}else{
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'The session you have selected has already been booked please select another.'));
				}
			}catch(Exception e){
				string error ='***bookSession: timezone: ' +selectedContactTimeZone + '; eventid='+selectedEventId
				 +'\n\n ERROR:'+  e.getMessage() 
				+ '\n\n//-- Stack Trace --//\n' + e.getStackTraceString();
				HaparaSendEmailNotification.SendAdminErrorEmail('bookSession', error, Apexpages.currentPage().getUrl());
				System.debug(error);    		
	   		}
		}else{
			Apexpages.addMessage(new ApexPages.message(ApexPages.severity.Error,
	   					'You have not selected a session please click "book" on a session.'));	
	   		step='1';
		}
		return newPage;
	}
	
	public PageReference bookOtherSessionDateTime(){
		PageReference newPage = null;
		system.debug('***bookOtherSessionDateTime -  selectAlternativeDateTime1=' +selectAlternativeDateTime1 
			+ '; selectAlternativeDateTime2=' +selectAlternativeDateTime2 +'; selectAlternativeDateTime3='+selectAlternativeDateTime3);
		step='2';
		selectedEventId = null;
			
		return newPage;
	}
	
	public string selectedCampaignId{get;set;}
	public string selectedCountry{get;set;}
	public string selectedState{get;set;}
	public string thankMessage {
		get{
			return 'We are looking forward to starting the setup journey with you. An email confirmation will be sent to you.';
		}
		set{}
	}
	
	public PageReference updateAccountDetails(){
		PageReference newPage = null;	
		string id = ApexPages.currentPage().getParameters().get('id');
		
		system.debug('***updateAccountDetails: timezone: ' +selectedContactTimeZone + '; eventid='+selectedEventId 
				+'; selectAlternativeDateTime1=' +selectAlternativeDateTime1 + '; selectAlternativeDateTime2=' +selectAlternativeDateTime2 
				+'; selectAlternativeDateTime3='+selectAlternativeDateTime3);	
		try{
			Account acc = [Select Prospect_Timezone__c, BillingStreet, BillingState,ownerid,name,
					BillingPostalCode, BillingCountry,BillingCity,Phone,How_did_you_hear_about_us__c,
					(Select Id, AccountId, LastName, FirstName, Email, Title From Contacts)
					From Account a
					where id =:currentContact.AccountId ];
			acc.Prospect_Timezone__c = selectedContactTimeZone;
			acc.Phone =currentAccountDetails.phone ;
			acc.BillingStreet =currentAccountDetails.mailingstreet;
			acc.BillingCity =currentAccountDetails.mailingcity;
			acc.BillingState =selectedState ;
			acc.BillingPostalCode =currentAccountDetails.mailingPostalCode ;
			acc.BillingCountry =selectedCountry ;
			acc.How_did_you_hear_about_us__c =currentAccountDetails.How_did_you_hear_about_us__c;
			acc.How_did_you_hear_about_us_2__c =currentAccountDetails.How_did_you_hear_about_us2__c;
			acc.Booked_Setup_Contact__c = currentContact.Id;
			acc.Type_of_Setup__c = currentAccountDetails.Type_of_Setup__c;
			acc.SurveyIntial_No_of_Students__c = currentAccountDetails.No_of_Student_licenses__c;
			
			currentContact.phone = currentAccountDetails.phone;
			currentContact.How_did_you_hear_about_us__c = currentAccountDetails.How_did_you_hear_about_us__c;
			currentContact.Timezone__c = selectedContactTimeZone;
			if(ApexPages.currentPage().getParameters().containsKey('ScheduleType')){
				scheduleType= ApexPages.currentPage().getParameters().get('ScheduleType');
				system.debug('***updateAccountDetails - updating scheduleType=' + scheduleType);
				if(currentContact.Hapara_Scheduling_Type__c != scheduleType){
					currentContact.Hapara_Scheduling_Type__c = scheduleType;
				}
			}
			update currentContact;
			
			//add the new attendees
			map<string, Contact> accContacts = new map<string, Contact>();
			for(Contact c : acc.Contacts){
				if(!accContacts.containsKey(c.email)){
					accContacts.put(c.email.toLowerCase(), c);
				}
			}
			Hapara_Scheduling_Session__c evt;
			// only if an event session has been selected.
			if(!string.IsEmpty(selectedEventId)){
				evt = [Select h.Status__c, h.Start_Datetime__c, h.Id, h.Hapara_Scheduling_Type__c, 
									h.Engineer__r.Name, h.Engineer__c, h.End_Datetime__c, h.Customer_Contact__c ,
									h.Customer_Contact_4__c, h.Customer_Contact_3__c, h.Customer_Contact_2__c
									From Hapara_Scheduling_Session__c h
									where  h.Id =:selectedEventId];
				acc.Booked_Setup_Session__c = evt.Start_Datetime__c;
				
			}else{
				acc.Booked_Setup_Session__c = null;
			}
			
			
			Contact cont = createEventAttendee(referredContact1Email,referredContact1Title,referredContact1Name,accContacts);
			if(cont != null ){
				acc.Setup_Contact_1__c = cont.Id;
				if(evt != null)
				evt.Customer_Contact_2__c = cont.Id;
			}
		
			cont = createEventAttendee(referredContact2Email,referredContact2Title,referredContact2Name,accContacts);
			if(cont != null ){
				acc.Setup_Contact_2__c = cont.Id;
				if(evt != null)
				evt.Customer_Contact_3__c = cont.Id;
			}
			cont = createEventAttendee(referredContact3Email,referredContact3Title,referredContact3Name,accContacts);
			if(cont != null ){
				acc.Setup_Contact_3__c = cont.Id;
				if(evt != null)
				evt.Customer_Contact_4__c = cont.Id;
			}
			if(evt != null)
				update evt;
				
			update acc;
			
			//check if the survery already done
		    List<SurveyTaker__c> check = [Select Contact__c, Survey__c, Case__c, User__c From SurveyTaker__c 
            	Where  Survey__c=:HAPARA_CONST.SETTING_SCHEDULE.Customer_Setup_Survey_Id__c and Contact__c=:id  ];
            system.debug('***updateAccountDetails - Check if survey is done - check:' + check.size());
            if(check.size()==0){
            	string surveyUrl = HAPARA_CONST.SETTING_SCHEDULE.Customer_Setup_Survey_URL__c;
            	surveyUrl = surveyUrl.replace('{!Contact.Id}',id);
            	surveyUrl= surveyUrl.replace('{!Survey.Id}',HAPARA_CONST.SETTING_SCHEDULE.Customer_Setup_Survey_Id__c);
				newPage = new Pagereference(surveyUrl);
            }else{
            	step = '3';
            }
            if(!string.IsEmpty(selectedEventId)){
	            Hapara_SchedulingSetupHandler.sendBookSessionInvite(
	            	HAPARA_CONST.SETTING_SCHEDULE.Setup_Confirmation_Email_Template__c,
	            	selectedEventId,HAPARA_CONST.CAMPAIGNMEMBER_STATUS_CONFIRMED);
	            string description = '';
	            Task setup = new Task();
				setup.OwnerId =acc.OwnerId;
				setup.WhatId = acc.Id;
				setup.WhoId = currentContact.Id;
				if(currentAccountDetails.Need_a_Quote__c =='Yes'){
					setup.ActivityDate = Date.today();
					setup.Subject =  acc.Name + ' has scheduled for setup please follow up and REQUIRE A QUOTE';
					setup.priority = 'High';
					description = 'Quote:REQUIRED \n';
					
				}else{
					setup.ActivityDate = evt.Start_Datetime__c.Date();
					setup.Subject =  acc.Name + ' has scheduled for setup please follow up';
				}
				description = description + ' Type of Setup: ' + acc.Type_of_Setup__c +'\n'
						+'No of licenses: ' + acc.SurveyIntial_No_of_Students__c;
				setup.description = description;
				setup.status = 'Not Started';
				
				Database.DMLOptions dmlo = new Database.DMLOptions();
                dmlo.EmailHeader.triggerUserEmail = true;
                database.insert(setup, dmlo);
            }else{
	        	HaparaSendEmailNotification.SendContactEmailwithBCCNSenderSetWhatId(currentContact,
	        		HAPARA_CONST.SETTING_SCHEDULE.Setup_Other_Times_ConfirmEmail_Template__c, 
					acc.Id, null, 'Hapara Team', 'customer.service@hapara.com', null);
				
	        }
       
		}catch(Exception e){
			string error ='***bookSession: timezone: ' +selectedContactTimeZone + '; eventid='+selectedEventId
			 +'\n\n ERROR:'+  e.getMessage() 
			+ '\n\n//-- Stack Trace --//\n' + e.getStackTraceString();
			HaparaSendEmailNotification.SendAdminErrorEmail('bookSession', error, Apexpages.currentPage().getUrl());
			System.debug(error);    		
   		}
		return newPage;
	}
	
	private Contact createEventAttendee(string email, string title, string name, map<string,Contact> check){
		Contact cont;
		if(!string.isEmpty(email) ){
				email = email.trim().toLowerCase();
				string[] contactName = name.trim().split(' ');
				title = title.trim();
				if(!check.containsKey(email)){
					cont = new Contact();
					cont.email = email;
					if(contactName.size()>1){
						cont.firstName = contactName[0];
						cont.lastName = contactName[1];
					}else
						cont.lastName = contactName[0];
					
					cont.title=title;
					insert cont;
				}else
					cont = check.get(email);
			}
		return cont;
	}
	
	public PageReference cancelBookedSession(){
		PageReference newPage = null;
		boolean cancelled = false;
		system.debug('***cancelBookedSession: timezone: ' +selectedContactTimeZone + '; eventid='+selectedEventId);	
		string id = ApexPages.currentPage().getParameters().get('id');
		try{
			if(currentBookedSession!=null){
				list<Hapara_Scheduling_Session__c> evt =[Select h.Status__c, h.Start_Datetime__c, h.Id, h.Hapara_Scheduling_Type__c, 
									h.Engineer__r.Name, h.Engineer__c, h.End_Datetime__c, h.Customer_Contact__c ,
									h.Customer_Contact_4__c, h.Customer_Contact_3__c, h.Customer_Contact_2__c
									From Hapara_Scheduling_Session__c h
									where  h.Id =:currentBookedSession.id];
				if(evt.size()>0){
					Hapara_SchedulingSetupHandler.sendBookSessionInvite(
		            	HAPARA_CONST.SETTING_SCHEDULE.Setup_Cancellation_Email__c,
		            	evt[0].Id,HAPARA_CONST.CAMPAIGNMEMBER_STATUS_CANCELLED);
		            	
					evt[0].Customer_Contact__c = null;
					evt[0].Status__c = 'Free';
					update evt;
					
					cancelled = true;
				}
				
			}
			if(!cancelled){
				Apexpages.addMessage(new ApexPages.message(ApexPages.severity.Error,
		   					'No booking to cancel. Please book another session.'));
			}else{
				Apexpages.addMessage(new ApexPages.message(ApexPages.severity.Info,
		   					'Session has been cancelled please choose another date for your setup.'));
			}
			 newPage = new Pagereference(getSchedulingSetupFormURL());
		}catch(Exception e){
			string error ='***bookSession: timezone: ' +selectedContactTimeZone + '; eventid='+selectedEventId
			 +'\n\n ERROR:'+  e.getMessage() 
			+ '\n\n//-- Stack Trace --//\n' + e.getStackTraceString();
			HaparaSendEmailNotification.SendAdminErrorEmail('bookSession', error, Apexpages.currentPage().getUrl());
			System.debug(error);    		
   		}
		
		return newPage;
	}
	
	
	private string getSchedulingSetupFormURL(){
		return HAPARA_CONST.CUSTOMER_PORTAL_SCHEDULINGSETUPBOOKING_URL + getURLParameters();
	}
	public string getURLParameters(){
   		string url = '?id='+ ApexPages.currentPage().getParameters().get('id');
   		
   		if(ApexPages.currentPage().getParameters().containsKey('ScheduleType')){
	        	scheduleType =  ApexPages.currentPage().getParameters().get('ScheduleType');
   		}
   		if(!string.isEmpty(scheduleType)){
   			url =url+'&ScheduleType='+scheduleType;
   		}
   		return url;  	
   }
   
   public PageReference backToConfirmPage(){
   		 PageReference newPage = new Pagereference(getSchedulingSetupFormURL());
   		 return newPage;
   }
}