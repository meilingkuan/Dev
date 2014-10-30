/**
 * A custom implementation of the LeadConversion process.
 * @author Logan Moore
 * @created 2013-03-21
 */
public with sharing class CustomConvertController {

    private String leadIdParam;
    private String retUrlParam;
   	static final String CONVERTTYPE_SCHEDULEDEMO = 'ScheduleDemo';
   	static final String CONVERTTYPE_NORMAL='Normal'; 
   
    // Preload Error. If not null, the preload error page is displayed, else the normal page is displayed.
    public String preloadError { get; private set; }

    // A copy of the lead this conversion page is operating on
    public Lead lead { get; private set; }
    private String enumeratedAccountName;

    // Convert Lead Section
    public Boolean sendEmailToTheOwner { get; set; }
    public String accountId { get; set; }
    public String opportunityName { get; set; }
    public Boolean doNotCreateOpportunity { get; set; }
    public String convertedStatus { get; set; }
    public Boolean taskSendNotificationEmail { get; set; }

    // Instead of providing custom functionality for date pickers and owner selection and picklists, I've
    // created these objects and can use apex:inputField to get the full standard functionality of that field.
    public Account account { get; set; }
    public Opportunity opportunity { get; set; }

    // Task is the exception, as it actually gets inserted
    public Task task { get; set; }

    public CustomConvertController() {
        
        // If there's a retUrl parameter, store it
        if (ApexPages.currentPage().getParameters().containsKey('retUrl')) {
            retUrlParam = ApexPages.currentPage().getParameters().get('retUrl');
        }

        // If there's an id parameter (expected), store it, else throw preload error
        if (ApexPages.currentPage().getParameters().containsKey('id')) {
            leadIdParam = ApexPages.currentPage().getParameters().get('id');
        } else {
            showLeadNotFoundError();
            return;
        }

        // Query the lead (the initLead method also checks if the lead has already been converted)
        if (initLead() == false) {
            return;
        }

        // Initialize records for data input
        account = new Account();
        opportunity = new Opportunity();
        task = new Task();
        opportunityName = enumeratedAccountName + '-';
        sendEmailToTheOwner = false;
        doNotCreateOpportunity = false;
        taskSendNotificationEmail = false;

        // The reminder checkbox should default to enabled, and the datetime value to now
        task.IsReminderSet = true;
        task.ReminderDateTime = DateTime.now();

        // Check if the lead owner is a user. If it is, assign it as the lead owner,
        // otherwise assign the currently active user as the new account owner.
        if (1 == [SELECT Id FROM User WHERE Id =: lead.OwnerId].size()) {
            account.OwnerId = lead.OwnerId;
        } else {
            account.OwnerId = UserInfo.getUserId();
        }
    }

    private Boolean initLead() {
        
        // query the lead from the database
        try {
            lead = [SELECT Id, Name, Company, OwnerId, IsConverted ,Prospect_Timezone__c, Demo_Session_Date__c,
            	How_did_you_hear_about_us__c,How_did_you_hear_about_us2__c,
            	
            	 (Select CampaignId, CreatedDate, Campaign_Type__c 
            	 	From CampaignMembers
            	 	where Campaign_Type__c = :HAPARA_CONST.CAMPAIGN_TYPE_CONFERENCE 
            	 	order by CreatedDate desc) 
            	FROM Lead WHERE Id =: leadIdParam];
        } catch (Exception ex) {
            showLeadNotFoundError();
            return false;
        }

        // check if the lead has already been converted
        if (lead.IsConverted) {
            showLeadAlreadyConvertedError();
        }

        // Set the enumerated account name
        enumeratedAccountName = lead.Company == null ? lead.Name : lead.Company;

        return true;
    }

    private void showLeadNotFoundError() {
        setPreloadError('Data Not Available',
            'The data you were trying to access could not be found. It may be due to another user deleting the data or '
            + 'a system error. If you know the data is not deleted but cannot access it, please look at our <a href="ja'
            + 'vascript:openPopupFocusEscapePounds(\'https://help.salesforce.com/apex/htdoor?body=%2Fhelp%2Fhlpsupporto'
            + 'ptions_JP.jsp%3Ftssection%3Dsupport&loc=support&language=en_US&release=182.13.4&instance=CS5\', \'Help\''
            + ', 1024, 768, \'width=1024,height=768,resizable=yes,toolbar=yes,status=yes,scrollbars=yes,menubar=yes,dir'
            + 'ectories=no,location=yes,dependant=no\', false, false);" title="support (New Window)">support</a> page.'
        );
    }

    private void showLeadAlreadyConvertedError() {
        setPreloadError('Lead has been Converted',
            'This lead has been converted. Please use Site Search to search for the converted records.'
        );
    }

    private void setPreloadError(String title, String description) {
        preloadError = '<table cellspacing="10"><tbody>'
        + '<tr><td><span style="font-weight: bold; font-size: 12pt;">' + title + '</span></td></tr>'
        + '<tr><td>' + description;
        if (ApexPages.currentPage().getParameters().containsKey('retUrl')) {
            preloadError += '<br><br>Click <a href="'
            + ApexPages.currentPage().getParameters().get('retUrl')
            + '">here</a> to return to the previous page.';
        }
        preloadError += '</td></tr></tbody></table>';
    }

    private List<SelectOption> accountNameOptions;

    public List<SelectOption> getAccountNameOptions() {
        
        if (accountNameOptions == null) {

            // the list of SelectOptions that will be returned by this method
            accountNameOptions = new List<SelectOption>();

            // search for existing accounts with the same name (exact matches only, no fuzzy matching)
            List<Account> existingAccounts = [ SELECT Id, Name FROM Account WHERE Name =: enumeratedAccountName];

            // if there are existing accounts with the same name we need to add '--none--', forcing user select and option
            if (existingAccounts.size() > 0) {
                accountNameOptions.add(new SelectOption('none', '--None--'));
            }

            // the option to create a new account is always available
            accountNameOptions.add(new SelectOption('new', 'Create New Account: ' + enumeratedAccountName));

            // the we list any matched accounts that can be merged with
            for (Account a : existingAccounts) {
                accountNameOptions.add(new SelectOption(a.Id, 'Attach to Existing: ' + a.Name));
            }
        }

        // return the populated list of SelectOptions
        return accountNameOptions;
    }

    public void addAccountNameOption() {

        try {
            Account acc = [SELECT Id, Name FROM Account WHERE Id =: opportunity.AccountId];
            Boolean exists = false;
            for (SelectOption opt : accountNameOptions) {
                if (opt.getValue() != 'none' && opt.getValue() != 'new' && opt.getValue() == acc.Id) {
                    exists = true;
                    break;
                }
            }
            if (!exists) {
                accountNameOptions.add(new SelectOption(acc.Id, 'Attach to Existing: ' + acc.Name));
            }
            accountId = acc.Id;
            enumeratedAccountName = acc.Name;
        } catch(Exception ex) {
            ApexPages.Message pageMessage = new ApexPages.Message( ApexPages.Severity.ERROR, ex.getMessage() );
            ApexPages.addMessage( pageMessage );
        }
    }

    public List<SelectOption> getOpportunityNameOptions() {

        // the list of SelectOptions that will be returned by this method
        List<SelectOption> options = new List<SelectOption>();

        List<Schema.PicklistEntry> picklistEntries = Schema.sObjectType.Opportunity.fields.Opportunity_Name_Template__c.getPicklistValues();

        // add the opportunity names
        options.add(new SelectOption(enumeratedAccountName + '-', '--None--'));
        for (Schema.PicklistEntry ple : picklistEntries) {
            options.add(new SelectOption(enumeratedAccountName + '-' + ple.getLabel(), ple.getLabel()));
        }

        // return the now populated list of SelectOptions
        return options;
    }
    
    public List<SelectOption> getConvertedStatusOptions() {

        // the list of SelectOptions that will be returned by this method
        List<SelectOption> options = new List<SelectOption>();

        // get the available converted lead statuses
        List<LeadStatus> convertedStatuses = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true];

        // add those statuses to the options list
        for (LeadStatus s : convertedStatuses) {
            options.add(new SelectOption(s.MasterLabel, s.MasterLabel));
        }

        // return the now populated list of SelectOptions
        return options;
    }

    public String accountNameError { get; private set; }
    public String opportunityNameError { get; private set; }
    public String opportunityStageError { get; private set; }
    public String taskStatusError { get; private set; }
    public String taskPriorityError { get; private set; }
    public String taskReminderError { get; private set; }

    public Boolean validate() {

        Boolean result = true;

        accountNameError = null;
        opportunityNameError = null;
        opportunityStageError = null;
        taskStatusError = null;
        taskPriorityError = null;
        taskReminderError = null;

        if (accountId == 'none') {
            accountNameError = '<div class=\'errorMsg\'><strong>Error:</strong> You must enter a value</div>';
            result = false;
        }

        if (doNotCreateOpportunity == false) {
        	if(string.isBlank( opportunity.Opportunity_Name_Template__c)){
        		opportunityNameError = '<div class=\'errorMsg\'><strong>Error:</strong> Please select a value in the opportunity name dropdown</div>';
                result = false;
        	}
            if (opportunityName == null || opportunityName == '') {
                opportunityNameError =opportunityNameError+ '<div class=\'errorMsg\'><strong>Error:</strong> You must enter a value</div>';
                result = false;
            }
            if (opportunity.StageName == null) {
                opportunityStageError = '<div class=\'errorMsg\'><strong>Error:</strong> You must enter a value</div>';
                result = false;
            }
        }

        if (task.Subject != null) {
            if (task.Status == null) {
                taskStatusError = '<div class=\'errorMsg\'><strong>Error:</strong> You must enter a value</div>';
                result = false;
            }
            if (task.Priority == null) {
                taskPriorityError = '<div class=\'errorMsg\'><strong>Error:</strong> You must enter a value</div>';
                result = false;
            }
        }

        if (task.IsReminderSet) {
            if (task.ReminderDateTime == null) {
                taskReminderError = '<div class=\'errorMsg\'><strong>Error:</strong> You must enter a value</div>';
                result = false;
            }
        }

        return result;
    }
    
    public PageReference convertScheduleDemo(){
    	return convert(CONVERTTYPE_SCHEDULEDEMO);
    }
    
    public PageReference convert(){
    	return convert(CONVERTTYPE_NORMAL);
    }
    
    public PageReference convert(string convertType) {
		try{
			system.debug('***convert - convertType = ' + convertType);
	        // reinit the lead, in case there have been changes
	        if (initLead() == false) {
	            return null;
	        }
	
	        if (validate() == false) {
	            return null;
	        }
	
	        // The converter is the standard object that performs a lead conversion. I've created it in the actual convert
	        // process because it's not serializable so can't persist as a member variable in sessions.
	        Database.LeadConvert lc = new Database.LeadConvert();
	        // lead
	        lc.setLeadId(ID.valueOf(lead.Id));
	        lc.setConvertedStatus(convertedStatus);
	        // account
	        lc.setOwnerId(account.OwnerId);
	        lc.setSendNotificationEmail(sendEmailToTheOwner);
	
	        // opportunity
	        lc.setDoNotCreateOpportunity(doNotCreateOpportunity);
	        if (!doNotCreateOpportunity) {
	            lc.setOpportunityName(opportunityName);
	        }
	
	        // handle the selected account
	        if (accountId == 'none') {
	            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Account not selected'));
	            return null;
	        }
	        else if (accountId != 'new') {
	            lc.setAccountId(accountId);
	        }
	
	        // Perform the conversion
	        Database.LeadConvertResult lcr = Database.convertLead(lc);
	
	        // Things to do after a successful conversion
	        if (lcr.isSuccess()) {
	
	            // Insert the task
	            if (task.Subject != null && task.Subject != '') {
	                task.WhatId = lcr.AccountId;
	                task.WhoId = lcr.ContactId;
	
	                // The following 3 lines of code control whether the task notification is sent when the task is inserted
	                Database.DMLOptions dmlo = new Database.DMLOptions();
	                dmlo.EmailHeader.triggerUserEmail = taskSendNotificationEmail;
	                database.insert(task, dmlo);
	            }
	            
	           
	            // And we need to update the opportunity to change the status
	            if (lcr.opportunityId != null && opportunity.StageName != null) {
	            	Hapara_SchedulingHandler.updateOpportunityAfterConvert(lcr.opportunityId,  lead, lcr.ContactId, opportunity.StageName, 
	            			 opportunity.Opportunity_Name_Template__c);
	     
	            }
				Hapara_SchedulingHandler.updateAccountAfterConvert( lcr.AccountId,lead);
				
				if(convertType==CONVERTTYPE_SCHEDULEDEMO){
					system.debug('***convert - sending unconfirm email');
					
					string emailtemplate = Hapara_SchedulingHandler.ScheduleContactForDemo(lcr.ContactId);
					HaparaSendEmailNotification.SendEmailInThefuture(lcr.ContactId,lcr.Accountid,emailTemplate,
						'Hapara Team', 'customerservices@hapara.com');
				} 
				
	            // redirect the user to the newly created account
	            return new PageReference('/' + lcr.accountId);
	        }
	
	        // Things to do on errors
	        else {
	            for (Database.Error error : lcr.errors) {
	                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error.message));
	            }
	        }
		}catch(Exception e){
			
			 ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Convert:'+ e));
		}

        return null;
    }

    public PageReference cancel() {
        if (retUrlParam != null) {
            return new PageReference(retUrlParam);
        } else {
            return new PageReference('/' + leadIdParam);
        }
    }
    
}