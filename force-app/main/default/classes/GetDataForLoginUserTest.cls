@istest
public class GetDataForLoginUserTest {
    
    public static testMethod  void getUserContactInfoTest(){
        user adminuser = TestDataFactory.createAdminUser(true);
        account acc;
        contact con;
        user testUser;
        EMS_LM_Leave__c annualtype;
        System.runAs(adminuser){
            annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
            EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
            EMS_LM_Leave__c paidtimeof = TestDataFactory.createLeaveType('Paid time off',true);
               EMS_LM_Leave__c unpaidTimeOff = TestDataFactory.createLeaveType('UnPaid time off',true);
               EMS_LM_Leave__c floatingholiday = TestDataFactory.createLeaveType('Floating Holiday',true);
            Office_Location__c officlocRec =TestDataFactory.createOfficeLocation('Hyderabad - India',true);
            Office_Location__c officlocRec2 =TestDataFactory.createOfficeLocation('California - USA',true);
            acc=TestDataFactory.createAccount(True);
            con=TestDataFactory.createResourceContact(acc.Id,false);
            con.EMS_Phone_Number__c='1234567890';
            con.Personal_Email__c='naga.karpurapu@cloudperitus.com';
            con.EMS_EM_DOB__c=system.today().adddays(-100);
            con.EMS_EM_BG__c='A RhD positive (A+)';
            con.EMS_EM_Nationality__c='Indian';
            con.EMS_EM_AadhaarNo__c='233011866123';
            con.EMS_EM_PanNo__c='JRDPl711c';
            con.EMS_EM_PassportNo__c='123567890';
            con.EMS_EM_PFno__c='UAN001234';
            con.EMS_Driving_License_No__c='drvln12345';
            con.EMS_RM_Employee_Id__c='cp1103';
            // con.Resource_Manager__c='Viswa';
            // con.Designation__c='salesforce';
            con.EMS_RM_Current_Job_Role__c='lead developer';
            con.EMS_EM_Gender__c='male';
            con.EMS_Employee_Type__c='Permanent';
            //con.EMS_EM_OLocation__c='hydherbad';
            //  con.Location__c='hyderbad';
            con.Email='nagavamsikrishna99@gmail.com';
            con.Work_Experience__c='4';
            //con.EMS_EM_HR_Assigned__c='buvana';
            con.EMS_EM_JD__c=system.today().adddays(-20);
            con.EMS_EM_PP__c=60;
            con.EMS_EM_CAddress_Line_1__c='hydherbad';
            con.EMS_EM_PAddress_Line_1__c='hydherbad';
            con.EMS_EM_CAddress_Line_2__c='hydherbad';
            con.EMS_EM_PAddress_Line_2__c='hydherbad';
            con.EMS_EM_CA_State__c='telangana';
            con.EMS_EM_PA_State__c='telangana';
            con.EMS_EM_CA_City__c='telangana';
            con.EMS_EM_PA_City__c='telangana';
            con.EMS_EM_CA_Zip__c='telana';
            con.EMS_EM_PA_Zip__c='telana';
            insert con;
            
        }
        Test.startTest();
        System.runAs(adminuser){
            testUser = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
            PayRoll__c Payroll=Testdatafactory.createPayroll(con.Id,False);
            //  System.runAs(testUser){
            ContentVersion content=new ContentVersion(); 
            content.Title='Header_Picture1'; 
            content.PathOnClient='/' + content.Title + '.jpg'; 
            Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
            content.VersionData=bodyBlob; 
            content.origin = 'H';
            insert content;
            ContentDocumentLink contentlink=new ContentDocumentLink();
            contentlink.LinkedEntityId=con.id;
            contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
            contentlink.ShareType = 'I';
            contentlink.Visibility = 'AllUsers'; 
            
            insert contentlink;
            List<ContentDocumentLink> ContentList=new list<ContentDocumentLink>();
            ContentList.add(contentlink);
            
            String recordId = con.Id; // replace with your own test record id
            List<GetDataForLoginUser.FileDataWP> files = new List<GetDataForLoginUser.FileDataWP>();
            GetDataForLoginUser.FileDataWP file = new GetDataForLoginUser.FileDataWP();
            file.fileName = 'Test File.txt';
            file.fileContent = 'VGhpcyBpcyBhIHRlc3QgZmlsZS4=';
            files.add(file);
            String filedata = JSON.serialize(files);
            
            GetDataForLoginUser.getUserContactInfo(testUser.Id); 
            GetDataForLoginUser.getPayrollInfo(con.id);
            GetDataForLoginUser.WelcomeAboardData();
            GetDataForLoginUser.CompanyGridData();
            GetDataForLoginUser.pfFormsid();
            GetDataForLoginUser.Documentsdata();
            GetDataForLoginUser.CompanyPoliciesdata();
            GetDataForLoginUser.getLoginURL();
            
            GetDataForLoginUser.getRelatedFilesByRecordId(con.id);
            
            GetDataForLoginUser.getContentDistributionForFile(contentlink.contentdocumentid);
            //GetDataForLoginUser.getContentDocumentIds(ContentList);
            GetDataForLoginUser.getRelatedFilesByRecordIdForPayForms(con.id);
            GetDataForLoginUser.updateStatus(con,con.id);
            GetDataForLoginUser.updateContact(con,con.Id,Payroll,new list<ContentVersion>());
            GetDataForLoginUser.saveFiles(recordId, filedata);
            
            //String result = GetDataForLoginUser.getExperienceURL();
            
            
            //System.assertEquals('https://test.salesforce.com/', result);
            
            
            Test.stopTest();
            
        }
        
    }
}