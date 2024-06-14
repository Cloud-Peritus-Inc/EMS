public class UserFieldUpdate {
    public static void updateUserCheckbox(List<User> newUsrList) {
      /*  System.debug('### newUsrList ' + newUsrList);
        Set<Id> hrAdminUserIds = new Set<Id>();
        Set<Id> UserIds = new Set<Id>();
        for (User usrId : newUsrList) {
            UserIds.add(usrId.Id);
        }
        List<PermissionSetAssignment> permissionSetAssignments = [SELECT Id, AssigneeId, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId IN :UserIds];
        for (PermissionSetAssignment psa : permissionSetAssignments) {
            if (psa.PermissionSet.Name == 'Hr_Admin') {
                hrAdminUserIds.add(psa.AssigneeId);
            }
        }
        System.debug('### hrAdminUserIds ' + hrAdminUserIds);
        List<User> users = [SELECT Id, Hr_Access__c FROM User WHERE Id IN :hrAdminUserIds];
        for (User usr : users) {
            usr.Hr_Access__c = true;
        }*/
        //update users;
    }
}