@isTest(SeeAllData=true)
public class Hapara_CampaignMassEmailTest {
	static testMethod void testHapara_CampaignMassEmailController(){
		Hapara_SchedulingHandler_Test.createTestSchedulingRecord();
		Campaign cam = Hapara_SchedulingHandler_Test.testCampaign;
	
		PageReference page = new PageReference('/apex/Hapara_CampaignMassEmailBasedOnStatus?id=' + cam.Id);
        Test.setCurrentPage(page);
        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(cam);
        Hapara_CampaignMassEmailController controller = new Hapara_CampaignMassEmailController(stdcontroller);
        /***test get methods***/
        system.assert( controller.getcampaignMemberStatuses().size() >0);
        system.assert(controller.getEmailTemplateFolders().size() >0);
        system.assertEquals(controller.getStep() ,'1');
        system.assertEquals( controller.getEmailingStatus(),'');
        controller.populateEmailTemplates();
        
        /***process methods**/
        controller.campaignMemberStatus = HAPARA_CONST.CAMPAIGNMEMBER_STATUS_CONFIRMED;
        controller.emailTemplateFolder = 'All';
        controller.emailTemplateId ='none';
        controller.SendEmail();
        controller.emailTemplateId = HAPARA_CONST.SETTING_SCHEDULE.Schedule_Confirmation_Email_Template__c;
        controller.SendEmail();
        controller.reloadResult();
        controller.Cancel();
        
	}
}