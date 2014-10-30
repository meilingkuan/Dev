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
private class Hapara_ProcessCDWPOHandler_Test {

    static testMethod void testHapara_ParsingCDWPOMessage() {
        List<Case> obj = [select Id, Subject, Description, status from case 
        	where subject like 'CDW P/O #%' order by createddate desc limit 1];
        System.debug('***Hapara_ProcessCDWPOHandler_Test() - ' + obj.Size());
        String deserialised;
		Hapara_ProcessCDWPOHandler handler = new Hapara_ProcessCDWPOHandler();
		string content = obj[0].Description;
		handler.parseCaseDescription(obj[0].Description);
		handler.parseCustomerNameAndAddress(content);
		
		deserialised = handler.deserialCaseMessageContent();
		System.assert( deserialised.length() >0);
		System.debug('***Hapara_ProcessCDWPOHandler_Test parseCustomerNameAndAddress: ' +deserialised );
		
		handler.parsePO(content);
		deserialised = handler.deserialCaseMessageContent();
		System.assert( deserialised.length() >0);
		System.debug('***Hapara_ProcessCDWPOHandler_Test parsePO: ' +deserialised );
		
		string productlines = content.substring(content.indexOf('LINE ORDER'), content.indexOf('Total Order',content.indexOf('LINE ORDER')));
		list<string> orderlines = productlines.split('-------------------------------------------------------------------------------------------------');
		system.debug('***parseCaseDescription: product lines found=' + orderlines.size());
		for(integer i=1; i<orderlines.size();i++ )
			handler.parseProduct(orderlines[i]);
		deserialised = handler.deserialCaseMessageContent();
		System.assert( deserialised.length() >0);
		System.debug('***Hapara_ProcessCDWPOHandler_Test parseProduct: ' +deserialised );
		
		handler.parseResellerAndContactDetails(content);
		deserialised = handler.deserialCaseMessageContent();
		System.assert( deserialised.length() >0);
		System.debug('***Hapara_ProcessCDWPOHandler_Test parseProduct: ' +deserialised );
    }
    
    static testMethod void testHapara_ParsingCDWPOCreateRecords() {
    	//where subject = 'CDW P/O #KUZ0217'
    	//where subject like 'CDW P/O #%'
    	List<Case> obj = [select Id, Subject, Description, status,createdDate from case 
    		where subject like  'CDW P/O #%' and status = 'Closed' order by createdDate desc limit 2];
		obj[0].status = 'In Progress';
		update obj;
		Hapara_ProcessCDWPOHandler handler = new Hapara_ProcessCDWPOHandler(obj);
		handler.initialise();
		System.assertEquals(obj[0].status, 'In Progress');
		handler.processMessage();
		handler.procesRecords(null);
		System.assert(handler.finalise()>0);
    }
    
    static testMethod void testHapara_ParsingCDWPOProcess() {
    	//where subject = 'CDW P/O #KWX8084'
    	//where subject like 'CDW P/O #%'
    	List<Case> obj = [select Id, Subject, Description, status,createdDate from case 
    		where subject like 'CDW P/O #%' and status ='Closed' order by createddate desc limit 2];
		obj[0].status = 'In Progress';
		update obj;
		List<Id> ids = new List<Id>();
		for(Case message : obj){
			ids.add(message.Id);
		}
		Boolean notfailed = true;
		try{
			Hapara_ProcessCDWPOHandler.process(ids,null);
		}catch(Exception e){
			notfailed = false;
		}
		System.assert(notfailed);
    }
    
}