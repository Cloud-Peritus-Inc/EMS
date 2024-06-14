@isTest
public class restrictOnlyOneDayOnProbationTest {
    
    @isTest
    static void restrictprobation() {
        user adminuser = TestDataFactory.createAdminUser(true);
        Resource_Role__c role;
        Resource_Role__c role1;
        Account acc;
        Contact con;
        Contact conRRR;
        EMS_LM_Leave__c annualtype;
        Resource_Resource_Relationship__c rrr;
        system.runAs(adminuser){
            
            role = TestDataFactory.createResourceRole('Software Engineer',true);
            role1 = TestDataFactory.createResourceRole('tech Engineer',true);
            annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
            EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
            EMS_LM_Leave__c paidTimeOff = TestDataFactory.createLeaveType('Paid time off',true);
            acc = TestDataFactory.createAccount(true);
            con=TestDataFactory.createResourceContact(acc.id, false);
            con.EMS_RM_Employee_Id__c = 'CP10234';
            con.Resource_Role__c = role.Id;
            con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
            con.EMS_LM_No_Of_Leaves_Credit__c = 10;
            con.Probationary_Period_End_Date__c = system.today().adddays(20);
            insert con;
            conRRR=TestDataFactory.createResourceContactForRRR(acc.id, false);
            conRRR.EMS_RM_Employee_Id__c = 'CP10235';
            conRRR.Resource_Role__c = role1.Id;
            conRRR.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
            conRRR.EMS_LM_No_Of_Leaves_Credit__c = 10;
            insert conRRR;
            rrr = TestDataFactory.createRRR(con.Id, true, conRRR.Id);
        }
        User u1;
        User u2;
        Test.startTest();
        system.runAs(adminuser){
            u1 = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
            u2 = Testdatafactory.createCommunityUser2WithAccAndContact(acc.id,conRRR.Id,true);
        }
        
        System.runAs(u1) {
            List<Id> leaveReqTabIdsList = new list<Id>();
            List<EMS_LM_Leave_History__c> requests = new List<EMS_LM_Leave_History__c>();
            EMS_LM_Leave_History__c request = TestDataFactory.createLeaveRequest(con.id, system.today(), system.today(), annualtype.id, true ,'Pending');
            request.EMS_LM_Status__c='Approver 1 Pending';
            update request;
            
            for(EMS_LM_Leave_History__c leaveIds : requests) {
                leaveReqTabIdsList.add(leaveIds.Id);
            }
        }
        Test.stopTest();
    }
}