trigger Hapara_Campaign_Member_Before_Insert_After_Update on CampaignMember (before insert, before update) {
    //currently not sure if this will work. doing it in a batch process would be better, but how to know when to update individual or all campaign members?
    
    //-----before inserting or updating a campaignmember-----//
    for(CampaignMember a : Trigger.new)
    {
    
        //get parent campaigns
        list<Campaign> existingrecords = [Select r.Name from Campaign r where r.Id =: a.CampaignId];
        
        //add campaign name to Event_Campaign_Name__c field in campaign member
        a.Event_Campaign_Name__c=existingrecords[0].Name;
    }
}