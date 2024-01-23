/**
* @author Shubham Maske
* @date 25/09/2023
* @description  BatchToUpdateProjectStatusTest Test class for BatchToUpdateProjectStatusTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
@isTest
public class BatchToUpdateProjectStatusTest {
    
    @isTest
    static void UpdateProjectStatusTest(){
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
        
        /*EMS_TM_Project__c projectRec = new EMS_TM_Project__c();
projectRec.EMS_TM_StartDate__c = System.today();
projectRec.EMS_TM_EndDate__c = System.today()+10;
projectRec.EMS_TM_Status__c = 'ongoing';
projectRec.Name = 'project1';
projectRec.Project_Manager__c = con1.Id;
projectRec.Offshore_Project_Manager__c = con.Id;
projectRec.Type_Of_Project__c ='Client Projects';
projectRec.Approval_Needed__c ='Yes';
INSERT projectRec;*/
        
        List<EMS_TM_Project__c> projectRecList = new List<EMS_TM_Project__c>();
        for(Integer i = 1; i <=200 ; i++){
            EMS_TM_Project__c projectRec = new EMS_TM_Project__c();
            projectRec.EMS_TM_StartDate__c = Date.today().addDays(-10);
            projectRec.EMS_TM_EndDate__c = Date.today().addDays(-1);
            projectRec.EMS_TM_Status__c = 'Ongoing';
            projectRec.Name = 'Test Project ' + i;
            projectRec.Project_Manager__c = con1.Id;
            projectRec.Offshore_Project_Manager__c = con.Id;
            projectRec.Type_Of_Project__c ='Client Projects';
            projectRec.Approval_Needed__c ='Yes';
            projectRecList.add(projectRec);
        }
        
        if(!projectRecList.isEmpty()){
            Insert(projectRecList);
        }
        
        Test.startTest();
        BatchToUpdateProjectStatus batchExecute = new BatchToUpdateProjectStatus(); 
        Database.executeBatch(batchExecute);
        Test.stopTest();        
    }
    
    public static testMethod void testscheduleclass() {
		Test.StartTest();
		BatchToUpdateProjectStatus_Sch testsche = new BatchToUpdateProjectStatus_Sch();
		String sch = '0 0 0 * * ?';
		system.schedule('Test BatchToUpdateProjectStatus Check', sch, testsche );
		Test.stopTest();
	}
}