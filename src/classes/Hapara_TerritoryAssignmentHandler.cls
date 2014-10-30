public with sharing class Hapara_TerritoryAssignmentHandler {
	
	
	public static void  AssignTerritory(list<Id> accounts){
		list<Account> accs = [select ownerid, name,type,
						 (Select CloseDate, IsClosed, OwnerId, CreatedDate
						 From ResellerRegisteredOpportunities__r
						 where Isclosed = false 
						 OR (Isclosed = true and CreatedDate>2013-12-31T23:59:59.000+0000 )
						 ), 
						 (Select CloseDate, IsClosed, OwnerId, CreatedDate 
						 From Opportunities
						 where Isclosed = false 
						 OR (Isclosed = true and CreatedDate>2013-12-31T23:59:59.000+0000 )
						 )  
						from Account 
						where (Type like 'Customer%' or Type like 'Prospect%')
						and Type != 'Prospect Reseller'
						and id in: accounts];
		
		list<AccountShare> groups = [Select a.UserOrGroupId, a.AccountId, a.account.name 
			From AccountShare a
			where RowCause = 'Territory' and accountId in : accounts]	;
			
		map<Id, Id> groupsId = new map<id,id>();
		for(AccountShare g: groups)
			groupsId.put(g.AccountId, g.UserOrGroupId);
			
		 //Query in Group object              
	    list<Group> listOfGroup = [Select Id, RelatedId from Group where Type='Territory' and Id IN :groupsId.Values()];
	    
		map<Id, Id> mapOfGroup = new Map<Id, Id>();
		//Map of Group object
	    for(Group groupRecord : listOfGroup){
	    	mapOfGroup.put(groupRecord.Id, groupRecord.RelatedId);         
	    }
			
		//Query in Territory object
	    list< Territory> territories =new list< Territory>([select id, name, ParentTerritoryId from Territory 
	    										where Id IN:mapOfGroup.Values() ]);   
	    
	    //Query in User Territory object from the parentTerritory
	   	map<id,id> parentTerritories = new map<id,id>();
	   	for(Territory t : territories){
	   		parentTerritories.put(t.id, t.ParentTerritoryId);
	   	}
	    list<UserTerritory> listOfUserTerritory = [Select u.UserId, u.TerritoryId, u.IsActive, u.Id From UserTerritory u 
	    		WHERE IsActive = true AND TerritoryId IN :parentTerritories.Values()];
	    		
		map<Id, list<id>> mapOfUserTerritory = new Map<Id, list<id>>();
		list<id> userIds = new list<id>();
		string checkTerritory;
		list<id> territoryUser;
		//Map of User Territory object
	    for(UserTerritory userTerritory : listOfUserTerritory){
	    	userIds.add(userTerritory.userId);
	    	if(checkTerritory == null || checkTerritory != userTerritory.TerritoryId){
	    		territoryUser = new list<id>();
	    		mapOfUserTerritory.put(userTerritory.TerritoryId, territoryUser);
	    	}
	    	territoryUser.add(userTerritory.UserId);          
	    }
		
		map<id,User> mapOfUser = new map<id,User>([select id,name,Is_Customer_Success__c,CreatedDate 
								from User where id in : userIds]);
		User us ;
		list<Account> accounttobeupdated = new list<Account>();
		list<Opportunity> opptobeupdated = new list<Opportunity>();
		map<id,id> mapOfOppTerritory = new map<id,id>();
		for(Account a : accs){
			us = null;
			if((a.Type.contains('Customer') ||a.Type.contains('Prospect'))
				&& !a.Type.Contains('Cold') && a.type != 'Prospect Reseller' ){
				Id group_id = groupsId.get(a.id);
				Id related_id = mapOfGroup.get(group_id);
				Id parentterritory_id = parentTerritories.get(related_id);
				territoryUser  =  mapOfUserTerritory.get(parentterritory_id);
				if(territoryUser.size()>0){
					//update account owner
					for(Id uId : territoryUser){
						us = mapOfUser.get(uId);
						if(a.Type.contains('Customer') && us.Is_Customer_Success__c){
							a.OwnerId = uId;
							break;
						}else if(a.Type.contains('Prospect') && !us.Is_Customer_Success__c){
							a.OwnerId = uId;
							break;
						}
					}
					accounttobeupdated.add(a);
					if(us != null){
						//update opportunity owner
						updateOpportunityOwner(a.ResellerRegisteredOpportunities__r, us,opptobeupdated,related_id ,mapOfOppTerritory);
						updateOpportunityOwner(a.Opportunities, us,opptobeupdated,related_id ,mapOfOppTerritory);
					}
				}
			}
		}
		if(accounttobeupdated.size()>0)
			update accounttobeupdated;
			
		if(opptobeupdated.size()>0)
			update opptobeupdated;
		
		list<OpportunityShare> oppShares = new list<OpportunityShare>([select OpportunityId, UserOrGroupId from OpportunityShare where OpportunityId in:mapOfOppTerritory.keySet()] );
		
		for(OpportunityShare opps: oppShares){
			
		}
	}
	
	private static void updateOpportunityOwner(list<Opportunity> opps, User us, list<Opportunity>opptobeupdated, id related_id, map<id,id> mapOfOppTerritory){
		boolean updated =false;
		for(Opportunity o : opps){
			updated = false;
			if(o.IsClosed && us.CreatedDate >= o.CreatedDate)
				updated = true;
			else if(!o.IsClosed)
				updated = true;
				
			if(updated){
				o.ownerId = us.id;
				opptobeupdated.add(o);
				mapOfOppTerritory.put(o.id, related_id);
			}
		}
	}
}