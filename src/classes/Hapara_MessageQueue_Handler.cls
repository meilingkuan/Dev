/**
 * Hapara Message Queue Handler
 *
 * @author Logan (Trineo)
 * @date August 2013
 */
public class Hapara_MessageQueue_Handler {

	/** Exception that may be thrown in this class */
	public class MessageQueueException extends Exception {}

	/** Custom settings to control behaviour of this class */
	public static Hapara_TDD_Settings__c settings = Hapara_TDD_Settings__c.getInstance();

	/** Static variables to make future changes easier. Could use custom settings here */
	public static final String  PERSON_ACCOUNT_RECORDTYPE               = 'Person Account';

	public static final String  OPPORTUNITY_NAME_TEMPLATE               = 'Teacher Dashboard Innovator';
	public static final Integer OPPORTUNITY_CLOSE_DATE_INTERVAL         =  35;
	public static final String  OPPORTUNITY_STAGE_PROSPECTING           = 'Prospecting';
	public static final String  OPPORTUNITY_STAGE_QUALIFICATION         = 'Qualification';
	public static final String  OPPORTUNITY_STAGE_CLOSED_WON            = 'Closed Won';

	public static final String  TDI_PRODUCT_CODE                        = 'TDI';
	public static final String  TDI_PRODUCT_NAME                        = 'Teacher Dashboard Innovator';
	public static final String  TDI_DIRECT_CAMPAIGN_NAME                = 'TDI-Direct';

	public static final String  MESSAGE_STATUS_NEW                      = 'New';
	public static final String  MESSAGE_STATUS_IN_PROGRESS              = 'In Progress';
	public static final String  MESSAGE_STATUS_COMPLETED                = 'Completed';
	public static final String  MESSAGE_STATUS_ERRORED                  = 'Errored';
	
	public static final string  MESSAGE_APPLICATIONNAME_TDI				= 'TDI';

	public static final String  MESSAGE_TYPE_SIGNEDUP                   = 'SignedUp';
	public static final String  MESSAGE_TYPE_UPDATEINFO                 = 'UpdateInfo';
	public static final String  MESSAGE_TYPE_UPDATEPAYMENTDETAILS       = 'UpdatePaymentDetails';
	public static final String  MESSAGE_TYPE_NOPAYMENTMADE              = 'NoPaymentMade';
	
	public static final string  MESSAGE_APPLICATIONNAME_DOMAINAUDIT		= 'DomainAudit';
	
	public static final String  MESSAGE_TYPE_AUDITINFO                  = 'AuditInfo';
	

	public static final String  LEAD_STATUS_CONVERTED                   = 'Converted';

	public static final String  ACCOUNT_TYPE_PROSPECT                   = 'Prospect';
	public static final String  ACCOUNT_TYPE_PROSPECT_OF_INNOVATOR      = 'Prospect of Innovator';
	public static final String  ACCOUNT_TYPE_PROSPECT_COLD_OF_INNOVATOR = 'Prospect Cold of Innovator';
	public static final String  ACCOUNT_TYPE_CUSTOMER_OF_INNOVATOR      = 'Customer of Innovator';
	public static final String  ACCOUNT_TYPE_CUSTOMER_COLD_OF_INNOVATOR = 'Customer Cold of Innovator';

	public static final String  ACCOUNT_ROLE_SCHOOL                     = 'School';

	

	//////////////////////////////////////////////////////////////////////
	// MAIN PROCESS FORK / PUBLIC INTERFACE:
	// This is where processing begins. The message is first sanity checked, and
	// then passed to an appropriate method to handle the message.

	@future
	public static void processAsync(Id msgId) {

		process(msgId);
	}

	public static void process(Id msgId) {

		// Query the message queue objects
		List<MessageQueue__c> messages = [
			SELECT
				Id,
				ApplicationName__c,
				MessageType__c,
				MessageContent__c,
				ErrorMessage__c,
				DateCompleted__c,
				Status__c,
				OriginMsgId__c
			FROM
				MessageQueue__c
			WHERE
				Id = :msgId
		];

		// Make sure a message exists
		if (messages.size() == 1) {

			MessageQueue__c msg = messages[0];

			if (msg.Status__c == MESSAGE_STATUS_COMPLETED) {
				msg.ErrorMessage__c = 'Message already completed';
				update msg;
				return;
			}

			Savepoint sp = Database.setSavepoint();

			try {

				// Set the message status to in progress
				msg.Status__c = MESSAGE_STATUS_IN_PROGRESS;
				update msg;

				// Check if a message already exists with the same origin message id
			//	List<MessageQueue__c> duplicateMessages = [
				//	SELECT Id
				//	FROM MessageQueue__c
				//	WHERE OriginMsgId__c = :msg.OriginMsgId__c
				//	AND Id != :msg.Id
				//];
				//if (duplicateMessages.size() > 0) {
					//throw new MessageQueueException('One or more messages already exist with OriginMsgId__c: ' + msg.OriginMsgId__c);
				//}
				string appName = msg.ApplicationName__c.trim();
				string messageType = msg.MessageType__c.trim();
				if(appName == MESSAGE_APPLICATIONNAME_TDI){
					// Call the appropriate method depending on the message type
					if      (messageType == MESSAGE_TYPE_SIGNEDUP)             signedUp(msg);
					else if ( messageType == MESSAGE_TYPE_UPDATEINFO)           updateInfo(msg);
					else if ( messageType == MESSAGE_TYPE_UPDATEPAYMENTDETAILS) updatePaymentDetails(msg);
					else if (messageType == MESSAGE_TYPE_NOPAYMENTMADE)        noPaymentMade(msg);
					else
						throw new MessageQueueException('Unexpected MessageType__c value: ' + msg.MessageType__c + ' for application name ' +msg.ApplicationName__c  );
				}else if(appName == MESSAGE_APPLICATIONNAME_DOMAINAUDIT){
					if      (messageType == MESSAGE_TYPE_AUDITINFO)             auditInfo(msg);
					else
						throw new MessageQueueException('Unexpected MessageType__c value: ' + msg.MessageType__c + ' for application name ' +msg.ApplicationName__c  );		
				}else {
					throw new MessageQueueException('Unexpected ApplicationName__c value: ' +msg.ApplicationName__c  );	
				}
			}
			catch (Exception e) {
				
				string error ='***process: '+  e.getMessage() + '\n\n//-- Stack Trace --//\n' + e.getStackTraceString();
				HaparaSendEmailNotification.SendAdminErrorEmail('MessageQueue process', error, '');
				System.debug(error);
				Database.rollback(sp);
				msg.Status__c = MESSAGE_STATUS_ERRORED;
				msg.ErrorMessage__c =error;
				update msg;
			}
		}
	}
	
	
	//////////////////////////////////////////////////////////////////////
	// AUDIT INFO
	public class AuditInfoMessage{
		public String number_students='0';
		public String intervention_enabled='';
		public String gplus_enabled='';
		public String domain='';
		public String sis_enabled='';
		public String parentportal_enabled='';
		public String rc_enabled='';
		public String primary_contact='';
		public String isActive='false';
		public String gmailviewer_enabled='';
		public String deactivation_dt='';
		public String reseller='';
		public String domtype='';
		public String created_by='';
		public String created_dt='';
		public String domlist_lastupdate_by='';
		public boolean IsAttachedToAccount=false;
	}
	
	
	private static void auditInfo(MessageQueue__c msg) {
		system.debug('***auditInfo: parsing the json for multi domains ' +msg.OriginMsgId__c);
		// Deserialize the message content
		string msgc= msg.MessageContent__c;
		list<AuditInfoMessage> auditInfos =  getAuditInfosPerDomain(msgc);
		if(auditInfos.size()==0)
			throw new MessageQueueException('auditInfo: no json parsed');
		AuditInfoMessage msgContent;
		boolean createDomainRecord = true;
		Id accId = null;
		map<string,Contact> cons = new map<string,Contact>();
		
		list<string> accountDomains = new list<string>();
		for(AuditInfoMessage a : auditInfos){
			system.debug('***auditInfo: adding to accountdomains ' + a.domain);
			accountDomains.add(a.domain);
		}
		
		system.debug('***auditInfo: query the acc');
		date currentYearJan =   date.valueOf(Date.today().year()+'-01-01');
		Date nextYearJan = date.valueOf((Date.today().year()+1)+'-01-01');
		list<Account> acc = [Select a.Website,a.ParentId,a.Id, a.TD_Domain_Inactive__c,No_Students_Sign_Up__c,
			a.NewNextInvoiceDate__c,a.CurrencyIsoCode,a.Type,
			
			 (Select Id, Email,Is_TD_Admin_Contact__c From Contacts ),
			 
			 (Select Quantity__c ,Subscription_Start_Date__c,Subscription_End_Date__c, Subscription_Period__c,Unit_Price__c,
			 
			    Product__r.Subscription_Period__c, Product__r.Subscription_Type__c, Product__r.Description, 
			    Product__r.ProductCode, Product__c 
			 	From Account_Product__r 
			 	where Subscription_Start_Date__c<:nextYearJan 
        		and (NOT Status__c LIKE '%cancelled%') AND Subscription_End_Date__c >today
        		AND (Product_Family__c = 'TD' OR Product_Family__c ='TD + RC') and Invoice_No__c != null
        	  ) ,
        	  
			  (Select CreatedDate, Opportunity_Name_Template__c From Opportunities 
			  where (Opportunity_Name_Template__c like 'Renewal%' ) 
			  and CloseDate >=:nextYearJan and isclosed = false
			  )
			From Account a where a.Website in :accountDomains order by website];
		system.debug('***auditInfo: return acc ' + acc.size());
		map<string, Account> parentAccounts = new map<string,Account>();
		for(Account a : acc ){
			string website = a.website.trim().toLowerCase();
			system.debug('***auditInfo:adding to the processing queue:' +website + ' queue size:' +parentAccounts.size());
			
			if(!parentAccounts.containsKey(website)){
				system.debug('***auditInfo:added to the processing queue:' +website);
				parentAccounts.put(website,a);
			}else{
				if(a.parentId ==null){
					parentAccounts.remove(website);
					parentAccounts.put(website, a);
				}
			}
			
		}
	//	list<Account> tobeUpdateAcc = new list<Account>();	
		list<TD_Domain__c> tobeInsertedTDDomain = new list<TD_Domain__c>();
		string extID = Date.today().year() + ''+Date.today().month()+''+ date.today().day();
		map<id,Account> tobeUpdatedCheck = new map<id,Account>();
		
		for(AuditInfoMessage aInfo : auditInfos ){
			Account a=null;
			string auditdomain = aInfo.domain.trim().toLowerCase();
			if(parentAccounts.containsKey(auditdomain)){
				system.debug('***auditInfo: found matching account:' +auditdomain);
				a = parentAccounts.get(auditdomain);
			}
			if(a !=null){
				system.debug('***auditInfo: acc exists:' + a.website);
				createDomainRecord = true;
				accId= a.Id;
				msgContent = aInfo;
				system.debug('***auditInfo: msgContent is not null:' + msgContent.domain);
				msgContent.IsAttachedToAccount = true;
				
				string TDDomainInactive = string.IsBlank( a.TD_Domain_Inactive__c )? '': a.TD_Domain_Inactive__c;
				
				if(!boolean.valueOf(msgContent.isActive) && TDDomainInactive.contains('{'+msgContent.domain+'}')){
					createDomainRecord = false;
				}else if(!boolean.valueOf(msgContent.isActive)){
					a.TD_Domain_Inactive__c = (string.IsBlank( a.TD_Domain_Inactive__c )? '': a.TD_Domain_Inactive__c )
								+'{'+msgContent.domain+'}';
				}else if(boolean.valueOf(msgContent.isActive))
					a.TD_Domain_Inactive__c = TDDomainInactive.replace('{'+msgContent.domain +'}','');
				if(createDomainRecord){
					system.debug('***auditInfo: create domain record');
					TD_Domain__c domain =  createAuditInfoMessage( msgContent, accId);
					domain.MessageQueue__c = msg.Id;
					tobeInsertedTDDomain.add(domain);
					checkPrimaryContact(domain);
					a.No_Students_Sign_Up__c = double.valueOf( (string.isBlank( msgContent.number_students)?'0': msgContent.number_students));
					if(a.Account_Product__r.size()>0){
						system.debug('***auditInfo: calcultate the Total_Seats_Invoiced_YTD__c');
						decimal purchasedSeats = 0.0;
						for(Account_Products__c p : a.Account_Product__r){
							purchasedSeats = purchasedSeats + p.Quantity__c;
						}
						a.Total_Seats_Invoiced_YTD__c = purchasedSeats;
					}
					
					if(!tobeUpdatedCheck.containsKey(a.id)){
						//tobeUpdateAcc.add(a);
						tobeUpdatedCheck.put(a.id,a);
					}
					system.debug('***auditInfo: updated acc');
				}	
			}
		}
		
		list<AuditInfoMessage> justCreateDomain =new list<AuditInfoMessage>();
		system.debug('***auditInfo: finding damains not linked to accounts');	
		for(AuditInfoMessage a1 :auditInfos ){
			system.debug('***auditInfo: adding to the create domain list:' + a1.domain);			
			if(!a1.IsAttachedToAccount && boolean.valueOf( a1.isActive)){
				justCreateDomain.add(a1);
			}
		}
		for(AuditInfoMessage a2 : justCreateDomain){
			system.debug('***auditInfo: creating domain with no accounts:' + a2.domain);
			TD_Domain__c domain =  createAuditInfoMessage( a2, null);
			domain.MessageQueue__c = msg.Id;			
			tobeInsertedTDDomain.add(domain);
			checkPrimaryContact(domain);
		}
		
		if(tobeInsertedTDDomain.size()>0){
			insert tobeInsertedTDDomain;
			
			if(tobeUpdatedCheck.size()>0)
				update tobeUpdatedCheck.values();
		}
		
			
		// Mark the message as completed
		msg.Status__c = MESSAGE_STATUS_COMPLETED;
		msg.DateCompleted__c = Datetime.now();
		msg.ErrorMessage__c = null;
		update msg;
		
	}
	
	private static void checkPrimaryContact(TD_Domain__c domain){
		//check if the primary contact field is populate with valid emails
		if(string.isEmpty(domain.Primary_Contact__c))
			domain.Status__c = HAPARA_CONST.AUDIT_INFO_STATUS_MISSINGCONTACT;
		else{
			string emails = domain.Primary_Contact__c;
			list<string> conEmails =emails.Contains(';') ? emails.split(';'):emails.split(',');
			if(conemails.size()==0)
				domain.Status__c = HAPARA_CONST.AUDIT_INFO_STATUS_MISSINGCONTACT;
		}
	}
	
	public static list<AuditInfoMessage> getAuditInfosPerDomain(string content){
		system.debug('***getAuditInfosPerDomain: entering ' + content);
		list<AuditInfoMessage> result = new list<AuditInfoMessage>();
		string temp = content.substring(1, content.length()-1);
		list<string>domains = temp.split('},');
		for(string d : domains){ 
			system.debug('***getAuditInfosPerDomain: parsing ' + d);
			AuditInfoMessage temp2 = (AuditInfoMessage)System.JSON.deserialize(d+'}', AuditInfoMessage.class);
			temp2.IsAttachedToAccount =false;
			result.add(temp2);
		}
		return result;
	}

	public static TD_Domain__c createAuditInfoMessage(AuditInfoMessage msgContent,string accId){
			system.debug('***createAuditInfoMessage: accId ' + accId);
			TD_Domain__c domain =  new TD_Domain__c();
			domain.Number_Students__c =string.isBlank( msgContent.number_students)?'0':msgContent.number_students;
			domain.Intervention_Enabled__c = msgContent.intervention_enabled;
			domain.Gplus_Enabled__c = msgContent.gplus_enabled;
			domain.Student_Domain_Name__c = msgContent.domain;
			domain.SIS_Enabled__c = msgContent.sis_enabled;
			domain.Parent_Portal_Enabled__c = msgContent.parentportal_enabled;
			domain.RC_Enabled__c = msgContent.rc_enabled;
			domain.Primary_Contact__c = msgContent.primary_contact;
			domain.Is_Active__c = boolean.valueOf( msgContent.isActive);
			domain.Gmail_Viewer_Enabled__c = msgContent.gmailviewer_enabled;
			if(accId != null)
				domain.Account__c = accId;

			domain.deactivation_dt__c =string.isBlank(msgContent.deactivation_dt)?null: (msgContent.deactivation_dt.contains('-')?Date.valueOf( msgContent.deactivation_dt):null);
			domain.Student_Domain_Name__c = msgContent.domain;
			domain.Domain_Type__c = msgContent.domtype;
			domain.Reseller__c =msgContent.reseller;
			domain.Domlist_Lastupdate_By__c = msgContent.domlist_lastupdate_by;
			domain.Activation_Date__c = string.isBlank(msgContent.created_dt)?null: (msgContent.created_dt.contains('-')?Date.valueOf( msgContent.created_dt):null);
			return domain;
	}

	//////////////////////////////////////////////////////////////////////
	// SIGNED UP

	public class SignedUpMessage {

		public String email;
		public String fullname;
		public String startdate;
		public String trialenddate;
		public String referrer;
		public Integer tcversion;
		public String notificationperference;
	}

	private static void signedUp(MessageQueue__c msg) {

		// Deserialize the message content
		SignedUpMessage msgContent = (SignedUpMessage)System.JSON.deserialize(msg.MessageContent__c, SignedUpMessage.class);

		Account account = null;
		Campaign campaign = null;

		// Look for existing person account with the same email address
		{
			List<Account> accountQueryResult = [
				SELECT Id, PersonEmail, PersonContactId
				FROM Account
				WHERE PersonEmail = :msgContent.email
				AND IsPersonAccount = true
			];
			
			if (accountQueryResult.size() == 1) {
				account = accountQueryResult[0];
			}

			else if (accountQueryResult.size() > 1) {
				throw new MessageQueueException('There are multiple existing person accounts with the email address ' + msgContent.email);
			}
		}

		// If an existing account with the email wasn't found, use 
		if (account == null) {

			// Get any leads with a matching email address
			List<Lead> leadQueryResult = [
				SELECT Id, Email, Company
				FROM Lead
				WHERE Email = :msgContent.email
				AND IsConverted = false
			];

			if (leadQueryResult.size() == 1) {
				Lead lead = leadQueryResult[0];

				// To convert to a person account, the lead must have a null company value
				if (lead.Company != null) {
					lead.Company = null;
					update lead;
				}

				// Convert the lead
				Database.LeadConvert lc = new Database.LeadConvert();
				lc.setLeadId(lead.Id);
				lc.setConvertedStatus(LEAD_STATUS_CONVERTED); // TODO: set by custom setting
				lc.setDoNotCreateOpportunity(true); // We will handle making the opportunity manually in a later step
				Database.LeadConvertResult lcr = Database.convertLead(lc);

				if (!lcr.isSuccess()) {

					String errorMessage = 'Failed to convert existing lead to account with reasons;';

					for (Database.Error e : lcr.getErrors()) {
						errorMessage += '\nCode: ' + e.getStatusCode() + ' Message: ' + e.getMessage() + 'Fields:';
						for (String field : e.getFields()) {
							errorMessage += ' ' + field;
						}
					}

					throw new MessageQueueException(errorMessage);
				}

				// Get the converted account record
				List<Account> accountQueryResult = [
					SELECT Id, PersonEmail, PersonContactId
					FROM Account
					WHERE Id = :lcr.getAccountId()
				];

				if (accountQueryResult.size() == 1) {
					account = accountQueryResult[0];
				}
			}
		}
		
		// Didn't find a lead either? Make a new account
		if (account == null) {

			account = new Account(
				LastName = msgContent.fullname,
				RecordTypeId = getPersonAccountId()
			);
			insert account;

			account = [
				SELECT Id, PersonEmail, PersonContactId
				FROM Account
				WHERE Id = :account.Id
			];
		}

		// When the referrer is an email, find a person account with that email and
		// set it as the Referral__c lookup. Else set the Referral_Email__c field.
		if (msgContent.referrer.contains('@')) {

			List<Account> referrerAccounts = [
				SELECT Id, PersonEmail
				FROM Account
				WHERE PersonEmail = :msgContent.referrer
			];

			if (referrerAccounts.size() == 1) {
				account.Referral__c = referrerAccounts[0].Id;
			}

			else {
				account.Referral_Email__c = msgContent.referrer;
			}
		}

		// When the referrer is not an email, it's referring to a campaign
		// Find the campaign and make the account a member, else make a new campaign
		else {

			// Find an existing campaign with the name from the referrer field
			List<Campaign> existingCampaigns = [
				SELECT Id, Name
				FROM Campaign
				WHERE Name = :msgContent.referrer
			];

			if (existingCampaigns.size() == 1) {
				campaign = existingCampaigns[0];
			}

			// If an existing campaign can't be found, make a new one
			else if (existingCampaigns.size() == 0) {
				Product2 tdiProduct = [
					SELECT Id, Name, Parent_Campaign__c
					FROM Product2
					WHERE ProductCode = :TDI_PRODUCT_CODE
					AND Parent_Campaign__c != null
				];
				Campaign tdiCampaign = [
					SELECT Id, Name
					FROM Campaign
					WHERE Id = :tdiProduct.Parent_Campaign__c
				];
				campaign = new Campaign(
					Name = msgContent.referrer,
					ParentId = tdiCampaign.Id,
					IsActive = true
				);
				insert campaign;
			}

			// Make the account a member of the campaign
			try {
				CampaignMember campaignMembership = new CampaignMember(
					CampaignId = campaign.Id,
					ContactId = account.PersonContactId
				);
				insert campaignMembership;
			}
			catch (Exception e) {
				// allow an exception here, it just means the account is already a member of the campaign
				// more reliable to catch this, than to prequery existing memberships
			}
		}

		// Make new opportunity
		{
			Opportunity opportunity = new Opportunity(
				AccountId = account.Id,
				Name = msgContent.fullname + '-' + OPPORTUNITY_NAME_TEMPLATE,
				Opportunity_Name_Template__c = OPPORTUNITY_NAME_TEMPLATE,
				CloseDate = Date.today().addDays(OPPORTUNITY_CLOSE_DATE_INTERVAL),
				StageName = OPPORTUNITY_STAGE_PROSPECTING,
				CurrencyIsoCode='USD'
			);

			if (campaign != null) {
				opportunity.CampaignId = campaign.Id;
			}

			else {
				Campaign tdiDirectCampaign =  [
					SELECT Id, Name
					FROM Campaign
					WHERE Name = :TDI_DIRECT_CAMPAIGN_NAME
				];
				opportunity.CampaignId = tdiDirectCampaign.Id;
			}
			insert opportunity;

			PricebookEntry tdiPricebookEntry = [
				SELECT Id, UnitPrice
				FROM PricebookEntry
				WHERE Id = :settings.TDI_PricebookEntry_Id__c
			];

			OpportunityLineItem lineItem = new OpportunityLineItem(
				OpportunityId = opportunity.Id,
				PricebookEntryId = tdiPricebookEntry.Id,
				UnitPrice = tdiPricebookEntry.UnitPrice,
				Quantity = 1
			);
			insert lineItem;
		}

		// Map the fields from the message content to the account
		account.Type = ACCOUNT_TYPE_PROSPECT_OF_INNOVATOR;
		account.TD_Setup_Date__c = Date.valueOf(msgContent.startdate);
		account.Trial_End_Date__c = Date.valueOf(msgContent.trialenddate);
		account.Term_And_Condition_Version__c = msgContent.tcversion;
		account.Notification_Per__c = msgContent.notificationperference;
		account.PersonEmail = msgContent.email;
		update account;

		// Mark the message as completed
		msg.Status__c = MESSAGE_STATUS_COMPLETED;
		msg.DateCompleted__c = Datetime.now();
		msg.ErrorMessage__c = null;
		update msg;
	}




	//////////////////////////////////////////////////////////////////////
	// UPDATE INFO

	public class UpdateInfoMessage {

		public String city;		//BEVERLY HILLS
		public String school;	//HAWTHORNE ELEMENTARY
		public String district;	//BEVERLY HILLS UNIFIED
		public String country;	//US
		public String state;	//CA
		public String zipcode;	//90210
		public String email;	//t.five@zawadzki.co.nz
	}

	private static void updateInfo(MessageQueue__c msg) {

		// Deserialize the message content
		UpdateInfoMessage msgContent = (UpdateInfoMessage)System.JSON.deserialize(msg.MessageContent__c, UpdateInfoMessage.class);

		// Match person account on email address
		List<Account> accountQuery = [
			SELECT Id, FirstName, LastName, PersonEmail, Type,
			(
				SELECT Id, Name, Opportunity_Name_Template__c
				FROM Opportunities
				WHERE Opportunity_Name_Template__c = :OPPORTUNITY_NAME_TEMPLATE
				AND IsClosed = false
			)
			FROM Account
			WHERE PersonEmail = :msgContent.email
		];

		// Update the type of account and stage of opportunity
		if (accountQuery.size() == 1) {

			Account account = accountQuery[0];

			// Query or create the district account
			Account district = null;
			{
				List<Account> districtQuery = [
					SELECT Id, Name
					FROM Account
					WHERE Name = :msgContent.district
					AND IsPersonAccount = false
				];

				if (districtQuery.size() == 1) {
					district = districtQuery[0];
				}

				else if (districtQuery.size() == 0 && msgContent.district != null && msgContent.district != '') {
					district = new Account(
						Name = msgContent.district,
						Type = ACCOUNT_TYPE_PROSPECT
					);
					insert district;
				}

				else if (districtQuery.size() > 1) {
					throw new MessageQueueException('More than one District was found with the name ' + msgContent.district);
				}
			}

			// Query or create the school account
			Account school = null;
			{
				List<Account> schoolQuery = [
					SELECT Id, Name
					FROM Account
					WHERE Name = :msgContent.school
					AND IsPersonAccount = false
				];

				if (schoolQuery.size() == 1) {
					school = schoolQuery[0];
					if (district != null) {
						school.ParentId = district.Id;
						update school;
					}
				}

				else if (schoolQuery.size() == 0) {
					school = new Account(
						Name = msgContent.school,
						Type = ACCOUNT_TYPE_PROSPECT

					);
					if (district != null) {
						school.ParentId = district.Id;
					}
					insert school;
				}

				else if (schoolQuery.size() > 1) {
					throw new MessageQueueException('More than one School was found with the name ' + msgContent.school);
				}
			}

			// Make the account a partner of the school
			List<Partner> existingPartnerships = [
				SELECT Id
				FROM Partner
				WHERE AccountFromId = :account.Id
				AND AccountToId = :school.Id
				AND Role = :ACCOUNT_ROLE_SCHOOL
			];

			if (existingPartnerships.size() == 0) {
				Partner schoolPartnership = new Partner(
					AccountFromId = account.Id,
					AccountToId = school.Id,
					Role = ACCOUNT_ROLE_SCHOOL
				);
				insert schoolPartnership;
			}

			// Change the opportunity stage to Qualification
			if (account.Opportunities.size() == 1) {
				Opportunity opportunity = account.Opportunities[0];
				opportunity.StageName = OPPORTUNITY_STAGE_QUALIFICATION;
				update opportunity;
			}

			else if (account.Opportunities.size() == 0) {
				throw new MessageQueueException('An open Teacher Dashboard Innovator opportunity was not found for account ' + account.Id);
			}

			else if (account.Opportunities.size() > 1) {
				throw new MessageQueueException('More than one open Teacher Dashboard Innovator opportunity was found for account ' + account.Id);
			}

			account.ShippingCountry = msgContent.country;
			account.ShippingPostalCode = msgContent.zipcode;
			account.ShippingState = msgContent.state;
			account.ShippingCity = msgContent.city;
			account.School_District__c = msgContent.district;
			update account;
		}

		else if (accountQuery.size() == 0) {
			throw new MessageQueueException('No Person Account was found with the email ' + msgContent.email);
		}

		else if (accountQuery.size() > 1) {
			throw new MessageQueueException('More than one Person Account was found with the email ' + msgContent.email);
		}

		// Mark the message as completed
		msg.Status__c = MESSAGE_STATUS_COMPLETED;
		msg.DateCompleted__c = Datetime.now();
		msg.ErrorMessage__c = null;
		update msg;
	}




	//////////////////////////////////////////////////////////////////////
	// UPDATE PAYMENT DETAILS

	public class UpdatePaymentDetailsMessage {

		public String paymentdate;	//2013-07-27T00:00:00
		public String paymentamount;	//3022
		public String paymentplan;	//Yearly
		public String firstname;	//Claudia
		public String lastname;	//Constantine
		public String country;	//United States
		public String address1;	//street1
		public String address2;	//street2
		public String city;	//New York City
		public String state;	//NY
		public String zipcode;	//0998
		public String email;	//claudia.constantine@ibp.edu.mx
		public String bill_country;	//New Zealand
		public String bill_address1;	//stonefield
		public String bill_address2;	//
		public String bill_city;	//Stonefield
		public String bill_state;	//Auckland
		public String bill_zipcode;	//0998
	}

	private static void updatePaymentDetails(MessageQueue__c msg) {

		// Deserialize the message content
		UpdatePaymentDetailsMessage msgContent = (UpdatePaymentDetailsMessage)System.JSON.deserialize(msg.MessageContent__c, UpdatePaymentDetailsMessage.class);

		// Match person account on email address
		List<Account> accountQuery = [
			SELECT FirstName, LastName, PersonEmail, Type,
			(
				SELECT Id, Name, Opportunity_Name_Template__c
				FROM Opportunities
				WHERE Opportunity_Name_Template__c = :OPPORTUNITY_NAME_TEMPLATE
				AND IsClosed = false
			)
			FROM Account
			WHERE PersonEmail = :msgContent.email
		];
		
		// Update the type of account and stage of opportunity
		if (accountQuery.size() == 1) {

			Account account = accountQuery[0];

			// If there's a payment date, we need to update the payment details and create a new account product record
			if (msgContent.paymentdate != null && msgContent.paymentdate != '') {

				account.Payment_Date__c = Date.valueOf(msgContent.paymentdate);
				account.TD_Invoiced_Date__c = account.Payment_Date__c;
				account.Credit_Card_Paid_Amt__c = Decimal.valueOf(msgContent.paymentamount) / 100;

				Product2 tdiProduct = [
					SELECT Id
					FROM Product2
					WHERE Name = :TDI_PRODUCT_NAME
				];

				Account_Products__c product = new Account_Products__c();
				product.Account__c = account.Id;
				product.Description__c = msgContent.paymentplan;
				product.Invoice_Date__c = Date.valueOf(msgContent.paymentdate);
				product.Invoice_No__c = 'TDI';
				product.Product__c = tdiProduct.Id;
				product.Quantity__c = 1;
				product.Unit_Price__c = Decimal.valueOf(msgContent.paymentamount) / 100;
				insert product;

				// Update the opportunity stage
				if (account.Opportunities.size() == 1){
					Opportunity opportunity = account.Opportunities[0];
					opportunity.StageName = OPPORTUNITY_STAGE_CLOSED_WON;
					opportunity.CloseDate = Date.valueOf(msgContent.paymentdate);
					opportunity.Amount = Decimal.valueOf(msgContent.paymentamount) / 100;
					opportunity.CurrencyIsoCode='USD';
					update opportunity;
				}
				else if (account.Opportunities.size() > 1) {
					throw new MessageQueueException('More than one open Teacher Dashboard Innovator opportunity was found for account ' + account.Id);
				}
			}

			// Update the account type
			account.Type = ACCOUNT_TYPE_CUSTOMER_OF_INNOVATOR;
			account.Invoice_Period__c = msgContent.paymentplan;
			account.FirstName = msgContent.firstname;
			account.LastName = msgContent.lastname;
			account.ShippingCountry = msgContent.country;
			account.ShippingStreet = msgContent.address1;
			account.ShippingStreet += msgContent.address2 == null || msgContent.address2 == '' ? '' : '\n' + msgContent.address2;
			account.ShippingCity = msgContent.city;
			account.ShippingState = msgContent.state;
			account.ShippingPostalCode = msgContent.zipcode;
			account.BillingCountry = msgContent.bill_country;
			account.BillingStreet = msgContent.bill_address1;
			account.BillingStreet += msgContent.bill_address2 == null || msgContent.bill_address2 == '' ? '' : '\n' + msgContent.bill_address2;
			account.BillingCity = msgContent.bill_city;
			account.BillingState = msgContent.bill_state;
			account.BillingPostalCode = msgContent.bill_zipcode;
			update account;
		}
		else if (accountQuery.size() == 0) {
			throw new MessageQueueException('No Person Account was found with the email ' + msgContent.email);
		}
		else if (accountQuery.size() > 1) {
			throw new MessageQueueException('More than one Person Account was found with the email ' + msgContent.email);
		}

		// Mark the message as completed
		msg.Status__c = MESSAGE_STATUS_COMPLETED;
		msg.DateCompleted__c = Datetime.now();
		msg.ErrorMessage__c = null;
		update msg;
	}




	//////////////////////////////////////////////////////////////////////
	// NO PAYMENT MADE

	public class NoPaymentMadeMessage {

		public String email;
	}

	private static void noPaymentMade(MessageQueue__c msg) {
		
		// Deserialize the message content
		NoPaymentMadeMessage msgContent = (NoPaymentMadeMessage)System.JSON.deserialize(msg.MessageContent__c, NoPaymentMadeMessage.class);

		// Query all Person Accounts with an email from the list
		List<Account> accountQuery = [
			SELECT Id, PersonEmail, Type,
			(
				SELECT Id, Name, Opportunity_Name_Template__c
				FROM Opportunities
				WHERE Opportunity_Name_Template__c = :OPPORTUNITY_NAME_TEMPLATE
				AND IsClosed = false
			)
			FROM Account
			WHERE PersonEmail = :msgContent.email
		];
		
		// Update the type of account and stage of opportunity
		if (accountQuery.size() == 1) {

			// Update the account type
			Account account = accountQuery[0];
			if (account.Type == ACCOUNT_TYPE_PROSPECT_OF_INNOVATOR) {
				account.Type = ACCOUNT_TYPE_PROSPECT_COLD_OF_INNOVATOR;
			}
			else if (account.Type == ACCOUNT_TYPE_CUSTOMER_OF_INNOVATOR) {
				account.Type = ACCOUNT_TYPE_CUSTOMER_COLD_OF_INNOVATOR;
			}
			account.Deactivation_Date__c = date.today();
			update account;

			// Update the opportunity stage
			if (account.Opportunities.size() == 1){
				Opportunity opportunity = account.Opportunities[0];
				opportunity.StageName = OPPORTUNITY_STAGE_PROSPECTING;
				update opportunity;
			}
			else if (account.Opportunities.size() == 0) {
				throw new MessageQueueException('An open Teacher Dashboard Innovator opportunity was not found for account ' + account.Id);
			}
			else if (account.Opportunities.size() > 1) {
				throw new MessageQueueException('More than one open Teacher Dashboard Innovator opportunity was found for account ' + account.Id);
			}
		}
		else if (accountQuery.size() == 0) {
			throw new MessageQueueException('No Person Account was found with the email ' + msgContent.email);
		}
		else if (accountQuery.size() > 1) {
			throw new MessageQueueException('More than one Person Account was found with the email ' + msgContent.email);
		}

		// Mark the message as completed
		msg.Status__c = MESSAGE_STATUS_COMPLETED;
		msg.DateCompleted__c = Datetime.now();
		msg.ErrorMessage__c = null;
		update msg;
	}




	//////////////////////////////////////////////////////////////////////
	// UTILITIES:
	// These auxiliary subclasses, methods and class variables support the process

	public static Id personAccountId;
	public static Id getPersonAccountId() {

		if (personAccountId == null) {
			List<RecordType> rtQuery = [
				SELECT Id, Name
				FROM RecordType
				WHERE IsActive = true
				AND IsPersonType = true
				AND SobjectType = 'Account'
				AND Name = :PERSON_ACCOUNT_RECORDTYPE
			];
			if (rtQuery.size() == 1) {
				personAccountId = rtQuery[0].Id;
			}
		}
		return personAccountId;
	}
}