@isTest
private class populateApproverDetailsTest {
    @isTest
    static void testPopulateApporverValuesOnLR() {
        user adminuser = TestDataFactory.createAdminUser(true);
        Resource_Role__c role;
        Resource_Role__c role1;
        Resource_Role__c role2;
        Account acc;
        Contact con;
        Contact con1;
        Contact conRRR;
        EMS_LM_Leave__c annualtype;
        EMS_LM_Leave__c wfhtype;
        Resource_Resource_Relationship__c rrr;
        system.runAs(adminuser){
            
            role = TestDataFactory.createResourceRole('Software Engineer',true);
            role1 = TestDataFactory.createResourceRole('tech Engineer',true);
            role2 = TestDataFactory.createResourceRole('tech Engineer',false);
            role2.Level_of_Approval__c = 0;
            role2.Auto_Approve__c = true;
            
            annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
            EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
            System.debug('### wfhtype' + wfhtype);
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
            insert con;
            
            con1=TestDataFactory.createResourceContact(acc.id, false);
            con1.EMS_RM_Employee_Id__c = 'CP10238';
            con1.Resource_Role__c = role2.Id;
            con1.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
            con1.EMS_LM_No_Of_Leaves_Credit__c = 10;
            con1.Email = 'testEmail44+test@cloudperitus.com';
            insert con1;
            
            rrr = TestDataFactory.createRRR(con.Id, true, conRRR.Id); 
            
        }
        User u1;
        User u2;
        Test.startTest();
        system.runAs(adminuser){
            u1 = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
            u2 = Testdatafactory.createCommunityUser2WithAccAndContact(acc.id,conRRR.Id,true);
        }
        
        system.runAs(u1){
            List<Id> leaveReqTabIdsList = new list<Id>();
            List<EMS_LM_Leave_History__c> requests = new List<EMS_LM_Leave_History__c>();
            requests.add(TestDataFactory.createLeaveRequest(con.Id, system.today(), system.today().adddays(1), annualtype.id, false, 'Pending'));
            requests.add(TestDataFactory.createLeaveRequest(con.Id, system.today().adddays(6), system.today().adddays(7), annualtype.id, false, 'Approver 1 Pending'));
            requests.add(TestDataFactory.createLeaveRequest(con.Id, system.today().adddays(8), system.today().adddays(9), wfhtype.id, false, 'Approver 2 Pending'));
            requests.add(TestDataFactory.createLeaveRequest(con.Id, system.today().adddays(8), system.today().adddays(9), wfhtype.id, false, 'Approver 1 Pending'));
            requests.add(TestDataFactory.createLeaveRequest(con1.Id, system.today().adddays(8), system.today().adddays(9), wfhtype.id, false, 'Approver 1 Pending'));
            requests.add(TestDataFactory.createLeaveRequest(con1.Id, system.today(), system.today().adddays(1), annualtype.id, false, 'Pending'));
            insert requests;
            System.debug('### requests' + requests);
            for(EMS_LM_Leave_History__c leaveIds : requests) {
                leaveReqTabIdsList.add(leaveIds.Id);
            }
            
            populateApproverDetails.populateApporverValuesOnLR(requests);       
            System.assertEquals(1, requests[0].Level_of_Approval__c);
            System.assertEquals('Pending', requests[0].EMS_LM_Status__c);
            
        }
    }
}