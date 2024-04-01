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
        Contact conRRR2;
        EMS_LM_Leave__c annualtype;
        EMS_LM_Leave__c wfhtype;
        Resource_Resource_Relationship__c rrr;
        Resource_Resource_Relationship__c rrr2;
        Resource_Resource_Relationship__c rrr3;
        system.runAs(adminuser){
            
            role = TestDataFactory.createResourceRole('Software Engineer',true);
            role1 = TestDataFactory.createResourceRole('tech Engineer',true);
            role2 = TestDataFactory.createResourceRole('tech Engineer',false);
            role2.Level_of_Approval__c = 0;
            role2.Auto_Approve__c = true;
            insert role2;
            
            annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
            EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
              EMS_LM_Leave__c paidtimeof = TestDataFactory.createLeaveType('Paid time off',true);
               EMS_LM_Leave__c unpaidTimeOff = TestDataFactory.createLeaveType('UnPaid time off',true);
               EMS_LM_Leave__c floatingholiday = TestDataFactory.createLeaveType('Floating Holiday',true);
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
            con.Override_the_standard_level_of_approval__c = true;
            con.Level_of_Approval__c = 1;
            insert con;
            
            con1=TestDataFactory.createResourceContact(acc.id, false);
            con1.EMS_RM_Employee_Id__c = 'CP10238';
            con1.Resource_Role__c = role.Id;
            con1.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
            con1.EMS_LM_No_Of_Leaves_Credit__c = 10;
            con1.Email = 'testEmail44+test@cloudperitus.com';
            insert con1;
            
            conRRR2=TestDataFactory.createResourceContactForRRR(acc.id, false);
conRRR2.EMS_RM_Employee_Id__c = 'CP10239';
conRRR2.Resource_Role__c = role2.Id;
conRRR2.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
conRRR2.EMS_LM_No_Of_Leaves_Credit__c = 10;
            conRRR2.Override_the_standard_level_of_approval__c = true;
            conRRR2.Level_of_Approval__c = 2;
            conRRR2.Email = 'Test@mail.com';
insert conRRR2;
            
            rrr = TestDataFactory.createRRR(con.Id, true, conRRR.Id);
            //rrr2 = TestDataFactory.createRRR(con1.Id, true, con.Id);
            rrr3 = TestDataFactory.createRRR(conRRR2.Id, true, null);
            
            //smaske : for adding reports to Lokkup on con obj rec
            con.ReportsToId = conRRR.Id;
            con1.ReportsToId = con.Id;
            update con;
            update con1;
        }
        User u1;
        User u2;
        User u3;
        Test.startTest();
        system.runAs(adminuser){
            u1 = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
            u2 = Testdatafactory.createCommunityUser2WithAccAndContact(acc.id,conRRR.Id,true);
            u3 = Testdatafactory.createCommunityUser2WithAccAndContact(acc.id,conRRR2.Id,false);
            u3.Username = 'u3' + '' + u3.Username;
            insert u3;
            
            con.EMS_TM_User__c = u1.Id;
            conRRR.EMS_TM_User__c =  u2.Id;
            List<Contact> updateCon = new List<Contact>();
            updateCon.add(con);
             updateCon.add(conRRR);
            update updateCon;
            
        }
        
        system.runAs(u1){
            List<Id> leaveReqTabIdsList = new list<Id>();
            List<EMS_LM_Leave_History__c> requests = new List<EMS_LM_Leave_History__c>();
            requests.add(TestDataFactory.createLeaveRequest(con.Id, system.today(), system.today().adddays(1), annualtype.id, false, 'Pending'));
            requests[0].Level_of_Approval__c = 1; 
            requests[0].EMS_LM_Auto_Approve__c = false;
            
            requests.add(TestDataFactory.createLeaveRequest(con1.Id, system.today().adddays(6), system.today().adddays(7), annualtype.id, false, 'Approver 1 Pending'));
            requests[1].Level_of_Approval__c = 2; 
            requests[1].EMS_LM_Auto_Approve__c = false; 
            
            requests.add(TestDataFactory.createLeaveRequest(con.Id, system.today().adddays(8), system.today().adddays(9), wfhtype.id, false, 'Approver 1 Pending'));
            //requests.add(TestDataFactory.createLeaveRequest(con1.Id, system.today().adddays(8), system.today().adddays(9), annualtype.id, false, 'Approver 1 Pending'));
          // requests.add(TestDataFactory.createLeaveRequest(con1.Id, system.today(), system.today().adddays(1), annualtype.id, false, 'Pending'));
            insert requests;
            System.debug('### requests' + requests);
            for(EMS_LM_Leave_History__c leaveIds : requests) {
                leaveReqTabIdsList.add(leaveIds.Id);
            }
            
            populateApproverDetails.populateApporverValuesOnLR(requests);  
            System.assertEquals(1, requests[0].Level_of_Approval__c);
            System.assertEquals('Pending', requests[0].EMS_LM_Status__c);
            
        }
            
        system.runAs(u3){
            List<EMS_LM_Leave_History__c> requests2 = new List<EMS_LM_Leave_History__c>();
            
            requests2.add(TestDataFactory.createLeaveRequest(conRRR2.Id, system.today().adddays(6), system.today().adddays(7), annualtype.id, false, 'Approver 1 Pending'));
            requests2[0].Level_of_Approval__c = 2; 
            requests2[0].EMS_LM_Auto_Approve__c = false;
            
            System.debug('### requests' + requests2);
            
                        requests2.add(TestDataFactory.createLeaveRequest(conRRR2.Id, system.today().adddays(3), system.today().adddays(7), annualtype.id, false, 'Approver 1 Pending'));
            requests2[1].Level_of_Approval__c = 2; 
            requests2[1].EMS_LM_Auto_Approve__c = false;
            requests2[1].EMS_LM_Leave_Type_Name__c = 'Work From Home';
            insert requests2;
            populateApproverDetails.populateApporverValuesOnLR(requests2); 
            
            
        }
    }
}