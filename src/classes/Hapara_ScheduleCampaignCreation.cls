global class Hapara_ScheduleCampaignCreation implements Schedulable {
    global void execute(SchedulableContext SC)
    {
        Hapara_SchedulingHandler.CreateSchedulingCampaigns(); 
    }
}