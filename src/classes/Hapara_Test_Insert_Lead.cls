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
private with sharing class Hapara_Test_Insert_Lead {

    static testMethod void verifyAddingLeadToCampaign() {
        List <Lead> Leads;
                
        // Create a Lead with a Lead Source matching a Campaign
        Lead L1 = new Lead();
        L1.lastname = 'Create_CampaignMember_For_New_Leads';
        L1.firstname = 'Test For1';
        L1.company = 'Company Name';
        L1.leadsource = 'Web'; // Make sure you have an active Campaign with this name
        L1.Lead_Type__c='Google App Pack Prospect';
        L1.No_of_Students__c = 1.0;
        System.debug('Inserting Google App Pack Prospect');    
        insert L1;
        String holder = L1.id;
         
        List <CampaignMember> cm = [select id from CampaignMember where leadid = :holder limit 1];
        system.AssertEquals(1,cm.size());
         
        // Create a Lead without a Lead Source matching a Campaign
        Lead L2 = new Lead();
        L2.lastname = 'Create_CampaignMember_For_New_Leads';
        L2.firstname = 'Test For2';
        L2.company = 'Company Name';
        L2.leadsource = 'No Matching Campaign'; // Make sure you DON'T have an active Campaign with this name 
        L2.No_of_Students__c = 1.0;
        System.debug('Inserting NON Google App Pack Prospect');     
        insert L2;
         
        String holder2 = L2.id;
         
        List <CampaignMember> cm2 = [select id from CampaignMember where leadid = :holder2 limit 1];
        system.AssertEquals(0,cm2.size());
    }
}