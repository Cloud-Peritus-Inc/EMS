@isTest
public class newServiceRequestControllerTest {
    
    public testmethod static void  caseCreationTest(){
         newServiceRequestController.daysBetweenExcludingWeekends(system.now(),system.now().adddays(4));
         user adminuser = TestDataFactory.createAdminUser(true);
         Resource_Role__c role = TestDataFactory.createResourceRole(true);
         TestDataFactory.createLeaveType(true);
         Account acc = TestDataFactory.createAccount(true);
		 Contact con=  TestDataFactory.createResourceContact(acc.id, false);
         con.EMS_RM_Employee_Id__c = 'CP10234';
         con.Resource_Role__c = role.Id;
         insert con;
        User u;
        system.runAs(adminuser){
         u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
        }
        system.runAs(u){
        Case cval = TestDataFactory.createCaseWithAccAndContact(acc.Id, con.Id, 'Problem', 'Problem', 'Test Subject', 'Test descrioyon sjd ', true);
         Case cval2 = TestDataFactory.createCaseWithAccAndContact(acc.Id, con.Id, 'Change Of Details', 'Bank Details', 'Test Subjectrr', 'Test descrioyon eresjd ', true);
          Case cval3 = TestDataFactory.createCaseWithAccAndContact(acc.Id, con.Id, 'Apply Resignation', 'Offboarding', 'Test Subjecterere', 'Test descrioyon eresjd ', true);
         Test.startTest();
          newServiceRequestController.getTheCurrentAccAndContactId();
          newServiceRequestController.getTheCurrentData();  
          newServiceRequestController.getTheCaseDetails(cval.Id);
          newServiceRequestController.processTheCaseUpdate(cval3.id,'teasting',true);
          newServiceRequestController.processTheCaseTransfer(cval2.id,con.id);
          newServiceRequestController.getTheCaseViewDetails(cval.Id);
          newServiceRequestController.getTheCaseViewDetails(cval2.Id);
            newServiceRequestController.getTheCaseViewDetails(cval3.Id);
         Test.stopTest();
        } 
    }

}