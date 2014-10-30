global class Hapara_GoogleInternalRegHandler implements Auth.RegistrationHandler{
    global User createUser(Id portalId, Auth.UserData data){
    	system.debug('***Hapara_GoogleInternalRegHandler createUser: ' + data.email);
		string devemail = data.email +'.dev';
        User u = [SELECT Id,userName FROM user u WHERE u.Email =:data.email Or u.email=:devemail limit 1 ];
        
        return u;
    }
    
    global void updateUser(Id userId, Id portalId, Auth.UserData data){
    }
    
    static testMethod void testHapara_GoogleInternalRegHandler() {
    Hapara_GoogleInternalRegHandler handler = new Hapara_GoogleInternalRegHandler();
    Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
        'testFirst testLast', 'meiling.kuan@hapara.com', null, 'testuserlong', 'en_US', 'facebook',
        null, new Map<String, String>{'language' => 'en_US'});
    User u = handler.createUser(null, sampleData);
    System.assert( u.userName.contains('meiling.kuan@hapara.com'));
   
    
    sampleData = new Auth.UserData('testNewId', 'testNewFirst', 'testNewLast',
        'testNewFirst testNewLast', 'testnewuser@example.org', null, 'testnewuserlong', 'en_US', 'facebook',
        null, new Map<String, String>{});
    handler.updateUser(u.id, null, sampleData);
    
    User updatedUser = [SELECT userName, email, firstName, lastName, alias FROM user WHERE id=:u.id];
    System.assertEquals(u.userName, updatedUser.userName);

}
}