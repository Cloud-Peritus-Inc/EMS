@IsTest
public class LeaveRequestHRRejectHandlerTest {
    
    @testSetup static void setup()  {
        user adminuser = TestDataFactory.createAdminUser(true);
        Resource_Role__c techLead;
        Resource_Role__c role1;
        Account acc;
        Contact con;
        Contact conRRR;
        Contact leadcontact;
        EMS_LM_Leave__c annualtype;
        Resource_Resource_Relationship__c rrr;
        system.runAs(adminuser){
            
            techLead = TestDataFactory.createResourceRole('Software Engineer',true);
            role1 = TestDataFactory.createResourceRole('tech Engineer',true);
            annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
            EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
              EMS_LM_Leave__c paidtimeof = TestDataFactory.createLeaveType('Paid time off',true);
               EMS_LM_Leave__c unpaidTimeOff = TestDataFactory.createLeaveType('UnPaid time off',true);
               EMS_LM_Leave__c floatingholiday = TestDataFactory.createLeaveType('Floating Holiday',true);
            
            acc = TestDataFactory.createAccount(true);
            
            con=TestDataFactory.createResourceContact(acc.id, false);
            con.EMS_RM_Employee_Id__c = 'CP10234';
            con.Resource_Role__c = techLead.id;
            con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
            con.EMS_LM_No_Of_Leaves_Credit__c = 15;
            con.Override_the_standard_level_of_approval__c = false;
            con.Level_of_Approval__c = 2;
            insert con;
            conRRR=TestDataFactory.createResourceContactForRRR(acc.id, false);
            conRRR.EMS_RM_Employee_Id__c = 'CP10235';
            conRRR.Resource_Role__c = role1.Id;
            conRRR.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
            conRRR.EMS_LM_No_Of_Leaves_Credit__c = 10;
            insert conRRR;
            rrr = TestDataFactory.createRRR(con.Id, true, conRRR.Id);
        }
        User contactuser;
        User leaduser;
        User empUser;
        system.runAs(adminuser){
            contactuser = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true); //tech
            leaduser = Testdatafactory.createCommunityUser2WithAccAndContact(acc.id,conRRR.Id,false); //pm
            leaduser.Hr_Access__c = true;
            insert leaduser;
        }
    } 
    
    static testMethod void testUpdateLeaveStatus() {
        EMS_LM_Leave_History__c leaveVal1;
        User resourceUser = [SELECT Id,ContactId FROM User WHERE Email = 'testemail@testclass.com.they'];
        User LeadUser = [SELECT Id,ContactId,FirstName,LastName FROM User WHERE Email = 'testemail4@testclass.com.they'];
        EMS_LM_Leave_History__c leaveReq = new EMS_LM_Leave_History__c(); 
        leaveReq.EMS_LM_Contact__c = resourceUser.ContactId;
        leaveReq.EMS_LM_Day__c = 'Full Day';
        leaveReq.EMS_LM_Leave_Start_Date__c = system.today();
        leaveReq.EMS_LM_Leave_End_Date__c = system.today().adddays(1);
        leaveReq.EMS_LM_Leave_Type__c = [SELECT Id FROM EMS_LM_Leave__c WHERE Name = 'Annual Leave'].Id;
        leaveReq.EMS_LM_Leave_Duration__c = 1;
        leaveReq.EMS_LM_Reason__c = 'Test Reason';
        leaveReq.EMS_LM_Status__c =  'Pending';
    	leaveReq.EMS_LM_Leave_Type_Name__c = 'Annual Leave';
		
		  Test.startTest();        
        System.runAs(LeadUser) {
            insert leaveReq;
            //EMS_LM_Leave_History__c leaveVal1 = TestDataFactory.createLeaveRequest(con.id, system.today(), system.today().adddays(1), annualtype.id, true, 'Pending');
            LeaveRequestHRRejectHandler.updateRejectStatus(leaveReq.Id, 'Rejected by HR');           
            leaveVal1 = [SELECT EMS_LM_Status__c, EMS_LM_Approved_On__c, EMS_LM_Current_Approver__c, EMS_LM_Remarks__c FROM EMS_LM_Leave_History__c WHERE Id = :leaveReq.Id];
            System.debug('### leaveVal1'+ leaveVal1);
            System.assertEquals(LeaveRequestConstant.REJECTED, leaveVal1.EMS_LM_Status__c);
            System.assertEquals(System.today(), leaveVal1.EMS_LM_Approved_On__c);
            System.assertEquals(LeadUser.FirstName + ' ' + LeadUser.LastName, leaveVal1.EMS_LM_Current_Approver__c);
            System.assertEquals('Rejected by HR', leaveVal1.EMS_LM_Remarks__c);
        	}
        Test.stopTest();
    	}
    
	
    static testMethod void testBulkUpdateLeaveStatus() {
       List<EMS_LM_Leave_History__c> requests = new List<EMS_LM_Leave_History__c>();
       List<EMS_LM_Leave_History__c> leaveVal1;
        User resourceUser = [SELECT Id,ContactId FROM User WHERE Email = 'testemail@testclass.com.they'];
        User LeadUser = [SELECT Id,ContactId,FirstName,LastName FROM User WHERE Email = 'testemail4@testclass.com.they'];
        for(Integer i=0; i<3; i++){
            EMS_LM_Leave_History__c leaveReq = new EMS_LM_Leave_History__c(); 
            leaveReq.EMS_LM_Contact__c = resourceUser.ContactId;
            leaveReq.EMS_LM_Day__c = 'Full Day';
            leaveReq.EMS_LM_Leave_Start_Date__c = system.today().adddays(i);
            leaveReq.EMS_LM_Leave_End_Date__c = system.today().adddays(i+1);
            leaveReq.EMS_LM_Leave_Type__c = [SELECT Id FROM EMS_LM_Leave__c WHERE Name = 'Annual Leave'].Id;
            leaveReq.EMS_LM_Leave_Duration__c = 1;
            leaveReq.EMS_LM_Reason__c = 'Test Reason';
            leaveReq.EMS_LM_Status__c =  'Pending';
            leaveReq.EMS_LM_Leave_Type_Name__c = 'Annual Leave';
            requests.add(leaveReq);
        }
        Test.startTest();
        System.runAs(LeadUser) {
            insert requests;
            List<Id> leaveReqRejectIdsList = new list<Id>();
            for(EMS_LM_Leave_History__c leaveIds : requests) {
                leaveReqRejectIdsList.add(leaveIds.Id);
            }
            
            LeaveRequestHRRejectHandler.bulkLeaveReqReject(leaveReqRejectIdsList, 'Bulk Rejection by HR');
            for (EMS_LM_Leave_History__c updatedLeaveRequests : [SELECT Id,
                                                                 		EMS_LM_Status__c, 
                                                                 		EMS_LM_Approved_On__c, 
                                                                 		EMS_LM_Current_Approver__c, 
                                                                 		EMS_LM_Remarks__c 
                                                                 FROM EMS_LM_Leave_History__c 
                                                                 WHERE Id IN :leaveReqRejectIdsList]) {
            System.assertEquals(LeaveRequestConstant.REJECTED, updatedLeaveRequests.EMS_LM_Status__c);
            System.assertEquals(System.today(), updatedLeaveRequests.EMS_LM_Approved_On__c);
            System.assertEquals(LeadUser.FirstName + ' ' + LeadUser.LastName, updatedLeaveRequests.EMS_LM_Current_Approver__c);
            System.assertEquals('Bulk Rejection by HR', updatedLeaveRequests.EMS_LM_Remarks__c);
            }
        }
        Test.stopTest();
    }
}