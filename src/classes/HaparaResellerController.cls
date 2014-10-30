public class HaparaResellerController {
	Account reseller;
	String unAuthorizeURL = '/apex/HaparaResellerUnAuthorize';
	String dealRegistrationURL = '/Reseller/HaparaRSDealRegistration';
	String welcomeURL = '/Reseller/HaparaRSWelcome';
	string sendRegistrationURL ='/Reseller/HaparaRSSendRegistrationReport';
	string updateRegistrationURL = '/Reseller/HaparaResellerUpdateRegistration';
	list<String> emailDomain = new list<string>();
	RecordType resellerType ;
	Opportunity opportunity;
   	OpportunityContactRole role;
   	Contact resellerRep;
   	Id repId;
   	Lead resellerLead;
   	list<Opportunity> registrations = new list<Opportunity>();
   	list<Reseller_Tier__c> tiers = new list<Reseller_Tier__c>();
   	
   	private ApexPages.StandardController stdCtrl {get; set;}
   	
   	string pageTitle='Welcome to Partner Portal';
   	public string getPageTitle(){
   		return pageTitle +' ' +getReseller().Name;
   	}
   	
   	string showWelcomePanel = 'No';
   	public string getShowWelcomePanel(){
   		return showWelcomePanel;
   	}
   	string showrepRegisterPanel='Yes';
   	public string getShowrepRegisterPanel(){
   		return showrepRegisterPanel;
   	}
   	
   	public boolean showPurchaseOrderButton{
   		get{return boolean.valueOf( getReseller().Can_Submit_Purchase_Order__c);}
   	}

    public boolean showSalesNotesButton{
   		get{return boolean.valueOf( getReseller().Can_Update_Notes__c);}
   	}
	
    public HaparaResellerController() {
    	system.debug('***HaparaResellerController: url '+ ApexPages.currentPage().getUrl());
    	resellerType = [SELECT Id FROM RecordType where DeveloperName = 'Reseller_Opportunity'];
    	getReseller();
    	showrepRegisterPanel = 'Yes';
    	filterRegistrationName = '';
    	filterRegistration='Rep';
    	if(reseller != null){
    		//ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'getting lead'));
	    	getResellerLead();
	    	resellerLead.Country = reseller.BillingCountry;
    	}
    	
    }
    
    
    public Account getReseller(){
    	string id = ApexPages.currentPage().getParameters().get('id');
    	system.debug('***getReseller: id=' + id); 
     	
    	try{
    		if(reseller !=null){
	    		checkRepId();
	    		return reseller;
    		}
	    	reseller = [SELECT Id, Name,BillingCountry,Internal_Reseller_Sales_Email__c,Reseller_s_Email_Domain__c,CurrencyIsoCode,
	    				 a.Reseller_Tier__r.Name,a.Reseller_Tier__r.Combination_Tier__c,a.Reseller_Tier__r.Description__c, 
	    				 a.Reseller_Tier__c,a.Can_Submit_Purchase_Order__c,a.Can_Update_Notes__c,OwnerId
	    				 FROM Account a
	                  	WHERE Id = :id];
	                  	
	        if(reseller.Reseller_s_Email_Domain__c != null){
	        	string emails = reseller.Reseller_s_Email_Domain__c;
	        	emailDomain = emails.split(';');
	        }
	             
	        checkRepId();      	
	       
    	}catch(Exception e){
    		HaparaSendEmailNotification.SendAdminErrorEmail('getReseller', e+'',Apexpages.currentPage().getUrl());
    		System.debug('***getReseller() - Cannot find account id = ' +id);
    		return null;
   		}
   		return reseller;
    }
    
    public boolean checkRepId(){
    	 if(ApexPages.currentPage().getParameters().containsKey('rep')){
	        	string repId = ApexPages.currentPage().getParameters().get('rep');
    			Contact rep = [select id, name,firstname,lastname,email,phone, mailingState, mailingCountry
    							from Contact where Id =:repId and accountId=:reseller.Id ];
    			
    			if(rep !=null){
    				resellerRep = rep;
     				showWelcomePanel = 'Yes';
    				return true;
    			}
    	 }
    	 return false;
    }
    
    
    public String getResellerSalesEmail(){
    	Account resellerAccount = getReseller();
    	String email = HaparaResellerUtilityCommon.getResellerSalesEmail(resellerAccount);
    	return email;
    }
    
   	
   	public Contact getResellerRep(){
   		if(resellerRep == null){
   			 resellerRep = new Contact();
   			 resellerRep.MailingCountry = getReseller().BillingCountry;
   		}
      	return resellerRep;
   	}
   	
   	public Lead getResellerLead(){
   		if(resellerLead == null) {
   			resellerLead = new Lead();	
   		}
      	return resellerLead;
   	}
   
    public Opportunity getOpportunity() {
      if(opportunity == null) opportunity = new Opportunity();
      opportunity.RecordTypeId=resellerType.Id;
      return opportunity;
   }

   public OpportunityContactRole getRole() {
      if(role == null) role = new OpportunityContactRole();
      return role;
   }
   
   
    public List<SelectOption> getResellerTier() {     
   		system.debug('***getResellerTier: '+ reseller.Reseller_Tier__c );
   		List<SelectOption> options = new List<SelectOption>();
		
		//options.add(new SelectOption('0001', '--Select--'));
		if(reseller.Reseller_Tier__c != null){
			if(tiers.size() ==0){
				if(reseller.Reseller_Tier__r.Combination_Tier__c){
					tiers = [Select r.Description__c, r.Id From Reseller_Tier__c r
							where r.Id in (Select c.Associated_to_Reseller_Tier__c 
							From Reseller_Tier_Associated__c c 
							 where c.Reseller_Tier__c =:reseller.Reseller_Tier__c) and r.IsActive__c = true ];
				}else{
					tiers.add(reseller.Reseller_Tier__r);
				}
			}
			
			for(Reseller_Tier__c c : tiers ){
				system.debug('***getResellerTier: options='+ c.id + c.Description__c);
			 	options.add(new  SelectOption(c.id, c.Description__c));
			 	
			} 
		}
		return options;
	}
	
   // This method cancels the wizard, and returns the user to the 
   // Opportunities tab
    public PageReference cancel() {
	  PageReference newPage = new PageReference(getWelcomeURL());
	  newPage.setRedirect(true);
	  return newPage;
    }
    
   public Opportunity ValidateExistingDealRegistration(){
   		System.debug('***ValidateExistingDealRegistration() - resellerLead.Company = '+resellerLead.Company + 
   					' resellerLead.State= '+resellerLead.State);
   		Opportunity result = null;
   		list<Opportunity> temp = [select o.Name, o.Size_of_Opportunity__c, o.Reseller_s_Status__c, 
	    				 o.Opportunity_Name_Template__c, o.Description ,o.Reseller_Tier__c,o.IsClosed ,
	    				 o.OwnerId,o.Owner.Name, o.Owner.email,
	    				 
	    				 o.Reseller_s_Rep__c, o.Reseller_s_Rep__r.Name,o.Reseller_s_Rep__r.Email,
	    				 o.Reseller_s_Rep__r.FirstName, o.Reseller_s_Rep__r.LastName,
	    				 
	    				 o.Account.Internal_Reseller_Sales_Email__c,o.AccountId,o.Account.Invoice_Contact__c,
	    				 o.Account.Reseller_Setup_Email_Temp_Name_Low_No__c,
	    				 o.Resellers_Account__c, 
	   
	    				 o.Resellers_Account__r.Website, o.Resellers_Account__r.BillingCountry, o.Resellers_Account__r.BillingPostalCode, 
	    				 o.Resellers_Account__r.BillingState, o.Resellers_Account__r.BillingCity, o.Resellers_Account__r.BillingStreet, 
	    				 o.Resellers_Account__r.Name, o.Resellers_Account__r.Domain_Comments__c,o.Resellers_Account__r.TD_Setup_Date__c,
	    				 o.Resellers_Account__r.Referral_Date__c,o.Resellers_Account__r.Referral__c,o.Resellers_Account__r.Referral_Contact__c,
	    				 o.Resellers_Account__r.Type,
	    				 
	    				 o.Resellers_Lead__r.Domain_Comments__c, o.Resellers_Lead__r.Website, o.Resellers_Lead__r.Email, o.Resellers_Lead__r.Phone, 
	    				 o.Resellers_Lead__r.Country, o.Resellers_Lead__r.PostalCode, o.Resellers_Lead__r.State, o.Resellers_Lead__r.City, 
	    				 o.Resellers_Lead__r.Street, o.Resellers_Lead__r.Company, o.Resellers_Lead__r.Title, o.Resellers_Lead__r.FirstName, 
	    				 o.Resellers_Lead__r.LastName, o.Resellers_Lead__c,o.Resellers_Lead__r.Job_Description__c, o.Resellers_Lead__r.IsConverted, 
	    				 o.Resellers_Lead__r.ConvertedContactId, o.Resellers_Lead__r.ConvertedAccountId,
	    				 
	    				 o.Reseller_s_Contact__r.Job_Description__c, o.Reseller_s_Contact__r.Email, o.Reseller_s_Contact__r.Phone, o.Reseller_s_Contact__r.FirstName,
	    				  o.Reseller_s_Contact__r.LastName, o.Reseller_s_Contact__c
   			from Opportunity o 
	   		where o.IsClosed = false and o.AccountId =:reseller.Id 
	   		 and  (o.Resellers_Account__r.Name =:resellerLead.Company or  o.Resellers_Lead__r.Company=: resellerLead.Company)
	   		 and  (o.Resellers_Account__r.BillingState =:resellerLead.State or  o.Resellers_Lead__r.State=: resellerLead.State)];
	   	if(temp.size()>0){
	   		result = temp[0];
	   		Account acc = result.Account;
	   		//if there is an existing opportunit we update this with the latest data.
	   		if(result.Reseller_s_Contact__c == null){ 				
   				result.Reseller_s_Contact__c= checkContactExistsOrCreate( acc.Id).Id;
	   		}
	   		
	   		result.Reseller_Tier__c = opportunity.Reseller_Tier__c;
	   		result.Size_of_Opportunity__c = opportunity.Size_of_Opportunity__c;
	   		result.Opportunity_Name_Template__c = opportunity.Opportunity_Name_Template__c;
	   		update result;
	   	}
   		return result;	
   }
   
  
    
   public PageReference SaveNewDealRegistration(){
   		PageReference newPage = null;
   		try{
   			if(string.isEmpty(resellerLead.State) || string.isEmpty(resellerLead.country)){
   				Apexpages.addMessage(new ApexPages.message(ApexPages.severity.Error,
   					'Customer must have Country and State populated.'));
   					return newPage;	
   			}
   			Opportunity opp = ValidateExistingDealRegistration();
   			if(opp ==null){
   				save(false);  
   				newPage = new PageReference(HAPARA_CONST.RESELLER_PORTAL_SUCCESSFULREGISTRATION_URL+getUrlParameters());
   				newPage.setRedirect(true);
   				
   			}
   			else
   				Apexpages.addMessage(new ApexPages.message(ApexPages.severity.Error,
   					'This registration is already pending with Hapara Inc. Please go to "Update Deals" to update it.'));	
   		}catch(Exception e){
   			HaparaSendEmailNotification.SendAdminErrorEmail('SaveNewDealRegistration',
   			 	 e.getMessage() 
   			 	 + '\n\n//-- Stack Trace --//\n' + e.getStackTraceString(),Apexpages.currentPage().getUrl());
			 PageReference errorPage =Page.Exception;
			 errorPage.setRedirect(true);
			 return errorPage;
   		} 		
   		    
	  	  return newPage;	
   }
   
    public PageReference SaveNewDealRegistrationNCreatePO(){
    	PageReference newPage = null;
    	System.debug('***SaveNewDealRegistrationNCreatePO() - starts');
   		try{
   			if(string.isEmpty(resellerLead.State) || string.isEmpty(resellerLead.country)){
   				Apexpages.addMessage(new ApexPages.message(ApexPages.severity.Error,
   					'Customer must have Country and State populated.'));
   					return newPage;	
   			}
   			Opportunity opp = ValidateExistingDealRegistration();
   			if(opp ==null){
   				save(true);  
   				newPage =new PageReference( 
	  							HAPARA_CONST.RESELLER_PORTAL_PURCHASEORDER_URL +getURLParameters()+'&activityId=' + opportunity.Id);
   			}else{
   				newPage =new PageReference( 
	  							HAPARA_CONST.RESELLER_PORTAL_PURCHASEORDER_URL +getURLParameters()+'&activityId=' + opp.Id);
   			}
   						
   		}catch(Exception e){
   			 HaparaSendEmailNotification.SendAdminErrorEmail('SaveNewDealRegistrationNCreatePO',
   			 	 e.getMessage() 
   			 	 + '\n\n//-- Stack Trace --//\n' + e.getStackTraceString(),Apexpages.currentPage().getUrl());
			 PageReference errorPage =Page.Exception;
			 errorPage.setRedirect(true);
			 return errorPage;
   		} 		
   		    
	  
	  newPage.setRedirect(true);
	  return newPage;	
   }
   
   private Contact checkContactExistsOrCreate(Id accId){
   		System.debug('***checkContactExistsOrCreate() - accId = ' +accId);
   		list<Contact> c = [Select c.LastName, c.Job_Description__c,AccountId, c.FirstName, c.Email From Contact c
					where c.Email=:resellerLead.Email and c.AccountId =: accId];
   		Contact con ;
   		boolean isNewCon = false;
   		if(!c.isEmpty())
   			con = c[0];
   		else{
   			isNewCon = true;
   			con = new Contact();
   			con.AccountId = accId;
   			con.email  = resellerLead.email;
   		}
   		con.FirstName = resellerLead.FirstName;
   		con.LastName = resellerLead.LastName;
   		con.Job_Description__c = resellerLead.Job_Description__c;
   				
   		if(isNewCon)
   			insert con;
   		else
   			update con;
   		return con;
   }

   // This method performs the final save for all four objects, and
   // then navigates the user to the detail page for the new
   // opportunity.
   public void save(boolean isCreatePO) {    	 		
   			string id = ApexPages.currentPage().getParameters().get('id');
    		string repId = ApexPages.currentPage().getParameters().get('rep');
    		System.debug('***save() - id = ' +id +'rep =' +repId);
			String opportunityName = reseller.Name + ' - ' + resellerLead.Company  +' - ' + opportunity.Opportunity_Name_Template__c;
   			opportunity.AccountId= id;
   			Contact rep = [select id, name from Contact where id =:repId limit 1];
   			rep.firstName = resellerRep.FirstName;
   			rep.lastName = resellerRep.LastName;
   			rep.email = resellerRep.Email;
   			rep.Phone = resellerRep.Phone;
   			rep.OwnerId = reseller.ownerId;
   			update rep;
   			 
   			//check if the school or email address exists in our system
   			System.debug('***save() - Check if account or contact exists');
   			list<Account> a = [select id, name,BillingCountry from Account 
   					where name = :resellerLead.Company and BillingState = : resellerLead.State
   					and BillingCountry=: resellerLead.Country limit 1];
   			string customerCountry ;
   			
   			if(!a.isEmpty()){
   				opportunity.Resellers_Account__c = a[0].Id;
   				opportunity.StageName = 'Found Account';
   				customerCountry = a[0].BillingCountry;
   			}
   			   			
   			if(a.isEmpty()){
   				list<Lead> dupLead = [select id, name,Referral__c,Referral_Contact__c,Referral_Date__c,LeadSource,Lead_Type__c,
   					CurrencyIsoCode,Country
   					from Lead where email =: resellerLead.Email and isConverted = false limit 1];
   				if(dupLead.isEmpty()){
	   				System.debug('***save() -insert Lead');
		   			resellerLead.Referral__c = reseller.Id;
		   			resellerLead.Referral_Contact__c = rep.Id;
		   			resellerLead.Referral_Date__c = Date.today();
		   			resellerLead.LeadSource ='Reseller Deal Registration';
		   			resellerLead.Lead_Type__c = 'Reseller Customer Prospect';
		   			resellerLead.CurrencyIsoCode= reseller.CurrencyIsoCode;
		   			resellerLead.OwnerId = reseller.OwnerId;
		   			customerCountry =resellerLead.Country;
		   			insert resellerLead;
		   			opportunity.Resellers_Lead__c = resellerLead.Id;
		   			opportunity.StageName = 'New Registration';
   				}else{
   					opportunity.Resellers_Lead__c = dupLead[0].Id;
   					opportunity.StageName = 'Found Lead';
   					customerCountry =dupLead[0].country;
   				}
	   			
   			}else{
   				opportunity.Reseller_s_Contact__c =checkContactExistsOrCreate( a[0].Id).Id;	
   			}
   			System.debug('***save() - Insert Opportunity');
   			
   			
   			List <Campaign> campaign = [select id, name from Campaign where name = :'Reseller/ Referral' limit 1];
			opportunity.Name =opportunityName;
			opportunity.CloseDate= Date.Today().addDays(90);
			opportunity.Probability=0;		
			opportunity.CampaignId=campaign[0].Id;
			opportunity.LeadSource= 'Reseller Deal Registration';		
			opportunity.Reseller_s_Rep__c = rep.Id;	
			opportunity.Reseller_s_Status__c = HAPARA_CONST.OPPORTUNITY_STATGE_RELLERPENDINGAPPROVAL;
			opportunity.CurrencyIsoCode= HaparaResellerUtilityCommon.getResellerCustomerCurrencyCode(customerCountry,getReseller().CurrencyIsoCode);
			opportunity.OwnerId = reseller.OwnerId;
			
			insert opportunity;
			opportunity.RecordTypeId = resellerType.Id;
			update opportunity;

     
      // Create the junction contact role between the opportunity
      // and the contact.
      		System.debug('***save() - Insert Contact Role');
      		getRole();
    	 	role.opportunityId = opportunity.id;
    		role.contactId =rep.Id;
    		role.Role = 'Reseller Representative';
    		role.IsPrimary=true;
    		insert role;
    		
    		System.debug('***save() - Updated contact with opportunity Name');
    		rep.Reseller_Registration_Details__c = opportunityName;
    		update rep;
    		
    		System.debug('***save() - Send Rep wiht email');
    		//sendRepEmail(rep);
    		
    		if(!isCreatePO){
	    		System.debug('***save() - Send Rep wiht email');
	    		HaparaSendEmailNotification.SendContactEmail(rep, HAPARA_CONST.SETTING_RESELLER.Deal_Registration_Email_Template__c,
	    			null,opportunity);
	    		HaparaResellerUtilityCommon.sendRSAdministratorEmail(  opportunity, getResellerSalesEmail(),
	    			'DEAL REGISTRATION','' );
    		}
   }
   
    public PageReference createResellerRep(){		
   		//check if the rep already exists in our system
   		System.debug('***createResellerRep() -create rep');	
   		try{
   			if(isValidRepEmail()){
		   		List <Contact> c = [select id, name,firstname,lastname,email,phone,mailingState,mailingCountry 
		   			from Contact 
		   			where Email = :resellerRep.Email and accountId=:reseller.Id limit 1];
		   		Contact rep;
		   		if(c.isEmpty()){
		   			resellerRep.AccountId = reseller.Id;
			   		insert resellerRep;
			   		repId = resellerRep.Id;
			   		rep = resellerRep;
		   		}else{
		   			repId = c[0].Id;  
		   			rep =c[0];
		   		}
			   	
		   		HaparaSendEmailNotification.SendContactEmail(rep,'Contact_Reseller_email_confirmation',reseller,null);
		   		showrepRegisterPanel= 'No';
		   		
   			}else{
   				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,
   					'Your email address is not registered with our system. Please contact our reseller team, at resellersales@hapara.com, to make sure our system is updated with your reseller details.'));
   				return null;
   			}		
   		}catch(Exception e){
   			HaparaSendEmailNotification.SendAdminErrorEmail('createResellerRep', e+'',Apexpages.currentPage().getUrl());  			
   		}   		
	  	return ApexPages.currentPage();		
   }
   
   private boolean isValidRepEmail(){
   		boolean result = false;
   		string repEmail = resellerRep.Email.trim();
   		string temp = repEmail.split('@')[1];
   		temp = temp.trim().toLowerCase();
	   	if(!temp.contains('hapara.com')){
	   		for(string domain : emailDomain){
	   			if(temp.contains(domain.trim().toLowerCase())){
	   				result = true;
	   				break;
	   			}
	   		}
   		}else
   			result = true;
   		return result;
   }
   
   public PageReference gotoWelcomePageWithRepId(){
   		string newPageUrl=getWelcomeURL();
   		newPageUrl = newPageUrl + '&rep=' + repId;
   		PageReference page = new PageReference(newPageUrl);
   		
   		return page;
   }
   
   public PageReference sendRegistrationReport() {
    	try{
    		getReseller();
    		System.debug('***sendRegistrationReport() - getting rep data: ' + resellerRep.Email);
    		HaparaSendEmailNotification.SendContactEmail(resellerRep, 'Reseller_Registration_Status_Report',reseller,null);
    		string salesEmail = getResellerSalesEmail();
    		System.debug('***sendRegistrationReport() - salesEmail: ' +salesEmail);
    		sendRSRegistrationStatusRequestEmail( reseller,  resellerRep, salesEmail );
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'The report will be send to your email shortly.'));
    	}catch(Exception e){
   			  HaparaSendEmailNotification.SendAdminErrorEmail('sendRegistrationReport', e+'',Apexpages.currentPage().getUrl());
			 PageReference errorPage =Page.Exception;
			 errorPage.setRedirect(true);
			 return errorPage;
   		} 		
   		
	  PageReference newPage = new PageReference( '/Reseller/HaparaRSRegistrationReport'+getURLParameters());
	  newPage.setRedirect(true);
	  return newPage;
   }
   
   public String getRegisterDealURL(){
   		
	  	return HAPARA_CONST.RESELLER_PORTAL_DEALREGISTRATION_URL +getURLParameters();
   }
   
   public String getMarketinglURL(){
   		
	  	return HAPARA_CONST.RESELLER_PORTAL_MARKETING_URL +getURLParameters();
   }
   
   public String getWelcomeURL(){   		
	  	return  HAPARA_CONST.RESELLER_PORTAL_WELCOME_URL +getURLParameters();
   }
   
   public String getSendRegistrationReportURL(){
   		String accId = ApexPages.currentPage().getParameters().get('id');
   		//string repId = 
   		
	  	return HAPARA_CONST.RESELLER_PORTAL_SENDREGISTRATION_URL +getURLParameters();
   }
   
   public String getUpdateRegistrationURL(){
   		return HAPARA_CONST.RESELLER_PORTAL_UPDATEREGISTRATION_URL+getURLParameters();
   }
   
  public void sendRSRegistrationStatusRequestEmail(Account reseller, Contact rep,String sendToEmail ){
   		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses;
		String salesforceURL = Hapara_Utility.isRunningInSandbox()?Hapara_Utility.GetSandboxURL():Hapara_Utility.GetProductionURL();
		
										
		System.debug('Email sent to Reseller Sales at ' + sendToEmail);
					
		mail.setSenderDisplayName('Reseller Sales');
		toAddresses = new String[] {sendToEmail};
		mail.setToAddresses(toAddresses);
		mail.setReplyTo(getResellerSalesEmail());
   
		// set the subject on the email
		mail.setSubject('Representative requested a Deal Registration Status Report:' +reseller.Name + ' - ' + rep.Name);
			      
		// set the body of the email
		mail.setHTMLBody('<p>*** '+rep.Name+' REQUESTED A Deal Registration Status Report *** </p>' 
				   		+ '<p>The following Reseller Rep has requested a deal registration report: </p>'
				   		+ '<p>Reseller: ' + reseller.Name +'</p>'
				   		+ '<p>Rep: ' +rep.Name +'</p>'
				   		+ '<p>Rep Email: ' + rep.Email +'</p>'
				   		+ '<p>Click on the link to access the reseller registration directly: ' 
				   		+ salesforceURL	+'/'+ rep.Id+'</p>'
				   	);
			  				   
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
   }
   
   
    public PageReference CheckId(){
    	PageReference newPage = null;
    	string id = ApexPages.currentPage().getParameters().get('id');
    	//String newPageUrl =ApexPages.currentPage().getUrl();
    	System.debug('***CheckId() - id = ' +id);
    	if(id == null || id=='null'){
    		System.debug('***CheckId() - No id = ' +id);
    		//ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'id == null'));
    		newPage =  new PageReference(unAuthorizeURL);
    		newPage.setRedirect(true);
    		return newPage;
    	}else{
    	//	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'id: ' + id));
    		if(getReseller() == null){
    			System.debug('***CheckId() - Cannot find account id = ' +id);
	   			newPage =  new PageReference(unAuthorizeURL);
	    		newPage.setRedirect(true);
	    		return newPage;
   			}
           
    	}
    	return null;
    }
    
   	public string filterRegistration{get;set;} 
	list<SelectOption> filterRegistrations;
	public list<SelectOption> getfilterRegistrations(){
		if(filterRegistrations == null){
			filterRegistrations = new list<SelectOption>();
			filterRegistrations.add(new SelectOption('Rep','My Deals only'));
			filterRegistrations.add(new SelectOption('Company','All Deals by My Company'));
			filterRegistration='Rep';
		}
		return filterRegistrations;
	}
	
	public string filterRegistrationName{get;set;}
	
	
	public PageReference populateRegistration(){
		getRegistrations();
		return null;
	}
	
   public list<Opportunity> getRegistrations(){
   		string whereFilter = '';
   		
   		if(filterRegistration == 'Rep')
   			whereFilter = ' and (o.Reseller_s_Rep__c =\'' +resellerRep.Id +'\' or Reseller_s_Rep_2__c =\'' +resellerRep.Id+'\')';
		else
			whereFilter = 'and o.AccountId =\'' + getReseller().Id+'\'';
		
		if(filterRegistrationName.trim().length()>0)
			whereFilter = whereFilter + ' and o.Name like \'%' + filterRegistrationName.trim() +'%\'';
	
		string sql = 'select Id, o.Resellers_Account__r.Name, o.Reseller_Tier__c,o.Name, o.CloseDate,'
					+' Opportunity_Name_Template__c, StageName'
		   			+' from Opportunity o' 
			   		+' where o.IsClosed = false '
			   		+ whereFilter
			   		+' and o.Reseller_Tier__c != null' 
			   		+' order by o.Resellers_Account__r.Name , o.CloseDate';
		
		system.debug('***getRegistrations: sql='+ sql);	   		
		registrations = Database.query(sql);
		   		 
   		system.debug('***getRegistrations: options size='+ registrations.size());
   		return registrations;
   }
   
   public Id CurrentRegistration{get; set;}
  
   
   public List<SelectOption> getOpenRegistrations() {     
   		system.debug('***getOpenRegistrations: options size='+ registrations.size());
   		List<SelectOption> options = new List<SelectOption>();
		getRegistrations();
		//options.add(new SelectOption('0001', '--Select--'));
		if(registrations != null){
			for(Opportunity c : registrations ){
				system.debug('***getOpenRegistrations: options='+ c.id+ c.Resellers_Account__r.Name);
			 	options.add(new  SelectOption(c.id, c.Name));
			 	
			} 
		}
		return options;
	}
	
	public string getEditRegistrationURL(){
		return HAPARA_CONST.RESELLER_PORTAL_EDITREGISTRATION_URL+getURLParameters() +'&activityid=';
	}
  
  	public PageReference editRegistration(){
  		system.debug('***editRegistration:');
  		if(CurrentRegistration != null){
	  		String newPageUrl = getEditRegistrationURL() +CurrentRegistration;
			PageReference newPage = new PageReference(newPageUrl);
			newPage.setRedirect(true);
			return newPage;
  		}else{
  			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select a registration to edit.'));
  			return null;
  		}
  	}
  	
  	public string getCreatePurchaseOrderUrl(){
  		return HAPARA_CONST.RESELLER_PORTAL_PURCHASEORDER_URL+getURLParameters()  +'&activityid=' ;
  	}
  	
  	public PageReference createPurchaseOrder(){
  		system.debug('***createPurchaseOrder:');
  		if(CurrentRegistration != null){
	  		String newPageUrl = getCreatePurchaseOrderUrl() +CurrentRegistration;
			PageReference newPage = new PageReference(newPageUrl);
			newPage.setRedirect(true);
			return newPage;
  		}else{
  			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select registration to submit a purchase order.'));
  			return null;
  		}
  	}
   
   public PageReference login(){
   		string newPageUrl;
   		List <Contact> c = [select id, name,firstname,lastname,email,phone,mailingstate,mailingCountry 
   			from Contact where Email = :resellerRep.Email and accountId=:reseller.Id limit 1];
   		Id customerAccountId;
   		if(c.isEmpty()){
   			newPageUrl = HAPARA_CONST.RESELLER_PORTAL_REGISTERREP_URL+getURLParameters();
   			showWelcomePanel = 'No';
   		}else{
	 	   	newPageUrl = getWelcomeURL() + '&rep='+c[0].Id;
	 	   	showWelcomePanel = 'Yes';
   		}
	   	PageReference newPage = new PageReference(newPageUrl); 
	   	return newPage;			   		
   }
   
  
   public string getURLParameters(){
   		string url = '?id='+ ApexPages.currentPage().getParameters().get('id');
   		
   		if(ApexPages.currentPage().getParameters().containsKey('rep')){
	        	url =url+'&rep='+ ApexPages.currentPage().getParameters().get('rep');
   		}
   		return url;  	
   }
   
   public list<ContentVersion> getHaparaLogos(){
   		list<ContentVersion> documents = [Select  c.Title, c.FileType,c.ContentSize,  c.ContentDocumentId ,c.Description
   									From ContentVersion c
   									Where  c.PublishStatus='P' and c.IsLatest= true 
   									and c.ContentDocument.ParentId=:HAPARA_CONST.SETTING_RESELLER.Document_Logos__c];
   									
   		
   		return documents;	
   }
   public list<ContentVersion> getHaparaBrochures(){
   		list<ContentVersion> documents = [Select  c.Title, c.FileType,c.ContentSize,  c.ContentDocumentId ,c.Description
   									From ContentVersion c
   									Where  c.PublishStatus='P' and c.IsLatest= true 
   									and c.ContentDocument.ParentId=:HAPARA_CONST.SETTING_RESELLER.Document_Brochures_Id__c];
   									
   		
   		return documents;	
   }
   public list<ContentVersion> getHaparaProductCopies(){
   		list<ContentVersion> documents = [Select  c.Title, c.FileType,c.ContentSize,  c.ContentDocumentId,c.Description
   									From ContentVersion c
   									Where  c.PublishStatus='P' and c.IsLatest= true 
   									and c.ContentDocument.ParentId=:HAPARA_CONST.SETTING_RESELLER.Document_Product_Copies_Id__c];
   									
   		
   		return documents;	
   }
   public list<ContentVersion> getHaparaHelpGuides(){
   		list<ContentVersion> documents = [Select  c.Title, c.FileType,c.ContentSize,  c.ContentDocumentId,c.Description
   									From ContentVersion c
   									Where  c.PublishStatus='P' and c.IsLatest= true 
   									and c.ContentDocument.ParentId=:HAPARA_CONST.SETTING_RESELLER.Document_Help_Id__c];
   									
   		
   		return documents;	
   }
}