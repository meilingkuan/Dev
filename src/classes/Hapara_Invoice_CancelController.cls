public with sharing class Hapara_Invoice_CancelController {
	private ApexPages.StandardController singlecontroller;
	private Id invId;
	private Hapara_Invoice__c inv;
	private final PageReference fromPage;
	private String currentStep = '1';  
	
	 public String getStep() {
		return currentStep;
	}
	
	private boolean isRefresh = false;
	public boolean getTurnOnRefresh(){
		return isRefresh;
	}
	
	private boolean canCancel = true;
	public boolean getDisableCancel(){
		return canCancel? false:true;
	}
	
	public Hapara_Invoice_CancelController(ApexPages.StandardController controller) { 		
		invId =  ApexPages.currentPage().getParameters().get('Id');	
		singlecontroller =controller; 	
		fromPage = controller.cancel();
		getInvoice();
	//	if(string.isEmpty(inv.Xero_Id__c)){
		//	ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 
			//	'Cannot cancel this invoice as it has not been synched to Xero. Please delete the invoice if you do not wish to synch the invoice.'));
			//canCancel = false;
		//}
		
 	}
 	
 	public Hapara_Invoice__c getInvoice(){
 		if(inv == null){
 			inv = [Select h.Xero_Invoice_No__c, h.SystemModstamp, h.Status__c, h.Reseller_PO__c, h.Reseller_PO_Received_Date__c, 
				h.Reseller_Account__c, h.Process__c, h.Paid_Date__c, h.OwnerId, h.Name, h.LastModifiedDate, h.LastModifiedById, h.IsDeleted, 
				h.Invoice_Date__c, h.Id, h.HTTP_Response__c, h.Error_Message__c, h.Due_Date__c, h.Customer_PO__c, h.Customer_PO_Received_Date__c,
				h.Cancelled_Reason__c, h.CurrencyIsoCode, h.CreatedDate, h.CreatedById, h.Case_Subject__c, h.Xero_Id__c,
				h.Opportunity_Lost_Stage__c,
				h.Account__r.Invoice_Contact__c, h.Account__r.CurrencyIsoCode, h.Account__r.Website, h.Account__r.BillingCountry, 
				h.Account__r.BillingPostalCode, h.Account__r.BillingState, h.Account__r.BillingCity, h.Account__r.BillingStreet, 
				h.Account__r.Name, h.Account__c, h.Account__r.Xero_Id__c,
				h.Reseller_Account__r.Xero_Id__c,  h.Reseller_Account__r.BillingCountry, 
				h.Reseller_Account__r.BillingPostalCode, h.Reseller_Account__r.BillingState, h.Reseller_Account__r.BillingCity,
				 h.Reseller_Account__r.BillingStreet, 
				h.Reseller_Account__r.CurrencyIsoCode,h.Reseller_Account__r.Website,h.Reseller_Account__r.Name,
				(Select Id, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, 
	            Product__c,Description__c, Account__c, Quantity__c, Discount__c, Invoice_Date__c, Invoice_No__c, Unit_Price__c, Amount__c, 
	            Hapara_Invoice__c, Subscription_Start_Date__c, Subscription_End_Date__c, Product_Family__c 
	            From Purchased_Products__r ),
	            (Select RecordTypeId, StageName, IsClosed,Hapara_Invoice__c From Opportunities__r )
				 From Hapara_Invoice__c h
				WHERE h.Id = :invId ];
 		}
 		return inv;
 	}
 	
 	public PageReference Process(){

   		try{
   			
   			if(!string.isEmpty(inv.Xero_Id__c) && inv.Status__c != HAPARA_CONST.INVOICE_STATUS_PAID && inv.Status__c != HAPARA_CONST.INVOICE_STATUS_PARTPAID){
   				inv.Status__c = HAPARA_CONST.INVOICE_STATUS_UPDATING_TO_XERO;
   				inv.Cancelled_Reason__c = date.today().format() + '-' + 	inv.Cancelled_Reason__c ;
   				update inv;
   				Hapara_XeroHandler.processCancelInvoice(invId);
   				ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Warning, 'The following invoices are being processed to Xero please have a look at status and the error messages.'));
   			}else if(inv.Status__c != HAPARA_CONST.INVOICE_STATUS_PAID && inv.Status__c != HAPARA_CONST.INVOICE_STATUS_PARTPAID){
   				inv.Status__c = HAPARA_CONST.INVOICE_STATUS_CANCELLED;
	   			inv.Cancelled_Reason__c = date.today().format() + '-' + 	inv.Cancelled_Reason__c ;
	   			update inv;
	   			Hapara_XeroHandler.lockCancelledInvoice(inv);
   			}
   			else{
   				inv.Status__c = HAPARA_CONST.INVOICE_STATUS_CANCELLED;
	   			inv.Cancelled_Reason__c = date.today().format() + '-' + 	inv.Cancelled_Reason__c ;
	   			update inv;
   				for(Account_Products__c line: inv.Purchased_Products__r){
	        		line.Status__c =  HAPARA_CONST.INVOICE_STATUS_CANCELLED;
	        		line.Invoice_Date__c = null;
	        	}
	        	//update opportunity to lost
	        	for(Opportunity o : inv.Opportunities__r){
	        		if(o.StageName == HAPARA_CONST.OPPORTUNITY_STATGE_PROCESSINGPO){
		            	o.StageName = HAPARA_CONST.OPPORTUNITY_STATGE_PENDINGPO;
	        		}else
	        			o.StageName =HAPARA_CONST.OPPORTUNITY_STAGE_INVOICING;
		           	o.Hapara_Invoice__c = null;
		        }
	       
		        update inv.Purchased_Products__r;
		       	update inv.Opportunities__r;
		       	ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, 'The invoice has been cancelled.'));
   			}
   		}catch(Exception e){   			
   			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Errored: ' + e));
   		}
   		
   		currentStep = '2';
   		isRefresh = true;
   		return ApexPages.currentPage(); 
   }
 	
 	public PageReference cancel() {
        return fromPage;
    }
    
     
   public PageReference reloadResult(){
   		inv = [Select h.Xero_Invoice_No__c, h.Status__c, h.Reseller_PO__c, h.Invoice_Date__c, 
			h.Customer_PO__c, h.CurrencyIsoCode, h.Account__r.BillingCountry,
			 h.Account__r.BillingPostalCode, h.Account__r.BillingState, h.Account__r.BillingCity, 
			 h.Account__r.BillingStreet, h.Account__r.Name, h.Account__c,h.Name,h.Error_Message__c ,
			 h.LastModifiedDate
			 From Hapara_Invoice__c h
			WHERE h.Id = :invId];

		if( inv.status__c == HAPARA_CONST.INVOICE_STATUS_CANCELLED){
   			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 
   				'Invoices should be processed successfully. See the status and error message columns to confirm processing.'));
		}else{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Warning, 
   				'Invoices still processing.....'));
		}
   		return null; 
   }
}