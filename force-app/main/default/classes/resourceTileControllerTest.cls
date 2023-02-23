/**
* @author Subba Kalavala
* @date 2/22/2023
* @description  Test class for resourceTileController.
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
@isTest
public class resourceTileControllerTest {
    public static testmethod void checkTheLoggedInUserResourceDetails(){
         Resource_Role__c role = TestDataFactory.createResourceRole(true);
         TestDataFactory.createLeaveType(true);
         Account acc = TestDataFactory.createAccount(true);
		 Contact con=  TestDataFactory.createResourceContact(acc.id, false);
         con.EMS_RM_Employee_Id__c = 'CP10234';
         con.Resource_Role__c = role.Id;
         insert con;
         User u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,false);
         Test.startTest();
         resourceTileController.getUserInfo(u.Id);
         Test.stopTest();
    }
}