@isTest(SeeAllData=true)
private class  Hapara_Test_Campaign_Update {
	 static testMethod void testCampaignBeforeUpdate() {
	 	DateTime demoDate = DateTime.now().addDays(-14);
	 	User u = [select id, email from User where email = 'meiling.kuan@hapara.com' limit 1];
	 	Campaign c = new Campaign();
	 	c.Demo_Days__c = 'Wednesday';
		c.StartDate =  demoDate.date(); 
		c.EndDate = demoDate.date(); 
		c.Demo_Time__c = '16:00:00'; 
		c.Demo_Time_Zone__c = 'America/Los_Angeles'; 
		c.Create_Next_Demo__c = false;
		c.Schedule_Meeting_Connection_Details__c= 'jkjkk';
		c.Status='In Progress';
		c.IsActive= true;
		c.Name = c.Demo_Time_Zone__c + '-'+ c.Demo_Days__c+','+c.Demo_Time__c+','+demoDate.format('dd MMMM yyyy');
		c.RecordTypeId =  HAPARA_CONST.SETTING_SCHEDULE.Campaign_Record_Type_Id__c;
		c.Demo_Presenter__c=u.Id;
		
		insert c;
		
		c.Reminder__c = HAPARA_CONST.CAMPAIGN_REMINDER_1;
		update c;
		
		c = [select Send_Out_Reminder__c from Campaign where id = : c.Id];
		system.assertEquals(c.Send_Out_Reminder__c , HAPARA_CONST.CAMPAIGN_REMINDER_1);
		
		c.Reminder__c = HAPARA_CONST.CAMPAIGN_REMINDER_3 ;
		update c;
		c = [select Send_Out_Reminder__c from Campaign where id = : c.Id];
		system.assertEquals(c.Send_Out_Reminder__c , HAPARA_CONST.CAMPAIGN_REMINDER_3);

	 }
}