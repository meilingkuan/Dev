@isTest(SeeAllData=true)
global class HAPARA_CONST {
	//Lead Variables
		public static string  LEAD_CONVERTED_STATUS = 'Converted';
		public static string  LEAD_DEFAULT_OPP_STATE = 'Teacher Dashboard Getting Started';
		public static string  LEAD_TYPE_SUSPICIOUS = 'Suspicious';
		
	//Account Variables
		public static string  ACCOUNT_TYPE_CUSTOMERDIRECT='Customer Direct';
		public static string  ACCOUNT_TYPE_CUSTOMERRESELLER = 'Customer of Reseller';
		public static string  ACCOUNT_TYPE_CUSTOMERGOOGLEAPP = 'Customer of Google App Pack';
		public static string  ACCOUNT_TYPE_PROSPECTDIRECT='Prospect';
		public static string  ACCOUNT_TYPE_PROSPECTRESELLER = 'Prospect of Reseller'; 
		public static string  ACCOUNT_TYPE_PROSPECTGOOGLEAPP = 'Prospect of Google App Pack';
    
    	public static string  ACCOUNT_INVOICEPERIOD_YEARLY = 'Yearly';
    	public static string  ACCOUNT_INVOICEPERIOD_MONTHLY = 'Monthly';
    	
	//Opportunity Variables
		public static string  OPPORTUNIYT_STAGE_WON='Closed Won';
		public static string  OPPORTUNITY_STAGE_APPROVEDPO = 'Approved Purchase Order';
		public static string  OPPORTUNITY_STATGE_PROCESSINGPO = 'Processing Purchase Order';
		public static string  OPPORTUNITY_STATGE_RELLERPENDINGAPPROVAL = 'Pending Approval';
		public static string  OPPORTUNITY_STATGE_PENDINGPO = 'Pending Purchase Order';
		public static string  OPPORTUNITY_STAGE_APROVEREGISTRATION= 'Approved Registration';
		public static string  OPPORTUNITY_STAGE_DECLINEDREGISTRATION= 'Declined Registration';
		public static string  OPPORTUNITY_STAGE_DEMONSTRATION = 'Demonstration';
		public static string  OPPORTUNITY_STAGE_NEGOTIATION = 'Negotiation/Review';
		public static string  OPPORTUNITY_STAGE_INVOICING = 'Invoicing';
		public static string  OPPORTUNITY_STAGE_LOST = 'Closed Lost: Unknown';
		
		public static string  OPPORTUNITY_CREATENEWINVOICE_PAGE = 'Hapara_OpportunityCreateInvoice';
		public static string  OPPORTUNITY_MERGE = 'Hapara_OpportunityMerge';
		
		public static string  OPPORTUNITY_RECORD_TYPE_RESELLER = 'Reseller_Opportunity';
		public static string  OPPORTUNITY_RECORD_TYPE_STANDARD = 'Standard_Opportunity';
		
		public static string  OPPORTUNITY_TEMPLATENAME_RENEWAL = 'Renewal';
		public static string  OPPORTUNITY_TEMPLATENAME_TDI = 'Teacher Dashboard Innovator';
		
		public static string  OPPORTUNITY_TYPE_EXISTING = 'Existing Business';
		
	//Product Variables
		public static string  PRODUCT_FAMILY_TD = 'TD';
		public static string  PRODUCT_FAMILY_TDRC = 'TD + RC';
		public static string  PRODUCT_FAMILY_RC = 'RC';
		public static string  PRODUCT_FAMILY_SIS = 'SIS';
		public static string  PRODUCT_FAMILY_RTI = 'RTI';
		public static string  PRODUCT_FAMILY_TDI = 'TDI';
		public static string  PRODUCT_FAMILY_TDSUPPORT ='TD SUPPORT';
		
	//REVENUE Variables
		public static string  REVENUE_TYPEOFACCOUNTING_GAAP = 'GAAP';
		public static string  REVENUE_TYPEOFACCOUNTING_MRR = 'MRR';
		
	//INVOICE VARIABLEs
		public static string  INVOICE_STATUS_ERRORED ='Errored';
		public static string  INVOICE_STATUS_SENT_INVOICE = 'Sent Invoice to Customer';
		public static string  INVOICE_STATUS_UPDATED_TO_XERO ='Updated to Xero';
		public static string  INVOICE_STATUS_GENERATE_INVOICE ='Generating Invoice PDF' ;
	   	public static string  INVOICE_STATUS_RETRIEVED_INVOICE ='Retrieved Invoice PDF';
	   	public static string  INVOICE_STATUS_PAID='Paid';
	   	public static string  INVOICE_STATUS_PARTPAID='Part Paid';
	   	public static string  INVOICE_STATUS_DELETED = 'Deleted';
	   	public static string  INVOICE_STATUS_CANCELLED='Cancelled';
	   	public static string  INVOICE_STATUS_UPDATING_TO_XERO = 'Updating to Xero';
	   	
	   	public static string  INVOICE_TYPE_SALESINVOICE = 'Sales Invoice';
	   	public static string  INVOICE_TYPE_PURCHASEINVOICE = 'Purchase Invoice';
	 
	//CAMPAING VARIABLES
		public static string  CAMPAIGNMEMBER_STATUS_CONFIRMED = 'CONFIRMED';
	   	public static string  CAMPAIGNMEMBER_STATUS_UNCONFIRMED = 'UNCONFIRMED';
	   	public static string  CAMPAIGNMEMBER_STATUS_ATTENDED = 'ATTENDED';
	   	public static string  CAMPAIGNMEMBER_STATUS_NONATTENDANCE = 'NON-ATTENDANCE';
	   	public static string  CAMPAIGNMEMBER_STATUS_CANCELLED = 'CANCELLED';
	   	public static string  CAMPAIGNMEMBER_STATUS_RESCHEDULED = 'RE-SCHEDULED';
	   	
	   	//Mail Chimp status
	   	public static string[]  CAMPAIGNMEMBER_MCSTATUSES = new string[]{'abuse','bounce','click','open','sent','unsub'};
	   	
	   	public static string  CAMPAIGN_REMINDER_1 = '1st Reminder';
	   	public static string  CAMPAIGN_REMINDER_2 = '2nd Reminder';
	   	public static string  CAMPAIGN_REMINDER_3 = '3rd Reminder';
	   	
	   	public static string  CAMPAIGN_DIRECTSALES = 'Direct Teacher Dashboard Sales';
	   	public static string  CAMPAIGN_RESELLER = 'Reseller/ Referral';
	   	
	   	public static string  CAMPAIGN_TYPE_CONFERENCE = 'Seminar / Conference';
	   	
	 //Scheduling Variable
	 	public static string   HAPARA_WEEKLYSCHEDULING_STATUS_CONFIRMED = 'Confirmed';
	 	public static string   HAPARA_WEEKLYSCHEDULING_STATUS_TENTATIVE = 'Tentative';
	 	public static string   HAPARA_ENGINEERSCHEDULEDTIMES_STATUS_ERRORED = 'Errored';
	 	public static string   HAPARA_ENGINEERSCHEDULEDTIMES_STATUS_GENERATED = 'Generated Events';
	   	
	//Customer Portal Variables
		public static String   CUSTOMER_PORTAL_UNAUTHOIZE_URL ='/apex/HaparaCustomerUnAuthorize';
		public static String   CUSTOMER_PORTAL_SuccessfulRegistration = '/apex/HaparaCustomerProductRegSucessful';
		public static String   CUSTOMER_PORTAL_CancelRegistration = '/apex/HaparaCustomerProductRegCancel';
		public static String   CUSTOMER_PORTAL_SCHEDULINGCONFIRM_URL ='/apex/Hapara_SchedulingConfirmForm';
		public static String   CUSTOMER_PORTAL_SCHEDULINGCONFIRM_MSG_URL ='/apex/Hapara_SchedulingMsgForm';
		public static string   CUSTOMER_PORTAL_SCHEDULINGSETUPBOOKING_URL = '/Customer/Hapara_Schedulingsetupbookingform';
		
		public static String   CUSTOMER_HAPARAWEB_THANKYOU = '/apex/Hapara_WebFormThankYou';
		public static String   CUSTOMER_HAPARAWEB_CUSTOMERENQUIRY = '/apex/Hapara_WebCustomerEnquiry';

	//RESELLER PORTAL VARIABLES
		public static string   RESELLER_PORTAL_UNAUTHORIZE_URL = '/apex/HaparaResellerUnAuthorize';
		public static string   RESELLER_PORTAL_DEALREGISTRATION_URL = '/Reseller/HaparaRSDealRegistration';
		public static string   RESELLER_PORTAL_WELCOME_URL = '/Reseller/HaparaRSWelcome';
		public static string   RESELLER_PORTAL_SENDREGISTRATION_URL ='/Reseller/HaparaRSSendRegistrationReport';
		public static string   RESELLER_PORTAL_UPDATEREGISTRATION_URL = '/Reseller/HaparaResellerUpdateRegistration';
		public static string   RESELLER_PORTAL_REGISTERREP_URL = '/Reseller/HaparaRSRegisterRep';
		public static string   RESELLER_PORTAL_SUCCESSFULREGISTRATION_URL = '/Reseller/HaparaRSSuccsessfulRegistration';
		public static string   RESELLER_PORTAL_SUCCESSFULPO_URL = '/Reseller/HaparaRSSuccsessfulPO';
		public static string   RESELLER_PORTAL_EDITREGISTRATION_URL = '/Reseller/HaparaResellerEditRegistration';
		public static string   RESELLER_PORTAL_PURCHASEORDER_URL = '/Reseller/HaparaResellerPurchaseOrder';
		public static String   RESELLER_PORTAL_MARKETING_URL ='/Reseller/HaparaRSMarketingMaterials';
		
		public static string   RESELLER_SETUP_EMAIL_TEMPLATE = 'Contact_Setup_Information_No_Templates';
		
	//AUDIT INFO
		public static string   AUDIT_INFO_CONTACTSTATUS_INVALIDEMAIL = 'Invalid Email';
		public static string   AUDIT_INFO_CONTACTSTATUS_BOUNCED = 'Bounced Contact';
		public static string   AUDIT_INFO_CONTACTSTATUS_UNSUBSCRIBED = 'Unsubscribed Contact';
		public static string   AUDIT_INFO_CONTACTSTATUS_CREATED = 'Created Contact';
		public static string   AUDIT_INFO_CONTACTSTATUS_PENDING = 'Pending';
		
		public static string   AUDIT_INFO_STATUS_MISSINGCONTACT = 'Missing Primary Contact';
		public static string   AUDIT_INFO_STATUS_PROCESSED ='Processed';
		
		
	//Custom settings
		public static HaparaSchedulerSettings__c SETTING_SCHEDULE = HaparaSchedulerSettings__c.getInstance();
		public static HaparaXeroConfig__c SETTING_INVOICE = HaparaXeroConfig__c.getInstance('Hapara');
		public static HaparaResellerSetting__c SETTING_RESELLER = HaparaResellerSetting__c.getInstance('Hapara'); 
		public static Hapara_Opportunity_Config__c SETTING_OPPORTUNITY_CONFIG = Hapara_Opportunity_Config__c.getInstance(); 
		public static Hapara_Admin_Setting__c SETTING_ADMIN_CONFIG = Hapara_Admin_Setting__c.getInstance(); 
		
		//extract settins
		private static map<string,string> countriesCurrencyMapping ;
    

	    public static string getCountriesCurrencyMapping(string country){
	        string result = 'USD';
	        country = country.Trim().toLowerCase();
	        system.debug('****getCoutriesCurrencyMapping country=' +country);
	        if(countriesCurrencyMapping==null){
	        	countriesCurrencyMapping  =  new map<string,string>();
	            string configStr = SETTING_INVOICE.Countries_Currency_Mapping__c;
	            list<string> configs = configStr.split(';');
	            for(string s : configs){
	                list<string> config = s.split(':');
	                countriesCurrencyMapping.put(config[0].toLowerCase(), config[1]);
	                system.debug('****getCoutriesCurrencyMapping put: ' +config[0].toLowerCase() +',' + config[1]);
	            }
	        }
	        
	        if(countriesCurrencyMapping.containsKey(country)){
	        	result = countriesCurrencyMapping.get(country);
	        }
	          
	        return result;
	    }
	    
	   
	
		static testmethod void testHapara_Const(){
			system.assertEquals(HAPARA_CONST.getCountriesCurrencyMapping('New Zealand'),'NZD');
			system.assertEquals(HAPARA_CONST.getCountriesCurrencyMapping('United States'), 'USD');
	 		
		} 
}