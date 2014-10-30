/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(SeeAllData=true)
public class Hapara_XeroHandlerTest {

    static testMethod void testHapara_InvoiceXeroController() {
        list<Hapara_Invoice__c> obj = [Select h.Xero_Invoice_No__c, h.SystemModstamp, h.Status__c, h.Reseller_PO__c, h.Reseller_PO_Received_Date__c, 
            h.Reseller_Account__c, h.Process__c, h.Paid_Date__c, h.OwnerId, h.Name, h.LastModifiedDate, h.LastModifiedById, h.IsDeleted, 
            h.Invoice_Date__c, h.Id, h.HTTP_Response__c, h.Error_Message__c, h.Due_Date__c, h.Customer_PO__c, h.Customer_PO_Received_Date__c, 
            h.CurrencyIsoCode, h.CreatedDate, h.CreatedById, h.Case_Subject__c, h.Xero_Id__c,
            h.Account__r.Invoice_Contact__c, h.Account__r.CurrencyIsoCode, h.Account__r.Website, h.Account__r.BillingCountry, 
            h.Account__r.BillingPostalCode, h.Account__r.BillingState, h.Account__r.BillingCity, h.Account__r.BillingStreet, 
            h.Account__r.Name, h.Account__c, h.Account__r.Xero_Id__c
            From Hapara_Invoice__c h where h.Account__r.Invoice_Contact__c != null and h.Account__r.Xero_Id__c != null limit 1];
        
        PageReference page = new PageReference('/apex/Hapara_ProcessInvoiceToXeroButton');
        Test.setCurrentPage(page);
        ApexPages.StandardSetController stdcontroller = new ApexPages.StandardSetController(obj);
        
        stdcontroller.setSelected(obj);
        
        Hapara_XeroController controller = new Hapara_XeroController(stdcontroller);
        system.debug('****Hapara_XeroController: invoices size' + controller.getRecordSize(obj) );
        
        
        system.assertEquals(controller.getStep(), '1');
        
        system.assertEquals(controller.getProcessStatus(), 'processing');
        sfxero.XeroAPI.startTesting();
        System.assertEquals( controller.Process().getUrl(),'/apex/Hapara_ProcessInvoiceToXeroButton');
        System.assertEquals( controller.ProcessPDF().getUrl(),'/apex/Hapara_ProcessInvoiceToXeroButton');
        sfxero.XeroAPI.stopTesting();
        system.assertEquals(controller.reloadResult(), null);
        system.assert( controller.getProcessedInvoices().size()>0);
        system.assert(controller.cancel() != null);
        
        PageReference page2 = new PageReference('/apex/Hapara_ProcessInvoiceToXeroButton');
        Test.setCurrentPage(page2);
        ApexPages.StandardController controller2 = new ApexPages.StandardController(obj[0]);
        Hapara_XeroController xerocontroller = new Hapara_XeroController(controller2);
        System.assert( xerocontroller.onload().getUrl().contains('/apex/Hapara_ProcessInvoiceToXeroButton'));
        System.assert( xerocontroller.onloadSendToCustomer().getUrl().contains('/apex/Hapara_ProcessInvoiceXeroToCustomer'));
        
    }
    
    public static testmethod Hapara_Invoice__c CreateTestInvoice(){
        Account acc = new Account();
        acc.Name = 'test Company';
        acc.BillingCity = 'test street';
        acc.BillingCountry = 'United States';
        acc.BillingState = 'Washington';
        acc.CurrencyIsoCode='USD';
        
        Contact con = new Contact();
        con.FirstName= 'f';
        con.LastName = 'l';
        con.Email = 'mkua001@gmail.com';
        //con.AccountId = acc.Id;
        insert con;
        acc.Invoice_Contact__c = con.Id;
        insert acc;
        Hapara_Invoice__c inv = new Hapara_Invoice__c();
        inv.Xero_Invoice_No__c = 'INV-101910';
        inv.Account__c = acc.Id;
        inv.Invoice_Date__c = Date.today();
        inv.Due_Date__c = Date.today().addDays(30);
        inv.Customer_PO__c = 'djljl';
        inv.Invoice_To_Contact__c = con.Id;
        insert inv;
        Product2 pro = [Select r.Xero_Product_Code__c, r.Reseller_Product_Code_del__c, r.Reseller_Account_del__c, 
                            r.Id ,r.Description, r.family,r.Subscription_Period__c,r.Subscription_Type__c
                            From Product2 r where Xero_Product_Code__c != null limit 1];
        Account_Products__c line = new Account_Products__c();
        line.Account__c = acc.Id;
        line.Hapara_Invoice__c = inv.Id;
        line.Invoice_Date__c = inv.Invoice_Date__c;
        line.Product__c = pro.Id;
        line.Subscription_Start_Date__c  = inv.Invoice_Date__c;
        line.Subscription_End_Date__c = inv.Invoice_Date__c.addDays(30);
        line.Description__c= pro.Description;
        line.Unit_Price__c =4.0;
        line.Quantity__c = 1;
        line.Product_Family__c = pro.Family;
        line.CurrencyIsoCode = acc.CurrencyIsoCode;
        insert line;
        
        HaparaInvoicePayment__c payment = new HaparaInvoicePayment__c();
        payment.Account__c= inv.Account__c;
        payment.Invoice__c = inv.Id;
        payment.Amount_Paid__c = 1.0;
        payment.Currency_Rate__c = 1.0;
        payment.Date_Of_Payment__c = Date.today();
        payment.Payment_Check_No_Ref__c = 'zz';
        payment.Status__c = 'Updated to Xero';
        insert payment;
        
        return inv;
    }
    
    static testMethod void testHapara_InvoiceXeroHandler(){
        Hapara_Invoice__c inv = CreateTestInvoice();
        list<Hapara_Invoice__c> obj = new list<Hapara_Invoice__c>();
        list<Id> messageIds = new list<Id>();
        messageIds.add(inv.Id);
        obj.add(inv);
             
        Hapara_XeroHandler handler = new Hapara_XeroHandler();
        
        system.assert( handler.initialise(messageIds,'Updating to Xero')>0);
        sfxero.XeroAPI.startTesting();
        
        Hapara_XeroHandler.processRecords(messageIds,handler.consumerKey,handler.certificate);
        Hapara_XeroHandler.processPDF( messageIds, handler.consumerKey,handler.certificate );
        sfxero.XeroAPI.stopTesting();
        
        system.assert(Hapara_XeroHandler.getAcountCustomerTypeFromProspect(HAPARA_CONST.ACCOUNT_TYPE_PROSPECTDIRECT)!='');
 		system.assert(Hapara_XeroHandler.getAcountCustomerTypeFromProspect(HAPARA_CONST.ACCOUNT_TYPE_PROSPECTGOOGLEAPP)!='');
 		system.assert(Hapara_XeroHandler.getAcountCustomerTypeFromProspect(HAPARA_CONST.ACCOUNT_TYPE_PROSPECTRESELLER)!='');
        Hapara_XeroHandler.sendXeroAdministratorEmail('TEST',obj[0]);
        string filename = obj[0].Account__r.Name +' - ' + obj[0].Xero_Invoice_No__c + '.pdf';
        Hapara_XeroHandler.SendContactInvoiceEmail(obj[0].Account__r.Invoice_Contact__c, 
            obj[0], Blob.valueOf('Some Text'), filename);
    }
    
    static testMethod void testHapara_PaymentXeroHandler(){
        Hapara_Invoice__c inv = CreateTestInvoice();
        list<Hapara_Invoice__c> obj = new list<Hapara_Invoice__c>();
        obj.add(inv);
        list<Id> messageIds = new list<Id>();
        
        for(Hapara_Invoice__c inv2 :obj){
            HaparaInvoicePayment__c payment = new HaparaInvoicePayment__c();
            payment.Account__c= inv2.Account__c;
            payment.Invoice__c = inv2.Id;
            payment.Amount_Paid__c = 1.0;
            payment.Currency_Rate__c = 1.0;
            payment.Date_Of_Payment__c = Date.today();
            payment.Payment_Check_No_Ref__c = 'zz';
            insert payment;
            messageIds.add(payment.id);
        }
        PageReference page = new PageReference('/apex/Hapara_ProcessPaymentToXeroForm');
        Test.setCurrentPage(page);
             
        Hapara_XeroHandler handler = new Hapara_XeroHandler();
        
        system.assert( handler.initialisePayment(messageIds,'Updating to Xero')>0);
        sfxero.XeroAPI.startTesting();
        Hapara_XeroHandler.processPaymentIntoXero(messageIds,handler.consumerKey,handler.certificate);
        sfxero.XeroAPI.stopTesting();
            
    }
    
    static testMethod void testHapara_PaymentXeroController() {
        list<Hapara_Invoice__c> obj = [Select h.Xero_Invoice_No__c, h.SystemModstamp, h.Status__c, h.Reseller_PO__c, h.Reseller_PO_Received_Date__c, 
            h.Reseller_Account__c, h.Process__c, h.Paid_Date__c, h.OwnerId, h.Name, h.LastModifiedDate, h.LastModifiedById, h.IsDeleted, 
            h.Invoice_Date__c, h.Id, h.HTTP_Response__c, h.Error_Message__c, h.Due_Date__c, h.Customer_PO__c, h.Customer_PO_Received_Date__c, 
            h.CurrencyIsoCode, h.CreatedDate, h.CreatedById, h.Case_Subject__c, h.Xero_Id__c,
            h.Account__r.Invoice_Contact__c, h.Account__r.CurrencyIsoCode, h.Account__r.Website, h.Account__r.BillingCountry, 
            h.Account__r.BillingPostalCode, h.Account__r.BillingState, h.Account__r.BillingCity, h.Account__r.BillingStreet, 
            h.Account__r.Name, h.Account__c, h.Account__r.Xero_Id__c
            From Hapara_Invoice__c h where h.Account__r.Invoice_Contact__c != null 
            and h.Account__r.Xero_Id__c != null and h.Xero_Id__c != null limit 1];
            HaparaInvoicePayment__c payment;
            list<Id> messageIds = new list<Id>();
            for(Hapara_Invoice__c inv :obj){
                payment = new HaparaInvoicePayment__c();
                payment.Account__c= inv.Account__c;
                payment.Invoice__c = inv.Id;
                payment.Amount_Paid__c = 1.0;
                payment.Currency_Rate__c = 1.0;
                payment.Date_Of_Payment__c = Date.today();
                payment.Payment_Check_No_Ref__c = 'zz';
                insert payment;
                messageIds.add(payment.id);
                payment = new HaparaInvoicePayment__c();
                payment.Account__c= inv.Account__c;
                payment.Invoice__c = inv.Id;
                payment.Amount_Paid__c = 1.0;
                payment.Currency_Rate__c = 1.0;
                payment.Date_Of_Payment__c = Date.today();
                payment.Payment_Check_No_Ref__c = 'zz';
                payment.Status__c = 'Updated to Xero';
                insert payment;
            }
        PageReference page = new PageReference('/apex/Hapara_ProcessPaymentToXeroForm');
        Test.setCurrentPage(page);
        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(payment);
        
        Hapara_XeroPaymentController controller = new Hapara_XeroPaymentController(stdcontroller);
  
        system.assertEquals(controller.getProcessStatus(), 'processing');
        system.assertEquals(controller.getCanProcess(), 'true');
        
        sfxero.XeroAPI.startTesting();
        
        System.assertEquals( controller.processPayment().getUrl(),'/apex/Hapara_ProcessPaymentToXeroForm');
        
        sfxero.XeroAPI.stopTesting();
        system.assertEquals(controller.reloadResult(), null);
        
        system.assert(controller.cancel() != null);
        system.assertEquals( controller.processPaymentSendToCustomer().getUrl(),'/apex/Hapara_ProcessPaymentToXeroForm');
        
    }
    
    static testMethod void testHapara_InvoiceGetXeroHandler(){
        Hapara_Invoice__c inv = CreateTestInvoice();
        list<Hapara_Invoice__c> obj = new list<Hapara_Invoice__c>();
        obj.add(inv);
        list<Id> messageIds = new list<Id>();
        messageIds.add(inv.Id);
        PageReference page = new PageReference('/apex/Hapara_InvoiceGet');
        Test.setCurrentPage(page);
             
        Hapara_XeroHandler handler = new Hapara_XeroHandler();
        
        system.assert( handler.initialise(messageIds,'Updating to Xero')>0);
        sfxero.XeroAPI.startTesting();
        Hapara_XeroHandler.getXeroInvoices(messageIds,handler.consumerKey,handler.certificate);
        sfxero.XeroAPI.stopTesting();
            
    }
    
    static testMethod void testHapara_XeroInvoiceGetController() {
        list<Hapara_Invoice__c> obj = [Select h.Xero_Invoice_No__c, h.SystemModstamp, h.Status__c, h.Reseller_PO__c, h.Reseller_PO_Received_Date__c, 
            h.Reseller_Account__c, h.Process__c, h.Paid_Date__c, h.OwnerId, h.Name, h.LastModifiedDate, h.LastModifiedById, h.IsDeleted, 
            h.Invoice_Date__c, h.Id, h.HTTP_Response__c, h.Error_Message__c, h.Due_Date__c, h.Customer_PO__c, h.Customer_PO_Received_Date__c, 
            h.CurrencyIsoCode, h.CreatedDate, h.CreatedById, h.Case_Subject__c, h.Xero_Id__c,
            h.Account__r.Invoice_Contact__c, h.Account__r.CurrencyIsoCode, h.Account__r.Website, h.Account__r.BillingCountry, 
            h.Account__r.BillingPostalCode, h.Account__r.BillingState, h.Account__r.BillingCity, h.Account__r.BillingStreet, 
            h.Account__r.Name, h.Account__c, h.Account__r.Xero_Id__c
            From Hapara_Invoice__c h where h.Account__r.Invoice_Contact__c != null and h.Account__r.Xero_Id__c != null 
            and h.Xero_Id__c != null and h.Xero_Invoice_No__c != null
            limit 1];
        list<Id> messageIds = new list<Id>();
        for(Hapara_Invoice__c inv :obj){
            messageIds.add(inv.id);
        }
        
        
        PageReference page = new PageReference('/apex/Hapara_InvoiceGet');
        Test.setCurrentPage(page);
        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(obj[0]);
        
        Hapara_XeroInvoiceGetController controller = new Hapara_XeroInvoiceGetController(stdcontroller);
  
        system.assertEquals(controller.getProcessStatus(), 'processing');
        system.assertEquals(controller.getCanProcess(), 'true');
        
        sfxero.XeroAPI.startTesting();
        
        System.assertEquals( controller.retrieveInvoice().getUrl(),'/apex/Hapara_InvoiceGet');
        
        sfxero.XeroAPI.stopTesting();
        system.assertEquals(controller.reloadResult(), null);
        
        system.assert(controller.cancel() != null);
        
        
    }
    
     static testMethod void testHapara_InvoiceCancelXeroHandler(){
        Hapara_Invoice__c inv = CreateTestInvoice();
        PageReference page = new PageReference('/apex/Hapara_Invoice_Cancel?id='+ inv.id);
        Test.setCurrentPage(page);
		ApexPages.StandardController stdcontroller = new ApexPages.StandardController(inv);
		Hapara_Invoice_CancelController controller= new Hapara_Invoice_CancelController(stdcontroller);
		
        /**test get method**/
        system.assertEquals(controller.getTurnOnRefresh(), false);
        system.assertEquals(controller.getStep(),'1');
        system.assertEquals(controller.getDisableCancel(), false);
        
        /***test page navigation**/
        system.assert(controller.cancel()!= null);     
        system.assert(controller.reloadResult() == null);
        
        /*** test cancelling***/
        controller.getInvoice().Cancelled_Reason__c = 'Cancelled';
        sfxero.XeroAPI.startTesting();
        system.assert(controller.process() != null)  ;
        sfxero.XeroAPI.stopTesting();
       // inv = [select Id, status__c from Hapara_Invoice__c where id =: inv.id];
        //system.assertEquals(inv.status__c, HAPARA_CONST.INVOICE_STATUS_CANCELLED);      
       
       controller.getInvoice().Status__c = HAPARA_CONST.INVOICE_STATUS_PAID;
       system.assert(controller.process() != null)  ;
    }
}