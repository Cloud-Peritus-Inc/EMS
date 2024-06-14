@isTest
public class LeaveManagementApexControllerTest {
    
    
    
    public static Contact getContact(){
        user userId =[SELECT id FROM User  WHERE IsActive = true LIMIT 1];        
        
        Resource_Role__c role = TestDataFactory.createResourceRole(false);
        role.Name ='Director';
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
        
        Contact con1=  TestDataFactory.createResourceContact(acc.id, false);
        con1.EMS_RM_Employee_Id__c = 'CP10236';
        con1.Email='praveen.pasham@cloudperitus2.com';
        con1.EMS_RM_ApplicantStatus_Update__c ='Active';
        con1.EMS_Phone_Number__c ='0123456789';
        con1.EMS_EM_CAddress_Line_1__c ='USA';
        con1.EMS_EM_CA_City__c ='USA';
        con1.EMS_EM_CA_State__c ='LA';
        con1.Work_Location__c = USA.Id;
        con1.Timesheet_NoNeed__c =false;
        con1.Resource_Role__c = role.Id;
        con1.EMS_TM_User__c =UserId.Id;
        con1.EMS_EM_JD__c = system.today();
        con1.RecordTypeId = ContactConstant.RESOURCE_RECORDTYPEID;
        INSERT con1;
        return con1;
    }
    
    @isTest
    static void testUpdateUsersAsync2(){
        LeaveManagementApexController.getLeaveRequestHr();
        LeaveManagementApexController.getLeaveRequest();
        LeaveManagementApexController.leaveBanlance();
        
     
        
    }
    
    @istest
    public static void cancelledLeaveTest(){
        Resource_Role__c role = TestDataFactory.createResourceRole(true);
        Office_Location__c officeindia=TestDataFactory.createOfficeLocation(true);
            Office_Location__c office=new Office_Location__c();
            office.Name='California - USA';
            insert office;
            EMS_LM_Leave__c annualtype= TestDataFactory.createLeaveType('Annual Leave',true);
            EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
            EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            EMS_LM_Leave__c paidTimeOff = TestDataFactory.createLeaveType('Paid time off',true);
            EMS_LM_Leave__c unpaidTimeOff = TestDataFactory.createLeaveType('UnPaid time off',true);
            EMS_LM_Leave__c floatingholiday = TestDataFactory.createLeaveType('Floating Holiday',true);
        User u=TestDataFactory.createCommunityUserWithOutAccAndContact(true);
        string userid=u.Id;
        Account acc = TestDataFactory.createAccount(true);
        Contact con;
        con=TestDataFactory.createResourceContact(acc.id, false);
            con.EMS_RM_Employee_Id__c = 'CP10234';
            con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
            con.EMS_LM_No_Of_Leaves_Credit__c = 1;
            con.Email='nagavamsikrishna88@gmail.com';
            con.EMS_EM_JD__c = system.today().adddays(-389);
            con.Work_Location__c=office.Id;
            //con.EMS_RM_ApplicantStatus_Update__c ='Notice Period';
            insert con;
        EMS_LM_Leave_Credit__c lcreditAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),50,annualtype.id, true); 
        EMS_LM_Leave_History__c request2 = TestDataFactory.createLeaveRequest(con.id, system.today().adddays(7), system.today().adddays(7), annualtype.id, true,'Pending');
        system.runAs(u){
            test.starttest();
            LeaveManagementApexController.cancleLeaveRequest(request2.Id);
            
            test.stoptest();
        }     
    }



}