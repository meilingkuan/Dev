public class Hapara_Utility {
	public static Boolean isRunningInSandbox() {
	    Organization org = [select Id, IsSandbox from Organization limit 1];
	    return org.IsSandbox;
	}    
	
	public static String GetSandboxURL(){
		return 'https://hapara--dev.cs6.my.salesforce.com';
	}
	
	public static String GetProductionURL(){
		return 'https://hapara.my.salesforce.com';
	}
	
	public static Integer getMonthValuefromString(string mth){
		Integer month = 0;
		string value = mth.trim();
		if(value =='January')
			month = 1;
		else if(value =='February')
			month = 2;
		else if(value =='March')
			month= 3;
		else if(value =='April')
			month= 4;
		else if(value =='May')
			month= 5;
		else if(value =='June')
			month= 6;
		else if(value=='July')
			month= 7;
		else if(value =='August')
			month= 8;
		else if(value =='September')
			month= 9;
		else if(value =='October')
			month= 10;	
		else if(value =='November')
			month= 11;	
		else if(value =='December')
			month= 12;	
		return month;
	}
	
	public static string replaceLineBreakWithLineChar(string value){
		string result='';
		if(!string.isEmpty(value)){
			for(integer i=0; i< value.length();i++){
				string c = value.substring(i, i+1);
				if(c=='\r')
					result =result +  '';
				else if(c=='\n')
					result = result +  '<br/>';
				else 
					result =result+ c;
			}
		}
		return result;
	}
	
	public static boolean validatePersonalEmail(string email){
		if(email.contains('gmail.com'))
			return false;
		else if(email.contains('yahoo.com'))
			return false;
		else if(email.contains('hotmail.com'))
			return false;
		else if(email.contains('aol.com'))
			return false;
		else
			return true;
	
	}
	
}