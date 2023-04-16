@isTest
public class updateTheProbationPeriodOnResource_Test {
    
    @istest
    public static void updateTheProbationPeriodOnResourceMethod(){
        user adminuser = TestDataFactory.createAdminUser(true);
        string adminuserid=adminuser.Id;
        Resource_Role__c role;
        Account acc;
        Contact con;
        Contact conRRR;
        Resource_Resource_Relationship__c rrr;
        EMS_LM_Leave__c annualtype; 
        system.runAs(adminuser){
            role = TestDataFactory.createResourceRole('Software Engineer',false);
            role.Probation_Days__c=180;
            insert role;
            annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
            EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);           
            acc = TestDataFactory.createAccount(true);
            con=TestDataFactory.createResourceContact(acc.id, false);
            con.EMS_RM_Employee_Id__c = 'CP10234';
            con.Resource_Role__c = role.Id;
            con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
            con.EMS_LM_No_Of_Leaves_Credit__c = 10;
            con.RecordTypeId=ContactConstant.RESOURCE_RECORDTYPEID;
            con.EMS_EM_JD__c= system.today();
            insert con;
            con.EMS_EM_JD__c= system.today()-15;
            update con;
            EMS_LM_Leave_Credit__c lcreditAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),1.6,annualtype.id, true);   
            
            EMS_LM_Leave_History__c request2 = TestDataFactory.createLeaveRequest(con.id, system.today().adddays(6), system.today().adddays(7), wfhtype.id, true,'Pending');
            string getleaveId= request2.Id;

        }
    }
}