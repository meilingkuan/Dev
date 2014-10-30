public with sharing class Hapara_XeroController {
	list<Id> ids = new list<Id>();
	 private final ApexPages.StandardSetController cntr;
	 private  List<Hapara_Invoice__c> processInvoices;
	 private  List<Hapara_Invoice__c> sendInvoices;
	 private  List<Hapara_Invoice__c> processedInvoices = new list<Hapara_Invoice__c>();
	 private transient ApexPages.Message currentMsg;
	 private integer noOfProcess=0 ;
	 private final PageReference fromPage;
	 private String currentStep = '1'; 
	 private ApexPages.StandardController singlecontroller;
	
 	public Hapara_XeroController(ApexPages.StandardController controller) { 		
		singlecontroller =controller; 	
 	}
 	
 	public PageReference onload() {   	
        PageReference redirect = new PageReference('/apex/Hapara_ProcessInvoiceToXeroButton');
        redirect.getParameters().put('Id', singlecontroller.getId());
         if (ApexPages.currentPage().getParameters().containsKey('retUrl')) {
            redirect.getParameters().put('retUrl', ApexPages.currentPage().getParameters().get('retUrl'));
        }
        return redirect;
    }
 	
 	public PageReference onloadSendToCustomer() {   	
        PageReference redirect = new PageReference('/apex/Hapara_ProcessInvoiceXeroToCustomer');
        redirect.getParameters().put('Id', singlecontroller.getId());
         if (ApexPages.currentPage().getParameters().containsKey('retUrl')) {
            redirect.getParameters().put('retUrl', ApexPages.currentPage().getParameters().get('retUrl'));
        }
        return redirect;
    }
    
 	 public Hapara_XeroController(ApexPages.StandardSetController controller) {
       controller.setPageSize(1000);
       cntr = (ApexPages.StandardSetController)controller;
       fromPage = cntr.cancel();
       string id = ApexPages.currentPage().getParameters().get('id');
       if(id!=null){       		
       		ids.add(id);
       }else{
       		List<Hapara_Invoice__c> temp = (List<Hapara_Invoice__c>)cntr.getSelected();
       		for(Hapara_Invoice__c inv : temp){
       			ids.add(inv.Id);
       		}
       }
       list<Hapara_Invoice__c> temp2 = [Select h.Xero_Invoice_No__c, h.SystemModstamp, h.Status__c, h.Reseller_PO__c, h.Reseller_PO_Received_Date__c, 
			h.Reseller_Account__c, h.Process__c, h.Paid_Date__c, h.OwnerId, h.Name, h.LastModifiedDate, h.LastModifiedById, h.IsDeleted, 
			h.Invoice_Date__c, h.Id, h.HTTP_Response__c, h.Error_Message__c, h.Due_Date__c, h.Customer_PO__c, h.Customer_PO_Received_Date__c, 
			h.CurrencyIsoCode, h.CreatedDate, h.CreatedById, h.Case_Subject__c, h.Xero_Id__c,
			h.Account__r.Invoice_Contact__c, h.Account__r.CurrencyIsoCode, h.Account__r.Website, h.Account__r.BillingCountry, 
			h.Account__r.BillingPostalCode, h.Account__r.BillingState, h.Account__r.BillingCity, h.Account__r.BillingStreet, 
			h.Account__r.Name, h.Account__c, h.Account__r.Xero_Id__c,
			h.Reseller_Account__r.Xero_Id__c,  h.Reseller_Account__r.BillingCountry, 
			h.Reseller_Account__r.BillingPostalCode, h.Reseller_Account__r.BillingState, h.Reseller_Account__r.BillingCity, h.Reseller_Account__r.BillingStreet, 
			h.Reseller_Account__r.CurrencyIsoCode,h.Reseller_Account__r.Website,h.Reseller_Account__r.Name
			 From Hapara_Invoice__c h
			WHERE h.Id = :ids ];
       processInvoices = temp2;
       sendInvoices = temp2.deepClone();
       system.debug('****Hapara_XeroController: invoice size' + getRecordSize(temp2) );
       if (getRecordSize(temp2)<1 && id=='') {
            String msg = 'No record was selected on the list view.  Please click Cancel button and select records for Process CDW PO on.'; 
            currentMsg = new ApexPages.Message(ApexPages.severity.ERROR, msg);
       } else {
       		checkListToProcess(temp2);
       		checkListToSendInvoice(sendInvoices);
            String msg = 'Number of records selected for processing: ' + noOfProcess+' out of ' + getRecordSize(temp2); 
            currentMsg = new ApexPages.Message(ApexPages.severity.INFO, msg);
       }
       ApexPages.addMessage(currentMsg);
   }
    public PageReference Process(){
   		
   		for(integer i = 0; i < processInvoices.size(); i++){
   			
   			if(processInvoices[i].Process__c){
   				Ids.add(processInvoices[i].Id);
   			}
   		}
   		try{
   			Hapara_XeroHandler.process(Ids);
   		}catch(Exception e){   			
   			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Errored: ' + e.getMessage() + '\n\n//-- Stack Trace --//\n' + e.getStackTraceString()));
   		}
   		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Warning, 'The following invoices are being processed please have a look at status and the error messages.'));
   		currentStep = '2';
   		
   		return ApexPages.currentPage(); 
   }
   
   public PageReference ProcessPDF(){
   		for(integer i = 0; i < sendInvoices.size(); i++){
   			
   			if(sendInvoices[i].Status__c !=HAPARA_CONST.INVOICE_STATUS_ERRORED && sendInvoices[i].Xero_Id__c!=null ){
   				Ids.add(sendInvoices[i].Id);
   			}
   		}	
   		try{
   			Hapara_XeroHandler.processInvoicePDF(Ids);
   		}catch(Exception e){   			
   			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Errored: ' + e.getMessage() + '\n\n//-- Stack Trace --//\n' + e.getStackTraceString()));
   		}
   		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Warning, 'The following invoices are being retrieved from Xero.'));
   		currentStep = '2';
   		
   		return ApexPages.currentPage(); 
   }
   
   public String getStep() {
		return currentStep;
	}
	
	string processStatus = 'processing';
	public String getProcessStatus(){
		return processStatus;
	}
	
   public List<Hapara_Invoice__c> getProcessInvoices(){
   		return processInvoices;
   }
	
   public List<Hapara_Invoice__c> getSendInvoices(){
   		return sendInvoices;
   }
   
   public List<Hapara_Invoice__c> getProcessedInvoices(){
   		return processedInvoices;
   }
   
   private void checkListToProcess(list<Hapara_Invoice__c>temp2){
		if(temp2 != null)
	   		for(Hapara_Invoice__c message: temp2){
	   			Account invoiceCustomer = message.Reseller_Account__c == null ? message.Account__r:  message.Reseller_Account__r;
	   			system.debug('****checkListToProcess = ' + invoiceCustomer.Name);
	   			
	   			if( message.Status__c !=HAPARA_CONST.INVOICE_STATUS_PAID
	   				&& message.Status__c !=HAPARA_CONST.INVOICE_STATUS_DELETED 
	   				 ){
	   				//check if the invoice customer has contact setup
	   				if(message.Account__r.Invoice_Contact__c ==null){
	   					message.Process__c = false;
	   					message.Error_Message__c = 'This invoice\'s customer account has not been setup with an Invoice Contact.';
	   					
	   				}else if(string.isEmpty(invoiceCustomer.BillingStreet) ){
	   					message.Process__c = false;
	   					message.Error_Message__c = 'This invoice\'s customer,' +invoiceCustomer.Name+', account billing address has not been filled out.';
	   					
	   				}else{	   				
		   				//check if the billing address has been entered
		   				message.Process__c = true;
		   				message.Error_Message__c = '';
		   				noOfProcess = noOfProcess+1;
	   				}
	   			}else{
	   				message.Process__c = false;
	   				message.Error_Message__c = 'Status of Invoice is not valid to be process:'+message.Status__c;
	   			}
	   		}
   }
     
   public integer getRecordSize(list<Hapara_Invoice__c> temp2) {
     if (temp2!=null) {
        return temp2.size();
     } else {
        return 0;
     }
   }
   
   public PageReference reloadResult(){
	   	string id = ApexPages.currentPage().getParameters().get('id');
	   	
   		processedInvoices = [Select h.Xero_Invoice_No__c, h.Status__c, h.Reseller_PO__c, h.Invoice_Date__c, 
			h.Customer_PO__c, h.CurrencyIsoCode, h.Account__r.BillingCountry,
			 h.Account__r.BillingPostalCode, h.Account__r.BillingState, h.Account__r.BillingCity, 
			 h.Account__r.BillingStreet, h.Account__r.Name, h.Account__c,h.Name,h.Error_Message__c ,
			 h.LastModifiedDate
			 From Hapara_Invoice__c h
			WHERE h.Id IN :Ids];
		integer totalRecords = processedInvoices.size();
		integer updateRecords = 0;
		for(Hapara_Invoice__c inv:processedInvoices ){
			if(inv.status__c ==HAPARA_CONST.INVOICE_STATUS_ERRORED|| inv.Status__c==HAPARA_CONST.INVOICE_STATUS_UPDATED_TO_XERO 
			|| inv.Status__c == HAPARA_CONST.INVOICE_STATUS_RETRIEVED_INVOICE)
				updateRecords = updateRecords +1;
		}
		if( updateRecords == totalRecords){
   			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 
   				'Invoices should be processed successfully. See the status and error message columns to confirm processing.'));
   			processStatus='done';
		}else{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Warning, 
   				'Invoices still processing.....'));
		}
   		return null; 
   }
   
    private void checkListToSendInvoice(list<Hapara_Invoice__c>temp2){
		if(temp2 != null)
	   		for(Hapara_Invoice__c message: temp2){
	   			if(message.Status__c ==HAPARA_CONST.INVOICE_STATUS_UPDATED_TO_XERO  || message.Status__c ==HAPARA_CONST.INVOICE_STATUS_GENERATE_INVOICE 
	   				|| message.Status__c ==HAPARA_CONST.INVOICE_STATUS_SENT_INVOICE  || message.Status__c==HAPARA_CONST.INVOICE_STATUS_RETRIEVED_INVOICE){
	   				
	   				message.Process__c = true;
	   				message.Error_Message__c = '';
	   				noOfProcess = noOfProcess+1;
	   			}else{
	   				message.Process__c = false;
	   				message.Error_Message__c = 'Status of Invoice is not valid to be process: '+message.Status__c;
	   			}
	   		}
   }
   
   public PageReference cancel() {
        return fromPage;
    }
}