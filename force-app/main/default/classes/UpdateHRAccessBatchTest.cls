@istest
public class UpdateHRAccessBatchTest {

    //Created Test User and assigned HR_Admin permission set to the user
    @TestSetup static void setupData() {
        
      User testuser = new User(
     ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
     LastName = 'Test',
     Email = 'Test000@amamama.com',
     Username = 'Test000@amamama.com' + System.currentTimeMillis(),
     CompanyName = 'TCS',
     Title = 'title',
     Alias = 'alias',
     TimeZoneSidKey = 'America/Los_Angeles',
     EmailEncodingKey = 'UTF-8',
     LanguageLocaleKey = 'en_US',
     LocaleSidKey = 'en_US'
     //UserRoleId = r.Id
);  
     insert testuser; 
        
    PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = '0PS52000000vexlGAA', AssigneeId = testuser.Id);
    
}    
    
    public static testmethod void testmethod1(){
        
        //Fetched the user record and its related permissionsetassignments
        User userlist = [select id, email,username,(select permissionsetid,PermissionSet.Name from permissionsetassignments where PermissionSet.Name = 'Hr_Admin' ) from user where LastName ='Test'  limit 1 ];
         
        test.startTest();
        UpdateHRAccessBatch batchtest = new UpdateHRAccessBatch();
        DataBase.executeBatch(batchtest);
        test.stopTest();
        
        //system.assertEquals(true, userlist.permissionsetassignments.Size() > 0);
    }
    
    
}