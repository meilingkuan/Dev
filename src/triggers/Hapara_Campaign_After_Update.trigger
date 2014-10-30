trigger Hapara_Campaign_After_Update on Campaign (before update,before insert) {
	
		if(trigger.isBefore){
			for(Campaign c : trigger.new){
				if(c.RecordTypeId == HAPARA_CONST.SETTING_SCHEDULE.Campaign_Record_Type_Id__c){
					if(c.Reminder__c == HAPARA_CONST.CAMPAIGN_REMINDER_1 && c.Send_Out_Reminder__c != HAPARA_CONST.CAMPAIGN_REMINDER_1){
						c.Send_Out_Reminder__c = HAPARA_CONST.CAMPAIGN_REMINDER_1;
						Hapara_SchedulingHandler.SendEmailReminderOnDemoCampaign(c.Id,HAPARA_CONST.SETTING_SCHEDULE.X1_Day_Reminder_Email__c);
					}else if(c.Reminder__c == HAPARA_CONST.CAMPAIGN_REMINDER_3 && c.Send_Out_Reminder__c != HAPARA_CONST.CAMPAIGN_REMINDER_3 ){
						c.Send_Out_Reminder__c = HAPARA_CONST.CAMPAIGN_REMINDER_3;
						Hapara_SchedulingHandler.SendEmailReminderOnDemoCampaign(c.Id,HAPARA_CONST.SETTING_SCHEDULE.X1_Hour_Reminder_Email__c);
					}
				}
			}	
		}
}