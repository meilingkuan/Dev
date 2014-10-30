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
@isTest (SeeAllData=true)
private class Hapara_MessageQueue_Handler_Test2 {

   static testmethod void autitInfo_TestJSON(){
		string multidomains = '[{"number_students": 68, "intervention_enabled": "true", "gplus_enabled": "false", "domain": "school.hapara.com", "sis_enabled": "false", "parentportal_enabled": "false", "rc_enabled": "false", "primary_contact": "info@hapara.com", "isActive": "True", "gmailviewer_enabled": "false"}, '
			+'{"number_students": -1, "intervention_enabled": "true", "primary_contact": "", "gplus_enabled": "false", "domain": "asbindia.org", "sis_enabled": "false", "parentportal_enabled": "false", "rc_enabled": "false", "isActive": "True", "gmailviewer_enabled": "false"},'
			+' {"number_students": -1, "intervention_enabled": "true", "gplus_enabled": "false", "domain": "ismanilla.org", "sis_enabled": "false", "parentportal_enabled": "false", "rc_enabled": "false", "primary_contact": "admin@zawadzki.co.nz", "isActive": "True", "gmailviewer_enabled": "false"}]';
		list<Hapara_MessageQueue_Handler.AuditInfoMessage> auditInfo = Hapara_MessageQueue_Handler.getAuditInfosPerDomain(multidomains)	; 
		system.assert(auditInfo.size()>0);
		TD_Domain__c td = Hapara_MessageQueue_Handler.createAuditInfoMessage(auditInfo[0],null);
		system.assertEquals(td.Student_Domain_Name__c, auditInfo[0].domain);
	}
	
	static testmethod void auditInfo_Create(){
		
		string domain = 'testSF.school.nz';
		string json = '[{"created_by": "wilson.fan@hapara.com",'+
			' "domlist_lastupdate_by": "wilson.fan@hapara.com",'+
			' "number_students": -1,'+
			' "created_dt": "2012-09-17",'+
			' "domain": "'+domain+'", '+
			' "gmailviewer_enabled": "false",'+
			' "intervention_enabled": "true",'+
			' "isActive": "True",'+
			' "gplus_enabled": "false",'+
			' "primary_contact": "admin@zawadzki.co.nz",'+
			' "sis_enabled": "false",'+
			' "deactivation_dt": "2016-09-17",'+
			' "reseller": "",'+
			' "domtype": "demo-hapara",'+
			' "parentportal_enabled": "false",'+
			' "rc_enabled": "false"}]';
		
		MessageQueue__c msg = new MessageQueue__c(
			ApplicationName__c = Hapara_MessageQueue_Handler.MESSAGE_APPLICATIONNAME_DOMAINAUDIT,
			MessageType__c = Hapara_MessageQueue_Handler.MESSAGE_TYPE_AUDITINFO,
			Status__c = Hapara_MessageQueue_Handler.MESSAGE_STATUS_NEW,
			OriginMsgId__c =Hapara_MessageQueue_Test.generateGUID(),
			MessageContent__c = json
		);
		test.startTest();
		insert msg;
		test.stopTest();

		msg = [ 
			SELECT Id, Status__c, ErrorMessage__c, DateCompleted__c
			FROM MessageQueue__c
			WHERE Id = :msg.Id
		];

		System.assertEquals(null, msg.ErrorMessage__c);
		System.assertEquals(Hapara_MessageQueue_Handler.MESSAGE_STATUS_COMPLETED, msg.Status__c);
		System.assertNotEquals(null, msg.DateCompleted__c);	
		
		list<TD_Domain__c> d = [Select Id, Account__c, Gmail_Viewer_Enabled__c, 
			Gplus_Enabled__c, Intervention_Enabled__c, Is_Active__c, Number_Students__c, Parent_Portal_Enabled__c, 
			Primary_Contact__c, RC_Enabled__c, SIS_Enabled__c, Student_Domain_Name__c, 
			Reseller__c, Domain_Type__c, Last_Update_By__c,Activation_Date__c From TD_Domain__c 
			where Student_Domain_Name__c = : domain  limit 1];
		system.assert(d.size()>0);
		
	}
	
	static testmethod void test_auditInfoLinkAccount(){
		string domain = 'testSF.school.nz';
		string json = '[{"created_by": "wilson.fan@hapara.com",'+
			' "domlist_lastupdate_by": "wilson.fan@hapara.com",'+
			' "number_students": -1,'+
			' "created_dt": "2012-09-17",'+
			' "domain": "'+domain+'", '+
			' "gmailviewer_enabled": "false",'+
			' "intervention_enabled": "true",'+
			' "isActive": "True",'+
			' "gplus_enabled": "false",'+
			' "primary_contact": "admin@zawadzki.co.nz",'+
			' "sis_enabled": "false",'+
			' "deactivation_dt": "2016-09-17",'+
			' "reseller": "",'+
			' "domtype": "demo-hapara",'+
			' "parentportal_enabled": "false",'+
			' "rc_enabled": "false"}]';
			
		Account acc = new Account();
        acc.Name = 'test Company';
        acc.BillingCity = 'test street';
        acc.BillingCountry = 'United States';
        acc.BillingState = 'Washington';
        acc.CurrencyIsoCode='USD';
        acc.Website = domain;
        insert acc;
        
        
        
        MessageQueue__c msg2 = new MessageQueue__c(
			ApplicationName__c = Hapara_MessageQueue_Handler.MESSAGE_APPLICATIONNAME_DOMAINAUDIT,
			MessageType__c = Hapara_MessageQueue_Handler.MESSAGE_TYPE_AUDITINFO,
			Status__c = Hapara_MessageQueue_Handler.MESSAGE_STATUS_NEW,
			OriginMsgId__c = Hapara_MessageQueue_Test.generateGUID(),
			MessageContent__c = json
		);
		
		test.startTest();
		insert msg2;
		test.stopTest();

		
		acc= [select No_Students_Sign_Up__c from Account where Id =: acc.Id];
		
		
		msg2 = [
			SELECT Id, Status__c, ErrorMessage__c, DateCompleted__c
			FROM MessageQueue__c
			WHERE Id = :msg2.Id
		];
		System.assertEquals(null, msg2.ErrorMessage__c);
		System.assertEquals(Hapara_MessageQueue_Handler.MESSAGE_STATUS_COMPLETED, msg2.Status__c);
		System.assertNotEquals(null, msg2.DateCompleted__c);	
		
		list<TD_Domain__c> d2 = [Select Id, Account__c, Gmail_Viewer_Enabled__c, 
			Gplus_Enabled__c, Intervention_Enabled__c, Is_Active__c, Number_Students__c, Parent_Portal_Enabled__c, 
			Primary_Contact__c, RC_Enabled__c, SIS_Enabled__c, Student_Domain_Name__c, 
			Reseller__c, Domain_Type__c, Last_Update_By__c,Activation_Date__c From TD_Domain__c 
			where Student_Domain_Name__c = : domain order by createdDate desc limit 1];
		system.assert(d2.size()>0);
		system.assertEquals(d2[0].Account__c, acc.Id);
		system.assertEquals(acc.No_Students_Sign_Up__c, -1);
	}
}