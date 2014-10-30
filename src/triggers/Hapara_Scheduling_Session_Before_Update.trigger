trigger Hapara_Scheduling_Session_Before_Update on Hapara_Scheduling_Session__c (before insert, before update) {
	if(trigger.isBefore){
		for(Hapara_Scheduling_Session__c c : trigger.new){				
			if(c.Reminder__c == HAPARA_CONST.CAMPAIGN_REMINDER_1 && c.Send_Out_Reminder__c != HAPARA_CONST.CAMPAIGN_REMINDER_1){
				c.Send_Out_Reminder__c = HAPARA_CONST.CAMPAIGN_REMINDER_1;
				Hapara_SchedulingSetupHandler.sendBookSessionInvite(HAPARA_CONST.SETTING_SCHEDULE.Setup_1_Day_Reminder_Email__c, c.id,HAPARA_CONST.CAMPAIGNMEMBER_STATUS_CONFIRMED);
			}else if(c.Reminder__c == HAPARA_CONST.CAMPAIGN_REMINDER_3 && c.Send_Out_Reminder__c != HAPARA_CONST.CAMPAIGN_REMINDER_3 ){
				c.Send_Out_Reminder__c = HAPARA_CONST.CAMPAIGN_REMINDER_3;
				Hapara_SchedulingSetupHandler.sendBookSessionInvite(HAPARA_CONST.SETTING_SCHEDULE.Setup_1hr_Reminder_Email__c, c.id,HAPARA_CONST.CAMPAIGNMEMBER_STATUS_CONFIRMED);
			}
		}
	
	}
}