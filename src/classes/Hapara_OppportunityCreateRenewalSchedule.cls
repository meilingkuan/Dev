global class Hapara_OppportunityCreateRenewalSchedule implements Schedulable {
    global void execute(SchedulableContext SC)
    {
       	Hapara_OppportunityCreateRenewal create = new Hapara_OppportunityCreateRenewal();
		create.createRenewalOpportunityAll(); 
    }
}