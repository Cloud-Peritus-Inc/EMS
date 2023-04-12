global class AutocreatedRegHandler1664637383413 implements Auth.RegistrationHandler{
global boolean canCreateUser(Auth.UserData data) {
	return true;
}

global User createUser(Id portalId, Auth.UserData data){
    String userName;   
    if(data.attributeMap.containsKey('sfdc_networkid')) {
            userName = data.email;
         }
          System.debug('userName'+userName);
        List<User> userList = [Select Id,
                               			Name,
                               			Email,
                               			UserName 
                               			FROM User 
                                        WHERE ( Email =: userName)
                                        AND isActive = true
                                        AND Profile.Name ='System Administrator'];
    SYstem.Debug('userList'+userList);
	if(userList != null && userList.size() > 0) {
		 User userdata = userList.get(0);
            return userdata;
    }else{
        return null;
    }
}

global void updateUser(Id userId, Id portalId, Auth.UserData data){
	User u = new User(id=userId);
	u.email = data.email;
	u.lastName = data.lastName;
	u.firstName = data.firstName;
	update(u);
}
}