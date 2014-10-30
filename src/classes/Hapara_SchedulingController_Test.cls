@isTest(SeeAllData=true)
public class Hapara_SchedulingController_Test {
	static Contact con;
	static Campaign cam;
	static Lead ld;
	
	
	static testMethod void testCreateSchedulingCampaigns(){ 
		Hapara_SchedulingHandler_Test.createTestSchedulingRecord();
		con = Hapara_SchedulingHandler_Test.testContact;
		cam = Hapara_SchedulingHandler_Test.testCampaign;
		ld = Hapara_SchedulingHandler_Test.testLead;
		PageReference page = new PageReference(Hapara_const.CUSTOMER_PORTAL_SCHEDULINGCONFIRM_URL);
        Test.setCurrentPage(page);
        Hapara_SchedulingController controller = new Hapara_SchedulingController();
        //**********test checkContactId()**************/
        system.assertEquals(controller.checkContactId().getUrl(),HAPARA_CONST.CUSTOMER_PORTAL_UNAUTHOIZE_URL );
        page.getParameters().put('id', con.Id);
        page.getParameters().put('type', 'Contact'); 
        system.assert(controller.checkContactId()==null );
        controller = new Hapara_SchedulingController();
        page.getParameters().put('id', ld.Id);
        page.getParameters().put('type', 'Lead');
        system.assert(controller.checkContactId()==null );
        
        //*************Test retrieval methods*******************/
        system.assert(controller.getCampaigns().size() >0);
        system.assert(controller.getDemoSession().length()>0);
        system.assert(controller.getScheduleMsgFormURL().contains(Hapara_const.CUSTOMER_PORTAL_SCHEDULINGCONFIRM_MSG_URL));
        //************Test setting the form values ************/
        Contact temp = controller.getTempContact();
       
        controller.selectedContactDateTimeDemo = cam.Demo_Date_and_Time__c.format();
        controller.selectedContactTimeZone = 'America/Los_Angeles';
        controller.selectedCountry = 'United States';
        controller.selectedState ='California';
        temp.Requested_Demo_Session__c = true;
        temp.How_did_you_hear_about_us__c = 'Conference';
        temp.Phone = '0999999';
        temp.MailingStreet = 'street';
        temp.MailingCity = 'Palo Alto';
        temp.MailingPostalCode = '9090';
        
        CampaignMember newbooking = controller.getNewBooking();
        newbooking.Contact_Question__c = 'Ask a question';
        newbooking.Invite_Colleague_Emails__c  = 'testcontact2@gmail.com' ;
       
       //**************Test book session***********************/
       system.assert(controller.bookSession().getUrl().contains(Hapara_const.CUSTOMER_PORTAL_SCHEDULINGCONFIRM_MSG_URL));
       temp.Requested_Demo_Session__c = false;
       controller.selectedCampaignId = cam.id;
       system.assert(controller.bookSession().getUrl().contains(Hapara_const.CUSTOMER_PORTAL_SCHEDULINGCONFIRM_MSG_URL));
       system.assert(controller.getCampaigns().size() >0);
        newbooking.Invite_Colleague_Emails__c  = 'testcontact4@gmail.com' ;
       system.assert(controller.bookSession().getUrl().contains(Hapara_const.CUSTOMER_PORTAL_SCHEDULINGCONFIRM_MSG_URL));
       //************test redirect methods ***************************/
       system.assert(controller.cancelSession().getUrl().contains(Hapara_const.CUSTOMER_PORTAL_SCHEDULINGCONFIRM_MSG_URL));
       system.assert(controller.backToConfirmPage().getUrl().contains(Hapara_const.CUSTOMER_PORTAL_SCHEDULINGCONFIRM_URL));
       
	}
}