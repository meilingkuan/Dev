public class SurveyEditController {
	private Survey_Question__c questionToAdd;
	public boolean editQuestion{get;set;}
	public String  questionReference{get; set;}
	private string surveyEditPageUrl = '/apex/SurveyEditPage';

   /** Class: question
    *  Retrieves the question information and puts it in the question object
    */    
	  public class question{
	      public String   name                   {get; set;}
	      public String   id                     {get; set;}
	      public String   question               {get; set;}
	      public String   orderNumber            {get; set;}
	      public String   choices                {get; set;}
	      public List<SelectOption> singleOptions{get; set;}
	      public List<SelectOption> multiOptions {get; set;}
	      public Boolean  required               {get; set;}
	      public String   questionType           {get; set;}  
	      public String   surveyName             {get; set;}
	      public String   renderFreeText         {get; set;}
	      public String   renderSelectRadio      {get; set;}
	      public String   renderSelectCheckboxes {get; set;} 
	      public String   renderSelectRow        {get; set;}
	      public List<String> responses          {get; set;}
	      public String   singleOptionsForChart  {get; set;}
	      public String   qResultsForChart       {get; set;} 
	      public List<String> strList            {get; set;} // The question's option as a list of string
	      public List<Integer> resultsCounts     {get; set;} // The count of each response to a question's choices
	      public List<SelectOption> rowOptions   {get; set;}
	      public boolean  noData                 {get; set;}
	      
	    /** Fills up the question object
	     *  param:  Survey_Question__c 
	       */     
	     public question(Survey_Question__c sq) {
		     name = sq.Name;
		     id = sq.Id;
		     System.debug('in Question found one with id '+id);
		     // question = sq.Question__c;
		     question = sq.Rich_Question__c;
		     orderNumber = String.valueOf(sq.OrderNumber__c+1);
		     choices = sq.Choices_Large__c;
		     required = sq.Required__c;
		     questionType = sq.Type__c;
		     singleOptionsForChart = ' ';
		     if (sq.Type__c=='Single Select--Vertical'){
		        renderSelectRadio='true';
		        singleOptions = stringToSelectOptions(choices);
		        renderSelectCheckboxes='false';
		        renderFreeText='false';
		        renderSelectRow = 'false';
		      }
		     else if (sq.Type__c=='Multi-Select--Vertical'){    
		        renderSelectCheckboxes='true';
		        multiOptions = stringToSelectOptions(choices);
		        renderSelectRadio='false';
		        renderFreeText='false';
		        renderSelectRow = 'false';
		      }
		     else if (sq.Type__c=='Single Select--Horizontal'){   
		        renderSelectCheckboxes='false';
		        rowOptions = stringToSelectOptions(choices);
		        renderSelectRadio='false';
		        renderFreeText='false';
		        renderSelectRow = 'true';
		      }
		     else if (sq.Type__c=='Free Text'){
		        renderFreeText='true';
		        renderSelectRadio='false';
		        renderSelectCheckboxes='false';
		        renderSelectRow = 'false';
		      }
	      }
	      
	     /** Splits up the string as given by the user and adds each option
	      *  to a list to be displayed as option on the Visualforce page
	      *  param: str String as submitted by the user
	      *  returns the List of SelectOption for the visualforce page
	        */  
	      private List<SelectOption> stringToSelectOptions(String str){
		      if (str == '')
		      {
		        return new List<SelectOption>();
		      }
		      strList = str.split('\n');
		    
		      List<SelectOption> returnVal = new List<SelectOption>();
		      for(String s: strList){
		        if (s!='') {
		          returnVal.add(new SelectOption(s,s));
		          if (s != 'null' && s!= null) {
		            String sBis = s.replace(' ', '%20');
		            singleOptionsForChart += s.trim()+'|';
		          }
		        }
		      }
		      singleOptionsForChart = singleOptionsForChart.substring(0, singleOptionsForChart.length()-1);
		      return returnVal;
	      } 
	  }
	 
	public SurveyEditController(ApexPages.StandardController stdController){
		editQuestion=false;
		if(Apexpages.currentPage().getParameters().containsKey('questionId')){
			string questionId = Apexpages.currentPage().getParameters().get('questionId');
			system.debug('***SurveyEditController - questionId=' +questionId );
			editQuestion = true;
			questionToAdd=  [Select s.Type__c, s.Id, s.Survey__c, s.Required__c, s.Question__c, s.Rich_Question__c,
			                    s.OrderNumber__c, s.Name, s.Choices__c ,Choices_Large__c
			                    From Survey_Question__c s 
			                    WHERE s.Id=:questionId];			              
		}
	}
	
	 /** Fills up the List of questions to be displayed on the Visualforce page
   	*/ 
   	public List<question> allQuestions        {get; set;}
   	public Integer allQuestionsSize           {get; set;}
	public List<question> getAQuestion() {
			Id  surveyId = Apexpages.currentPage().getParameters().get('id');
			if(allQuestionsSize == null){
			    List<Survey_Question__c> allQuestionsObject = 
			                    [Select s.Type__c, s.Id, s.Survey__c, s.Required__c, s.Question__c, s.Rich_Question__c,
			                    s.OrderNumber__c, s.Name, s.Choices__c ,Choices_Large__c
			                    From Survey_Question__c s 
			                    WHERE s.Survey__c =: surveyId ORDER BY s.OrderNumber__c];
			    allQuestions = new List<question>();
			    
			    Double old_OrderNumber = 0;
			    Double new_OrderNumber;
			    Double difference = 0;
			    /* Make sure that the order number follow each other (after deleting a question, orders might not do so) */
			    for (Survey_Question__c q : allQuestionsObject){ 
			      new_OrderNumber = q.OrderNumber__c;
			      difference = new_OrderNumber - old_OrderNumber - 1;
			      if (difference > 0) {
			        Double dd = double.valueOf(difference);
			        Integer newOrderInt = dd.intValue();
			        q.OrderNumber__c -= Integer.valueOf(newOrderInt); 
			      }
			      old_OrderNumber = q.OrderNumber__c;
			      question theQ = new question(q);
			      allQuestions.add(theQ);
			    }
			    allQuestionsSize = allQuestions.size();
		    }
		    
		    return allQuestions;
	} 
	
	public double getNextSurveyQuestionNumber(){
		return getAQuestion().size();
	}
	
	public Survey_Question__c getNewQuestions(){
		if(questionToAdd == null){
			questionToAdd = new Survey_Question__c();
		}
		
		return questionToAdd;
	}
	
	private boolean validateQuestionAdd(){
		boolean result = true;
		if(string.IsEmpty(questionToAdd.Rich_Question__c)){
			result = false;
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter the questions for this survey question.'));
		}
		if(questionToAdd.Type__c !='Free Text'){
			if(string.IsEmpty(questionToAdd.Choices_Large__c)){
				result = false;
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter answer choices for the non-Free Text questions.'));
			}
		}else{
			if(!string.IsEmpty(questionToAdd.Choices_Large__c)){
				result = false;
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Free Text questions cannot have answer choices.'));
			}
		}
		return result;
	}

	public PageReference addNewQuestionLink(){
		if(validateQuestionAdd()){
			try{
				Id  surveyId = Apexpages.currentPage().getParameters().get('id');
				questionToAdd.Survey__c = surveyId;
				questionToAdd.OrderNumber__c = getNextSurveyQuestionNumber();
				insert questionToAdd;
				question theQ = new question(questionToAdd);
				getAQuestion().add(theQ);
				questionToAdd = new Survey_Question__c();
			}catch(Exception e){
				string error ='***addNewQuestionLink: '+  e.getMessage() + '\n\n//-- Stack Trace --//\n' + e.getStackTraceString();
				HaparaSendEmailNotification.SendAdminErrorEmail('addNewQuestionLink', error, Apexpages.currentPage().getUrl());
				Apexpages.addMessage(new ApexPages.message(ApexPages.severity.Error,error));	
			}
		}
		return Apexpages.currentPage();
	}
	public PageReference updateQuestion(){
		PageReference newPage;
		Id  surveyId = Apexpages.currentPage().getParameters().get('id');
		try{
			if(validateQuestionAdd()){
				system.debug('***updateQuestion - questionlist size ='+getAQuestion().size() +'; question order number=' + questionToAdd.OrderNumber__c);
				if(questionToAdd.OrderNumber__c < getAQuestion().size() && questionToAdd.OrderNumber__c >=0){
					update questionToAdd;
					reOrderQuestionsNumber(surveyId);
				    newPage = new Pagereference(surveyEditPageUrl+'?id='+surveyId);
				    newPage.setRedirect(true);
				}else
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Question\'s order number must be within the number of Questions.'));			
			}
		}catch(Exception e){
				string error ='***updateQuestion: '+  e.getMessage() + '\n\n//-- Stack Trace --//\n' + e.getStackTraceString();
				HaparaSendEmailNotification.SendAdminErrorEmail('updateQuestion', error, Apexpages.currentPage().getUrl());
				Apexpages.addMessage(new ApexPages.message(ApexPages.severity.Error,error));	
		}
		return newPage;
	}
	
	private void reOrderQuestionsNumber(string surveyId){
		allQuestions.clear();
	    double j = 0.0;
	    List<Survey_Question__c> allQuestionsObject = 
	                    [Select Type__c, Id, Survey__c, Required__c, 
	                    Question__c,Rich_Question__c, OrderNumber__c, Name, Choices__c,Choices_Large__c
	                    From Survey_Question__c  
	                    WHERE Survey__c =: surveyId
	                    order by OrderNumber__c];
	    for (Integer i =0; i< allQuestionsObject.size(); i++){
		      allQuestionsObject[i].OrderNumber__c= j;
		      question theQ = new question(allQuestionsObject[i]);
		      allQuestions.add(theQ);
		      j = j+1.0;
	    }
	    try{
	      update allQuestionsObject;
	     
	    }catch(Exception e){
	    	string error ='***reOrderQuestionsNumber: '+  e.getMessage() + '\n\n//-- Stack Trace --//\n' + e.getStackTraceString();
			HaparaSendEmailNotification.SendAdminErrorEmail('reOrderQuestionsNumber', error, Apexpages.currentPage().getUrl());
	      	Apexpages.addMessage(new ApexPages.message(ApexPages.severity.Error,error));
	    }
	}
	
	 public Pagereference deleteExistingRefresh(){
 		Pagereference newPage ;
 		Id  surveyId = Apexpages.currentPage().getParameters().get('id');
	    if (questionReference!= null )
	    {
	    	try{
	    		system.debug('***deleteExistingRefresh - reference=' +questionReference );
		         Survey_Question__c sq = [Select Id, Name FROM Survey_Question__c WHERE Id =: questionReference];
		         delete sq;  
		         questionReference = null;  
		         reOrderQuestionsNumber(surveyId);
		         newPage = new Pagereference(surveyEditPageUrl+'?id='+surveyId);
		    }catch(Exception e){
				string error ='***deleteExistingRefresh: '+  e.getMessage() + '\n\n//-- Stack Trace --//\n' + e.getStackTraceString();
				HaparaSendEmailNotification.SendAdminErrorEmail('deleteExistingRefresh', error, Apexpages.currentPage().getUrl());
				Apexpages.addMessage(new ApexPages.message(ApexPages.severity.Error,error));	
			}
	    }
	    return newPage;
	 }
	 
	 public Pagereference editExistingQuestion(){
	 	Pagereference newPage ;
	 	if (questionReference!= null ){
	 		Id  surveyId = Apexpages.currentPage().getParameters().get('id');
	 		system.debug('***editExistingQuestion - reference=' +questionReference );
	 		newPage = new Pagereference(surveyEditPageUrl+'?id='+surveyId+'&questionId='+ questionReference);
	 		newPage.setRedirect(true);
		}
        return newPage;
	 }
	 
	 public Pagereference cancelEditQuestion(){
	 	Id  surveyId = Apexpages.currentPage().getParameters().get('id');
	 	Pagereference newPage = new Pagereference(surveyEditPageUrl+'?id='+surveyId);
	 	newPage.setRedirect(true);
	 	return newPage;
	 }
}