public class HaparaSendEmailNotification {
	
	
	public static Boolean SendAdminErrorEmail(string methodName, string errorMessage,string currentPageURL){
		Boolean result = true;
			  				   
		SentNonTemplateEmail('ERROR Occurred in ' + methodName, 
						'<p>*** ERROR Occurred in ' + methodName+' *** </p>' 
						+ '<p>URL: '+currentPageURL+'</p>'
				   		+ '<p>'+errorMessage+'</p>', 
				   		'meiling.kuan@hapara.com' );
		return result;
	}
	
	public static Boolean SentNonTemplateEmail(string subject, string emailcontent, string recipientemailAddress ){
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses;								
		System.debug('***SentNonTemplateEmail for: ' + recipientemailAddress + ' subject:' + subject );
		toAddresses = new String[] {recipientemailAddress};
		mail.setToAddresses(toAddresses);
   
		// set the subject on the email
		mail.setSubject(subject );
			      
		// set the body of the email
		mail.setHTMLBody(emailcontent);
			  				   
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
		return true;
	}
	
	public static Boolean SendContactEmail(Contact recipient,String templateName, Account relatedAccount, Opportunity relatedOpportunity){
		
		return SendContactEmailwithBCC(recipient, templateName,relatedAccount, relatedOpportunity, null);
	}
	
	public static Boolean SendContactEmailwithBCC(Contact recipient,String templateName, Account relatedAccount, Opportunity relatedOpportunity,
		list<string> cc){
		
		return SendContactEmailwithBCCNSender(recipient,templateName,relatedAccount,relatedOpportunity,cc,
			'Hapara Team','customer.service@hapara.com');
	}
	
	public static Boolean SendContactEmailwithBCCNSetWhatId(Contact recipient,String templateName,Id setWhatId,
		list<string> cc){
		
		return SendContactEmailwithBCCNSenderSetWhatId(recipient,templateName,setWhatId,cc,
			'Hapara Team','customer.service@hapara.com',null);
	}
	
	public static Boolean SendContactEmailwithBCCNSetWhatIdNAttachment(Contact recipient,String templateName,Id setWhatId,
		list<string> cc,  Messaging.EmailFileAttachment[] attachments){
		
		return SendContactEmailwithBCCNSenderSetWhatId(recipient,templateName,setWhatId,cc,
			'Hapara Team','customer.service@hapara.com',attachments);
	}
	
	public static Boolean SendContactEmailwithBCCNSetWhatIdNAttachment(Id recipientId,String templateName,Id setWhatId,
		list<string> cc,  Messaging.EmailFileAttachment[] attachments){
		Contact c = [Select Id,firstName,LastName,Email, Name ,Hapara_Demo_Scheduling_URL__c
					from contact 
					where id =: recipientId];
		
		return SendContactEmailRecipientIdwithBCCNSenderSetWhatId(c.Id,templateName,setWhatId,cc,
			'Hapara Team','customer.service@hapara.com',attachments);
	}
	
	public static Boolean SendContactEmailwithBCCNSender(Contact recipient,String templateName, Account relatedAccount, Opportunity relatedOpportunity,
		list<string> cc, string senderName, string replyTo){
		Id setWhatId ;
		if(relatedAccount != null){
			setWhatId = relatedAccount.Id;
		}else if(relatedOpportunity != null)
			setWhatId=relatedOpportunity.Id;
			
		return SendContactEmailwithBCCNSenderSetWhatId( recipient, templateName, setWhatId, cc,  senderName,  replyTo,null);
	}
	
	public static Boolean SendContactEmailwithBCCNSenderSetWhatId(Contact recipient,String templateName, 
		Id setWhatId,list<string> cc, string senderName, string replyTo, Messaging.EmailFileAttachment[] attachments){
		
		return SendContactEmailRecipientIdwithBCCNSenderSetWhatId(recipient.id,templateName, setWhatId,cc, senderName, replyTo, attachments);
	}
	
	public static Boolean SendContactEmailRecipientIdwithBCCNSenderSetWhatId(Id recipientId,String templateName, 
		Id setWhatId,list<string> cc, string senderName, string replyTo, Messaging.EmailFileAttachment[] attachments){
		system.debug('***SendContactEmailRecipientIdwithBCCNSenderSetWhatId: recipientId='+recipientId + ' templateName='+templateName
			+ ' setWhatId='+setWhatId+' cc='+cc +' senderName='+ senderName+ ' replyTo='+ replyTo);
		Boolean result = true;
		try{
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			if(setWhatId != null)
				mail.setWhatId(setWhatId);
			 
			EmailTemplate et = [SELECT id FROM EmailTemplate WHERE developerName =:templateName limit 1];
			mail.setTemplateId(et.id);
			setOrgWideID( replyTo, senderName, mail ); 
			
			mail.setTargetObjectId(recipientId); // Specify who the email should be sent to.
			
			if(cc != null)
				if(cc.size()>0)
					mail.setCcAddresses(cc);
			
			if(attachments !=null)
				mail.setFileAttachments(attachments);
		 
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
		}catch(Exception e){
			string error ='***SendContactEmailRecipientIdwithBCCNSenderSetWhatId: '+  e.getMessage() + '\n\n//-- Stack Trace --//\n' + e.getStackTraceString();
			HaparaSendEmailNotification.SendAdminErrorEmail('HaparaSendEmailNotification SendContactEmailRecipientIdwithBCCNSenderSetWhatId process', error, '');
			System.debug(error);
			result = false;
		}
		return result;
	}
	
	 @future(callout=true)
	 public static void SendEmailInThefuture(Id recipientId, Id setWhatId, string templateName,string senderName, string replyTo){
	 	system.debug('***SendEmailInThefuture: recipientId='+recipientId + ' templateName='+templateName
			+ ' setWhatId='+setWhatId +' senderName='+ senderName+ ' replyTo='+ replyTo);
		
		try{
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setWhatId(setWhatId);
			 
			EmailTemplate et = [SELECT id FROM EmailTemplate WHERE developerName =:templateName limit 1];
			mail.setTemplateId(et.id);
			mail.setSenderDisplayName(senderName);
			mail.setReplyTo(replyTo);
			 
			mail.setTargetObjectId(recipientId); // Specify who the email should be sent to.
		 
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
		}catch(Exception e){
			string error ='***SendEmailInThefuture: '+  e.getMessage() + '\n\n//-- Stack Trace --//\n' + e.getStackTraceString();
			HaparaSendEmailNotification.SendAdminErrorEmail('HaparaSendEmailNotification SendEmailInThefuture process', error, '');
			throw new HaparaException(e);
			
		}
	 }
	
	public static Boolean SendContactSandboxEmail(Contact recipient,String templateName, Sandbox_Register__c register){
		Boolean result = true;
		try{
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			
			mail.setWhatId(register.Id);
			 
			EmailTemplate et = [SELECT id FROM EmailTemplate WHERE developerName =:templateName];
			 
			setOrgWideID('customer.service@hapara.com', 'Hapara', mail ) ;
			mail.setTargetObjectId(recipient.id); // Specify who the email should be sent to.
			mail.setTemplateId(et.id);
		 
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
		}catch(Exception e){
			System.debug('SendContactSandboxEmail Error: ' + e);
			result = false;
		}
		return result;
	}
	
	public static Boolean SendMassContactEmails(String templateName, Id setWhatId,string whattype, Id[]  recipientIds, 
		string senderName, string replyTo,map<id, Messaging.EmailFileAttachment[]> attachments){
		string parameters = '***SendMassContactEmails: templateName='+templateName + ' setWhatId='+setWhatId
			+' senderName='+ senderName+ ' replyTo='+ replyTo + ' targetObjectId=' + recipientIds;
		system.debug(parameters);
		Boolean result = true;
		try{
			EmailTemplate et = [SELECT id FROM EmailTemplate WHERE developerName =:templateName limit 1];	
			
			if(whattype != 'Contract' && whattype != 'Case' && whattype != 'Product'  && whattype != 'Opportunity'){
				Messaging.SingleEmailMessage[] mails = new Messaging.SingleEmailMessage[recipientIds.size()];
				for(integer i = 0; i < recipientIds.size(); i++){
					Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
					mail1.setWhatId(setWhatId);
					mail1.setTemplateId(et.id);
					setOrgWideID( replyTo, senderName, mail1 );
					mail1.setTargetObjectId(recipientIds[i]);
					//attachment can only be send in single email
					if(attachments !=null){
						if(attachments.containskey(recipientIds[i]))
							mail1.setFileAttachments(attachments.get(recipientIds[i]));
					}
					mails[i] =mail1;
				}
				Messaging.sendEmail(mails);
			}else{
				Messaging.MassEmailMessage mail = new  Messaging.MassEmailMessage();	
				
				mail.setTemplateId(et.id);
				mail.setSenderDisplayName(senderName);
				mail.setReplyTo(replyTo);
				mail.setWhatIds(new Id[]{setWhatId});
				mail.setTargetObjectIds(recipientIds);
				mail.setSaveAsActivity(true);
				Messaging.sendEmail(new  Messaging.MassEmailMessage[] {mail});
			}
			
		}catch(Exception e){
			string error ='***SendMassContactEmails: parameters= ' + parameters + '\n\n ERROR:' + e.getMessage() + '\n\n//-- Stack Trace --//\n' + e.getStackTraceString();
			HaparaSendEmailNotification.SendAdminErrorEmail('HaparaSendEmailNotification SendMassContactEmails process', error, '');
			System.debug(error);
			result = false;
		}
		return result;
	}
	
	public static boolean SendUserWithTemplate(string TemplateName, Id whatId, string useremail){
		Boolean result = true;
		String[]  useremails = new String[] {useremail};
		
		return SendUsersWithTemplate(TemplateName,whatId,useremails);
	}
	
	public static boolean SendUsersWithTemplate(string TemplateName, Id whatId, String[] useremails){
		Boolean result = true;
		Contact con = new Contact();
		con.FirstName = 'Test';
		con.LastName = 'Contact';
		con.Email = 'no-reply@organization.com';
		insert con;
		EmailTemplate et = [SELECT id FROM EmailTemplate WHERE developerName =:templateName limit 1];	
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses;
										
		System.debug('SendUsersWithTemplate for: ' + useremails + ' whatId=' + whatId + ' templatename=' + TemplateName );
		toAddresses = useremails;
		mail.setToAddresses(toAddresses);
		//can't sent email to user without linking an contact to the template. 
   	 	mail.setTargetObjectId(con.Id);
   	 	if(whatId != null)
			mail.setWhatId(whatId);
		mail.setTemplateId(et.id);
			  				   
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
		//delete the dummy contact record
		delete con;
		return result;
	}
	
	private static void setOrgWideID(string replyTo,string senderName, Messaging.SingleEmailMessage mail1 ){
		list<OrgWideEmailAddress> orgEmail = [select id, Address, DisplayName from OrgWideEmailAddress where address=:replyTo];
		System.debug('setOrgWideID orgEmail: ' + orgEmail.size());			
		if(orgEmail.size()>0){
			mail1.setOrgWideEmailAddressId(orgEmail[0].id); 
		}else{
			mail1.setSenderDisplayName(senderName);
			mail1.setReplyTo(replyTo);
		}
	}
	
}