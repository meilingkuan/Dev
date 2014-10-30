/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(SeeAllData=true)
private class Hapara_CustomerProductRegTest {

    static testMethod void testCustomerProductRegController() {
    	Hapara_CustomerProductRegController controller = new Hapara_CustomerProductRegController();
        // Set the test to RS Welcome page
        PageReference page = new PageReference('/apex/HaparaCustomerProductRegistration');
        Test.setCurrentPage(page);
      	String noIdErrorPage = controller.CheckId().getUrl();
      	System.debug('***TEST - testing no id');
      	// Verify that page fails without Id
		System.assertEquals('/apex/HaparaCustomerUnAuthorize', noIdErrorPage);
		
       	Account a = new Account();
		a.RecordTypeId = '01290000000ONfs';
		a.Name='TEst account';
		insert a;
		Contact c = new Contact();
		c.FirstName = 'test';
		c.LastName='last';
		c.Email='test@gmail.com';
		c.AccountId= a.Id;
		insert c;
		Sandbox_Register__c s = new Sandbox_Register__c();
		s.Account_Id__c = a.Id;
		s.Class_ID__c = 'test class';
		s.Login__c = 'test@gmail.com';
		s.Password__c = 'test password';
		s.Customer_Contact__c = c.id;
		insert s;
		
		// Set the test page
		System.debug('***TEST - testing with id');
        PageReference page2 = new PageReference('/apex/HaparaCustomerProductRegistration');
        Test.setCurrentPage(page);
        ApexPages.currentPage().getParameters().put('id',s.Id);
        ApexPages.currentPage().getParameters().put('code','Sandbox');
		controller = new Hapara_CustomerProductRegController();
		
		Hapara_Term_Conditions__c tNc = controller.getTermAndConditions();
		Boolean r = controller.getRegistration();
		
		String savePage = controller.setAgreedTermAndConditions().getUrl();
		// Verify that page agreed
		System.assertEquals('/apex/HaparaCustomerProductRegSucessful?code=Sandbox&id='+s.id, savePage);
		
		String cancelPage = controller.cancel().getUrl();
		// Verify that page agreed
		System.assertEquals('/apex/HaparaCustomerProductRegCancel?code=Sandbox&id='+s.id, cancelPage);
		
		
    }
}