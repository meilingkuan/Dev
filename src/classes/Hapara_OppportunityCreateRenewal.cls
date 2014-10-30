public class Hapara_OppportunityCreateRenewal {
	public void createRenewalOpportunityById(Id accId)
	{
		list<Account> accounts = [
			Select a.Type, a.No_Students_Sign_Up__c, a.NewNextInvoiceDate__c, a.Id, a.CurrencyIsoCode,Invoice_Contact__c,name,
			OwnerId,UpdatedRenewalOpportunity__c,Reseller_Tier__c,Reseller_Customer_Tier__c,
			a.Referral__r.name,a.Referral__r.Reseller_Tier__c, a.Referral__r.Invoice_Contact__c, a.Referral__c, a.Referral_Contact__c,
			a.Referral__r.CurrencyIsoCode,a.Referral__r.OwnerId,
			(Select Id, AccountId, Name, Description, StageName, CloseDate, Type, IsClosed, CampaignId, Pricebook2Id, Opportunity_Name_Template__c 
			From Opportunities 
			where Opportunity_Name_Template__c like 'Renewal' and Opportunity_Name_Template__c != 'Renewal SIS Integration'  
			 and IsClosed = false
			limit 1
			), 
			(Select AccountId, Name, Description, StageName, CloseDate, Type, IsClosed, Opportunity_Name_Template__c 
			From ResellerRegisteredOpportunities__r
			where Opportunity_Name_Template__c like 'Renewal'  and IsClosed = false
			limit 1
			),
			(Select Product__c, Quantity__c, Invoice_Date__c, Subscription_Start_Date__c, Status__c ,Product_Family__c
			From Account_Product__r 
			where (Product_Family__c ='TD' or Product_Family__c = 'TD + RC') and Invoice_No__c !=null 
			and  status__c  = null and Invoice_Date__c != null
			order by Subscription_End_Date__c desc limit 1
			),
			(Select Number_Students__c, SIS_Enabled__c, RC_Enabled__c 
			From TD_Domains__r 
			where  RC_Enabled__c !=null
			order by  CreatedDate desc limit 1) 
			From Account a where (a.Type like 'Customer%') and (Not a.Type like '%Cold%')and TD_Discount__c !=100 
			and (not a.NewNextInvoiceDate__c = null) 
			//and a.LastModifiedDate <LAST_N_DAYS:7 
			and a.id=:accId
			order by a.NewNextInvoiceDate__c desc 
		];
		createRenewalOpportunity(accounts);
	}
	
	public void createRenewalOpportunityAll()
	{
		list<Account> accounts = [
			Select a.Type, a.No_Students_Sign_Up__c, a.NewNextInvoiceDate__c, a.Id, a.CurrencyIsoCode,Invoice_Contact__c,name,
			OwnerId,UpdatedRenewalOpportunity__c,Reseller_Tier__c,Reseller_Customer_Tier__c,
			a.Referral__r.name,a.Referral__r.Reseller_Tier__c, a.Referral__r.Invoice_Contact__c, a.Referral__c, a.Referral_Contact__c,
			a.Referral__r.CurrencyIsoCode,a.Referral__r.OwnerId,
			(Select Id, AccountId, Name, Description, StageName, CloseDate, Type, IsClosed, CampaignId, Pricebook2Id, Opportunity_Name_Template__c 
			From Opportunities 
			where Opportunity_Name_Template__c like 'Renewal' and Opportunity_Name_Template__c != 'Renewal SIS Integration'  
			and IsClosed = false
			limit 1
			), 
			(Select AccountId, Name, Description, StageName, CloseDate, Type, IsClosed, Opportunity_Name_Template__c 
			From ResellerRegisteredOpportunities__r
			where Opportunity_Name_Template__c like 'Renewal'  and IsClosed = false
			limit 1
			),
			(Select Product__c, Quantity__c, Invoice_Date__c, Subscription_Start_Date__c, Status__c ,Product_Family__c
			From Account_Product__r 
			where (Product_Family__c ='TD' or Product_Family__c = 'TD + RC') and Invoice_No__c !=null 
			and  status__c  = null and Invoice_Date__c != null
			order by Subscription_End_Date__c desc limit 1
			),
			(Select Number_Students__c, SIS_Enabled__c, RC_Enabled__c 
			From TD_Domains__r 
			where  RC_Enabled__c !=null
			order by  CreatedDate desc limit 1) 
			From Account a where (a.Type like 'Customer%') and (Not a.Type like '%Cold%')  
			and (not a.NewNextInvoiceDate__c = null) and TD_Discount__c !=100
			and (a.UpdatedRenewalOpportunity__c <LAST_N_DAYS: 7 or a.UpdatedRenewalOpportunity__c=null )
			and a.NewNextInvoiceDate__c >NEXT_N_MONTHS:3	
			order by a.NewNextInvoiceDate__c desc limit 100
		];
		createRenewalOpportunity(accounts);
	}
	public void createRenewalOpportunityTest30()
	{
		list<Account> accounts = [
			Select a.Type, a.No_Students_Sign_Up__c, a.NewNextInvoiceDate__c, a.Id, a.CurrencyIsoCode,Invoice_Contact__c,name,
			OwnerId,UpdatedRenewalOpportunity__c,Reseller_Tier__c,Reseller_Customer_Tier__c,
			a.Referral__r.name,a.Referral__r.Reseller_Tier__c, a.Referral__r.Invoice_Contact__c, a.Referral__c, a.Referral_Contact__c,
			a.Referral__r.CurrencyIsoCode,a.Referral__r.OwnerId,
			(Select Id, AccountId, Name, Description, StageName, CloseDate, Type, IsClosed, CampaignId, Pricebook2Id, Opportunity_Name_Template__c 
			From Opportunities 
			where Opportunity_Name_Template__c like 'Renewal'and Opportunity_Name_Template__c != 'Renewal SIS Integration'  
		    and IsClosed = false
			limit 1
			), 
			(Select AccountId, Name, Description, StageName, CloseDate, Type, IsClosed, Opportunity_Name_Template__c 
			From ResellerRegisteredOpportunities__r
			where Opportunity_Name_Template__c like 'Renewal'  and IsClosed = false
			limit 1
			),
			(Select Product__c, Quantity__c, Invoice_Date__c, Subscription_Start_Date__c, Status__c ,Product_Family__c
			From Account_Product__r 
			where (Product_Family__c ='TD' or Product_Family__c = 'TD + RC') and Invoice_No__c !=null 
			and  status__c  = null and Invoice_Date__c != null
			order by Subscription_End_Date__c desc limit 1
			),
			(Select Number_Students__c, SIS_Enabled__c, RC_Enabled__c 
			From TD_Domains__r 
			where  RC_Enabled__c !=null
			order by  CreatedDate desc limit 1) 
			From Account a where (a.Type like 'Customer%') and (Not a.Type like '%Cold%') and TD_Discount__c !=100
			and (not a.NewNextInvoiceDate__c = null) 
			//and a.LastModifiedDate <LAST_N_DAYS:7 
			//and a.NewNextInvoiceDate__c <=NEXT_N_DAYS:30	
			order by a.NewNextInvoiceDate__c desc  limit 30 
		];
		createRenewalOpportunity(accounts);
	}
	
	public void createRenewalOpportunity(list<Account> accounts){
		
		system.debug('***createRenewalOpportunity: accounts to renewal = ' + accounts.size());
		list<Id> renewalOpps = new list<Id>();
		list<Opportunity> newOpps = new list<Opportunity>();
		list<Opportunity> updateOpps =  new list<Opportunity>();
        map<id,Account> accountsMap = new map<id,Account>();
        string accounName;
		try{
			for(Account a : accounts){
					Opportunity newOpp = null;
					accounName = a.name +'-id='+a.Id; 
					if(!a.Type.contains('Reseller')  ){
						if( a.Opportunities.isEmpty()){
							newOpp = createRenewalDirectOpportunity(a);
							newOpps.add(newOpp);
						}else{
                            renewalOpps.add(a.Opportunities[0].Id);
                            if(a.Opportunities[0].stageName !=HAPARA_CONST.OPPORTUNITY_STAGE_INVOICING){
                            	a.Opportunities[0].stageName = HAPARA_CONST.OPPORTUNITY_STAGE_INVOICING;
                            	updateOpps.add(a.Opportunities[0]);
                            }
						}
					}
					
					if(a.Type.contains('Reseller') ){
						if(a.ResellerRegisteredOpportunities__r.isEmpty()){
							newOpp = createRenewalResellerOpportunity(a);
							newOpps.add(newOpp);
						}else{
                            renewalOpps.add(a.ResellerRegisteredOpportunities__r[0].Id);
                             if(a.ResellerRegisteredOpportunities__r[0].stageName !=HAPARA_CONST.OPPORTUNITY_STAGE_INVOICING){
                            	a.ResellerRegisteredOpportunities__r[0].stageName = HAPARA_CONST.OPPORTUNITY_STAGE_INVOICING;
                            	updateOpps.add(a.ResellerRegisteredOpportunities__r[0]);
                            }
						}
					}
				system.debug('***createRenewalOpportunity: a.Id='+a.Id);
				accountsMap.put(a.Id,a);
				a.UpdatedRenewalOpportunity__c = Date.today();
			}
			system.debug('***createRenewalOpportunity: inserting new opportunity = ' + newOpps.size());
            if(newOpps.size()>0){
				insert newOpps; 
                for(Opportunity o : newOpps){
                	renewalOpps.add(o.Id);
                }
            }
            system.debug('***createRenewalOpportunity: update opportunity = ' + updateOpps.size());
			if(updateOpps.size()>0)
				update updateOpps;
           //create opportunity line
			list<Opportunity> accountOpps = [Select Id, AccountId, Name, Description, StageName, CloseDate, Type, IsClosed, CampaignId, 
                                         Pricebook2Id, Opportunity_Name_Template__c,RecordTypeId,Resellers_Account__c,Reseller_Tier__c,
                                         (Select Id From Quotes limit 1), 
                                         (Select Id, PricebookEntryId, Quantity ,o.Product_Family__c
                                         From OpportunityLineItems o
                                         where o.Product_Family__c = 'TD'  OR o.Product_Family__c = 'TD + RC' limit 1) 
                                         From Opportunity  
                                         where Opportunity_Name_Template__c like 'Renewal'  and IsClosed = false
                                         and Id =: renewalOpps];
            list<OpportunityLineItem> updatelines = new list<OpportunityLineItem>();     
            list<OpportunityLineItem> insertlines = new list<OpportunityLineItem>();   
            list<OpportunityLineItem> deletelines = new list<OpportunityLineItem>();     
            system.debug('***createRenewalOpportunity: create or update opportunity lines for = ' + accountOpps.size());               
            for(Opportunity o : accountOpps){
            	//if there is an existing quote then we assume that negotiation is under going and therefore we don't update.
            	if(o.Quotes.isEmpty()){
                	Account acc = null;
                	OpportunityLineItem line = null;
	                if(o.RecordTypeId == HAPARA_CONST.SETTING_OPPORTUNITY_CONFIG.Record_Type_Reseller__c)
	                    acc = accountsMap.get(o.Resellers_Account__c);
	                else
	                    acc = accountsMap.get(o.AccountId);
	                accounName = acc.name +'-id='+acc.Id; 
	                system.debug('***createRenewalOpportunity:  purchased quantity='+ acc.Account_Product__r[0].Quantity__c 
	                			+ ' td students=' + string.valueOf(acc.No_Students_Sign_Up__c));  
               		double quantity = acc.No_Students_Sign_Up__c >0? acc.No_Students_Sign_Up__c :acc.Account_Product__r[0].Quantity__c;
               		if(quantity >0){
		                if(o.OpportunityLineItems.isEmpty()){
		                	line = createOpportunityLineItem(acc,o,quantity);
		                	insertlines.add(line);
		                }else{
		                	//only update opportunities that one month in the future
		                	if(o.CloseDate > date.today().addDays(30)){
			                	line = o.OpportunityLineItems[0];		 
			                    boolean isRCEnabled = acc.TD_Domains__r.isEmpty() ?false: boolean.valueOf( acc.TD_Domains__r[0].RC_Enabled__c);
			                    if(line.Product_Family__c =='TD' && isRCEnabled){
			                    	deletelines.add(line);
			                    	line = createOpportunityLineItem(acc,o,quantity);
			                    	insertlines.add(line);
			                    }else if(line.Product_Family__c =='TD + RC' && !isRCEnabled) {
			                    	deletelines.add(line);
			                    	line = createOpportunityLineItem(acc,o,quantity);
			                    	insertlines.add(line);
			                    }else{
			                		line.Quantity = quantity;
			                		updatelines.add(line);
			                    }
		                	}
		                }
               		}
                
            	}
            }	
            system.debug('***createRenewalOpportunity: insert opp lines = ' + insertlines.size());               
            if(insertlines.size()>0)
            	insert insertlines;
            system.debug('***createRenewalOpportunity: update opp lines = ' + updatelines.size()); 
            if(updatelines.size()>0)
            	update updatelines;		
            system.debug('***createRenewalOpportunity: delete opp lines = ' + deletelines.size());          
            if(deletelines.size()>0)
            	delete deletelines;
            system.debug('***createRenewalOpportunity: update account renewal date ');       	
            if(accounts.size()>0)
            	update accounts;
		}catch(Exception e){
			string error ='***createRenewalOpportunity: accountName: ' +accounName +' - '+  e.getMessage() 
						+ '\n\n//-- Stack Trace --//\n' + e.getStackTraceString();
			HaparaSendEmailNotification.SendAdminErrorEmail('Hapara_OppportunityCreateRenewal createRenewalOpportunity process', error, '');
			System.debug(error);
			//throw new HaparaException(error);
        }
		
	}
	
	private PricebookEntry getOpportunityLinePrice(Account acc, Opportunity opp){
		PricebookEntry price  = null;
		boolean isRCEnabled = acc.TD_Domains__r.isEmpty() ?false:acc.TD_Domains__r[0].RC_Enabled__c==null?false: boolean.valueOf( acc.TD_Domains__r[0].RC_Enabled__c);
		string productCode = 'TD';
		
		//system.debug('***getOpportunityLinePrice: rc= ' + isRCEnabled + ' recordTypeId=' + opp.RecordTypeId 
	//			+ ' acc.name=' +  acc.Name );
		if(opp.RecordTypeId == HAPARA_CONST.SETTING_OPPORTUNITY_CONFIG.Record_Type_Reseller__c){
			Reseller_Tier__c tier =getResellerTier().get(opp.Reseller_Tier__c);
			if(isRCEnabled)
				productCode = productCode+'RC'; 
			
			if(tier.Combination_Tier__c)
				tier = getResellerTier().get(acc.Reseller_Customer_Tier__c); 
		//	system.debug('***getOpportunityLinePrice: tier=' +tier.name); 
			productCode =tier.Product_Code_Pre_Fix__c+ productCode +'1Y'+acc.CurrencyIsoCode+tier.Id;
			price = getProductPricing().get( productCode);
		}
		else{
			if(isRCEnabled)
				productCode = 'TD RC';
			productCode = productCode +acc.CurrencyIsoCode;
			price = getProductPricing().get(productCode);
		}
		//system.debug('***getOpportunityLinePrice: productCode='+ productCode);
		return price;
	}
	
	
	private OpportunityLineItem createOpportunityLineItem(Account acc,Opportunity opp,double quantity){
		OpportunityLineItem lineItem = new OpportunityLineItem();
		
		PricebookEntry price  = getOpportunityLinePrice(acc,opp);
		
		lineItem.OpportunityId = opp.Id; 
		lineItem.PricebookEntryId =price.Id;
		lineItem.UnitPrice = price.UnitPrice;
		lineItem.Quantity = quantity;
		lineItem.account__c = acc.Id;
		lineItem.ServiceDate = acc.NewNextInvoiceDate__c.addDays(1);
		lineItem.Subscription_End_Date__c = 
			Hapara_UtilityCommonRecordAccess.CalculateProductEndSubscriptionDate(price.Product2,lineItem.ServiceDate);
		lineItem.Description2__c =  
			Hapara_UtilityCommonRecordAccess.BuildInvoiceLineDescription(price.Product2.Description, acc.Name, 
					lineItem.ServiceDate, lineItem.Subscription_End_Date__c);
		return lineItem;
	}
	
	
	private Opportunity createRenewalDirectOpportunity(Account acc){
		system.debug('***createRenewalDirectOpportunity');
		Opportunity result = new Opportunity();
		result.RecordTypeId = HAPARA_CONST.SETTING_OPPORTUNITY_CONFIG.Record_Type_Standard__c;
		result.AccountId = acc.id;
		result.Opportunity_Name_Template__c = HAPARA_CONST.OPPORTUNITY_TEMPLATENAME_RENEWAL;
		result.Name = acc.Name + '-' + HAPARA_CONST.OPPORTUNITY_TEMPLATENAME_RENEWAL;
		result.Type =HAPARA_CONST.OPPORTUNITY_TYPE_EXISTING;
		result.StageName = HAPARA_CONST.OPPORTUNITY_STAGE_INVOICING;
		result.Primary_Contact__c= acc.Invoice_Contact__c;
		result.CloseDate = acc.NewNextInvoiceDate__c;
		result.CampaignId = HAPARA_CONST.SETTING_OPPORTUNITY_CONFIG.Campaign_Direct_Sales__c;
		result.CurrencyIsoCode = acc.CurrencyIsoCode;
		result.OwnerId = acc.OwnerId;
		return result;
	}
	
	private Opportunity createRenewalResellerOpportunity(Account acc){
		system.debug('***createRenewalResellerOpportunity');
		Opportunity result = new Opportunity();
		result.RecordTypeId = HAPARA_CONST.SETTING_OPPORTUNITY_CONFIG.Record_Type_Reseller__c;
		result.AccountId = acc.Referral__c;
		result.Opportunity_Name_Template__c = HAPARA_CONST.OPPORTUNITY_TEMPLATENAME_RENEWAL;
		result.Name =acc.Referral__r.name +'-'+ acc.Name + '-' + HAPARA_CONST.OPPORTUNITY_TEMPLATENAME_RENEWAL;
		result.Type =HAPARA_CONST.OPPORTUNITY_TYPE_EXISTING;
		result.StageName = HAPARA_CONST.OPPORTUNITY_STAGE_INVOICING;
		result.Primary_Contact__c= acc.Referral__r.Invoice_Contact__c;
		result.CloseDate = acc.NewNextInvoiceDate__c;
		result.CampaignId = HAPARA_CONST.SETTING_OPPORTUNITY_CONFIG.Campaign_Direct_Sales__c;
		result.CurrencyIsoCode = acc.Referral__r.CurrencyIsoCode;
		result.Reseller_s_Rep__c = acc.Referral_Contact__c;
		Reseller_Tier__c tier = getResellerTier().get(acc.Referral__r.Reseller_Tier__c);
		if(tier.Combination_Tier__c)
			tier =getResellerTier().get( acc.Reseller_Customer_Tier__c);
		system.debug('***createRenewalResellerOpportunity - new opp tier=' + tier.name);
		result.Reseller_Tier__c=tier.id;
		result.Resellers_Account__c = acc.id;
		result.OwnerId = acc.OwnerId;
		return result;
	}
	private map<string,PricebookEntry> productPricing;
	private map<string,PricebookEntry> getProductPricing(){
		if(productPricing == null){
			productPricing = new map<string,PricebookEntry>();
			list<PricebookEntry> entries = [Select p.Id, p.UnitPrice, p.Product2Id, p.IsActive, p.CurrencyIsoCode ,
						p.Product2.Subscription_Period__c, p.Product2.Subscription_Type__c, p.Product2.Family, p.Product2.ProductCode, 
						p.Product2.Description,p.Product2.Reseller_Tier__c
						From PricebookEntry p
						where p.IsActive = true and (p.Product2.Family = 'TD' or p.Product2.Family= 'TD + RC')
						and p.Product2.Subscription_Type__c = 'Yearly' and p.Product2.Subscription_Period__c = 1
						and p.Product2.IsActive = true and (not p.Product2.ProductCode like '%CHR%')
						];
			string productcode;
			for(PricebookEntry p : entries){
				if(p.Product2.Reseller_Tier__c!= null)
					productcode = p.Product2.ProductCode+p.CurrencyIsoCode+p.Product2.Reseller_Tier__c;
				else
					productcode = p.Product2.ProductCode+p.CurrencyIsoCode;
		//		system.debug('***getProductPricing: productcode=' +productcode );
				productPricing.put(productcode,p);
			}
		}
		
		return productPricing;
	} 
	
	private  map<Id, Reseller_Tier__c> resellerTiers;
	private map<Id, Reseller_Tier__c> getResellerTier(){
		if(resellerTiers == null){
			resellerTiers = new map<Id, Reseller_Tier__c> ();
			list<Reseller_Tier__c> tiers = [Select r.Product_Code_Pre_Fix__c, r.Name, r.Id ,r.IsActive__c, r.Combination_Tier__c, r.Commission__c
							From Reseller_Tier__c r];
			for(Reseller_Tier__c t : tiers){
				resellerTiers.put(t.id, t);
			}
		}
		return resellerTiers;
	}
	
}