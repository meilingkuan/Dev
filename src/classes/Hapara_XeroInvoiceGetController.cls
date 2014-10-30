public with sharing class Hapara_XeroInvoiceGetController {
	private ApexPages.StandardController singlecontroller;
	private Hapara_Invoice__c currentRecord;
	private final PageReference fromPage;
	
	string processStatus = 'processing';
	public String getProcessStatus(){
		return processStatus;
	}
	string canProcess = 'false';
	public String getCanProcess(){
		return canProcess;
	}
	
	public Hapara_XeroInvoiceGetController(ApexPages.StandardController controller) { 		
		singlecontroller =controller; 	
		
		currentRecord = [Select h.Xero_Invoice_No__c, h.SystemModstamp, h.Status__c, h.Reseller_PO__c, h.Reseller_PO_Received_Date__c, 
			h.Reseller_Account__c, h.Process__c, h.Paid_Date__c, h.OwnerId, h.Name, h.LastModifiedDate, h.LastModifiedById, h.IsDeleted, 
			h.Invoice_Date__c, h.Id, h.HTTP_Response__c, h.Error_Message__c, h.Due_Date__c, h.Customer_PO__c, h.Customer_PO_Received_Date__c, 
			h.CurrencyIsoCode, h.CreatedDate, h.CreatedById, h.Case_Subject__c, h.Xero_Id__c,
			h.Account__r.Invoice_Contact__c, h.Account__r.CurrencyIsoCode, h.Account__r.Website, h.Account__r.BillingCountry, 
			h.Account__r.BillingPostalCode, h.Account__r.BillingState, h.Account__r.BillingCity, h.Account__r.BillingStreet, 
			h.Account__r.Name, h.Account__c, h.Account__r.Xero_Id__c
			From Hapara_Invoice__c h
			 WHERE h.Id = :controller.getRecord().Id];
			 
		fromPage = singlecontroller.cancel();
		if(currentRecord.Xero_Id__c == null && currentRecord.Xero_Invoice_No__c == null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Cannot retrieve from Xero because invoice number or xero id are not provided.'));
		}else{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, 'Click on the Retrieve button to proces.'));
			canProcess = 'true';
		}
 	}
	
	public PageReference cancel() {
        return fromPage;
    }
    
     public PageReference reloadResult(){
	   	string id = ApexPages.currentPage().getParameters().get('id');
	   	currentRecord = [Select h.Xero_Invoice_No__c, h.SystemModstamp, h.Status__c, h.Reseller_PO__c, h.Reseller_PO_Received_Date__c, 
			h.Reseller_Account__c, h.Process__c, h.Paid_Date__c, h.OwnerId, h.Name, h.LastModifiedDate, h.LastModifiedById, h.IsDeleted, 
			h.Invoice_Date__c, h.Id, h.HTTP_Response__c, h.Error_Message__c, h.Due_Date__c, h.Customer_PO__c, h.Customer_PO_Received_Date__c, 
			h.CurrencyIsoCode, h.CreatedDate, h.CreatedById, h.Case_Subject__c, h.Xero_Id__c,
			h.Account__r.Invoice_Contact__c, h.Account__r.CurrencyIsoCode, h.Account__r.Website, h.Account__r.BillingCountry, 
			h.Account__r.BillingPostalCode, h.Account__r.BillingState, h.Account__r.BillingCity, h.Account__r.BillingStreet, 
			h.Account__r.Name, h.Account__c, h.Account__r.Xero_Id__c
			From Hapara_Invoice__c h
			 WHERE h.Id = :singlecontroller.getRecord().Id];
		if(CurrentRecord.Status__c =='Sent Invoice to Customer' ||CurrentRecord.Status__c =='Errored'  )
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info,CurrentRecord.Status__c +(CurrentRecord.Status__c =='Errored'?': ' + CurrentRecord.Error_Message__c:'') ));
		else
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Warning, 'Retrieving Invoice from Xero now.. please wait.'));
		processStatus ='done';
		return null; 
   	}
   	
   	public PageReference retrieveInvoice(){
   		try{
   			list<Id> ids = new list<id>();
   			ids.add(currentRecord.Id);
   			Hapara_XeroHandler.processRetrieveFromXero(ids);
   		}catch(Exception e){   			
   			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Errored: ' + e));
   		}
   		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Warning, 'Retrieving Invoice from Xero now.. please wait.'));
   		canProcess = 'false';
   		return ApexPages.currentPage(); 
   	}
}