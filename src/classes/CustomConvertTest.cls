@isTest(SeeAllData=true)
private class CustomConvertTest {

	static Lead generateTestLead() {

		// Create a lead for testing the conversion process
        Lead testLead = new Lead(
        	FirstName = 'First',
        	LastName = 'Last',
        	Email = 'user@test.com',
        	Lead_Type__c = 'School Prospect',
        	No_of_Students__c = 1
        );
        insert testLead;
        return testLead;
	}

	/**
	 * Ellaborate high level use test to cover the largest number of code paths. Subsequent tests will
	 * be both simplified and more targeted to specific code paths.
	 */
    static testmethod void positiveTest() {
        
        Lead testLead = generateTestLead();

        // Set the test page
        PageReference page = new PageReference('/apex/CustomConvert');
        page.getParameters().put('id', testLead.Id);
        Test.setCurrentPage(page);

        // Load the controller
        CustomConvertController ctrl = new CustomConvertController();

        // Fill in Convert Lead section
        ctrl.sendEmailToTheOwner = true;
        ctrl.accountId = ctrl.getAccountNameOptions()[0].getValue();
        ctrl.opportunityName = ctrl.getOpportunityNameOptions()[1].getValue(); // the first option is none, the second is an actual template value
        ctrl.opportunity.Opportunity_Name_Template__c = ctrl.getOpportunityNameOptions()[1].getValue();
        ctrl.opportunity.stageName = 'Prospecting';
        ctrl.convertedStatus = ctrl.getConvertedStatusOptions()[0].getValue();

        // Fill in Task Information section
        ctrl.task.subject = 'task';
        ctrl.task.activityDate = Date.today().addDays(2);
        ctrl.task.description = 'description';

        // Fill in Additional Information section
        ctrl.task.status = 'In Progress';
        ctrl.task.priority = 'High';
        ctrl.taskSendNotificationEmail = true;

        // Fill in Reminder section
        ctrl.task.isReminderSet = true;
        ctrl.task.reminderDateTime = DateTime.now().addDays(1);

        // Click the convert button
        PageReference redirect = ctrl.convert();
        System.assertNotEquals(null, redirect);
    }
    
    static testmethod void testRetUrl() {

        Lead testLead = generateTestLead();

        // -- Test with retUrl

        // Set the test page
        PageReference page = new PageReference('/apex/CustomConvert');
        page.getParameters().put('id', testLead.Id);
        page.getParameters().put('retUrl', 'http://www.google.com/');
        Test.setCurrentPage(page);

        // Load the controller
        CustomConvertController ctrl = new CustomConvertController();

        // Click cancel button
        PageReference redirect = ctrl.cancel();
        System.assertEquals('http://www.google.com/', redirect.getUrl());

        // -- Test without retUrl

        // Set the test page
        page = new PageReference('/apex/CustomConvert');
        page.getParameters().put('id', testLead.Id);
        Test.setCurrentPage(page);

        // Load the controller
        ctrl = new CustomConvertController();

        // Click cancel button
        redirect = ctrl.cancel();
        System.assertEquals('/'+testLead.id, redirect.getUrl());
    }
    
    static testmethod void testMissingInvalidId() {

        Lead testLead = generateTestLead();

        // -- Test missing id
        // Set the test page
        PageReference page = new PageReference('/apex/CustomConvert');
        Test.setCurrentPage(page);

        // Load the controller
        CustomConvertController ctrl = new CustomConvertController();
        System.assertNotEquals(null, ctrl.preloadError);

        // -- Test invalid id

        // Set the test page
        page = new PageReference('/apex/CustomConvert');
        page.getParameters().put('id', 'invalidvalue');
        Test.setCurrentPage(page);

        // Load the controller
        ctrl = new CustomConvertController();
        System.assertNotEquals(null, ctrl.preloadError);
    }

    static testmethod void testAlreadyConverted() {

        Lead testLead = generateTestLead();

        // Set the test page
        PageReference page = new PageReference('/apex/CustomConvert');
        page.getParameters().put('id', testLead.Id);
        page.getParameters().put('retUrl', '/'+testLead.Id);
        Test.setCurrentPage(page);

        // Load the controller
        CustomConvertController ctrl = new CustomConvertController();

        // Fill in Convert Lead section
        ctrl.sendEmailToTheOwner = true;
        ctrl.accountId = ctrl.getAccountNameOptions()[0].getValue();
        ctrl.opportunityName = ctrl.getOpportunityNameOptions()[1].getValue(); // the first option is none, the second is an actual template value
        ctrl.opportunity.Opportunity_Name_Template__c = ctrl.getOpportunityNameOptions()[1].getValue();
        ctrl.opportunity.stageName = 'Prospecting';
        ctrl.convertedStatus = ctrl.getConvertedStatusOptions()[0].getValue();

        // Fill in Task Information section
        ctrl.task.subject = 'task';
        ctrl.task.activityDate = Date.today().addDays(2);
        ctrl.task.description = 'description';

        // Fill in Additional Information section
        ctrl.task.status = 'In Progress';
        ctrl.task.priority = 'High';
        ctrl.taskSendNotificationEmail = true;

        // Fill in Reminder section
        ctrl.task.isReminderSet = true;
        ctrl.task.reminderDateTime = DateTime.now().addDays(1);

        // Click the convert button
        PageReference redirect = ctrl.convert();

        // Test that trying to load this page again causes an error
        ctrl = new CustomConvertController();
        System.assertNotEquals(null, ctrl.preloadError);
    }

    static testmethod void testExistingAccount() {

    	Lead testLead = generateTestLead();

        // Set the test page
        PageReference page = new PageReference('/apex/CustomConvert');
        page.getParameters().put('id', testLead.Id);
        page.getParameters().put('retUrl', '/'+testLead.Id);
        Test.setCurrentPage(page);

        // Load the controller
        CustomConvertController ctrl = new CustomConvertController();

        // Fill in Convert Lead section
        ctrl.accountId = ctrl.getAccountNameOptions()[0].getValue();
        ctrl.doNotCreateOpportunity = true;
        ctrl.convertedStatus = ctrl.getConvertedStatusOptions()[0].getValue();

        // Click the convert button
        PageReference redirect = ctrl.convert();
        System.assertNotEquals(null, redirect);

        // Generate a new lead and do over
        testLead = generateTestLead();
        page = new PageReference('/apex/CustomConvert');
        page.getParameters().put('id', testLead.Id);
        Test.setCurrentPage(page);

        // We should have the option to merge with the new account.
        ctrl = new CustomConvertController();

        // Get the converted account record
        Account convertedAccount = [SELECT Id, Name, FirstName, LastName FROM Account WHERE FirstName = 'First' AND LastName = 'Last'];

        // Make sure it's on the merge list
      	Boolean found = false;
        for (SelectOption option : ctrl.getAccountNameOptions()) {
        	if (option.getValue() == String.valueOf(convertedAccount.Id)) {
        		found = true;
        	}
        }
        System.assertEquals(true, found);

        // Then select it and convert again
        ctrl.accountId = convertedAccount.id;
        ctrl.doNotCreateOpportunity = true;
        ctrl.convertedStatus = ctrl.getConvertedStatusOptions()[0].getValue();

        redirect = ctrl.convert();
        System.assertNotEquals(null, redirect);
    }

    static testmethod void testMergeUnlistedAccount() {

    	Lead testLead = generateTestLead();

    	Account testAccount = new Account(
    		Name = 'test'
 		);
    	insert testAccount;

        // Set the test page
        PageReference page = new PageReference('/apex/CustomConvert');
        page.getParameters().put('id', testLead.Id);
        Test.setCurrentPage(page);

        // Load the controller
        CustomConvertController ctrl = new CustomConvertController();
        ctrl.getAccountNameOptions();

        // Select the unrelated account in lookup field
        ctrl.opportunity.accountId = testAccount.Id;
        ctrl.addAccountNameOption();
        ctrl.addAccountNameOption(); // do this twice...

        // Assert the new account has been added to the list
        Boolean found = false;
        for (SelectOption option : ctrl.getAccountNameOptions()) {
        	if (option.getValue() == String.valueOf(testAccount.Id)) {
        		if (found == true) {
        			System.assert(false, 'merged account was added to the account options more than once');
        		} else {
        			found = true;
        		}
        	}
        }
        System.assertEquals(true, found);

        // Fill in Convert Lead section
        ctrl.accountId = ctrl.getAccountNameOptions()[0].getValue();
        ctrl.doNotCreateOpportunity = true;
        ctrl.convertedStatus = ctrl.getConvertedStatusOptions()[0].getValue();

        // Click the convert button
        PageReference redirect = ctrl.convert();
        System.assertNotEquals(null, redirect);
    }

    static testmethod void testErrors() {
        
        Lead testLead = generateTestLead();

        // Set the test page
        PageReference page = new PageReference('/apex/CustomConvert');
        page.getParameters().put('id', testLead.Id);
        Test.setCurrentPage(page);

        // Load the controller
        CustomConvertController ctrl = new CustomConvertController();

        // Fill in Convert Lead section
        ctrl.sendEmailToTheOwner = true;
        ctrl.accountId = 'none';
        ctrl.opportunityName = null; // the first option is none, the second is an actual template value
        ctrl.opportunity.stageName = null;
        ctrl.convertedStatus = ctrl.getConvertedStatusOptions()[0].getValue();

        // Fill in Task Information section
        ctrl.task.subject = 'task';
        ctrl.task.activityDate = Date.today().addDays(2);
        ctrl.task.description = 'description';

        // Fill in Additional Information section
        ctrl.task.status = null;
        ctrl.task.priority = null;
        ctrl.taskSendNotificationEmail = true;

        // Fill in Reminder section
        ctrl.task.isReminderSet = true;
        ctrl.task.reminderDateTime = null;

        // Click the convert button
        PageReference redirect = ctrl.convert();
        System.assertEquals(null, redirect);
    }
}