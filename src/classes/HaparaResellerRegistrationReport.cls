public class HaparaResellerRegistrationReport {
	public HaparaResellerRegistrationReport(){}
	
	private list<Opportunity> repOpportunities;
	
	public string repId {get;set;}
	
	public list<Opportunity> getRepOpportunities(){
		if(repOpportunities ==null && repId!=null){
			repOpportunities = [Select o.Reseller_s_Status__c, o.Reseller_s_Rep__c, 
			o.Name, o.CloseDate From Opportunity o where o.Reseller_s_Rep__c =:repId];			
		}
		return repOpportunities;
	}
}