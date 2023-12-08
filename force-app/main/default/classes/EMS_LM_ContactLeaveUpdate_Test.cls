@isTest
public class EMS_LM_ContactLeaveUpdate_Test {
    
    @istest
    public static void leavecreateContent(){
        //user contactuser=TestDataFactory.createCommunityUserWithOutAccAndContact(true);
                user adminuser = TestDataFactory.createAdminUser(true);
        string adminuserid=adminuser.Id;
          Resource_Role__c role;
       //role = TestDataFactory.createResourceRole('Software Engineer',true);      
        Account acc;
        Contact con;
        Contact conRRR;
        Resource_Resource_Relationship__c rrr;
        EMS_LM_Leave__c annualtype; 
        
        system.runAs(adminuser){
            Test.starttest();
                // role = TestDataFactory.createResourceRole('Software Engineer',true);
           Office_Location__c officlocRec =TestDataFactory.createOfficeLocation('Hyderabad - India',true);
           Office_Location__c officlocRec2 =TestDataFactory.createOfficeLocation('California - USA',true);
            
            
            annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
            EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
           
            EMS_LM_Leave__c paidTimeOff = TestDataFactory.createLeaveType('Paid time off',true);
            EMS_LM_Leave__c paidtimeof = TestDataFactory.createLeaveType('Paid time off',true);
               EMS_LM_Leave__c unpaidTimeOff = TestDataFactory.createLeaveType('UnPaid time off',true);
               EMS_LM_Leave__c floatingholiday = TestDataFactory.createLeaveType('Floating Holiday',true);
            acc = TestDataFactory.createAccount(true);
  
           con=TestDataFactory.createResourceContact(acc.id, false);
            con.EMS_RM_Employee_Id__c = 'CP10234';
          //  con.Resource_Role__c = role.Id;
            con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
            con.EMS_LM_No_Of_Leaves_Credit__c = 10;
            con.Email='nagavamsikrishna88@gmail.com';
            con.EMS_EM_JD__c = system.today().adddays(-389);
            con.Work_Location__c=officlocRec.Id;
            insert con;
            EMS_LM_Leave_Credit__c lcreditAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),50,annualtype.id, true);   
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Test Content';
            cv.VersionData = Blob.valueOf('Test Data');
            cv.PathOnClient = 'Test File.txt';
            insert cv;
             EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',false); 
            wfhtype.EMS_LM_Leave_Type__c='Work From Home';
            wfhtype.Name='Work From Home';
            insert wfhtype;
            EMS_LM_Leave_History__c request2 = TestDataFactory.createLeaveRequest(con.id, system.today().adddays(6), system.today().adddays(6), annualtype.id, true,'Cancelled');
            //EMS_LM_Leave_History__c request3 = TestDataFactory.createLeaveRequest(con.id, system.today().adddays(10), system.today().adddays(10), wfhtype.id, true,'Pending');
            string getleaveId= request2.Id;
              String Reason='Personal Reason';
          //  String startd = string.valueOf(system.today().adddays(13));
          //  String endd = string.valueOf(system.today().adddays(14));
            string startd = '2023-12-27';
            string endd='2023-12-28';
            decimal duration =2.0;
            string conId =String.valueOf(con.Id);
            String base64 = EncodingUtil.base64Encode(Blob.valueOf('Test file contents'));
            String filename = 'TestFile.txt';
            EMS_LM_ContactLeaveUpdate.uploadFile(base64,filename,getleaveId);
            
            
            EMS_LM_ContactLeaveUpdate.createContentLink(cv.Id, getleaveId);
            EMS_LM_ContactLeaveUpdate.getLeaveType(adminuserid,15);
            EMS_LM_ContactLeaveUpdate.createContentVersion(base64, filename);
            EMS_LM_ContactLeaveUpdate.getbilling(adminuserid);
            EMS_LM_ContactLeaveUpdate.getProfileName(adminuserid);
            EMS_LM_ContactLeaveUpdate.getExperienceOfUser(adminuserid);
            EMS_LM_ContactLeaveUpdate.getUserInfo(adminuserid);
            EMS_LM_ContactLeaveUpdate.getLeaveBalance(adminuserid); 
             EMS_LM_ContactLeaveUpdate.createwfhRecord(conId,duration,startd,endd,Reason);

            try{
                            EMS_LM_ContactLeaveUpdate.getLeaveTypeid('Annual Leave');
                            


            }catch(exception e){
                system.debug('');
            }


            test.stoptest();
        }
        
        
        
    }
    @istest
    public static void leaveCalculatemethod(){
        Resource_Role__c role = TestDataFactory.createResourceRole(true);
        Office_Location__c officeindia=TestDataFactory.createOfficeLocation(true);
            Office_Location__c office=new Office_Location__c();
            office.Name='California - USA';
            insert office;
            EMS_LM_Leave__c annualtype= TestDataFactory.createLeaveType('Annual Leave',true);
            EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
            EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            EMS_LM_Leave__c paidTimeOff = TestDataFactory.createLeaveType('Paid time off',true);
            EMS_LM_Leave__c unpaidTimeOff = TestDataFactory.createLeaveType('UnPaid time off',true);
            EMS_LM_Leave__c floatingholiday = TestDataFactory.createLeaveType('Floating Holiday',true);
        Office_Location__c officlocRec =TestDataFactory.createOfficeLocation('Hyderabad - India',true);
        Office_Location__c officlocRec2 =TestDataFactory.createOfficeLocation('California - USA',true);
        User u=TestDataFactory.createCommunityUserWithOutAccAndContact(true);
        string userid=u.Id;
               Resource_Role__c role1 = TestDataFactory.createResourceRole('tech Engineer',true);
        Account acc = TestDataFactory.createAccount(true);
        Contact con;
        con=TestDataFactory.createResourceContact(acc.id, false);
            con.EMS_RM_Employee_Id__c = 'CP10234';
            con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
            con.EMS_LM_No_Of_Leaves_Credit__c = 1;
            con.Email='nagavamsikrishna88@gmail.com';
            con.EMS_EM_JD__c = system.today().adddays(-389);
            con.Work_Location__c=office.Id;
            //con.EMS_RM_ApplicantStatus_Update__c ='Notice Period';
            insert con;
         contact conRRR=TestDataFactory.createResourceContactForRRR(acc.id, false);
            conRRR.EMS_RM_Employee_Id__c = 'CP10235';
            conRRR.Resource_Role__c = role1.Id;
            conRRR.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
            conRRR.EMS_LM_No_Of_Leaves_Credit__c = 10;
            insert conRRR;
                   Resource_Resource_Relationship__c rrr = TestDataFactory.createRRR(con.Id, true, conRRR.Id);

        EMS_LM_Leave_Credit__c lcreditAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),50,annualtype.id, true); 
        EMS_LM_Leave_History__c request2 = TestDataFactory.createLeaveRequest(con.id, system.today().adddays(7), system.today().adddays(7), annualtype.id, true,'Pending');
        system.runAs(u){
            test.starttest();
            EMS_LM_ContactLeaveUpdate.getLeaveType(userid,5);
            
            test.stoptest();
        }     
    }
    /*@istest
    public static void leaveCalculatemethod(){
        Id p = [select id from profile where name='Employee - HR(Community)'].id;
        Resource_Role__c role = TestDataFactory.createResourceRole(true);
        Resource_Role__c Hrrole = TestDataFactory.createResourceRole('HR Manager',true);
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
       EMS_LM_Leave__c Bereavementype = TestDataFactory.createLeaveType('Bereavement Leave',true);
        Bereavementype.EMS_LM_Leave_Type__c='Bereavement Leave';
        //Insert Bereavementype; 
        EMS_LM_Leave__c paidTimeOff = TestDataFactory.createLeaveType('Paid time off',false);
        paidTimeOff.EMS_LM_Leave_Type__c='Paid time off';
        Insert paidTimeOff;
        
        string annualLeave =annualtype.Name;
        EMS_LM_ContactLeaveUpdate.getLeaveTypeid(annualLeave);
        
        Account acc = TestDataFactory.createAccount(true);
        list<contact> conList=New list<contact>();
        list<EMS_LM_Leave_History__c> leaverequestList=New list<EMS_LM_Leave_History__c>();
        Office_Location__c hydlocation = Testdatafactory.createOfficeLocation('Hyderabad - India',true);
        Office_Location__c uslocation = Testdatafactory.createOfficeLocation('California - USA',true);
        Contact conhr=  TestDataFactory.createResourceContact(acc.id, false);
        conhr.EMS_RM_Employee_Id__c = 'CP10236';
        conhr.Resource_Role__c = role.Id;
        conhr.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
        conhr.EMS_LM_Maternity_Leave__c=true;
        conhr.EMS_EM_JD__c = system.today().adddays(-389);
        conhr.Work_Location__c=uslocation.Id;
        conhr.Resource_Role__c=Hrrole.Id;
        insert conhr;
        Contact con=  TestDataFactory.createResourceContact(acc.id, false);
        con.LastName='CloudPeritus1';
        con.EMS_RM_Employee_Id__c = 'CP10234';
        con.Resource_Role__c = role.Id;
        con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
        con.EMS_LM_Maternity_Leave__c=true;
        con.EMS_EM_JD__c = system.today().adddays(-389);
        con.Work_Location__c=uslocation.Id;
        con.EMS_EM_HR_Assigned__c=conhr.Id;
        con.Email='nagavamsikrishna99@gmail.com';
        insert con;
        conList.add(con);
        Contact con1=  TestDataFactory.createResourceContact(acc.id, false);
        con1.EMS_RM_Employee_Id__c = 'CP10235';
        con1.LastName='Cp2';
        con1.Resource_Role__c = role.Id;
        con1.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
        con1.EMS_LM_Maternity_Leave__c=true;
        con1.EMS_EM_JD__c = system.today().adddays(-389);
        con1.Work_Location__c=uslocation.Id;
       // con1.Email='nagavamsikrishna88@gmail.com';
         con1.EMS_EM_HR_Assigned__c	=conhr.Id;
        insert con1;
        Resource_Resource_Relationship__c resource=Testdatafactory.createRRR(con.Id,True,con1.Id);
        User u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
        Id userid = u.Id;   
        system.runAs(u){
             Test.startTest();       
          //  EMS_LM_Leave_Credit__c lcreditAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),1.6,annualtype.id, true);
          //  EMS_LM_Leave_Credit__c bretAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),20,Bereavementype.id, true);
            EMS_LM_Leave_Credit__c mattypecredit = Testdatafactory.createLeaveCredit(con.id,system.today(),20,mattype.id, true);
            EMS_LM_Leave_Credit__c commOffAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),1,compofftype.id, true);
            EMS_LM_Leave_Credit__c workforHome = Testdatafactory.createLeaveCredit(con.id,system.today(),1,workfromhome.id, true);
            EMS_LM_Leave_Credit__c lossofpay = Testdatafactory.createLeaveCredit(con.id,system.today(),1,loptype.id, true);
            EMS_LM_Leave_Credit__c paternity = Testdatafactory.createLeaveCredit(con.id,system.today(),10,paternitytype.id, true);
            
           
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
       //  EMS_LM_ContactLeaveUpdate.getExperienceOfUser(userid);
     //   EMS_LM_ContactLeaveUpdate.getLeaveType(userid,5);
        EMS_LM_ContactLeaveUpdate.getLeaveBalance(userid);    
        EMS_LM_ContactLeaveUpdate.getbilling(userid);
        EMS_LM_ContactLeaveUpdate.getProfileName(userid);
        EMS_LM_ContactLeaveUpdate.getUserInfo(userid);
        EMS_LM_ContactLeaveUpdate.getUserInfo(userid);
        Test.stopTest();
        }
    }  */
}