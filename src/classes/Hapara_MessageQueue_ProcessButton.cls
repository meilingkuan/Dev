/**
 * Extension that powers a button which kicks of the logic for a MessageQueue__c record.
 *
 * @author Logan (Trineo)
 * @date August 2013
 */
public with sharing class Hapara_MessageQueue_ProcessButton {
	
	private MessageQueue__c msg;

	public Hapara_MessageQueue_ProcessButton(ApexPages.StandardController controller) {

		msg = [
			SELECT Id, MessageType__c, Status__c
			FROM MessageQueue__c
			WHERE Id = :controller.getId()
		];
	}

	public PageReference process() {

		Hapara_MessageQueue_Handler.process(msg.Id);
		return new PageReference('/' + msg.Id);
	}
}