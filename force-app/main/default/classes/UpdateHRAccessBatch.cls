global class UpdateHRAccessBatch implements Database.Batchable<sObject> {
   global final String HR_ADMIN = 'Hr_Admin';
  global Database.QueryLocator start(Database.BatchableContext BC) {
      return Database.getQueryLocator([select id, email, username,(select permissionsetid,PermissionSet.Name from permissionsetassignments where PermissionSet.Name = 'Hr_Admin' ) from user  ]);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<User> users = (List<User>) scope;
        list<User> userList=New list<User>();
        for (User usr : users) {
            if(usr.permissionsetassignments.Size() > 0){
               usr.Hr_Access__c = true;
               userList.add(usr);   
            }
        }
        update userList;
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}