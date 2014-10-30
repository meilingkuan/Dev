public class Hapara_CalculateRevenue {
	public static string TRANSANCTION_TYPE_NEW = 'New';
	public static string TRANSANCTION_TYPE_RENEWAL='Renewal';
	public static string TRANSANCTION_TYPE_EXPANSION = 'Expansion';
	public static string TRANSANCTION_TYPE_CONTRACTION = 'Contraction';
	public static string TRANSANCTION_TYPE_LOST = 'Lost';
	public static string TRANSANCTION_TYPE_UPGRADE = 'Upgrade';
	public static string TRANSANCTION_TYPE_DOWNGRADE = 'Downgrade';
	
	public static void CalculateInitialMRR(Id AccountId){
		string debugMsg = '';
		try{
			list<Account_Products__c> invlines = [Select 
                a.Account__c ,a.Account__r.name,a.Account__r.Invoice_Period__c,
                                                  
				a.Invoice_No__c,a.Invoice_Date__c,a.Product_Family__c, a.Subscription_Start_Date__c, 
				a.Subscription_End_Date__c, a.Quantity__c, a.Unit_Price__c,a.Amount__c,a.Amount_USD__c,
				a.CurrencyIsoCode, a.Processed_MRR__c,a.Name,
				
				a.Product__r.Calculate_MRR__c, a.Product__c, 
				
				a.Hapara_Invoice__r.Xero_Currency_Rate__c, a.Hapara_Invoice__r.Status__c, 
				a.Hapara_Invoice__r.Invoice_Date__c, a.Hapara_Invoice__r.Account__c, a.Hapara_Invoice__c
	
	
				From Account_Products__c a
				where a.Product__r.Calculate_MRR__c = true and a.Invoice_No__c like 'INV%' 
               // and Processed_MRR__c = false
                and a.Account__c =: AccountId                           
				order by a.Account__c,a.Subscription_Start_Date__c, a.Subscription_End_Date__c,a.Product_Family__c  
			];
			
			Id currentAccountId;	
			string prevTDProductFamily ;
			string transactionType;
			decimal prevInvoiceValue = 0.0;
			integer noOfMonths =0;
			decimal invoicelineAmount = 0.0;
			decimal variableAmount = 0.0;
			Date prevStartDate = null;
            Date prevEndDate = null;
			string variableType;
            integer noOfMonthsStartDate;
            decimal monthNonVariable =0.0;
            decimal monthVariable = 0.0;
			list<Invoice_Amount_per_Month__c> mrrTrans  = new list<Invoice_Amount_per_Month__c>();
            list<Account_Products__c> lastRenewalProducst ;
			for(Account_Products__c a : invlines){
				//calculate the number of months between the subscripton dates
				noOfMonths = a.Subscription_Start_Date__c.monthsBetween(a.Subscription_End_Date__c)+1 ;
				debugMsg = '***CalculateInitialMRR - accountid='+ a.Account__c +'; invoiceNo:' + a.Invoice_No__c
					+'; purchasedProduct= ' + a.Name + '; productFamily=' + a.Product_Family__c + '; startdate='+ a.Subscription_Start_Date__c 
					+'; endDate='+ a.Subscription_End_Date__c + '; amount='+a.Amount_USD__c + '; noOfMonths=' + noOfMonths 
                    + ';prevStartDate='+prevStartDate + ';prevEndDate=' + prevEndDate ;
				system.debug(debugMsg);
				if(currentAccountId !=  a.Account__c || currentAccountId == null){
					 currentAccountId = a.Account__c ;
					 prevTDProductFamily = null;
					 prevInvoiceValue = 0.0;
					 prevStartDate = null;
                     lastRenewalProducst = new  list<Account_Products__c>();
                     prevEndDate = null;
				}
				
				invoicelineAmount = a.Amount_USD__c;      
                variableAmount = 0.0;
                variableType ='';
                noOfMonthsStartDate =0;
                monthNonVariable =invoicelineAmount/ noOfMonths;
             	monthVariable = 0.0;
				//determine the transaction type
				if( prevStartDate == null ){
					transactionType = TRANSANCTION_TYPE_NEW;
                    prevTDProductFamily = a.Product_Family__c.contains('TD')?a.Product_Family__c:prevTDProductFamily;
                    prevStartDate =a.Subscription_Start_Date__c;
                    prevEndDate = a.Subscription_End_Date__c;
				}else if(a.Subscription_Start_Date__c != prevStartDate){
                   //  noOfMonthsStartDate=prevStartDate!= null? a.Subscription_Start_Date__c.monthsBetween(prevStartDate)+1:1;
                    //if the next startDate is less than 11 months then it is more about upgrade or downgrade and expansion
                    if(a.Subscription_Start_Date__c <= prevEndDate){
                        if(prevTDProductFamily == a.Product_Family__c ){
                            if(invoicelineAmount >0)
                                transactionType =TRANSANCTION_TYPE_EXPANSION; 
                            else
                                transactionType =TRANSANCTION_TYPE_CONTRACTION;                         
                        }else if(invoicelineAmount <0)
                            transactionType =TRANSANCTION_TYPE_CONTRACTION;
                        else if(prevTDProductFamily == HAPARA_CONST.PRODUCT_FAMILY_TD && a.Product_Family__c == HAPARA_CONST.PRODUCT_FAMILY_TDRC)
                            transactionType = TRANSANCTION_TYPE_UPGRADE;
                        else if(prevTDProductFamily == HAPARA_CONST.PRODUCT_FAMILY_TD && a.Product_Family__c == HAPARA_CONST.PRODUCT_FAMILY_RC)
                            transactionType = TRANSANCTION_TYPE_UPGRADE;
                        else if(prevTDProductFamily == HAPARA_CONST.PRODUCT_FAMILY_TDRC && a.Product_Family__c == HAPARA_CONST.PRODUCT_FAMILY_TD)
                            transactionType = TRANSANCTION_TYPE_DOWNGRADE;
                        else  
                             transactionType = TRANSANCTION_TYPE_UPGRADE;
                       
                    }else{
                       transactionType = TRANSANCTION_TYPE_RENEWAL; 
					 	
                        boolean foundProduct = false;
                        prevInvoiceValue = 0.0; 
                       // system.debug('***CalculateInitialMRR - lastRenewalProducst before loop = '+lastRenewalProducst.size());
                        if(lastRenewalProducst.size()>0){
                            for(integer i=lastRenewalProducst.size()-1; i >=0; i--){                          
                                Account_Products__c prev = lastRenewalProducst[i];
                              //  system.debug('***CalculateInitialMRR - lastRenewalProducst loop=' + prev.Name 
                              //               +'; same product family='+(a.Product_Family__c ==prev.Product_Family__c)
                               //             +'; prev amount >'+(prev.Amount_USD__c >0));
                                if(a.Product_Family__c ==prev.Product_Family__c && prev.Amount_USD__c >0){
                                    foundProduct = true;
                                    prevInvoiceValue = prev.Amount_USD__c;                                    
                                    break;
                                }
                            }
                        }
                           
                        if(foundProduct){
                            if(prevInvoiceValue != 0.0 && a.Amount_USD__c >prevInvoiceValue ){
                                variableAmount =a.Amount_USD__c -  prevInvoiceValue ;
                                variableType = TRANSANCTION_TYPE_RENEWAL + ' ' + TRANSANCTION_TYPE_EXPANSION;
                            }else if(prevInvoiceValue != 0.0 && a.Amount_USD__c <prevInvoiceValue ){
                                variableAmount = a.Amount_USD__c  ;
                                variableType =TRANSANCTION_TYPE_RENEWAL + ' ' + TRANSANCTION_TYPE_CONTRACTION;
                            }
                            invoicelineAmount = a.Amount_USD__c - variableAmount;
                        }else{
                            if(prevTDProductFamily == HAPARA_CONST.PRODUCT_FAMILY_TD && a.Product_Family__c == HAPARA_CONST.PRODUCT_FAMILY_TDRC)
                                transactionType =  TRANSANCTION_TYPE_RENEWAL + ' ' + TRANSANCTION_TYPE_UPGRADE;
                            else if(prevTDProductFamily == HAPARA_CONST.PRODUCT_FAMILY_TD && a.Product_Family__c == HAPARA_CONST.PRODUCT_FAMILY_RC)
                                transactionType =TRANSANCTION_TYPE_RENEWAL + ' ' +  TRANSANCTION_TYPE_UPGRADE;
                            else if(prevTDProductFamily == HAPARA_CONST.PRODUCT_FAMILY_TDRC && a.Product_Family__c == HAPARA_CONST.PRODUCT_FAMILY_TD)
                                transactionType = TRANSANCTION_TYPE_RENEWAL + ' ' + TRANSANCTION_TYPE_DOWNGRADE;
                            else if(prevTDProductFamily != a.Product_Family__c ) 
                                transactionType = TRANSANCTION_TYPE_RENEWAL + ' ' +  TRANSANCTION_TYPE_UPGRADE;
                            
                        }
                        monthNonVariable =invoicelineAmount/ noOfMonths;
                        monthVariable = variableAmount/noOfMonths;
                        system.debug('***CalculateInitialMRR - RENEWAL - preproduct:' + foundProduct + '; prevInvoiceValue:'+ prevInvoiceValue 
                                     + '; currentAmount='+ a.Amount_USD__c + '; productFamily=' + a.Product_Family__c 
                                     +';invoicelineAmount='+invoicelineAmount +';monthNonVariable='+ monthNonVariable 
                                     + ';variableAmount='+variableAmount + ';monthVariable='+monthVariable
                                     +';noOfMonths='+noOfMonths);
                    } 	
				}                                    
				
				//create mrr transactions
				Date dateOfmonthCounter = a.Subscription_Start_Date__c;
				
				for(integer i = 0; i< noOfMonths;i++){
					//if it is contraction then there will not be any normal lines.
					if(monthNonVariable>0)
						mrrTrans.add(createMRRInvoicePerMonth(a.Account__c,
							dateOfmonthCounter,
							a.Hapara_Invoice__c,
							a.Invoice_Date__c,
							monthNonVariable,
							a.Product_Family__c,
							a.Product__c,
							transactionType, 
							a.id));
						
					if(variableAmount != 0.0){
						mrrTrans.add(createMRRInvoicePerMonth(a.Account__c,
							dateOfmonthCounter,
							a.Hapara_Invoice__c,
							a.Invoice_Date__c,
							monthVariable,
							a.Product_Family__c,
							a.Product__c,
							variableType, 
							a.id));
					}
					
					dateOfmonthCounter =   dateOfmonthCounter.addMonths(1);
					
				}
                
                if(a.Subscription_Start_Date__c > prevEndDate ){
					prevTDProductFamily = a.Product_Family__c.contains('TD')?a.Product_Family__c:prevTDProductFamily;
					prevInvoiceValue = a.Amount_USD__c;
                    prevStartDate =a.Subscription_Start_Date__c;
					prevEndDate = a.Subscription_End_Date__c;
                    
                }
                lastRenewalProducst.add(a);
             //   system.debug('***CalculateInitialMRR - lastRenewalProducst=' + lastRenewalProducst.size()+'; add purchasedProduct='+a.name 
              //               +'; ProductFamily=' + a.Product_Family__c);  
				a.Processed_MRR__c = true;
				
			}
			
			if(mrrTrans.size()>0)
				insert mrrTrans;
				
			update invlines;
		}catch(Exception e){
			string error ='***CalculateInitialMRR: ' + debugMsg + ' ERROR:'+  e.getMessage() 
			+ '\n\n//-- Stack Trace --//\n' + e.getStackTraceString();
			HaparaSendEmailNotification.SendAdminErrorEmail('Hapara_CalculateRevenue CalculateInitialMRR', error, '');
			System.debug(error);
		}
	}
    	
	private static Invoice_Amount_per_Month__c createMRRInvoicePerMonth(Id AccountId, Date dateOfmonthCounter,
	Id Hapara_InvoiceId, Date Invoice_Date,decimal amount,string pf, id product, string transactionType,
	id purchasedProduct ){
		Invoice_Amount_per_Month__c perMonth  = new Invoice_Amount_per_Month__c();
		perMonth.CurrencyIsoCode = 'USD';
		perMonth.Account__c =AccountId;
		perMonth.Date_of_Month__c =dateOfmonthCounter;
		perMonth.Hapara_Invoice__c =Hapara_InvoiceId;
		perMonth.Monthly_Invoice_Amount__c = amount;
		perMonth.PF__c = pf;
		perMonth.Product__c = product;
		perMonth.Purchased_Product__c = purchasedProduct;
		perMonth.Transaction_Type__c = transactionType;
		perMonth.Type_of_Accounting__c = HAPARA_CONST.REVENUE_TYPEOFACCOUNTING_MRR;
		return perMonth;
	}
}