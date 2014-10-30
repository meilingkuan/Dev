@isTest(SeeAllData=true)
public  class HaparaResellerRegistrationTest {

	private static testmethod void testSaveNotes() {
       		System.debug('***testSaveNotes - begins reseller opporuntiy with and existing Customer account' );
       		HaparaResellerUtilityCommon_Test.CreateTestResellerRecords();
       		//create opportunity data to test
       		List <Campaign> campaign = [select id, name from Campaign where name = :'Reseller/ Referral' limit 1];
       		RecordType resellerType = [SELECT Id FROM RecordType where DeveloperName = 'Reseller_Opportunity'];
			Opportunity opp =new Opportunity();			
			opp.Opportunity_Name_Template__c =  'Teacher Dashboard';
			Reseller_Tier__c tier = [select id from Reseller_Tier__c limit 1];
			opp.Reseller_Tier__c = tier.id;
			opp.Size_of_Opportunity__c = 'under 2000';
			opp.AccountId = HaparaResellerUtilityCommon_Test.reseller.id;	
			opp.StageName = 'Approved Registration';
			opp.CloseDate= Date.Today().addDays(90);
			opp.Probability=80;		
			opp.CampaignId=campaign[0].Id;
			opp.LeadSource= 'Reseller Deal Registration';		
			opp.Reseller_s_Rep__c = HaparaResellerUtilityCommon_Test.ResellerRep.Id;	
			opp.CurrencyIsoCode= HaparaResellerUtilityCommon_Test.reseller.CurrencyIsoCode;
			opp.RecordTypeId = resellerType.Id;
			opp.Resellers_Account__c= HaparaResellerUtilityCommon_Test.acc.id;
			opp.Reseller_s_Contact__c = HaparaResellerUtilityCommon_Test.con.id;
			opp.Name = HaparaResellerUtilityCommon_Test.acc.Name;
			insert opp;
			
			//test controller
       		HaparaResellerRegistrationController controller = new HaparaResellerRegistrationController();
       		PageReference page = new PageReference('/apex/HaparaRSWelcome');
	        Test.setCurrentPage(page);
	        //no id passed 
	      	String noIdErrorPage = controller.CheckId().getUrl();
			System.assertEquals('/apex/HaparaResellerUnAuthorize', noIdErrorPage);
			//test cancel
			PageReference cancelPage = controller.cancel();
			system.assert(cancelPage.getUrl().contains(HAPARA_CONST.RESELLER_PORTAL_UPDATEREGISTRATION_URL));
			
			//test load current activity
			string url = HAPARA_CONST.RESELLER_PORTAL_EDITREGISTRATION_URL
				 + '?id='+HaparaResellerUtilityCommon_Test.Reseller.Id
				 + '&rep=' + HaparaResellerUtilityCommon_Test.ResellerRep.Id
				 + '&activityid=' + opp.Id;
		    PageReference getRegistration = new PageReference(url);
		    
	        Test.setCurrentPage(getRegistration);
			controller = new HaparaResellerRegistrationController();
			controller.CheckId();
			Opportunity tempObject = controller.getTempObject();
			tempObject.CloseDate = date.today();
			tempObject.Description = 'test notes';
			tempobject.Opportunity_Name_Template__c ='Call';
			
	      	PageReference savedNotes = controller.saveSalesNotes();
	      	system.assert(savedNotes.getUrl().contains(HAPARA_CONST.RESELLER_PORTAL_EDITREGISTRATION_URL));
       		list<HaparaResellerRegistrationController.CallHistory> callhistory = controller.getCallHistory();
       		system.assert(callhistory.size()>0);
       		
       		system.assert(controller.getRegistration() != null);
       		system.assert(controller.getResellerLead() != null);
       		system.assert(controller.getCallType().size()>0);
       		system.assert(controller.getPurchaseOrderURL().contains(HAPARA_CONST.RESELLER_PORTAL_PURCHASEORDER_URL));
       		system.assert(controller.getWelcomeURL().contains(HAPARA_CONST.RESELLER_PORTAL_WELCOME_URL));
       		system.assert(controller.getEditRegistrationURL().contains(HAPARA_CONST.RESELLER_PORTAL_EDITREGISTRATION_URL));
       		system.assert(controller.getPageTitle().contains('Partner Portal'));
       		HaparaResellerRegistrationController.CallHistory history = new HaparaResellerRegistrationController.CallHistory();
       		history.ActivityDate =date.today();
       		history.Notes = 'TEST';
       		history.TypeOfCall = 'Call';
       		system.assert(history.getActivityDateFormatted() != null);
       }
       
       	private static testmethod void testSubmitPurchaseOrder() {
       		System.debug('***testSubmitPurchaseOrder - begins' );
       		HaparaResellerUtilityCommon_Test.CreateTestResellerRecords();
       		//create opportunity data to test 
       		List <Campaign> campaign = [select id, name from Campaign where name = :'Reseller/ Referral' limit 1];
       		RecordType resellerType = [SELECT Id FROM RecordType where DeveloperName = 'Reseller_Opportunity'];
			Opportunity opp =new Opportunity();			
			opp.Opportunity_Name_Template__c =  'Teacher Dashboard';
			Reseller_Tier__c tier = [select id from Reseller_Tier__c where IsActive__c = true and Commission__c=30 limit 1];
			opp.Reseller_Tier__c = tier.id;
			opp.Size_of_Opportunity__c = 'under 2000';
			opp.AccountId = HaparaResellerUtilityCommon_Test.reseller.id;	
			opp.StageName = 'Approved Registration';
			opp.CloseDate= Date.Today().addDays(90);
			opp.Probability=80;		
			opp.CampaignId=campaign[0].Id;
			opp.LeadSource= 'Reseller Deal Registration';		
			opp.Reseller_s_Rep__c = HaparaResellerUtilityCommon_Test.ResellerRep.Id;	
			opp.CurrencyIsoCode= HaparaResellerUtilityCommon_Test.reseller.CurrencyIsoCode;
			opp.RecordTypeId = resellerType.Id;
			opp.Resellers_Account__c= HaparaResellerUtilityCommon_Test.acc.id;
			opp.Reseller_s_Contact__c = HaparaResellerUtilityCommon_Test.con.id;
			opp.Name = HaparaResellerUtilityCommon_Test.acc.Name;
			insert opp;
			
			//test controller
       		PageReference page = new PageReference(HAPARA_CONST.RESELLER_PORTAL_PURCHASEORDER_URL 
       			+'?id='+HaparaResellerUtilityCommon_Test.reseller.Id
       			+'&rep=' +HaparaResellerUtilityCommon_Test.resellerRep.Id
       			+'&activityid='+opp.Id
       			);
	        Test.setCurrentPage(page);
	        HaparaResellerRegistrationController controller = new HaparaResellerRegistrationController();
	        system.assert( controller.CheckId()==null);
	       
	     	/*** test get method***/   
	        system.assert(controller.getAttachment()!=null);
	        system.assert( controller.getRegistration() !=null);
	        system.assert(controller.getPrimaryRep()!= null); 	   
			
			/***Populate the PO form with values**/
			Lead lead = controller.getResellerLead();
			lead.FirstName = 'test';
			lead.LastName = 'test lastnaem';
			lead.Company = 'test company';
			lead.Street = 'street w';
			lead.City = 'cite';
			lead.State='California';
			lead.PostalCode = 'postal code';
			lead.Country= 'United States';
			lead.Website = 'gmail.com';
			
			Hapara_Invoice__c invoice = controller.getInvoice();
			invoice.Reseller_PO__c = 'PO12';
			invoice.Customer_PO__c = 'CO12';
			
			Attachment attach = controller.getAttachment();
			attach.Body= blob.valueOf('');
			attach.ContentType='pdf';
			attach.Name = 'filnea.pdf';
			
			Contact rep = controller.getPrimaryRep();
			rep.FirstName = 'testrep';
			rep.LastName = 'testlast';
			rep.Email='test@gmail.com';
			
			/*** test order line methods**/
			controller.resetOrderLines();
			HaparaResellerRegistrationController.OrderLineItem lineItem = controller.getLineItem();		
			system.assert(lineItem!= null);    
			list<SelectOption>options = controller.getActiveProductsOptions();
	        system.assert(options.size()>1);
			controller.selectedPriceEntryBook = options[1].getValue();
			system.assert(controller.populateProductDetails() == null);
			lineItem.Quantity = 10;
			if(lineItem.editableSubPeriod)
				lineItem.SubscriptionPeriod = '2';
			controller.saveOrderLine();
			system.assert(lineItem.lineNo >0);
			page.getParameters().put('deleteOrderLineNo',lineItem.lineNo.format());
			controller.deleteOrderLine();
			
			options = controller.getActiveProductsOptions();
			controller.selectedPriceEntryBook = options[1].getValue();
			controller.populateProductDetails();
			lineItem = controller.getLineItem();
			lineItem.Quantity = 10;
			if(lineItem.editableSubPeriod)
				lineItem.SubscriptionPeriod = '2';
			controller.saveOrderLine();
			system.assert(controller.savePurchaseOrder()== null);
			system.assertEquals(controller.getViewPurchaseOrderForm(), false);
       	}
}