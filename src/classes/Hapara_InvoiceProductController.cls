public class Hapara_InvoiceProductController {
	private ApexPages.StandardController singlecontroller;
	private Account_Products__c product ;
	private final Hapara_Invoice__c inv; 
	private Id invId;
	private string invName;
	private Id accId;
	private string accName;
	private Account acc;
	private Quote quoterec;
	private string currencyIsoCode ='USD';
	private string retUrl;
	private PricebookEntry price;
	private Id tierId;
	Product2 pro;
	private string currentStep = '1';
	PageReference fromPage ;
	string sRecordType;
	
 	public Hapara_InvoiceProductController(ApexPages.StandardController stdController){ 	
 		invId =  ApexPages.currentPage().getParameters().get('Id');	
 		system.debug('***Hapara_InvoiceProductController invId=' + invId);
		singlecontroller =stdController; 	
		Schema.SObjectType recordType =invId.getSObjectType();
		sRecordType = recordType.getDescribe().getName();
		system.debug('***Hapara_InvoiceProductController sRecordType=' + sRecordType);
		fromPage = singlecontroller.cancel();
		getAccountProduct();
		
		if(sRecordType == 'Hapara_Invoice__c'){
			inv =[Select h.Name, h.Id, h.Account__c,Invoice_Date__c,Xero_Invoice_No__c,h.Reseller_Account__c ,
				h.Account__r.Type
				From Hapara_Invoice__c h where h.Id =: invId ];
			invName = inv.Name;
			if(inv.Invoice_Date__c != null){
				product.Account__c = inv.Account__c;
				product.Invoice_Date__c = inv.Invoice_Date__c;
				product.Invoice_No__c = inv.Xero_Invoice_No__c;
				string acctype= inv.Account__r.Type;
				if(acctype.contains('Reseller') || acctype.contains('Referral') )
					product.Reseller_Account__c = inv.Account__c;
			}
			accId = inv.Account__c;
		
			if(ApexPages.currentPage().getParameters().containsKey('CF00N900000052Kfm_lkid')){
				 accId= ApexPages.currentPage().getParameters().get('CF00N900000052Kfm_lkid');
			}
			
		}else if(sRecordType == 'Quote'){
			quoterec = [select Opportunity.AccountId,Opportunity.Resellers_Account__c,Pricebook2Id ,
						Opportunity.Reseller_Tier__c
						from Quote where id=: invId];
			Opportunity opprec = [select AccountId,o.Resellers_Account__c,o.RecordType.DeveloperName, o.RecordTypeId  ,
								Reseller_Tier__c
								from Opportunity o where id=: quoterec.OpportunityId];
			
			if(opprec.RecordType.DeveloperName =='Reseller_Opportunity'){
				product.Account__c  = opprec.Resellers_Account__c;
				accId =opprec.Resellers_Account__c;
			}else{
				accId =quoterec.Opportunity.AccountId;
				product.Account__c = quoterec.Opportunity.AccountId;
			}
			tierId = quoterec.Opportunity.Reseller_Tier__c;
			
		}else if(sRecordType == 'Opportunity'){
			Opportunity opprec = [select AccountId,o.Resellers_Account__c,o.RecordType.DeveloperName, o.RecordTypeId  ,Reseller_Tier__c
								from Opportunity o where id=: invId];
			
			if(opprec.RecordType.DeveloperName =='Reseller_Opportunity'){
				product.Account__c  = opprec.Resellers_Account__c;
				accId =  opprec.Resellers_Account__c;
			}else{
				product.Account__c = opprec.accountId;
				accId = opprec.accountId;
			}
			tierId = opprec.Reseller_Tier__c;
		}
		
		if(accId != null){
			acc = [select Id,Name, CurrencyIsoCode from Account  where Id=:accId];
			accName = acc.Name;			
 			currencyIsoCode = acc.CurrencyIsoCode;
		}
		if (ApexPages.currentPage().getParameters().containsKey('retUrl')) {
            retUrl = ApexPages.currentPage().getParameters().get('retUrl');
        }else{
        	
        	retUrl ='\\' + invId;
		}
        	
		system.debug('***Hapara_InvoiceProductController accid=' + accId +' accName='+accName 
			+' invId='+invId+' invName='+invName + ' returl='+retUrl);	
 	}
 	
 	public Account_Products__c getAccountProduct(){
 		if(product == null){
 			product = new Account_Products__c();
 			product.Subscription_Start_Date__c = Date.Today();
	 		product.Quantity__c = 1;
	 		product.Subscription_Period__c = 1;
 		}
 		
 		return product;
 	}
 	
 	public List<SelectOption> getActiveProducts() {     
   		List<SelectOption> options = new List<SelectOption>();
   		List<Product2> prods;
   		if(tierId == null)
			prods =  [Select p.Name, p.IsActive, p.Id,Subscription_Type__c 
				From Product2 p 
				where p.IsActive = true and p.Reseller_Tier__c =null 
				order by p.Sort_Order_No__c ASC NULLS LAST,p.Name ];
		else
			prods = [Select p.Name, p.IsActive, p.Id,Subscription_Type__c 
				From Product2 p 
				where  p.Reseller_Tier__c =:tierId 
				order by p.Sort_Order_No__c ASC NULLS LAST,p.Name 
			
			];
			
		options.add(new SelectOption('0001', '--Select--'));
		
		for(Product2 c : prods ){
		 	options.add(new  SelectOption(c.id, c.Name + ' ('+ c.Subscription_Type__c+' Subscription)'));
		 	
		} 
		return options;
	}
 	
 	public PageReference Process() {  
 		system.debug('***Process accid=' + accId +' accName='+accName 
			+' invId='+invId+' invName='+invName+ ' returl='+retUrl); 	
		
		 
 		pro = [Select p.Subscription_Type__c,Subscription_Period__c, p.Name, p.Description,p.Not_Sync_to_Xero__c
 						From Product2 p where p.Id =: product.Product__c
 						];
 		system.debug('***Process pro.Id =' + pro.Id  +' currencyIsoCode='+currencyIsoCode); 				
 		Date endDate;
 		
 		endDate = Hapara_UtilityCommonRecordAccess.CalculateProductEndSubscriptionDateWithPeriod(
 							pro,product.Subscription_Start_Date__c,product.Subscription_Period__c.intValue() );
 		
 		product.Subscription_End_Date__c = endDate;
 		product.Not_Sync_to_Xero__c = pro.Not_Sync_to_Xero__c; 
 		price = [Select Id, Name, Pricebook2Id, Product2Id, CurrencyIsoCode, UnitPrice, IsActive,
 						UseStandardPrice, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, 
 						ProductCode, IsDeleted,
 						Product2.Calculate_Unit_Price_Based_On_Period__c
 						From PricebookEntry where IsActive = true 
 						and CurrencyIsoCode =:currencyIsoCode and Product2Id =:pro.Id limit 1 ] ;
 		if(price != null){
 			//product.Unit_Price__c = price.UnitPrice;
 			product.Unit_Price__c =Hapara_UtilityCommonRecordAccess.CalculateProductNewUnitPrice(
 										price.Product2.Calculate_Unit_Price_Based_On_Period__c,
										price.UnitPrice,integer.valueOf(product.Subscription_Period__c));
 			product.List_Price__c = price.UnitPrice;
 		}	
 		currentStep='2';
        return ApexPages.currentPage(); 
    }
    
    public PageReference CreateAccountProduct(){
    	PageReference redirect;
    	system.debug('***CreateAccountProduct - recordType=' +sRecordType + ' prod = ' + product.Product__c );
    	
    	if(product.Account__c != null)
    		acc = [select name from Account where id=: product.Account__c];
    	
    	product.Description__c=  Hapara_UtilityCommonRecordAccess.BuildInvoiceLineDescription(pro.Description,acc.Name , 
	    		product.Subscription_Start_Date__c, product.Subscription_End_Date__c);
    	if(sRecordType == 'Hapara_Invoice__c'){
	    	//Account acc = [select Name from Account where id =: product.Account__c];	    	
	 		product.Hapara_Invoice__c = invId;
	 		product.CurrencyIsoCode = currencyIsoCode;
	 		
	 		insert product;
	 	    redirect = new PageReference('/'+ product.Id + '/e');
	 		redirect.getParameters().put('retURL', '/'+invId);
	 		redirect.getParameters().put('saveURL','/'+invId);
	 		redirect.getParameters().put('nooverride','1');
	 		system.debug('***CreateAccountProduct Hapara_Invoice__c=' + redirect.getURL());
	       
       }else if(sRecordType == 'Quote'){
       		if(quoterec.Pricebook2Id == null){
       			quoterec.Pricebook2Id = price.Pricebook2Id;
       			update quoterec;
       		}
       			
       		QuoteLineItem quoteline = new QuoteLineItem();
       		quoteline.Account__c= product.Account__c;
       		quoteline.QuoteId = invId;
       		quoteline.ServiceDate = product.Subscription_Start_Date__c;
       		quoteline.Subscription_End_Date__c = product.Subscription_End_Date__c;
       		quoteline.Discount = product.Discount__c;
       		quoteline.Description2__c  = product.Description__c;
       		quoteline.Quantity = product.Quantity__c; 
       		quoteline.UnitPrice = product.Unit_Price__c;
       		quoteline.PricebookEntryId = price.Id;
       		
       		
       		insert quoteline;
       		redirect = new PageReference('/'+ quoteline.Id + '/e');
	 		redirect.getParameters().put('retURL', '/'+invId);
	 		redirect.getParameters().put('saveURL','/'+invId);
	 		redirect.getParameters().put('nooverride','1');
	 		system.debug('***CreateAccountProduct Quote=' + redirect.getURL());
       	
       }else if(sRecordType == 'Opportunity'){
       		OpportunityLineItem oppproduct = new OpportunityLineItem();
       		oppproduct.Account__c = product.Account__c;
       		oppproduct.OpportunityId = invId;
       		oppproduct.ServiceDate = product.Subscription_Start_Date__c;
       		oppproduct.Subscription_End_Date__c = product.Subscription_End_Date__c;
       		oppproduct.discount = product.Discount__c;
       		oppproduct.Description2__c  = product.Description__c;
       		oppproduct.PricebookEntryId = price.Id;
       		oppproduct.Quantity = product.Quantity__c;
       		oppproduct.UnitPrice = product.Unit_Price__c;
       		
       		insert oppproduct;
       		redirect = new PageReference('/'+ oppproduct.Id + '/e');
	 		redirect.getParameters().put('retURL', '/'+invId);
	 		redirect.getParameters().put('saveURL','/'+invId);
	 		redirect.getParameters().put('nooverride','1');
	 		system.debug('***CreateAccountProduct Opportunity=' + redirect.getURL());
       	
       }
       return redirect;
    }
    
    public string getStep(){
    	return currentStep;
    }
    
    public PageReference cancel() {
        return fromPage;
    }
    
}