public with sharing class Hapara_XeroPaymentController {
	private ApexPages.StandardController singlecontroller;
	private HaparaInvoicePayment__c currentRecord;
	private final PageReference fromPage;
	
	string processStatus = 'processing';
	public String getProcessStatus(){
		return processStatus;
	}
	string canProcess = 'false';
	public String getCanProcess(){
		return canProcess;
	}
	
	public Hapara_XeroPaymentController(ApexPages.StandardController controller) { 		
		singlecontroller =controller; 	
		
		currentRecord = [Select h.Xero_Payment_Id__c, h.Status__c, h.Payment_Check_No_Ref__c, h.Invoice__r.Xero_Id__c,h.Invoice__r.Name,
				h.Invoice__r.Id,h.Invoice__c, h.Id, h.Date_Of_Payment__c, h.Amount_Paid__c 
				From HaparaInvoicePayment__c h
			 WHERE h.Id = :controller.getRecord().Id];
			 
		fromPage = singlecontroller.cancel();
		if(currentRecord.Invoice__r.Xero_Id__c == null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Payment cannot be processed Payment because the invoice is not yet processed into Xero.'));
		}else{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, 'Verified that the payment can be processed.'));
			canProcess = 'true';
		}
 	}
	
	public PageReference cancel() {
        return fromPage;
    }
    
     public PageReference reloadResult(){
	   	string id = ApexPages.currentPage().getParameters().get('id');
	   	currentRecord = [Select h.Xero_Payment_Id__c, h.Status__c, h.Payment_Check_No_Ref__c, h.Invoice__r.Xero_Id__c,h.Invoice__r.Name,
				h.Invoice__r.Id,h.Invoice__c, h.Id, h.Date_Of_Payment__c, h.Amount_Paid__c ,h.Error_Message__c
				From HaparaInvoicePayment__c h
			 WHERE h.Id = :singlecontroller.getRecord().Id];
		if(CurrentRecord.Status__c =='Updated to Xero' ||CurrentRecord.Status__c =='Errored' || CurrentRecord.Status__c =='Sent Payment Advice'  )
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info,CurrentRecord.Status__c +(CurrentRecord.Status__c =='Errored'?': ' + CurrentRecord.Error_Message__c:'')));
		else
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, 'Processing the payment ..... please wait.'));
		processStatus ='done';
		return null; 
   	}
   	
   	public PageReference processPayment(){
   		try{
   			list<Id> ids = new list<id>();
   			ids.add(currentRecord.Id);
   			Hapara_XeroHandler.processInvoicePayment(ids);
   		}catch(Exception e){   			
   			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Errored: ' + e));
   		}
   		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, 'Processing the payment into Xero now.. please wait.'));
   		canProcess = 'false';
   		return ApexPages.currentPage(); 
   	}
   	
   	public PageReference processPaymentSendToCustomer(){
   		try{
			Hapara_Invoice__c relatedInvoice = [select h.Invoice_To_Contact__c, h.Invoice_To_Contact__r.firstname, h.Invoice_To_Contact__r.lastname, 
			h.Invoice_To_Contact__r.email,h.Total_Paid_Amount__c,h.Last_Paid_Date__c,h.Total_Amount__c,h.Xero_Invoice_No__c,
			h.Invoice_Date__c, h.Due_Date__c,h.Invoice_Billing_Emails__c,h.Account__r.Name
			from Hapara_Invoice__c h where h.Id =:currentRecord.Invoice__c];
			 
			list<string> cc = null;
			if(!string.isEmpty(relatedInvoice.Invoice_Billing_Emails__c)){
				if(relatedInvoice.Invoice_Billing_Emails__c.contains(';'))
					cc = relatedInvoice.Invoice_Billing_Emails__c.split(';');
				else
					cc = relatedInvoice.Invoice_Billing_Emails__c.split(',');
			}
			HaparaSendEmailNotification.SendContactEmailRecipientIdwithBCCNSenderSetWhatId(relatedInvoice.Invoice_To_Contact__c,
						HAPARA_CONST.SETTING_INVOICE.Invoice_Payment_Report_Template__c, relatedInvoice.Id,cc, 'Customer Account', 
						HAPARA_CONST.SETTING_INVOICE.Customer_Account_Email__c, null);
   			
   			currentRecord.Status__c = 'Sent Payment Advice';
   			update CurrentRecord;
   		}catch(Exception e){   			
   			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Errored: ' + e));
   			
   		}
   		
   		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, 'Successfully sent email to customer with payment advice.'));
   		canProcess = 'false';
   		return ApexPages.currentPage(); 
   	}
}