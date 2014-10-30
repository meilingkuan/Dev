public class Hapara_TDD_UpdatePaymentDetailsHandler {
	
	/**
	 * A class to store related objects, making bulk processing easier.
	 */
	public class MessageCache {

		public MessageQueue__c message;
		public MessageContent content;
		public Account account;
		public Opportunity opportunity;
		public Account_Products__c product;

		public Boolean errorState = false;
		public String errorMessage = '';
	}

	/**
	 * A class representing the content of an NoPaymentMade JSON string
	 */
	public class MessageContent {

		public String paymentdate;	//2013-07-27T00:00:00
		public String paymentamount;	//3022
		public String paymentplan;	//Yearly
		public String firstname;	//Claudia
		public String lastname;	//Constantine
		public String country;	//United States
		public String address1;	//street1
		public String address2;	//street2
		public String city;	//New York City
		public String state;	//NY
		public String zipcode;	//0998
		public String email;	//claudia.constantine@ibp.edu.mx
		public String bill_country;	//New Zealand
		public String bill_address1;	//stonefield
		public String bill_address2;	//
		public String bill_city;	//Stonefield
		public String bill_state;	//Auckland
		public String bill_zipcode;	//0998
	}

	/**
	 * Takes a JSON string and deserializes it into a MessageContent object.
	 */
	private static MessageContent deserialzeJSON(String jsonString) {

		return (MessageContent) System.JSON.deserialize(jsonString, MessageContent.class);
	}

	/**
	 * Contains the objects we need to work with and enables last minute commits instead of committing on the fly.
	 */
	private List<MessageCache> cache = new List<MessageCache>();

	/**
	 * The settings that control how this process should behave. If the settings do not exist, a new instance will
	 * be returned so watch out for that. It will definitely blow things up.
	 */
	private static Hapara_TDD_Settings__c settings = Hapara_TDD_Settings__c.getInstance();

	/**
	 * An argumentless constructor to allow instantiation with out arguments.
	 */
	private Hapara_TDD_UpdatePaymentDetailsHandler() {}

	/**
	 * Constructor that also appends a single message to the message cache.
	 * @param message A single MessageQueue__c object that this handler should process
	 */
	private Hapara_TDD_UpdatePaymentDetailsHandler(MessageQueue__c message) {

		addMessage(message);
	}

	/**
	 * Constructor that appends a list of messages to the message cache.
	 * @param messages A list of MessageQueue__c objects that this handler should process
	 */
	private Hapara_TDD_UpdatePaymentDetailsHandler(List<MessageQueue__c> messages) {

		// Call the addMessages routine
		addMessages(messages);
	}

	/**
	 * Adds a single message to the message cache.
	 */
	private void addMessage(MessageQueue__c message) {

		// Make a new cache entry object and store the message inside it
		MessageCache cacheEntry = new MessageCache();
		cacheEntry.message = message;
		cache.add(cacheEntry);

		// Deserialize the JSON string into an object
		cacheEntry.content = deserialzeJSON(cacheEntry.message.MessageContent__c);
	}

	/**
	 * Adds a list of messages to the message cache.
	 */
	private void addMessages(List<MessageQueue__c> messages) {

		// Add each message using the single addMessage method
		for (MessageQueue__c msg : messages) {
			addMessage(msg);
		}
	}

	/**
	 * Sets the message statuses to 'In Progress'. If processing does not complete,
	 * we will know that the processing had started because of the status.
	 */
	private void initialise() {

		List<MessageQueue__c> messages = new List<MessageQueue__c>();
		for (MessageCache cacheEntry : cache) {
			cacheEntry.message.Status__c = 'In Progress';
			messages.add(cacheEntry.message);
		}
		update messages;
	}

	private void checkDuplicates() {

		List<String> originMsgIds = new List<String>();
		for (MessageCache cacheEntry : cache) {
			originMsgIds.add(cacheEntry.message.OriginMsgId__c);
		}
			
		Map<String,Integer> originMsgIdCounters = new Map<String,Integer>();
		for (MessageQueue__c msg : [SELECT OriginMsgId__c FROM MessageQueue__c WHERE OriginMsgId__c IN : originMsgIds]) {
			originMsgIdCounters.put(msg.OriginMsgId__c, (originMsgIdCounters.containsKey(msg.OriginMsgId__c) ? originMsgIdCounters.get(msg.OriginMsgId__c) + 1 : 1));
		}

		for (MessageCache cacheEntry : cache) {
			Integer counter = originMsgIdCounters.get(cacheEntry.message.OriginMsgId__c);
			if (counter != null && counter > 1) {
				cacheEntry.errorState = true;
				cacheEntry.errorMessage = (counter - 1) + ' other messages have the same OriginMsgId__c value';
			}
		}
	}

	/**
	 * Finds a person account with the email address from the message content
	 */
	private void matchRecords() {

		// Make a list of all email addresses from the message cache
		List<String> emailAddresses = new List<String>();
		for (MessageCache cacheEntry : cache) {
			emailAddresses.add(cacheEntry.content.email);
		}

		// Query all Person Accounts with an email from the list
		List<Account> accountQuery = [
			SELECT PersonEmail, Type,
			(
				SELECT Id, Name, Opportunity_Name_Template__c
				FROM Opportunities
				WHERE Opportunity_Name_Template__c = 'Teacher Dashboard Innovator'
				AND IsClosed = false
			)
			FROM Account
			WHERE PersonEmail IN :emailAddresses
		];

		// Put the returned accounts into a map sorted by
		Map<String,Account> accountsByEmail = new Map<String,Account>();
		for (Account a : accountQuery) {
			accountsByEmail.put(a.PersonEmail, accountsByEmail.containsKey(a.PersonEmail) ? null : a);
		}

		// Finally, iterate over message cache, matching accounts by email
		for (MessageCache cacheEntry : cache) {
			if (accountsByEmail.containsKey(cacheEntry.content.email)) {
				cacheEntry.account = accountsByEmail.get(cacheEntry.content.email);
				if (cacheEntry.account == null) {
					cacheEntry.errorState = true;
					cacheEntry.errorMessage = 'More than one PersonAccount was found with the email ' + cacheEntry.content.email;
					return;
				}
				cacheEntry.account.Type = 'Customer of Innovator';
			}
			else {
				cacheEntry.errorState = true;
				cacheEntry.errorMessage = 'No PersonAccount was found with the email ' + cacheEntry.content.email;
				return;
			}
		}

		// Check the oppotunities
		for (MessageCache cacheEntry : cache) {
			if (cacheEntry.errorState == false) {
				if (cacheEntry.account.Opportunities.size() == 0) {
					cacheEntry.errorState = true;
					cacheEntry.errorMessage = 'A Teacher Dashboard Innovator opportunity was not found for account ' + cacheEntry.account.Name;
				}
				else if (cacheEntry.account.Opportunities.size() > 1) {
					cacheEntry.errorState = true;
					cacheEntry.errorMessage = 'More than one Teacher Dashboard Innovator opportunity was found for account ' + cacheEntry.account.Name;
				}
				else {
					cacheEntry.opportunity = cacheEntry.account.Opportunities[0];
					cacheEntry.opportunity.StageName = 'Closed Won';
					cacheEntry.opportunity.CloseDate = Date.today();
				}
			}
		}
	}

	private static Id tdiProductId;
	private Id getTdiProductId() {

		if (tdiProductId == null) {
			List<Product2> products = [
				SELECT Id
				FROM Product2
				WHERE Name = 'Teacher Dashboard Innovator'
			];
			if (products.size() == 1) {
				tdiProductId = products[0].Id;
			}
		}
		return tdiProductId;
	}

	private void handlePayment() {

		for (MessageCache cacheEntry : cache) {
			if (cacheEntry.errorState == false) {
				if (cacheEntry.content.paymentdate != null && cacheEntry.content.paymentdate != '') {

					cacheEntry.account.Payment_Date__c = Date.valueOf(cacheEntry.content.paymentdate);


					try { // This could throw a wobbly
						cacheEntry.account.Credit_Card_Paid_Amt__c = Decimal.valueOf(cacheEntry.content.paymentamount) / 100;
					}
					catch (Exception e) {
						// we tried
					}

					cacheEntry.product = new Account_Products__c();
					cacheEntry.product.Account__c = cacheEntry.account.Id;
					cacheEntry.product.Description__c = cacheEntry.content.paymentplan;
					cacheEntry.product.Invoice_Date__c = Date.valueOf(cacheEntry.content.paymentdate);
					cacheEntry.product.Invoice_No__c = 'TDI';
					cacheEntry.product.Product__c = getTdiProductId();
					cacheEntry.product.Quantity__c = 1;
					cacheEntry.product.Hapara_Invoice__c = settings.Default_Hapara_Invoice__c;

					try { // This could throw a wobbly
						cacheEntry.product.Unit_Price__c = Decimal.valueOf(cacheEntry.content.paymentamount) / 100;
					}
					catch (Exception e) {
						// we tried
					}

					// Update the opportunity stage to 'Closed Won' and change the ClosedDate to the paymentdate
					cacheEntry.opportunity.StageName = 'Closed Won';
					cacheEntry.opportunity.CloseDate = cacheEntry.account.Payment_Date__c;
				}
			}
		}
	}

	private void mapFields() {

		for (MessageCache cacheEntry : cache) {
			if (cacheEntry.errorState == false) {
				cacheEntry.account.Invoice_Period__c = cacheEntry.content.paymentplan;
				cacheEntry.account.FirstName = cacheEntry.content.firstname;
				cacheEntry.account.LastName = cacheEntry.content.lastname;
				cacheEntry.account.ShippingCountry = cacheEntry.content.country;
				cacheEntry.account.ShippingStreet = cacheEntry.content.address1;
				cacheEntry.account.ShippingStreet += cacheEntry.content.address2 == null && cacheEntry.content.address2 == '' ? '' : '\n' + cacheEntry.content.address2;
				cacheEntry.account.ShippingCity = cacheEntry.content.city;
				cacheEntry.account.ShippingState = cacheEntry.content.state;
				cacheEntry.account.ShippingPostalCode = cacheEntry.content.zipcode;
				cacheEntry.account.BillingCountry = cacheEntry.content.bill_country;
				cacheEntry.account.BillingStreet = cacheEntry.content.bill_address1;
				cacheEntry.account.BillingStreet += cacheEntry.content.bill_address2 == null && cacheEntry.content.bill_address2 == '' ? '' : '\n' + cacheEntry.content.bill_address2;
				cacheEntry.account.BillingCity = cacheEntry.content.bill_city;
				cacheEntry.account.BillingState = cacheEntry.content.bill_state;
				cacheEntry.account.BillingPostalCode = cacheEntry.content.bill_zipcode;
			}
		}
	}

	/**
	 * Pushes all the changes made to the database.
	 */
	private void finalise() {

		List<Account> accounts = new List<Account>();
		List<Opportunity> opportunities = new List<Opportunity>();

		Map<Id,MessageCache> cacheByAccountId = new Map<Id,MessageCache>();
		Map<Id,MessageCache> cacheByOpportunityId = new Map<Id,MessageCache>();

		for (MessageCache cacheEntry : cache) {
			if (cacheEntry.errorState == false) {
				accounts.add(cacheEntry.account);
				opportunities.add(cacheEntry.opportunity);
				cacheByAccountId.put(cacheEntry.account.Id, cacheEntry);
				cacheByAccountId.put(cacheEntry.opportunity.Id, cacheEntry);
			}
		}

		List<Database.SaveResult> accountsUpdateResults = Database.update(accounts, false);
		List<Database.SaveResult> opportunitiesUpdateResults = Database.update(opportunities, false);

		for (Database.SaveResult saveResult : accountsUpdateResults) {
			if (!saveResult.isSuccess()) {
				MessageCache cacheEntry = cacheByAccountId.get(saveResult.getId());
				cacheEntry.errorState = true;
				cacheEntry.errorMessage = cacheEntry.errorMessage == null ? '' : '\n\n';
				cacheEntry.errorMessage += 'Errors when updating account;\n';
				for(Database.Error dbError : saveResult.getErrors()) {
					cacheEntry.errorMessage += dbError.getStatusCode() + ': ' + dbError.getMessage() + '\n';
				}
			}
		}

		for (Database.SaveResult saveResult : opportunitiesUpdateResults) {
			if (!saveResult.isSuccess()) {
				MessageCache cacheEntry = cacheByAccountId.get(saveResult.getId());
				cacheEntry.errorState = true;
				cacheEntry.errorMessage = cacheEntry.errorMessage == null ? '' : '\n\n';
				cacheEntry.errorMessage += 'Errors when updating opportunity;\n';
				for(Database.Error dbError : saveResult.getErrors()) {
					cacheEntry.errorMessage += dbError.getStatusCode() + ': ' + dbError.getMessage() + '\n';
				}
			}
		}

		List<Account_Products__c> products = new List<Account_Products__c>();
		for (MessageCache cacheEntry : cache) {
			if (cacheEntry.errorState == false && cacheEntry.product != null) {
				products.add(cacheEntry.product);
			}
		}
		List<Database.SaveResult> productsInsertResults = Database.insert(products, false);


		List<MessageQueue__c> messages = new List<MessageQueue__c>();
		for (MessageCache cacheEntry : cache) {
			if (cacheEntry.errorState == false) {
				cacheEntry.message.Status__c = 'Completed';
				cacheEntry.message.ErrorMessage__c = null;
			}
			else {
				cacheEntry.message.Status__c = 'Errored';
				cacheEntry.message.ErrorMessage__c = cacheEntry.errorMessage;
			}
			cacheEntry.message.DateCompleted__c = Datetime.now();
			messages.add(cacheEntry.message);
		}
		update messages;
	}

	/**
	 * Queries the messages and marshalls them through the process.
	 */
	public static void process(List<Id> messageIds) {

		// Query the message queue objects
		List<MessageQueue__c> messages = [
			SELECT Id, ApplicationName__c, MessageType__c, MessageContent__c,
				ErrorMessage__c, DateCompleted__c, Status__c, OriginMsgId__c
			FROM MessageQueue__c
			WHERE Id IN :messageIds
			//AND Status__c != 'Completed' // <- Prevents processing messages that have already been completed
			AND MessageType__c = 'UpdatePaymentDetails'
		];

		//HACK json parser doesn't like the decimal place used in billing address labels. Strip the dp.
		for (MessageQueue__c m : messages) {
			m.MessageContent__c = m.MessageContent__c.replace('bill.country','bill_country');
			m.MessageContent__c = m.MessageContent__c.replace('bill.address1','bill_address1');
			m.MessageContent__c = m.MessageContent__c.replace('bill.address2','bill_address2');
			m.MessageContent__c = m.MessageContent__c.replace('bill.city','bill_city');
			m.MessageContent__c = m.MessageContent__c.replace('bill.state','bill_state');
			m.MessageContent__c = m.MessageContent__c.replace('bill.zipcode','bill_zipcode');
		}

		Hapara_TDD_UpdatePaymentDetailsHandler handler = new Hapara_TDD_UpdatePaymentDetailsHandler(messages);
		handler.initialise();
		handler.checkDuplicates();
		handler.matchRecords();
		handler.handlePayment();
		handler.mapFields();
		handler.finalise();
	}

	/**
	 * A method to run this process asynchronously.
	 */
	@future
	public static void processFuture(List<Id> messageIds) {

		try {
			process(messageIds);
		}
		catch (Exception e) {
			sendExceptionEmail(e);
		}
	}

	public static void sendExceptionEmail(Exception e) {
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject( 'TDD SignedUpHandler Exception');
        mail.setPlainTextBody( e.getMessage() );
        mail.setToAddresses( new String[] { 'sfdev@trineo.co.nz' } );
        
        try {
        	Messaging.SendEmailResult[] results = Messaging.sendEmail( new Messaging.SingleEmailMessage[]{ mail }, false);
        }
        catch (Exception e2) {}
	}
}