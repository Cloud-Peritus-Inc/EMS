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
    @isTest
    public static void assignmetUpdateTest(){
        User adminUser = [Select Id, UserRoleId,IsActive From User Where Profile.Name='System Administrator' AND IsActive = true Limit 1];
        try{
            System.runAs(adminUser){
                recordType rec =[SELECT Id, Name, IsActive FROM RecordType where name ='Client Projects'];
                Contact con = new contact();
                con.Email ='suneel@gmail.com';
                con.FirstName ='Suneel';
                con.LastName ='Kumar';
                con.EMS_Phone_Number__c ='9999999999';
                con.EMS_RM_Phone_Number__c ='9999999999';
                con.Location__c ='India';
                con.RecordTypeId = [SELECT Id FROM RecordType where name = 'Resource'].Id;
                con.EMS_EM_JD__c = system.today();
                insert con;
                EMS_TM_Project__c Emp = new EMS_TM_Project__c();
                emp.RecordTypeId = rec.Id;
                emp.Name ='qwq';
                emp.EMS_TM_Status__c = 'ongoing';
                emp.EMS_TM_StartDate__c = System.today();
                insert emp;
                EMS_TM_Assignment__C assign = new EMS_TM_Assignment__C();
                assign.EMS_TM_EmployeeName__c = con.id;
                assign.EMS_TM_StartDate_Asgn__c = System.today();
                assign.EMS_TM_ProjectName_Asgn__c = emp.id;
                insert assign;
            }
            EMS_TM_Project__c proj = [Select id,EMS_TM_Status__c,name from EMS_TM_Project__c where name ='qwq'];
            proj.EMS_TM_Status__c ='Completed';
            update proj;
        }catch (DmlException exc) {
            LogException.logHandledException(exc, 'CP_ProjectStatusUpdateTest', 'assignmetUpdateTest');
            //System.assertEquals('expected text', ex.getMessage());
        }
        
    }
}