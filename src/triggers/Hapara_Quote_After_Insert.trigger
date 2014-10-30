trigger Hapara_Quote_After_Insert on Quote (after insert) {
	 if(Trigger.isInsert){
	 	map<Id,Quote> opps = new map<Id,Quote>();
	 
	 	for(Quote q : Trigger.new){
	 		if(!opps.containsKey(q.OpportunityId))
	 			opps.put(q.OpportunityId,q);
	 	}
	 	list<Opportunity> quoteOpps = [Select o.Account.Invoice_Contact__c, o.Account.BillingCountry, o.Account.BillingPostalCode,
	 			 o.Account.BillingState, o.Account.BillingCity, o.Account.BillingStreet, 
	 			 o.AccountId ,o.Primary_Contact__c
	 			 From Opportunity o where o.Id = :opps.keySet()];
	 	
	 	map<Id,Account> updateAccs = new map<Id,Account>();
	 	list<Opportunity> updateOpps= new list<Opportunity>();
	 	//updates account with quote Id and opportunity primary contact
	 	for(Opportunity opp: quoteOpps){
	 		if(!updateAccs.containsKey(opp.AccountId)){
	 			system.debug('*** Hapara_Quote_After_Insert: updating account');
	 			Quote q2 = opps.get(opp.Id);
	 			Account a = opp.Account;
	 			a.Invoice_Contact__c = q2.ContactId;
	 			a.BillingCountry = q2.BillingCountry;
	 			a.BillingPostalCode =q2.BillingPostalCode;
	 			a.BillingState = q2.BillingState;
	 			a.BillingStreet = q2.BillingStreet;
	 			a.BillingCity = q2.BillingCity;
	 			updateAccs.put(a.Id, a);
	 			if(opp.Primary_Contact__c == null){
	 				system.debug('*** Hapara_Quote_After_Insert: updating opportunity');
	 				opp.Primary_Contact__c = q2.ContactId;
	 				updateOpps.add(opp);
	 			}
	 		}
	 	}
	 	
	 	if(updateAccs.size()>0){
	 		list<Account> accs = updateAccs.values();
	 		update accs;
	 		
	 		system.debug('*** Hapara_Quote_After_Insert: updated accounts - invoice contact:'+ accs[0].Invoice_Contact__c);
	 	}
	 	
	 	if(updateOpps.size()>0){
	 		update updateOpps;
	 		system.debug('*** Hapara_Quote_After_Insert: updated opps: ' + updateOpps[0].Primary_Contact__c);
	 	}
	 }
}