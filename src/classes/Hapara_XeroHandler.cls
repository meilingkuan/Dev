public class Hapara_XeroHandler {
    public string consumerKey ;
    public string consumerSecret;
    public string token ;
    public String tokenSecret ;
    public string endPoint;
    public String certificate;
    static sfXero.XeroCredentials xc;
    static HaparaXeroConfig__c haparaSetting = HaparaXeroConfig__c.getInstance('Hapara');
    
    

    public Hapara_XeroHandler(){
        OAuth_Service__c obj = [Select o.OAuth_Certificate__c, o.ConsumerSecretKey__c, o.ConsumerKey__c, o.AccessTokenUrl__c 
                        From OAuth_Service__c o where o.Name = 'XeroAPI' ];     
        consumerKey= obj.ConsumerKey__c     ;
        consumerSecret = obj.ConsumerSecretKey__c;
        token = consumerKey;
        tokenSecret = consumerSecret;
        certificate = obj.OAuth_Certificate__c;
        endPoint = obj.AccessTokenUrl__c;           
    }
    
    @future(callout=true)
    public static void processRecords(list<Id> messageIds, string consumerKey,string certificate ){
        system.debug('****processRecords started');
        list<Hapara_Invoice__c> objs = [
            Select h.Xero_Invoice_No__c, h.SystemModstamp, h.Status__c, h.Reseller_PO__c, h.Reseller_PO_Received_Date__c, 
            h.Reseller_Account__c, h.Process__c, h.Paid_Date__c, h.OwnerId, h.Name, h.LastModifiedDate, h.LastModifiedById, h.IsDeleted, 
            h.Invoice_Date__c, h.Id, h.HTTP_Response__c, h.Error_Message__c, h.Due_Date__c, h.Customer_PO__c, h.Customer_PO_Received_Date__c, 
            h.CurrencyIsoCode, h.CreatedDate, h.CreatedById, h.Case_Subject__c, h.Xero_Id__c,
            h.Xero_Payment_Id__c,h.Payment_Check_No__c,h.Total_Amount__c,h.Invoice_Type__c,h.Xero_Currency_Rate__c,
           
            h.Invoice_To_Contact__c, h.Invoice_To_Contact__r.firstname, h.Invoice_To_Contact__r.lastname, h.Invoice_To_Contact__r.email,
            
            h.Account__r.Invoice_Contact__c, h.Account__r.CurrencyIsoCode, h.Account__r.Website, h.Account__r.BillingCountry, 
            h.Account__r.BillingPostalCode, h.Account__r.BillingState, h.Account__r.BillingCity, h.Account__r.BillingStreet, 
            h.Account__r.Name, h.Account__c, h.Account__r.Xero_Id__c,
            h.Account__r.TD_Invoiced_Date__c, h.Account__r.TD_Invoice_Due_Date__c, h.Account__r.Invoice_Period__c,
            h.Account__r.Current_Invoice_No__c, h.Account__r.Payment_Date__c,h.Account__r.Type,h.Account__r.Purchase_Order_No__c,
            h.Account__r.Received_Date_of_PO__c,
           
            h.Reseller_Account__r.Xero_Id__c,  h.Reseller_Account__r.BillingCountry, 
            h.Reseller_Account__r.BillingPostalCode, h.Reseller_Account__r.BillingState, h.Reseller_Account__r.BillingCity, h.Reseller_Account__r.BillingStreet, 
            h.Reseller_Account__r.CurrencyIsoCode,h.Reseller_Account__r.Website,h.Reseller_Account__r.Name,
            
            (Select RecordTypeId, StageName, IsClosed From Opportunities__r ),
           
            (Select Id, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, 
            Product__c,Description__c, Account__c, Quantity__c, Discount__c, Invoice_Date__c, Invoice_No__c, Unit_Price__c, Amount__c, 
            Hapara_Invoice__c, Subscription_Start_Date__c, Subscription_End_Date__c, Product_Family__c From Purchased_Products__r 
            where Not_Sync_to_Xero__c !=true) 
            From Hapara_Invoice__c h
             WHERE h.Id = :messageIds
        ];
        //
        system.debug('****processRecords Initialising values');
        xc = new sfXero.XeroCredentials(consumerKey, '', certificate);
        Hapara_XeroHandler.getXeroInvoiceBrandingThemes();  
            
        system.debug('****processRecords started procesing invoices');
        sfxero.XeroInvoiceResponse xir;
        string xmlResponse;
        string xmlMessage;
        list<Account> tobeUpdateAccount = new list<Account>();
        list<Account_Products__c> updatePurchasedProduct = new list<Account_Products__c>();
        
        for(Hapara_Invoice__c inv :objs){
            try {   
                sfxero.XeroContact xcon = createContact( inv);
                sfxero.XeroInvoice xinv= createInvoice(inv, xcon);
                system.debug('****processRecords Purchased_Products__r size = ' +inv.Purchased_Products__r.size());
                for(Account_Products__c line :inv.Purchased_Products__r )
                    addInvoiceLineInvoice(line, xinv);
                
                list<sfxero.XeroInvoice> ls = new list<sfxero.XeroInvoice>();
                ls.add(xinv);
                try{
                    if(Test.isRunningTest()){
                        xir = new sfxero.XeroInvoiceResponse();
                        xir.status = 'OK';
                        list<sfxero.XeroInvoice> test = new list<sfxero.XeroInvoice>();
                        test.add(new sfxero.XeroInvoice());
                        xir.invoices = test;
                    }
                    else
                        xir = sfxero.XeroAPI.postInvoices(ls, xc);      
                    system.debug('****postXeroInvoice status:' +xir.status);
                    if(xir.status != 'OK'){         
                        xmlResponse = xir.xmlResponse;
                        xmlMessage = xir.httpResponseMessage;
                        
                        inv.Status__c = HAPARA_CONST.INVOICE_STATUS_ERRORED;
                        Hapara_XeroHandler.sendXeroAdministratorEmail(xmlResponse, inv );
                        inv.Error_Message__c ='postXeroInvoice ERROR :'+ xmlMessage;
                        inv.HTTP_Response__c = xmlResponse;
                    }else{
                        sfxero.XeroInvoice xpinv = xir.invoices[0];
                        inv.Status__c = HAPARA_CONST.INVOICE_STATUS_UPDATED_TO_XERO;
                        inv.Error_Message__c ='';
                        
                        inv.Xero_Id__c = xpinv.invoiceId;
                        if(xpinv.invoiceType == sfxero.XeroInvoice.XeroInvoiceType.ACCPAY){
                        	inv.Xero_Invoice_No__c = 'Purchase Invoice';
                        	inv.Total_Amount__c =xpinv.total*-1;
                        }
                        else{
                        	inv.Xero_Invoice_No__c = xpinv.invoiceNumber;
                        	inv.Total_Amount__c =xpinv.total;
                        }
                        inv.Xero_Currency_Rate__c = xpinv.currencyRate;
                        Account acc = inv.Account__r;                                                 
                       // inv.RecordType = Hapara_XeroHandler.getRecordType();  
                        if(inv.Account__r.Xero_Id__c == null){
                           
                            acc.Xero_Id__c =xpinv.contact.contactId ;
                            acc.TD_Invoice_Due_Date__c = xpinv.DueDate;
                           
                            string temp = getAcountCustomerTypeFromProspect(acc.Type);
                           
                           	if(temp != '')
                            	acc.Type =temp;
                        }
                        acc.TD_Invoiced_Date__c = inv.Invoice_Date__c;
                        acc.Current_Invoice_No__c = xpinv.invoiceNumber;
                        acc.Invoice_Contact__c = inv.Invoice_To_Contact__c;   
                        acc.Purchase_Order_No__c= inv.Reseller_PO__c==null? inv.Customer_PO__c:inv.Reseller_PO__c;
                        acc.Received_Date_of_PO__c=inv.Reseller_PO_Received_Date__c == null? inv.Customer_PO_Received_Date__c: inv.Reseller_PO_Received_Date__c;
                        tobeUpdateAccount.add(acc);          
                    }
                }catch(System.CalloutException e){
                    system.debug('****postXeroInvoice Errored:' + e.getMessage() + '\n\n//-- Stack Trace --//\n' + e.getStackTraceString());
                    if(!Test.isRunningTest())
                        throw new HaparaException('postXeroInvoice Errored:' + e.getMessage() + '\n\n//-- Stack Trace --//\n' + e.getStackTraceString());
                }
            } catch (Exception e) {
            	string error = 'processRecords ERROR2 :'+ e.getMessage() + '\n\n//-- Stack Trace --//\n' + e.getStackTraceString();
                System.debug(error);
                inv.Status__c = HAPARA_CONST.INVOICE_STATUS_ERRORED;
                inv.Error_Message__c =error;
                
            }
        }
        list<Opportunity> tobeUpdatedOpps = new list<Opportunity>();
        list<id> lineAccountIds = new list<id>();
        list<Account> updateAccountLines = new list<Account>();
        for(Hapara_Invoice__c inv1:objs){
            for(Account_Products__c pro : inv1.Purchased_Products__r){
                pro.Invoice_Date__c =  inv1.Invoice_Date__c;
                pro.Invoice_No__c = inv1.Xero_Invoice_No__c;
                //if(pro.Account__c != inv1.Account__c){
                	lineAccountIds.add(pro.Account__c);
               // }
                
            }
            updatePurchasedProduct.addAll(inv1.Purchased_Products__r);
            for(Opportunity o : inv1.Opportunities__r){
            	if(o.StageName == HAPARA_CONST.OPPORTUNITY_STATGE_PROCESSINGPO){
            		o.StageName = HAPARA_CONST.OPPORTUNITY_STAGE_APPROVEDPO;
            		tobeUpdatedOpps.add(o);
            	}
            }
        }
        string temp;
        if(lineAccountIds.size()>0){
        	date currentYearJan =   date.valueOf(Date.today().year()+'-01-01');
        	Date nextYearJan = date.valueOf((Date.today().year()+1)+'-01-01');
        	list<Account>lineAccounts = [select id,type ,Total_Seats_Invoiced_YTD__c,
        			 (Select Quantity__c, Product_Family__c, Subscription_End_Date__c 
        			 	From Account_Product__r
        			 	where  Subscription_Start_Date__c<:nextYearJan 
        			 		and (NOT Status__c LIKE '%cancelled%') AND Subscription_End_Date__c >today
        			 		AND (Product_Family__c = 'TD' OR Product_Family__c ='TD + RC') and Invoice_No__c != null
        			 		)
        			from Account where id =: lineAccountIds];
        	for(Account a :lineAccounts ){
        		temp = getAcountCustomerTypeFromProspect(a.Type);
                           
                if(temp != ''){
                       a.Type =temp;  
                }
                decimal purchasedSeats = 0.0;
				for(Account_Products__c p : a.Account_Product__r){
					purchasedSeats = purchasedSeats + p.Quantity__c;
				}
				a.Total_Seats_Invoiced_YTD__c = purchasedSeats;
                
                updateAccountLines.add(a);
                 
        	}
        }
        
        update objs;
        update updatePurchasedProduct;
        if(tobeUpdateAccount.size()>0)
            update tobeUpdateAccount;
            
        if(tobeUpdatedOpps.size()>0)
        	update tobeUpdatedOpps;
        if(updateAccountLines.size()>0)
        	update updateAccountLines;
    }
    
    @future(callout=true)
    public static void processCancelInvoice(Id invId, string consumerKey,string certificate ){
        system.debug('****processCancelInvoice started');
        Hapara_Invoice__c inv = [
            Select h.Xero_Invoice_No__c, h.SystemModstamp, h.Status__c, h.Reseller_PO__c, h.Reseller_PO_Received_Date__c, 
            h.Reseller_Account__c, h.Process__c, h.Paid_Date__c, h.OwnerId, h.Name, h.LastModifiedDate, h.LastModifiedById, h.IsDeleted, 
            h.Invoice_Date__c, h.Id, h.HTTP_Response__c, h.Error_Message__c, h.Due_Date__c, h.Customer_PO__c, h.Customer_PO_Received_Date__c, 
            h.CurrencyIsoCode, h.CreatedDate, h.CreatedById, h.Case_Subject__c, h.Xero_Id__c,
            h.Xero_Payment_Id__c,h.Payment_Check_No__c,h.Total_Amount__c,h.Invoice_Type__c,h.Cancelled_Reason__c,h.Opportunity_Lost_Stage__c,
           
            h.Invoice_To_Contact__c, h.Invoice_To_Contact__r.firstname, h.Invoice_To_Contact__r.lastname, h.Invoice_To_Contact__r.email,
            
            h.Account__r.Invoice_Contact__c, h.Account__r.CurrencyIsoCode, h.Account__r.Website, h.Account__r.BillingCountry, 
            h.Account__r.BillingPostalCode, h.Account__r.BillingState, h.Account__r.BillingCity, h.Account__r.BillingStreet, 
            h.Account__r.Name, h.Account__c, h.Account__r.Xero_Id__c,
            h.Account__r.TD_Invoiced_Date__c, h.Account__r.TD_Invoice_Due_Date__c, h.Account__r.Invoice_Period__c,
            h.Account__r.Current_Invoice_No__c, h.Account__r.Payment_Date__c,h.Account__r.Type,h.Account__r.Purchase_Order_No__c,
            h.Account__r.Received_Date_of_PO__c,
           
            h.Reseller_Account__r.Xero_Id__c,  h.Reseller_Account__r.BillingCountry, 
            h.Reseller_Account__r.BillingPostalCode, h.Reseller_Account__r.BillingState, h.Reseller_Account__r.BillingCity, h.Reseller_Account__r.BillingStreet, 
            h.Reseller_Account__r.CurrencyIsoCode,h.Reseller_Account__r.Website,h.Reseller_Account__r.Name,
            
            (Select RecordTypeId, StageName, IsClosed From Opportunities__r ),
           
            (Select Id, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, 
            Product__c,Description__c, Account__c, Quantity__c, Discount__c, Invoice_Date__c, Invoice_No__c, Unit_Price__c, Amount__c, 
            Hapara_Invoice__c, Subscription_Start_Date__c, Subscription_End_Date__c, Product_Family__c From Purchased_Products__r 
            where Not_Sync_to_Xero__c !=true) 
            From Hapara_Invoice__c h
             WHERE h.Id = :invId
        ];
        //
        system.debug('****processCancelInvoice Initialising values');
        xc = new sfXero.XeroCredentials(consumerKey, '', certificate);

            
        system.debug('****processCancelInvoice started procesing invoices');
        sfxero.XeroInvoiceResponse xir;
        string xmlResponse;
        string xmlMessage;

	    try {   
	      
	        sfxero.XeroInvoice xinv = new sfxero.XeroInvoice();
	      	xinv.invoiceId = inv.Xero_Id__c;
	      	xinv.status = sfxero.XeroInvoice.XeroInvoiceStatus.VOIDED;
	        xinv.invoiceNumber = inv.Xero_Invoice_No__c;
	        
	        list<sfxero.XeroInvoice> ls = new list<sfxero.XeroInvoice>();
	        ls.add(xinv);
	        try{
	            if(Test.isRunningTest()){
	                xir = new sfxero.XeroInvoiceResponse();
	                xir.status = 'OK';
	                list<sfxero.XeroInvoice> test = new list<sfxero.XeroInvoice>();
	                test.add(new sfxero.XeroInvoice());
	                xir.invoices = test;
	            }
	            else
	                xir = sfxero.XeroAPI.postInvoices(ls, xc);      
	            system.debug('****processCancelInvoice status:' +xir.status);
	            if(xir.status != 'OK'){         
	                xmlResponse = xir.xmlResponse;
	                xmlMessage = xir.httpResponseMessage;
	                
	                inv.Status__c = HAPARA_CONST.INVOICE_STATUS_ERRORED;
	                Hapara_XeroHandler.sendXeroAdministratorEmail(xmlResponse, inv );
	                inv.Error_Message__c ='processCancelInvoice ERROR :'+ xmlMessage;
	                inv.HTTP_Response__c = xmlResponse;
	            }else{
	                sfxero.XeroInvoice xpinv = xir.invoices[0];
	                inv.Status__c = HAPARA_CONST.INVOICE_STATUS_CANCELLED;
	                inv.Error_Message__c ='';
	                      
	            }
	        }catch(System.CalloutException e){
	            system.debug('****processCancelInvoice Errored:' + e.getMessage() + '\n\n//-- Stack Trace --//\n' + e.getStackTraceString());
	            if(!Test.isRunningTest())
	                throw new HaparaException('processCancelInvoice Errored:' + e.getMessage() + '\n\n//-- Stack Trace --//\n' + e.getStackTraceString());
	        }
	        update inv;
        	lockCancelledInvoice(inv);
	    } catch (Exception e) {
	        System.debug('****processCancelInvoice ERROR2:'+ e.getMessage() + '\n\n//-- Stack Trace --//\n' + e.getStackTraceString());
	        inv.Status__c = HAPARA_CONST.INVOICE_STATUS_ERRORED;
	        inv.Error_Message__c ='processCancelInvoice ERROR2 :'+ e;
	        
	    }    
      
    }
    	
    public static void lockCancelledInvoice(Hapara_Invoice__c inv){
    	//UPDATE LINES TO BE CANCELLED
        if(inv.status__c== HAPARA_CONST.INVOICE_STATUS_CANCELLED){

        	list<Approval.ProcessSubmitRequest> reqs = new list<Approval.ProcessSubmitRequest>();
        	Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
       	    req1.setComments('Cancelled the Invoice set to ready only');
        	req1.setObjectId(inv.id);
        	reqs.add(req1);
        	for(Account_Products__c line: inv.Purchased_Products__r){
        		line.Status__c =  HAPARA_CONST.INVOICE_STATUS_CANCELLED;
        		line.Invoice_Date__c = null;
        		req1 = new Approval.ProcessSubmitRequest();
        		req1.setComments('Cancelled the Invoice set to ready only');
	        	req1.setObjectId(line.id);
	        	reqs.add(req1);
        	}
        	//update opportunity to lost
        	for(Opportunity o : inv.Opportunities__r){
	            o.StageName = inv.Opportunity_Lost_Stage__c != null ? inv.Opportunity_Lost_Stage__c: HAPARA_CONST.OPPORTUNITY_STAGE_LOST;
	            o.Lost_Reason__c = inv.Cancelled_Reason__c;
	           	req1 = new Approval.ProcessSubmitRequest();
	            req1.setComments('Cancelled the Invoice set to ready only');
	        	req1.setObjectId(o.id);
	        	reqs.add(req1);
	        }
       
          	update inv.Purchased_Products__r;
       		update inv.Opportunities__r;
       		
       		Approval.ProcessResult[] result = Approval.process(reqs);      		
       		string[] useremails = HAPARA_CONST.SETTING_INVOICE.Invoice_Cancellation_Notification_Emails__c.split(';');
       		HaparaSendEmailNotification.SendUsersWithTemplate(HAPARA_CONST.SETTING_INVOICE.Invoice_Cancellation_Email_Template__c,
			 inv.id, useremails);
        }
    
    }
    
    public  static string getAcountCustomerTypeFromProspect(string prospectType){
	    	string result= '';
	    	if(prospectType == HAPARA_CONST.ACCOUNT_TYPE_PROSPECTDIRECT)
            	result = HAPARA_CONST.ACCOUNT_TYPE_CUSTOMERDIRECT;
            else if(prospectType == HAPARA_CONST.ACCOUNT_TYPE_PROSPECTGOOGLEAPP)
            	result = HAPARA_CONST.ACCOUNT_TYPE_CUSTOMERGOOGLEAPP;
            else if(prospectType == HAPARA_CONST.ACCOUNT_TYPE_PROSPECTRESELLER)
            	result =HAPARA_CONST.ACCOUNT_TYPE_CUSTOMERRESELLER;
            return result;
	    }
    
    public Integer initialise(list<Id> messageIds, string status) {
        list<Hapara_Invoice__c> objs = [
            Select h.Xero_Invoice_No__c, h.SystemModstamp, h.Status__c, h.Reseller_PO__c, h.Reseller_PO_Received_Date__c, 
            h.Reseller_Account__c, h.Process__c, h.Paid_Date__c, h.OwnerId, h.Name, h.LastModifiedDate, h.LastModifiedById, h.IsDeleted, 
            h.Invoice_Date__c, h.Id, h.HTTP_Response__c, h.Error_Message__c, h.Due_Date__c, h.Customer_PO__c, h.Customer_PO_Received_Date__c, 
            h.CurrencyIsoCode, h.CreatedDate, h.CreatedById, h.Case_Subject__c, h.Xero_Id__c,h.Xero_Payment_Id__c,Payment_Check_No__c,
            Total_Amount__c
            From Hapara_Invoice__c h
             WHERE h.Id = :messageIds
        ];
        system.debug('****initialise started');
        for(Hapara_Invoice__c inv :objs){
            inv.Status__c =status ;
            inv.Error_Message__c ='';
            inv.HTTP_Response__c = '';
        }
        update objs;
        return objs.size();
    }
    
    public Integer initialisePayment(list<Id> messageIds, string status) {
        list<HaparaInvoicePayment__c> objs = [
            Select h.Xero_Payment_Id__c, h.Status__c, h.Payment_Check_No_Ref__c, h.Invoice__r.Xero_Id__c,h.Invoice__r.Name,
                h.Invoice__r.Id,
                 h.Invoice__c, h.Id, 
                h.Date_Of_Payment__c, h.Amount_Paid__c 
                From HaparaInvoicePayment__c h
             WHERE h.Id = :messageIds
        ];
        system.debug('****initialisePayment started');
        for(HaparaInvoicePayment__c pay :objs){
            pay.Status__c =status ;
            pay.Error_Message__c ='';
            pay.HTTP_Response__c = '';
        }
        update objs;
        return objs.size();
    }
    
    public static void sendXeroAdministratorEmail(string response,Hapara_Invoice__c inv ){
        system.debug('****sendXeroAdministratorEmail started');
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses;
        String salesforceURL = Hapara_Utility.isRunningInSandbox()?Hapara_Utility.GetSandboxURL():Hapara_Utility.GetProductionURL();
        
                                        
        System.debug('****sendXeroAdministratorEmail');
                    
        mail.setSenderDisplayName('Xero Integration');
        toAddresses = new String[] {'salesforcedev@hapara.com'};
        mail.setToAddresses(toAddresses);
   
        // set the subject on the email
        mail.setSubject('Errored on Invoice: '  + inv.Name);
                  
        // set the body of the email
        mail.setHTMLBody('<p>*** HTTP RESPONSE ERROR *** </p>' 
                        + salesforceURL +'/'+ inv.id+'</p>'
                        + response
                    );
                               
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
   }
   
    
    private static sfxero.XeroContact createContact(Hapara_Invoice__c inv){
        system.debug('****createContact started');
        Account invoiceCustomer = inv.Reseller_Account__c == null? inv.Account__r:inv.Reseller_Account__r;
        Contact con = inv.Invoice_To_Contact__r;
        sfxero.XeroContact contact = new sfxero.XeroContact();
        string orgName = invoiceCustomer.Name;
        if(!string.isEmpty(inv.Account__r.website)){
            orgName = orgName + ' (' +invoiceCustomer.website +')';
        }
        if(invoiceCustomer.Xero_Id__c != null){
            contact.contactId =invoiceCustomer.Xero_Id__c; 
        }
        
        contact.orgName =orgName;
        contact.firstName =con.FirstName;
        contact.lastName = con.LastName;
        contact.emailAddress = con.Email;
        contact.defaultCurrency = inv.CurrencyIsoCode;
        
        contact.isCustomer = true;
        if(inv.Reseller_Account__r != null)
            contact.contactGroups = 'Reseller';
        else
            contact.contactGroups = 'Customers';
        
        sfxero.XeroContact.XeroAddress address = new sfxero.XeroContact.XeroAddress();
        address.addressLine1 = invoiceCustomer.BillingStreet;
        address.addressType = sfxero.XeroContact.XeroAddressType.POBOX;
        address.attentionTo = con.FirstName + ' ' + con.LastName;
        address.city=invoiceCustomer.BillingCity;
        address.country= invoiceCustomer.BillingCountry;
        address.postalCode=invoiceCustomer.BillingPostalCode;
        address.region=invoiceCustomer.BillingState;
        
        contact.addAddress(address);
        
        return contact;
    }
    
    private static sfxero.XeroInvoice createInvoice(Hapara_Invoice__c inv, sfxero.XeroContact xcon){
        system.debug('****createInvoice started');
        
        sfxero.XeroInvoice xinv = new sfxero.XeroInvoice();
        if(inv.Invoice_Type__c == HAPARA_CONST.INVOICE_TYPE_PURCHASEINVOICE)
        	xinv.invoiceType = sfxero.XeroInvoice.XeroInvoiceType.ACCPAY;
        else 
        	xinv.invoiceType = sfxero.XeroInvoice.XeroInvoiceType.ACCREC;
        xinv.invoiceId = inv.Xero_Id__c;
        xinv.contact = xcon;
        xinv.issuedDate = inv.Invoice_Date__c;  
        xinv.DueDate = inv.Due_Date__c;
        xinv.lineAmountTypes = sfxero.XeroInvoice.XeroLineAmountType.Exclusive;
        xinv.reference = inv.Reseller_PO__c == null? inv.Customer_PO__c : inv.Reseller_PO__c;
        xinv.currencyCode = inv.CurrencyIsoCode;
        xinv.status = sfxero.XeroInvoice.XeroInvoiceStatus.AUTHORISED;
    //  if(inv.Paid_Date__c != null){
    //      createPayment( inv,xinv);   
    //  }
        
        string result = '';
        if(Hapara_XeroHandler.xeroBrandingConfig.containsKey(inv.Account__r.BillingCountry) )
            result = Hapara_XeroHandler.xeroBrandingConfig.get(inv.Account__r.BillingCountry);
        else if(Hapara_XeroHandler.xeroBrandingConfig.containsKey('Other'))
            result = Hapara_XeroHandler.xeroBrandingConfig.get('Other');
            
        system.debug('****createInvoice inv.Account__r.CurrencyIsoCode' + inv.Account__r.BillingCountry 
            + ' branding theme=' + result);
        xinv.brandingThemeID = result;
        
        return xinv;
        
    }
    
    private static  sfxero.XeroPayment createPayment(Hapara_Invoice__c inv,HaparaInvoicePayment__c payment ){
        system.debug('****createPayment started');
        sfxero.XeroInvoice xinv = new sfxero.XeroInvoice();
        xinv.invoiceId = inv.Xero_Id__c;
        
        sfxero.XeroPayment xpay = new sfxero.XeroPayment();
        if(payment.Xero_Payment_Id__c != null)
            xpay.paymentId = payment.Xero_Payment_Id__c;
        xpay.paymentDate = payment.Date_Of_Payment__c;
        //xpay.paymentType = 'ACCRECPAYMENT';
        //xpay.Status= 'AUTHORISED';
        xpay.reference = payment.Payment_Check_No_Ref__c;
        xpay.amount = payment.Amount_Paid__c;
        xpay.currencyRate = payment.Currency_Rate__c;
        
        sfxero.XeroAccount acc = new sfxero.XeroAccount();
        
        acc.accountID  = Hapara_XeroHandler.xeroBankAccountConfig.get(payment.Payment_Account_Code__c);
            
        //acc.AccountType = sfxero.XeroAccount.AccountType.BANK;
        xpay.acc = acc;
        
        xpay.inv = xinv;
        return xpay;
    }
    
    private static void addInvoiceLineInvoice(Account_Products__c line, sfxero.XeroInvoice xinv){
        system.debug('****addInvoiceLineInvoice started');
        sfxero.XeroLineItem xline = new sfxero.XeroLineItem();
        xline.quantity = line.Quantity__c;
        xline.unitAmount=line.Unit_Price__c;
       // xline.accountCode='4000';
        xline.itemCode = Hapara_XeroHandler.getXeroProductCode(line.Product__c);
        xline.description = line.Description__c;
        xline.discountRate = line.Discount__c;
        xinv.addLineItem(xline); 
    }
    
    public static map<string,string> xeroBrandingConfig = new map<string,string>();
    
    //@future(callout=true)
    public static void getXeroInvoiceBrandingThemes(){
        
        system.debug('****getXeroInvoiceBrandingThemes started');
        if(xeroBrandingConfig.size() == 0){
            string configStr = haparaSetting.BrandingTheme_Config__c;
            list<string> brandingConfig = configStr.split(';');
            for(string s : brandingConfig){
                list<string> config = s.split(':');
                xeroBrandingConfig.put(config[0], config[1]);
                system.debug('****getXeroInvoiceBrandingThemes put: ' +config[0] +',' + config[1]);
            }
        }
    }
    
    public static map<string,string> xeroBankAccountConfig = new map<string,string>();
    
    //@future(callout=true)
    public static void getXeroBankAccount(){
        
        system.debug('****getXeroBankAccount started');
        if(xeroBankAccountConfig.size() == 0){
            list<Payment_Account_Code__c> codes = [Select Id,Xero_Account_ID__c from Payment_Account_Code__c ] ;
            for(Payment_Account_Code__c code : codes){
            	xeroBankAccountConfig.put(code.Id,code.Xero_Account_ID__c);
            }
        }
    }
    
    
    static map<Id,Product2> xeroProductCodes = null;
    
    private static String getXeroProductCode(Id productId){
        string result ;
        Hapara_XeroHandler.populateXeroProductCodes();  
        if(xeroProductCodes.containsKey(productId)){
            Product2 pro2 =xeroProductCodes.get(productId);
            result = pro2.Xero_Product_Code__c;
        }
        else
            throw new HaparaException('getXeroProductCode: Cannot find xero product code for this product: ' 
                        + productId);
        return result;
        
    }
    
    private static void populateXeroProductCodes(){
        
        if(xeroProductCodes == null){
            system.debug('****populateXeroProductCodes started...');
            xeroProductCodes =  new map<Id, Product2>();
            list<Product2> prods = [Select r.Xero_Product_Code__c, r.Reseller_Product_Code_del__c, r.Reseller_Account_del__c, 
                            r.Id ,r.Description, r.family,r.Subscription_Period__c,r.Subscription_Type__c
                            From Product2 r where Xero_Product_Code__c != null
                            ];
            for(Product2 prod : prods){
                xeroProductCodes.put( prod.Id, prod);
            }
        
        }   
    }
    
    static map<string, string> mapping = new map<string,string>{
            'CHR Users - GBP'=>'RC',
            'CHR Users - NZD'=>'RC',
            'CHR Users - USD'=>'RC',
            'GOOGLE APP - GBP'=>'GOOG TD CHR',
            'GOOGLE APP - USD'=>'GOOG TD CHR',
            'Prof Dev'=>'PD',
            'RTI - USD'=>'RTI',
            'SIS Integration'=>'SIS Int One',
            'TD - GBP'=>'TD',
            'TD - NZD'=>'TD',
            'TD - USD'=>'TD',
            'TD CEOSYD 3Y AUD'=>'TD',
            'TD CHR - GBP'=>'TD',
            'TD CHR - NZD'=>'TD',
            'TD CHR - USD'=>'TD'
        };
    private static Product2 getMappedXeroProductCode(string code){
        Product2 result = null;
        populateXeroProductCodes();
        system.debug('****getMappedXeroProductCode gettin product to : ' + code);
        for(Id prodId : xeroProductCodes.keySet()){
            Product2 pro = xeroProductCodes.get(prodId);
            if(code.toLowerCase() ==  pro.Xero_Product_Code__c.toLowerCase()){
                result = pro;
                break;
            }
        }
        if(result == null){                 
            if(mapping.containsKey(code)){
                string temp = mapping.get(code);
                system.debug('****getMappedXeroProductCode mapping product to : '+temp);
                for(Id prodId : xeroProductCodes.keySet()){
                    Product2 pro = xeroProductCodes.get(prodId);
                    if(temp.toLowerCase() == pro.Xero_Product_Code__c.toLowerCase()){
                        result = pro;
                        break;
                    }
                }
            }
        }
        return result;
    }
        
    public static void process(List<Id> messageIds) {
        Hapara_XeroHandler handler = new Hapara_XeroHandler();
        handler.initialise(messageIds,'Updating to Xero');
        Hapara_XeroHandler.processRecords(messageIds,handler.consumerKey,handler.certificate);
    }
    
    public static void processCancelInvoice(Id invId) {
        Hapara_XeroHandler handler = new Hapara_XeroHandler();
        List<Id> messageIds = new list<Id> ();
        messageIds.add(invId);
        handler.initialise(messageIds,'Updating to Xero');
        Hapara_XeroHandler.processCancelInvoice(invId,handler.consumerKey,handler.certificate);
    }
    
    public static void processInvoicePDF(List<Id> messageIds) {
        Hapara_XeroHandler handler = new Hapara_XeroHandler();
        handler.initialise(messageIds,'Generating Invoice PDF');
        Hapara_XeroHandler.processPDF(messageIds,handler.consumerKey,handler.certificate);
    }
    
    public static void processInvoicePayment(List<Id> messageIds) {
        Hapara_XeroHandler handler = new Hapara_XeroHandler();
        handler.initialisePayment(messageIds,'Updating to Xero');
        Hapara_XeroHandler.processPaymentIntoXero(messageIds,handler.consumerKey,handler.certificate);
    }
    
    @future(callout=true)
    public static void processPaymentIntoXero(list<Id> messageIds, string consumerKey,string certificate ){
        system.debug('****processPaymentIntoXero started');
        list<HaparaInvoicePayment__c> objs = [Select h.Xero_Payment_Id__c, h.Status__c, h.Payment_Check_No_Ref__c, 
                h.Invoice__r.Xero_Id__c,h.Invoice__r.Name,h.Invoice__r.Id,h.Invoice__r.Status__c,
                 h.Invoice__c, h.Id, h.Payment_Account_Code__c,
                h.Date_Of_Payment__c, h.Amount_Paid__c,
                Account__r.BillingCountry ,h.Currency_Rate__c
                From HaparaInvoicePayment__c h
             WHERE h.Id = :messageIds and h.Status__c!=:HAPARA_CONST.INVOICE_STATUS_ERRORED 
             and  h.Invoice__r.Xero_Id__c != null and h.Xero_Payment_Id__c =null
        ];
        system.debug('****processPaymentIntoXero Initialising values');
        xc = new sfXero.XeroCredentials(consumerKey, '', certificate);
        Hapara_XeroHandler.getXeroBankAccount();
            
        system.debug('****processPaymentIntoXero started procesing payments');
        sfxero.XeroPaymentResponse xir;
        string xmlResponse;
        string xmlMessage;
        list<Hapara_Invoice__c> invs = new list<Hapara_Invoice__c>();
        list<Id> invoiceIds = new list<Id>();
        for(HaparaInvoicePayment__c pay :objs){
            try {   
                try{
                    sfxero.XeroPayment xpay = createPayment(pay.Invoice__r,pay);
                    list<sfxero.XeroPayment> ls = new list<sfxero.XeroPayment>();
                    ls.add(xpay);
                    if(Test.isRunningTest()){
                        xir = new sfxero.XeroPaymentResponse();
                        xir.status = 'OK';
                        list<sfxero.XeroPayment> test = new list<sfxero.XeroPayment>();
                        test.add(new sfxero.XeroPayment());
                        xir.payments = test;
                    }
                    else
                        xir = sfxero.XeroAPI.putPayments( xc,ls);       
                    system.debug('****processPaymentIntoXero status:' +xir.status);
                    if(xir.status != 'OK'){                     
                        xmlResponse = xir.xmlResponse;
                        xmlMessage = xir.httpResponseMessage;
                        
                        pay.Status__c = HAPARA_CONST.INVOICE_STATUS_ERRORED;
                        Hapara_XeroHandler.sendXeroAdministratorEmail(xmlResponse, pay.Invoice__r );
                        pay.Error_Message__c ='postXeroInvoice ERROR :'+ xmlMessage;
                        pay.HTTP_Response__c = xmlResponse;
                    }else{
                        sfxero.XeroPayment xppay = xir.payments[0];
                        pay.Status__c = HAPARA_CONST.INVOICE_STATUS_UPDATED_TO_XERO;
                        pay.Error_Message__c ='';
                        pay.Xero_Payment_Id__c = xppay.paymentId;   
                        Hapara_Invoice__c inv = pay.Invoice__r;
                        inv.Status__c = HAPARA_CONST.INVOICE_STATUS_PAID;
                        invs.add(inv); 
                        invoiceIds.add(inv.Id) ;  
                    }
                }catch(System.CalloutException e){
                    system.debug('****postXeroInvoice Errored:' + e.getMessage() + '\n\n//-- Stack Trace --//\n' + e.getStackTraceString());
                    if(!Test.isRunningTest())
                        throw new HaparaException('postXeroInvoice Errored:' + e.getMessage() + '\n\n//-- Stack Trace --//\n' + e.getStackTraceString());
                }
            } catch (Exception e) {
                System.debug('****processRecords ERROR:'+e);
                pay.Status__c = HAPARA_CONST.INVOICE_STATUS_ERRORED;
                pay.Error_Message__c ='processRecords ERROR :'+ e;
            }
        }
        
        
        update objs;
        update invs;    
    }
    
    @future(callout=true)
    public static void processPDF(list<Id> messageIds, string consumerKey,string certificate ){
        system.debug('****processPDF started');
        list<Hapara_Invoice__c> objs = [
            Select h.Xero_Invoice_No__c, h.SystemModstamp, h.Status__c, h.Reseller_PO__c, h.Reseller_PO_Received_Date__c, 
            h.Reseller_Account__c, h.Process__c, h.Paid_Date__c, h.OwnerId, h.Name, h.LastModifiedDate, h.LastModifiedById, h.IsDeleted, 
            h.Invoice_Date__c, h.Id, h.HTTP_Response__c, h.Error_Message__c, h.Due_Date__c, h.Customer_PO__c, h.Customer_PO_Received_Date__c, 
            h.CurrencyIsoCode, h.CreatedDate, h.CreatedById, h.Case_Subject__c, h.Xero_Id__c,
            h.Account__r.Invoice_Contact__c, h.Account__r.CurrencyIsoCode, h.Account__r.Website, h.Account__r.BillingCountry, 
            h.Account__r.BillingPostalCode, h.Account__r.BillingState, h.Account__r.BillingCity, h.Account__r.BillingStreet, 
            h.Account__r.Name, h.Account__c, h.Account__r.Xero_Id__c
            From Hapara_Invoice__c h
             WHERE h.Id = :messageIds and h.Status__c!=:HAPARA_CONST.INVOICE_STATUS_ERRORED and h.Xero_Id__c!= null
        ];
        xc = new sfXero.XeroCredentials(consumerKey, '', certificate);
        map<Id,blob> attachments = new map<Id,blob>();
        list<Attachment> attachlist = new list<Attachment>();
        list<Document> docs = new list<Document>();
        sfxero.XeroInvoicePDFResponse xir;
        for(Hapara_Invoice__c inv : objs){
            try{
                try{
                    if(Test.isRunningTest()){
                        xir = new sfxero.XeroInvoicePDFResponse();
                        xir.invoicePDF = Blob.valueOf('test');
                    }else
                        xir = sfxero.XeroAPI.getInvoiceAsPDF(xc,inv.Xero_Id__c);
                     if(xir.errorMessage != null){                          
                        inv.Status__c = HAPARA_CONST.INVOICE_STATUS_ERRORED;
                        Hapara_XeroHandler.sendXeroAdministratorEmail(xir.httpResponseMessage, inv );
                        inv.Error_Message__c ='processPDF ERROR :'+ xir.errorMessage;
                        inv.HTTP_Response__c = xir.httpResponseMessage;
                    }else{
                        
                        inv.Status__c = HAPARA_CONST.INVOICE_STATUS_RETRIEVED_INVOICE;
                        attachments.put(inv.Id,  xir.invoicePDF);                       
                    }
                }catch(System.CalloutException e){
                    system.debug('****processPDF Errored:' + e.getMessage() + '\n\n//-- Stack Trace --//\n' + e.getStackTraceString());
                    if(!Test.isRunningTest())
                        throw new HaparaException('processPDF Errored:' + e.getMessage() + '\n\n//-- Stack Trace --//\n' + e.getStackTraceString());
                }       
             } catch (Exception e) {
                System.debug('****processPDF ERROR:'+ e.getMessage() + '\n\n//-- Stack Trace --//\n' + e.getStackTraceString());
                inv.Status__c = HAPARA_CONST.INVOICE_STATUS_ERRORED;
                inv.Error_Message__c ='processPDF ERROR :'+  e.getMessage() + '\n\n//-- Stack Trace --//\n' + e.getStackTraceString();
            }   
        }
        
       
        for(Hapara_Invoice__c inv:objs){
            string InvoiceDateValue = inv.Xero_Invoice_No__c+'-'+ Date.today().year()+Date.today().month()+Date.today().day();
            string accountName = inv.Account__r.Name;
            
            accountName = Hapara_UtilityCommonRecordAccess.stripInvalidCharacter(accountName);
            system.debug('****processPDF: accountName= '+ accountName);
            integer length = accountName.length() >20? 20 : accountName.length(); 
            string filename = accountName.substring(0, length)  +' - ' +InvoiceDateValue+ '.pdf';
          	system.debug('****processPDF: filename= '+ filename);	
            inv.Invoice_Attachment_Name__c = filename;
            blob pdf = attachments.get(inv.Id);
           // Hapara_XeroHandler.SendContactInvoiceEmail(inv.Account__r.Invoice_Contact__c, inv, pdf, filename);
            Attachment attach = new Attachment();
            attach.ParentId= inv.Id;
            attach.Body =pdf;
            attach.Name = filename;
            attach.IsPrivate = false;
            attach.OwnerId = inv.OwnerId;
            attachlist.add(attach);
            Document doc = new Document();
            doc.Name = filename;
            doc.IsInternalUseOnly=true;
            doc.Body = pdf;
            doc.ContentType = 'application/pdf';
			doc.Type = 'pdf';
			doc.AuthorId = inv.OwnerId;
			doc.FolderId = inv.OwnerId;
            docs.add(doc);
        }
        update objs;
        insert attachlist;
        insert docs;
    }
    
    public static void processRetrieveFromXero(List<Id> messageIds) {
        Hapara_XeroHandler handler = new Hapara_XeroHandler();
        handler.initialise(messageIds,'Updating to Xero');
        Hapara_XeroHandler.getXeroInvoices(messageIds,handler.consumerKey,handler.certificate);
    }
    
    @future(callout=true)
    public static void getXeroInvoices(list<Id> messageIds, string consumerKey,string certificate ){
        system.debug('****getXeroInvoices started');
        list<Hapara_Invoice__c> objs = [
            Select h.Xero_Invoice_No__c, h.SystemModstamp, h.Status__c, h.Reseller_PO__c, h.Reseller_PO_Received_Date__c, 
            h.Reseller_Account__c, h.Process__c, h.Paid_Date__c, h.OwnerId, h.Name, h.LastModifiedDate, h.LastModifiedById, h.IsDeleted, 
            h.Invoice_Date__c, h.Id, h.HTTP_Response__c, h.Error_Message__c, h.Due_Date__c, h.Customer_PO__c, h.Customer_PO_Received_Date__c, 
            h.CurrencyIsoCode, h.CreatedDate, h.CreatedById, h.Case_Subject__c, h.Xero_Id__c,
            h.Account__r.Invoice_Contact__c, h.Account__r.CurrencyIsoCode, h.Account__r.Website, h.Account__r.BillingCountry, 
            h.Account__r.BillingPostalCode, h.Account__r.BillingState, h.Account__r.BillingCity, h.Account__r.BillingStreet, 
            h.Account__r.Name, h.Account__c, h.Account__r.Xero_Id__c,
            (Select Product__c From Purchased_Products__r)
            From Hapara_Invoice__c h
             WHERE h.Id = :messageIds and h.Status__c!=:HAPARA_CONST.INVOICE_STATUS_ERRORED
        ];
        xc = new sfXero.XeroCredentials(consumerKey, '', certificate);
        sfxero.XeroInvoiceResponse xir;
        list<Account> tobeUpdateAccount = new list<Account>();
        list<Account_Products__c> insertPurchaseProducts = new list<Account_Products__c>();
        list<Account_Products__c> updatePurchaseProducts = new list<Account_Products__c>();
        
        for(Hapara_Invoice__c inv : objs){
            try{
                try{
                    if(Test.isRunningTest()){
                        xir = new sfxero.XeroInvoiceResponse();
                        xir.status = 'OK';
                        list<sfxero.XeroInvoice> test = new list<sfxero.XeroInvoice>();
                        sfxero.XeroInvoice xinv2 = new sfxero.XeroInvoice();
                        xinv2.contact = new sfxero.XeroContact();
                        sfxero.XeroLineItem line2 = new sfxero.XeroLineItem();
                        line2.itemCode = 'TD - USD';
                        line2.quantity = 1;
                        line2.unitAmount = 4.0;
                        line2.description='test';
                        list<sfxero.XeroLineItem> lines = new list<sfxero.XeroLineItem>();
                        lines.add(line2);
                        xinv2.lineItems = lines;
                        test.add(xinv2);
                        xir.invoices = test;
                    }else{
                        system.debug('****getXeroInvoices getting invoice: ' +inv.Xero_Id__c+','+ inv.Xero_Invoice_No__c);
                        if(!string.isBlank(inv.Xero_Id__c)){
                            xir = sfxero.XeroAPI.getInvoiceById(xc,inv.Xero_Id__c);
                        }else{
                            xir = sfxero.XeroAPI.getInvoiceByNumber(xc,inv.Xero_Invoice_No__c);
                        }
                    }
                    
                     if(xir.status != 'OK'){
                        string xmlResponse = xir.xmlResponse;
                        string xmlMessage = xir.httpResponseMessage;
                        
                        inv.Status__c = HAPARA_CONST.INVOICE_STATUS_ERRORED;
                        Hapara_XeroHandler.sendXeroAdministratorEmail(xmlResponse, inv );
                        inv.Error_Message__c ='getXeroInvoices ERROR :'+ xmlMessage;
                        inv.HTTP_Response__c = xmlResponse;
                    }else{
                        system.debug('****getXeroInvoices retrieved invoice: ' + xir.invoices.size());
                        sfxero.XeroInvoice xpinv = xir.invoices[0];
                        inv.Status__c = HAPARA_CONST.INVOICE_STATUS_UPDATED_TO_XERO;
                        inv.Error_Message__c ='';
                        inv.Xero_Invoice_No__c = xpinv.invoiceNumber;
                        inv.Xero_Id__c = xpinv.invoiceId;
                        inv.Total_Amount__c =xpinv.total;
                        inv.Invoice_Date__c = xpinv.issuedDate;
                        inv.Due_Date__c=xpinv.DueDate;
                        inv.Status__c = HAPARA_CONST.INVOICE_STATUS_SENT_INVOICE;
                      //  inv.HTTP_Response__c = xir.xmlResponse;
                        inv.Customer_PO__c = xpinv.reference;
                        if(inv.Account__r.Xero_Id__c == null){
                            system.debug('****getXeroInvoices updating account');
                            Account acc = inv.Account__r;
                            acc.Xero_Id__c =xpinv.contact.contactId ;
                            if(acc.Payment_Date__c == null && !string.isEmpty(acc.Current_Invoice_No__c)){
                                acc.Current_Invoice_No__c = acc.Current_Invoice_No__c + ',' +   xpinv.invoiceNumber;
                            }else{
                                acc.Current_Invoice_No__c = xpinv.invoiceNumber;
                                acc.Payment_Date__c = null;
                            }
                            acc.TD_Invoice_Due_Date__c = xpinv.DueDate;
                            acc.TD_Invoiced_Date__c = xpinv.issuedDate;
                            tobeUpdateAccount.add(acc);
                        }   
                       
                        if(inv.Purchased_Products__r != null)
                            for(Account_Products__c pro : inv.Purchased_Products__r){                               
                                updatePurchaseProducts.add(pro);                                
                            }
                        system.debug('****getXeroInvoices size of xero invoice line: ' + xpinv.lineItems.size());
                        for(sfxero.XeroLineItem xline : xpinv.lineItems)    {
                            system.debug('****getXeroInvoices adding xero lines: ' + xline.itemCode + ',' + xline.description);
                            if( xline.itemCode!=null){
                                Product2 pro3 = Hapara_XeroHandler.getMappedXeroProductCode(xline.itemCode);
                                system.debug('****getXeroInvoices mapped: ' + pro3.Xero_Product_Code__c);
                                Account_Products__c line = new Account_Products__c();
                                line.Invoice_Date__c = inv.Invoice_Date__c;
                                line.Invoice_No__c = inv.Xero_Invoice_No__c;
                                line.Quantity__c = xline.quantity;
                                line.Unit_Price__c=xline.unitAmount;
                                line.Description__c =xline.description ;
                                line.Product__c= pro3.Id;
                                line.Account__c =inv.Account__c;
                                line.Hapara_Invoice__c = inv.Id;
                                line.Subscription_Start_Date__c = inv.Invoice_Date__c;
                                line.Reseller_Account__c = inv.Reseller_Account__c;
                                line.Subscription_End_Date__c = Hapara_UtilityCommonRecordAccess.CalculateProductEndSubscriptionDate(pro3, inv.Invoice_Date__c);
                                line.Product_Family__c = pro3.family;
                                line.Discount__c = xline.discountRate ;
                                line.CurrencyIsoCode = inv.CurrencyIsoCode;
                                insertPurchaseProducts.add(line);       
                            }             
                        }            
                    }
                }catch(System.CalloutException e){
                    system.debug('****getXeroInvoices Errored:' + e.getMessage() + '\n\n//-- Stack Trace --//\n' + e.getStackTraceString());
                    if(!Test.isRunningTest())
                        throw new HaparaException('getXeroInvoices Errored:' + e.getMessage() + '\n\n//-- Stack Trace --//\n' + e.getStackTraceString());
                }       
             } catch (Exception e) {
                System.debug('****getXeroInvoices ERROR:'+ e.getMessage() + '\n\n//-- Stack Trace --//\n' + e.getStackTraceString());
                inv.Status__c = HAPARA_CONST.INVOICE_STATUS_ERRORED;
                inv.Error_Message__c ='getXeroInvoices ERROR :'+ e.getMessage() + '\n\n//-- Stack Trace --//\n' + e.getStackTraceString();
            }   
        }
        

        update objs;
    
        if(tobeUpdateAccount.size()>0)
            update tobeUpdateAccount;
        
        if(updatePurchaseProducts.size()>0)
            delete updatePurchaseProducts;
        
        if(insertPurchaseProducts.size()>0)
            insert insertPurchaseProducts;
        
    }
    
    
    
    public static Boolean SendContactInvoiceEmail(Id recipient, Hapara_Invoice__c inv, Blob pdf,string filename){
        Boolean result = true;
        try{
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            mail.setWhatId(inv.Id);
             
            EmailTemplate et = [SELECT id FROM EmailTemplate WHERE developerName ='HaparaInvoice_Send_invoice_to_Customer'];
             
            mail.setSenderDisplayName('Hapara');
            mail.setReplyTo('customeraccounts@hapara.com');
             
            mail.setTargetObjectId(recipient); // Specify who the email should be sent to.
            mail.setTemplateId(et.id);
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(filename);
            efa.setBody(pdf);   
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
         
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        }catch(Exception e){
            System.debug('SendContactInvoiceEmail Error: ' + e);
            result = false;
        }
        return result;
    }
    
    public static Boolean SendContactInvoiceRelatedEmail(Contact recipient,String templateName, Hapara_Invoice__c relatedInvoice){
        Boolean result = true;
        try{
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            mail.setWhatId(relatedInvoice.Id);
             
            EmailTemplate et = [SELECT id FROM EmailTemplate WHERE developerName =:templateName];
             
            mail.setSenderDisplayName('Hapara');
            mail.setReplyTo('customeraccounts@hapara.com');
             
            mail.setTargetObjectId(recipient.id); // Specify who the email should be sent to.
            mail.setTemplateId(et.id);
         
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        }catch(Exception e){
            System.debug('SendContactInvoiceEmail Error: ' + e);
            result = false;
        }
        return result;
    }
    
    
}