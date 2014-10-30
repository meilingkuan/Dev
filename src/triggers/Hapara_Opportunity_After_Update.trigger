trigger Hapara_Opportunity_After_Update on Opportunity (after insert) {
    
    //mlk 2014/8/20 - decommisioned processing fee..
  //  if(Trigger.isInsert && Trigger.isAfter){
  //      system.debug('***Hapara_Opportunity_After_Update: getting processing fee=' +HAPARA_CONST.SETTING_OPPORTUNITY_CONFIG.Processing_Fee__c);
  //      list<OpportunityLineItem> lines = new list<OpportunityLineItem>();
        //create process fee line in opportunity.
  //      Product2 prod = [Select r.Xero_Product_Code__c, r.Reseller_Product_Code_del__c, r.Reseller_Account_del__c, 
  //                          r.Id ,r.Description, r.family, r.Subscription_Type__c,r.Subscription_Period__c,
  //                          (Select  p.UseStandardPrice, p.UnitPrice, p.ProductCode, p.Product2Id, p.Id, 
  //                          p.CurrencyIsoCode, p.IsActive 
   //                         From PricebookEntries p 
   //                         where p.IsActive = true
    //                        ) 
     //                       From Product2 r where r.Id =: HAPARA_CONST.SETTING_OPPORTUNITY_CONFIG.Processing_Fee__c];
     //   map<string,PricebookEntry> pricing = new map<string,PricebookEntry>();
        
     //   for(PricebookEntry p: prod.PricebookEntries){
      //      pricing.put(p.CurrencyIsoCode, p);
     //   }
        
      //  for(Opportunity opp : Trigger.new){       
       // 	if(opp.RecordTypeId != HAPARA_CONST.SETTING_OPPORTUNITY_CONFIG.Record_Type_Reseller__c
      ///  	  && opp.RecordTypeId != HAPARA_CONST.SETTING_OPPORTUNITY_CONFIG.Record_Type_Reseller_New__c 
       // 	  && opp.Opportunity_Name_Template__c != HAPARA_CONST.OPPORTUNITY_TEMPLATENAME_TDI 
       // 	) {
	   //         system.debug('***Hapara_Opportunity_After_Update: creating lineitem for id=' + opp.Id +' opp.CurrencyIsoCode:' +opp.CurrencyIsoCode);
	   //         OpportunityLineItem lineItem = new OpportunityLineItem();
	   //         PricebookEntry price =pricing.get(opp.CurrencyIsoCode);
	   //         lineItem.OpportunityId = opp.Id;
	    //        lineItem.PricebookEntryId =price.id;
	    //        lineItem.UnitPrice = price.UnitPrice;
	    //        lineItem.Quantity =  1;
	    //        lineItem.Account__c = opp.AccountId;
	    //        lineItem.Description2__c = prod.Description;
	    //       lineItem.ServiceDate =date.today();
	     //       lineItem.Subscription_End_Date__c = date.today();
	    //        lines.add( lineItem);
        //	}
        //}
       // if(lines.size()>0)
       //     insert lines;
    //}
}