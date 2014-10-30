public  class Hapara_CampaignMassEmailController {
	string campaignId;
	private ApexPages.StandardController singlecontroller;
	PageReference fromPage;
	public Hapara_CampaignMassEmailController(ApexPages.StandardController controller){
		if(templatefolders == null)
			emailTemplateFolder = 'All';
		campaignId =  ApexPages.currentPage().getParameters().get('Id');
		singlecontroller =controller; 	
		fromPage = singlecontroller.cancel();
	}
	
	string step = '1';
	public string getStep(){
		return step;
	}
	
	public string campaignMemberStatus{get;set;}
	
	list<SelectOption> campaignMemberStatusesOpts;
	public list<SelectOption> getcampaignMemberStatuses(){
		if(campaignMemberStatusesOpts == null){
			list<CampaignMemberStatus> campaignMemberStatuses = [Select c.Label, c.Id, c.CampaignId 
						From CampaignMemberStatus c 
						where c.CampaignId =:campaignId and c.IsDeleted = false];
			campaignMemberStatusesOpts = new list<selectOption>();
			for(CampaignMemberStatus s : campaignMemberStatuses){
				campaignMemberStatusesOpts.add(new SelectOption(s.Label,s.Label));
			}
		}	
		return campaignMemberStatusesOpts;
	}
	
	public string emailTemplateFolder{get;set;}
	
	list<SelectOption> templatefolders;
	public list<SelectOption> getEmailTemplateFolders(){
		if(templatefolders == null){
			list<Folder> folders = [Select f.Type,f.DeveloperName,  f.Name,  f.Id, f.AccessType From Folder f
									where f.Type ='Email' and f.AccessType ='Public'];
			templatefolders= new list<SelectOption>();
			templatefolders.add(new SelectOption('All','All'));
			for(Folder f : folders){
				templatefolders.add(new SelectOption(f.Id,f.Name));
			}
		}
		return templatefolders;
	}
	public string emailTemplateId{get;set;}
	
	list<EmailTemplate> emailTemplates;
	public list<SelectOption> getEmailTemplates(){
		system.debug('***getEmailTemplates-emailTemplateFolder='+ emailTemplateFolder);
		if(emailTemplateFolder =='All')
			emailTemplates =[Select e.Name, e.DeveloperName ,e.IsActive, e.Id, e.FolderId 
						From EmailTemplate e where isActive = true order by e.Name];
		else
			emailTemplates =[Select e.Name, e.DeveloperName ,e.IsActive, e.Id, e.FolderId 
						From EmailTemplate e where isActive = true and e.FolderId =:emailTemplateFolder order by e.Name];
		list<SelectOption> options= new list<SelectOption>();
		options.add(new SelectOption('none','Please select an template'));
		for(EmailTemplate t : emailTemplates){
			options.add(new SelectOption(t.DeveloperName,t.Name));
		}
		return options;
	}
	
	public void populateEmailTemplates(){
		getEmailTemplates();
	}
	 
	string emailingStatus='';
	public string getEmailingStatus(){
		return emailingStatus;
	}
	
	
	public PageReference SendEmail(){
		if(emailTemplateId != 'none'){
			step = '2';	
			emailCampaignMembers();
		}
		else
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please select an email template.'));
		return null;
	}
	
	  public PageReference Cancel() {
        return fromPage;
    }
    
    public PageReference reloadResult(){
    	emailCampaignMembers();
    	return null; 
    }
    
    integer counterMax = 0;
    integer counter = 0;
    CampaignMember[] emailMembers ;
    public void emailCampaignMembers(){
    	try{
    	system.debug('***emailCampaignMembers -memberstatus=' + campaignMemberStatus + '; campaignId = ' +campaignId);
    	if(emailMembers == null){
    		emailMembers = [Select c.Status,c.LeadId, c.ContactId, c.CampaignId 
    				From CampaignMember c
    				WHERE c.Status =:campaignMemberStatus and c.CampaignId=:campaignId];
    	}
    	if((emailMembers.size()- counter) >100){
    		counterMax = counter + 100;
    	}else
    		counterMax = emailMembers.size();
    		
    	emailingStatus =counterMax + ' out of ' + emailMembers.size();
    	system.debug('***emailCampaignMembers - counter=' + counter + '; counterMax='+ counterMax + '; Member.size='+ emailMembers.size());
    	list<Id> recipientIds = new list<Id>();
    	if(counter!= counterMax && counter >0 )
    		counter = counter -1;
    		
    	for(integer i = counter;i<counterMax;i++){
    		CampaignMember c = emailMembers[i];
    		if(c.ContactId != null)
    			recipientIds.add(c.ContactId);
    		else
    			recipientIds.add(c.LeadId);
    	}
    	if(recipientIds.size()>0)
    		HaparaSendEmailNotification.SendMassContactEmails(emailTemplateId, campaignId, 'Campaign', recipientIds, 
    				Userinfo.getName(), Userinfo.getUserEmail(),null );
		
    	counter= counterMax;
    	
    	}catch(Exception e){
    		string error ='***emailCampaignMembers: '+  e.getMessage() + '\n\n//-- Stack Trace --//\n' + e.getStackTraceString();
			HaparaSendEmailNotification.SendAdminErrorEmail('Hapara_CampaignMassEmailController', error,Apexpages.currentPage().getUrl());
			System.debug(error);
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,error));
    	}
    }
}