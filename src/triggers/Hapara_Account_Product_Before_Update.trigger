trigger Hapara_Account_Product_Before_Update on Account_Products__c (before insert, before update, before delete) {
	list<Hapara_Invoice_History__c> histories = new list<Hapara_Invoice_History__c>();
	
	if(trigger.isUpdate){
		for(Account_Products__c obj : Trigger.new) {
			Account_Products__c objOldvalues = Trigger.oldMap.get(obj.id);	
			if(obj.Subscription_Start_Date__c != objOldvalues.Subscription_Start_Date__c 
				||obj.Subscription_End_Date__c != objOldvalues.Subscription_End_Date__c
				|| obj.Quantity__c != objOldvalues.Quantity__c
				|| obj.Unit_Price__c != objOldvalues.Unit_Price__c
				|| obj.Product__c != objOldvalues.Product__c
				|| obj.Account__c != objOldvalues.Account__c
				)	{
					if(obj.Hapara_Invoice__c != null){
						Hapara_Invoice_History__c history = Hapara_UtilityCommonRecordAccess.createInvoiceHistory(obj,'Update');
						histories.add(history);
						obj.Processed_MRR__c = false;
					}
				}
		}
	}else if(trigger.isInsert){
		for(Account_Products__c obj : Trigger.new) {
			if(obj.Hapara_Invoice__c != null){
				Hapara_Invoice_History__c history2 = Hapara_UtilityCommonRecordAccess.createInvoiceHistory(obj,'Insert');
				histories.add(history2);
			}
		}
	}else if(trigger.isDelete){
		for(Account_Products__c obj : Trigger.old) {
			if(obj.Hapara_Invoice__c != null){
				Hapara_Invoice_History__c history3 = Hapara_UtilityCommonRecordAccess.createInvoiceHistory(obj,'Delete');
				histories.add(history3);
			}
		}
	}
		
	if(histories.size()>0)
		insert histories;

}