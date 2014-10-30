@isTest(SeeAllData=true)
private class  Hapara_Test_Update_Account {
	static testMethod void testAccountUpdate() {

		Account acc = new Account();
		acc.Name = 'Account';
		acc.Type = 'Customer';
		acc.BillingStreet = 'test street';
		acc.BillingCity = 'test city';
		acc.BillingState = 'Auckland';
		acc.BillingPostalCode = 'test zip code';
		acc.BillingCountry = 'New Zealand';
		insert acc;
		System.assertEquals( acc.BillingCountry,'New Zealand' );	
			
		
		Account acc1 = new Account();
		acc1.Name = 'Account';
		acc1.Type = 'Customer';
		acc1.ShippingStreet = 'test street';
		acc1.ShippingCity = 'test city';
		acc1.ShippingState = 'California';
		acc1.ShippingPostalCode = 'test zip code';
		acc1.ShippingCountry = 'United States'; 
		insert acc1;
		System.assertEquals( acc1.ShippingCountry,'United States' );
		
		Account acc3 = new Account();
		acc3.Name = 'Account';
		acc3.Type = 'Prospect';
		acc3.BillingStreet = 'test street';
		acc3.BillingCity = 'test city';
		acc3.BillingState = 'Western Australia';
		acc3.BillingPostalCode = 'test zip code';
		acc3.BillingCountry = 'Australia';
		insert acc3;
		//System.assertEquals( acc3.CurrencyIsoCode,'AUD' );
		
		//testing student domain corrections 
		Account acc2 = new Account();
		acc2.Name = 'Account';
		acc2.Type = 'Prospect';
		acc2.CurrencyIsoCode = 'USD';
		acc2.Website = 'http://leportstudents.com/leportschools.com	';
		insert acc2;
		acc2=[select website from Account a where a.Id = :acc2.Id];
		system.assertEquals(acc2.Website, 'leportstudents.com'); 
		
		acc2.Website = 'http://student@perthmontessori.wa.edu.au';
		update acc2;
		acc2=[select website from Account a where a.Id = :acc2.Id];
		system.assertEquals(acc2.Website, 'perthmontessori.wa.edu.au');
		
		acc2.Website = 'http://ucdsehd.net/';
		update acc2;
		acc2=[select website from Account a where a.Id = :acc2.Id];
		system.assertEquals(acc2.Website, 'ucdsehd.net');
		
		acc2.Website = 'http://www.conway.k12.wa.us';
		update acc2;
		acc2=[select website from Account a where a.Id = :acc2.Id];
		system.assertEquals(acc2.Website, 'conway.k12.wa.us');	
    }
}