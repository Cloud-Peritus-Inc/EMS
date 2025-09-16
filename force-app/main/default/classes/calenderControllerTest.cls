@isTest
public class calenderControllerTest {
    public static testMethod void testBatchclass() {
        Resource_Role__c role = TestDataFactory.createResourceRole(true);
        EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
        EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
        EMS_LM_Leave__c paidTimeOff = TestDataFactory.createLeaveType('Paid time off',true);
         Account acc = TestDataFactory.createAccount(true);
		 Contact con=  TestDataFactory.createResourceContact(acc.id, false);
         con.EMS_RM_Employee_Id__c = 'CP10234';
         con.Resource_Role__c = role.Id;
         con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
         insert con; 
        //Contact con1=  TestDataFactory.createResourceContact(acc.id, true);
        User u1 = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true); 
        Contact con2=  TestDataFactory.createResourceContact(acc.id, false);
        con2.LastName='lokisai';
        con2.EMS_RM_Employee_Id__c = 'CP10236';
        con2.Resource_Role__c = role.Id;
         con2.ReportsToId=u1.contactId;
        con2.EMS_RM_ApplicantStatus_Update__c='active';
        con2.Email = 'testEmail+test1@cloudperitus1.com';
        con2.EMS_TM_User__c=u1.id;
        insert con2;
         //User u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con2.Id,true); 
        
        EMS_TM_Assignment__c assignrment=new EMS_TM_Assignment__c();
        assignrment.EMS_TM_Status_Asgn__c='Active';
        assignrment.EMS_TM_EmployeeName__c=con2.id;
        assignrment.EMS_TM_AssignedAs__c='Developer';
             assignrment.EMS_TM_StartDate_Asgn__c=system.today().adddays(16);
            assignrment.Project_Allocation__c=10;
         insert assignrment;
         EMS_LM_Leave_Credit__c lcreditAnnual = Testdatafactory.createLeaveCredit(con2.id,system.today(),1.6,annualtype.id, true);
         EMS_LM_Leave_Credit__c bretAnnual = Testdatafactory.createLeaveCredit(con2.id,system.today(),20,bretype.id, true);
         EMS_LM_Leave_Credit__c commOffAnnual = Testdatafactory.createLeaveCredit(con2.id,system.today(),1,compofftype.id, true);
       
        system.runAs(u1){
          EMS_LM_Leave_History__c request = TestDataFactory.createLeaveRequest(con2.id, system.today(), system.today().adddays(12), annualtype.id, true,null);
          //EMS_LM_Leave_History__c request2 = TestDataFactory.createLeaveRequest(con2.id, system.today().adddays(-5), system.today().adddays(17), bretype.id, true,null);
       //   EMS_LM_Leave_History__c request3 = TestDataFactory.createLeaveRequest(con.id, system.today().adddays(8), system.today().adddays(19), compofftype.id, true,null);
        /*calenderController.datawrapper datawrap=new calenderController.datawrapper();
        datawrap.id = request.Name;
        datawrap.title ='lokisai';
        datawrap.start = system.today();
        datawrap.endTime = system.today().adddays(12);
        datawrap.allDay = true; */
        
         Test.startTest();
             calenderController.getEvents();
             calenderController.getRecordInfo(request.Id);
             calenderController.convertTimeToOtherTimeZone(system.now());
         Test.stopTest();
        }
    }
    public static testMethod void convertTimeToOtherTimeZonetest(){
        DateTime testDateTime = DateTime.newInstanceGMT(2023, 8, 11, 12, 0, 0);
        calenderController.convertTimeToOtherTimeZone(testDateTime);
        DateTime resultDateTime = calenderController.convertTimeToOtherTimeZone(testDateTime);
        TimeZone userTimeZone = UserInfo.getTimeZone();
        Integer userOffset = userTimeZone.getOffset(testDateTime);
        DateTime expectedDateTime = testDateTime.addMinutes(userOffset / (1000 * 60));
        System.assertEquals(expectedDateTime, resultDateTime);
    }
}