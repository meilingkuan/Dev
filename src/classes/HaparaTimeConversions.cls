global class HaparaTimeConversions {
	
	public static DateTime convertDateTimeToGMT(string timezone, Date datevalue, string timevalue){
		Datetime result;
		string[] timearray = timevalue.split(':');
		system.debug('***convertDateTimeToGMT: ' +timezone + ' datevalue: ' + datevalue.year()+'-' + datevalue.month()+'-' +datevalue.day()
				+ ' timevalue: ' + timevalue );
		result = Datetime.newInstanceGmt( datevalue.year(), datevalue.month(),datevalue.day(),
					integer.valueOf(timearray[0]), integer.valueOf(timearray[1]), integer.valueOf(timearray[2]));
		Date[] daylightsaving =getTZSIDDSTKeys(timezone,string.valueOf(datevalue.year()));
		Integer[] timezoneOffset = getTZSidKeys(timezone);
		integer offset = -timezoneOffset[1];
		if(daylightsaving != null){
			Date startDaylight = daylightsaving[0];
			Date endDaylight = daylightsaving[1];
		//	system.debug('***convertDateTimeToGMT: startDaylight: '+ startDaylight.year()+'-' + startDaylight.month()+'-' +startDaylight.day()
	//				+ ' enddaylight: ' +endDaylight.year()+'-' + endDaylight.month()+'-' +endDaylight.day());
			if(datevalue > startDaylight && datevalue < endDaylight )
				offset = -timezoneOffset[0];
		}
		result = result.addHours(offset);
		system.debug('***convertDateTimeToGMT: converted datetime: ' + result.format() + ' offset = ' + offset);
		return result;
	}
	
	static Map<String, Integer[]> tzSIDKeys = new Map<String, Integer[]>();
	public static Integer[] getTZSidKeys(string timezone) {
		//system.debug('***getTZSidKeys: timezone: ' + timezone) ;
     	if(tzSIDKeys.size()==0){
		      tzSIDKeys.put('America/Los_Angeles', new Integer[]{-7,-8});
		      tzSIDKeys.put('America/New_York', new Integer[]{-4,-5});
		      tzSIDKeys.put('Europe/London', new Integer[]{1, 0});
		      tzSIDKeys.put('Pacific/Auckland', new Integer[]{+12, +13});
		      tzSIDKeys.put('Australia/Sydney', new Integer[]{+10, +11});
     	}
     	
      return tzSIDKeys.get(timezone);
   }
   
   static Map<String, Map<string,Date[]>> tzSIDDSTKeys = new Map<String, Map<string,Date[]>>();
   public static Date[] getTZSIDDSTKeys(string timezone, string year) {
   		//system.debug('***getTZSIDDSTKeys: timezone: ' + timezone +' year=' + year);
   		Date[] result = null;
     	if(tzSIDDSTKeys.size()==0){
		      tzSIDDSTKeys.put('America/Los_Angeles', new Map<string,Date[]>{
		      		'2014'=> new Date[]{ Date.newInstance(2014, 3, 9),Date.newInstance(2014, 11, 2)},
		      		'2015'=> new Date[]{ Date.newInstance(2015, 3, 8),Date.newInstance(2015, 11, 1)},
		      		'2016'=> new Date[]{ Date.newInstance(2016, 3, 13),Date.newInstance(2016,11, 6)},
		      		'2017'=> new Date[]{ Date.newInstance(2017, 3, 12),Date.newInstance(2017,11, 5)},
		      		'2018'=> new Date[]{ Date.newInstance(2018, 3, 11),Date.newInstance(2018,11, 4)},
		      		'2019'=> new Date[]{ Date.newInstance(2019, 3, 10),Date.newInstance(2019,11, 3)}
		      		});
		      tzSIDDSTKeys.put('America/New_York',  new Map<string,Date[]>{
		      		'2014'=> new Date[]{ Date.newInstance(2014, 3, 9),Date.newInstance(2014, 11, 2)},
		      		'2015'=> new Date[]{ Date.newInstance(2015, 3, 8),Date.newInstance(2015, 11, 1)},
		      		'2016'=> new Date[]{ Date.newInstance(2016, 3, 13),Date.newInstance(2016,11, 6)},
		      		'2017'=> new Date[]{ Date.newInstance(2017, 3, 12),Date.newInstance(2017,11, 5)},
		      		'2018'=> new Date[]{ Date.newInstance(2018, 3, 11),Date.newInstance(2018,11, 4)},
		      		'2019'=> new Date[]{ Date.newInstance(2019, 3, 10),Date.newInstance(2019,11, 3)}
		      		});
		      tzSIDDSTKeys.put('Europe/London',  new Map<string,Date[]>{
		      		'2014'=> new Date[]{ Date.newInstance(2014, 3, 30),Date.newInstance(2014, 10, 26)},
		      		'2015'=> new Date[]{ Date.newInstance(2015, 3, 29),Date.newInstance(2015, 10, 25)},
		      		'2016'=> new Date[]{ Date.newInstance(2016, 3, 27),Date.newInstance(2016,10, 30)},
		      		'2017'=> new Date[]{ Date.newInstance(2017, 3, 26),Date.newInstance(2017,10, 29)},
		      		'2018'=> new Date[]{ Date.newInstance(2018, 3, 25),Date.newInstance(2018,10, 28)},
		      		'2019'=> new Date[]{ Date.newInstance(2019, 3, 31),Date.newInstance(2019,10, 27)}
		      		});
		      tzSIDDSTKeys.put('Pacific/Auckland',new Map<string,Date[]>{
		      		'2014'=> new Date[]{ Date.newInstance(2014, 4, 5),Date.newInstance(2014, 9, 27)},
		      		'2015'=> new Date[]{ Date.newInstance(2015, 4, 6),Date.newInstance(2015, 9, 26)},
		      		'2016'=> new Date[]{ Date.newInstance(2016, 4, 7),Date.newInstance(2016, 9, 24)},
		      		'2017'=> new Date[]{ Date.newInstance(2017, 4, 8),Date.newInstance(2017, 9, 23)},
		      		'2018'=> new Date[]{ Date.newInstance(2018, 3, 31),Date.newInstance(2018, 9, 29)},
		      		'2019'=> new Date[]{ Date.newInstance(2019, 4, 6),Date.newInstance(2019, 9, 28)}
		      		});
		      tzSIDDSTKeys.put('Australia/Sydney',new Map<string,Date[]>{
		      		'2014'=> new Date[]{ Date.newInstance(2014, 4, 5),Date.newInstance(2014, 10, 4)},
		      		'2015'=> new Date[]{ Date.newInstance(2015, 4, 4),Date.newInstance(2015, 10, 3)},
		      		'2016'=> new Date[]{ Date.newInstance(2016, 4, 2),Date.newInstance(2016, 10, 1)},
		      		'2017'=> new Date[]{ Date.newInstance(2017, 4, 1),Date.newInstance(2017, 9, 30)},
		      		'2018'=> new Date[]{ Date.newInstance(2018, 3, 31),Date.newInstance(2018, 10, 6)},
		      		'2019'=> new Date[]{ Date.newInstance(2019, 4, 6),Date.newInstance(2019, 10, 5)}
		      		});
     	}
     	
     	if(tzSIDDSTKeys.containsKey(timezone)){
     		Map<string,Date[]> years = tzSIDDSTKeys.get(timezone);
     		//system.debug('***getTZSIDDSTKeys: found time zone=' + timezone);
     		if(years.containsKey(year)){
     			result = years.get(year);
     			//system.debug('***getTZSIDDSTKeys: found daylight saving year=' + year);
     		}
     	}
     	
      return result;
   }
}