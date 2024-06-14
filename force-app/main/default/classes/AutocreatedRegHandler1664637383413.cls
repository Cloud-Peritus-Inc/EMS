global class AutocreatedRegHandler1664637383413 implements Auth.RegistrationHandler{
    global boolean canCreateUser(Auth.UserData data) {
        System.debug('Page url1------'+ApexPages.currentPage().getHeaders().get('Host'));
        
        System.debug('Page url2------'+Apexpages.currentPage().getUrl());
        return true;
    }
    
    global User createUser(Id portalId, Auth.UserData data){
        System.debug('Page url1------'+ApexPages.currentPage().getHeaders().get('Host'));
        
        System.debug('Page url2------'+Apexpages.currentPage().getUrl());
        System.debug('***ProtalID'+portalId);
        String userName;   
        if(data.attributeMap.containsKey('sfdc_networkid')) {
            userName = data.email;
        }
        List<User> userList = new List<User>();
        if(data.siteLoginUrl != null && data.siteLoginUrl.contains('Grid')){
            userList = [SELECT Id, 
                    Name, 
                    Email,
                    UserName,
                    profile.Name
                    FROM User 
                    WHERE ( Email =: userName)
                    AND isActive = true AND (profile.Name = 'Employee - HR(Community)' 
                                             OR profile.Name = 'Employee - Operations(Community)' OR profile.Name = 'Employee - Resource(Community)' )
                   ];
        }else{
            userList = [SELECT Id, 
                    Name, 
                    Email,
                    UserName,
                    profile.Name
                    FROM User 
                    WHERE ( Email =: userName)
                    AND isActive = true AND (profile.Name != 'Employee - HR(Community)' 
                                             AND profile.Name != 'Employee - Operations(Community)' AND profile.Name != 'Employee - Resource(Community)' )
                   ];
        }
        
        
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