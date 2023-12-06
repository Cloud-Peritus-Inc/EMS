@isTest
Public class EMS_LM_MyRequestTabLeaveReqTest {
    
    @isTest
    public static void testGetLMHistory() {
        user adminuser = TestDataFactory.createAdminUser(true);
        Resource_Role__c role;
        Resource_Role__c role1;
        Account acc;
        Contact con;
        Contact conRRR;
        EMS_LM_Leave__c annualtype;
        EMS_LM_Leave__c annualtype1;
        Resource_Resource_Relationship__c rrr;
        system.runAs(adminuser){
            
            role = TestDataFactory.createResourceRole('Software Engineer',true);
            role1 = TestDataFactory.createResourceRole('tech Engineer',true);
            annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            annualtype1 = TestDataFactory.createLeaveType('Paid time off',true);
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
            con.Resource_Role__c = role.Id;
            con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
            con.EMS_LM_No_Of_Leaves_Credit__c = 10;
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
            //u2 = Testdatafactory.createCommunityUser2WithAccAndContact(acc.id,conRRR.Id,true);
        }
        
        System.runAs(u1) {
            List<Id> leaveReqTabIdsList = new list<Id>();
            List<EMS_LM_Leave_History__c> requests = new List<EMS_LM_Leave_History__c>();
            requests.add(TestDataFactory.createLeaveRequest(con.id, system.today(), system.today().adddays(1), annualtype.id, false, 'Pending'));
            requests.add(TestDataFactory.createLeaveRequest(con.id, system.today().adddays(6), system.today().adddays(7), annualtype.id, false, 'Approver 1 Pending'));
            requests.add(TestDataFactory.createLeaveRequest(con.id, system.today().adddays(8), system.today().adddays(9), annualtype.id, false, 'Approver 2 Pending'));
            insert requests;
            for(EMS_LM_Leave_History__c leaveIds : requests) {
                leaveReqTabIdsList.add(leaveIds.Id);
            }
            
            List<String> statusValues = new List<String>{'Pending','Approver 1 Pending','Approver 2 Pending'};
                List<String> typeValues = new List<String>{'Annual Leave'};
                    String startDate = String.valueOf(Date.today().addDays(-7));           
            String endDate = String.valueOf(Date.today().addDays(7)); 
            List<EMS_LM_Leave_History__c> result = EMS_LM_MyRequestTabLeaveReq.getLMHistory(startDate, endDate, statusValues, typeValues);
            EMS_LM_MyRequestTabLeaveReq.getAllLeavesData(); 
            for (EMS_LM_Leave_History__c asserTest : result) {
               String status = asserTest.EMS_LM_Status__c;
               String requestStartDate = String.valueOf(asserTest.EMS_LM_Leave_Start_Date__c);
    		   String requestEndDate = String.valueOf(asserTest.EMS_LM_Leave_End_Date__c);
    	      System.assertEquals(true, (requestStartDate >= startDate && requestStartDate <= endDate));
   		 	  System.assertEquals(true, (requestEndDate >= startDate && requestEndDate <= endDate));
              System.assertEquals('Annual Leave', asserTest.EMS_LM_Leave_Type__r.Name);
              System.assertEquals(true, statusValues.contains(status));
            }
        }
        
        Test.stopTest();
    }
    
    
}