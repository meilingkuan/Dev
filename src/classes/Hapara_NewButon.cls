@isTest(SeeAllData=true)
public  class Hapara_NewButon {
    static HaparaVisualForce__c haparaSetting = HaparaVisualForce__c.getInstance('Hapara');
    private Opportunity opp;
    
    private ApexPages.StandardController singlecontroller;
    private final PageReference fromPage;
    
    public string oppSearchId ='';
    public String opportunitySearchId{
        get{
            system.debug('***opportunitySearchId -'+oppSearchId);
            return oppSearchId;
            }
        set{
            system.debug('***opportunitySearchId set -'+oppSearchId);
            oppSearchId = value;
            }
    }
    
    public Hapara_NewButon(ApexPages.StandardController controller) {
        singlecontroller =controller; 
        fromPage = singlecontroller.cancel();
        string url = ApexPages.currentPage().getUrl();
        
        if(url.contains(HAPARA_CONST.OPPORTUNITY_CREATENEWINVOICE_PAGE)){
            validateCreateNewInvoice();
        }else if(url.contains(HAPARA_CONST.OPPORTUNITY_MERGE)){
            getOpportunityMergeTo();
            opportunitySearchId = '';
        }
    }
    
    private Opportunity oppmerge;
    public Opportunity getOpportunityMergeTo(){
        if(oppmerge == null){
            oppmerge=  new Opportunity();
        }
        
        return oppmerge;
    }
    
    string canProcess = 'false';
    public String getCanProcess(){
        
        return canProcess;
    }
    
    string canUpdateInvoice = 'false';
    public String getCanUpdateInvoice(){
        
        return canUpdateInvoice;
    }
        
    public PageReference onloadHaparaInvoice() {
        PageReference redirect = new PageReference('/'+ haparaSetting.Hapara_Invoice_Id__c +'/e');
        redirect.getParameters().put('nooverride', '1');
        populateReturnUrl(redirect,false);
        if (ApexPages.currentPage().getParameters().containsKey(
            'CF'+ haparaSetting.Hapara_Invoice_Id_c_parameter__c +'_lkid')) {
            string accid = ApexPages.currentPage().getParameters().get(
                'CF'+ haparaSetting.Hapara_Invoice_Id_c_parameter__c +'_lkid');
            
            Account acc = [Select a.Invoice_Contact__c,a.Invoice_Contact__r.Name,a.Name,Invoice_Billing_Emails__c,
            		a.CurrencyIsoCode 
            		From Account a where a.Id = :accid ];
            
            redirect.getParameters().put('CF'+ haparaSetting.Hapara_Invoice_Id_c_parameter__c +'_lkid', accid);
            redirect.getParameters().put('CF'+ haparaSetting.Hapara_Invoice_Id_c_parameter__c, acc.Name);
            redirect.getParameters().put('CurrencyIsoCode', acc.CurrencyIsoCode);
            redirect.getParameters().put('CF'+ haparaSetting.Hapara_Invoice_Id_c_parameter_2__c +'_lkid',acc.Invoice_Contact__c);
            redirect.getParameters().put('CF'+ haparaSetting.Hapara_Invoice_Id_c_parameter_2__c ,acc.Invoice_Contact__r.Name);
        	redirect.getParameters().put(haparaSetting.Hapara_Invoice_Id_c_parameter_3__c ,acc.Invoice_Billing_Emails__c);
        }
        
        return redirect;
    }
    
 	public PageReference onloadHaparaPayment() {
 		PageReference redirect = new PageReference('/'+ haparaSetting.Hapara_Invoice_Payment_Id__c +'/e');
        redirect.getParameters().put('nooverride', '1');
        populateReturnUrl(redirect,false);
        if (ApexPages.currentPage().getParameters().containsKey(
        			'CF'+ haparaSetting.Hapara_Invoice_Payment_Id_c_parameter__c +'_lkid')) {
        	string recordId = ApexPages.currentPage().getParameters().get(
        		'CF'+ haparaSetting.Hapara_Invoice_Payment_Id_c_parameter__c +'_lkid');
            
            Hapara_Invoice__c record = [Select h.CurrencyIsoCode,  h.Account__c ,h.Name,h.Total_Amount__c,Total_Paid_Amount__c,
            					h.Account__r.BillingCountry,h.Account__r.Name
					            From Hapara_Invoice__c h
					            where h.Id = :recordId ];
            double amountOwing = double.valueOf(record.Total_Amount__c)- double.valueOf(record.Total_Paid_Amount__c);
            redirect.getParameters().put('CF'+ haparaSetting.Hapara_Invoice_Payment_Id_c_parameter__c +'_lkid', recordId);
            redirect.getParameters().put('CF'+ haparaSetting.Hapara_Invoice_Payment_Id_c_parameter__c , record.Name);
            redirect.getParameters().put('CurrencyIsoCode', record.CurrencyIsoCode);
            redirect.getParameters().put('CF'+ haparaSetting.Hapara_Invoice_Payment_Id_c_parameter_2__c +'_lkid',record.Account__c);
            redirect.getParameters().put('CF'+ haparaSetting.Hapara_Invoice_Payment_Id_c_parameter_2__c ,record.Account__r.Name);
            redirect.getParameters().put(haparaSetting.Hapara_Invoice_Payment_Amount__c ,amountOwing.format());
            string accountId='';
            
            if(amountOwing==record.Total_Amount__c){
		        string billingCountry ='{'+ record.Account__r.BillingCountry+'}'; 
		        list<Payment_Account_Code__c> codes = [Select Id,name from Payment_Account_Code__c 
		        	where Countries__c like: billingCountry limit 1] ;
		        if(codes.size()==0)
		       		codes = [Select Id,name from Payment_Account_Code__c 
		        		where Countries__c ='Other' limit 1] ;
		         
	           	redirect.getParameters().put('CF'+ haparaSetting.Hapara_Invoice_Payment_Id_c_parameter_3__c +'_lkid',codes[0].Id);
	            redirect.getParameters().put('CF'+ haparaSetting.Hapara_Invoice_Payment_Id_c_parameter_3__c ,codes[0].Name); 
            }
        }
        
        return redirect;
 	}

    public PageReference onloadQuote() {
        PageReference redirect = new PageReference('/0Q0/e');
        redirect.getParameters().put('nooverride', '1');
        populateReturnUrl(redirect,false);
        if (ApexPages.currentPage().getParameters().containsKey('oppid')) {
            string recordId = ApexPages.currentPage().getParameters().get('oppid');
            
            Opportunity record = [Select h.CurrencyIsoCode,h.Opportunity_Name_Template__c ,
                    Primary_Contact__c,h.Primary_Contact__r.Name,h.Name,
                    
                    AccountId,h.Account.BillingCountry, h.Account.BillingPostalCode, h.Account.BillingState, 
                    h.Account.BillingCity, h.Account.BillingStreet
                    From Opportunity h
                    where h.Id = :recordId ];
            
            redirect.getParameters().put('oppid', recordId);
           
            redirect.getParameters().put('CurrencyIsoCode', record.CurrencyIsoCode);
            redirect.getParameters().put('Name',record.Opportunity_Name_Template__c);
            redirect.getParameters().put('ExpirationDate',Date.today().addDays(30).format());
            redirect.getParameters().put('Contact_lkid', record.Primary_Contact__c);
            redirect.getParameters().put('Contact', record.Primary_Contact__r.Name);
            redirect.getParameters().put('Name', record.Name);
            redirect.getParameters().put('ExpirationDate',Date.today().addDays(30).format());
            if(record.Account.BillingStreet!=null)
            	 redirect.getParameters().put('BillingStreet', record.Account.BillingStreet);
            if(record.Account.BillingCity!=null)
            	 redirect.getParameters().put('BillingCity', record.Account.BillingCity);
            if(record.Account.BillingState!=null)
            	 redirect.getParameters().put('BillingState', record.Account.BillingState);
            if(record.Account.BillingPostalCode!=null)
            	 redirect.getParameters().put('BillingPostalCode', record.Account.BillingPostalCode);
            if(record.Account.BillingCountry!=null)
            	 redirect.getParameters().put('BillingCountry', record.Account.BillingCountry);
            
        }
        
        return redirect;
    }
    
     public PageReference onloadOpportunity() {   	
        PageReference redirect = new PageReference('/006/e');
        redirect.getParameters().put('nooverride', '1');
        redirect.getParameters().put('opp3', '-- Not Required --');
       	redirect.getParameters().put('RecordType',  ApexPages.currentPage().getParameters().get('RecordType'));
        if (ApexPages.currentPage().getParameters().containsKey('retUrl')) {
            redirect.getParameters().put('retUrl', ApexPages.currentPage().getParameters().get('retUrl'));
        }
        if (ApexPages.currentPage().getParameters().containsKey('accid')) {
        	string accid = ApexPages.currentPage().getParameters().get('accid');
            redirect.getParameters().put('accid', accid);
            Account acc = [Select a.Reseller_Tier__r.Name,a.Reseller_Tier__r.Combination_Tier__c, a.Reseller_Tier__c, a.CurrencyIsoCode,
            a.Invoice_Contact__c,a.Invoice_Contact__r.name
            From Account a where a.Id = :accid ];
            redirect.getParameters().put('opp16', acc.CurrencyIsoCode);
             redirect.getParameters().put('CF'+haparaSetting.Opportunity_Parameter_1__c+'_lkid', acc.Invoice_Contact__c);
		     redirect.getParameters().put('CF'+haparaSetting.Opportunity_Parameter_1__c, acc.Invoice_Contact__r.name);
            if(acc.Reseller_Tier__c != null){
            	boolean combination=acc.Reseller_Tier__r.Combination_Tier__c;
            	if(!combination){
		            redirect.getParameters().put('CF'+haparaSetting.Opportunity_Parameter_2__c+'_lkid', acc.Reseller_Tier__c);
		            redirect.getParameters().put('CF'+haparaSetting.Opportunity_Parameter_2__c, acc.Reseller_Tier__r.Name);
            	}
            }
        }
        
        return redirect;
    }
    
    private void populateReturnUrl(PageReference redirect, boolean hasSave){
        string retUrl ;
        if (ApexPages.currentPage().getParameters().containsKey('retUrl')) {
            retUrl= ApexPages.currentPage().getParameters().get('retUrl');
            redirect.getParameters().put('retUrl',retUrl );
           
        }
        if( hasSave)
            if(Apexpages.currentPage().getParameters().containsKey('saveURL')){
                redirect.getParameters().put('saveURL', ApexPages.currentPage().getParameters().get('saveURL'));
            }else{
                redirect.getParameters().put('saveURL',retUrl);
            }
    }
    
    public void validateCreateNewInvoice(){
        string message = 'Click Yes to close the opportunity and create an Invoice or Cancel to return to the Opportunity. Once the invoice is created please make sure to synch to Xero.';
        string oppId = ApexPages.currentPage().getParameters().get('Id');
        opp = [Select o.Id, o.Primary_Contact__c,  o.CurrencyIsoCode,o.amount,o.stageName,
        
        	o.Hapara_Invoice__c,o.Hapara_Invoice__r.Status__c,
        
            o.SyncedQuote.BillingCountry, o.SyncedQuote.BillingPostalCode, o.SyncedQuote.BillingState, 
            o.SyncedQuote.BillingCity, o.SyncedQuote.BillingStreet, o.SyncedQuote.ContactId, 
            o.SyncedQuoteId,o.Customer_PO_Reference__c,o.Customer_PO_Received_Date__c,
            
            o.AccountId,o.Account.Invoice_Contact__c , o.Account.BillingCountry, o.Account.BillingPostalCode, o.Account.BillingState, 
            o.Account.BillingCity, o.Account.BillingStreet,o.Account.CurrencyIsoCode,o.Account.Invoice_Billing_Emails__c,
            
            (Select Id, OpportunityId, SortOrder, PricebookEntryId, 
            CurrencyIsoCode, Quantity, TotalPrice, UnitPrice, ListPrice, ServiceDate, HasRevenueSchedule, Discount,
            HasQuantitySchedule, Description, HasSchedule, CreatedDate, CreatedById, LastModifiedDate, 
            LastModifiedById, SystemModstamp, IsDeleted, Account__c, Subscription_End_Date__c, Description2__c
            From OpportunityLineItems)  
            From Opportunity o where o.Id=:oppId];
        canProcess = 'false'; 
            
        if(opp.OpportunityLineItems.Size() ==0)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'No products been added to the opportunity.'));
        else if(opp.Hapara_Invoice__c != null)  {
        	if(opp.Hapara_Invoice__r.Status__c == HAPARA_CONST.INVOICE_STATUS_CANCELLED 
        		|| opp.Hapara_Invoice__r.Status__c == HAPARA_CONST.INVOICE_STATUS_DELETED
        		||  opp.Hapara_Invoice__r.Status__c == HAPARA_CONST.INVOICE_STATUS_PARTPAID){
        		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'The invoice linked to this opportunity cannot be updated because the status is ' + opp.Hapara_Invoice__r.Status__c ));
        	}else{
        		canProcess = 'true'; 
        		canUpdateInvoice = 'true';
            	ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, 'Click "Yes" to update the current invoice with the changes made to the opportunity. Please make sure to synch to Xero.'));
        	}
        } else if((opp.Primary_Contact__c != null || opp.Account.Invoice_Contact__c != null) && (opp.SyncedQuoteId!= null 
            || (!string.IsEmpty(opp.Account.BillingCountry) 
            && !string.IsEmpty(opp.Account.BillingStreet)))){
                canProcess = 'true'; 
                canUpdateInvoice = 'false';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, message));              
            }else{
                message =  'Opportunity Primary Contact and Account Billing Address must set before creating an Invoice. ' 
            			+ 'Please set this before proceeding to create the Invoice from this Opportunity';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, message));
            }
    }
    
    public PageReference UpdateOpportunityInvoice(){
    	Id id = opp.Hapara_Invoice__c;
    	string url =  '/'+id;
    	Hapara_Invoice__c inv = [Select Status__c,Xero_Id__c ,Invoice_Date__c,Xero_Invoice_No__c,
    				(Select Id, IsDeleted, Name, CurrencyIsoCode, Product__c, Account__c, Quantity__c, 
    				Discount__c, Invoice_Date__c, Invoice_No__c, Description__c, Unit_Price__c, Amount__c, Hapara_Invoice__c, 
    				Product_Family__c, Subscription_End_Date__c, Subscription_Start_Date__c, Status__c, Reseller_Account__c, 
    				Subscription_Revision__c, Subscription_Period__c, Product_Name__c, Account_Name__c 
    				From Purchased_Products__r) 
    				From Hapara_Invoice__c h where id=:id];
    	
    	if(inv.Purchased_Products__r.size() >0)
    		delete inv.Purchased_Products__r;
    	
    	 createInvoiceLinesFromOppLines(opp,inv);
    	 
    	if(inv.Xero_Id__c != null)
    		inv.Status__c = 'Must Update Xero';
    	else
    		inv.Status__c ='Updated from Opportunity';
    		
    	update inv;
    	 
        PageReference page = new Pagereference(url);
        return page;
    }
    
    public PageReference CreateNewInvoiceCloseOpportunity(){
        return createNewInvoiceFromOpportunity('True');
    }
    public PageReference CreateNewInvoiceNotCloseOpportunity(){
        return createNewInvoiceFromOpportunity('False');
    }
    
    private PageReference createNewInvoiceFromOpportunity(string updateOpportunity){
            
            string id;
            Account acc = opp.Account;
            if(opp.SyncedQuoteId != null){
            	if(string.isEmpty(acc.BillingStreet)){
	                acc.BillingCity =opp.SyncedQuote.BillingCity;
	                acc.BillingCountry= opp.SyncedQuote.BillingCountry;
	                acc.BillingPostalCode =  opp.SyncedQuote.BillingPostalCode;
	                acc.BillingState= opp.SyncedQuote.BillingState;
	                acc.BillingStreet =  opp.SyncedQuote.BillingStreet;
            	}
                if(acc.Invoice_Contact__c == null)
                	acc.Invoice_Contact__c =  opp.SyncedQuote.ContactId;
                update acc;
            }
            Hapara_Invoice__c inv = new Hapara_Invoice__c();
            inv.Account__c = opp.AccountId;
            inv.Invoice_To_Contact__c = opp.SyncedQuoteId != null? opp.SyncedQuote.ContactId
            				: opp.Primary_Contact__c ==null? acc.Invoice_Contact__c :opp.Primary_Contact__c;
            inv.CurrencyIsoCode = opp.Account.CurrencyIsoCode;
            inv.Invoice_Billing_Emails__c = opp.Account.Invoice_Billing_Emails__c;
            inv.Opportunity__c = opp.id;
            inv.Customer_PO__c = opp.Customer_PO_Reference__c;
            inv.Customer_PO_Received_Date__c = opp.Customer_PO_Received_Date__c;
           
            insert inv;
            id= inv.id;
            
            createInvoiceLinesFromOppLines(opp,inv);
            
            //update opportunity
            if(updateOpportunity =='True'){
                opp.StageName = HAPARA_CONST.OPPORTUNIYT_STAGE_WON;
                opp.CloseDate = Date.today();
            }
            opp.Hapara_Invoice__c = inv.id;
            if(opp.Primary_Contact__c == null)
            	opp.Primary_Contact__c = acc.Invoice_Contact__c ;
            system.debug('***createNewInvoiceFromOpportunity: opp currecey =' + opp.CurrencyIsoCode + ' amount:' +opp.Amount);
            update opp;
            
            string url =  '/'+id;
            PageReference page = new Pagereference(url);
            return page;
    }
    
    public void createInvoiceLinesFromOppLines(Opportunity opp, Hapara_Invoice__c inv){
    		list<Account_Products__c> invlines = new list<Account_Products__c>();
            Account_Products__c invl ;
            list<Id> prices = new list<Id>();
            for(OpportunityLineItem line: opp.OpportunityLineItems){
                prices.Add(line.PricebookEntryId);
                
            }
            map<Id,PricebookEntry> mappedProduct = new map<Id,PricebookEntry>([
                Select p.Product2Id,p.Product2.Family,Product2.Not_Sync_to_Xero__c, 
                p.Pricebook2Id, p.Id 
                From PricebookEntry p where p.Id =: prices]);
            
            for(OpportunityLineItem line: opp.OpportunityLineItems){
                invl = new Account_Products__c();
                invl.Account__c = line.Account__c;
                invl.CurrencyIsoCode= opp.Account.CurrencyIsoCode;
                invl.Description__c = line.Description2__c;
                invl.Discount__c = line.Discount;
                invl.Hapara_Invoice__c = inv.Id;
                invl.Invoice_Date__c = inv.Invoice_Date__c;
                invl.Invoice_No__c =inv.Xero_Invoice_No__c;
                invl.List_Price__c = line.ListPrice;
                PricebookEntry price = mappedProduct.get( line.PricebookEntryId);
                invl.Product__c = price.Product2Id;
                invl.Product_Family__c = price.Product2.Family;
                invl.Not_Sync_to_Xero__c = price.Product2.Not_Sync_to_Xero__c;
                invl.Quantity__c = line.Quantity;
                invl.Subscription_End_Date__c = line.Subscription_End_Date__c;
                invl.Subscription_Start_Date__c=line.ServiceDate;
                invl.Unit_Price__c = line.UnitPrice;
                invlines.add(invl); 
            }
            insert invlines;
    }
    
    public PageReference cancel() {
        return fromPage;
    }
    
    public List<SelectOption> getOppSearchResults() {  
        string id = ApexPages.currentPage().getParameters().get('Id');   
        List<SelectOption> options = new List<SelectOption>();
        string nameSearch ='';
        
        if(oppmerge!= null){
            nameSearch = oppmerge.Name +'%';
            system.debug('***getOppSearchResults - oppmerge is not null-'+nameSearch);
        }
            
        List<Opportunity> opps =  [Select p.Name,p.StageName,p.closeDate,  p.Id From Opportunity p 
             where p.Name like :nameSearch and p.Id !=:id ];
        options.add(new SelectOption('0001', '--Select--'));
        for(Opportunity c : opps ){
            options.add(new  SelectOption(c.id, c.Name + '('+ c.StageName +' closes on ' + c.CloseDate.format()+ ')'));
            
        } 
        return options;
    }
    
    public PageReference searchOpportunity(){
        list<SelectOption> options = getOppSearchResults();
        if(options.size()>1){
            canProcess ='true';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, 
                'Please select an Opportunity and click on the Merge button. This will copy all the current Opportunity history to the selected Opportunity and delete the current Opportunity.'));  
        }
        else
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Warning, 'Cannot find opportunity matching the name.'));   
        return null; 
    }
    
    public PageReference mergeOpportunity(){
        string id = ApexPages.currentPage().getParameters().get('Id');
        system.debug('***mergeOpportunity - id-'+Id +' merge into ' + opportunitySearchId);
        PageReference page;
        Opportunity record ;
        if(opportunitySearchId == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Warning, 'Please search and select an opportunity to merge into.'));   
            page = ApexPages.currentPage(); 
        }else{
            try{
                 record =  [Select SyncedQuoteId, 
                (
                    Select  BillingCity,BillingCountry,BillingName,BillingPostalCode,BillingState,BillingStreet,ContactId,Description,
                    Email,ExpirationDate,Name,Pricebook2Id,QuoteNumber,ShippingName,Status,CreatedById,CreatedDate,
                    IsSyncing 
                    From Quotes where IsDeleted = false
                ),  
                (
                    Select OpportunityId,ContactId,IsPrimary,Role
                    From OpportunityContactRoles where IsDeleted = false
                ), 
                (
                    Select OpportunityId,CompetitorName,Strengths,Weaknesses 
                    From OpportunityCompetitors where IsDeleted = false
                ), 
                (Select WhatId From Events), 
                (Select WhatId From Tasks),
                (
                    Select ParentId,BodyLength,ContentType,Description,Name
                    From Attachments where isDeleted = false
                ) 
                From Opportunity o  where o.Id =:id ];
                
                for(Quote q : record.Quotes){
                    Quote newq = new Quote();
                    newq.OpportunityId = opportunitySearchId;
                    newq.Old_Quote_No__c = q.QuoteNumber;
                    newq.BillingCity = q.BillingCity;
                    newq.BillingCountry = q.BillingCountry;
                    newq.BillingName=q.BillingName;
                    newq.BillingPostalCode= q.BillingPostalCode;
                    newq.BillingState = q.BillingState;
                    newq.BillingStreet = q.BillingStreet;
                    newq.ContactId=q.ContactId ;
                    newq.Description= q.Description;
                    newq.Email= q.email;
                    newq.ExpirationDate = q.ExpirationDate;
                    newq.Name = q.Name;
                    newq.Pricebook2Id = q.Pricebook2Id;
                    newq.ShippingName=q.ShippingName;
                    newq.Status= q.Status;
                    newq.Old_Quote_Created_by__c = q.CreatedById;
                    newq.Old_Quote_Created_On__c=q.CreatedDate;
                    
                    insert newq;
                    
                    list<QuoteLineItem> lines = [
                                                select CurrencyIsoCode,Description2__c,Discount,PricebookEntryId,Quantity,QuoteId,ServiceDate,
                                                SortOrder,Subscription_End_Date__c,UnitPrice
                                                from QuoteLineItem l where l.QuoteId = : q.Id
                                                ];
                    list<QuoteLineItem> newlines = new list<QuoteLineItem>();
                    for(QuoteLineItem l: lines){
                        QuoteLineItem newl = new QuoteLineItem();
                        newl.Description2__c=l.Description2__c;
                        newl.Discount=l.Discount;
                        newl.PricebookEntryId=l.PricebookEntryId;
                        newl.Quantity=l.Quantity;
                        newl.QuoteId=newq.Id;
                        newl.ServiceDate=l.ServiceDate;
                        newl.Subscription_End_Date__c=l.Subscription_End_Date__c;
                        newl.UnitPrice = l.UnitPrice;
                        newlines.add(newl);
                    }
                    if(newlines.size()>0)
                        insert newlines;
                }
                
                list<OpportunityContactRole> contactRoles = new list<OpportunityContactRole>();         
                for(OpportunityContactRole o : record.OpportunityContactRoles ){
                    OpportunityContactRole newo = new OpportunityContactRole();
                    newo.OpportunityId= opportunitySearchId;
                    newo.ContactId = o.ContactId;
                    newo.IsPrimary = o.IsPrimary;
                    newo.Role = o.role;
                    contactRoles.add(newo);
                }
                if(contactroles.size()>0)
                    insert contactRoles;
                
                list<OpportunityCompetitor> newComps = new list<OpportunityCompetitor>();
                for(OpportunityCompetitor c : record.OpportunityCompetitors){
                    OpportunityCompetitor newc = new OpportunityCompetitor();
                    newc.OpportunityId = opportunitySearchId;
                    newc.CompetitorName = c.CompetitorName;
                    newc.Strengths= c.Strengths;
                    newc.Weaknesses = c.Weaknesses;
                    newComps.add(newc);
                }
                if(newComps.size()>0)
                    insert newComps;
            
                for(Event e : record.Events)
                    e.WhatId = opportunitySearchId;
                if(record.Events.size()>0)
                    update record.Events;
                
                for(Task t : record.Tasks)
                    t.WhatId = opportunitySearchId;
                if(record.Tasks.size()>0)
                    update record.Tasks;
                
                
                list<Attachment> newAttachs = new list<Attachment>();
                for(Attachment a : record.Attachments){
                    Attachment body = [ select body from Attachment where id=:a.Id];
                    
                    Attachment newa = new Attachment();
                    newa.ParentId = opportunitySearchId;
                    newa.Body = body.Body;
                    newa.ContentType=a.ContentType;
                    newa.Description = a.Description;
                    newa.Name = a.Name;
                    newAttachs.add(newa);
                }
                if(newAttachs.size()>0) 
                    insert newAttachs;
                    
                
                
                page = new PageReference('/'+opportunitySearchId);
            }catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'COPYING OPPORTUNITY HISTORY:' +  e));
                return  null;
            }
            try{
                if(record != null)
                    delete record;
            }catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'DELETING OLD OPPORTUNITY:' + e));
                return null;
            }
        }
        return page;
    }
    
    private static testmethod void testNewButtons() {
        
        // Set the test page
        Account acc = new Account();
        acc.Name = 'Account';
        acc.Type = 'Customer';
        acc.BillingStreet = 'test street';
        acc.BillingCity = 'test city';
        //acc.BillingState = 'test state';
        acc.BillingPostalCode = 'test zip code';
        acc.BillingCountry = 'United States';   
        acc.CurrencyIsoCode = 'USD';
         
        insert acc;
        
        Contact c = new Contact();
        c.FirstName = 'test';
        c.LastName = 'testLate';
        c.AccountId = acc.Id ;
        c.Email = 'test@gmail.com';
        insert c;
        acc.Invoice_Contact__c= c.Id;
        update acc;
        
        PageReference page = new PageReference('/apex/Hapara_InvoiceNewButton?retUrl=006&CF00NO0000000oH1P_lkid=' + acc.Id);
        Test.setCurrentPage(page);
        ApexPages.StandardController controller = new ApexPages.StandardController(new Hapara_Invoice__c());
        Hapara_NewButon extension = new Hapara_NewButon(controller);
        PageReference redirect = extension.onloadHaparaInvoice();
        System.assertNotEquals(null, redirect, 'Expected to be redirected');
        
        
        Hapara_Invoice__c inv = new Hapara_Invoice__c();
        inv.Invoice_Date__c = Date.today();
        inv.Account__c = acc.Id;
        inv.Due_Date__c= Date.today();
        insert inv;
        
        PageReference page2 = new PageReference('/apex/Hapara_InvoiceNewButton?retUrl=006&CF00NO0000000oH1P_lkid=' + acc.Id);
        Test.setCurrentPage(page2);
        ApexPages.StandardController controller2 = new ApexPages.StandardController(new HaparaInvoicePayment__c());
        
        Hapara_NewButon extension2 = new Hapara_NewButon(controller2);
        redirect = extension.onloadHaparaPayment();
        System.assertNotEquals(null, redirect, 'Expected to be redirected');
        
        Opportunity opp = new Opportunity();
        opp.AccountId= acc.Id;
        opp.Primary_Contact__c = acc.Invoice_Contact__c;
        opp.StageName ='Prospecting';
        opp.CloseDate = Date.today();
        opp.Opportunity_Name_Template__c = 'Getting STarted';
        opp.Name='test';
        opp.Amount = 1.0;
        opp.CurrencyIsoCode = acc.CurrencyIsoCode;
        insert opp;
        Opportunity oppMergeTo = new Opportunity();
        oppMergeTo.AccountId= acc.Id;
        oppMergeTo.Primary_Contact__c = acc.Invoice_Contact__c;
        oppMergeTo.StageName ='Prospecting';
        oppMergeTo.CloseDate = Date.today();
        oppMergeTo.Opportunity_Name_Template__c = 'Getting STarted';
        oppMergeTo.Name='test Merge To-**';
        oppMergeTo.Amount = 1.0;
        oppMergeTo.CurrencyIsoCode = acc.CurrencyIsoCode;
        insert oppMergeTo;
        
        Product2 prod = [Select p.Subscription_Type__c, p.Name, p.Description
                        From Product2 p where p.ProductCode ='TD' limit 1];
        PricebookEntry price = [Select Id, Name, Pricebook2Id, Product2Id, CurrencyIsoCode, UnitPrice, IsActive, 
                        UseStandardPrice, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, 
                        ProductCode, IsDeleted From PricebookEntry where IsActive = true 
                        and CurrencyIsoCode ='USD' and Product2Id =:prod.Id limit 1 ] ;
                        
        OpportunityLineItem line = new OpportunityLineItem();
        line.Account__c = acc.id;
        line.PricebookEntryId = price.Id;
        line.Description2__c = 'test';
        line.Discount=20;
        line.OpportunityId = opp.Id;
        line.Quantity = 1;
        line.ServiceDate =  Date.today();
        line.Subscription_End_Date__c = Date.today();
        line.UnitPrice = 2.0;
        insert line;
        PageReference page3 = new PageReference('/apex/'+HAPARA_CONST.OPPORTUNITY_CREATENEWINVOICE_PAGE+'?retUrl='+opp.Id+'&id=' + opp.Id);
        Test.setCurrentPage(page3);
        ApexPages.StandardController controller3 = new ApexPages.StandardController(new Opportunity());
        Hapara_NewButon extension3 = new Hapara_NewButon(controller2);
        PageReference url1 =  extension3.CreateNewInvoiceCloseOpportunity();
        system.assert(url1!=null);
        PageReference url2 = extension3.CreateNewInvoiceNotCloseOpportunity();
        system.assert(url2!=null);
        PageReference url3 = extension3.cancel();
        system.assert(url3 != null);
        
        Quote newq = new Quote();
        newq.OpportunityId = opp.Id;
        newq.BillingCity = acc.BillingCity;
        newq.BillingCountry = acc.BillingCountry;
        newq.BillingName=acc.Name;
        newq.BillingPostalCode= acc.BillingPostalCode;
        newq.BillingState = acc.BillingState;
        newq.BillingStreet = acc.BillingStreet;
        newq.ContactId=acc.Invoice_Contact__c ;
        newq.Description= 'test';
        newq.Email= c.email;
        newq.ExpirationDate = date.today();
        newq.Name = opp.Name;
        newq.Pricebook2Id = price.Pricebook2Id;
        newq.ShippingName=acc.Name;
        newq.Status='Draft';
        insert newq;
        
        QuoteLineItem newl = new QuoteLineItem();
        newl.Description2__c=line.Description2__c;
        newl.Discount=line.Discount;
        newl.PricebookEntryId=line.PricebookEntryId;
        newl.Quantity=line.Quantity;
        newl.QuoteId=newq.Id;
        newl.ServiceDate=line.ServiceDate;
        newl.Subscription_End_Date__c=line.Subscription_End_Date__c;
        newl.UnitPrice = line.UnitPrice;
        insert newl;
        
        OpportunityContactRole newo = new OpportunityContactRole();
        newo.OpportunityId= opp.Id;
        newo.ContactId = acc.Invoice_Contact__c;
        newo.IsPrimary = true;
        newo.Role = 'test';
        insert newo;
        
        OpportunityCompetitor newc = new OpportunityCompetitor();
        newc.OpportunityId = opp.Id;
        newc.CompetitorName = 'test comp';
        newc.Strengths= 'test strengths';
        newc.Weaknesses = 'test Weaknesses';
        insert newc;
        
        Event e = new Event();
        e.WhatId = opp.Id;
        e.ActivityDate = date.today();
        e.description = 'test';
        e.Subject = 'test';
        e.WhoId = acc.Invoice_Contact__c;
        e.DurationInMinutes = 1;
        e.ActivityDateTime = Datetime.now();
        insert e;
        
        Task t = new Task();
        t.Status = 'Completed';
        t.whoId = acc.Invoice_Contact__c;
        t.WhatId = opp.Id;
        t.ActivityDate = date.today();
        t.description = 'test';
        t.Subject = 'test';
        insert t;
        
        Attachment newa = new Attachment();
        newa.ParentId = opp.Id;
        newa.Body = Blob.valueOf('Some Text');
        newa.Description = 'test';
        newa.Name = 'test';
        insert newa;
        
        PageReference page4 = new PageReference('/apex/Hapara_OpportunityMerge?id=' + opp.Id);
        Test.setCurrentPage(page4);
        ApexPages.StandardController controller4 = new ApexPages.StandardController(new Opportunity());
        Hapara_NewButon extension4 = new Hapara_NewButon(controller4);
        Opportunity oppMerge = extension4.getOpportunityMergeTo();
        oppMerge.Name = 'test Merge To-*';        
        extension4.searchOpportunity();
        system.assert(extension4.getCanProcess()=='true');
        list<SelectOption> values = extension4.getOppSearchResults();
        extension4.opportunitySearchId = values[1].getValue();
        PageReference result4 = extension4.mergeOpportunity();
        system.assert(result4.getUrl() != null);
        

        PageReference page5 = new PageReference('/apex/NewOpportunityButtonOverride?retUrl=006&accId=' + acc.Id);
        Test.setCurrentPage(page5);
        ApexPages.StandardController controller5 = new ApexPages.StandardController(new Opportunity());
        Hapara_NewButon extension5 = new Hapara_NewButon(controller5);
        PageReference redirect5 = extension5.onloadOpportunity();
        System.assertNotEquals(null, redirect, 'Expected to be redirected');
        
    }
    
}