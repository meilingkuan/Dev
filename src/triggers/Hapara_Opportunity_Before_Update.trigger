trigger Hapara_Opportunity_Before_Update on Opportunity (before update,before insert) {
	map<Id,Opportunity> currentOpps = new map<Id, Opportunity>();
	list<Id> oppIds = new list<Id>();
	list<Id> opportunityAccountId = new list<Id>();
	map<id, Account> searchAcc = new map<id,Account>();
	for(Opportunity opp : Trigger.new){
		oppIds.add(opp.Id);
		currentOpps.put(opp.Id, opp);	
		opportunityAccountId.add(opp.AccountId);
	}
	if(Trigger.isBefore & Trigger.isUpdate){
		//after the opportunity update check the reseller deal status and update the account PO.
		list<Opportunity> opps = [Select o.Account.CurrencyIsoCode, o.Account.Type, o.AccountId,
				o.Reseller_s_Rep__r.Email, o.Reseller_s_Rep__r.FirstName, o.Reseller_s_Rep__r.LastName, 
				o.Reseller_s_Rep__c,o.Customer_PO_Reference__c,o.Customer_PO_Received_Date__c,
				o.Sent_Renewal_Reminder__c, o.Renewal_Reminder__c,
				
				o.Reseller_Tier__r.Name, o.Reseller_Tier__c, o.Reseller_Tier__r.Commission__c,
				o.RecordType.DeveloperName,o.RecordType.Id, o.RecordTypeId, 
				o.Resellers_Account__r.Referral_Contact__c, o.Resellers_Account__r.Referral_Date__c, o.Resellers_Account__r.Type,
				o.Resellers_Account__c,
				
				o.Resellers_Lead__r.IsConverted, o.Resellers_Lead__c
				From Opportunity o where o.Id =: oppIds];
		
		LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true limit 1];
		list<Id> oppAccountIds = new list<Id> () ;
		
		System.debug('****Hapara_Opportunity_Before_Update - got all lookup values');
		List<Id> customerAccounts = new List<Id>();
		for(Opportunity oppTemp :opps) {
			try{
				Opportunity opp = currentOpps.get(oppTemp.Id); 
				system.debug('****Hapara_Opportunity_Before_Update: account currency: '+oppTemp.Account.CurrencyIsoCode );
				
				System.debug('****Hapara_Opportunity_Before_Update - record Type = '+ opp.RecordTypeId);
				//send renew notification
				if(opp.Renewal_Reminder__c == HAPARA_CONST.CAMPAIGN_REMINDER_1 && opp.Sent_Renewal_Reminder__c != HAPARA_CONST.CAMPAIGN_REMINDER_1){
					if(opp.RecordTypeId == HAPARA_CONST.SETTING_OPPORTUNITY_CONFIG.Record_Type_Reseller__c){
					 	HaparaSendEmailNotification.SendContactEmailwithBCCNSenderSetWhatId(oppTemp.Reseller_s_Rep__r,
							HAPARA_CONST.SETTING_OPPORTUNITY_CONFIG.Reseller_Renewal_Email_Template__c,
							oppTemp.Resellers_Account__c,null,  
							'Hapara Team',HAPARA_CONST.SETTING_OPPORTUNITY_CONFIG.Reseller_Purchasing_Email__c, null);
							opp.Sent_Renewal_Reminder__c = opp.Renewal_Reminder__c;
					}
				}
				if( opp.RecordTypeId == HAPARA_CONST.SETTING_OPPORTUNITY_CONFIG.Record_Type_Reseller__c  ){
					
					if(opp.Resellers_Account__c != null){
							System.debug('****Hapara_Opportunity_Before_Update - customer account Resellers_Account__c: ' + opp.Resellers_Account__c);
							//update the account to set the account owner and type
							customerAccounts.add(opp.Resellers_Account__c);
					}	
					String accId ;
					
					if(opp.StageName ==HAPARA_CONST.OPPORTUNITY_STAGE_APROVEREGISTRATION 
						&& opp.Reseller_s_Status__c!=HAPARA_CONST.OPPORTUNITY_STAGE_APROVEREGISTRATION ){
						System.debug('****Hapara_Opportunity_Before_Update - process approved deal');
						// convert lead 
						if(oppTemp.Resellers_Lead__c != null){
							if(!oppTemp.Resellers_Lead__r.IsConverted){
								Database.LeadConvert lc = new database.LeadConvert();
								lc.setLeadId(opp.Resellers_Lead__c);
								lc.setOwnerId(opp.OwnerId);
								lc.setConvertedStatus(convertStatus.MasterLabel);
								lc.setDoNotCreateOpportunity(true);
								
								Database.LeadConvertResult lcr = Database.convertLead(lc);
								System.assert(lcr.isSuccess());
								System.debug('Converted Successfully');
								
								accId = lcr.getAccountId();
								customerAccounts.add(accId);						
								System.debug('****Hapara_Opportunity_Before_Update - customer account Resellers_Lead__c: ' + accId);
								opp.Resellers_Account__c = accId;
								opp.Reseller_s_Contact__c = lcr.getContactId();
							}
							
						}		
						opp.Reseller_s_Status__c = HAPARA_CONST.OPPORTUNITY_STAGE_APROVEREGISTRATION ;
						//update opp;
						HaparaSendEmailNotification.SendContactEmail(oppTemp.Reseller_s_Rep__r, 'Contact_Reseller_Registration_Approved',
							null,opp);
						
					}else if(opp.StageName == HAPARA_CONST.OPPORTUNITY_STAGE_DECLINEDREGISTRATION 
						&& opp.Reseller_s_Status__c != HAPARA_CONST.OPPORTUNITY_STAGE_DECLINEDREGISTRATION){
						//Decline t
						opp.Reseller_s_Status__c = HAPARA_CONST.OPPORTUNITY_STAGE_DECLINEDREGISTRATION;
						//update opp;
						HaparaSendEmailNotification.SendContactEmail(oppTemp.Reseller_s_Rep__r, 'Contact_Reseller_Registration_Declined',null,opp);
						
					}
				}else{
					customerAccounts.add(opp.accountId);
				}
			    
			}catch(Exception e){
				System.debug('Error (Hapara_Opportunity_Before_Update):' + e );
				throw new HaparaException(e);
			}
		}
		
		//update the account to set the account owner and type
		list<Account> acctoUpdate = [Select a.Type, a.Referral__c, a.Referral_Date__c,a.ParentId, a.Id,Purchase_Order_No__c,Received_Date_of_PO__c
									 From Account a where a.Id =: customerAccounts];
		
		System.debug('****Hapara_Opportunity_Before_Update -No of accounts to be updated: ' + acctoUpdate.size());							 
	    for(Account acc : acctoUpdate){
	    	searchAcc.put(acc.id, acc);
	    }
	    
	    if(acctoUpdate.size()>0){
	    	Account acc;
		    //updating account with referral deatils
		    for(Opportunity oppTemp : opps) {
	
				Opportunity opp = currentOpps.get(oppTemp.Id);
				System.debug('****Hapara_Opportunity_Before_Update - Opportunity Record type before account update: ' +opp.RecordTypeId);		
				if( opp.RecordTypeId ==HAPARA_CONST.SETTING_OPPORTUNITY_CONFIG.Record_Type_Reseller__c
				 && (opp.StageName ==HAPARA_CONST.OPPORTUNITY_STAGE_APROVEREGISTRATION  
				 || opp.StageName ==HAPARA_CONST.OPPORTUNITY_STATGE_PROCESSINGPO)){
					acc = searchAcc.get(opp.Resellers_Account__c);
					if(!acc.Type.contains('Customer')){
						if(oppTemp.Reseller_Tier__r.Commission__c>10.0){
							acc.Type = HAPARA_CONST.ACCOUNT_TYPE_PROSPECTRESELLER;
				    	}else{
				    		acc.Type = HAPARA_CONST.ACCOUNT_TYPE_PROSPECTDIRECT;
						}
			    	}else
			    		acc.Type=HAPARA_CONST.ACCOUNT_TYPE_CUSTOMERRESELLER;
			    	
			    	System.debug('***Hapara_Opportunity_Before_Update - updated account type to = ' +acc.Type);
					//acc.ParentId = opp.AccountId;
					acc.Referral__c = opp.AccountId;
					acc.Referral_Contact__c = opp.Reseller_s_Rep__c;
					acc.Referral_Date__c =Date.newInstance( opp.CreatedDate.year(),  opp.CreatedDate.month(),  opp.CreatedDate.day());
					acc.Referral_Commission__c = oppTemp.Reseller_Tier__r.Commission__c;
				}else{
					acc = searchAcc.get(opp.accountid);
				}
				
				if(opp.Customer_PO_Reference__c != null){
					acc.Purchase_Order_No__c = opp.Customer_PO_Reference__c;
					acc.Received_Date_of_PO__c = opp.Customer_PO_Received_Date__c;
				}
		    }

	    	update acctoUpdate;
	    }
	}else{
		// update the opportunity's currency code after insert
		list<Account> acctoUpdate = [Select a.Type, a.Referral__c, a.Referral_Date__c,a.ParentId, a.Id,Purchase_Order_No__c,Received_Date_of_PO__c,
										a.currencyIsoCode
									 From Account a where a.Id =: opportunityAccountId];
		system.debug('***Opportunity before insert');
		for(Account acc : acctoUpdate){
	    	searchAcc.put(acc.id, acc);
	    }	
	    
	   for(Opportunity opp : Trigger.new){
	   		Account acc = searchAcc.get(opp.AccountId);
	   	    system.debug('***Opportunity before insert: account currency='+ acc.currencyIsoCode);
	   		opp.CurrencyIsoCode = acc.currencyIsoCode;
	   }
	}
}