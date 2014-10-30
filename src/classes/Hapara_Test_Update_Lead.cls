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
private with sharing  class Hapara_Test_Update_Lead {

    static testMethod void verifyCreationOfGoogleAppPackAccount() {
        List <Lead> Leads;
                
        // Create a Lead with a Lead Source matching a Campaign
        Lead L1 = new Lead();
        L1.lastname = 'Create_CampaignMember_For_New_Leads';
        L1.firstname = 'Test For1';
        L1.company = 'Company Name';
        L1.leadsource = 'Web'; // Make sure you have an active Campaign with this name
        L1.Lead_Type__c='Google App Pack Prospect';
        L1.Email='mkua001@gmail.com';
        L1.No_of_Students__c=100;
        L1.Invoice_Addressee__c= 'test invoice';
        L1.Invoice_Email__c= 'mkua002@gmail.com';
        System.debug('Inserting Google App Pack Prospect');    
       
       
        Insert L1;
        
        Test.startTest();
        
		String leadId = L1.Id;
		Lead updateL = [Select l.Status, l.Id From Lead l where l.Id = :leadId];
		updateL.Status = 'Made Payment';
		update updateL;
		
		
		Lead testLead = [Select l.Status, l.Id From Lead l where l.Id = :updateL.Id];
		system.AssertEquals('Made Payment', testLead.Status);
		
		
		Lead L2 = new Lead();
        L2.lastname = 'Create_CampaignMember_For_New_Leads';
        L2.firstname = 'Test For2';
        L2.company = 'Company Name';
        L2.leadsource = 'Web'; // Make sure you have an active Campaign with this name
        L2.Lead_Type__c='Google App Pack Prospect';
        L2.Email='mkua002@gmail.com';
        L2.No_of_Students__c=100;
        L2.Invoice_Email__c= 'mkua002@gmail.com';
        System.debug('Inserting Google App Pack Prospect without invoice contact');
        insert L2;
        
               
        String lead2Id = L2.Id;
		Lead updateL2 = [Select l.Status, l.Id From Lead l where l.Id = :lead2Id];
		updateL2.Status = 'Made Payment';
		update updateL2;
		
		
		
		Lead testLead2 = [Select l.Status, l.Id From Lead l where l.Id = :updateL2.Id];
		system.AssertEquals('Made Payment', testLead2.Status);
		
        
        Lead L3 = new Lead();
        L3.lastname = 'Non-google pack';
        L3.firstname = 'Test For2';
        L3.company = 'Company Name';
        L3.leadsource = 'Web'; // Make sure you have an active Campaign with this name
        L3.Lead_Type__c='Reseller Prospect';
        L3.Email='mkua003@gmail.com';
        L3.No_of_Students__c=100;
        L3.Invoice_Email__c= 'mkua002@gmail.com';
        System.debug('InsertingNon-google pack without invoice contact');
        insert L3;
        
        
        
        
		Lead updateL3 = [Select l.Status, l.Id From Lead l where l.Id = :L3.Id];
		updateL3.Status = 'Made Payment';
		update updateL3;
		
		
		Test.stopTest();
		Lead testLead3 = [Select l.Status, l.Id From Lead l where l.Id = :updateL3.Id];
		system.AssertEquals( 'Made Payment', testLead3.Status);
		
    }
}