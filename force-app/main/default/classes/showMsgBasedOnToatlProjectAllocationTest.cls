/**
    * @author Shubham Maske
    * @date 26/09/2023
    * @description : TestClass for showMsgBasedOnToatlProjectAllocation
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/
@isTest
public class showMsgBasedOnToatlProjectAllocationTest {
    public static testMethod void testDataCreation(){
        
        List<EMS_TM_Assignment__c> assignmentList = commonHandlerMethod();
        List<EMS_TM_Assignment__c> assignmentListToInsert = new List<EMS_TM_Assignment__c>();
        for(EMS_TM_Assignment__c asmnt: assignmentList){
            EMS_TM_Assignment__c newAsmnt = new EMS_TM_Assignment__c();
            newAsmnt.EMS_TM_ProjectName_Asgn__c = asmnt.EMS_TM_ProjectName_Asgn__c;
            newAsmnt.EMS_TM_EmployeeName__c = asmnt.EMS_TM_EmployeeName__c;
            newAsmnt.EMS_TM_Billable__c = asmnt.EMS_TM_Billable__c;
            newAsmnt.EMS_TM_AssignedAs__c = asmnt.EMS_TM_AssignedAs__c;
            newAsmnt.EMS_TM_StartDate_Asgn__c = asmnt.EMS_TM_StartDate_Asgn__c;
            newAsmnt.EMS_TM_EndDate_Asgn__c = asmnt.EMS_TM_EndDate_Asgn__c;
            newAsmnt.Project_Allocation__c = asmnt.Project_Allocation__c;
            newAsmnt.EMS_TM_Status_Asgn__c = asmnt.EMS_TM_Status_Asgn__c;
            assignmentListToInsert.add(newAsmnt);
        }
        
        Test.startTest();
        if(!assignmentListToInsert.isEmpty()){
            INSERT assignmentListToInsert;
        }
        Test.stopTest();

    }
    
    public static List<EMS_TM_Assignment__c> commonHandlerMethod(){
        Date todayval = system.today();
        Date considerDate = todayval.toStartofWeek().addDays(-2);
        Date weekStart = considerDate.toStartofWeek().addDays(1);
        Date weekEnd = considerDate.toStartofWeek().addDays(7);
        user userId =[SELECT id FROM User  WHERE IsActive = true LIMIT 1];          
        
        Resource_Role__c role = TestDataFactory.createResourceRole(false);
        role.Name ='Project Manager';
        insert role;
        
        //Work Location
        Office_Location__c HYD = new Office_Location__c();
        HYD.Name = 'Hyderabad - India';
        HYD.Address__c = 'Jubilee Hills. Road No 36';
        HYD.Country__c = 'India';
        HYD.Timezone__c = 'Asia/Kolkata';
        INSERT HYD;
        
        Office_Location__c USA = new Office_Location__c();
        USA.Name = 'California - USA';
        USA.Country__c = 'United States of America';
        USA.Address__c = '3000 Executive Parkway Suite 215, San Ramon, CA 94583 USA';
        USA.Timezone__c = 'America/Los_Angeles';
        INSERT USA;
        
        
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
        con.Work_Location__c = HYD.Id;
        con.Timesheet_NoNeed__c =false;
        con.Resource_Role__c = role.Id;
        con.EMS_TM_User__c =userId.Id;
        INSERT con;
        
        Contact con1=  TestDataFactory.createResourceContact(acc.id, false);
        con1.EMS_RM_Employee_Id__c = 'CP10236';
        con1.Email='ramakrishna.papana@cloudperitus2.com';
        con1.EMS_RM_ApplicantStatus_Update__c ='Active';
        con1.EMS_Phone_Number__c ='0123456789';
        con1.EMS_EM_CAddress_Line_1__c ='USA';
        con1.EMS_EM_CA_City__c ='USA';
        con1.EMS_EM_CA_State__c ='LA';
        con1.Work_Location__c = USA.Id;
        con1.Timesheet_NoNeed__c =false;
        con1.Resource_Role__c = role.Id;
        con1.EMS_TM_User__c =UserId.Id;
        INSERT con1;
        
        EMS_TM_Project__c projectRec = new EMS_TM_Project__c();
        projectRec.EMS_TM_StartDate__c = System.today();
        projectRec.EMS_TM_EndDate__c = System.today()+10;
        projectRec.EMS_TM_Status__c = 'ongoing';
        projectRec.Name = 'project1';
        projectRec.Project_Manager__c = con1.Id;
        projectRec.Offshore_Project_Manager__c = con.Id;
        projectRec.Type_Of_Project__c ='Client Projects';
        projectRec.Approval_Needed__c ='Yes';
        INSERT projectRec;
        
        EMS_TM_Project__c projectRec2 = new EMS_TM_Project__c();
        projectRec2.EMS_TM_StartDate__c = System.today();
        projectRec2.EMS_TM_EndDate__c = System.today()+10;
        projectRec2.EMS_TM_Status__c = 'ongoing';
        projectRec2.Name = 'project2';
        projectRec2.Project_Manager__c = con1.Id;
        projectRec2.Offshore_Project_Manager__c = con.Id;
        projectRec2.Type_Of_Project__c ='Client Projects';
        projectRec2.Approval_Needed__c ='Yes';
        INSERT projectRec2;
               
        List<EMS_TM_Assignment__c> assignmentRecList = new List<EMS_TM_Assignment__c>();
        
        for(Integer i = 1; i<=5;i++){
            EMS_TM_Assignment__c assignmentRec = new EMS_TM_Assignment__c();
            assignmentRec.EMS_TM_EmployeeName__c = con.Id;
            assignmentRec.EMS_TM_ProjectName_Asgn__c = projectRec.Id;
            assignmentRec.EMS_TM_StartDate_Asgn__c = system.today();
            assignmentRec.EMS_TM_Billable__c = true;
            assignmentRec.EMS_TM_AssignedAs__c = 'Administrator';
            assignmentRec.Project_Allocation__c = 20;
            assignmentRecList.add(assignmentRec);
        }
        
        for(Integer i = 1; i<=5;i++){
            EMS_TM_Assignment__c assignmentRec2 = new EMS_TM_Assignment__c();
            assignmentRec2.EMS_TM_EmployeeName__c = con1.Id;
            assignmentRec2.EMS_TM_ProjectName_Asgn__c = projectRec2.Id;
            assignmentRec2.EMS_TM_StartDate_Asgn__c = system.today();
            assignmentRec2.EMS_TM_Billable__c = true;
            assignmentRec2.EMS_TM_AssignedAs__c = 'Administrator';
            assignmentRec2.Project_Allocation__c = 20;
            assignmentRecList.add(assignmentRec2);
        }
                
        INSERT assignmentRecList;
        return assignmentRecList;
        
    }
}