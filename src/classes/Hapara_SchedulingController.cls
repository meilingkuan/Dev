public with sharing class Hapara_SchedulingController {
	private Contact currentContact;
	private list<Campaign> campaigns;
	private list<CampaignMember> currentBooking;
	private CampaignMember newBooking;
	private Contact tempContact;
	private Lead currentLead;
	private string redirectContact ;
	private Account currentAccount;
		
	public string selectedContactTimeZone{get;set;}
	public string selectedContactDateTimeDemo{get;set;}
	public string selectedCampaignId{get;set;}
	public string selectedCountry{get;set;}
	public string selectedState{get;set;}
	public string referredContact1Name{get;set;}
	public string referredContact1Email{get;set;}
	public string referredContact1Organisation{get;set;}
	public string referredContact2Name{get;set;}
	public string referredContact2Email{get;set;}
	public string referredContact2Organisation{get;set;}
	public string referredContact3Name{get;set;}
	public string referredContact3Email{get;set;}
	public string referredContact3Organisation{get;set;}
	
	public Hapara_SchedulingController(){
	}	
	
	public CampaignMember getNewBooking(){
		if(newBooking == null){
			system.debug('***getNewBooking - creating a new member');
			newBooking = new CampaignMember();
		}
			
		return newBooking;
	}
	 
	public Contact getTempContact(){
		if(tempContact == null)
			tempContact = new Contact();
			
		return tempContact;
	}
	
	public PageReference checkContactId(){
		PageReference newPage = null;
    	string id = ApexPages.currentPage().getParameters().get('id');
    	string recordType = ApexPages.currentPage().getParameters().get('type');
    	
    	System.debug('***checkContactId() - id = ' +id + ' type=' + recordtype);
    	if(id == null || id=='null' ){
    		newPage =  new PageReference(HAPARA_CONST.CUSTOMER_PORTAL_UNAUTHOIZE_URL);
    		newPage.setRedirect(true);  		
    	}else{
    		if(recordType=='Lead')
    		{
    			if(getLeadRecord() == null){
    				System.debug('***checkContactId() - Cannot find lead id = ' +id);
		   			newPage =  new PageReference(HAPARA_CONST.CUSTOMER_PORTAL_UNAUTHOIZE_URL);
		    		newPage.setRedirect(true);
    			}
    			else if(!string.isEmpty(redirectContact)){
    				System.debug('***checkContactId() - redirect to contact url= ' +redirectContact);
    				newPage =  new PageReference(redirectContact);
		    		newPage.setRedirect(true);
    			}
    		}
    		else{
	    		if(getContactRecord('')==null){
	    			System.debug('***checkContactId() - Cannot find contact id = ' +id);
		   			newPage =  new PageReference(HAPARA_CONST.CUSTOMER_PORTAL_UNAUTHOIZE_URL);
		    		newPage.setRedirect(true);
	   			}
    		}
    	}
    	return newPage;
	}
	
	public Lead getLeadRecord(){
		string id = ApexPages.currentPage().getParameters().get('id');
		system.debug('***getLeadRecord:id ='+id);
		redirectContact = '';
		if(currentLead == null){
			currentLead = [Select l.LastName, l.FirstName, l.Email, l.ConvertedContactId ,l.Prospect_Timezone__c,l.IsConverted, l.company,
				 	l.State, l.PostalCode, l.Phone, l.Country, l.City , l.Street,l.How_did_you_hear_about_us__c
					From Lead l where id=:id ];
			currentBooking = new list<CampaignMember>();
			//check if the lead has been converted 
			if(currentLead.ConvertedContactId != null){
				redirectContact = HAPARA_CONST.CUSTOMER_PORTAL_SCHEDULINGCONFIRM_URL + '?id='+ currentLead.ConvertedContactId + '&type=Contact';
			}else{
		    	selectedContactTimeZone = currentLead.Prospect_Timezone__c;
		    	setContactDetails(currentLead.phone, currentLead.street,currentLead.city, currentLead.state, currentLead.PostalCode, 
		    		currentLead.country,currentlead.How_did_you_hear_about_us__c);
			}
			getNewBooking();
		}
		return currentLead;
	}
	
	public void setContactDetails(string phone, string street, string city, string state, string postcode, string country, string howyouhearaboutus){
		system.debug('***setContactDetails:setting details');
		getTempContact().phone = phone;
		getTempContact().mailingstreet= street;
		getTempContact().mailingcity= city;
		selectedState = state;
		getTempContact().mailingPostalCode = postcode;
		selectedCountry = country;
		getTempContact().How_did_you_hear_about_us__c = howyouhearaboutus; 
	}
	
	public Contact getContactRecord(string convertedId){		
		string id = string.isEmpty(convertedId)? ApexPages.currentPage().getParameters().get('id'):convertedId;
		system.debug('***getContactRecord:id ='+id);
		if(currentContact == null){
			currentContact = [Select c.LastName, c.FirstName, c.Email, c.TimeZone__c,c.name,Contact_Date_Time_Demo__c,
			
					c.AccountId,c.Account.TimeZone__c,c.Requested_Demo_Session__c, c.Account.BillingStreet, c.Account.BillingState,
					c.Account.BillingPostalCode, c.Account.BillingCountry, c.Account.BillingCity,c.Account.Phone,c.Account.How_did_you_hear_about_us__c,
					c.Hapara_Demo_Scheduling_URL__c,c.How_did_you_hear_about_us2__c,
					
					(Select cm.Status, cm.Contact_Local_Date_Time__c, cm.ContactId, cm.Campaign.RecordTypeId,
				 		cm.CampaignId,cm.Invite_Colleague_Emails__c
				 		From CampaignMembers cm
				 		where cm.Campaign.RecordTypeId  =:  HAPARA_CONST.SETTING_SCHEDULE.Campaign_Record_Type_Id__c 
				 	)
					From Contact c
					where id =:id ];
			currentBooking=currentContact.CampaignMembers;
			currentAccount = currentContact.account;
			getNewBooking();
			system.debug('***getContactRecord:currentBooking ='+currentBooking.size());
			
			if(currentBooking.size()>0)	{ 
				getNewBooking().CampaignId = currentBooking[0].CampaignId;
				getNewBooking().Status = currentBooking[0].STatus;
				getNewBooking().Invite_Colleague_Emails__c = currentBooking[0].Invite_Colleague_Emails__c;
				getNewBooking().Contact_Local_Date_Time__c = currentBooking[0].Contact_Local_Date_Time__c;
				selectedCampaignId = currentBooking[0].CampaignId;
				selectedContactDateTimeDemo = currentBooking[0].Contact_Local_Date_Time__c;
			}else{
				if(string.isEmpty(convertedId)){
					selectedCampaignId='';
					selectedContactDateTimeDemo='';
				}
			}
			if(string.isEmpty(convertedId)){
				getTempContact().Requested_Demo_Session__c = currentContact.Requested_Demo_Session__c ;
				getTempContact().How_did_you_hear_about_us2__c = currentContact.How_did_you_hear_about_us2__c;
				getCurrentBookingStatus();
				selectedContactTimeZone = string.isEmpty( currentContact.Timezone__c)? currentContact.Account.TimeZone__c:currentContact.Timezone__c;
				setContactDetails(currentContact.Account.Phone, currentContact.Account.BillingStreet, currentContact.Account.Billingcity, 
					currentContact.Account.Billingstate, currentContact.Account.BillingPostalCode, currentContact.Account.Billingcountry, 
					currentContact.Account.How_did_you_hear_about_us__c);
			}
			system.debug('***getContactRecord:selectedCampaignId ='+selectedCampaignId 
				+ ' selectedContactDateTimeDemo='+ selectedContactDateTimeDemo +' selectedContactTimeZone = '+selectedContactTimeZone);
			
		}
		return currentContact;
	}
	
	public void getCurrentBookingStatus(){ 
		
		if(!string.isEmpty(getNewBooking().Status)){
			if(getNewBooking().Status ==HAPARA_CONST.CAMPAIGNMEMBER_STATUS_CONFIRMED)
				Apexpages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,
   						'This booking has been confirmed.'));
   			else if (getNewBooking().Status ==HAPARA_CONST.CAMPAIGNMEMBER_STATUS_UNCONFIRMED)
   				Apexpages.addMessage(new ApexPages.message(ApexPages.severity.INFO,
   						'This booking has not been confirmed. Please click on Confirm button and we will send through meeting information.'));
		}
		else
			Apexpages.addMessage(new ApexPages.message(ApexPages.severity.Info,
   					'No current booking, please select a demo session and click on Confirm button.'));	
		
	}
	
	public list<Campaign> getCampaigns(){
		Date next2weeks = Date.today().addDays(6*7);
		system.debug('***getCampaigns:date filter today= ' + Date.Today().format() + ' next2weeks='+next2weeks.format());
		if(campaigns == null){
			if(currentBooking != null && currentBooking.size()>0)
				campaigns = [Select c.Type, c.Status, c.StartDate, 
					c.Schedule_Meeting_Connection_Details__c, 
					c.RecordTypeId, c.Next_Scheduled__c, c.Name, c.IsDeleted, c.IsActive, c.Id, c.EndDate, 
					c.Demo_Time__c, c.Demo_Time_Zone__c, c.Demo_Presenter__c, c.Demo_Day__c, 
					c.Create_Next_Demo__c, c.Copied_From_Campaign__c ,
					(Select Id From CampaignMembers) 
					From Campaign c
					where( ( c.EndDate >: Date.today() and c.EndDate <=: next2weeks) Or c.Id =: currentBooking[0].CampaignId )
					and c.RecordTypeId =:  HAPARA_CONST.SETTING_SCHEDULE.Campaign_Record_Type_Id__c and c.IsActive = true 
					order by c.EndDate
					];
			else
				campaigns = [Select c.Type, c.Status, c.StartDate, 
					c.Schedule_Meeting_Connection_Details__c, 
					c.RecordTypeId, c.Next_Scheduled__c, c.Name, c.IsDeleted, c.IsActive, c.Id, c.EndDate, 
					c.Demo_Time__c, c.Demo_Time_Zone__c, c.Demo_Presenter__c, c.Demo_Day__c, 
					c.Create_Next_Demo__c, c.Copied_From_Campaign__c ,
					(Select Id From CampaignMembers) 
					From Campaign c
					where c.IsActive = true 
					and c.RecordTypeId =:  HAPARA_CONST.SETTING_SCHEDULE.Campaign_Record_Type_Id__c
					and c.EndDate >: Date.today() and c.EndDate <=: next2weeks 
					order by c.EndDate
					];
		}
		system.debug('***getCampaigns:date filter campaigns= ' + campaigns.size());
		return campaigns;
	}
	
	public string getDemoSession(){
		string result='';
		integer campaignMemberCounter ;
		for(Campaign c : getCampaigns()){
			campaignMemberCounter = 0;
			for(CampaignMember m : c.CampaignMembers ){
				campaignMemberCounter=campaignMemberCounter+1;
			}
			if(campaignMemberCounter <26)
				result =result+ '\'' + c.Id +'\' : \''+  c.name +'\',';
		}
		if(result.length()>0)
			result = result.left(result.length()-1);
			
		system.debug('***getDemoSession:campaigns string= ' + result);
		return result;
	}
	
	list<Campaign> campaignEvents;
	public List<SelectOption> getCampaignEvents(){
		return Hapara_UtilityCommonRecordAccess.getCampaignEvents(campaignEvents);
	}
	
	public PageReference bookSession(){
		PageReference page = new Pagereference(getScheduleMsgFormURL());
		CampaignMember tobesaved;
		boolean insertNew = false;
		string recordType = ApexPages.currentPage().getParameters().get('type');
    	
		system.debug('***bookSession: selectedcampaignId=' + selectedCampaignId + ' ContactTimeZone:' + selectedContactTimeZone
				+ ' Requested_Demo_Session__c:' + getTempContact().Requested_Demo_Session__c + ' recordType=' +recordType);
		
		try{
			
			if(!string.isEmpty(selectedCampaignId) != null && !string.isEmpty(selectedContactTimeZone)){
				if(currentLead != null && recordType =='Lead'){
					//convert the lead and then continue booking
					if(!currentLead.IsConverted ){
						convertLead();
					}
				}else{
					system.debug('***bookSession: update current account address details');
					currentAccount.BillingStreet = getTempContact().mailingstreet;
					currentAccount.BillingCity = getTempContact().mailingcity;
					currentAccount.BillingState = selectedState;
					currentAccount.BillingCountry = selectedCountry;
					currentAccount.BillingPostalCode= getTempContact().mailingpostalcode;
					currentAccount.Phone = getTempContact().phone;
					currentAccount.How_did_you_hear_about_us__c = getTempContact().How_did_you_hear_about_us__c;
					update currentAccount;
				}
				getNewBooking().CampaignId = selectedCampaignId;
				currentContact.Timezone__c = selectedContactTimeZone;
				currentContact.phone = getTempContact().phone;
				currentContact.How_did_you_hear_about_us__c= getTempContact().How_did_you_hear_about_us__c;
				currentContact.How_did_you_hear_about_us2__c=getTempContact().How_did_you_hear_about_us2__c;
				currentContact.Requested_Demo_Session__c= getTempContact().Requested_Demo_Session__c;
				
				getTempContact().Timezone__c = selectedContactTimeZone;
				getTempContact().Contact_Date_Time_Demo__c = selectedContactDateTimeDemo;
				getNewBooking().Contact_Local_Date_Time__c = selectedContactDateTimeDemo;
				
				currentContact.Contact_Date_Time_Demo__c = getTempContact().Contact_Date_Time_Demo__c;
				update currentContact;
				
				if(currentBooking.size()>0){
					system.debug('***bookSession: selectedcampaignId=' + selectedCampaignId + ' currentBookingId:'+selectedCampaignId);
					tobesaved = currentBooking[0];
					if(tobesaved.CampaignId != selectedCampaignId){
						delete tobesaved;
						currentBooking.remove(0);
						insertNew = true;
					}else{
						system.debug('***bookSession: confirmed current booking');
						tobesaved.Status = HAPARA_CONST.CAMPAIGNMEMBER_STATUS_CONFIRMED;
						tobesaved.Contact_Local_Date_Time__c = getNewBooking().Contact_Local_Date_Time__c;
						tobesaved.Contact_Question__c = getNewBooking().Contact_Question__c;
						tobesaved.Invite_Colleague_Emails__c = getNewBooking().Invite_Colleague_Emails__c;
						update tobesaved;
						Hapara_SchedulingHandler.SendEmailOnDemoCampaign(tobesaved.CampaignId, 
							HAPARA_CONST.SETTING_SCHEDULE.Schedule_Confirmation_Email_Template__c, tobesaved.Id);
						Apexpages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 
							'Booking is confirmed and an email has been sent to you with the meeting details.'));
					}
				}else{
					insertNew =true;
				}
					
				if(insertNew){
					system.debug('***bookSession: create new booking');
					tobesaved = new CampaignMember();
					tobesaved.CampaignId = getNewBooking().CampaignId;
					tobesaved.ContactId = currentContact.Id;
					tobesaved.Contact_Local_Date_Time__c = getNewBooking().Contact_Local_Date_Time__c;
					tobesaved.Contact_Question__c = getNewBooking().Contact_Question__c;
					tobesaved.Invite_Colleague_Emails__c = getNewBooking().Invite_Colleague_Emails__c;
					tobesaved.Status = HAPARA_CONST.CAMPAIGNMEMBER_STATUS_CONFIRMED;
					insert tobesaved;
					if(currentBooking.size()>0)
						currentbooking[0] = tobesaved;
					else
						currentbooking.add(tobesaved);
					//send meeting details
					Hapara_SchedulingHandler.SendEmailOnDemoCampaign(getNewBooking().CampaignId, 
						HAPARA_CONST.SETTING_SCHEDULE.Schedule_Confirmation_Email_Template__c, tobesaved.Id);
					Apexpages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 
							'Booking is confirmed and an email has been sent to you with the meeting details.'));
				}					
				CreateLeadReferrals(currentContact.email);
			}else{
				Apexpages.addMessage(new ApexPages.message(ApexPages.severity.Error,
	   					'Please select a demo session in your timezone.'));	
			}
		}catch(Exception e){
    		string error ='***bookSession: '+  e.getMessage() + '\n\n//-- Stack Trace --//\n' + e.getStackTraceString();
			HaparaSendEmailNotification.SendAdminErrorEmail('bookSession', error, Apexpages.currentPage().getUrl());
			Apexpages.addMessage(new ApexPages.message(ApexPages.severity.Error,
	   					'We seem to be experiencing some problem with our site please contact customer.service@hapara.com if you need any support. We are working on this problem now and hope to get the site up soon.'));	
			System.debug(error);
    		return page;
   		}
		return page;
	}
	
	public void convertLead(){
		//check the lead and see if has been converted or not
		
		Lead lead = [select id,IsConverted from Lead where id=:currentLead.Id ];
		if(!lead.IsConverted){
		
			system.debug('***convertLead: converting lead ');
			boolean oppCreate = true;
			currentlead.Prospect_Timezone__c = selectedContactTimeZone;
			currentlead.Street = getTempContact().mailingstreet;
			currentlead.City = getTempContact().mailingcity;
			currentlead.State = selectedstate;
			currentLead.PostalCode = getTempContact().mailingpostalcode;
			currentLead.Country =selectedCountry;
			currentlead.Phone = getTempContact().phone;
			currentLead.How_did_you_hear_about_us__c = getTempContact().How_did_you_hear_about_us__c;
			currentlead.How_did_you_hear_about_us2__c = getTempContact().How_did_you_hear_about_us2__c;
			update currentlead;
			
	        Database.LeadConvert lc = new Database.LeadConvert();
	        lc.setLeadId(currentLead.Id);
	        lc.setConvertedStatus(HAPARA_CONST.LEAD_CONVERTED_STATUS);
	        lc.setOwnerId(HAPARA_CONST.SETTING_RESELLER.Reseller_Scheduling_User_Id__c);
	        //check if there is an existing account and if the account's contact has this contact
	        system.debug('***convertLead: company=' + currentLead.company + ' country=' + currentlead.Country + ' state=' + currentLead.state
	        			+ ' email=' + currentLead.email);
	        list<Account> acc = [select Id from Account where name=: currentLead.Company.trim() 
	        			and BillingState=: currentLead.state.trim() and BillingCountry=: currentlead.Country.trim() limit 1];
	        if(acc.size() >0 ){
	        	lc.setAccountId(acc[0].Id);
	        	list<Contact> con =[select Id from Contact where accountId =: acc[0].Id and email=: currentLead.email.trim() limit 1];
	        	if(con.size()>0)
	        		lc.setContactId(con[0].Id);
	        	//check if the account has an opportunity already??
	        	list<Opportunity> opp =[select Id from Opportunity where accountId=: acc[0].Id limit 1];
	        	
	        	if(opp.Size()>0){
	        		  lc.setDoNotCreateOpportunity(true);
	        		  oppCreate= false;
	        	}
	        }
	       
	        
	        if(oppCreate){
		        lc.setOpportunityName(HAPARA_CONST.LEAD_DEFAULT_OPP_STATE);
	        }   
		    Database.LeadConvertResult lcr = Database.convertLead(lc);     
		        
		    if (lcr.opportunityId != null && opportunity.StageName != null) {
		        Hapara_SchedulingHandler.updateOpportunityAfterConvert(lcr.opportunityId,  currentLead, lcr.ContactId,  HAPARA_CONST.OPPORTUNITY_STAGE_DEMONSTRATION, 
			            		 HAPARA_CONST.LEAD_DEFAULT_OPP_STATE);
		    }
	        
	        Hapara_SchedulingHandler.updateAccountAfterConvert( lcr.AccountId,currentLead);
	        
	        currentLead = [Select l.LastName, l.FirstName, l.Email, l.ConvertedContactId ,l.Prospect_Timezone__c,l.IsConverted
						From Lead l where id=:currentLead.Id ];
	        getContactRecord(lcr.contactId);
		}
	}
	
	private void CreateLeadReferrals(string customerEmail){
		system.debug('***CreateLeadReferrals:referredContact1Email='+ referredContact1Email+
			' referredContact2Email=' + referredContact2Email + 'referredContact3Email ='+referredContact3Email);
		list<Lead> insertLead = new list<Lead>();
		QueueSobject q =[Select Id, q.Queue.Name,q.Queue.ID from QueueSobject q where q.Queue.ID=:HAPARA_CONST.SETTING_SCHEDULE.Queue_General_Enquiry__c];
		
		if(!string.isEmpty(referredContact1Email) && referredContact1Email.trim().tolowercase() != customerEmail.tolowercase() ){
			Lead l; l = new Lead();
			l.email = referredContact1Email;
			l.lastname = referredContact1Name;
			l.company = referredContact1Organisation;
			l.description = 'referred by ' + currentContact.firstName + ' ' + currentContact.LastName + ' ('+customerEmail+')';
			l.Referral_Contact__c = currentContact.Id;
			l.OwnerId = HAPARA_CONST.SETTING_SCHEDULE.Queue_General_Enquiry__c;
			l.Lead_Queue__c = q.Queue.Name;
			insertLead.add(l);
		}
		if(!string.isEmpty(referredContact2Email)&& referredContact2Email.trim().tolowercase() != customerEmail.tolowercase()){
			Lead l2 = new Lead();
			l2.email = referredContact2Email;
			l2.lastname = referredContact2Name;
			l2.company = referredContact2Organisation;
			l2.description = 'referred by ' + currentContact.firstName + ' ' + currentContact.LastName+ ' ('+customerEmail+')';
			l2.Referral_Contact__c = currentContact.Id;
			l2.OwnerId = HAPARA_CONST.SETTING_SCHEDULE.Queue_General_Enquiry__c;
			l2.Lead_Queue__c = q.Queue.Name;
			insertLead.add(l2);
		}
		if(!string.isEmpty(referredContact3Email)&& referredContact3Email.trim().tolowercase() != customerEmail.tolowercase()){
			Lead l3 = new Lead();
			l3.email = referredContact3Email;
			l3.lastname = referredContact3Name;
			l3.company = referredContact3Organisation;
			l3.description = 'referred by ' + currentContact.firstName + ' ' + currentContact.LastName + ' ('+customerEmail+')';
			l3.Referral_Contact__c = currentContact.Id;
			l3.OwnerId = HAPARA_CONST.SETTING_SCHEDULE.Queue_General_Enquiry__c;
			l3.Lead_Queue__c = q.Queue.Name;
			insertLead.add(l3);
		}
		system.debug('***CreateLeadReferrals: insertLead=' + insertLead.size());
		if(insertLead.size()>0)
			insert insertLead;
		
		for(Lead t:insertLead){
			Hapara_SchedulingHandler.SendInternalLeadRegistrationEmail(t);
		}
	}
	
	public PageReference cancelSession(){
		PageReference page = new Pagereference(getScheduleMsgFormURL());
		try{
			if(currentBooking.size()>0){
				CampaignMember c = currentBooking[0];
				delete c;
				currentBooking.remove(0);
				selectedCampaignId = '';
				HaparaSendEmailNotification.SendContactEmail(currentContact,
					HAPARA_CONST.SETTING_SCHEDULE.Schedule_Cancel_Email_Template__c, 
					currentContact.Account, null);
				
				Apexpages.addMessage(new ApexPages.message(ApexPages.severity.confirm,
	   					'Your booking has been cancelled. If you wish to book another session we have send you an email to rebook so please come back to choose another time.'));	
			}else{
				Apexpages.addMessage(new ApexPages.message(ApexPages.severity.Error,
	   					'No session booking to be cancelled.'));	
			}
			if(currentContact == null){
				page = new Pagereference(getScheduleConfirmationURL());
				page.setRedirect(false);   
			}
		}catch(Exception e){
			string error ='***cancelSession: '+  e.getMessage() + '\n\n//-- Stack Trace --//\n' + e.getStackTraceString();
			HaparaSendEmailNotification.SendAdminErrorEmail('cancelSession', error, Apexpages.currentPage().getUrl());
			System.debug(error);
    		Apexpages.addMessage(new ApexPages.message(ApexPages.severity.Error,
	   					'We seem to be experiencing some problem with our site please contact customer.service@hapara.com if you need any support. We are working on this problem now and hope to get the site up soon.'));	
    		return page;
   		}
		return page;
	}
	
	private string getScheduleConfirmationURL(){
		return HAPARA_CONST.CUSTOMER_PORTAL_SCHEDULINGCONFIRM_URL + getURLParameters();
	}
	
	public string getURLParameters(){
   		string url = '?id='+ ApexPages.currentPage().getParameters().get('id');
   		
   		if(ApexPages.currentPage().getParameters().containsKey('type')){
	        	url =url+'&type='+ ApexPages.currentPage().getParameters().get('type');
   		}
   		return url;  	
   }
   
   public string getScheduleMsgFormURL(){
   		return HAPARA_CONST.CUSTOMER_PORTAL_SCHEDULINGCONFIRM_MSG_URL + getURLParameters();
   }
   
   public PageReference backToConfirmPage(){
   	 	PageReference page = new Pagereference(getScheduleConfirmationURL());
   	 	page.setRedirect(true);
   	 	return page;
   }
}