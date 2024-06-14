@isTest
public class EMS_LM_LoptoResource_Test {
    
     public static testMethod void testlossofpayclass() {
       
         user adminuser = TestDataFactory.createAdminUser(true);
        Resource_Role__c role;
        Resource_Role__c role1;
        Account acc;
        Contact con;
        Contact conRRR;
        EMS_LM_Leave__c annualtype;
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
            EMS_LM_Leave__c paidTimeOff = TestDataFactory.createLeaveType('Paid time off',true);


            //EMS_LM_Leave_Credit__c lcreditAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),1.6,annualtype.id, true);
        
            
            acc = TestDataFactory.createAccount(true);
            con=TestDataFactory.createResourceContact(acc.id, false);
            con.EMS_RM_Employee_Id__c = 'CP10234';
            con.Resource_Role__c = role.Id;
            con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
            con.EMS_LM_No_Of_Leaves_Credit__c = -4;
            
            
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
        Test.startTest();
        system.runAs(adminuser){
            u1 = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
            u2 = Testdatafactory.createCommunityUser2WithAccAndContact(acc.id,conRRR.Id,true);
        }
        
        System.runAs(u1) {
            List<Id> leaveReqTabIdsList = new list<Id>();
            List<EMS_LM_Leave_History__c> requests = new List<EMS_LM_Leave_History__c>();
            requests.add(TestDataFactory.createLeaveRequest(con.id, system.today(), system.today().adddays(1), annualtype.id, false, 'Pending'));
            requests.add(TestDataFactory.createLeaveRequest(con.id, system.today().adddays(6), system.today().adddays(7), annualtype.id, false, 'Approver 1 Pending'));
            requests.add(TestDataFactory.createLeaveRequest(con.id, system.today().adddays(8), system.today().adddays(9), annualtype.id, false, 'Approver 2 Pending'));
            insert requests;
          String startd = string.valueOf(system.today().adddays(13));
          String endd = string.valueOf(system.today().adddays(14));
         
             EMS_LM_LoptoResource lotresource =New EMS_LM_LoptoResource();
       		lotresource.LoptoResourcemethod(conlist);
         Test.stopTest();
    }    
}
}