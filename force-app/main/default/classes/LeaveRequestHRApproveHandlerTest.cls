@IsTest
public class LeaveRequestHRApproveHandlerTest {
    
    static testMethod void testUpdateLeaveStatus() {
        user adminuser = TestDataFactory.createAdminUser(true);
        Resource_Role__c role;
        Account acc;
        Contact con;
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
            System.debug('con'+ con);
        }
        User u;
        Test.startTest();
        system.runAs(adminuser){
            u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
        }
        System.runAs(u) {
            EMS_LM_Leave_History__c leaveVal1 = TestDataFactory.createLeaveRequest(con.id, system.today(), system.today().adddays(1), annualtype.id, true, 'Pending');
            
            LeaveRequestHRApproveHandler.updateLeaveStatus(leaveVal1.Id, 'Approved by HR');           
            leaveVal1 = [SELECT EMS_LM_Status__c, EMS_LM_Approved_On__c, EMS_LM_Current_Approver__c, EMS_LM_Remarks__c FROM EMS_LM_Leave_History__c WHERE Id = :leaveVal1.Id];
            System.assertEquals(LeaveRequestConstant.APPROVED, leaveVal1.EMS_LM_Status__c);
            System.assertEquals(System.today(), leaveVal1.EMS_LM_Approved_On__c);
            System.assertEquals(adminuser.FirstName + ' ' + adminuser.LastName, leaveVal1.EMS_LM_Current_Approver__c);
            System.assertEquals('Approved by HR', leaveVal1.EMS_LM_Remarks__c);
        }
        Test.stopTest();
    }
    
    static testMethod void testBulkUpdateLeaveStatus() {
        user adminuser = TestDataFactory.createAdminUser(true);
        Resource_Role__c role;
        Account acc;
        Contact con;
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
            System.debug('con'+ con);
        }
        User u;
        Test.startTest();
        system.runAs(adminuser){
            u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
        }
        System.runAs(u) {
            List<Id> leaveApprovalIdsList = new list<Id>();
            List<EMS_LM_Leave_History__c> requests = new List<EMS_LM_Leave_History__c>();
            requests.add(TestDataFactory.createLeaveRequest(con.id, system.today(), system.today().adddays(1), annualtype.id, false, 'Pending'));
            requests.add(TestDataFactory.createLeaveRequest(con.id, system.today().adddays(6), system.today().adddays(7), annualtype.id, false, 'Approver 1 Pending'));
            requests.add(TestDataFactory.createLeaveRequest(con.id, system.today().adddays(8), system.today().adddays(9), annualtype.id, false, 'Approver 2 Pending'));
            insert requests;
            
            for(EMS_LM_Leave_History__c leaveIds : requests) {
                leaveApprovalIdsList.add(leaveIds.Id);
            }
            
            LeaveRequestHRApproveHandler.bulkLeaveReqApproval(leaveApprovalIdsList, 'Bulk Approved by HR');
            for (EMS_LM_Leave_History__c updatedLeaveRequests : [SELECT Id,
                                                                 		EMS_LM_Status__c, 
                                                                 		EMS_LM_Approved_On__c, 
                                                                 		EMS_LM_Current_Approver__c, 
                                                                 		EMS_LM_Remarks__c 
                                                                 FROM EMS_LM_Leave_History__c 
                                                                 WHERE Id IN :leaveApprovalIdsList]) {
            System.assertEquals(LeaveRequestConstant.APPROVED, updatedLeaveRequests.EMS_LM_Status__c);
            System.assertEquals(System.today(), updatedLeaveRequests.EMS_LM_Approved_On__c);
            System.assertEquals(adminuser.FirstName + ' ' + adminuser.LastName, updatedLeaveRequests.EMS_LM_Current_Approver__c);
            System.assertEquals('Bulk Approved by HR', updatedLeaveRequests.EMS_LM_Remarks__c);
            }
        }
        Test.stopTest();
    }
}