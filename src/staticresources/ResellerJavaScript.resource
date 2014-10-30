function CountryState(countryvalue,statevalue,ctrlCountryName, ctrlStateName){
		if(countryvalue.length >0){
			document.getElementById(ctrlCountryName).value = countryvalue;
			print_state(ctrlStateName,countryvalue);
			if(statevalue.length >0){
				document.getElementById(ctrlStateName).value = statevalue;
			}
		}
}

function confirmCancel() {
      var isCancel = confirm("Are you sure you wish to cancel?");
      if (isCancel) return true;
  
     return false;
  }  
  
 function validateEmail(){
  	var emailDomains = document.getElementById('resellerEmailDomain');
  	var repEmail = document.getElementById('{!$Component.frm.resellerRepEmail}');
  	if(repEmail.value.length >0){
  		var emaildomain = emailDomain.split(";");
  		var foundDomain = false;
  		for(i=0; emaildomain.length; i++){
  			if(repEmail.value.indexOf(emailDomain.value)>1 ||repEmail.value.indexOf('hapara.com')>1){
  				foundDomain = true;
  				break;
  			}
  		}
  	
	  	if(foundDomain)
	  		return true;
	  	else{
	  		alert("The email you have enter is not registered with our system. Please contact our Hapara Reseller Support if you wish to be registered?");
	  		return false;
	  	}
  	}else{
  		alert("Please enter an email in the 'Sales Rep Email' field.");
  		return false;
  	}
 }
 
 function ValidatePersonalEmail(emailAddress){
	if(emailAddress.length>0){
		if(emailAddress.indexOf('gmail.com') >0)
			return false;
		if(emailAddress.indexOf('yahoo.com') >0)
			return false;
		if(emailAddress.indexOf('hotmail.com') >0)
			return false;
		if(emailAddress.indexOf('aol.com') >0)
			return false;
	}
	return true;
}