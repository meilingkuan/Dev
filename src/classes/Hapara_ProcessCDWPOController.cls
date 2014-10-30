public with sharing class Hapara_ProcessCDWPOController {
	 private final ApexPages.StandardSetController cntr;
	 private  List<Case> objs;
	 private transient ApexPages.Message currentMsg;
	 private integer noOfProcess=0 ;
	 private final PageReference fromPage;
	 private String currentStep = '1'; 
	 private list<Id> caseIds = new list<Id>();
	 private ApexPages.StandardController singlecontroller;
	 private Case currentCase ;
	 private Hapara_ProcessCDWPOHandler handler;	
	 private list<Account> existingAccounts = new list<Account>();
	 
	 public Hapara_ProcessCDWPOController(ApexPages.StandardController controller) { 		
		singlecontroller =controller; 
		fromPage = singlecontroller.cancel();	
		currentCase = [select CaseNumber, Subject,Description, Status, Process__c, Error_Message__c, CreatedDate, closedDate 
			from case c where c.Id =:singlecontroller.getId() ];
		caseIds.add(currentCase.id);
		handler = new Hapara_ProcessCDWPOHandler();
		try{
			handler.parseCaseDescription(currentCase.Description);
			existingAccounts =  [Select  a.Id ,a.Website,a.Website_1__c, a.Name,a.TD_Setup_Date__c,
					a.Type,a.OwnerId,a.billingState, a.billingStreet			
					From Account a 
					where a.Website =: handler.message.customerDomain
					or a.Name  =: handler.message.customerName or a.Website_1__c  =:handler.message.customerDomain];
					
		}catch(Exception e){   			
   			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Error:' +  e.getMessage() 
					+ '\n\n//-- Stack Trace --//\n' + e.getStackTraceString()));
   		}
 	}
 	
 	public PageReference onload() {   	
        PageReference redirect = new PageReference('/apex/HaparaProcessCDWPOButton');
        redirect.getParameters().put('Id', singlecontroller.getId());
         if (ApexPages.currentPage().getParameters().containsKey('retUrl')) {
            redirect.getParameters().put('retUrl', ApexPages.currentPage().getParameters().get('retUrl'));
        }
        return redirect;
    }
	 
	 
	 public Hapara_ProcessCDWPOController(ApexPages.StandardSetController controller) {
       controller.setPageSize(1000);
       cntr = (ApexPages.StandardSetController)controller;
       fromPage = cntr.cancel();
       string id = ApexPages.currentPage().getParameters().get('id');
       if (this.objs == null) {
       		if(string.isEmpty(id)){
            	this.objs = (List<Case>)cntr.getSelected();
       		}else{
       			list<id> ids = new list<id>();
       			ids.add(id);
       			this.objs = [select CaseNumber, Subject, Status, Process__c, Error_Message__c, CreatedDate, closedDate from case c where c.Id IN: ids ];       			
       		}
       }
       system.debug('****Hapara_ProcessCDWPOController: cases size' + getRecordSize() );
       if (getRecordSize()<1) {
            String msg = 'No record was selected on the list view.  Please click Cancel button and select records for Process CDW PO on.'; 
            currentMsg = new ApexPages.Message(ApexPages.severity.ERROR, msg);
       } else {
       		checkListToProcess();
            String msg = 'Number of records selected for processing: ' + noOfProcess+' out of ' + getRecordSize(); 
            currentMsg = new ApexPages.Message(ApexPages.severity.INFO, msg);
       }
       ApexPages.addMessage(currentMsg);
   }
   
   private string  accountChoice = 'NEW';
   
   public string getAccountChoice(){
   		return accountChoice;
   }
   public void setAccountChoice(string choice){
   		accountChoice = choice;
   }
   
   public string getCaseDetails(){
   		return '<u><b>Case Customer Details</b></u>'
   		+'<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Customer Name:<i> ' + handler.message.customerName 
   		+'</i></b><br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Google Domain: '+handler.message.customerDomain
   		+'<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Address: ' + handler.message.customerStreet 
   		+'&nbsp;|&nbsp;' + handler.message.customerCity  
   		+'&nbsp;|&nbsp;' + handler.message.customerState 
   		+'&nbsp;|&nbsp;' + handler.message.customerZipCode 
   		+'&nbsp;|&nbsp;' + handler.message.customerCountry ;
   }
   
   public list<SelectOption> getAccountChoices() {
        list<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('NEW','Create new Account')); 
        
        if(existingAccounts.size()>0){
        	for(Account acc:existingAccounts ){
        		options.add(new SelectOption(acc.id,acc.Name +' | website: '+ acc.Website_1__c+' | student domain: '+ acc.website
        				 + ' | Billing State: '+ acc.BillingState +' | Billing Street: '+ acc.BillingStreet)); 
        	}
        }
        
        return options; 
    }
   public PageReference ProcessWithAccount(){
   		System.debug('***ProcessWithAccount - accId=' + accountChoice);
   		Id accId = null;
   		Account acc = null;
   		if(accountChoice != 'NEW'){
   			accId = accountChoice;
   			acc = [select  a.Id ,a.Website,a.Website_1__c, a.Name,a.TD_Setup_Date__c,
					a.Type,a.OwnerId,
					(Select c.Id, c.FirstName, c.Email From Contacts c
					where c.Email =: handler.message.customerContactEmail limit 1)			
					From Account a  where a.id =: accId];
   		}else{
   			acc = new Account();
   			acc.Type = HAPARA_CONST.ACCOUNT_TYPE_PROSPECTRESELLER;
   			acc.Name = handler.message.customerName ;
   			insert acc;
   		}
   		list<Id> messageIds = new list<Id>();
   		messageIds.add(currentCase.Id);
   		try{
   			Hapara_ProcessCDWPOHandler.process(messageIds, acc);
   		}catch(Exception e){   			
   			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Error:' +  e.getMessage() 
					+ '\n\n//-- Stack Trace --//\n' + e.getStackTraceString()));
   		}
   		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'The following cases are processed please have a look at the error messages.'));
   		currentStep = '2';
   		return ApexPages.currentPage(); 
   }
   
   public PageReference Process(){
   		
   		for(integer i = 0; i < objs.size(); i++){
   			
   			if(objs[i].Process__c){
   				caseIds.add(objs[i].Id);
   			}
   		}
   		try{
   			Hapara_ProcessCDWPOHandler.process(caseIds,null);
   		}catch(Exception e){   			
   			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Error:' +  e.getMessage() 
					+ '\n\n//-- Stack Trace --//\n' + e.getStackTraceString()));
   		}
   		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'The following cases are processed please have a look at the error messages.'));
   		currentStep = '2';
   		
   		return ApexPages.currentPage(); 
   }
   
   public String getStep() {
		return currentStep;
	}
	
   public List<Case> getCases(){
   		return objs;
   }
	
   private void checkListToProcess(){
		if(objs != null)
	   		for(Case message: objs){
	   			if(message.Subject.startsWith('CDW P/O #') && message.Status !='Closed'){
	   				message.Process__c = true;
	   				noOfProcess = noOfProcess+1;
	   			}else
	   				message.Process__c = false;
	   		}
   }
     
   public integer getRecordSize() {
     if (objs!=null) {
        return objs.size();
     } else {
        return 0;
     }
   }
   
   public PageReference reloadResult(){
	   	
   		objs = [select CaseNumber, Subject, Status, Process__c, Error_Message__c, CreatedDate, closedDate from case c where c.Id IN :caseIds];
   		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Reloaded result.'));
	   
   		return null; 
   }
   
   public PageReference cancel() {
        return fromPage;
    }
}