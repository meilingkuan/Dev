trigger Hapara_Lead_After_Insert on Lead (after insert) {
	try {   
         
        if (Trigger.new.size() >0) {
            
            List <CampaignMember> cm = new list<CampaignMember>();
            String cname = 'Google App Pack';
                     
            List <Campaign> c = [select id, name from Campaign where name = :cname limit 1];
            for(Lead L : Trigger.new) {
            	if(L.Lead_Type__c == 'Google App Pack Prospect'){
                    
                    if(!c.isEmpty()){
                        CampaignMember cml = new CampaignMember();
                        cml.campaignid = c[0].id;
                        cml.leadid = l.id;
                        cm.add(cml);                       
                        
		                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
						String[] toAddresses;
											
						System.debug('Email sent to ' + user.Name + ' at ' + user.Email);
						//System.debug('Lead id ' + l.id);		
						mail.setSenderDisplayName('Salesforce Administrator');
						//toAddresses = new String[] {HAPARA_CONST.SETTING_SCHEDULE.Web_To_Lead_Nofications_Email__c};
						toAddresses = new String[] {'customerservice@hapara.com'};
						mail.setToAddresses(toAddresses);
       
				     	// set the subject on the email
				 	    mail.setSubject('New lead added to Salesforce from Google App Pack: ' +L.FirstName + ' ' + L.LastName +' from ' + L.Company);
				      
					    // set the body of the email
					   	mail.setHTMLBody('<p>*** NEW LEAD NOTIFICATION *** </p>' 
					   		+ '<p>The following lead has been added to Salesforce from Google App Pack </p>'
					   		+ '<p>Company: ' + L.Company +'</p>'
					   		+ '<p>Lead Name: ' + L.FirstName + ' ' + L.LastName +'</p>'
					   		+ '<p>Lead Email: ' +L.Email+'</p>'
					   		+ '<p>No of Students: ' + L.No_of_Students__c +'</p>'
					   		+ '<p>Click on the link to access the lead directly: ' + URL.getSalesforceBaseUrl().toExternalForm()  +'/'+ L.id+'</p>'
					   	);
				  				   
						Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
                
                    }else{
                    	throw new HaparaException('Cannot find campaign ' + cname);
                    }
            	}
            }
             
            if(!cm.isEmpty()){
                insert cm;                                
            }
        }
         
         
    } catch(Exception e) {
        system.debug ('Hapara_Lead_After_Insert Error: ' + e.getMessage() );
    } 
}