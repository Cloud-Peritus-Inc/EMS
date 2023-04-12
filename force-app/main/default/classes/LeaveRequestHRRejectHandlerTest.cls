@IsTest
public class LeaveRequestHRRejectHandlerTest {
    
    static testMethod void testUpdateLeaveStatus() {
        user adminuser = TestDataFactory.createAdminUser(true);
        Resource_Role__c role;
        Resource_Role__c role1;
        Account acc;
        Contact con;
        Contact conRRR;
        Resource_Resource_Relationship__c rrr;
        EMS_LM_Leave__c annualtype;
        system.runAs(adminuser){
            
            role = TestDataFactory.createResourceRole('Software Engineer',true);
            role1 = TestDataFactory.createResourceRole('tech Engineer',true);
            annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
            EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
            
            
            acc = TestDataFactory.createAccount(true);

            
            conRRR=TestDataFactory.createResourceContactForRRR(acc.id, false);
            conRRR.EMS_RM_Employee_Id__c = 'CP10235';
            conRRR.Resource_Role__c = role1.Id;
            conRRR.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
            conRRR.EMS_LM_No_Of_Leaves_Credit__c = 10;
            insert conRRR;
            
            con=TestDataFactory.createResourceContact(acc.id, false);
            con.EMS_RM_Employee_Id__c = 'CP10234';
            con.Resource_Role__c = role.Id;
            con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
            con.EMS_LM_No_Of_Leaves_Credit__c = 10;
            con.ReportsToId = conRRR.Id;
            insert con;
            System.debug('con'+ con);
            
            rrr = TestDataFactory.createRRR(con.Id, true, conRRR.Id);
            System.debug('### rrr' + rrr);
            List<Resource_Resource_Relationship__c> rrrList = [SELECT Id, Name, Resource__c, Resource_Reports_To__c,Resource_Reports_To_User__c FROM Resource_Resource_Relationship__c WHERE Resource__c =: con.Id];
			System.debug('### rrrList' + rrrList);
            for (Resource_Resource_Relationship__c rr : rrrList) {
            System.debug('#### Resource_Reports_To_User__c' + rr.Resource_Reports_To_User__c);
        }
        User u1;
        User u2;
        Test.startTest();
        system.runAs(adminuser){
            u1 = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
            u2 = Testdatafactory.createCommunityUser2WithAccAndContact(acc.id,conRRR.Id,true);
        }
        
        System.runAs(u1) {
            EMS_LM_Leave_History__c leaveVal1 = TestDataFactory.createLeaveRequest(con.id, system.today(), system.today().adddays(1), annualtype.id, true, 'Pending');
            LeaveRequestHRRejectHandler.updateRejectStatus(leaveVal1.Id, 'Rejected by HR');           
            leaveVal1 = [SELECT EMS_LM_Status__c, EMS_LM_Approved_On__c, EMS_LM_Current_Approver__c, EMS_LM_Remarks__c FROM EMS_LM_Leave_History__c WHERE Id = :leaveVal1.Id];
            System.debug('### leaveVal1'+ leaveVal1);
            System.assertEquals(LeaveRequestConstant.REJECTED, leaveVal1.EMS_LM_Status__c);
            System.assertEquals(System.today(), leaveVal1.EMS_LM_Approved_On__c);
            System.assertEquals(adminuser.FirstName + ' ' + adminuser.LastName, leaveVal1.EMS_LM_Current_Approver__c);
            System.assertEquals('Rejected by HR', leaveVal1.EMS_LM_Remarks__c);
        	}
        Test.stopTest();
    	}
    
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
            con.EMS_LM_No_Of_Leaves_Credit__c = 15;
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
            
            LeaveRequestHRRejectHandler.bulkLeaveReqReject(leaveApprovalIdsList, 'Bulk Rejection by HR');
            for (EMS_LM_Leave_History__c updatedLeaveRequests : [SELECT Id,
                                                                 		EMS_LM_Status__c, 
                                                                 		EMS_LM_Approved_On__c, 
                                                                 		EMS_LM_Current_Approver__c, 
                                                                 		EMS_LM_Remarks__c 
                                                                 FROM EMS_LM_Leave_History__c 
                                                                 WHERE Id IN :leaveApprovalIdsList]) {
            System.assertEquals(LeaveRequestConstant.REJECTED, updatedLeaveRequests.EMS_LM_Status__c);
            System.assertEquals(System.today(), updatedLeaveRequests.EMS_LM_Approved_On__c);
            System.assertEquals(adminuser.FirstName + ' ' + adminuser.LastName, updatedLeaveRequests.EMS_LM_Current_Approver__c);
            System.assertEquals('Bulk Rejection by HR', updatedLeaveRequests.EMS_LM_Remarks__c);
            }
        }
        Test.stopTest();
    }
}