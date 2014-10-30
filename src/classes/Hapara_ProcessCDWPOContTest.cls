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
private class Hapara_ProcessCDWPOContTest {

    static testMethod void testProcessCDWPOController() {
      	list<Case> obj = [select CaseNumber, Subject, Status, Process__c, Error_Message__c, CreatedDate, closedDate 
      		from case 
      		where    status ='In Progress' OR subject like 'CDW P/O #%' limit 2];
       	//obj[0].status ='In Progress';
       	//update obj;
        PageReference page = new PageReference('/apex/HaparaProcessCDWPOButton');
        Test.setCurrentPage(page);
        ApexPages.StandardSetController stdcontroller = new ApexPages.StandardSetController(obj);
        
        stdcontroller.setSelected(obj);
        
        Hapara_ProcessCDWPOController controller = new Hapara_ProcessCDWPOController(stdcontroller);
        system.debug('****Hapara_ProcessCDWPOContTest: cases size' + controller.getRecordSize() );
        
        system.assert( controller.getCases().size()>0);
        system.assertEquals(controller.getStep(), '1');
        
        System.assertEquals( controller.Process().getUrl(),'/apex/HaparaProcessCDWPOButton');
        
        system.assertEquals(controller.reloadResult(), null);
        
        system.assert(controller.cancel() != null);
        
        PageReference page2 = new PageReference('/apex/HaparaProcessCDWPOSingleButton');
        Test.setCurrentPage(page2);
        ApexPages.StandardController stdcontroller2 = new ApexPages.StandardController(obj[0]);
       
        Hapara_ProcessCDWPOController controller2 = new Hapara_ProcessCDWPOController(stdcontroller2);
        PageReference newPage =  controller2.onload();
         system.assert( newPage.getUrl().contains('HaparaProcessCDWPOButton'));
    }
    

}