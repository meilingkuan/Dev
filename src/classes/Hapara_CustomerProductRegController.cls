public class Hapara_CustomerProductRegController {
	String unAuthorizeURL = '/apex/HaparaCustomerUnAuthorize';
	String successfulRegistration = '/apex/HaparaCustomerProductRegSucessful';
	String cancelRegistration = '/apex/HaparaCustomerProductRegCancel';
	Hapara_Term_Conditions__c termNConditions;
	Sandbox_Register__c sandRegister;
	
	public Hapara_CustomerProductRegController(){}
	
    public PageReference CheckId(){
    	PageReference newPage = null;
    	string id = ApexPages.currentPage().getParameters().get('id');
    	string productCode =  ApexPages.currentPage().getParameters().get('code');
    	//String newPageUrl =ApexPages.currentPage().getUrl();
    	System.debug('***CheckId() - id = ' +id);
    	if(id == null || id=='null' || productCode == null || productCode=='null'){
    		System.debug('***CheckId() - No id = ' +id);
    		//ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'id == null'));
    		newPage =  new PageReference(unAuthorizeURL);
    		newPage.setRedirect(true);
    		return newPage;
    	}else{
    	//	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'id: ' + id));
    		if(getRegistration()){
    			System.debug('***CheckId() - Cannot find Registration id = ' +id);
	   			newPage =  new PageReference(unAuthorizeURL);
	    		newPage.setRedirect(true);
	    		return newPage;
   			}
           
    	}
    	return null;
    }	

    
    public Boolean getRegistration(){
    	Boolean result = false;
    	
    	string productCode =  ApexPages.currentPage().getParameters().get('code');
    	string id = ApexPages.currentPage().getParameters().get('id');
    	
    	if(productCode =='Sandbox'){
	    	if(sandRegister !=null)
	    		return true;
	    	try{
		    	sandRegister = [Select s.Term_and_Condition_Version__c, s.Start_Date__c, s.Password__c, s.Login__c, s.End_Date__c, 
		    				s.Date_of_Registration__c, s.Customer_Sandbox_URL__c, s.Class_ID__c,s.Customer_Contact__c,s.Account_Id__c
		    				From Sandbox_Register__c s
		                  	WHERE Id = :id];
	    	}catch(Exception e){
	    		System.debug('***getRegistration() - Cannot find sandRegister id = ' +id);
	    		return false;
	   		}
    	}
   		return result;
    }
    
    public Hapara_Term_Conditions__c getTermAndConditions(){
    	string productCode =  ApexPages.currentPage().getParameters().get('code');
    	
    	termNConditions = [Select h.Term_and_Conditions_Version_Code__c, h.Term_and_Conditions_Text__c,
    						 h.Successful_Registration_Message__c, h.Registration_Title__c, h.Registration_Summary_Details__c 
    						From Hapara_Term_Conditions__c h
    									where 
    									Product__c
										in (Select p.Id From Product2 p 
										where p.ProductCode =:productCode) 
										and Active__c = true];
	 	return termNConditions;
    }
    
    public PageReference setAgreedTermAndConditions(){
    	PageReference newPage;
    	string productCode =  ApexPages.currentPage().getParameters().get('code');
    	string id = ApexPages.currentPage().getParameters().get('id');
    	String url = successfulRegistration +'?id=' + id + '&code=' + productCode;
    	try{
	    	getRegistration();
	    	if(productCode =='Sandbox'){
	    		sandRegister.Date_of_Registration__c = Date.today();
	    		sandRegister.Term_and_Condition_Version__c = termNConditions.Term_and_Conditions_Version_Code__c;
	    		update sandRegister;
	    		
	    		Contact contact = [select id,email,firstname from contact c where id =: sandRegister.Customer_Contact__c];    		
	    		
	    		HaparaSendEmailNotification.SendContactSandboxEmail(contact, 'SandboxRegister_Login_Details', sandRegister);
	    		
	    		Account acc = [select a.Owner.Email, a.OwnerId ,Name,Id from Account a where a.id =: sandRegister.Account_Id__c];
	    	
	    		sendCustomerAccountOwnerEmail(sandRegister,acc,acc.Owner.email);
	    		
	    		
	    		System.debug('****setAgreedTermAndConditions: url = ' + url);
	    		newPage =  new PageReference(url);
	    		newPage.setRedirect(true);
	    		return newPage;
	    	}
    	}catch(Exception e){
			string error ='***setAgreedTermAndConditions: '+  e.getMessage() +'; url='+url + '\n\n//-- Stack Trace --//\n' + e.getStackTraceString();
			HaparaSendEmailNotification.SendAdminErrorEmail('HaparaSendEmailNotification setAgreedTermAndConditions process', error, '');
			throw new HaparaException(e);
			
		}
    	return newPage;
    
    }
    
    
    
    public PageReference cancel(){
    	PageReference newPage;
    	string productCode =  ApexPages.currentPage().getParameters().get('code');
    	string id = ApexPages.currentPage().getParameters().get('id');
    	String url = cancelRegistration +'?id=' + id + '&code=' + productCode;
    	System.debug('****cancel: url = ' + url);
    	
    	newPage =  new PageReference(url);
		newPage.setRedirect(true);
		return newPage;
    
    }
    
    public void sendCustomerAccountOwnerEmail(Sandbox_Register__c sb,Account acc,String sendToEmail ){
   		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses;
		String salesforceURL = Hapara_Utility.isRunningInSandbox()?Hapara_Utility.GetSandboxURL():Hapara_Utility.GetProductionURL();
		
										
		System.debug('Email sent to Reseller Sales at ' + sendToEmail);
					
		mail.setSenderDisplayName('Sandbox Registration');
		toAddresses = new String[] {sendToEmail};
		mail.setToAddresses(toAddresses);
   		mail.setReplyTo('customer.service@hapara.com');
		// set the subject on the email
		mail.setSubject('Sandbox has been activated by ' + acc.Name);
			      
		// set the body of the email
		mail.setHTMLBody('<p>*** Sandbox Activated *** </p>' 
				   		+ '<p>The following account has activated their sandbox: </p>'
				   		+ '<p>Date of Registration: ' + sb.Date_of_Registration__c +'</p>'
				   		+ '<p>Class Id: ' + sb.Class_ID__c+'</p>'
				   		+ '<p>Click on the link to access the account directly: ' 
				   		+ salesforceURL	+'/'+ acc.id+'</p>'
				   	);
			  				   
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
   }
   
}