@isTest
public class EMS_LM_ContactLeaveUpdate_Test {
    
    @istest
    public static void leavecreateContent(){
        user adminuser = TestDataFactory.createAdminUser(false);
        string adminuserid=adminuser.Id;
        Resource_Role__c role;
        Account acc;
        Contact con;
        Contact conRRR;
        Resource_Resource_Relationship__c rrr;
        EMS_LM_Leave__c annualtype; 
        system.runAs(adminuser){
            role = TestDataFactory.createResourceRole('Software Engineer',true);
            annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
            EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);           
            acc = TestDataFactory.createAccount(true);
            con=TestDataFactory.createResourceContact(acc.id, false);
            con.EMS_RM_Employee_Id__c = 'CP10234';
            con.Resource_Role__c = role.Id;
            con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
            con.EMS_LM_No_Of_Leaves_Credit__c = 10;
            insert con;
            EMS_LM_Leave_Credit__c lcreditAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),1.6,annualtype.id, true);   
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Test Content';
            cv.VersionData = Blob.valueOf('Test Data');
            cv.PathOnClient = 'Test File.txt';
            insert cv;
            EMS_LM_Leave_History__c request2 = TestDataFactory.createLeaveRequest(con.id, system.today().adddays(6), system.today().adddays(7), wfhtype.id, true,'Pending');
            string getleaveId= request2.Id;
            
            String base64 = EncodingUtil.base64Encode(Blob.valueOf('Test file contents'));
            String filename = 'TestFile.txt';
            EMS_LM_ContactLeaveUpdate.uploadFile(base64,filename,getleaveId);
            
            
            EMS_LM_ContactLeaveUpdate.createContentLink(cv.Id, getleaveId);
            EMS_LM_ContactLeaveUpdate.getLeaveType(adminuserid,15);
            EMS_LM_ContactLeaveUpdate.createContentVersion(base64, filename);
        }
    }
    
    @istest
    public static void leaveCalculatemethod(){
        Resource_Role__c role = TestDataFactory.createResourceRole(true);
        EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',false);
        annualtype.EMS_LM_Leave_Type__c='Annual Leave';
        Insert annualtype;
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',false);
        loptype.EMS_LM_Leave_Type__c='Loss of Pay';
        Insert loptype;
        EMS_LM_Leave__c mattype = TestDataFactory.createLeaveType('Maternity Leave',false);
        mattype.EMS_LM_Leave_Type__c='Maternity Leave';
        Insert mattype;
        EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',false);
        compofftype.EMS_LM_Leave_Type__c='Compensatory Off';
        Insert compofftype;
        EMS_LM_Leave__c workfromhome = TestDataFactory.createLeaveType('Work From Home',false);
        workfromhome.EMS_LM_Leave_Type__c='Work From Home';
        Insert workfromhome;
        
        EMS_LM_Leave__c paternitytype = TestDataFactory.createLeaveType('Paternity Leave',false);
        paternitytype.EMS_LM_Leave_Type__c='Paternity Leave';
        Insert paternitytype;
     /*   EMS_LM_Leave__c Bereavementype = TestDataFactory.createLeaveType('Bereavement Leave',true);
        Bereavementype.EMS_LM_Leave_Type__c='Bereavement Leave';
        Insert Bereavementype;*/
        
        string annualLeave =annualtype.Name;
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
          //  EMS_LM_Leave_Credit__c bretAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),20,Bereavementype.id, true);
            EMS_LM_Leave_Credit__c mattypecredit = Testdatafactory.createLeaveCredit(con.id,system.today(),20,mattype.id, true);
            EMS_LM_Leave_Credit__c commOffAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),1,compofftype.id, true);
            EMS_LM_Leave_Credit__c workforHome = Testdatafactory.createLeaveCredit(con.id,system.today(),1,workfromhome.id, true);
            EMS_LM_Leave_Credit__c lossofpay = Testdatafactory.createLeaveCredit(con.id,system.today(),1,loptype.id, true);
            EMS_LM_Leave_Credit__c paternity = Testdatafactory.createLeaveCredit(con.id,system.today(),10,paternitytype.id, true);
            
            Test.startTest();       
            leaverequestList.add(TestDataFactory.createLeaveRequest(con.id, system.today(), system.today().adddays(1), annualtype.id, true ,'Pending'));
        //    leaverequestList.add(TestDataFactory.createLeaveRequest(con.id, system.today().adddays(8), system.today().adddays(9), compofftype.id, true,'Pending'));
            leaverequestList.add(TestDataFactory.createLeaveRequest(con.id, system.today().adddays(10), system.today().adddays(12), workfromhome.id, true,'Pending'));
            leaverequestList.add(TestDataFactory.createLeaveRequest(con.id, system.today().adddays(15), system.today().adddays(15), paternitytype.id, true,'Pending'));
            
            String Reason='Personal Reason';
            String startd = string.valueOf(system.today().adddays(13));
            String endd = string.valueOf(system.today().adddays(14));
            decimal duration =2;
            string conId =con.Id;
            //system.debug('conId'+conId);
            EMS_LM_ContactLeaveUpdate.createwfhRecord(conId,duration,startd,endd,Reason);
 
        }
    
        EMS_LM_ContactLeaveUpdate.getLeaveType(userid,5);
        EMS_LM_ContactLeaveUpdate.getLeaveBalance(userid);    
        EMS_LM_ContactLeaveUpdate.getbilling(userid);
        EMS_LM_ContactLeaveUpdate.getProfileName(userid);
        EMS_LM_ContactLeaveUpdate.getUserInfo(userid);
        
        Test.stopTest();
    }
}