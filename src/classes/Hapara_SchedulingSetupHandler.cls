global class Hapara_SchedulingSetupHandler {
	
	//@future
	webservice static void generateEventsFromScheduledTimes(Id weeklyScheduleId){
		
		Hapara_Weekly_Scheduling__c schedule = [Select h.Timezone__c, h.Status__c, h.Start_Date__c, h.Id, h.End_Date__c,
				 (Select Engineer__c, Engineer__r.Name , Date_Available_from__c, Hapara_Scheduling_Type__c,
				Data_Available_To__c, Time_Available_From__c, Time_Available_To__c,Goto_Meeting_Acess__c
				From Hapara_Engineer_Times__r 
				order by Date_Available_from__c,  Time_Available_From__c) ,
				(Select Id, Customer_Contact__c ,Start_Datetime__c, End_Datetime__c 
				From Hapara_Scheduling_Sessions__r 
				where Customer_Contact__c= null) 
			From Hapara_Weekly_Scheduling__c h where id=: weeklyScheduleId 
			and h.Status__c!=: HAPARA_CONST.HAPARA_WEEKLYSCHEDULING_STATUS_CONFIRMED];
		
		map<id, Hapara_Scheduling_Type__c> mapeventTypes = new map<id,Hapara_Scheduling_Type__c>();
		list<Hapara_Scheduling_Type__c> eventTypes = [Select h.Name, h.Is_Active__c, h.Id, h.Duration_of_Event_Scheduled__c 
				From Hapara_Scheduling_Type__c h where is_Active__c = true];
		mapeventTypes.putall(eventTypes);
		system.debug('***generateEventsFromScheduledTimes- mapeventTypes=' +mapeventTypes.size() 
					+'; schedule.Hapara_Scheduling_Sessions__r='+schedule.Hapara_Scheduling_Sessions__r.size());
		list<Hapara_Scheduling_Session__c> newSessions = new list<Hapara_Scheduling_Session__c>();
		list<Hapara_Engineer_Scheduled_Times__c> erroredEngineerTimes = new list<Hapara_Engineer_Scheduled_Times__c>();
		try{
			string format = 'yyyyMMdd\'T\'HHmmss\'Z\'';
			map<string, Id> bookedSessions = new map<string, Id> ();
			//clear all unbooked times and regenerate
			if(schedule.Hapara_Scheduling_Sessions__r.size()>0){
				list<id> ids = new list<id>();
				
				for(Hapara_Scheduling_Session__c a : schedule.Hapara_Scheduling_Sessions__r){
					if(a.Customer_Contact__c == null)
						ids.add(a.id);
					else{
						bookedSessions.put(a.Engineer__c + a.Start_Datetime__c.formatGmt(format),schedule.Id);
					}
				}
				list<Hapara_Scheduling_Session__c> openSessions = [select id from Hapara_Scheduling_Session__c where id in : ids];
				delete openSessions;
			}
	
			for(Hapara_Engineer_Scheduled_Times__c t: schedule.Hapara_Engineer_Times__r){
				date startDate = t.Date_Available_from__c;
				date endDate = t.Data_Available_To__c;
				integer eventCounter = 0;
				//convert start and end time to gmt time
				Hapara_Scheduling_Type__c eventType = mapeventTypes.get(t.Hapara_Scheduling_Type__c);
				system.debug('***generateEventsFromScheduledTimes- startDate=' +startDate.format() + '; endDate='+endDate.format()
							+'; eventType=' +eventType.Duration_of_Event_Scheduled__c.format() 
							+ '; time from:' + t.Time_Available_From__c + '; time to:' + t.Time_Available_To__c );
				list<string> durationComponent;
				string duration = eventType.Duration_of_Event_Scheduled__c.format();
				if(duration.contains('.'))
					durationComponent =duration.split('.');
				else{
					durationComponent = new list<string>();
					durationComponent.add(duration);
				}
				while(startDate <= endDate){
					datetime gmtStartTime = HaparaTimeConversions.convertDateTimeToGMT(schedule.Timezone__c, startDate,t.Time_Available_From__c );
					datetime gmtEndTime = HaparaTimeConversions.convertDateTimeToGMT(schedule.Timezone__c, startDate,t.Time_Available_To__c );
					datetime tempEndTime = gmtStartTime.addHours(integer.valueOf(durationComponent[0]));
					
					while(tempEndTime <= gmtEndTime){
						system.debug('***generateEventsFromScheduledTimes- gmtStartTime=' + gmtStartTime.format() 
								+';tempEndTime=' +tempEndTime.format() +'; gmtEndTime=' + gmtEndTime.format() 
								+'; durationComponent=' +eventType.Duration_of_Event_Scheduled__c);
						if(!bookedSessions.containsKey(t.Engineer__c + gmtStartTime.formatGmt(format))){
							//create event
							Hapara_Scheduling_Session__c session = new Hapara_Scheduling_Session__c(
					            OwnerId = t.Engineer__c ,
					            Engineer__c = t.Engineer__c ,
					            Hapara_Engineer_Scheduled_Times__c = t.Id,
					            Hapara_Weekly_Scheduling__c = schedule.Id, 
					            Start_Datetime__c = gmtStartTime,
					            End_Datetime__c =tempEndTime,
								Hapara_Scheduling_Type__c=eventType.Id,
								Status__c=Hapara_Const.CAMPAIGNMEMBER_STATUS_UNCONFIRMED,
								Goto_Meeting_details__c = t.Goto_Meeting_Acess__c
					        );
					        bookedSessions.put(t.Engineer__c + gmtStartTime.formatGmt(format), schedule.id);
					        newSessions.add(session);
						}
				       
				        gmtStartTime = tempEndTime;
				        tempEndTime = gmtStartTime.addHours(integer.valueOf(durationComponent[0]));
				        if(durationComponent.size()>1)
						 	tempEndTime = tempEndTime.addMinutes(integer.valueOf(durationComponent[1]));
				        eventCounter = eventCounter + 1;
				        system.debug('***generateEventsFromScheduledTimes - created=' + eventCounter);
					}
					startDate = startDate.addDays(1);
				} 
				if(eventCounter == 0){
					t.status__c = HAPARA_CONST.HAPARA_ENGINEERSCHEDULEDTIMES_STATUS_ERRORED;
					t.Error_Message__c = 'Unabled to create scheluded times for this record because the specified time is not within the duration required for the schedulte type. Please check the times again.';
					erroredEngineerTimes.add(t);
				}else{
					t.status__c = HAPARA_CONST.HAPARA_ENGINEERSCHEDULEDTIMES_STATUS_GENERATED;
					t.Error_Message__c = 'No of Events Created:' + eventCounter;
				}
			}
			if(newSessions.size()>0)
				insert newSessions;
			update schedule.Hapara_Engineer_Times__r;
			
			if(erroredEngineerTimes.size()>0){	
				schedule.Status__c = HAPARA_CONST.HAPARA_ENGINEERSCHEDULEDTIMES_STATUS_ERRORED;
				schedule.Error_Message__c = 'Error has occured while generating the scheuled times: ' + erroredEngineerTimes.size() + ' engineer scheduled times failed. Please check the status on each Engineer Scheduled Time to investigate the problem.';
				schedule.Is_Active__c = false;
				update schedule;
			}else{
				schedule.Status__c = HAPARA_CONST.HAPARA_WEEKLYSCHEDULING_STATUS_CONFIRMED;
				schedule.Error_Message__c = '';
				schedule.Is_Active__c = true;
				update schedule;
			}
			
		}catch(Exception e){
			string error ='***generateEventsFromScheduledTimes: '+  e.getMessage() + '\n\n//-- Stack Trace --//\n' + e.getStackTraceString();
			HaparaSendEmailNotification.SendAdminErrorEmail('Hapara_SchedulingSetupHandler generateEventsFromScheduledTimes process', error, '');
			System.debug(error);
			schedule.Status__c = HAPARA_CONST.HAPARA_ENGINEERSCHEDULEDTIMES_STATUS_ERRORED;
			schedule.Error_Message__c = error;
			update schedule;
		}
	}
	
	public static void sendBookSessionInvite(string emailTemplate, Id bookedSessionId,string status){
		Hapara_Scheduling_Session__c h = [Select h.Status__c, h.Start_Datetime__c,h.End_Datetime__c, h.Id, h.Hapara_Scheduling_Type__c, 
				h.Hapara_Scheduling_Type__r.name,  h.Customer_Contact__c ,
				h.Engineer__r.Name, h.Engineer__c,Engineer__r.email,Engineer_Email__c,
				h.Customer_Contact_4__c,h.Customer_Contact_4__r.email, h.Customer_Contact_3__c,h.Customer_Contact_3__r.email,
				 h.Customer_Contact_2__c,h.Customer_Contact_2__r.email,Goto_Meeting_details__c,
				h.Customer_Contact__r.Timezone__c,h.Customer_Contact__r.firstName,h.Customer_Contact__r.lastName,
				h.Customer_Contact__r.email,
				h.Hapara_Engineer_Scheduled_Times__r.Goto_Meeting_Acess__c,h.Hapara_Engineer_Scheduled_Times__r.Goto_Meeting_ID__c
				From Hapara_Scheduling_Session__c h
				where  h.Id =:bookedSessionId];
		string contactlocaldatetime = h.End_Datetime__c.format('yyyy-MM-dd HH:mm:ss', h.Customer_Contact__r.Timezone__c);
		string fileName = h.Hapara_Scheduling_Type__r.name.replace(' ','');
		Messaging.EmailFileAttachment[] attach = Hapara_SchedulingHandler.SendInviteWithICSfile(
			h.id,status, h.Start_Datetime__c,h.End_Datetime__c , 
			h.Engineer_Email__c,h.Customer_Contact__r,contactlocaldatetime,
			h.Goto_Meeting_details__c, h.Hapara_Scheduling_Type__r.name ,fileName+'.ics');
			
		list<string> cc  = new list<string>();
		if(h.Customer_Contact_2__c != null)	
			cc.add(h.Customer_Contact_2__r.email);
		if(h.Customer_Contact_3__c != null)	
			cc.add(h.Customer_Contact_3__r.email);
		if(h.Customer_Contact_4__c != null)	
			cc.add(h.Customer_Contact_4__r.email);
		cc.add(h.Engineer_Email__c);
	  	HaparaSendEmailNotification.SendContactEmailwithBCCNSetWhatIdNAttachment(h.Customer_Contact__r,
	  		emailTemplate, h.Id, cc,attach);
		  	
	}
}