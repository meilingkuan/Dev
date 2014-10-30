public class HaparaResellerRegistrationController {
	public class CallHistory{
	
		public DateTime ActivityDate{get;Set;}
		
		public string getActivityDateFormatted(){
			return ActivityDate.format('MMMM d, yyyy');
		}
		public string Notes{get;set;}
		public string TypeOfCall{get;set;}
	}
	
	
	public class OrderLineItem{
		public integer lineNo {get;set;}
		public string PricebookEntryId{get;set;}			
		public string Description{get;set;}
		integer qty = 0;
		public integer Quantity{get{return qty;}set{qty = value;}}
		
		decimal up = 0.0;
		public decimal UnitPrice{get{return up;}set{up=value;}}
		public decimal NewUnitPrice{get;set;}
		public decimal TotalPrice{
			get{
				return Quantity * NewUnitPrice;
			}			
		}			
		public string Product2Id {get;set;}	
		
		public string ProductName{get;set;}	
		
		public string CurrencyCode{get;set;}
		 
		decimal subscriptionPeriodVal = 0.0;
		public string SubscriptionPeriod{
			get{return string.valueOf( subscriptionPeriodVal);}
			set{subscriptionPeriodVal =decimal.valueOf( value);}
		}
		
		public boolean editableSubPeriod = false;
		public boolean DisabledSubscriptionPeriod{
			get{
				if(editableSubPeriod)
					return false;
				else
					return true;
			}
			set;
		}
		
		private string startDate = Date.today().year() +'-'+Date.Today().month() + '-'+ Date.Today().day();
		public string SubscriptionStartDate{
			get{ return startDate;}
			set{ startDate = value;}
		}
		
		public Date getDateSubscriptionStartDate(){
			return Date.valueOf(startDate);
		}
	}
	 
	PageReference newPage;
	String unAuthorizeURL = '/apex/HaparaResellerUnAuthorize';
	String dealRegistrationURL = '/Reseller/HaparaRSDealRegistration';
	String welcomeURL = '/Reseller/HaparaRSWelcome';
	String sendRegistrationURL ='/Reseller/HaparaRSSendRegistrationReport';
	Opportunity registration;
	list<OpportunityLineItem> opplines;
	Lead currentLead;
	Account currentAccount;
	Contact currentContact;
	Lead resellerLead;
	Hapara_Invoice__c invoice;
	Task callTask;
	list<CallHistory> callHistory ;
	Account reseller;
	Contact resellerRep;
	
	public Id activityId{get;set;}
	public Id rep{get;set;}
	
	private boolean viewPurchaseOrderForm = true;
	public boolean getViewPurchaseOrderForm(){
		return viewPurchaseOrderForm;
	}
	
	Attachment attach;
    public Attachment getAttachment() 
    {
    	System.debug('***getAttachment() - attach = ' +attach);
    	if(attach == null)
    		attach = new Attachment();
    	return attach;
	}
    
	public HaparaResellerRegistrationController(){
		viewPurchaseOrderForm = true;
		activityId = ApexPages.currentPage().getParameters().get('activityid');
		rep =  ApexPages.currentPage().getParameters().get('rep');
	}
	
	public PageReference CheckId(){
		
	 	string id = ApexPages.currentPage().getParameters().get('activityid');
	 	if(string.isEmpty(id))
	 		id = activityId;
	 	System.debug('***CheckId - activityid = '+id );
    	try{
	    	registration = [Select o.Name, o.Size_of_Opportunity__c, o.Reseller_s_Status__c, 
	    				 o.Opportunity_Name_Template__c, o.Description ,o.IsClosed ,
	    				 o.OwnerId,o.Owner.Name, o.Owner.email,
	    				 
	    				 o.Reseller_Tier__c,o.Reseller_Tier__r.Reseller_Does_On_setup__c,
	    				 
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
	    				  o.Reseller_s_Contact__r.LastName, o.Reseller_s_Contact__c,
	    				  
	    				  (Select Id, OpportunityId, SortOrder, PricebookEntryId, CurrencyIsoCode, Quantity, Discount,
	    				   TotalPrice, UnitPrice, ListPrice, ServiceDate, HasRevenueSchedule, HasQuantitySchedule,
	    				    Description, HasSchedule, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById,
	    				     SystemModstamp, IsDeleted, Account__c, Subscription_End_Date__c, Description2__c
						 From OpportunityLineItems) 
	    				From Opportunity o WHERE Id = :id  ];
	    	currentAccount = registration.Resellers_Account__r;
	    	currentLead = registration.Resellers_Lead__r;
	    	currentContact = registration.Reseller_s_Contact__r;
	    	resellerRep = registration.Reseller_s_Rep__r;
	    	
	    	opplines = registration.OpportunityLineItems;
	    	if(Apexpages.currentPage().getUrl().contains(HAPARA_CONST.RESELLER_PORTAL_PURCHASEORDER_URL)){
	    		getInvoice();
	    		getAttachment();
	    	}
	    	if(getReseller() == null)
	    		throw new HaparaException('***HaparaResellerRegistrationController() - Cannot find reseller id' );
	    		
	    	if(registration.IsClosed){
	    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Deal has been closed please request a status report to view the status.'));
	    	}
    	}catch(Exception e){
    		system.debug(e);
    		HaparaSendEmailNotification.SendAdminErrorEmail('CheckId', e+'',Apexpages.currentPage().getUrl());
    		System.debug('***HaparaResellerRegistrationController() - Cannot find opportunity id = ' +id);
    		newPage =  new PageReference(unAuthorizeURL);
    		newPage.setRedirect(true);
    		return newPage;
   		}
   		return null;
	}
	
	public Opportunity getRegistration(){
		return registration;
	}
	
	Opportunity tempObject;
	public Opportunity getTempObject(){
		if(tempObject == null)
			tempObject = new Opportunity();
		return tempObject;
	}
	
	Contact otherResellerRep;
	public Contact getPrimaryRep(){
		if(otherResellerRep == null){
			otherResellerRep= new Contact();
		}
		return otherResellerRep;
	}
	
	 public Account getReseller(){
    	if(reseller !=null)
    		return reseller;
    	string id = ApexPages.currentPage().getParameters().get('id');
    	try{
	    	reseller = [SELECT Id, Name,BillingCountry,Internal_Reseller_Sales_Email__c,Reseller_s_Email_Domain__c,CurrencyIsoCode,
	    				Reseller_Setup_Email_Template_Name__c,Reseller_Setup_Email_Temp_Name_Low_No__c,
	    				Invoice_Billing_Emails__c,OwnerId,Reseller_Low_Order_Send_to_Customer__c,Invoice_Contact__c
	    				 FROM Account 
	                  	WHERE Id = :id];
    	}catch(Exception e){
    		HaparaSendEmailNotification.SendAdminErrorEmail('getReseller', e+'',Apexpages.currentPage().getUrl());
    		System.debug('***getReseller() - Cannot find account id = ' +id);
    		return null;
   		}
   		return reseller;
    }
    
	public String getResellerSalesEmail(){
    	Account resellerAccount = getReseller();
    	String email = 'resellersales@hapara.com';
    	if(resellerAccount != null)
    		if(resellerAccount.Internal_Reseller_Sales_Email__c != null)
    			email = resellerAccount.Internal_Reseller_Sales_Email__c;
    	return email;
    }   
    
    public Hapara_Invoice__c getInvoice(){
    	if(invoice == null){
    		invoice = new Hapara_Invoice__c();
    	}
    	return invoice;
    }
	
	public Lead getResellerLead(){
		system.debug('***getResellerLead currentAccount=' +currentAccount+' currentContact=' +currentContact
			+' currentLead='+ currentLead);
   		if(resellerLead == null) {
   			resellerLead = new Lead();	
   			if(currentAccount != null){
   				resellerLead.Company = currentAccount.Name;
   				resellerLead.Website = currentAccount.Website;
   				resellerLead.Country = currentAccount.BillingCountry;
   				resellerLead.State = currentAccount.BillingState;
   				resellerLead.Street = currentAccount.BillingStreet;
   				resellerLead.City = currentAccount.BillingCity;
   				resellerLead.PostalCode = currentAccount.BillingPostalCode;
   				resellerLead.Domain_Comments__c = currentAccount.Domain_Comments__c;
   			}
   			
   			if(currentContact != null){
   				resellerLead.FirstName = currentContact.FirstName;
   				resellerLead.LastName = currentContact.LastName;
   				resellerLead.Email = currentContact.Email;
   				resellerLead.Job_Description__c = currentContact.Job_Description__c;
   				resellerLead.Phone = currentContact.Phone;
   			}else if(currentLead != null){
   				resellerLead.FirstName = currentLead.FirstName;
   				resellerLead.LastName = currentLead.LastName;
   				resellerLead.Job_Description__c = currentLead.Job_Description__c;
   				resellerLead.Email = currentLead.Email;
   				resellerLead.Phone = currentLead.Phone;
   				resellerLead.Company = currentLead.Company;
   				resellerLead.Website = currentLead.Website;
   				resellerLead.Country = currentLead.Country;
   				resellerLead.State = currentLead.State;
   				resellerLead.Street = currentLead.Street;
   				resellerLead.City = currentLead.City;
   				resellerLead.PostalCode = currentLead.PostalCode;
   				resellerLead.Domain_Comments__c = currentLead.Domain_Comments__c;
   			}
   		}
      	return resellerLead;
   	}
   	
	public list<CallHistory> getCallHistory(){
		callHistory = new list<CallHistory>();
		system.debug('***getCallHistory - retrieving tasks');
		list<Task> tasks= [Select t.Description, t.ActivityDate,t.CallDisposition From Task t
           			where  WhoId = : registration.Reseller_s_Rep__c and WhatId= :registration.Id 
           			and  CallType = 'Inbound'
           			order by ActivityDate desc];
           		
        
        system.debug('***getCallHistory - retrieved tasks: ' + tasks.size());
        for(Task t : tasks){
        	Date dt = t.ActivityDate ;
        	CallHistory h = new CallHistory();
        	h.ActivityDate = Datetime.newInstance(dt,Time.newInstance(0,0,0,0));
        	h.Notes= t.Description;
			h.TypeOfCall=t.CallDisposition;
			callHistory.add(h);
        }
		return callHistory;
	}
	
	public List<SelectOption> getCallType() {     
   		system.debug('***getCallType: ');
   		List<SelectOption> options = new List<SelectOption>();
		
		options.add(new SelectOption('Call', 'Call'));
		options.add(new SelectOption('Email', 'Email'));
		options.add(new SelectOption('Site Visit', 'Site Visit'));
		options.add(new SelectOption('Demo', 'Demo'));
		options.add(new SelectOption('Setup', 'Setup'));
		options.add(new SelectOption('Other', 'Other'));
		return options;
	}
	
	public Task createCallTask(){
		system.debug('***createCallTask: tempObject= ' + tempObject.Opportunity_Name_Template__c);
        callTask = new Task(ActivityDate =tempObject.CloseDate,
            CallDisposition = tempObject.Opportunity_Name_Template__c ,
            CallType = 'Inbound',
            Status = 'Completed',
            Subject =registration.Reseller_s_Rep__r.Name +  ' logged: ' + tempObject.Opportunity_Name_Template__c ,
          	Description = tempObject.Description,
            Type = 'Call',
            WhoId =  registration.Reseller_s_Rep__c,
            WhatId = registration.Id);		
            
        return callTask;
        
	}
	
	public PageReference saveSalesNotes(){
		try{
			system.debug('***saveSalesNotes: registration= ' + registration.Id);
			insert createCallTask();
			update 	registration;
			sendRSAdministratorSalesNotesEmail( registration,getResellerSalesEmail() );
		}catch(Exception e){
   			 HaparaSendEmailNotification.SendAdminErrorEmail('saveSalesNotes', e+'',Apexpages.currentPage().getUrl());
			 PageReference errorPage =Page.Exception;
			 errorPage.setRedirect(true);
			 return errorPage;
   		} 		
   		
   	 	string url = getEditRegistrationURL()  +'&activityid=' + Apexpages.currentPage().getParameters().get('activityid');
   		PageReference newPage = new PageReference( url);
	  	newPage.setRedirect(true);
	  	return newPage;
	}
	
	
	public PageReference savePurchaseOrder(){
		string url;
		try{			
			if(orderlines.size()==0){
				 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please add an order line before saving this order.'));
				return null;
			}
			if(string.isEmpty(getResellerLead().country) ||string.isEmpty(getResellerLead().state) ){
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Customer must have Country and State populated.'));
				return null;
			}
			system.debug('***savePurchaseOrder: registration= ' + registration.Id 
					+ ' account: ' + registration.Resellers_Account__c + ' contact: '+registration.Reseller_s_Contact__c);	
			//update opportunity to closed won
			registration.StageName = HAPARA_CONST.OPPORTUNIYT_STAGE_WON;
			registration.CloseDate = date.today();
			registration.Amount = 1;
			Account acc;
			Contact con;
			string accId;
			string conId;
			if(registration.Resellers_Account__c != null){				
				acc= registration.Resellers_Account__r;
				
				if(registration.Reseller_s_Contact__c != null)
					con = registration.Reseller_s_Contact__r;
				else{
					list<Contact> lscon = [select 
	    				 Job_Description__c, Email, Phone, FirstName,LastName 
	    				 from Contact where email=: resellerLead.Email and accountid=: acc.Id];
	    			if(lscon.size()>0)
	    				con = lscon[0];
	    			else
	    				con = null;
				}
				setPurchaseOrderAccountValues(registration.Resellers_Account__r,con);
				System.debug('****savePurchaseOrder - Resellers_Account__c ='+registration.Resellers_Account__c );
			}else if(registration.Resellers_Lead__c != null && registration.Resellers_Account__c == null){
				if(!registration.Resellers_Lead__r.IsConverted){
					LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
					Database.LeadConvert lc = new database.LeadConvert();
					lc.setLeadId(registration.Resellers_Lead__c);
					lc.setOwnerId(registration.OwnerId);
					lc.setConvertedStatus(convertStatus.MasterLabel);
					lc.setDoNotCreateOpportunity(true);
					
					Database.LeadConvertResult lcr = Database.convertLead(lc);
					System.assert(lcr.isSuccess());
					System.debug('****savePurchaseOrder - Converted Successfully');
					
					accId = lcr.getAccountId();
					conId	= 	lcr.getContactId();
				}else{
					accId = registration.Resellers_Lead__r.ConvertedAccountId;
					conId	= 	registration.Resellers_Lead__r.ConvertedContactId;
				}
				System.debug('****savePurchaseOrder - customer account Resellers_Lead__c: ' + accId);
				registration.Resellers_Account__c = accId;
				registration.Reseller_s_Contact__c = conId;
				
				acc = [select 
						Website, BillingCountry, BillingPostalCode, BillingState,BillingCity, BillingStreet, 
	    				Name, Domain_Comments__c,Referral_Date__c,Referral__c,Referral_Contact__c,Type
	    				from Account where Id=:accId ];
	    		con = [select 
	    				 Job_Description__c, Email, Phone, FirstName,LastName 
	    				 from Contact where Id=: conId];		
	    		
			}else
				throw new HaparaException('HaparaResellerRegistrationController.savePurchaseOrder: missing Reseller account or Reseller on opportunity = ' + registration.Id);

			setPurchaseOrderAccountValues(acc,con );
			delete opplines;
			//Create hapara invoices 
			invoice.Invoice_Date__c = date.today();
			invoice.Due_Date__c = date.today().addDays(30);
			invoice.Account__c = reseller.Id;
			invoice.Reseller_PO_Received_Date__c = date.today();
			invoice.Customer_PO_Received_Date__c = date.today();
			invoice.Invoice_To_Contact__c = registration.Account.Invoice_Contact__c;
			invoice.CurrencyIsoCode =getCurrencyCode();
			invoice.Invoice_Billing_Emails__c= reseller.Invoice_Billing_Emails__c;	
			invoice.OwnerId = reseller.OwnerId;		
			invoice.Opportunity__c = registration.Id;
			
			if(invoice.Id !=null)
				update invoice;
			else
				insert invoice;
			System.debug('****savePurchaseOrder - inserted invoice: ' + invoice.Id);
						
			if(attach.Body != null){
				System.debug('****savePurchaseOrder - inserted attachement: ' + attach);
	   			attach.ParentId = invoice.Id;
	   			if(attach.Id == null)
	   				insert attach;
	   			else
	   				update attach;
	   			System.debug('****savePurchaseOrder - inserted attachement: ' + attach.Id);
			}	
			
			list<string> cc = new list<string>();
			cc.add(resellerRep.Email);
			//check if the primary rep has changed
			if(otherResellerRep.Email.trim().toLowerCase() != resellerRep.Email.toLowerCase())
			{
				list<Contact> searchRep2 = [select id from contact where email =:otherResellerRep.Email and accountid=:reseller.Id ];
				if(searchRep2.size()==0){
					otherResellerRep.AccountId = Reseller.id;
					insert otherResellerRep;
					registration.Reseller_s_Rep_2__c = otherResellerRep.id;
				}else
					registration.Reseller_s_Rep_2__c = searchRep2[0].id;
				cc.add(otherResellerRep.Email);
			}
			
			//save opportunity
			registration.CurrencyIsoCode= getCurrencyCode();
			registration.Hapara_Invoice__c = invoice.Id;
			registration.StageName = HAPARA_CONST.OPPORTUNITY_STATGE_PROCESSINGPO;
			registration.Reseller_s_Status__c = HAPARA_CONST.OPPORTUNITY_STATGE_PROCESSINGPO;
   			registration.CloseDate = date.today();
   			registration.OwnerId = reseller.OwnerId;
   			update registration;
   			
   			//create invoice lines and opporutnity lines
   			list<Account_Products__c> lineItems = createLines( invoice, acc);
   			System.debug('****savePurchaseOrder - updated opportunity: ' + registration.Id); 
			//create setup task
			if(!registration.Reseller_Tier__r.Reseller_Does_On_setup__c)
		  		HaparaResellerUtilityCommon.createTaskforSetup(acc,con,reseller,cc);
				
			HaparaSendEmailNotification.SendContactEmail(resellerRep,HAPARA_CONST.SETTING_RESELLER.Purchase_Order_Email_Template__c,
				null,registration);
					
			if(HaparaResellerUtilityCommon.ValidateResellerMinimumOrder(lineItems, resellerRep, reseller, acc, invoice, 
				registration.Owner))
				HaparaResellerUtilityCommon.sendRSAdministratorEmail(  registration, 
					'rspurchaseorder@hapara.com','PURCHASE ORDER','' );
   			
		}catch(Exception e){
   			
   			string error ='***savePurchaseOrder: '+  e.getMessage() + '\n\n//-- Stack Trace --//\n' + e.getStackTraceString();
			HaparaSendEmailNotification.SendAdminErrorEmail('HaparaResellerRegistrationController savePurchaseOrder', error,Apexpages.currentPage().getUrl());
			System.debug(error);
   			// ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Error:' +e.getStackTraceString()));
			//return null;
			 PageReference errorPage =Page.Exception;
			 errorPage.setRedirect(true);
			 return errorPage;
			
   		} 		
   	
	  	viewPurchaseOrderForm = false;
	  	return newPage;
	}
	
	private list<Account_Products__c>  createLines(Hapara_Invoice__c invoice,Account acc){
		list<Account_Products__c> invLines = new list<Account_Products__c>();
		list<OpportunityLineItem>opplines = new list<OpportunityLineItem>();
		
		system.debug('***createLines - orderlines to be processed=' + orderlines.size());
		for(OrderLineitem line : orderlines){
			//create invoice lines
   			Account_Products__c lineItem = new Account_Products__c();
			lineItem.Hapara_Invoice__c = invoice.Id;
			lineItem.Account__c = acc.Id;
			lineItem.CurrencyIsoCode = line.CurrencyCode;
			PricebookEntry price = pricebooks.get(line.PricebookEntryId);
			Product2 prod = price.Product2;
			integer subscriptionperiod = prod.Calculate_Unit_Price_Based_On_Period__c ?  integer.valueOf(line.SubscriptionPeriod):1;
			Date endDate = Hapara_UtilityCommonRecordAccess.CalculateProductEndSubscriptionDateWithPeriod
								(prod,line.getDateSubscriptionStartDate(), subscriptionperiod);
			
			lineItem.Subscription_Start_Date__c =line.getDateSubscriptionStartDate() ;
			lineItem.Subscription_End_Date__c = endDate;
			lineItem.Description__c = Hapara_UtilityCommonRecordAccess.BuildInvoiceLineDescription(prod.Description,acc.name, 
	    		lineItem.Subscription_Start_Date__c,  lineItem.Subscription_End_Date__c);
			lineItem.Invoice_Date__c = invoice.Invoice_Date__c ;
			lineItem.Product__c = prod.Id;
			lineItem.Quantity__c = line.Quantity;
			lineItem.Unit_Price__c =line.NewUnitPrice;
			lineItem.Product_Family__c= prod.family;
			lineItem.Reseller_Account__c =reseller.Id; 
			invLines.add(lineItem);
			
			OpportunityLineItem opplineItem = new OpportunityLineItem();
   			opplineItem.Account__c = acc.id;
			opplineItem.OpportunityId = registration.Id;
			
			opplineItem.PricebookEntryId =price.Id;
			opplineItem.UnitPrice = line.NewUnitPrice;
			opplineItem.Quantity =  line.Quantity;
			opplineItem.ServiceDate = line.getDateSubscriptionStartDate();
			opplineItem.Subscription_End_Date__c = endDate;
			opplineItem.Description2__c = 	lineItem.Description__c;
			opplines.add(opplineItem);
		}
		insert invLines;
		insert opplines;
		return invLines;
	}
	

	
	private void setPurchaseOrderAccountValues(Account acc, Contact con){
		System.debug('****setPurchaseOrderAccountValues: acc='+acc.id);
		acc.Name = resellerLead.Company;
		acc.BillingStreet = resellerLead.Street;
		acc.BillingCountry = resellerLead.Country;
		acc.BillingPostalCode = resellerLead.PostalCode; 
		acc.BillingState = resellerLead.State;
		acc.BillingCity = resellerLead.City;
		acc.CurrencyIsoCode = getCurrencyCode();
		acc.Billing_in_Own_Currency__c = Hapara_UtilityCommonRecordAccess.setBillingInOwnCurrency(acc.BillingCountry,
												acc.Type,acc.Billing_in_Own_Currency__c);
		if(string.IsEmpty(acc.Website))
			acc.Website= resellerLead.Website;
		if(string.IsEmpty(acc.Domain_Comments__c))
			acc.Domain_Comments__c = resellerLead.Domain_Comments__c;
		
		acc.Invoice_Contact__c = getReseller().Invoice_Contact__c;
		acc.Purchase_Order_No__c =( string.isblank( invoice.Customer_PO__c)? '':invoice.Customer_PO__c)  + '-'+invoice.Reseller_PO__c;
		acc.Received_Date_of_PO__c = date.today();
		if(acc.No_of_Students__c == null)
			acc.No_of_Students__c = orderlineItem.Quantity;
		
		if(acc.Referral_Date__c != null){
			acc.Referral__c = reseller.Id;
			acc.Referral_Contact__c = resellerRep.id;
			acc.Referral_Date__c = date.today();
			acc.Reseller_Customer_Tier__c = registration.Reseller_Tier__c;
		}
		
		if(string.IsBlank(acc.How_did_you_hear_about_us__c))
			acc.How_did_you_hear_about_us__c = 'Hapara Partner / Reseller';
		
		//acc.OwnerId = getReseller().OwnerId;
		update acc;
		
		boolean isInsertContact = false;		
		if(con== null){
			con = new Contact();
			con.AccountId = acc.Id;
			isInsertContact = true;
			con.Email= resellerLead.Email;
			con.OwnerId= getReseller().OwnerId;
		}
		con.Job_Description__c = resellerLead.Job_Description__c;
		
		con.Phone = resellerLead.Phone;
		con.FirstName = resellerLead.FirstName;
		con.LastName = resellerLead.LastName;
		con.Primary_Contact__c = true;
		
		
		if(isInsertContact){
			insert con;
			registration.Reseller_s_Contact__c = con.Id;
		}else
			update con;					
	}
	
	public boolean validateOrderLine(){
		system.debug('***validateOrderLine: orderlineItem.PricebookEntryId= ' + orderlineItem.PricebookEntryId 
			+'; quantity='+orderlineItem.Quantity + '; subscriptionPeriod=' +orderlineItem.SubscriptionPeriod 
			+'; date = ' +  orderlineItem.SubscriptionStartDate);
		boolean result = true;
		if(orderlineItem.PricebookEntryId == null || integer.valueOf( orderlineItem.Quantity)==0 || integer.valueOf(orderlineItem.SubscriptionPeriod)==0 ){
			 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please select an order item and enter a quantity and months or years that is greater than zero.'));
			 result = false;
		}
		if(string.IsEmpty(orderlineItem.SubscriptionStartDate) ){
			 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Order Start Date must be entered.'));
			 result = false;
		}else {
			try{
				Date testDate = Date.valueOf(orderlineItem.SubscriptionStartDate);
			}catch(Exception e){
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,
						'Order Start Date must be entered in the following format: YYYY-MM-DD'));
				result= false;
			}
		}
		return result;
	}
	
	public PageReference saveOrderLine(){
		PageReference page = null;
	
		try{
			if(!validateOrderLine())
					return page;
			Integer lineNumber = 0;
			for(Integer i = 0 ; i< orderlines.size() ; i++){
				if(orderlines[i].lineNo > lineNumber)
					lineNumber= orderlines[i].lineNo;
			}
			orderlineItem.lineNo = lineNumber +10;
			orderlineItem.NewUnitPrice = Hapara_UtilityCommonRecordAccess.CalculateProductNewUnitPrice(orderlineItem.editableSubPeriod,
										orderlineItem.UnitPrice,integer.valueOf(orderlineItem.SubscriptionPeriod));
			orderlines.add(orderlineItem);
			orderlineItem = new OrderLineItem();
			selectedPriceEntryBook = '0001';
		}catch(Exception e){
			string error ='***saveOrderLine: '+  e.getMessage() + '\n\n//-- Stack Trace --//\n' + e.getStackTraceString();
			HaparaSendEmailNotification.SendAdminErrorEmail('HaparaResellerRegistrationController saveOrderLine', error,Apexpages.currentPage().getUrl());
			System.debug(error);
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()));
		}
		return page;
	}
	
	
	public PageReference deleteOrderLine(){
		PageReference page = null;
		string deleteOrderLineNo = System.CurrentPageReference().getParameters().get('deleteOrderLineNo');
		system.debug('***2deleteOrderLine - deleteOrderLineNo=' + deleteOrderLineNo);
		if(!string.isempty(deleteOrderLineNo)){
			for(Integer i = 0 ; i< orderlines.size() ; i++){
				OrderLineItem o = orderlines[i];
				if(o.lineNo.format() ==deleteOrderLineNo)
					orderlines.remove(i);
			}
		}
		return page;
	}
	
	public PageReference cancel() {
	 
	  PageReference newPage = new PageReference( HAPARA_CONST.RESELLER_PORTAL_UPDATEREGISTRATION_URL+getURLParameters());
	  newPage.setRedirect(true);
	  return newPage;
    }
    
    list<OrderLineItem> orderlines = new list<OrderLineItem>();
    public list<OrderLineItem> getOrderLines(){
    	system.debug('***getOrderLines - orderlines='+ orderlines.size());
    	return orderlines;
    }
	
	OrderLineItem orderlineItem;
	public OrderLineItem getLineItem(){
		
		if(orderlineItem == null){
			orderlineItem=new OrderLineItem();
		}
		System.debug('****getLineItem: orderlineItem ='+orderlineItem);
		return orderlineItem;
	}
	
	map<Id,PricebookEntry> pricebooks = new map<Id,PricebookEntry>();
	
	public list<SelectOption> getActiveProductsOptions(){
		List<SelectOption> options = new List<SelectOption>();

		options.add(new SelectOption('0001', '--Select--'));
		for(PricebookEntry c : getActiveProducts(false) ){
		 	options.add(new  SelectOption(c.id, c.Product2.Name));
		 	if(!pricebooks.containsKey(c.Id))
		 		pricebooks.put(c.Id,c);
		} 
		return options;
	}
	
	private string getCurrencyCode(){
    	return  HaparaResellerUtilityCommon.getResellerCustomerCurrencyCode
    					(getResellerLead().Country,getReseller().currencyIsoCode ); 
	}
	
    public List<PricebookEntry> getActiveProducts(boolean resetCurrency) {
    	string currencyCode =getCurrencyCode(); 
    	
    	System.debug('****getActiveProducts: pricebooks='+pricebooks.size() +' currentlead.Country=' + getResellerLead().Country
    			+ ' reseller=' +getReseller().Id +' currencyCode='+currencyCode + ' resetCurrency='+resetCurrency);
    		
   		List<PricebookEntry> prods = new list<PricebookEntry>();
		if(pricebooks.size() == 0 || resetCurrency){
			pricebooks.clear();
			System.debug('****getActiveProducts: refreshing product pricing');
			//retrieve the products linked to a reseller
			if(reseller != null)
				prods = [
					Select p.Product2.IsActive, p.Product2.Description, p.Product2.Name, p.Product2Id, 
					p.Product2.Subscription_Type__c,p.Product2.Subscription_Period__c,p.Product2.Family,
					p.Product2.Calculate_Unit_Price_Based_On_Period__c,
					p.IsActive, p.Id, p.CurrencyIsoCode ,p.UnitPrice,p.ProductCode
					From PricebookEntry p
					where p.IsActive = true 
							and p.CurrencyIsoCode =:currencyCode  and p.Product2.Is_Reseller_Portal_Enabled__c = true
							and p.Product2.Reseller_Account_del__c =:getReseller().Id 
							and p.Product2.Reseller_Tier__c=:getRegistration().Reseller_Tier__c
							order by p.Product2.Sort_Order_No__c, p.Product2.Name];
			System.debug('****getActiveProducts: reseller skus='+prods.size());				
			//if the reseller doesn't have special pricing then get the generic skus.
			if(prods.size() == 0)
				prods = [
					Select p.Product2.IsActive, p.Product2.Description, p.Product2.Name, p.Product2Id, 
					p.Product2.Subscription_Type__c,p.Product2.Subscription_Period__c,p.Product2.Family,
					p.Product2.Calculate_Unit_Price_Based_On_Period__c,
					p.IsActive, p.Id, p.CurrencyIsoCode ,p.UnitPrice,p.ProductCode
					From PricebookEntry p
					where p.IsActive = true 
							and p.CurrencyIsoCode =:currencyCode  and p.Product2.Is_Reseller_Portal_Enabled__c = true
							and p.Product2.Reseller_Account_del__c = null
							and p.Product2.Reseller_Tier__c=:registration.Reseller_Tier__c
							order by p.Product2.Sort_Order_No__c, p.Product2.Name];
						
    	}else{
    		prods =  pricebooks.values();
    	}
    	System.debug('****getActiveProducts:prods='+prods.size());
		return prods;
	}
	public string selectedPriceEntryBook{get;set;}
	
	public PageReference populateProductDetails(){
		PageReference page = null;
		System.debug('****populateProductDetails: priceEntryId='+selectedPriceEntryBook );
		if(selectedPriceEntryBook !='0001' ){
			PricebookEntry price = pricebooks.get(selectedPriceEntryBook);
			System.debug('****populateProductDetails: priceEntry='+price );
			orderlineItem.PricebookEntryId=price.Id;
			orderlineItem.ProductName = price.Product2.Name;
			orderlineItem.Description = price.Product2.Description;
			orderlineItem.UnitPrice = price.UnitPrice;
			orderlineItem.Product2Id = price.Product2Id; 
			orderlineItem.SubscriptionPeriod =price.Product2.Calculate_Unit_Price_Based_On_Period__c==true ? '0': string.valueOf( price.Product2.Subscription_Period__c);
			orderlineItem.editableSubPeriod=price.Product2.Calculate_Unit_Price_Based_On_Period__c;
			orderlineItem.CurrencyCode = price.CurrencyIsoCode;
		}else{
			resetOrderLine();
		}
		return page;
	}
	
	public void resetOrderLine(){
		getLineItem().PricebookEntryId=null;
		getLineItem().ProductName ='';
		getLineItem().Description = '';
		getLineItem().UnitPrice = 0.0;
		getLineItem().Product2Id = null; 
		getLineItem().SubscriptionPeriod =string.valueOf( 1.0);
		getLineItem().editableSubPeriod = false;
		getLineItem().CurrencyCode = '';
	}
	
	public PageReference resetOrderLines(){
		system.debug('***resetOrderLines - reseller lead country='+ getResellerLead().Country);
		PageReference page = null;
		if(!string.isEmpty(getResellerLead().Country)){
			getActiveProducts(true);
			if(orderlines.size()>0)
				orderlines.clear();
			
			resetOrderLine();
		}
		return page;
	}
	   
	string pageTitle='Welcome to Partner Portal';
   	public string getPageTitle(){
   		return pageTitle +' ' +getReseller().Name;
   	}
   	
    public String getWelcomeURL(){   		
	  	return  HAPARA_CONST.RESELLER_PORTAL_WELCOME_URL +getURLParameters();
   }
	
	 public String getPurchaseOrderURL(){   		
	  	return  HAPARA_CONST.RESELLER_PORTAL_PURCHASEORDER_URL +getURLParameters();
   }
	
	 public String getEditRegistrationURL(){   		
	  	return  HAPARA_CONST.RESELLER_PORTAL_EDITREGISTRATION_URL +getURLParameters();
   }
	
	public string getUpdateDealURL(){
		return HAPARA_CONST.RESELLER_PORTAL_UPDATEREGISTRATION_URL+getURLParameters();
	}
	
	public void sendRSAdministratorSalesNotesEmail(Opportunity opportunity,String sendToEmail ){
   		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses;
		String salesforceURL = Hapara_Utility.isRunningInSandbox()?Hapara_Utility.GetSandboxURL():Hapara_Utility.GetProductionURL();
		
										
		System.debug('Email sent to Reseller Sales at ' + sendToEmail);
					
		mail.setSenderDisplayName('Reseller Sales');
		toAddresses = new String[] {sendToEmail};
		mail.setToAddresses(toAddresses);
   
		// set the subject on the email
		mail.setSubject(registration.Reseller_s_Rep__r.Name +' has updated Notes on ' + opportunity.Name );
			      
		// set the body of the email
		mail.setHTMLBody('<p>*** ' + registration.Reseller_s_Rep__r.Name +' has updated the following opportunity: *** </p>' 
				   		+ '<p>The following registration has been added to Salesforce </p>'
				   		+ '<p>Opportunity: ' + opportunity.Name +'</p>'
				   		+ '<p>Size of Opportunity: ' + opportunity.Size_of_Opportunity__c +'</p>'
				   		+ '<p>Sales Notes: ' +callTask.Description +'</p>'
				   		+ '<p>Click on the link to access the reseller registration directly: ' 
				   		+ salesforceURL	+'/'+ opportunity.id+'</p>'
				   	);
			  				   
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
   }
   
   public string getURLParameters(){
   		string url = '?id='+ ApexPages.currentPage().getParameters().get('id');
   		
   		if(ApexPages.currentPage().getParameters().containsKey('rep')){
	        	url =url+'&rep='+ ApexPages.currentPage().getParameters().get('rep');
   		}else if(!string.isEmpty(rep))
   			url =url+'&rep='+rep;
   			
   		if(ApexPages.currentPage().getParameters().containsKey('activityid')){
   			url =url+'&activityid='+ ApexPages.currentPage().getParameters().get('activityid');
   		}else if(!string.isEmpty(activityid))
   			url =url+'&activityid='+ activityId;
   		return url;  	
   }
}