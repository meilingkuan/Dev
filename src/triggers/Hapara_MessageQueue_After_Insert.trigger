/**
 * When a new MessageQueue is created, this trigger looks at the message type, and passes
 * the message to the appropriate static method in Hapara_MessageQueue_Handler class.
 * 
 * @author Logan (Trineo)
 * @created July 2013
 */
trigger Hapara_MessageQueue_After_Insert on MessageQueue__c (after insert) {
	
	// The entire code is surrounded with a try-catch block as a safety net. If any exceptions occur we can log the message on the record
	try {

		// This trigger is not bulk capable. It will only process single messages.
		if (trigger.new.size() == 1) {

			// Get the single message from the trigger
			MessageQueue__c msg = trigger.new[0];

			if (msg.Status__c == 'New') {
				
				// Pass the message to the handler in an asynchronus call
				Hapara_MessageQueue_Handler.processAsync(msg.Id);

				// Because we're calling a future method, set the status to In Progress now, indicating that we're waiting for an async method
				update new MessageQueue__c(
					Id = msg.Id,
					Status__c = 'In Progress'
				);
			}
		}

		// If there's more than on message in this trigger execution, mark all the records as unprocessed with reason
		else {
			List<MessageQueue__c> allMessages = new List<MessageQueue__c>();
			for (MessageQueue__c msg : trigger.new) {
				allMessages.add(
					new MessageQueue__c(
						Id = msg.Id,
						Status__c = 'Errored',
						ErrorMessage__c = 'Hapara_MessageQueue_Handler does not support bulk operations.'
					)
				);
			}
			update allMessages;
		}
	}

	// If there's an uncaught exception, add the exception message to all the message queue objects
	catch(Exception e) {
		List<MessageQueue__c> allMessages = new List<MessageQueue__c>();
		for (MessageQueue__c msg : trigger.new) {
			allMessages.add(
				new MessageQueue__c(
					Id = msg.Id,
					Status__c = 'Errored',
					ErrorMessage__c = 'Unexpected exception caught in Hapara_MessageQueue_Before_Insert.trigger; ' + e.getMessage()
				)
			);
		}
		update allMessages;
	}
}