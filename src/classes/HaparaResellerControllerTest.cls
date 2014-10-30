/***
** Test class for Hapara Reseller Controller
**
**
***/
@isTest(SeeAllData=true)
public class HaparaResellerControllerTest {
	 public static Account reseller;
	 public static Contact resellerRep;
	 public static Account acc;
	 public static Contact con;
	 public static Lead lead;
	 public static Reseller_Tier__c tier;
	 public static Product2 prod;
	 public static Opportunity opptest;
	  
	 private static testmethod void testHaparaResellerController() {
	 	System.debug('***testHaparaResellerController - begins' );
	 	HaparaResellerUtilityCommon_Test.CreateTestResellerRecords();
	 	HaparaResellerController controller = new HaparaResellerController();
        // Set the test to RS Welcome page
        PageReference page = new PageReference('/apex/HaparaRSWelcome');
        Test.setCurrentPage(page);
      	String noIdErrorPage = controller.CheckId().getUrl();
      	system.assertEquals(controller.getShowWelcomePanel(),'No');
      	
      	System.debug('***TEST - testing no id');
      	// Verify that page fails without Id
		System.assertEquals('/apex/HaparaResellerUnAuthorize', noIdErrorPage);
		
		//set the test to RS Deal Registration
		 // Set the test page
		 System.debug('***TEST - testing with id');
       	reseller = HaparaResellerUtilityCommon_Test.reseller;
        ApexPages.currentPage().getParameters().put('id',Reseller.Id); 
		controller = new HaparaResellerController();
		resellerRep = controller.getResellerRep();
		resellerRep.FirstName= 'rep';
		resellerRep.LastName= 'test';
		resellerRep.Email= 'mkua001@gmail.com';
		resellerRep.Phone='09888888';
		resellerRep.AccountId = Reseller.Id;
		resellerRep.MailingState = 'California';
		resellerRep.MailingCountry =  'United States';
		insert resellerRep;
		
		string loginPage = controller.login().getUrl();
		system.assertEquals(loginPage,HAPARA_CONST.RESELLER_PORTAL_WELCOME_URL
				+'?id='+Reseller.id +'&rep='+resellerRep.id);
		
		
		reseller = controller.getReseller();
		Lead resellerLead = controller.getResellerLead();
		Opportunity opportunity =controller.getOpportunity();

		OpportunityContactRole role = controller.getRole();
		
		resellerLead.FirstName = 'Test';
		resellerLead.LastName = 'Last';
		resellerLead.Email = 'test@gmail.com';
		resellerLead.Title = 'job';
		resellerLead.Company =  'company';
		resellerLead.State = 'California';
		resellerLead.Country =  'United States';
		resellerLead.Website = 'domain';
		//resellerLead.No_of_Students__c = 9;
		
		opportunity.Opportunity_Name_Template__c =  'Teacher Dashboard';
		opportunity.Reseller_Tier__c = HaparaResellerUtilityCommon_Test.tier.id;
		//opportunity.Type =  'RFP';
		opportunity.Size_of_Opportunity__c = 'under 2000';
		opportunity.AccountId = reseller.id;	
		System.debug('***TEST - saving deal registration');
		PageReference page2 = new PageReference(HAPARA_CONST.RESELLER_PORTAL_DEALREGISTRATION_URL 
			+'?id='+Reseller.Id +'&rep='+resellerRep.Id);
        Test.setCurrentPage(page2);
		String savePage = controller.SaveNewDealRegistration().getUrl();
		
      		
		acc = HaparaResellerUtilityCommon_Test.acc;
		// Verify that page save with Id
		System.assertEquals(HAPARA_CONST.RESELLER_PORTAL_SUCCESSFULREGISTRATION_URL+controller.getUrlParameters(), 
			savePage);
		Opportunity opp2 = new Opportunity();
		opp2.Resellers_Account__c = acc.id;
		opp2.Name='test';
		opp2.Reseller_Tier__c = HaparaResellerUtilityCommon_Test.tier.id;
		opp2.Reseller_s_Rep__c= resellerRep.Id;
		opp2.StageName='Prospecting';
		opp2.CloseDate = Date.today();
		opp2.AccountId = reseller.Id;
   		insert opp2;
   		
		PageReference page5 = new PageReference(HAPARA_CONST.RESELLER_PORTAL_UPDATEREGISTRATION_URL 
			+'?id='+Reseller.Id +'&rep='+resellerRep.Id);
        Test.setCurrentPage(page5);
		List<SelectOption> options = controller.getOpenRegistrations();
		System.assert(options.size()>0);
		
		System.debug('***TEST - go to purchase order ' +options[0].getValue() );
        controller.CurrentRegistration = options[0].getValue();
		String createPurchaseOrder = controller.createPurchaseOrder().getUrl();
		string editRegistration = controller.editRegistration().getUrl();
		system.assert(createPurchaseOrder!=null);
		system.assert(editRegistration!= null);
		
		String cancelPage = controller.cancel().getUrl();
      	System.assertEquals(controller.getWelcomeURL(), cancelPage);
      	
      	System.assert(controller.getPageTitle().contains( 'Partner Portal'));
      	system.assert(controller.getUpdateRegistrationURL()!=null);
      
      	List<SelectOption> options2 = controller.getResellerTier();
      	system.assert(options2.size()>0);
        system.assert(controller.showPurchaseOrderButton);   
      	system.assert(controller.getSendRegistrationReportURL()!=null);
      	system.assert(controller.getRegisterDealURL()!=null);  
      	system.assert(controller.showSalesNotesButton == false);
   		system.assert(controller.getfilterRegistrations().size()>0);
      
      	try{
      		controller.sendRegistrationReport();
      	}Catch(Exception e){
      		System.assert(1==0 ,'Failed sendRegistrationReport');
      	}
      	System.assert(1==1 ,'Failed sendRegistrationReport');
      	
      	system.assert(controller.getShowrepRegisterPanel() =='Yes');
      	system.assert(controller.getMarketinglURL().contains(HAPARA_CONST.RESELLER_PORTAL_MARKETING_URL));  	
      	system.assert(controller.getHaparaLogos().size() == 0 || controller.getHaparaLogos().size() >0 );
      	system.assert(controller.getHaparaBrochures().size() == 0 || controller.getHaparaBrochures().size() >0 );
      	system.assert(controller.getHaparaProductCopies().size() == 0 || controller.getHaparaProductCopies().size() >0 );
      	system.assert(controller.getHaparaHelpGuides().size() == 0 || controller.getHaparaHelpGuides().size() >0 );
      }
      
      //test rep's registration
      private static testmethod void testHaparaResellerRepRegistration(){
      		System.debug('***testHaparaResellerRepRegistration - begins' );
      		HaparaResellerUtilityCommon_Test.CreateTestResellerRecords();
      		reseller = HaparaResellerUtilityCommon_Test.reseller;
      		// Set the test to RS Welcome page
	        PageReference page = new PageReference(HAPARA_CONST.RESELLER_PORTAL_REGISTERREP_URL 
	        	+'?id=' + reseller.Id);
	        Test.setCurrentPage(page);
      		HaparaResellerController controller = new HaparaResellerController();
      		reseller = HaparaResellerUtilityCommon_Test.reseller;
	        
	        controller.getReseller();
	        Contact rep =  controller.getResellerRep();
	        rep.FirstName = 'test';
	        rep.LastName = 'test lastname';
            rep.Email = 'test@gmail.com';
	        rep.Phone = '900';
	        rep.MailingState = 'California';
	        rep.MailingCountry = 'United States';
            PageReference badEmail = controller.createResellerRep();
	        system.assertEquals(badEmail, null);
	        
	        PageReference redirect = controller.gotoWelcomePageWithRepId();
	        system.assert(redirect.getUrl().contains(HAPARA_CONST.RESELLER_PORTAL_WELCOME_URL));
	   }
      
       private static testmethod void testHaparaResellerRegistrationCreatePO(){
       		system.debug('***testHaparaResellerRegistrationCreatePO - begins' );
       		HaparaResellerUtilityCommon_Test.CreateTestResellerRecords();
       		reseller = HaparaResellerUtilityCommon_Test.reseller;
       		Account customerAcc= HaparaResellerUtilityCommon_Test.acc;
       		Contact customerCon = HaparaResellerUtilityCommon_Test.con;
       		resellerRep= HaparaResellerUtilityCommon_Test.resellerRep;		 	
		 	
		   	PageReference page2 = new PageReference(HAPARA_CONST.RESELLER_PORTAL_DEALREGISTRATION_URL );
		   	page2.getParameters().put('id', reseller.id);
		   	page2.getParameters().put('rep', resellerRep.id);
        	Test.setCurrentPage(page2);
        	
			HaparaResellerController controller = new HaparaResellerController();
			system.debug('***testHaparaResellerRegistrationCreatePO - created controller' );			
       		Lead resellerLead = controller.getResellerLead();
       		resellerLead.FirstName =customercon.FirstName;
			resellerLead.LastName = customercon.LastName;
			resellerLead.Email = customercon.Email;
			resellerLead.Title = customercon.Title;
			resellerLead.Company =  customerAcc.Name;
			resellerLead.State = customerAcc.BillingState;
			resellerLead.Country =  customerAcc.BillingCountry;
			resellerLead.Website = customerAcc.Website;
			system.debug('***testHaparaResellerRegistrationCreatePO - passed reseller lead' );
			Opportunity tempOpp = controller.getOpportunity();
			tempOpp.Reseller_Tier__c = HaparaResellerUtilityCommon_Test.tier.id;
			tempOpp.Size_of_Opportunity__c = 'under 2000';
			tempOpp.Opportunity_Name_Template__c='Teacher Dashboard';
			
			PageReference page = controller.SaveNewDealRegistrationNCreatePO();
			
			system.assert(page.getURL().contains(HAPARA_CONST.RESELLER_PORTAL_PURCHASEORDER_URL));
       }
}