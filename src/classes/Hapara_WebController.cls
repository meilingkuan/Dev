public class Hapara_WebController {
	public string[] invalidEmails=new string[]{'gmail.com','yahoo.com','aol.com','hotmail.com'};
	public string selectedCountry{get;set;}
	public string selectedState{get;set;}
	
	public Hapara_WebController(){
		system.debug('***Hapara_WebController: url='+ApexPages.currentPage().getUrl());
		if(ApexPages.currentPage().getUrl().contains(HAPARA_CONST.CUSTOMER_HAPARAWEB_CUSTOMERENQUIRY)){
			getExistingCustomer();
			tempCustomer.Question_Copied_From_Lead__c = ApexPages.currentPage().getParameters().get('Question_from_Lead__c');
		}else
			getLead();
	}
	
	public string getTitle(){
		string title =ApexPages.currentPage().getParameters().containsKey('Title')?
			 ApexPages.currentPage().getParameters().get('Title'):'';
		if(title.contains('Contact us'))
			title = 'Contact Us About Our Product';
		system.debug(title);
		if(string.isEmpty(title))
			title='Contact Us About Our Product';
		
		return title;
	}
	
	
	Contact tempCustomer;
	public Contact getExistingCustomer(){
		if(tempCustomer == null) {
			tempCustomer = new Contact();
		}
		return tempCustomer;
	}
		
	Lead currentLead;
	public Lead getLead(){
   		if(currentLead == null) {
   			currentLead = new Lead();	
   		}
      	return currentLead;
   	}
   	
   	list<Campaign> campaignEvents;
	public List<SelectOption> getCampaignEvents(){
		return Hapara_UtilityCommonRecordAccess.getCampaignEvents(campaignEvents);
	}
	
	private boolean ValidateLead(){
		boolean validated = true;
		//validate email
		if(currentLead.email.length()>0){
			string email = currentLead.email;
			if(!email.contains('@')){
				Apexpages.addMessage(new ApexPages.message(ApexPages.severity.Error,
   						'Please enter a valid institution email.'));
   				validated = false;
			}
   			else{
   				for(integer i=0; i < invalidEmails.size(); i++){
   					if(email.contains(invalidEmails[i])){
   						Apexpages.addMessage(new ApexPages.message(ApexPages.severity.Error,
   						'Institution email cannot be personal email.'));
   						validated = false;
   					}
   				}
   			}
   		
   			if(string.isEmpty(selectedCountry)){
   				Apexpages.addMessage(new ApexPages.message(ApexPages.severity.Error,
   						'Country cannot be empty.'));
   				validated = false;
   			}

   			if(string.isEmpty(selectedState)){
   				Apexpages.addMessage(new ApexPages.message(ApexPages.severity.Error,
   						'State cannot be empty.'));
   				validated = false;
   			}
   			string company = currentLead.Company;
   			if(string.isEmpty(company)){
   				Apexpages.addMessage(new ApexPages.message(ApexPages.severity.Error,
   						'Company cannot be empty.'));
   				validated = false;
   			}
		}
		system.debug('***ValidateLead: validated=' + validated);
		return validated;
	}
	
	public PageReference saveSignUpforDemo(){
		PageReference page = ApexPages.currentPage();
		system.debug('***saveSignUpforDemo: email=' + currentLead.email + ' country:'+ selectedCountry + '; title=' + getTitle());
		boolean successfulSave = false;
		QueueSobject q;
		if(getTitle().toLowerCase().contains('sign'))
		  	q =[Select Id, q.Queue.Name,q.Queue.ID from QueueSobject q where q.Queue.ID=:HAPARA_CONST.SETTING_SCHEDULE.Queue_Demo__c];
		else if(getTitle().toLowerCase().contains('started'))
			q =[Select Id, q.Queue.Name,q.Queue.ID from QueueSobject q where q.Queue.ID=:HAPARA_CONST.SETTING_SCHEDULE.Queue_Setup__c];
		else
			q =[Select Id, q.Queue.Name,q.Queue.ID from QueueSobject q where q.Queue.ID=:HAPARA_CONST.SETTING_SCHEDULE.Queue_General_Enquiry__c];
			 
		Lead tempLead;
		system.debug('***saveSignUpforDemo: queue name='+q.Queue.Name);
		try{
			if(ValidateLead()){
				Contact existingCustomer;
				existingCustomer = checkExistingCustomer();
				system.debug('***saveSignUpforDemo: existingCustomer=' +existingCustomer);
				if(existingCustomer == null){
					
					tempLead = checkIfDuplicatedlead();
					if(tempLead == null){
						tempLead = currentLead;
						templead.ownerId = q.Queue.ID;
						tempLead = currentLead;
						templead.Question_from_Lead__c = Date.today().format() +': ' +templead.Question_from_Lead__c;
						templead.Country = selectedCountry;
						templead.State = selectedState;
						templead.Lead_Queue__c = q.Queue.Name;
						templead.LeadSource = 'Web';
					    insert tempLead;
						successfulSave = true;
					}
					else{
						if(tempLead.Lead_Type__c != HAPARA_CONST.LEAD_TYPE_SUSPICIOUS){
							templead.ownerId =q.Queue.ID;
							templead.Question_from_Lead__c = Date.today().format()+': ' + currentLead.Question_from_Lead__c 
								+ '\n'+templead.Question_from_Lead__c; 
							templead.Country = selectedCountry;
							templead.State = selectedState;
							templead.Lead_Queue__c = q.Queue.Name;
							update tempLead;
							successfulSave = true;
						}  
					}
					system.debug('***saveSignUpforDemo: redirecting to=' + HAPARA_CONST.CUSTOMER_HAPARAWEB_THANKYOU);
					page = new PageReference(HAPARA_CONST.CUSTOMER_HAPARAWEB_THANKYOU);
					if(successfulSave){	
						//send lead notification
						HaparaSendEmailNotification.SendContactEmailRecipientIdwithBCCNSenderSetWhatId(templead.Id,HAPARA_CONST.SETTING_SCHEDULE.Sign_For_Demo_Lead_Notification__c, 
								null,null, 'Hapara Team', HAPARA_CONST.SETTING_SCHEDULE.Web_To_Lead_Nofications_Email__c, null);
						//send internal notification
						Hapara_SchedulingHandler.SendInternalLeadRegistrationEmail(templead);
					}
				}else{
					system.debug('***saveSignUpforDemo: redirecting to=' + HAPARA_CONST.CUSTOMER_HAPARAWEB_CUSTOMERENQUIRY + '?contactId=' + existingCustomer.Id);
					page = new PageReference(HAPARA_CONST.CUSTOMER_HAPARAWEB_CUSTOMERENQUIRY);
					page.setRedirect(true);
					page.getParameters().put('Question_from_Lead__c', currentLead.Question_from_Lead__c);
					page.getParameters().put('contactId', existingCustomer.Id);
				}
			}
		}catch(Exception e){
			string error ='***saveSignUpforDemo: '+  e.getMessage() + '\n\n//-- Stack Trace --//\n' + e.getStackTraceString();
			HaparaSendEmailNotification.SendAdminErrorEmail('saveSignUpforDemo', error, Apexpages.currentPage().getUrl());
			Apexpages.addMessage(new ApexPages.message(ApexPages.severity.Error,
	   					'We seem to be experiencing some problem with our site please contact customer.service@hapara.com if you need any support. We are working on this problem now and hope to get the site up soon.'));	
			System.debug(error);
    		return page;
		}
		return page;	
	}
	
	public Lead checkIfDuplicatedlead(){
		Lead tempLead = null;
		list<Lead> leads = [select firstname,lastname,email, title, company, website,industry,School_Type__c,How_did_you_hear_about_us__c,
			How_did_you_hear_about_us2__c,Question_from_Lead__c,Lead_Type__c
			from lead where email =: currentLead.email  and IsConverted = false
			order by createdDate desc limit 1
		 ];
		 system.debug('***checkIfDuplicatedlead: leads='+ leads.size());
		 if(leads.size()>0)
		 	tempLead = leads[0];
	
		return tempLead;
	}
	
	public Contact checkExistingCustomer(){
		Contact contact = null;
		list<Contact> contacts = [Select c.OwnerId,c.AccountId, c.Account.Name, c.Question_Copied_From_Lead__c, c.FirstName,c.lastName, c.Email From Contact c
			where c.email =: currentLead.email and  c.Account_Type__c like 'customer%' and (not c.Account_Type__c  like '%cold%')
			order by createdDate desc limit 1
		 ];
		  system.debug('***checkExistingCustomer: contacts='+ contacts.size());
		 if(contacts.size()>0)
		 	contact = contacts[0];
		
		return contact;
	}
	
	public PageReference saveContactComment(){
		PageReference page = ApexPages.currentPage();
		try{
			Id contactId = ApexPages.currentPage().getParameters().get('contactId');
			Contact contact = [Select c.OwnerId,c.AccountId, c.Account.Name, c.Question_Copied_From_Lead__c, c.FirstName,c.lastName, c.Email From Contact c
						where c.Id =: contactId 
					 ];
					 
			contact.Question_Copied_From_Lead__c = Date.today().format() +': ' +tempCustomer.Question_Copied_From_Lead__c + '/n'+contact.Question_Copied_From_Lead__c ;
			update contact;
			Task task = new Task();
			task.ActivityDate = Date.today().addDays(2);
			task.OwnerId =contact.OwnerId;
			task.WhatId = contact.AccountId;
			task.WhoId = contact.Id;
			task.Subject = 'Sales Query from:'+contact.FirstName + ' ' +contact.LastName +' at '  + contact.Account.Name;
			task.Description = tempCustomer.Question_Copied_From_Lead__c;
			task.priority= 'High';
			task.status = 'Not Started';
			
			 // The following 3 lines of code control whether the task notification is sent when the task is inserted
            Database.DMLOptions dmlo = new Database.DMLOptions();
            dmlo.EmailHeader.triggerUserEmail = true;
            database.insert(task, dmlo);
			page = new PageReference(HAPARA_CONST.CUSTOMER_HAPARAWEB_THANKYOU);
			
		}catch(Exception e){
			string error ='***saveContactComment: '+  e.getMessage() + '\n\n//-- Stack Trace --//\n' + e.getStackTraceString();
			HaparaSendEmailNotification.SendAdminErrorEmail('saveContactComment', error, Apexpages.currentPage().getUrl());
			Apexpages.addMessage(new ApexPages.message(ApexPages.severity.Error,
	   					'We seem to be experiencing some problem with our site please contact customer.service@hapara.com if you need any support. We are working on this problem now and hope to get the site up soon.'));	
			System.debug(error);
    		return page;
		}
		return page;	
	}
}