function CountryState(country,state){
		this.Country = country;
		this.State = state;
		
}
var month=new Array();
        month[0]="January";
        month[1]="February";
        month[2]="March";
        month[3]="April";
        month[4]="May";
        month[5]="June";
        month[6]="July";
        month[7]="August";
        month[8]="September";
        month[9]="October";
        month[10]="November";
        month[11]="December";
		
var dayOfWeek= new Array();
	    dayOfWeek[0]="Sunday";
		dayOfWeek[1]="Monday";
		dayOfWeek[2]="Tuesday";
		dayOfWeek[3]="Wednesday";
		dayOfWeek[4]="Thursday";
		dayOfWeek[5]="Friday";
		dayOfWeek[6]="Saturday";
		
var timezoneCountry ={
	 	'Etc/GMT+12' : new CountryState('Unknown','Unknown'),
	    'Pacific/Pago_Pago': new CountryState( 'American Samoa','Eastern'),
	    'America/Adak': new CountryState('United States','Alaska'),
	    'Pacific/Apia': new CountryState('Samoa','Tuamasaga'),
	    'Pacific/Honolulu': new CountryState('United States','Hawaii'),
	    'Pacific/Marquesas' : new CountryState('French Polynesia','Archipel des Marquises'),
	    'Pacific/Gambier' : new CountryState('French Polynesia','Archipel des Tuamotu'),
	    'America/Anchorage' : new CountryState('United States','Alaska'),
	    'America/Los_Angeles' : new CountryState('United States','California'),
	    'Pacific/Pitcairn' : new CountryState('Pitcairn','Pitcairn Islands'),
	    'America/Phoenix' : new CountryState('United States','Arizona'),
	    'America/Denver' : new CountryState('United States','Colorado'),
	    'America/Guatemala' : new CountryState('Guatemala','Guatemala'),
	    'America/Chicago' : new CountryState('United States','Illinois'),
	    'Pacific/Easter' : new CountryState('Chile','Valparaiso'),
	    'America/Bogota' : new CountryState('Colombia','Distrito Capital de Santa Fe de Bogota'),
	    'America/New_York' : new CountryState('United States','New York'),
	    'America/Caracas' : new CountryState('Venezuela','Miranda'),
	    'America/Halifax' : new CountryState('Canada','Nova Scotia'),
	    'America/Santo_Domingo' : new CountryState('Dominican Republic','Distrito Nacional'),
	    'America/Asuncion' : new CountryState('Paraguay','Asuncion (city)'),
	    'America/St_Johns' : new CountryState('Canada','Newfoundland'),
	    'America/Godthab' : new CountryState('Greenland','Avannaa (Nordgronland)'),
	    'America/Argentina/Buenos_Aires' : new CountryState('Argentina','Buenos Aires'),
	    'America/Montevideo' : new CountryState('Uruguay','Montevideo'),
	    'America/Noronha' : new CountryState('Brazil','Pernambuco'),
	    'Etc/GMT+2' : new CountryState('Unknown','Unknown'),
	    'Atlantic/Azores' : new CountryState('Portugal','Acores (Azores)'),
	    'Atlantic/Cape_Verde' : new CountryState('Cape Verde','Praia'),
	    'Etc/UTC' : new CountryState('Unknown','Unknown'),
	    'Europe/London' : new CountryState('United Kingdom','City of London'),
	    'Europe/Berlin' : new CountryState('Germany','Berlin'),
	    'Africa/Lagos' : new CountryState('Nigeria','Lagos'),
	    'Africa/Windhoek' : new CountryState('Namibia','Khomas'),
	    'Asia/Beirut' : new CountryState('Lebanon','Beyrouth'),
	    'Africa/Johannesburg' : new CountryState('South Africa','Gauteng'),
	    'Europe/Moscow' : new CountryState('Russia','|Moskva (Moscow)'),
	    'Asia/Baghdad' : new CountryState('Iraq','Baghdad'),
	    'Asia/Tehran' : new CountryState('Iran  Islamic Republic of','Tehran'),
	    'Asia/Dubai' : new CountryState('United Arab Emirates','Dubayy (Dubai)'),
	    'Asia/Yerevan' : new CountryState('Armenia','Yerevan'),
	    'Asia/Kabul' : new CountryState('Afghanistan','Kabul'),
	    'Asia/Yekaterinburg' : new CountryState('Russian Federation','Sverdlovskaya (Yekaterinburg)'),
	    'Asia/Karachi' : new CountryState('Pakistan','Sindh'),
	    'Asia/Kolkata' : new CountryState('India','West Bengal'),
	    'Asia/Kathmandu' : new CountryState('Kathmandu','Bagmati'),
	    'Asia/Dhaka' : new CountryState('Bangladesh','Dhaka'),
	    'Asia/Omsk' : new CountryState('Russia Federation','Omskaya'),
	    'Asia/Rangoon' : new CountryState('Myanmar','Yangon'),
	    'Asia/Krasnoyarsk' : new CountryState('Russia Federation','Krasnoyarskiy'),
	    'Asia/Jakarta' : new CountryState('Indonesia','Jakarta Raya'),
	    'Asia/Shanghai' : new CountryState('China','Shanghai'),
	    'Asia/Irkutsk' : new CountryState('Russia Federation','Irkutskaya'),
	    'Australia/Eucla' : new CountryState('Australia','Western Australia'),
	    'Asia/Yakutsk' : new CountryState('Russia Federation','Sakha (Yakutsk)'),
	    'Asia/Tokyo' : new CountryState('Japan','Tokyo'),
	    'Australia/Darwin' : new CountryState('Australia','Northern Territory'),
	    'Australia/Adelaide' : new CountryState('Australia','South Australia'),
	    'Australia/Brisbane' : new CountryState('Australia','Queensland'),
	    'Asia/Vladivostok' : new CountryState('Russia Federation','Primorskiy (Vladivostok)'),
	    'Australia/Sydney' : new CountryState('Australia','New South Wales'),
	    'Australia/Lord_Howe' : new CountryState('Australia','New South Wales'),
	    'Asia/Kamchatka' : new CountryState('Russia Federation','Kamchatskaya (Petropavlovsk-Kamchatskiy)'),
	    'Pacific/Noumea' : new CountryState('New Caledonia','Unknown'),
	    'Pacific/Norfolk' : new CountryState('United Kingdom','Norfolk'),
	    'Pacific/Auckland' : new CountryState('New Zealand','Auckland'),
	    'Pacific/Tarawa' : new CountryState('Kiribati','Tarawa'),
	    'Pacific/Chatham' : new CountryState('New Zealand','Chatham Islands'),
	    'Pacific/Tongatapu' : new CountryState('Tonga','Tongatapu'),
	    'Pacific/Kiritimati' : new CountryState('Kiribati','Kiritimati')
	 };	
	 
function setLocalTimeZone(componentId, defaultValue){
	var theOption;
	var ddl =  document.getElementById(componentId);
	
	for(var t in timezoneCountry){
		theOption = new Option;
	    theOption.text = t;
	    theOption.value =t;
	    ddl.add( theOption,null);	
	}
	
	ddl.value =defaultValue;
	
}

function confirmCancel() {
      var isCancel = confirm("Are you sure you wish to cancel?");
      if (isCancel) return true;
     return false;
} 

function CalculateLocalTime(dateValue,timezone,localtimezone){
		var demoSessionOffset = new timezoneJS.Date(dateValue.getFullYear(),
							dateValue.getMonth(),dateValue.getDate(),
							dateValue.getHours(),dateValue.getMinutes(),dateValue.getMilliseconds(),
							timezone );
        demoSessionOffset.setTimezone(localtimezone);
		return demoSessionOffset._dateProxy;
	
}

function FormatToLongDateString3(date){
    var day =date.getDate();
    var dd = day <10?"0" + day: day;
	var time = date.toLocaleTimeString().replace(/([\d]+:[\d]{2})(:[\d]{2})(.*)/, "$1$3");
    var dth = date.getDate() >3 ? day + "th": day == 1? "1st": day == 2? "2nd": day ==3 ? "3rd": "0th";
	var ms =  date.getMinutes()<10? "0"+ date.getMinutes(): date.getMinutes();
	var hs = date.getHours() <10?"0"+date.getHours():date.getHours();
    var s = time+" " + dayOfWeek[date.getDay()] +", " +month[date.getMonth()] + " "+dth +" "+ date.getFullYear();
    return s;
}
