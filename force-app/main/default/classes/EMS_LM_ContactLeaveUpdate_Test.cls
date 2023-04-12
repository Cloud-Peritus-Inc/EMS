@isTest
public class EMS_LM_ContactLeaveUpdate_Test {
    
    @istest
    public static void leaveCalculatemethod(){
        Resource_Role__c role = TestDataFactory.createResourceRole(true);
        EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        annualtype.EMS_LM_Leave_Type__c='Annual Leave';
        update annualtype;
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        loptype.EMS_LM_Leave_Type__c='Loss of Pay';
        update loptype;
        EMS_LM_Leave__c mattype = TestDataFactory.createLeaveType('Maternity Leave',true);
        mattype.EMS_LM_Leave_Type__c='Maternity Leave';
        update mattype;
        EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
        compofftype.EMS_LM_Leave_Type__c='Compensatory Off';
        update compofftype;
        EMS_LM_Leave__c workfromhome = TestDataFactory.createLeaveType('Work From Home',true);
        workfromhome.EMS_LM_Leave_Type__c='Work From Home';
        update workfromhome;
        EMS_LM_Leave__c Bereavementype = TestDataFactory.createLeaveType('Bereavement Leave',true);
        Bereavementype.EMS_LM_Leave_Type__c='Bereavement Leave';
        update Bereavementype;
        
        string annualLeave =annualtype.Name;
        // system.debug('annualtype'+);
        EMS_LM_ContactLeaveUpdate.getLeaveTypeid(annualLeave);
        
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
            EMS_LM_Leave_Credit__c bretAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),20,Bereavementype.id, true);
            EMS_LM_Leave_Credit__c mattypecredit = Testdatafactory.createLeaveCredit(con.id,system.today(),20,mattype.id, true);
            EMS_LM_Leave_Credit__c commOffAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),1,compofftype.id, true);
            EMS_LM_Leave_Credit__c workforHome = Testdatafactory.createLeaveCredit(con.id,system.today(),1,workfromhome.id, true);
            EMS_LM_Leave_Credit__c lossofpay = Testdatafactory.createLeaveCredit(con.id,system.today(),1,loptype.id, true);
          //  EMS_LM_Leave_Credit__c paternity = Testdatafactory.createLeaveCredit(con.id,system.today(),1,paternitytype.id, true);
            
            Test.startTest();      
            
            
            //  EMS_LM_Leave_History__c request2 = TestDataFactory.createLeaveRequest(con.id, system.today().adddays(13), system.today().adddays(), annualtype.id, true ,'Approved');
            
            leaverequestList.add(TestDataFactory.createLeaveRequest(con.id, system.today(), system.today().adddays(1), annualtype.id, true ,'Pending'));
            leaverequestList.add(TestDataFactory.createLeaveRequest(con.id, system.today().adddays(8), system.today().adddays(9), compofftype.id, true,'Pending'));
            leaverequestList.add(TestDataFactory.createLeaveRequest(con.id, system.today().adddays(10), system.today().adddays(12), workfromhome.id, true,'Pending'));
            //leaverequestList.add(TestDataFactory.createLeaveRequest(con.id, system.today().adddays(13), system.today().adddays(13), paternity.id, true,'Pending'));
            // leaverequestList.add(TestDataFactory.createLeaveRequest(con.id, system.today().adddays(14), system.today().adddays(15), bretAnnual.id, true ,'Pending'));
            string leaveId =leaverequestList[0].Id;
        }
        
        //  String LeaveTypeName='Annual Leave';
        String Reason='Personal Reason';
        String startd = string.valueOf(system.today().adddays(13));
        String endd = string.valueOf(system.today().adddays(14));
        decimal duration =2;
        string conId =con.Id;
        //system.debug('conId'+conId);
        //  EMS_LM_ContactLeaveUpdate.createwfhRecord(conId,duration,startd,endd,Reason);
        
        
        EMS_LM_ContactLeaveUpdate.getLeaveType(userid,5);
        EMS_LM_ContactLeaveUpdate.getLeaveBalance(userid);    
        EMS_LM_ContactLeaveUpdate.getbilling(userid);
        EMS_LM_ContactLeaveUpdate.getProfileName(userid);
        EMS_LM_ContactLeaveUpdate.getUserInfo(userid);
        
        
        Test.stopTest();
    }
    
    
    
   /* @istest                                                      
    private static void createwfhRecord(){   
        Account acc = TestDataFactory.createAccount(true);
        Contact con=TestDataFactory.createResourceContact(acc.id, true);
        EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);   
        EMS_LM_Leave_History__c leaveVal = TestDataFactory.createLeaveRequest(con.id, system.today(), system.today().adddays(1),wfhtype.Id, false, 'Pending');
        Decimal duration=Decimal.valueOf(leaveVal.EMS_LM_Leave_Start_Date__c-leaveVal.EMS_LM_Leave_End_Date__c);
        EMS_LM_ContactLeaveUpdate.createwfhRecord(con.Id,duration,leaveVal.EMS_LM_Leave_Start_Date__c,leaveVal.EMS_LM_Leave_End_Date__c,'leaveVal.EMS_LM_Reason__c');
        
        //   (String cId, Decimal duration, String stDate, String edDate, String reason )  
        
    }*/
    
 /*   @istest                                                      
    private static void createContentLinkTest(){   
        Account acc = TestDataFactory.createAccount(true);
        Contact con=TestDataFactory.createResourceContact(acc.id, true);
        EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true); 
        EMS_LM_Leave_History__c request2 = TestDataFactory.createLeaveRequest(con.id, system.today().adddays(6), system.today().adddays(7), wfhtype.id, true,'Pending');
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Content';
        cv.VersionData = Blob.valueOf('Test Data');
        EMS_LM_ContactLeaveUpdate.createContentLink(cv.Id, request2.Id);
        
        
    }*/
    
    @istest     
    private static void  createContentVersionTest() {
        String base64Data = 'VGhpcyBpcyBhIHRlc3QgZGF0YQ=='; 
        String filename = 'test.txt';
        EMS_LM_ContactLeaveUpdate.createContentVersion(base64Data, filename);
    }
}