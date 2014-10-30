public with sharing class Hapara_Invite_Controller {
 	Id recordId;
 	string srecordType;
 	PageReference fromPage ;
 	
 	public string inviteType{get;set;}
 	public string selectedEmailTemplate{get;set;}
 	public string selectedScheduleType{get;set;}

	public Hapara_Invite_Controller(ApexPages.StandardController stdController){ 	
 		recordId =  ApexPages.currentPage().getParameters().get('Id');	
 		Schema.SObjectType recordType =recordId.getSObjectType(); 
		srecordType = recordType.getDescribe().getName();
 		inviteType =  ApexPages.currentPage().getParameters().get('inviteType');	
 		fromPage = stdController.cancel();
	}
	
	public list<SelectOption> getEmailTemplates(){
		list<SelectOption> options= new list<Selectoption>();
		list<string> templateNames;
		if(inviteType =='DEMO'){
			templateNames = HAPARA_CONST.SETTING_SCHEDULE.Schedule_Unconfirm_Email_Template__c.split(';');
			
		}else if(inviteType =='SETUP'){
			templateNames = HAPARA_CONST.SETTING_SCHEDULE.Setup_Invite_Email__c.split(';');
		}
		list<EmailTemplate> ems = [Select e.id, e.Name,e.DeveloperName 
						From EmailTemplate e where e.DeveloperName in:templateNames ];
		for(EmailTemplate e : ems){
			options.add(new Selectoption(e.DeveloperName, e.Name));
		}
		
		return options;
	}
	
	public list<SelectOption> getScheduleTypes(){
		list<SelectOption> options= new list<Selectoption>();
		list<Hapara_Scheduling_Type__c> types = [Select h.Name, h.Is_Active__c, h.Duration_of_Event_Scheduled__c 
				From Hapara_Scheduling_Type__c h 
				where is_Active__c = true];
				
		for(Hapara_Scheduling_Type__c s : types){
			options.add(new Selectoption(s.id, s.Name + ' ('+ s.Duration_of_Event_Scheduled__c +' hr)'));
		}
		
		return options;
	}
	
	public PageReference sendInvite(){
		string debug = '***sendInvite: srecordType='+srecordType +'; recordId=' + recordId + '; selectedEmailTemplate=' +selectedEmailTemplate
					+ '; selectedScheduleType=' + selectedScheduleType;
		try{
			system.debug(debug);
			if(srecordType =='Lead'  ){
				Lead l = [select id,Lead_Reminder__c, Email from Lead where id=: recordId ];
				if(inviteType=='DEMO'){
					if(string.isEmpty(l.Lead_Reminder__c))
						l.Lead_Reminder__c ='1st time';
					else if(l.Lead_Reminder__c=='1st time')
						l.Lead_Reminder__c ='2nd time';
					else if(l.Lead_Reminder__c=='2nd time')
						l.Lead_Reminder__c ='3rd time';
					else
						l.Lead_Reminder__c ='1st time'; 
				}
				update l;
				HaparaSendEmailNotification.SendContactEmailRecipientIdwithBCCNSenderSetWhatId(l.id,selectedEmailTemplate, 
					null,null, 'Hapara Team',HAPARA_CONST.SETTING_SCHEDULE.Web_To_Lead_Nofications_Email__c, null); 
			 
			}else if(srecordType=='Contact'){
				Contact c = [Select c.Setup_Reminder__c, c.Contact_Reminder__c, c.Account.Demo_Reminder__c, c.Account.Setup_Reminder__c, 
						c.AccountId 
						From Contact c
						where c.id =:recordId];
				Account a = c.Account;
				if(inviteType=='DEMO'){
					if(string.isEmpty(c.Contact_Reminder__c))
						c.Contact_Reminder__c ='1st time';
					else if(c.Contact_Reminder__c=='1st time')
						c.Contact_Reminder__c ='2nd time';
					else if(c.Contact_Reminder__c=='2nd time')
						c.Contact_Reminder__c ='3rd time';
					else
						c.Contact_Reminder__c ='1st time'; 
					
					a.Demo_Reminder__c = c.Contact_Reminder__c;
				}else if(inviteType=='SETUP'){
					c.Hapara_Scheduling_Type__c = selectedScheduleType;
					if(string.isEmpty(c.Setup_Reminder__c))
						c.Setup_Reminder__c ='1st Reminder';
					else if(c.Setup_Reminder__c=='1st Reminder')
						c.Setup_Reminder__c ='2nd Reminder';
					else if(c.Setup_Reminder__c=='2nd Reminder')
						c.Setup_Reminder__c ='3rd Reminder';
					else
						c.Setup_Reminder__c ='1st Reminder'; 
						
					a.Setup_Reminder__c = c.Setup_Reminder__c;
				}
				update c;
				update a;
				
				HaparaSendEmailNotification.SendContactEmailRecipientIdwithBCCNSenderSetWhatId(c.id,selectedEmailTemplate, 
					a.id,null, 'Hapara Team',HAPARA_CONST.SETTING_SCHEDULE.Web_To_Lead_Nofications_Email__c, null);
					
				
			}
		}catch(Exception e){
			string error =debug +'\n\n ERROR:'+  e.getMessage() 
			+ '\n\n//-- Stack Trace --//\n' + e.getStackTraceString();
			HaparaSendEmailNotification.SendAdminErrorEmail('sendInvite', error, Apexpages.currentPage().getUrl());
			System.debug(error);    
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()));		
			return null;
		}
		return fromPage;
	}
	
	public PageReference cancel() {
        return fromPage;
    }
	
}