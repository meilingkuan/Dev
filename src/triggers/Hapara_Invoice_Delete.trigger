trigger Hapara_Invoice_Delete on Hapara_Invoice__c (before delete) {
	list<Account_Products__c> deleteProds = new list<Account_Products__c>();
	for(Hapara_Invoice__c i : trigger.old){
		if(!string.IsEmpty(i.Xero_Invoice_No__c)){
			i.addError('Cannot delete this invoice as it has been synch to Xero. Please contact George or Mei Ling to cancel this invoice in Xero.');
		}else{
			//delete attached product lines
			list<Account_Products__c> products = [select id from Account_Products__c where Hapara_Invoice__c=: i.Id ];
			if(products.size()>0)
				deleteProds.addAll(products);
		}
	}
	
	if(deleteProds.size()>0)
		delete deleteProds;
}