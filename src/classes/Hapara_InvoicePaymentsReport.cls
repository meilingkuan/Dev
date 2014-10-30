@isTest(SeeAllData=true)
public with sharing class Hapara_InvoicePaymentsReport {
	public Hapara_InvoicePaymentsReport(){}
	
	
	private list<HaparaInvoicePayment__c>  payments;
	
	public string invoiceId {get;set;}
	public string accountId{get;set;}
	
	public Hapara_Invoice__c invoice;
	
	public Hapara_Invoice__c getInvoice(){
		if(invoice == null  && !string.isEmpty(invoiceId))
			invoice = [select 
			h.Invoice_To_Contact__c, h.Invoice_To_Contact__r.firstname, h.Invoice_To_Contact__r.lastname, 
			h.Invoice_To_Contact__r.email,
			h.Total_Paid_Amount__c,h.Last_Paid_Date__c,h.Total_Amount__c,h.Xero_Invoice_No__c,
			h.Invoice_Date__c, h.Due_Date__c,
			h.Account__r.Name,h.Account__r.BillingStreet, h.Account__r.BillingState, h.Account__r.BillingPostalCode, 
			h.Account__r.BillingCountry, h.Account__r.BillingCity 	
			 from Hapara_Invoice__c h where h.Id =: invoiceId];
			 
		return invoice;
	}
	
	public Account account;
	public Account getAccount(){
		if(account == null)
			if(getInvoice() != null)
				account = getInvoice().Account__r; 
			else if(!string.isEmpty(accountId )){
				account = [Select h.Name,h.BillingStreet, h.BillingState, h.BillingPostalCode, 
				h.BillingCountry, h.BillingCity from Account h where h.id =: accountId];
			}
		
		return account;
	}
	
	public string getAccountBillingAddress(){
		string address = '';
		if(getAccount() != null){
			address = account.BillingStreet 
				+ (String.isBlank(account.BillingCity)?'': '<br/>' +  account.BillingCity)
				+( String.isBlank(account.BillingState)?'': '<br/>' +  account.BillingState + ' ' + account.BillingPostalCode)
				+(String.isBlank( account.BillingCountry)?'': '<br/>' +  account.BillingCountry)
				;
		}
		return address;
	}
	
	public string getReportDate(){
		return datetime.newInstance( Date.today(), time.newInstance(0,0,0,0)).format('dd MMMMM yyyy');
	}
	
	public String getHaparaAddress(){
		HaparaXeroConfig__c haparaSetting = HaparaXeroConfig__c.getInstance('Hapara');
		return haparaSetting.Hapara_Address_HTML__c;
	}

	public string getOutstandingAmount(){
		if(getInvoice() == null)
			return '0';
		double amount = (getInvoice().Total_Amount__c==null?0:getInvoice().Total_Amount__c)
			- (getInvoice().Total_Paid_Amount__c==null?0:getInvoice().Total_Paid_Amount__c);
		return amount >0? amount.format(): '0';
	}
	
	public list<HaparaInvoicePayment__c> getPayments(){
		if(payments ==null && invoiceId != null ){
			payments = [Select h.Xero_Payment_Id__c, h.Status__c, h.Payment_Check_No_Ref__c, 
				h.Invoice__r.Xero_Id__c,h.Invoice__r.Name,h.Invoice__r.Id,h.Invoice__r.Status__c,
				 h.Invoice__c, h.Id, 
				h.Date_Of_Payment__c, h.Amount_Paid__c,
				Account__r.BillingCountry ,h.Currency_Rate__c
				From HaparaInvoicePayment__c h
			 WHERE h.Invoice__c = :invoiceId	];
		}
		return payments;
	}
	
	list<Account_Products__c> licenses;
	public list<Account_Products__c> getLicenses(){
		if(licenses ==null && getInvoice() != null ){
			licenses = [Select a.Unit_Price__c, a.SystemModstamp, a.Subscription_Start_Date__c, a.Subscription_End_Date__c,
			 a.Reseller_Account__c,  a.Quantity__c, a.Product_Family__c, a.Name, 
			 a.LastModifiedDate, a.LastModifiedById, a.IsDeleted, a.Invoice_No__c, a.Invoice_Date__c, a.Id, 
			 a.Discount__c, a.Description__c, a.CurrencyIsoCode, a.CreatedDate, a.CreatedById, a.Amount__c, a.Account__c,
			 a.Hapara_Invoice__r.Status__c,
			 
			 a.Product__r.Name,a.Product__c,
			 
			 a.Hapara_Invoice__r.Reseller_PO__c, a.Hapara_Invoice__r.Customer_PO__c, a.Hapara_Invoice__r.Account__c, a.Hapara_Invoice__c
			 From Account_Products__c a where  a.Hapara_Invoice__c =:getInvoice().Id 
			 and (a.Hapara_Invoice__c = null OR a.Hapara_Invoice__r.Status__c ='Paid' 
			 Or a.Hapara_Invoice__r.Status__c ='Sent Invoice to Customer')];
		}else if(licenses ==null && getAccount() != null ){
			licenses = [Select a.Unit_Price__c, a.SystemModstamp, a.Subscription_Start_Date__c, a.Subscription_End_Date__c,
			 a.Reseller_Account__c,  a.Quantity__c, a.Product_Family__c, a.Name, 
			 a.LastModifiedDate, a.LastModifiedById, a.IsDeleted, a.Invoice_No__c, a.Invoice_Date__c, a.Id, 
			 a.Discount__c, a.Description__c, a.CurrencyIsoCode, a.CreatedDate, a.CreatedById, a.Amount__c, a.Account__c,
			 a.Hapara_Invoice__r.Status__c,
			 
			 a.Product__r.Name,a.Product__c,
			 
			 a.Hapara_Invoice__r.Reseller_PO__c, a.Hapara_Invoice__r.Customer_PO__c, a.Hapara_Invoice__r.Account__c, a.Hapara_Invoice__c
			 From Account_Products__c a where  a.Hapara_Invoice__r.Account__c =:getAccount().Id 
			 and (a.Hapara_Invoice__c = null OR a.Hapara_Invoice__r.Status__c ='Paid' 
			 Or a.Hapara_Invoice__r.Status__c ='Sent Invoice to Customer')];
		}
		return licenses;
	}
	
	
	private static testmethod void selfTest() {
		Hapara_Invoice__c inv =  Hapara_XeroHandlerTest.CreateTestInvoice();
		Hapara_InvoicePaymentsReport testObj = new Hapara_InvoicePaymentsReport();
		testObj.invoiceId =	inv.Id;
		system.assert( testObj.getReportDate().length()>0);
		system.assert(testObj.getOutstandingAmount()!=null);
		system.assert(testObj.getAccount()!=null);
		system.assert(testObj.getPayments()!=null);
		system.assert(testObj.getLicenses()!=null);
		system.assert(testObj.getAccountBillingAddress()!=null);
		system.assert(testObj.getHaparaAddress() !=null);
		
	
	}
}