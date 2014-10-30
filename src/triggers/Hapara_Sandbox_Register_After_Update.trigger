trigger Hapara_Sandbox_Register_After_Update on Sandbox_Register__c (after insert, after update) {
		for(Sandbox_Register__c s : Trigger.new) {
			if(s.Sandbox_Register_URL__c != null){
				Contact contact = [select id,email,firstname from contact c where id =: s.Customer_Contact__c];    		
    		
				HaparaSendEmailNotification.SendContactSandboxEmail(contact, 'SandboxRegister_TNC_URL', s);
			}
		}
}