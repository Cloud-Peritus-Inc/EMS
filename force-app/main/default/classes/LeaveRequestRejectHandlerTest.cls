@isTest
public class LeaveRequestRejectHandlerTest {
    
    static testMethod void testUpdateLeaveStatus() {
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
            
            
            acc = TestDataFactory.createAccount(true);
            con=TestDataFactory.createResourceContact(acc.id, false);
            con.EMS_RM_Employee_Id__c = 'CP10234';
            con.Resource_Role__c = role.Id;
            con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
            con.EMS_LM_No_Of_Leaves_Credit__c = 10;
            insert con;
            System.debug('con'+ con);
            conRRR=TestDataFactory.createResourceContactForRRR(acc.id, false);
            conRRR.EMS_RM_Employee_Id__c = 'CP10235';
            conRRR.Resource_Role__c = role1.Id;
            conRRR.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
            conRRR.EMS_LM_No_Of_Leaves_Credit__c = 10;
            insert conRRR;
            rrr = TestDataFactory.createRRR(con.Id, true, conRRR.Id);
            System.debug('### rrr' + rrr);
            List<Resource_Resource_Relationship__c> rrrList = [SELECT Id, Name, Resource__c, Resource_Reports_To__c,Resource_Reports_To_User__c FROM Resource_Resource_Relationship__c WHERE Resource__c =: con.Id];
			System.debug('### rrrList' + rrrList);
            for (Resource_Resource_Relationship__c rr : rrrList) {
            System.debug('#### Resource_Reports_To_User__c' + rr.Resource_Reports_To_User__c);
            }
        }
        User u1;
        User u2;
        Test.startTest();
        system.runAs(adminuser){
            u1 = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
            u2 = Testdatafactory.createCommunityUser2WithAccAndContact(acc.id,conRRR.Id,true);
            System.debug('### u2'+ u2.Id);
        }
                
        System.runAs(u2) {
            EMS_LM_Leave_History__c leaveVal1 = TestDataFactory.createLeaveRequest(con.id, system.today(), system.today().adddays(1), annualtype.id, true, 'Pending');
            System.debug('### leaveVal1 Data' + leaveVal1);
            leaveVal1 = [SELECT Id,
                         		EMS_LM_Status__c, 
                         		EMS_LM_Approved_On__c, 
                         		EMS_LM_Current_Approver__c, 
                         		Approver_1_Approved_Comments__c,
                         		EMS_LM_Approver__c,
                         		EMS_LM_Approver__r.FirstName,
                         		EMS_LM_Approver__r.LastName
                         FROM EMS_LM_Leave_History__c WHERE Id = :leaveVal1.Id];
            System.debug('#### leaveVal1 '+ leaveVal1);
            System.debug('### leaveVal1' + leaveVal1.EMS_LM_Approver__c);
            LeaveRequestRejectHandler.updateRejecteStatusAndComments(leaveVal1.Id, 'Approver 1 Rejected');           
            System.assertEquals(LeaveRequestConstant.REJECTED, leaveVal1.EMS_LM_Status__c);
            System.assertEquals(System.today(), leaveVal1.EMS_LM_Approved_On__c);
            System.assertEquals(u2.FirstName + ' ' + u2.LastName, leaveVal1.EMS_LM_Approver__r.FirstName + ' ' +leaveVal1.EMS_LM_Approver__r.LastName);
            System.assertEquals('Approver 1 Rejected', leaveVal1.Approver_1_Approved_Comments__c);
        }
        Test.stopTest();
    }
}