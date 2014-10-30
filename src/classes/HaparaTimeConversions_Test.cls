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
private class HaparaTimeConversions_Test {

    static testmethod void testHaparaTimeConversions(){
		DateTime ausTimezone = HaparaTimeConversions.convertDateTimeToGMT('Australia/Sydney', Date.newInstance(2014,2,19), '16:00:00');
		DateTime ausGMT = Datetime.newInstanceGmt( 2014,2,19,5,0,0);
		system.assertEquals(ausTimezone, ausGMT);
		DateTime lonTimezone = HaparaTimeConversions.convertDateTimeToGMT('Europe/London', Date.newInstance(2014,2,19), '16:00:00');
		DateTime lonGMT = Datetime.newInstanceGmt( 2014,2,19,16,0,0);
		system.assertEquals(lonTimezone, lonGMT);	
		DateTime nyTimezone = HaparaTimeConversions.convertDateTimeToGMT('America/New_York', Date.newInstance(2014,2,19), '16:00:00');
		DateTime nyGMT = Datetime.newInstanceGmt( 2014,2,19,21,0,0);
		system.assertEquals(nyTimezone, nyGMT);	
		DateTime aucTimezone = HaparaTimeConversions.convertDateTimeToGMT('Pacific/Auckland', Date.newInstance(2014,2,19), '16:00:00');
		DateTime aucGMT = Datetime.newInstanceGmt( 2014,2,19,3,0,0);
		system.assertEquals(aucTimezone, aucGMT);	
		DateTime laTimezone = HaparaTimeConversions.convertDateTimeToGMT('America/Los_Angeles', Date.newInstance(2014,2,19), '16:00:00');
		DateTime laGMT = Datetime.newInstanceGmt( 2014,2,20,0,0,0);
		system.assertEquals(laTimezone, laGMT);	
	}
}