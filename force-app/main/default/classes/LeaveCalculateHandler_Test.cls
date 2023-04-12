@isTest
public class LeaveCalculateHandler_Test {
   
    
  /*  @isTest
  //  public static void testLeaveCalculateHandler(){
        user adminuser = TestDataFactory.createAdminUser(true);
        Resource_Role__c role;
        Resource_Role__c role1;
        Account acc;
        Contact con;
        Contact conRRR;
        EMS_LM_Leave__c annualtype;
        //  EMS_LM_Leave__c loptype;
        // EMS_LM_Leave__c compofftype;
        // EMS_LM_Leave__c wfhtype;
        Resource_Resource_Relationship__c rrr;
        list<contact> conlist = new list<contact>();
        system.runAs(adminuser){
            
            role = TestDataFactory.createResourceRole('Software Engineer',true);
            role1 = TestDataFactory.createResourceRole('tech Engineer',true);
            annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
            EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
            
            //EMS_LM_Leave_Credit__c lcreditAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),1.6,annualtype.id, true);
            
            
            acc = TestDataFactory.createAccount(true);
            con=TestDataFactory.createResourceContact(acc.id, false);
            con.EMS_RM_Employee_Id__c = 'CP10234';
            con.Resource_Role__c = role.Id;
            con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;           
            
            
            conlist.add(con);
            insert conlist;
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
        
        system.runAs(adminuser){
            Test.startTest();
            // u1 = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
            //   u2 = Testdatafactory.createCommunityUser2WithAccAndContact(acc.id,conRRR.Id,true);
            EMS_LM_Leave_History__c request = TestDataFactory.createLeaveRequest(con.id, system.today(), system.today().adddays(1), annualtype.id, true ,'Pending');
            request.EMS_LM_Status__c='Approved';
            request.EMS_LM_Leave_Duration__c=2;
            update request;
            
            EMS_LM_Leave_History__c request2 = TestDataFactory.createLeaveRequest(con.id, system.today().adddays(10), system.today().adddays(11), annualtype.id, true ,'Auto Approved');
            
            EMS_LM_Leave_History__c request3 = TestDataFactory.createLeaveRequest(con.id, system.today().adddays(8), system.today().adddays(9), annualtype.id, true,'Approver 1 Pending');
            request3.EMS_LM_Status__c='Approver 2 Pending';
            update request3;
            //  request.EMS_LM_Status__c='Approved';
//update request;
            Test.stopTest();
        }
        
    }*/
    
    @isTest
    public static void testContactLeaveUpdate(){
        Resource_Role__c role = TestDataFactory.createResourceRole(true);
        EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
        EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
        EMS_LM_Leave__c workfromhome = TestDataFactory.createLeaveType('Work From Home',true);
        
        Account acc = TestDataFactory.createAccount(true);
        list<contact> conList=New list<contact>();
        list<EMS_LM_Leave_History__c> leaverequestList=New list<EMS_LM_Leave_History__c>();
        Contact con=  TestDataFactory.createResourceContact(acc.id, false);
        con.EMS_RM_Employee_Id__c = 'CP10234';
        con.Resource_Role__c = role.Id;
        con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
        insert con;
        conList.add(con);
        User u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
        Id userid = u.Id;
        system.runAs(u){
            EMS_LM_Leave_Credit__c lcreditAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),1.6,annualtype.id, true);
            EMS_LM_Leave_Credit__c bretAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),20,bretype.id, true);
            EMS_LM_Leave_Credit__c commOffAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),1,compofftype.id, true);
            EMS_LM_Leave_Credit__c workforHome = Testdatafactory.createLeaveCredit(con.id,system.today(),1,workfromhome.id, true);
            
            Test.startTest();
            list<EMS_LM_Leave_History__c> requestlist =New list<EMS_LM_Leave_History__c>();
            EMS_LM_Leave_History__c request = TestDataFactory.createLeaveRequest(con.id, system.today(), system.today().adddays(1), annualtype.id, true ,'Pending');
            requestlist.add(request);
            
            EMS_LM_Leave_History__c request3 = TestDataFactory.createLeaveRequest(con.id, system.today().adddays(8), system.today().adddays(9), compofftype.id, true,'Pending');
            requestlist.add(request3);
            
            string leaveId =request.Id;
            String startd = string.valueOf(system.today().adddays(13));
            String endd = string.valueOf(system.today().adddays(14));
            EMS_LM_Leave_Duration_Handler.getLeaveDuration(startd, endd, 'India', true,'Annual Leave');
            EMS_LM_Leave_Duration_Handler.getwfhDuration(startd, endd, 'India');
            EMS_LM_Leave_Duration_Handler.getwfhWFHweekends(startd, endd);
            
            EMS_LM_EditLeaveRequest.getLeaveRequestMethod(leaveId);
            EMS_LM_EditLeaveRequest.updateleaveRequest(request,leaveId);
            System.assertEquals(true, requestlist.size()>0);
            System.assertEquals(2, requestlist.size());
            test.stopTest();
        }
    }
    
    
}