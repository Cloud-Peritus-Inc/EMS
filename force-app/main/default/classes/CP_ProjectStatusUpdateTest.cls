/**
* @author Suneel & Rakshitha
* @date 10/01/2023
* @description  whenever project status is completed assignments status is  
*               also be closed
*
*               Test code coverage for CP_ProjectStatusUpdate class
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
@isTest
public class CP_ProjectStatusUpdateTest {
    
       @testSetup
    public static void getAdminUser(){
              user adminuser = TestDataFactory.createAdminUser(true);
             adminuser.TA_Admin__c = true;
             adminuser.Timesheet_Admin__c =true;
            // adminuser.IT_Admin_Access__c = true;
             UPDATE adminuser;
        
    }
    public static testmethod void assignmetUpdateTest(){
        User adminUser = [Select Id From User Where firstname ='Alan' AND IsActive = true Limit 1];
           
                 Resource_Role__c role = TestDataFactory.createResourceRole(false);
                 role.Name ='Sr Project Manager';
                 INSERT role;
                 EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
                EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
                EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
                EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
                EMS_LM_Leave__c workfromhome = TestDataFactory.createLeaveType('Work From Home',true);
                 Account acc = TestDataFactory.createAccount(true);
                 Contact con=  TestDataFactory.createResourceContact(acc.id, false);
                 con.EMS_RM_Employee_Id__c = 'CP10235';
                 con.Resource_Role__c = role.Id;
                 con.EMS_TM_User__c = adminUser.Id;
                 INSERT con;
                
                EMS_TM_Project__c projectRec = new EMS_TM_Project__c();
                projectRec.EMS_TM_StartDate__c = System.today();
                projectRec.EMS_TM_EndDate__c = System.today()+10;
                projectRec.EMS_TM_Status__c = 'ongoing';
                projectRec.Name = 'project1';
                projectRec.Project_Manager__c = con.Id;
                projectRec.Type_Of_Project__c ='Client Projects';
                INSERT projectRec; 
                 System.runAs(adminUser){
                EMS_TM_Assignment__c assignmentRec = new EMS_TM_Assignment__c();
                assignmentRec.EMS_TM_EmployeeName__c = con.Id;
                assignmentRec.EMS_TM_ProjectName_Asgn__c = projectRec.Id;
                assignmentRec.EMS_TM_StartDate_Asgn__c = system.today();
                assignmentRec.EMS_TM_Billable__c = true;
                INSERT assignmentRec; 
                System.debug('assignmentRec'+assignmentRec);
            }
        test.startTest();
                try{
            EMS_TM_Project__c proj = [Select id,EMS_TM_Status__c,name from EMS_TM_Project__c where name ='project1'];
            proj.EMS_TM_Status__c ='Completed';
            UPDATE proj;
        }catch (DmlException exc) {
            LogException.logHandledException(exc, 'CP_ProjectStatusUpdateTest', 'assignmetUpdateTest');
        }
        test.stoptest();
        EMS_TM_Assignment__c assignRec =[Select Id,EMS_TM_EmployeeName__c,EMS_TM_Status_Asgn__c from EMS_TM_Assignment__c LIMIT 1];
        System.assertEquals('Closed', assignRec.EMS_TM_Status_Asgn__c);
        
    }
}