@isTest
public class LeaveCalculateHandler_Test {
    
    
    @isTest
    public static void testLeaveCalculateHandler(){      
        
        user adminuser = TestDataFactory.createAdminUser(true);       
        user adminuser2 = TestDataFactory.createAdminUser(true);
        Resource_Role__c role;
        EMS_LM_Leave__c annualtype;
        EMS_LM_Leave__c loptype;
        EMS_LM_Leave__c bretype;
        EMS_LM_Leave__c compofftype;
        EMS_LM_Leave__c paternitytype;
        EMS_LM_Leave__c  Bereavementtype;
        EMS_LM_Leave__c  workfromhometype;
        EMS_LM_Leave__c  marriagetype;
        
        Account acc;Contact con;
        system.runAs(adminuser){
            role = TestDataFactory.createResourceRole(true);
            annualtype = TestDataFactory.createLeaveType('Annual Leave',false);
                    EMS_LM_Leave__c paidTimeOff = TestDataFactory.createLeaveType('Paid time off',true);
            annualtype.EMS_LM_Leave_Type__c='Annual Leave';
            insert annualtype;
            loptype = TestDataFactory.createLeaveType('Loss of Pay',false);
            loptype.EMS_LM_Leave_Type__c='Loss of Pay';
            insert loptype;
            bretype  = TestDataFactory.createLeaveType('Maternity Leave',false);
            bretype.EMS_LM_Leave_Type__c='Maternity Leave';
            insert bretype;
            compofftype = TestDataFactory.createLeaveType('Compensatory Off',false);
            compofftype.EMS_LM_Leave_Type__c='Compensatory Off';
            insert compofftype;
            paternitytype = TestDataFactory.createLeaveType('Paternity Leave',false);
            paternitytype.EMS_LM_Leave_Type__c='Paternity Leave';
            insert paternitytype;
            Bereavementtype = TestDataFactory.createLeaveType('Bereavement Leave',false);
            Bereavementtype.EMS_LM_Leave_Type__c='Bereavement Leave';
            insert Bereavementtype;
            workfromhometype = TestDataFactory.createLeaveType('Work From Home',false);
            workfromhometype.EMS_LM_Leave_Type__c='Work From Home';
            insert workfromhometype;
            marriagetype = TestDataFactory.createLeaveType('Marriage Leave',false);
            marriagetype.EMS_LM_Leave_Type__c='Marriage Leave';
            insert marriagetype;
            acc = TestDataFactory.createAccount(true);
            con=  TestDataFactory.createResourceContact(acc.id, false);
            con.EMS_RM_Employee_Id__c = 'CP10234';
            con.Resource_Role__c = role.Id;
            con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
            con.EMS_LM_Maternity_Leave__c=true;
            con.EMS_RM_ApplicantStatus_Update__c = 'Active';
            con.RecordTypeId = ContactConstant.RESOURCE_RECORDTYPEID;
            
            insert con;
        }
        
        
        
        User u;
       // system.runAs(adminuser){
            
         //   u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
            
      //  }
        system.runAs(adminuser2){
             u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
            EMS_LM_Leave_Credit__c lcreditAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),1.6,annualtype.id, true);
            EMS_LM_Leave_Credit__c bretAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),20,bretype.id, true);
            Test.startTest();
            EMS_LM_Leave_Credit__c commOffAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),1,compofftype.id, true);
            EMS_LM_Leave_Credit__c patAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),1,paternitytype.id, true); 
            EMS_LM_Leave_Credit__c berveAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),1,Bereavementtype.id, true);
            EMS_LM_Leave_Credit__c lossofpay = Testdatafactory.createLeaveCredit(con.id,system.today(),1,loptype.id, true);
            EMS_LM_Leave_Credit__c workfromhome = Testdatafactory.createLeaveCredit(con.id,system.today(),1,workfromhometype.id, true);
            EMS_LM_Leave_Credit__c marriage = Testdatafactory.createLeaveCredit(con.id,system.today(),1,marriagetype.id, true);
        }
        system.runAs(u){
            List<EMS_LM_Leave_History__c> hlist = new List<EMS_LM_Leave_History__c>();
            hlist.add(TestDataFactory.createLeaveRequest(con.id, system.today(), system.today().adddays(1), annualtype.id, false, null));
            hlist.add(TestDataFactory.createLeaveRequest(con.id, system.today().adddays(90), system.today().adddays(7), bretype.id, false, null));
            hlist.add(TestDataFactory.createLeaveRequest(con.id, system.today().adddays(8), system.today().adddays(9), compofftype.id, false, null));
            hlist.add(TestDataFactory.createLeaveRequest(con.id, system.today().adddays(7), system.today().adddays(9), paternitytype.id, false, null));
            hlist.add(TestDataFactory.createLeaveRequest(con.id, system.today().adddays(7), system.today().adddays(9), Bereavementtype.id, false, null));
            hlist.add(TestDataFactory.createLeaveRequest(con.id, system.today().adddays(7), system.today().adddays(9), loptype.id, false, null));
             hlist.add(TestDataFactory.createLeaveRequest(con.id, system.today().adddays(7), system.today().adddays(9), workfromhometype.id, false, null));
             hlist.add(TestDataFactory.createLeaveRequest(con.id, system.today().adddays(7), system.today().adddays(9), marriagetype.id, false, null));
            insert hlist;
        }
        test.stopTest();
    }    
    
    
    @isTest
    public static void testContactLeaveUpdate(){
        Resource_Role__c role = TestDataFactory.createResourceRole(true);
        EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
        EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
        EMS_LM_Leave__c workfromhome = TestDataFactory.createLeaveType('Work From Home',true);
         EMS_LM_Leave__c paidTimeOff = TestDataFactory.createLeaveType('Paid time off',true);
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