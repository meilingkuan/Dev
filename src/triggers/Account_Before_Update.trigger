trigger Account_Before_Update on Account (before insert, before update) {
	if(Trigger.isBefore &&(Trigger.isUpdate || Trigger.isInsert)){
		for(Account a : Trigger.new){
			if(! String.isBlank(a.ShippingStreet) && String.isBlank(a.BillingStreet)){
				a.BillingStreet = a.ShippingStreet;
				a.BillingCity = a.ShippingCity;
				a.BillingState = a.ShippingState;
				a.BillingPostalCode = a.ShippingPostalCode;
				a.BillingCountry = a.ShippingCountry;
			}else if(!String.isBlank(a.BillingStreet) && String.isBlank(a.ShippingStreet)){
				a.ShippingStreet = a.BillingStreet;
				a.ShippingCity = a.BillingCity;
				a.ShippingState = a.BillingState;
				a.ShippingPostalCode = a.BillingPostalCode;
				a.ShippingCountry = a.BillingCountry;
			}
			a.CurrencyIsoCode = 'USD';
			
			if(!string.Isblank(a.BillingCountry) ){
				if(Trigger.isInsert)
					a.Billing_in_Own_Currency__c = Hapara_UtilityCommonRecordAccess.setBillingInOwnCurrency(a.BillingCountry,
												a.Type,a.Billing_in_Own_Currency__c);
				a.CurrencyIsoCode = Hapara_UtilityCommonRecordAccess.setCurrencyCode(a.BillingCountry, a.Billing_in_Own_Currency__c);
			}	
			
			if(string.isNotBlank( a.Website)){
				//remove invalid student domain characters
				string website = a.Website;
				system.debug('***Hapara_Account_Before_Update: before parsing ' + website);
				website = website.trim().tolowerCase();
				list<string> temp;
				if(website.contains('http://www.')){
					website = website.replace('http://www.','');
				}else if(website.contains('http://'))
					website = website.replace('http://','');
			 	if(website.contains('www.'))
			 		website = website.replace('www.','');
			 		
				if(website.contains('@')){
					system.debug('***Hapara_Account_Before_Update: @ ' + website);
					temp = website.split('@');
					website = temp[temp.size()-1];
				}
				if(website.contains('/')){
					temp = website.split('/');
					website = temp[0];
				}
				a.website = website;
				system.debug('***Hapara_Account_Before_Update: after parsing ' + website);
			}
		} 
	}
}