@isTest(SeeAllData=true)
private with sharing class  Hapara_WebControllerTest {
	static testmethod void testsaveSignUpforDemo(){
		System.debug('***testsaveSignUpforDemo - begins' );
		PageReference page = new PageReference('/apex/Hapara_WebDemoSignUp');
        Test.setCurrentPage(page);
		Hapara_WebController controller = new Hapara_WebController();
        
        Lead currentLead = controller.getLead();
        controller.getTitle();
        //*******test get methods************/
       	system.assert( controller.getCampaignEvents().size()>0);
       	//****** test save method***/
       	currentlead.FirstName ='test';
       	currentlead.LastName = 'lastname';
       	currentlead.Email = 'Hapara_WebControllerTest@gmail.com';
       	currentlead.Title = 'title';
       	currentlead.Company = '';
       	currentlead.Website = 'domain';
       	currentlead.Industry = 'conference';
       	currentlead.Question_from_Lead__c = 'test';
       	//**********test save*********///
      	system.assert(!controller.saveSignUpforDemo().getUrl().contains(HAPARA_CONST.CUSTOMER_HAPARAWEB_THANKYOU));
       	controller.selectedCountry = 'United States';
       	controller.selectedState = 'California';
       	currentlead.Company = 'Company';
       	currentlead.Email = 'Hapara_WebControllerTest@test.com';
		system.assert(controller.saveSignUpforDemo().getUrl().contains(HAPARA_CONST.CUSTOMER_HAPARAWEB_THANKYOU));
	}
	
	static testmethod void testsaveContactComment(){
		System.debug('***testsaveContactComment - begins' );
		Account testAccount = new Account();
		testAccount.name = 'test company';
		testAccount.Requested_Demo_Session_Date__c = '11:00 AM Wednesday, January 15th 2014 (America/New_York) / 4pm Wednesday, January 15th 2014 (Europe/London)';
		testAccount.BillingCountry = 'United States';
		testAccount.BillingState = 'California';
		testAccount.Type = 'Customer Direct';
		insert testAccount;
		
		Contact testContact = new Contact();
		testContact.firstName = 'test';
		testContact.lastName = 'Contact';
		testContact.email = 'testcontact@test.com';
		testContact.accountid = testAccount.id;
		testContact.Contact_Date_Time_Demo__c = '6:00 PM Wednesday, February 26th 2014';
		insert testContact;
		
		System.debug('***testsaveContactComment - begins' );
		PageReference page = new PageReference('/apex/Hapara_WebDemoSignUp');
        Test.setCurrentPage(page);
		Hapara_WebController controller = new Hapara_WebController();
       
        Lead currentLead = controller.getLead();
        currentlead.FirstName =testContact.FirstName;
       	currentlead.LastName = testContact.LastName;
       	currentlead.Email = testContact.Email;
       	currentlead.Title = 'test';
       	currentlead.Company = testAccount.Name;
       	currentlead.Website = testAccount.website;
       	currentlead.Industry = 'conference';
       	currentlead.Question_from_Lead__c = 'test';
       	currentlead.Country = testAccount.BillingCountry;
       	currentlead.State = testAccount.BillingState;
       	currentlead.Question_from_Lead__c = 'question1';
       	controller.selectedCountry = 'United States';
       	controller.selectedState = 'California';
       	string url = controller.saveSignUpforDemo().getUrl();
        system.assert(url.contains(HAPARA_CONST.CUSTOMER_HAPARAWEB_CUSTOMERENQUIRY));
        
        page = new PageReference(url);
        Test.setCurrentPage(page);
        controller = new Hapara_WebController();
        Contact tempCustomer = controller.getExistingCustomer();
        tempCustomer.Question_Copied_From_Lead__c = currentlead.Question_from_Lead__c ;
        system.assert(controller.saveContactComment().getUrl().contains(HAPARA_CONST.CUSTOMER_HAPARAWEB_THANKYOU));
	}
}