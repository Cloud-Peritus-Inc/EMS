@isTest
public class LeaveManagementApexControllerTest {
    
    static testMethod void leaveManagemet() {
        user adminuser = TestDataFactory.createAdminUser(true);
        Resource_Role__c role;
        Account acc;
        Contact con;
        Contact conRRR;
        Resource_Resource_Relationship__c rrr;
        EMS_LM_Leave__c annualtype;
        system.runAs(adminuser){
            role = TestDataFactory.createResourceRole('Software Engineer',true);
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
            insert con;
        }
        User u;
        Test.startTest();
        system.runAs(adminuser){
            u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
        }
        
        System.runAs(u) {
            Contact leaveBalance = LeaveManagementApexController.leaveBanlance();
            Contact conLeaves =[SELECT Id,
                                	  EMS_LM_No_Of_Availble_Leaves__c
                                FROM Contact WHERE Id =: u.ContactId LIMIT 1];
            System.assertEquals(10.00, conLeaves.EMS_LM_No_Of_Availble_Leaves__c);
            EMS_LM_Leave_History__c leaveVal = TestDataFactory.createLeaveRequest(con.id, system.today(), system.today().adddays(1), annualtype.id, true, 'Pending');
            LeaveManagementApexController.cancleLeaveRequest(leaveVal.Id);
            leaveVal = [SELECT EMS_LM_Status__c, EMS_LM_Approved_On__c, EMS_LM_Current_Approver__c, EMS_LM_Remarks__c FROM EMS_LM_Leave_History__c WHERE Id = :leaveVal.Id];
            System.assertEquals(LeaveRequestConstant.CANCELLED, leaveVal.EMS_LM_Status__c);
            Test.stopTest();
            LeaveManagementApexController.getLeaveRequest();
            List<EMS_LM_Leave_History__c> requests = new List<EMS_LM_Leave_History__c>();
            requests.add(TestDataFactory.createLeaveRequest(con.id, system.today(), system.today().adddays(1), annualtype.id, false, 'Pending'));
            requests.add(TestDataFactory.createLeaveRequest(con.id, system.today().adddays(6), system.today().adddays(7), annualtype.id, false, 'Approver 1 Pending'));
            requests.add(TestDataFactory.createLeaveRequest(con.id, system.today().adddays(8), system.today().adddays(9), annualtype.id, false, 'Approver 2 Pending'));
            requests.add(TestDataFactory.createLeaveRequest(con.id, system.today().adddays(8), system.today().adddays(9), annualtype.id, false, 'Approved'));
            requests.add(TestDataFactory.createLeaveRequest(con.id, system.today().adddays(8), system.today().adddays(9), annualtype.id, false, 'Cancelled'));
            insert requests;
            System.assertEquals(true, requests.size()>0);
            System.assertEquals(5, requests.size());
            LeaveManagementApexController.getLeaveRequestHr();
            System.assertEquals(5, requests.size());
        }
    }
}