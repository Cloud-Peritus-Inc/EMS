@isTest
public class EMS_LM_PendingOnMeLeaveReqTest {
    
    public static testMethod void testGetPendingLeaveHistory() {
        user adminuser = TestDataFactory.createAdminUser(true);
        Resource_Role__c role;
        Resource_Role__c role1;
        Resource_Role__c role2;
        Account acc;
        Account acc1;
        Contact con;
        Contact con1;
        Contact conRRR;
        Office_Location__c location;
        EMS_LM_Leave__c annualtype;
        Resource_Resource_Relationship__c rrr;
        system.runAs(adminuser){
            location=TestDataFactory.createOfficeLocation(true);
            
            role = TestDataFactory.createResourceRole('Software1 Engineer',true);
            role2 = TestDataFactory.createResourceRole('Associate Salesforce Developer',true);
            role1 = TestDataFactory.createResourceRole('tech Engineer',true);
            annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            EMS_LM_Leave__c loptype1 = TestDataFactory.createLeaveType('Paid time off',true);
            EMS_LM_Leave__c loptype2 = TestDataFactory.createLeaveType('UnPaid time off',true);
            EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
            EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
            
            acc = TestDataFactory.createAccount(true);
            acc1 = TestDataFactory.createAccount('accountname',true);
            con=TestDataFactory.createResourceContact(acc.id, false);
            con.EMS_RM_Employee_Id__c = 'CP10234';
            con.Resource_Role__c = role.Id;
            con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
            con.EMS_LM_No_Of_Leaves_Credit__c = 10;
            insert con;
            //con1=TestDataFactory.createResourceContact1(acc1,true);
            con1=  TestDataFactory.createResourceContact(acc.id, false);
            con1.EMS_RM_Employee_Id__c = 'CP10235';
            con1.Resource_Role__c = role2.Id;
            con1.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
            con1.EMS_RM_ApplicantStatus_Update__c = 'Active';
            con1.RecordTypeId = ContactConstant.RESOURCE_RECORDTYPEID;
            con1.EMS_EM_JD__c = system.today() - 180;
            con1.LastName='testing321';
            con1.Work_Location__c=location.Id;
            con1.Email='testEmail+test@cloudperitus.com';
            //insert con1;
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
            u2 = Testdatafactory.createCommunityUser3WithAccAndContact(acc.id,conRRR.Id,true);
        }
        system.runAs(u2){
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
            List<EMS_LM_Leave_History__c> result = EMS_LM_PendingOnMeLeaveReq.getPendingLeaveHistory(' ', startDate, endDate, statusValues, typeValues);
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