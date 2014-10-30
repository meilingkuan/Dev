trigger Hapara_MCSubscriberActivity_After_Insert on MC4SF__MC_Subscriber_Activity__c (after insert) {
	if(trigger.isInsert){
		list<id> activityIds = new list<id>();
		for(MC4SF__MC_Subscriber_Activity__c a : trigger.new){
			activityIds.add(a.id);
		}
		
		list<MC4SF__MC_Subscriber_Activity__c> acitivites = [Select m.Id, m.MC4SF__Type__c, m.MC4SF__MC_Subscriber__r.MC4SF__Email2__c, 
			m.MC4SF__MC_Subscriber__c, m.MC4SF__MC_List__r.Id, m.MC4SF__MC_List__c, m.MC4SF__Action__c 
			From MC4SF__MC_Subscriber_Activity__c m
			where m.Id in:activityIds];
		
		list<string> contactEmails = new list<string>();
		list<id> mclistids = new list<id>();
		for(MC4SF__MC_Subscriber_Activity__c a: acitivites){
			contactEmails.add(a.MC4SF__MC_Subscriber__r.MC4SF__Email2__c);
			mclistids.add( a.MC4SF__MC_List__c);
		}
		
		list<CampaignMember> members = [Select c.Lead.Email, c.LeadId, c.Id, c.Contact.Email, c.ContactId, c.Campaign.MC_List__c, 
				c.Campaign.Id, c.CampaignId 
				From CampaignMember c
				Where ( c.Contact.Email in:contactEmails or c.Lead.Email in:contactEmails) and c.Campaign.MC_List__c in:mclistids
				];
		map<string,CampaignMember>	mappingCM = new map<string,CampaignMember>();	
		list<id> campaignId = new list<id>();
		//for(CampaignMember m : members){
		//	if(m.ContactId != null)
		//		mappingCM.put(m.Campaign.MC_List__c + m.Contact.Email, m);
		//	else if(m.LeadId != null) 
		//		mappingCM.put(m.Campaign.MC_List__c + m.Lead.Email,m);
		//	campaignId.add(m.CampaignId);
		//}
		
		//check if the campaign has the relevant status
		//list<Campaign> campaigns = [select Id 
		//	from Campaign c 
		//	where Id in:campaignId and
		//	(not c.Id in (Select cm.CampaignId 
		//					From CampaignMemberStatus cm
		//					where cm.Label in: HAPARA_CONST.CAMPAIGNMEMBER_MCSTATUSES
		//	 ))
		//];
		
		
	}
}