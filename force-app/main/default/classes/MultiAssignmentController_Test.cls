@isTest
public class MultiAssignmentController_Test {
    
    public static testmethod void createTimesheet(){
        user loginedUser =[SELECT id from User  where IsActive = true LIMIT 1];
        Resource_Role__c role = TestDataFactory.createResourceRole(true);
         Office_Location__c officlocRec =TestDataFactory.createOfficeLocation('Hhyderabad',true);
        EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
        EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
        EMS_LM_Leave__c workfromhome = TestDataFactory.createLeaveType('Work From Home',true);
        EMS_LM_Leave__c paidTimeOff = TestDataFactory.createLeaveType('Paid time off',true);
        Account acc = TestDataFactory.createAccount(true);
        Contact con=  TestDataFactory.createResourceContact(acc.id, false);
        con.EMS_RM_Employee_Id__c = 'CP10235';
        con.EMS_RM_ApplicantStatus_Update__c ='Active';
        con.EMS_Phone_Number__c ='0123456789';
        con.EMS_EM_CAddress_Line_1__c ='Hyd';
        con.EMS_EM_CA_City__c ='Hyd';
        con.EMS_EM_CA_State__c ='AP';
        con.Timesheet_NoNeed__c =false;
        con.Resource_Role__c = role.Id;
        con.EMS_TM_User__c =loginedUser.Id;
        con.Work_Location__c =officlocRec.Id;
        INSERT con;
        System.debug('conData'+con);
        EMS_TM_Project__c projectRec = new EMS_TM_Project__c();
        projectRec.EMS_TM_StartDate__c = System.today();
        projectRec.EMS_TM_EndDate__c = System.today()+10;
        projectRec.EMS_TM_Status__c = 'ongoing';
        projectRec.Name = 'project1';
        projectRec.Project_Manager__c = con.Id;
        projectRec.Type_Of_Project__c ='Client Projects';
        INSERT projectRec;        
        System.debug('ProjectREC'+projectRec);       
        System.debug('ProjectREC'+projectRec);
        EMS_TM_Assignment__c assignmentRec = new EMS_TM_Assignment__c();
        assignmentRec.EMS_TM_EmployeeName__c = con.Id;
        assignmentRec.EMS_TM_ProjectName_Asgn__c = projectRec.Id;
        assignmentRec.EMS_TM_StartDate_Asgn__c = system.today();
        assignmentRec.EMS_TM_Billable__c = true;
        assignmentRec.EMS_TM_AssignedAs__c='Administrator';
        assignmentRec.Project_Allocation__c=1;
        INSERT assignmentRec;
        List<EMS_TM_Assignment__c> assignmentList = new List<EMS_TM_Assignment__c>();
        EMS_TM_Assignment__c assignmentRec1 = new EMS_TM_Assignment__c();
        assignmentRec1.EMS_TM_EmployeeName__c = con.Id;
        assignmentRec1.EMS_TM_ProjectName_Asgn__c = projectRec.Id;
        assignmentRec1.EMS_TM_StartDate_Asgn__c = system.today();
        assignmentRec1.EMS_TM_Billable__c = true;
        assignmentList.add(assignmentRec1);
        String str = JSON.serialize(assignmentList);
        test.startTest();
          try
      {
         MultiAssignmentController.getRelatedAssignments(projectRec.Id);
          MultiAssignmentController.deleteAssignmentHandler(assignmentRec.Id, projectRec.Id);
       MultiAssignmentController.saveAssignmentData(str, projectRec.Id);
      }catch(exception e){
          system.debug('errror======'+e.getMessage());
      }
        
        test.stopTest();
    }
    
    

}