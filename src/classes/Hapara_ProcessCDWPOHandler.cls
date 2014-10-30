public class Hapara_ProcessCDWPOHandler {
	/**
	 * A class representing the content in the case description
	 */
	public class CaseMessageContent {
		public String customerName;
		public String customerStreet;
		public String customerCity;
		public String customerState;
		public String customerCountry;
		public String customerZipCode;
		public String customerPO;
		
		public String customerContact;
		public String customerContactEmail;
		public String customerContactPhone;
		public String customerDomain;
		
		public String resellerPO;
		public String resellerRepName;
		public String resellerRepEmail;
		
		public Date createdDate;
		
		public list<CDWProductLine> cdwProductLines;
	} 
	
	/**
	 * A class to represent the products
	 **/
	 public class CDWProductLine{
	 	String purchaseProductCode;
		Decimal purchaseProductQuantiy;
		Decimal purchaseProductPrice;
	 }
	
	/**
	 * A class representing the SF objects that will be created from the Case description
	 */
	public class MessageCache {

		public Case message;
		public CaseMessageContent content;
		public Account account;
		public Opportunity opportunity;
		public list<OpportunityLineItem> lineItems =new list<OpportunityLineItem>();
		public Contact resellerRep;
		public Contact customerContact;
		public Product2 product;
		public PricebookEntry price;
		public Hapara_Invoice__c invoice;
		public list<Account_Products__c> invoicelines =new list<Account_Products__c>();

		public Boolean errorState = false;
		public String errorMessage = '';
		public date processDate = date.today();
	}
	
	/**
	 * Contains the objects we need to work with and enables last minute commits instead of committing on the fly.
	 */
	private List<MessageCache> cache = new List<MessageCache>();
	
	/**
	 * Constructor that appends a list of messages to the message cache.
	 */
	public Hapara_ProcessCDWPOHandler(List<Case> messages) {

		// Call the addMessages routine
		addMessages(messages);
	}

	public Hapara_ProcessCDWPOHandler(){
	
	}
	
	public CaseMessageContent message;
	public CaseMessageContent parseCaseDescription(String content){
		message = new CaseMessageContent();
		parseCustomerNameAndAddress(content);
		parsePO(content);
		parseResellerAndContactDetails(content);
		string productlines = content.substring(content.indexOf('LINE ORDER'), content.indexOf('Total Order',content.indexOf('LINE ORDER')));
		list<string> orderlines = productlines.split('-------------------------------------------------------------------------------------------------');
		system.debug('***parseCaseDescription: product lines found=' + orderlines.size());
		for(integer i=1; i<orderlines.size();i++ )
			parseProduct(orderlines[i]);
		System.debug('****parseCaseDescription: ' + deserialCaseMessageContent());
		return message;
	}

	public void parseCustomerNameAndAddress(String content){
		
		String nameAndAddress = content.substring(content.indexOf('SHIP TO:'),content.indexOf('CUSTOMER PO#',content.indexOf('SHIP TO:')));
		System.debug('***parseCustomerNameAndAddress: ' + nameAndAddress);
		List<String> values = nameAndAddress.split('\n');
		System.debug('***parseCustomerNameAndAddress: split size: ' + values.size() );
		if(values.size() >0){
			
			message.customerName = values[1].trim();
			message.customerStreet = values[2].trim();
			System.debug('***parseCustomerNameAndAddress: split cityState ' + values[ values.size()-2]);
			List<String> cityState = values[ values.size()-2].split(',');
			
			message.customerCity = cityState[0].trim();
			message.customerState = cityState[1].substring(0,3);
			message.customerCountry = 'United States';
			message.customerZipCode = cityState[1].substring(5);
			
		}
	}
	
	public void parsePO(String content){
		String poValues = content.substring(content.indexOf('CUSTOMER PO#'), content.indexOf('SHIP VIA',content.indexOf('CUSTOMER PO#')));
		//System.debug('***parsePO: ' + poValues);
		List<String> values = poValues.split('\n');
		System.debug('***parsePO: splited ' + values.size());
		
		if(values.size() >0){
			message.customerPO = values[0].split('#')[1].trim();
			message.resellerPO =values[1].split('#')[1].trim();
		}
	}
	
	public void parseResellerAndContactDetails(String content){
		String contactDetails = content.substring(content.indexOf('CDW SLS'), content.indexOf('Total Order',content.indexOf('CDW SLS')));
		//System.debug('***parseResellerAndContactDetails: ' + contactDetails);
		List<String> values = contactDetails.split('\n');
		System.debug('***parseResellerAndContactDetails: splited ' + values.size());
		message.resellerRepName = values[0].split(':')[1].trim();
		message.customerContactPhone = values[1].split(':')[1].trim();
		message.customerContact = values[2].split(':')[1].trim();
		message.customerContactEmail = values[3].split(':')[1].trim();
		message.customerDomain = values[4].split(':')[1].trim();
		System.debug('***parseResellerAndContactDetails: resellerRepEmail length ' + values[5].split(' ').size());
		message.resellerRepEmail = values[5].trim().split(' ')[5];
	}
	
	public void parseProduct(String content){
		if(message.cdwProductLines == null)
			message.cdwProductLines = new list<CDWProductLine>();
			
		CDWProductLine line = new CDWProductLine();
		System.debug('***parseProduct: ' + content);
		String values = content.split('\n')[1];
		System.debug('***parseProduct: splited ' + values);
		
		List<String> productValue = values.trim().splitByCharacterTypeCamelCase();
		System.debug('***parseProduct: productValue ' + productValue.size());
		System.debug('***parseProduct: productValue X ' +values.trim().splitByCharacterTypeCamelCase());
		Integer counter = 0;
		string purchaseProductQuantity = productValue[2];
		
		for(Integer i =1; i < 4; i++){
			counter =2+ i;
			if(productValue[counter].containsWhitespace()){
				break;
			}
			else{
				purchaseProductQuantity = purchaseProductQuantity + productValue[counter];
				
			}
		}
		purchaseProductQuantity = purchaseProductQuantity.replace(',','');
		System.debug('***parseProduct: purchaseProductQuantity ' + purchaseProductQuantity);
		line.purchaseProductQuantiy = Decimal.valueOf(purchaseProductQuantity.trim());
		counter = counter +1;
		
		System.debug('***parseProduct: counter ' + counter);
		line.purchaseProductCode = productValue[counter];
		System.debug('***parseProduct: purchaseProductCode ' + line.purchaseProductCode);
		//' ' d / mm / yyyy
		string startDate ;
		for(Integer i =2; i < 7; i++){
			if(productValue[counter+i].containsWhitespace())
				break;
			else
				startDate = startDate +productValue[counter+i];
		}
		System.debug('***parseProduct: startDate=' + startDate);
		if(startDate.contains('/'))
			counter = counter +7;
		else 
			counter = counter + 1;
		System.debug('***parseProduct: counter ' + counter);
		String purchaseProductPrice  = '';
		for(Integer i =1; i < 4; i++){
			if(productValue[counter+i].containsWhitespace())
				break;
			else
				purchaseProductPrice =purchaseProductPrice + productValue[counter+i];
		}
		System.debug('***parseProduct: purchaseProductPrice ' + purchaseProductPrice);
		purchaseProductPrice = purchaseProductPrice.replace(',','');
		
		line.purchaseProductPrice = decimal.valueOf(purchaseProductPrice.trim());
		
		message.cdwProductLines.add(line);
	}
	
	public String deserialCaseMessageContent(){
		return JSON.serialize(message);
	}
	
	
	/**
	 * Queries the messages and marshalls them through the process.
	 */
	public static void process(List<Id> messageIds, Account selectedAccount) {

		// Query the message queue objects
		List<Case> messages = [
			Select c.Status,c.subject,c.Id, c.Description, c.ClosedDate,c.CreatedDate From Case c
			WHERE c.Id IN :messageIds
		];

		Hapara_ProcessCDWPOHandler handler = new Hapara_ProcessCDWPOHandler(messages);
		handler.initialise();
		handler.processMessage();
		handler.procesRecords(selectedAccount);
		handler.finalise();
	}
	
	public void procesRecords( Account selectedAccount){
		list<string> domains = new list<string>();
		list<string> accountNames = new list<string>();
		list<string> customerEmails = new list<string>();
		list<string> resellerPOs =  new list<string>();
		CaseMessageContent content;
		for(MessageCache cacheEntry1: cache){
			content = cacheEntry1.content;
			domains.add(content.customerDomain);
			accountNames.add(content.customerName);
			customerEmails.add(content.customerContactEmail);
			resellerPOs.add(content.resellerPO+ '-' +cacheEntry1.message.subject);
		}
		
		list<Account> accounts =  [Select  a.Id ,a.Website,a.Website_1__c, a.Name,a.TD_Setup_Date__c,
					a.Type,a.OwnerId,
					(Select c.Id, c.FirstName, c.Email From Contacts c
					where c.Email in : customerEmails limit 1)			
					From Account a 
					where a.Website in : domains
					or a.Name in : accountNames or a.Website_1__c in :domains];
		
		map<string,Account> accountDomains = new map<string,Account>();
		map<string,Account> accountNameslist = new map<string,Account>();
		map<string,Account> accountWebsite = new map<string,Account>();
		list<Id> accountIds = new list<Id>();
		string domain ='';
		for(Account acc: accounts){
			if(acc.Website != null)
				if(!accountDomains.containsKey(acc.Website.toUpperCase()))
					accountDomains.put(acc.Website.toUpperCase(),acc);
			if(acc.Website_1__c != null)
				if(!accountWebsite.containsKey(acc.Website_1__c.toUpperCase()))
					accountWebsite.put(acc.Website_1__c.toUpperCase(), acc);
			
			if(!accountNameslist.containsKey(acc.name.toUpperCase()))
				accountNameslist.put(acc.name.toUpperCase(), acc);
			accountIds.add(acc.Id)	; 
		}
		
		map<Id, Opportunity> oppsList = getExistingOpportunity(accountIds);

		map<string,Hapara_Invoice__c> invList = getExistingInvoices(resellerPOs);
		
		for (MessageCache cacheEntry : cache) {
			if(!cacheEntry.errorState){
				Savepoint sp = Database.setSavepoint();
				CaseMessageContent msg = cacheEntry.content;
				try{
					CreateRecords( cacheEntry,accountDomains,accountWebsite,accountNameslist,  invList,oppsList ,selectedAccount);
				}catch(Exception e){
					Database.rollback(sp);
					cacheEntry.errorState = true;
					cacheEntry.errorMessage = 'procesRecords Error:' +  e.getMessage() 
					+ '\n\n//-- Stack Trace --//\n' + e.getStackTraceString();
					HaparaSendEmailNotification.SendAdminErrorEmail('CDW Order Processing', cacheEntry.errorMessage, '');
					system.debug(cacheEntry.errorMessage);
				}
			}
		}
	}
	
	public map<Id, Opportunity> getExistingOpportunity(list<Id> accountIds) {
		list<Opportunity> opps = [Select o.StageName, o.Id, (Select Id From OpportunityLineItems),
						o.Resellers_Account__c ,o.Hapara_Invoice__c
						From Opportunity o
						where o.AccountId=: getCDWAccount().Id 
						and o.Resellers_Account__c in : accountIds  and o.IsClosed = false 
						and o.StageName !=: HAPARA_CONST.OPPORTUNITY_STATGE_PROCESSINGPO
						];
		map<Id, Opportunity> oppsList = new map<Id,Opportunity>();
		for(Opportunity opp : opps){
			if(!oppsList.containsKey(opp.Resellers_Account__c))
				oppsList.put(opp.Resellers_Account__c,opp);
		}
		return oppsList;
	}
	
	public map<string,Hapara_Invoice__c> getExistingInvoices(list<string> resellerPOs){
		List<Hapara_Invoice__c> invs = [
								Select h.Status__c, h.Reseller_PO__c, h.Reseller_PO_Received_Date__c, 
								h.Reseller_Account__c,h.Name, h.Id, h.Error_Message__c, h.Customer_PO__c, 
								h.Customer_PO_Received_Date__c, h.CurrencyIsoCode, h.CreatedDate, h.Account__c ,
								(Select Id From Purchased_Products__r)
								From Hapara_Invoice__c h 
								where h.Reseller_Account__c=:getCDWAccount().Id 
								and h.Reseller_PO__c in:resellerPOs];
		map<string,Hapara_Invoice__c> invList = new map<string,Hapara_Invoice__c>();
		for(Hapara_Invoice__c inv :invs){
			invList.put(inv.Reseller_PO__c.toUpperCase(), inv);
		}
		return invList;
	}
	
	public void CreateRecords(MessageCache cacheEntry, map<string,Account> accountDomains,
		map<string,Account> accountWebsite,map<string,Account> accountNameslist, map<string,Hapara_Invoice__c> invList,
		map<Id, Opportunity> oppsList , Account specificAccount){
		CaseMessageContent msg = cacheEntry.content;
		System.debug('****CreateRecords:case=' + cacheEntry.message.Id + ' subject: ' +cacheEntry.message.subject);
		processCustomerAccount( cacheEntry,accountDomains,accountWebsite,accountNameslist, specificAccount);
		processCustomerContact(cacheEntry,cacheEntry.account);
		processInvoice( cacheEntry,invList);
		list<CDWProductLine> lines = msg.cdwProductLines;
		for(CDWProductLine line:lines){
			processInvoiceProduct(cacheEntry,line);
		}
		if(cacheEntry.invoicelines.size()>0)
			insert cacheEntry.invoicelines;
		
		processOpportunity(cacheEntry,oppsList);
		for(CDWProductLine line: lines){
			processOpportunityProduct(cacheEntry,line);
		}
		if(cacheEntry.lineItems.size()>0)	
			insert cacheEntry.lineItems;
		
		//create setup task
		list<string> cc = new list<string>();
		cc.add(msg.resellerRepEmail);
		cc.add(getCDWShipToinvoices().email);
		if(HaparaResellerUtilityCommon.ValidateResellerMinimumOrder(cacheEntry.invoicelines, 
			cacheEntry.resellerRep, getCDWAccount(), cacheEntry.account, cacheEntry.invoice, 
			getCDWAccount().Owner))
			HaparaResellerUtilityCommon.createTaskforSetup(cacheEntry.account,cacheEntry.customerContact,
				getCDWAccount(),cc);
	}

	private void processInvoiceProduct(MessageCache cacheEntry,CDWProductLine line){
		CaseMessageContent content = cacheEntry.content;
		Hapara_Invoice__c inv = cacheEntry.invoice;
		System.debug('****processInvoiceProduct: invoice= '+inv.Id );

		Product2 prod = getCDWProduct(cacheEntry,line);
		cacheEntry.Product = prod;
		Account_Products__c lineItem = new Account_Products__c();
		lineItem.Hapara_Invoice__c = inv.Id;
		lineItem.Account__c = cacheEntry.account.Id;
		lineItem.CurrencyIsoCode = getCDWAccount().CurrencyIsoCode;
		Date endDate = Hapara_UtilityCommonRecordAccess.CalculateProductEndSubscriptionDate(prod,cacheEntry.processDate);
		
		lineItem.Subscription_Start_Date__c = cacheEntry.processDate;
		lineItem.Subscription_End_Date__c = endDate;
		lineItem.Description__c = Hapara_UtilityCommonRecordAccess.BuildInvoiceLineDescription(prod.Description,cacheEntry.account.name, 
    		lineItem.Subscription_Start_Date__c,  lineItem.Subscription_End_Date__c);
		lineItem.Invoice_Date__c = cacheEntry.processDate;
		lineItem.Product__c = prod.Id;
		lineItem.Quantity__c = line.purchaseProductQuantiy;
		lineItem.Unit_Price__c =line.purchaseProductPrice;
		lineItem.Product_Family__c= prod.family;
		lineItem.Reseller_Account__c =getCDWAccount().Id; 
		
		cacheEntry.invoicelines.add( lineItem);
		
	}
	
	private void processInvoice(MessageCache cacheEntry,map<string,Hapara_Invoice__c> invs){
		CaseMessageContent content = cacheEntry.content;
		System.debug('****processInvoice: resellerPO= '+content.resellerPO);
								
		Boolean isNew = false;
		Hapara_Invoice__c inv;
		
		if(!invs.containsKey((content.resellerPO+ '-' +cacheEntry.message.subject).toUpperCase())){
			inv = new Hapara_Invoice__c();
			isNew = true;
			inv.Account__c = getCDWAccount().Id;
			inv.Reseller_PO__c = content.resellerPO+ '-' +cacheEntry.message.subject;
		}else
			inv = invs.get((content.resellerPO+ '-' +cacheEntry.message.subject).toUpperCase());
		
		inv.Status__c = 'New';
		inv.Reseller_PO_Received_Date__c =cacheEntry.processDate;
	    inv.Customer_PO__c = content.customerPO;
	    inv.Customer_PO_Received_Date__c = cacheEntry.processDate;
	    inv.CurrencyIsoCode = getCDWAccount().CurrencyIsoCode;
	  //  inv.Account__c = cacheEntry.account.Id;
	    inv.Invoice_Date__c = cacheEntry.processDate;
	    inv.Due_Date__c = cacheEntry.processDate.addDays(45);
	    inv.Case_Subject__c = cacheEntry.message.subject;
	    inv.OwnerId = getCDWAccount().OwnerId;
	    inv.Invoice_To_Contact__c = getCDWShipToInvoices().Id;
	    inv.Reseller_Email_PO__c = cacheEntry.message.Id;
	    if(isNew)
	   		insert inv;
	   	else{
	   		update inv;
	   		if(inv.Purchased_Products__r.size()>0)
	   			delete inv.Purchased_Products__r;
	   	}
	   	cacheEntry.message.Hapara_Invoice__c = inv.id;
	   	cacheEntry.invoice = inv;
	}
	
	private void processOpportunityProduct(MessageCache cacheEntry,CDWProductLine line){
		CaseMessageContent content = cacheEntry.content;
		Opportunity opp = cacheEntry.opportunity;
		System.debug('****processOpportunityProduct: opportunity= '+opp.Id);
		
		Product2 prod = cacheEntry.Product;
		Date endDate = Hapara_UtilityCommonRecordAccess.CalculateProductEndSubscriptionDate(prod,cacheEntry.processDate);
		System.debug('****processOpportunityProduct: Product= '+prod.Id + ' entry = ' +prod.PricebookEntries.size() );
		OpportunityLineItem lineItem = new OpportunityLineItem();
		lineItem.OpportunityId = opp.Id;
		lineItem.PricebookEntryId =prod.PricebookEntries[0].Id;
		lineItem.UnitPrice = line.purchaseProductPrice;
		lineItem.Quantity =  line.purchaseProductQuantiy;
		lineItem.account__c = cacheEntry.account.Id;
		lineItem.ServiceDate = cacheEntry.processDate;
		lineItem.Subscription_End_Date__c =  endDate;
		lineItem.Description2__c =  Hapara_UtilityCommonRecordAccess.BuildInvoiceLineDescription(prod.Description,cacheEntry.account.name, 
    		lineItem.ServiceDate,  lineItem.Subscription_End_Date__c);
		
		cacheEntry.lineItems.add(lineItem);
	}
	
	
	private void processOpportunity(MessageCache cacheEntry, map<Id,Opportunity> oppsList){
		CaseMessageContent content = cacheEntry.content;
		System.debug('****processOpportunity: cdw= ' +getCDWAccount().Id  +' account = ' +cacheEntry.account.Id 
				+ ' contact='+cacheEntry.customerContact.Id + ' createddate = ' +cacheEntry.processDate.format());
		//list<Opportunity> opps = [
		//				Select o.StageName, o.Id, (Select Id From OpportunityLineItems) From Opportunity o
		//				where o.AccountId=: getCDWAccount().Id 
		//				and o.Resellers_Account__c=: cacheEntry.account.Id  and o.PO_Number__c =: content.resellerPO
		//				limit 1];
		Opportunity opp;
		Boolean isNew = false;
		if(!oppsList.containsKey(cacheEntry.account.Id)){
			opp =  new Opportunity();
			opp.RecordTypeId = getRecordType().Id;
			opp.Name = getCDWAccount().Name +'-'+ cacheEntry.account.Name + '-Teacher Dashboard';
			opp.Opportunity_Name_Template__c = 'Teacher Dashboard'; 
			opp.Resellers_Account__c = cacheEntry.account.Id;
			opp.AccountId = getCDWAccount().Id;	
			isNew = true;
		}else
			opp = oppsList.get(cacheEntry.account.Id);
			
			opp.Hapara_Invoice__c =cacheEntry.Invoice.Id;
			opp.Reseller_Tier__c = getCDWAccount().Reseller_Tier__c;
			opp.CloseDate = cacheEntry.processDate;
			opp.StageName = HAPARA_CONST.OPPORTUNITY_STATGE_PROCESSINGPO;
			opp.Reseller_s_Status__c = HAPARA_CONST.OPPORTUNITY_STATGE_PROCESSINGPO;
			opp.Reseller_s_Contact__c = cacheEntry.customerContact.Id;
			opp.Reseller_s_Rep__c = cacheEntry.resellerRep.Id;
			opp.CampaignId = getResellerCampaign().Id;
			opp.PO_Number__c = content.resellerPO;
			opp.Amount = 1;
		    opp.Primary_Contact__c = getCDWShipToInvoices().Id;
			opp.Size_of_Opportunity__c= 'under 2000';
			
			opp.OwnerId = cacheEntry.account.ownerid == null?getCDWAccount().OwnerId:cacheEntry.account.ownerid ;
			opp.Reseller_Email_PO__c = cacheEntry.message.Id;
		
			if(isNew)
				insert opp;
			else{
				update opp;
				if(opp.OpportunityLineItems.size()>0)
					delete opp.OpportunityLineItems;
			}
			cacheEntry.message.Opportunity__c = opp.id;
			cacheEntry.opportunity = opp;
	}
	
	private void processCustomerContact(MessageCache cacheEntry,Account account){
		CaseMessageContent content = cacheEntry.content;
		System.debug('****processCustomerContact: filter email = '+content.customerContactEmail
					+ ' account = ' + cacheEntry.account.Id + ' account owner= ' + cacheEntry.account.ownerid);
		//list<Contact> cons = [Select c.Id, c.FirstName, c.Email From Contact c
		//			where c.Email =: content.customerContactEmail and c.AccountId =: cacheEntry.account.Id
		//			 limit 1];
		Contact con;
		List<String> names= content.customerContact.split(' ');
		Boolean isNew = false;
		if(account.Contacts.isEmpty()){
			con = new Contact();
			isNew = true;			
			con.AccountId = cacheEntry.account.Id;			
			con.Email = content.customerContactEmail;					
		}else
			con = account.Contacts[0];
			
		con.FirstName = names[0];
		con.LastName = names[1];
		con.Phone = content.customerContactPhone;
		con.Primary_Contact__c = true;
		con.OwnerId= getCDWAccount().OwnerId;
		if(isNew)
			insert con;
		else
			update con;		
		
		cacheEntry.customerContact = con;
	}
	
	private void  processCustomerAccount(MessageCache cacheEntry, map<string,Account> accountDomains, 
		map<string,Account>accountWebsite, map<string,Account>accountNameslist, Account specificAccount){
		CaseMessageContent content = cacheEntry.content;
		System.debug('****processCustomerAccount: filter customerName = '+content.customerName
					+ ' Domain = ' + content.customerDomain );
		
		Boolean isNew = false;
		Account acc;
		
		if(specificAccount == null){
			System.debug('****processCustomerAccount: accountDomains = '+accountDomains.size()
				+ ' accountWebsite= '+ accountWebsite.size()
				+ ' accountNameslist=' +accountNameslist.size() );
			if(accountDomains.containsKey(content.customerDomain.toUpperCase() )){
				acc = accountDomains.get(content.customerDomain.toUpperCase());
				if(acc.Name.toUpperCase() != content.customerName.toUpperCase())
					if(accountNameslist.containsKey(content.customerName.toUpperCase()) )
						acc = accountNameslist.get(content.customerName.toUpperCase()); 
			}else if(accountNameslist.containsKey(content.customerName.toUpperCase()) )
				acc = accountNameslist.get(content.customerName.toUpperCase());
			else if(accountWebsite.containsKey(content.customerDomain.toUpperCase()))
				acc= accountWebsite.get(content.customerDomain.toUpperCase());
			else{
				acc = new Account();
				isNew = true;
				acc.Name = content.customerName;
			}
		}else
			acc = specificAccount;
			
		System.debug('****processCustomerAccount: acc.Name = '+acc.Name + ' isnew=' +isNew);
		if(string.isEmpty(acc.Type))
			acc.Type =HAPARA_CONST.ACCOUNT_TYPE_PROSPECTRESELLER;
		else if(acc.Type.Contains('Customer'))
			acc.Type = HAPARA_CONST.ACCOUNT_TYPE_CUSTOMERRESELLER;
		else if(!acc.Type.contains('reseller'))
			acc.Type = HAPARA_CONST.ACCOUNT_TYPE_PROSPECTRESELLER;
			
		if(acc.Website == null)
			acc.Website = content.customerDomain;
		acc.Website_1__c = content.customerDomain;
		acc.Referral__c = getCDWAccount().Id;
		if(acc.Referral_Date__c  == null)
			acc.Referral_Date__c =cacheEntry.processDate;
		acc.Referral_Contact__c = cacheEntry.resellerRep.Id;
		acc.BillingCity = content.customerCity;
		acc.BillingCountry = content.customerCountry;
		acc.BillingState= content.customerState;
		acc.BillingPostalCode = content.customerZipCode;
		acc.BillingStreet = content.customerStreet;
		acc.Purchase_Order_No__c = content.resellerPO;
		acc.Received_Date_of_PO__c = cacheEntry.processDate;
		acc.Invoice_Contact__c = getCDWShipToInvoices().Id;
		if(isNew)
			acc.OwnerId = getCDWAccount().OwnerId;
		acc.Academic_Start_Month__c = 'July';
		if(acc.Type == null || acc.Type == HAPARA_CONST.ACCOUNT_TYPE_PROSPECTDIRECT)
			acc.Type = HAPARA_CONST.ACCOUNT_TYPE_PROSPECTRESELLER;
		
		if(acc.How_did_you_hear_about_us__c == null)
			acc.How_did_you_hear_about_us__c = 'Hapara Partner / Reseller';
		
		if(isNew )
			insert acc;
		else{
			update acc;
		}
		System.debug('****processCustomerAccount: inserted = ' + isNew);
		cacheEntry.account= acc;
	}
	
	
	public void processMessage(){
		for (MessageCache cacheEntry : cache) {
			try{
				Case caseDetails = cacheEntry.message;
				parseCaseDescription(caseDetails.Description);
				cacheEntry.content = message;	
				datetime createdDate = caseDetails.CreatedDate;
				
				//cacheEntry.cacheEntry.processDate = Date.newInstance(createdDate.year(),createdDate.month(),createdDate.day());	
				
				System.debug('****processMessage: parsed message createddate='+createdDate.format());
				
			}catch(Exception e){
				cacheEntry.errorState = true;
				cacheEntry.errorMessage = 'processMessage-Error:'  +  e.getMessage() 
					+ '\n\n//-- Stack Trace --//\n' + e.getStackTraceString();
				System.debug('****processMessage: ERROR:' +cacheEntry.errorMessage );
			}
		}
		getCDWReps(cache);
	}
	
	
	
	private static RecordType resellerType ;
	private static RecordType getRecordType(){
		try{
		if(resellerType == null)
			resellerType = [SELECT Id FROM RecordType where DeveloperName = 'Reseller_Opportunity'];
		}catch(Exception e){
			throw new HaparaException('getRecordType: Error:' + e);
		}
		//System.debug('****getRecordType: id = ' + resellerType.Id);	
		return resellerType;
	}
	
	private static Map<String,Product2> cdwProducts;
	
	private static Product2 getCDWProduct(MessageCache cacheEntry,CDWProductLine line){
		Product2 result ;
		 if(cdwProducts == null){
			cdwProducts =  new map<string,Product2>();
			list<Product2> prods = [Select r.Xero_Product_Code__c, r.Reseller_Product_Code_del__c, r.Reseller_Account_del__c, 
							r.Id ,r.Description, r.family, r.Subscription_Type__c,r.Subscription_Period__c,ProductCode,
							(Select  p.UseStandardPrice, p.UnitPrice, p.ProductCode, p.Product2Id, p.Id, 
							p.CurrencyIsoCode, p.IsActive 
							From PricebookEntries p where  p.CurrencyIsoCode =:getCDWAccount().CurrencyIsoCode and p.IsActive = true
							limit 1) 
							From Product2 r
							where  r.Reseller_Account_del__c =: getCDWAccount().Id
							];
			for(Product2 prod : prods){
				cdwProducts.put( prod.Reseller_Product_Code_del__c, prod);
			}
		
		}		
		system.debug('getCDWProduct:Product code ' +line.purchaseProductCode +' found = ' +cdwProducts.containsKey(line.purchaseProductCode));
		if(cdwProducts.containsKey(line.purchaseProductCode))
			result = cdwProducts.get(line.purchaseProductCode);
		else
			throw new HaparaException('getCDWProducts: Cannot find product code: ' + line.purchaseProductCode);
		return result;
		
	}
	
	
	private static Account cdwAccount;
	private static Account getCDWAccount(){
		try{
		if(cdwAccount == null)
			cdwAccount = [Select a.Website, a.Name, a.Id ,a.CurrencyIsoCode,a.Reseller_Tier__c,
						a.OwnerId, a.Owner.Name, a.Owner.email,a.Reseller_Setup_Email_Template_Name__c,
						a.Invoice_Contact__r.FirstName, a.Invoice_Contact__r.LastName, a.Invoice_Contact__c,
						a.Invoice_Contact__r.email,
						Reseller_Low_Order_Send_to_Customer__c,a.type
						From Account a where a.Name = 'CDW-G' limit 1];
		
		System.debug('****getCDWAccount: cdwAccount = ' +cdwAccount.Id +' ownerId= '+cdwAccount.OwnerId );
		}catch(Exception e){
			throw new HaparaException( 'getCDWAccount - Error:' + e);
		}
		return cdwAccount;
	}
	
	private  static Map<String,Contact> cdwReps = new Map<String,Contact>();
	
	public static void  getCDWReps(list<MessageCache> cache){
		try{
			system.debug('****getCDWReps: cache='+cache.size());
			CaseMessageContent message ;
			list<String> repEmails = new list<String>();
			for(MessageCache cacheEntry : cache){
				
				if(!cdwReps.containsKey(cacheEntry.content.resellerRepEmail.toLowerCase())){
					system.debug('****getCDWReps: not exists email='+cacheEntry.content.resellerRepEmail);
					repEmails.add(cacheEntry.content.resellerRepEmail.toLowerCase());
				}
			}
			
			system.debug('****getCDWReps: getting more reps=' +repEmails.size());
			if(repEmails.size() >0){
				
				List<Contact> reps = [select Id, email from Contact c 
									where c.email in: repEmails 
									and c.accountid =:getCDWAccount().Id ];
								
				for(Contact rep : reps){
					if(!cdwReps.containsKey(rep.email.toLowerCase()))
						cdwReps.put(rep.email.toLowerCase(), rep);
				}
			}
			
			for(MessageCache cacheEntry: cache){
				
				message = cacheEntry.content;
				System.debug('****getCDWReps: mesage email=' + message.resellerRepEmail  );
				if(!cdwReps.containsKey(message.resellerRepEmail.toLowerCase())){
					List<String> names= message.resellerRepName.split(' ');
					
					Contact rep;
					rep = new Contact();
					rep.FirstName = names[0];
					rep.LastName = names[1];
					rep.Title = 'Representative';
					rep.email = message.resellerRepEmail.toLowerCase();
					rep.AccountId = getCDWAccount().Id;
					insert rep;						
					cdwReps.put(rep.email, rep);						
					cacheEntry.resellerRep = rep;							
				}else{
					cacheEntry.resellerRep = cdwReps.get(message.resellerRepEmail.toLowerCase());	
				}
						
			}
		}catch(Exception e){
			throw new HaparaException('getCDWReps: ' +e);
		}
		
	}
	
	private static Campaign resellerCampaign;
	private static Campaign getResellerCampaign(){	
		try{
			if(resellerCampaign == null)
				resellerCampaign = [Select c.Name, c.Id From Campaign c where c.Name = 'Reseller/ Referral' limit 1 ];
				
		}catch(Exception e){
			throw new HaparaException( 'getResellerCampaign - Error:' + e);
		}
		return resellerCampaign;
	}
	

	
	private static Contact cdwShipToInvoices;
	private static Contact getCDWShipToInvoices(){			
		if(cdwShipToInvoices == null)
				cdwShipToInvoices = getCDWAccount().Invoice_Contact__r;
						
		return cdwShipToInvoices;
	}
	
	/**
	 * Sets the message statuses to 'In Progress'. If processing does not complete,
	 * we will know that the processing had started because of the status.
	 */
	public void initialise() {

		List<Case> messages = new List<Case>();
		for (MessageCache cacheEntry : cache) {
			cacheEntry.message.Status = 'In Progress';
			messages.add(cacheEntry.message);
		}
		update messages;
	}
	
	public Integer finalise() {
		List<Case> messages = new List<Case>();
		for (MessageCache cacheEntry : cache) {
			if(cacheEntry.errorState){				
				cacheEntry.message.Error_Message_2__c = cacheEntry.errorMessage;
				cacheEntry.message.Status = 'Errored';
			}else{
				cacheEntry.message.Status = 'Closed';
				cacheEntry.message.Error_Message_2__c = '';
			}
			if(cacheEntry.account !=null)
				cacheEntry.message.Link_To_Account__c = cacheEntry.account.Id;
			System.debug('****finalise: Case Id = '+ cacheEntry.message.Id  + ' subject =' + cacheEntry.message.Subject + ' Error:' + cacheEntry.errorMessage);
			messages.add(cacheEntry.message);
		}
		update messages;
		System.debug('****finalise:updated cases');
		return messages.size();
	}
	/**
	 * Adds a single message to the message cache.
	 */
	private void addMessage(Case message) {

		// Make a new cache entry object and store the message inside it
		MessageCache cacheEntry = new MessageCache();
		cacheEntry.message = message;
		cache.add(cacheEntry);
	}

	/**
	 * Adds a list of messages to the message cache.
	 */
	private void addMessages(List<Case> messages) {

		// Add each message using the single addMessage method
		for (Case msg : messages) {
			addMessage(msg);
		}
	}
}