@istest
public class Test_EMS_TM_ProjectHandler {
    @istest
    public static void assignmetUpdateTest(){
     User adminUser = [Select Id, UserRoleId,IsActive From User Where Profile.Name='System Administrator' AND IsActive = true Limit 1];
       EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
        EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
        EMS_LM_Leave__c workfromhome = TestDataFactory.createLeaveType('Work From Home',true);
        System.runAs(adminUser){
          //  recordType rec =[SELECT Id, Name, IsActive FROM RecordType where name ='Client Projects'];
             Contact con = new contact();
        con.Email ='ramakrishna@gmail.com';
     //   con.AccountId = account.id;
        con.FirstName ='rama111';
        con.LastName ='krishna11';
        con.EMS_Phone_Number__c ='9652107520';
        con.EMS_RM_Phone_Number__c ='96529010750';
        con.Location__c ='India';
        con.RecordTypeId = [SELECT Id FROM RecordType where name = 'Resource'].Id;
        con.EMS_EM_JD__c = system.today();
        insert con;
            EMS_TM_Project__c Emp = new EMS_TM_Project__c();
           // Emp.EMS_TM_Project_Type__c = rec.id;
            emp.Type_Of_Project__c ='Client Projects';
            emp.Name ='qwq';
            emp.EMS_TM_Status__c = 'ongoing';
            emp.EMS_TM_StartDate__c = System.today().adddays(1);
            emp.EMS_TM_EndDate__c=System.today().adddays(365);
            emp.Project_Manager__c=con.Id;
            insert emp;
            EMS_TM_Assignment__C assign = new EMS_TM_Assignment__C();
            assign.EMS_TM_EmployeeName__c = con.id;
            assign.EMS_TM_StartDate_Asgn__c = System.today().adddays(10);
            assign.EMS_TM_ProjectName_Asgn__c = emp.id;
            assign.Project_Allocation__c=1;
            assign.EMS_TM_AssignedAs__c='Administrator';
            insert assign;
             
        }
         
        EMS_TM_Project__c proj = [Select id,EMS_TM_Status__c,name from EMS_TM_Project__c where name ='qwq'];
        proj.EMS_TM_Status__c ='Completed';
        
        update proj;
        
    }

}