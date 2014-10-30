public with sharing class Hapara_LeadDuplicateCheckerController {
	private final ApexPages.StandardSetController cntr;
   	private final PageReference fromPage;
   	private List<Lead> objs;
   	private Map<String, Schema.SObjectField> fieldMap;
  	private transient ApexPages.Message currentMsg;
   	private final String newLine ='<br></br>';
   	private List<SelectOption> picklistValues;
   	private String currentStep;
   	private integer noOfRecords = 0;
   	
	public Hapara_LeadDuplicateCheckerController(ApexPages.StandardSetController controller) {
       currentStep = '1';
       controller.setPageSize(500);
       cntr = (ApexPages.StandardSetController)controller;
       fromPage = cntr.cancel();
       if (this.objs == null) {
       		getRecords();
       }    
   }
   
  	private void getRecords( ){
  		List<Lead> tempObj =(List<Lead>)cntr.getRecords();
       	list<Id> ids = new list<Id>();
	    for(Lead l:tempObj){
	    	ids.add(l.Id);
	    }
      	objs=[select Id, name,email,company,Duplicated_Lead__c,DeDup_Status__c,Duplicated_Contact__c,Existed_Customer_Account__c,
       		Existed_Customer_Account_Type__c
       		from Lead
       		where Id in: ids and (DeDup_Status__c = 'Not Duplicated' OR DeDup_Status__c = null)];
       
		noOfRecords= cntr.getResultSize();
		currentMsg = new ApexPages.Message(ApexPages.severity.Info, 'The duplicate check can only process 500 record at a time.');
	   
	   if (getRecordSize()<1) {
	        String msg = 'No record was in the list view.  Please click Previous button and select a view with Record.'; 
	        currentMsg = new ApexPages.Message(ApexPages.severity.ERROR, msg);
	   } else {
	        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info,'Current Page being checked:' + cntr.getPageNumber() ));
	   }
	   ApexPages.addMessage(currentMsg);
		
  }
  
  public list<Lead> getDeDupLeads(){
  	 return this.objs;
  }
  
  public integer getRecordSize() {
  	 if (objs!=null) {
    	return objs.size();
	 } else {
	    return 0;
	 }
   }
   
   public String getStep() {
		return currentStep;
   }
    public PageReference cancel() {
        return fromPage;
    }
    
   	public PageReference processDuplicateCheckLead(){
		list<string> emails = new list<string>();
		list<id> ids = new list<id>();
		for(Lead l: objs){
			emails.add(l.email);
			ids.add(l.id);
		}
		list<Lead> leadwithEmails = [select id, email 
			from Lead 
			where email in: emails and Id not in:ids and IsConverted=false];
		
		map<string,id> mapleademails = new map<string,id>();
		for(Lead c : leadwithEmails){
			if(!mapleademails.containsKey(c.email))
				mapleademails.put(c.email, c.id);
		}
		
		list<Lead> leadswithlead = new list<Lead>();
		for(Lead l: objs){
			if(mapleademails.containsKey(l.email)){
				l.Duplicated_Lead__c = mapleademails.get(l.email);
				l.DeDup_Status__c = 'Found Lead';
				leadswithlead.add(l);
			}else if(string.isEmpty(l.DeDup_Status__c) )
				l.DeDup_Status__c = 'Not Duplicated';
		}
		
		///if(leadswithlead.size() >0)
		//	update leadswithlead;
		update objs;	
		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, 'No of duplicated Leads found with Lead:'
				 + leadswithlead.size()));
		return null;
	}
	
	public PageReference processDuplicateCheckContact(){
		list<string> emails = new list<string>();
		for(Lead l: objs){
			emails.add(l.email);
		}
		list<Contact> contactwithEmails = [select id, email,accountId from Contact where email in: emails];
		
		map<string,Contact> mapcontactemails = new map<string,Contact>();
		for(Contact c : contactwithEmails){
			if(!mapcontactemails.containsKey(c.email))
				mapcontactemails.put(c.email, c);
		}
		
		list<Lead> leadswithContact = new list<Lead>();
		for(Lead l: objs){
			if(mapcontactemails.containsKey(l.email)){
				Contact con = mapcontactemails.get(l.email);
				l.Duplicated_Contact__c =con.id ;
				l.Existed_Customer_Account__c =con.accountid;
				l.DeDup_Status__c = 'Found Contact';
				leadswithContact.add(l);
			}else if(string.isEmpty(l.DeDup_Status__c) )
				l.DeDup_Status__c = 'Not Duplicated';
		}
		
	//	if(leadswithContact.size() >0)
		//	update leadswithContact;
		
		update objs;
		
		ApexPages.addMessage( new ApexPages.Message(ApexPages.severity.Info, 'No of duplicated Leads found with Contact:' 
				+ leadswithContact.size()));
		
		return null;
		
	}
	
	public PageReference processDuplicateCheckAccount(){
		list<string> accountNames = new list<string>();
		list<string> emailDomains = new list<string>();
		string[] emails ;
		for(Lead l: objs){
			accountNames.add(l.Company);
			if(Hapara_Utility.validatePersonalEmail(l.email)){
				emails =l.email.split('@');
				if(emails.size()>0) 
					emailDomains.add(emails[1].trim());
			}
		}
		list<Account> companies = [select id, Name,website from Account where name in: accountNames or website in:emailDomains ];
		
		map<string,id> mapAccountName = new map<string,id>();
		map<string, id>mapAccountEmail = new map<string,id>();
		for(Account c : companies){
			if(!mapAccountName.containsKey(c.name))
				mapAccountName.put(c.name, c.id);
			if(!mapAccountEmail.containsKey(c.website))
				mapAccountEmail.put(c.website,c.id);
		}
		
		list<Lead> leadswithAccount = new list<Lead>();
		for(Lead l: objs){
			if(mapAccountName.containsKey(l.company)){
				l.Existed_Customer_Account__c = mapAccountName.get(l.company);
				l.DeDup_Status__c = 'Found Customer Account';
				leadswithAccount.add(l);
			}else if(Hapara_Utility.validatePersonalEmail(l.email)){
				emails =l.email.split('@');
				if(emails.size()>1){
				 	if(mapAccountEmail.containsKey(emails[1].trim())){
						l.Existed_Customer_Account__c = mapAccountEmail.get(emails[1].trim());
						l.DeDup_Status__c = 'Found Customer Account Domain';
						leadswithAccount.add(l);
					}else  if(string.isEmpty(l.DeDup_Status__c) )
						l.DeDup_Status__c = 'Not Duplicated';	
				}else
					l.DeDup_Status__c = 'Not Duplicated';	
			}else if(string.isEmpty(l.DeDup_Status__c) )
				l.DeDup_Status__c = 'Not Duplicated';
		}
		
		//if(leadswithAccount.size() >0)
		//	update leadswithAccount;
		update objs;
		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, 'No of duplicated Leads found with Account:' 
				+ leadswithAccount.size()));
		return null;
		
	}
	
	public PageReference nextPage(){
		if(cntr.getHasNext()){
			cntr.next();
			getRecords();
		}
		return null;
		
	}
	
	public PageReference previousPage(){
		if(cntr.getHasPrevious()){
			cntr.previous();
			getRecords();
		}
		return null;
		
	}
}