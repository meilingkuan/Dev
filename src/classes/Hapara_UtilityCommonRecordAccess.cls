public class Hapara_UtilityCommonRecordAccess {
	public static List<SelectOption> getCampaignEvents(list<Campaign>campaignEvents){
		List<SelectOption> result =new List<SelectOption>();
		result.add(new SelectOption('None', '--Please Select One--'));
		if(campaignEvents == null){
			Date dtvalue = Date.today();
			string year =string.valueOf( dtvalue.year())+'%';
			system.debug('*** getCampaignEvents - year='+ year);
			campaignEvents = [Select c.Name, c.Id, c.CreatedDate 
					From Campaign c 
					where c.Name like: year and Type = 'Seminar / Conference' and isActive = true
					order by c.Name,c.CreatedDate 
			];
		}
		if(campaignEvents.size()>0){
			for(Campaign c : campaignEvents){
				result.add(new SelectOption(c.name,c.name));
			}
		}
		result.add(new SelectOption('Other', 'Other'));
		return result;
	}
	
	public static Date CalculateProductEndSubscriptionDate(Product2 pro, Date startDate){
		return CalculateProductEndSubscriptionDateWithPeriod(pro,startDate,1);
	}
	
	public static Date CalculateProductEndSubscriptionDateWithPeriod(Product2 pro, Date startDate,integer subPeriod){
		Date enddate = Date.today();
		
		integer properiod = pro.Subscription_Period__c == null?1: pro.Subscription_Period__c.intValue();
		integer  period = properiod * subPeriod;
		
 		string type =string.isEmpty( pro.Subscription_Type__c) ? '' : pro.Subscription_Type__c;
 		system.debug('****CalculateProductEndSubscriptionDateWithPeriod: period='+ period +' type=' + type +'; properiod='+properiod 
 			+';pro.id=' +pro.id);
 		if(pro.Subscription_Type__c == 'Yearly'){
 			endDate = startDate.addYears(period);
 			endDate = endDate.addDays(-1);
 		}
 		else if(pro.Subscription_Type__c == 'Monthly'){
 			endDate = startDate.addMonths(period);
 			endDate = endDate.addDays(-1);
 		}
 		else if(pro.Subscription_Type__c =='Biannually'){
 			endDate = startDate.addMonths(6);
 			endDate = endDate.addDays(-1);
 		}
 		else if(pro.Subscription_Type__c =='Quarterly'){
 			endDate = startDate.addMonths(3);
 			endDate = endDate.addDays(-1);
 		}
 		else 
 			endDate = startDate;
		
		return enddate;
	}
	public static decimal CalculateProductNewUnitPrice(boolean calculateUnitbasedPeriod, decimal UnitPrice ,integer subPeriod){
		system.debug('****CalculateProductNewUnitPrice: calculateUnitbasedPeriod='+ calculateUnitbasedPeriod 
			+' UnitPrice=' + UnitPrice + ' subPeriod='+subPeriod);
		decimal newUnitPrice =0.0;
		if(calculateUnitbasedPeriod){
			newUnitPrice = UnitPrice * subPeriod;
		}else
			newUnitPrice = UnitPrice;
		return newUnitPrice;
	}
	
	
	public static string BuildInvoiceLineDescription(string productDescription, string accountName, Date startDate, Date endDate){
		return productDescription + ' for ' + accountName
			+'\r\n\r\n'
			+'Subscription will start from ' 
    		+ datetime.newInstance( startDate, time.newInstance(0,0,0,0)).format('dd MMMMM yyyy')
    		+ ' to ' 
 			+ datetime.newInstance( endDate, time.newInstance(0,0,0,0)).format('dd MMMMM yyyy');
			
	}
	
	public static string stripInvalidCharacter(string value){
		 string[] special = new string[] {'~','!','@','#','$','%','^','&','*','_','+','=','<','>','?','\'','\"','|',',',';',':'};
		 
		 for(string s:special){
		 	value = value.replace(s,'');
		 	//system.debug('****stripInvalidCharacter:'+ value);
		 }
		return value;
	}
	
	public static list<pw_cc__CountryObject__c> countries;
	public static list<pw_cc__CountryObject__c> getCountriesList(){
		if(countries == null){
			countries = [SELECT Name FROM pw_cc__CountryObject__c 
					where pw_cc__Enabled__c = true order by Sort_Order_No__c DESC NULLS LAST, Name];
		}
				
		return countries;
	}
	
	public static map<string,list<Hapara_Country_State__c>> countryStates;
	public static  list<Hapara_Country_State__c> getCountryStatesList(string country){
		list<Hapara_Country_State__c> states = new list<Hapara_Country_State__c>();
		System.debug('****getCountryStatesList: countryStates='+countryStates +' country='+country );
		if(!string.isBlank(country)){
			if(countryStates == null || !countryStates.containsKey(country)){			
				if(countryStates == null){
					countryStates = new  map<string,list<Hapara_Country_State__c>>();
					
				}
				states = [SELECT Country__r.Name,Name,State_Code__c 
						FROM Hapara_Country_State__c where country__r.Name =: country 
						order by Name];
				System.debug('****getCountryStatesList:states='+states.Size()  );
				if(states.size()>0)
					countryStates.put(country,states);
			}else
				states = countryStates.get(country);
		}
		
		return states;
	}
	
	public static map<string, PricebookEntry> productTDPrices;
	public static PricebookEntry getPriceEntryforTDProduct(string productCode,string country){
		
		if(productTDPrices == null){
			productTDPrices = new map<string, PricebookEntry>();
			List<PricebookEntry> prices =[Select p.Product2.Family, p.Product2.ProductCode, p.Product2Id, p.Id, p.CurrencyIsoCode ,
									p.UnitPrice
									From PricebookEntry p where p.Product2.Family = 'TD' or p.Product2.Family = 'TD + RC'];
			for(PricebookEntry price : prices){
				productTDPrices.put(price.Product2.ProductCode+price.CurrencyIsoCode, price);
			}
		}
		
		
		return productTDPrices.get(productCode+country);
	}
	
	public static Hapara_Invoice_History__c createInvoiceHistory(Account_Products__c obj,string action){
		Hapara_Invoice_History__c history = new Hapara_Invoice_History__c();
		history.Action__c = action;
		history.Changes__c = 'Purchased Product: ' + obj.name
			+'\n Subscription Start Date: ' + obj.Subscription_Start_Date__c.format()
			+'\n Subscription End Date: '+obj.Subscription_End_Date__c.format()
			+'\n Purchased Seats: ' + obj.Quantity__c
			+'\n Unit Price: ' + obj.Unit_Price__c
			+'\n Account: ' + obj.Account_Name__c
			+'\n Product: ' + obj.Product_Name__c;
		history.Hapara_Invoice__c = obj.Hapara_Invoice__c;
			
		return history;
	}
	
	public static string setCurrencyCode(string billingCountry, boolean billingInOwnCurrency){
		system.debug('***setCurrencyCode: billingCountry ' + billingCountry + ' billingInOwnCurrency=' +billingInOwnCurrency );
		billingCountry=billingCountry.trim().toLowerCase();
		string currencyIsoCode ='USD';
		if(!string.Isblank(billingCountry) ){
			if(billingCountry != 'new zealand'  && billingInOwnCurrency){
				currencyIsoCode =HAPARA_CONST.getCountriesCurrencyMapping(billingCountry);
			}else if(billingCountry == 'new zealand'){
				currencyIsoCode =HAPARA_CONST.getCountriesCurrencyMapping(billingCountry);
			}
		}
		return currencyIsoCode;
	}
	
	public static boolean setBillingInOwnCurrency(string billingCountry, string customerType,boolean billingInOwnCurrency){
		billingCountry=billingCountry.trim().toLowerCase();
		customerType = customerType.trim().toLowerCase();
		if(billingCountry == 'new zealand')
			billingInOwnCurrency = true;
		else {
			string currencyIsoCode =HAPARA_CONST.getCountriesCurrencyMapping(billingCountry);
			if(currencyIsoCode != 'USD')
				billingInOwnCurrency= true;
		}
			
		return billingInOwnCurrency;
	}

}