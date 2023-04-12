@isTest
public class LeaveCalculateHandler_Test {
   
    
    @isTest
    public static void testLeaveCalculateHandler(){
           Resource_Role__c role = TestDataFactory.createResourceRole(true);
        EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        annualtype.EMS_LM_Leave_Type__c='Annual Leave';
        update annualtype;
        
       EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        loptype.EMS_LM_Leave_Type__c='Loss of Pay';
        update loptype;
       
       
        EMS_LM_Leave__c workfromhome = TestDataFactory.createLeaveType('Work From Home',true);
        workfromhome.EMS_LM_Leave_Type__c='Work From Home';
        update workfromhome;
       
        EMS_LM_Leave__c paternitytype = TestDataFactory.createLeaveType('Paternity Leave',true);
        paternitytype.EMS_LM_Leave_Type__c='Paternity Leave';
        update paternitytype;
        
        Account acc = TestDataFactory.createAccount(true);
        list<contact> conList=New list<contact>();
        list<EMS_LM_Leave_History__c> leaverequestList=New list<EMS_LM_Leave_History__c>();
        Contact con=  TestDataFactory.createResourceContact(acc.id, false);
        con.EMS_RM_Employee_Id__c = 'CP10234';
        con.Resource_Role__c = role.Id;
        con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
        con.EMS_LM_Maternity_Leave__c=true;
        insert con;
        conList.add(con);
        User u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
        Id userid = u.Id;
        
        
        system.runAs(u){
            EMS_LM_Leave_Credit__c lcreditAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),1.6,annualtype.id, true);
            EMS_LM_Leave_Credit__c workforHome = Testdatafactory.createLeaveCredit(con.id,system.today(),1,workfromhome.id, true);        
            EMS_LM_Leave_Credit__c paternity = Testdatafactory.createLeaveCredit(con.id,system.today(),1,paternitytype.id, true);
            
            Test.startTest();      
         
            
            //  EMS_LM_Leave_History__c request2 = TestDataFactory.createLeaveRequest(con.id, system.today().adddays(13), system.today().adddays(), annualtype.id, true ,'Approved');
            
            leaverequestList.add(TestDataFactory.createLeaveRequest(con.id, system.today(), system.today().adddays(1), annualtype.id, true ,'Pending'));
          //    leaverequestList.add(TestDataFactory.createLeaveRequest(con.id, system.today().adddays(8), system.today().adddays(9), compofftype.id, true,'Pending'));
           // leaverequestList.add(TestDataFactory.createLeaveRequest(con.id, system.today().adddays(10), system.today().adddays(12), workfromhome.id, true,'Pending'));
          //    leaverequestList.add(TestDataFactory.createLeaveRequest(con.id, system.today().adddays(13), system.today().adddays(13), paternity.id, true,'Pending'));
           // leaverequestList.add(TestDataFactory.createLeaveRequest(con.id, system.today().adddays(14), system.today().adddays(15), bretAnnual.id, true ,'Pending'));
       Test.stopTest();
        }
        
        
    }
    
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