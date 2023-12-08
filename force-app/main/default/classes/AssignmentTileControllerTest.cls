@isTest
public class AssignmentTileControllerTest {
    public static testmethod void checkTheLoggedInUserAssignmentDetails(){
 
        user adminuser = TestDataFactory.createAdminUser(true);
        Resource_Role__c role;
        Account acc;
        Contact con;
        EMS_TM_Project__c projectRec;
        EMS_LM_Leave__c annualtype;
        system.runAs(adminuser){
            
            //role = TestDataFactory.createResourceRole('Software Engineer',true);
             role = TestDataFactory.createResourceRole('Project Manager',true);
            annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
            EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
              EMS_LM_Leave__c paidtimeof = TestDataFactory.createLeaveType('Paid time off',true);
        EMS_LM_Leave__c unpaidTimeOff = TestDataFactory.createLeaveType('UnPaid time off',true);
        EMS_LM_Leave__c floatingholiday = TestDataFactory.createLeaveType('Floating Holiday',true);
            
            
            acc = TestDataFactory.createAccount(true);
            con=TestDataFactory.createResourceContact(acc.id, false);
            con.EMS_RM_Employee_Id__c = 'CP10234';
            con.Resource_Role__c = role.Id;
            con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
            con.EMS_LM_No_Of_Leaves_Credit__c = 10;
            insert con;
          projectRec = new EMS_TM_Project__c();
        projectRec.EMS_TM_StartDate__c = System.today();
        projectRec.EMS_TM_EndDate__c = System.today()+10;
        projectRec.EMS_TM_Status__c = 'ongoing';
        projectRec.Name = 'project1';
        projectRec.Project_Manager__c = con.Id;
        projectRec.Type_Of_Project__c ='Client Projects';
        projectRec.Offshore_Project_Manager__c=con.Id;   
        projectRec.Offshore_Project_Manager__c=con.Id;   
        INSERT projectRec;        

            System.debug('con'+ con);
        }
        User u;
        Test.startTest();
        system.runAs(adminuser){
            u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
    //    }
          
         // system.runAs(u){
             EMS_TM_Assignment__c assignmentRec = new EMS_TM_Assignment__c();
        assignmentRec.EMS_TM_EmployeeName__c = con.Id;
        assignmentRec.EMS_TM_ProjectName_Asgn__c = projectRec.Id;
        assignmentRec.EMS_TM_StartDate_Asgn__c = system.today();
        assignmentRec.EMS_TM_Billable__c = true;
        assignmentRec.Project_Allocation__c=2;
        assignmentRec.EMS_TM_AssignedAs__c='Administrator';
        INSERT assignmentRec; 
             AssignmentTileController.getMyProjectDetails();
          // }
         Test.stopTest();
    }
    }
        
}