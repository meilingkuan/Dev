trigger Hapara_Lead_After_Update on Lead (after update) {
	try{
		//User owner = [Select u.Id From User u where u.Name = 'Mei Ling Kuan'];
		LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
	    
		
		for(Lead L : Trigger.new) {
			
			if(L.Lead_Type__c=='Google App Pack Prospect' && L.Status=='Made Payment'){
			//	System.debug('***Start of the conversion Process***');
			//check if there is an existing account based on the name or domain
			//	String accName = L.Company;
			//	String accDomain = L.Website;
			//	System.debug('***Check if Account Exists Name:' + accName + '; Domain:'+accDomain ); 
			//	Account[] existingAcc = [Select a.Website, a.Name, a.Id From Account a where (a.Website =:accDomain and a.Website  != null)  or  a.Name=:accName LIMIT 1];
				//convert lead into account and set the opportunity to won
			//	Database.LeadConvert lc = new database.LeadConvert();
			//	lc.setLeadId(L.id);
				   
			//	if(existingAcc.Size()>0){
			//		System.debug('***Account Exists***');
			//		lc.setAccountId(existingAcc[0].Id);
			//	}
			//	lc.setOwnerId(owner.id);
			//	lc.setConvertedStatus(convertStatus.MasterLabel);
				
			//	Database.LeadConvertResult lcr = Database.convertLead(lc);
			//	System.assert(lcr.isSuccess());
			//	System.debug('Converted Successfully');    
				  
			//	String contactId='';
			//	String accId = lcr.getAccountId();
			//	if(L.Invoice_Addressee__c != null & L.Invoice_Email__c != null){
					//create invoice contact
				//	String invoiceContact = L.Invoice_Addressee__c;
				//	invoiceContact = invoiceContact.trim();
					
				//	String invoiceEmail =  L.Invoice_Email__c;
				//	System.debug('****Invoice Details: ' + invoiceContact +', ' + invoiceEmail); 
				//	if(invoiceContact.length()>0 && invoiceEmail.trim().length() >0)
				//	{
					//	Contact cn = new Contact();
					//	List<String> contactName = invoiceContact.split(' ');
						
					//	if(contactName.size() >1){
					//		cn.FirstName = contactName[0];
					//		cn.LastName = contactName[1];
					//	}
					//	else
					//		cn.LastName= contactName[0];
						
					//	cn.Email = L.Invoice_Email__c;
					//	cn.AccountId = accId;
						//Database.SaveResult lsr = Database.insert(cn,false);					
						//System.assert(lsr.isSuccess());
						//contactId = lsr.getId();
					//	Insert cn;
					//	contactId = cn.Id;
					//	System.debug('****Created Invoice Contact: ' + contactId);
						//System.assertEquals(L.Invoice_Email__c,cn.Email);    
				//		
			//		}
			//	}
					
				//update the account type 
				  				
			//	Account acc =[Select a.Invoice_Contact__c, a.Type, a.Invoice_Period__c, a.Invoice_Amt_Per_Student__c, a.Id From Account a where a.Id = :accId];
			//	System.debug('***Account Id: ' + acc.Id);  
			//	acc.Type='Customer of Google App Pack';
			//	acc.Invoice_Period__c='Yearly';
			//	acc.Invoice_Amt_Per_Student__c=5.10;
				
				//only set the billing contact and flag if there is invoice contact
			//	if(contactId.length()>0){
			//		acc.Invoice_Contact__c = contactId;
			//		System.debug('****Updated Invoice Contact to account: ' + contactId);    
			//	}
				//Database.SaveResult lsr2 = Database.update(acc,false);					
				//System.assert(lsr2.isSuccess());
			//	update acc;
			//	System.debug('***Updated Account: ' + acc.Id);  
			//	System.assertEquals('Customer of Google App Pack',acc.Type);
				
				//update the opportunity to won
			//	String opportunityId = lcr.getOpportunityId();
			//	Opportunity opp = [Select o.StageName, o.Id From Opportunity o where o.Id = :opportunityId];
			//	opp.StageName = 'Closed Won';
			//	opp.Amount = l.Invoice_Amount__c;
			//	opp.SyncedQuoteId = null;
			//	update opp;
			//	System.debug('***Updated Opportunity to Won');  
				
				//sent notification of conversion
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				String[] toAddresses;
										
			//	System.debug('Email sent to ' + HAPARA_CONST.SETTING_SCHEDULE.Web_To_Lead_Nofications_Email__c);
				//System.debug('Lead id ' + l.id);		
				mail.setSenderDisplayName('Salesforce Administrator');
				//toAddresses = new String[] {HAPARA_CONST.SETTING_SCHEDULE.Web_To_Lead_Nofications_Email__c};
				toAddresses = new String[] {'customerservice@hapara.com'};
				mail.setToAddresses(toAddresses);
   
			    // set the subject on the email
			 	mail.setSubject('Teacher Dashboard Setup Required for Google App Pack School: ' +L.FirstName + ' ' + L.LastName +' from ' + L.Company);
			      
				// set the body of the email
				mail.setHTMLBody('<p>*** TEACHER DASHBOARD SETUP REQUIRED *** </p>' 
				   		+ '<p>The following School require setup and Invoicing: </p>'
				   		+ '<p>School: ' + L.Company +'</p>'
				   		+ '<p>Contact Name: ' + L.FirstName + ' ' + L.LastName +'</p>'
				   		+ '<p>Contact Email: ' +L.Email+'</p>'
				   		+ '<p>No of Students: ' + L.No_of_Students__c +'</p>'
				   		+ '<p>Click on the link to access the Account directly: ' + URL.getSalesforceBaseUrl().toExternalForm()  +'/'+ L.Id+'</p>'
				);
			  				   
				Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
				
				//generate invoice
				
				
			}
			
		}
	} catch(Exception e) {
        system.debug ('Hapara_Lead_After_Update Error: ' + e.getMessage() );
    } 
}