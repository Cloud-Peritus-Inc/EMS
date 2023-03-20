@isTest
public class AssignmentTileControllerTest {
    public static testmethod void checkTheLoggedInUserAssignmentDetails(){
         Resource_Role__c role = TestDataFactory.createResourceRole(true);
         TestDataFactory.createLeaveType(true);
         EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
         Account acc = TestDataFactory.createAccount(true);
		 Contact con=  TestDataFactory.createResourceContact(acc.id, false);
         con.EMS_RM_Employee_Id__c = 'CP10234';
         con.Resource_Role__c = role.Id;
         insert con;
         User u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
         EMS_TM_Project__c projectRec = new EMS_TM_Project__c();
        projectRec.EMS_TM_StartDate__c = System.today();
        projectRec.EMS_TM_EndDate__c = System.today()+10;
        projectRec.EMS_TM_Status__c = 'ongoing';
        projectRec.Name = 'project1';
        projectRec.Project_Manager__c = con.Id;
        projectRec.Type_Of_Project__c ='Client Projects';
        INSERT projectRec;        
       
        
         Test.startTest();
          
          system.runAs(u){
             EMS_TM_Assignment__c assignmentRec = new EMS_TM_Assignment__c();
        assignmentRec.EMS_TM_EmployeeName__c = con.Id;
        assignmentRec.EMS_TM_ProjectName_Asgn__c = projectRec.Id;
        assignmentRec.EMS_TM_StartDate_Asgn__c = system.today();
        assignmentRec.EMS_TM_Billable__c = true;
        INSERT assignmentRec; 
             AssignmentTileController.getMyProjectDetails();
           }
         Test.stopTest();
    }
}