public with sharing class viewSurveyResultsComponentController {

	public String surveyId {get;set;}
	
	
	public String reportId {get;set;}
	public PageReference results;
	
	public viewSurveyResultsComponentController()
	{
	    ReportFinderUtil rfu = new ReportFinderUtil();
	    reportId = rfu.findReportId('Survey with Questions and Responses'); 
	
	}
	
	
	public pageReference getResults()
	{
	    surveyId = surveyId.substring(0,15);
	    return new PageReference('/' + reportId + '?pv0=' + surveyId);
	}
	
	public list<SurveyTaker__c> getAllSurveyResponse(){
		return  [Select s.Id,s.Name, s.LastModifiedDate, s.Contact__r.Account_Name__c, s.Contact__r.Name, s.Contact__c From SurveyTaker__c s 
			where s.Survey__c =: surveyId];
	}
	
	private static testmethod void testResultController()
	{
	    Survey__c mySurvey = new Survey__c();
	    mySurvey.Submit_Response__c = 'empty';  
	    insert mySurvey;
	    
	    viewSurveyResultsComponentController vsr = new viewSurveyResultsComponentController();
	    vsr.surveyId = mySurvey.Id;
	    
	    String mySurveyId = mySurvey.Id;
	    PageReference pageRef = new PageReference ('/' + vsr.reportId + '?pv0=' + mySurveyId.substring(0,15));
	    System.assertEquals(pageRef.getURL(),vsr.getResults().getURL());
	    
	}

}