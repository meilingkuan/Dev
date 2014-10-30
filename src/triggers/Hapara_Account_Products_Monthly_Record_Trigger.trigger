trigger Hapara_Account_Products_Monthly_Record_Trigger on Account_Products__c (after insert, after update)
{
    //create list to upload in bulk
    List<Invoice_Amount_per_Month__c> records = new List<Invoice_Amount_per_Month__c>();

    //when a new purchased product is added or edited
    for(Account_Products__c a : Trigger.new)//for each purchased product
    {
    	if(a.Hapara_Invoice__c != null && a.Invoice_Date__c > Date.valueOf('2014-06-30')){
    		Account_Products__c objOldvalues =trigger.isUpdate? Trigger.oldMap.get(a.id): a;
    		
    		if(a.Subscription_Start_Date__c != objOldvalues.Subscription_Start_Date__c
    		 || a.Amount__c != objOldvalues.Amount__c
    		 || a.Status__c != objOldvalues.Status__c
    		 || trigger.isInsert ){
		        //if update
		        if (Trigger.isUpdate && string.isEmpty( a.Invoice_No__c ))
		        {
		            //delete all records
		            list<Invoice_Amount_per_Month__c> existingrecords = [Select r.Id from Invoice_Amount_per_Month__c r where r.Purchased_Product__c =: a.Id];
		            if(existingrecords.size()>0){
		               delete existingrecords;
		            }
		
		        }
		        //Add new records		
		        //<--------GET DATES-------->//
		        //get subscription start date
		        Date startDate=a.Subscription_Start_Date__c;
		        //get subscription end date
		        Date endDate=a.Subscription_End_Date__c;
		        //<--------CALCUALTE DAYS-------->//
		        Integer dayNum =startDate.daysBetween(endDate)+1;
		
		        //<--------CALCUALTE FIELD VALUES-------->//
		        //get total price
		        Decimal priceTotal=a.Amount__c;
		
		        //calculate daily price
		        Double priceDaily=priceTotal/dayNum; //<--Final value
		
		        //get product family
		        String productFamily=a.Product_Family__c; //<--Final value
		
		
		        //<--------INITIATE LOOPING VALUES AND LISTS-------->//
		        Date counterDate=startDate;
		
		        List<Double> months= new List<Double>();
		        List<Date> startOfMonthList= new List<Date>();
		
		        Integer counter=0;
		
		        Double monthPrice=0;
		
		        //<--------LOOP THROUGH EACH DAY-------->//
		        do
		        {
		            //check tomorrows date
		            Date nextDay=counterDate.addDays(1);
		
		            //<--------CALCULATE PRICES-------->//
		            if(counterDate < a.Invoice_Date__c){
		              //add price for that day
		                monthPrice=monthPrice+priceDaily;
		            }else if(counterDate == a.Invoice_Date__c ){
		            	//log the months price in a list
		                monthPrice=monthPrice+priceDaily;
		                months.add(monthPrice);
		                //add last day of time period to list
		                startOfMonthList.add(counterDate);
		                counter++;
		                //reset monthly price
		                monthPrice=0;
		            }else if ((counterDate.month())==(nextDay.month())) //check if month is changing
		            {
		                //add price for that day
		                monthPrice=monthPrice+priceDaily;
		            }
		            else
		            {
		                //log the months price in a list
		                monthPrice=monthPrice+priceDaily;
		                months.add(monthPrice);
		                //add last day of time period to list
		                startOfMonthList.add(counterDate);
		                counter++;
		                //reset monthly price
		                monthPrice=0;
		            }
		
		            //increase the date
		            counterDate=counterDate.addDays(1);
		
		        } while (counterDate<endDate);//until the last day
		
		        //on last day add final time periods price
		        monthPrice=monthPrice+priceDaily;
		        months.add(monthPrice);
		        startOfMonthList.add(endDate);
		        counter++;
		
		        // for each month looped through
		        for(Integer monthCounter= 0; monthCounter< (counter); monthCounter++)
		        {
		            //create a record of the month
		            records.add(new Invoice_Amount_per_Month__c(
		            Account__c=a.Account__c,
		            Date_of_Month__c=startOfMonthList[monthCounter], 
		            Monthly_Invoice_Amount__c=months[monthCounter],
		            PF__c=productFamily,
		            Product__c=a.Product__c,
		            Purchased_Product__c=a.Id,
		            Hapara_Invoice__c = a.Hapara_Invoice__c ));
		        }
		    }
		}
    		 
    }
    //insert the records as SF objects
    if(records.size()>0)
    	insert records;

}