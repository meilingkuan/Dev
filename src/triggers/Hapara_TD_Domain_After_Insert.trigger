trigger Hapara_TD_Domain_After_Insert on TD_Domain__c (after insert) {
	list<string> contactEmails = new list<string>();
	map<string,TD_History_Contacts__c> tddomaincontacts = new map<string,TD_History_Contacts__c> ();
	for (TD_Domain__c auditInfo : trigger.new) {
		string emails = auditInfo.Primary_Contact__c;
		if(!string.isBlank( auditInfo.Primary_Contact__c)){
			list<string> conEmails =emails.Contains(';') ? emails.split(';'):emails.split(',');
			
			TD_History_Contacts__c c;
			for(string s : conEmails){
				list<string> conemail = s.trim().split('@');		
				c = new TD_History_Contacts__c();
				c.Contact_Email__c =s;
				c.TD_Domain_History__c = auditInfo.Id;
				c.Account__c = auditInfo.Account__c;
				if(conemail.size()<2)
					c.ValidityStatus__c = HAPARA_CONST.AUDIT_INFO_CONTACTSTATUS_INVALIDEMAIL;
				else{
					contactEmails.add(s);
					c.ValidityStatus__c = HAPARA_CONST.AUDIT_INFO_CONTACTSTATUS_PENDING;
				}
				string unique =(auditInfo.Account__c != null? auditInfo.Account__c: auditInfo.id)+'-'+s;
				tddomaincontacts.put(unique,c);	
			}
		}
	}
	//check if there are existing Contact and if they are bounced
	list<Contact> contacts = [Select c.Is_TD_Admin_Contact__c, c.IsEmailBounced, c.HasOptedOutOfEmail, c.EmailBouncedReason, 
								c.EmailBouncedDate, c.Email, c.AccountId ,c.Primary_Contact__c,
								(Select CampaignId From CampaignMembers 
									WHERE CampaignId=:HAPARA_CONST.SETTING_ADMIN_CONFIG.TD_Admin_Campaign_Id__c 
									OR CampaignId=:HAPARA_CONST.SETTING_ADMIN_CONFIG.TD_Admin_Northern_Campaign__c
									OR CampaignId=:HAPARA_CONST.SETTING_ADMIN_CONFIG.TD_Admin_Southern_Campaign__c) 
								From Contact c
								where email in : contactEmails];
	list<Contact> updateContacts = new list<Contact>();
	
	for(Contact cn : contacts){
		string unique =cn.AccountId+'-'+cn.email;
		if(tddomaincontacts.containsKey(unique)){
			TD_History_Contacts__c td = tddomaincontacts.get(unique);
			td.Contact__c = cn.Id;
			td.ValidityStatus__c = HAPARA_CONST.AUDIT_INFO_CONTACTSTATUS_CREATED;
			if(!cn.Is_TD_Admin_Contact__c ){
				//flag the current contact to be td admin
				cn.Is_TD_Admin_Contact__c = true;
				cn.Primary_Contact__c = true;
				updateContacts.add(cn);
			}
			if(cn.CampaignMembers.size()>0)
				td.Added_to_Campaign__c = true;
				
			if(cn.IsEmailBounced ||cn.HasOptedOutOfEmail ){
				td.ValidityStatus__c = cn.IsEmailBounced ? HAPARA_CONST.AUDIT_INFO_CONTACTSTATUS_BOUNCED 
					:HAPARA_CONST.AUDIT_INFO_CONTACTSTATUS_UNSUBSCRIBED;
			}
		}
	}
	map<string,string>uniqueContacts = new map<string,string>();
	if( tddomaincontacts.size() > 0){
		//create contact if it is not already existing in our system
		list<Contact> insertContact = new list<Contact>();
		for(TD_History_Contacts__c td :tddomaincontacts.values() ){
			string unique =td.Contact_Email__c.trim()+td.Account__c;
			if(td.ValidityStatus__c == HAPARA_CONST.AUDIT_INFO_CONTACTSTATUS_PENDING && td.Account__c !=null 
				&& !uniqueContacts.containsKey(unique)){
				uniqueContacts.put(unique,td.Contact_Email__c);
				insertContact.add(new Contact(lastName=td.Contact_Email__c, email=td.Contact_Email__c, accountId = td.Account__c,
									Is_TD_Admin_Contact__c = true));
				td.ValidityStatus__c = HAPARA_CONST.AUDIT_INFO_CONTACTSTATUS_CREATED;
			}
		}
		insert tddomaincontacts.values();
		if(insertContact.size()>0)
			insert insertContact;
		if(updateContacts.size() >0)
			update updateContacts;
	}
}