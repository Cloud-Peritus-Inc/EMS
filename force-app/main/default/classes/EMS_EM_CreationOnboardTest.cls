@isTest
public class EMS_EM_CreationOnboardTest {
    @testSetup static void methodName() {
        EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
        EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
        EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
        
        Account acc=TestDataFactory.createAccount(True);
        
        Contact  con=TestDataFactory.createResourceContact(acc.Id,False);
        con.Personal_Email__c='naga.karpurapu@cloudperitus.com';
        insert con;
        
        EMS_EM_Onboarding_Request__c onboarding=new EMS_EM_Onboarding_Request__c();
        onboarding.EMS_EM_First_Name__c='vamsi';
        onboarding.EMS_EM_Last_Name__c='Krishna';
        onboarding.Phone_Number__c='9505977304';
        onboarding.EMS_EM_Personal_Email__c='naga.karpurapu@cloudperitus.com';
        onboarding.ContactId1__c=con.Id;
        insert onboarding;
    }
    
    Public static Testmethod void creationOnboard(){
        
        Contact condata=[select id,lastname,Personal_Email__c from contact where Personal_Email__c='naga.karpurapu@cloudperitus.com'];
        
        EMS_EM_Onboarding_Request__c onboardinggg=new EMS_EM_Onboarding_Request__c();
        onboardinggg.EMS_EM_First_Name__c='Raghu';
        onboardinggg.EMS_EM_Last_Name__c='Krishna';
        onboardinggg.Phone_Number__c='9505773041';
        onboardinggg.EMS_EM_Personal_Email__c='raghu.karpurapu@gmail.com';
        insert onboardinggg;
        
        Blob b=EncodingUtil.base64Decode('Unit Test Attachment Body'); 
        List<EMS_EM_CreationOnboard.relatedFile> fInfoList = new List<EMS_EM_CreationOnboard.relatedFile>();
        EMS_EM_CreationOnboard.relatedFile singlefileInfo = new EMS_EM_CreationOnboard.relatedFile();
        singlefileInfo.PathOnClient = '/' + 'Header_Picture1' + '.jpg';
        singlefileInfo.Title = 'ABC';
        singlefileInfo.VersionData = b;
        fInfoList.add(singlefileInfo);
        
        EMS_EM_Onboarding_Request__c onboardingsss=new EMS_EM_Onboarding_Request__c();
        onboardingsss.EMS_EM_First_Name__c='Mukesh';
        onboardingsss.EMS_EM_Last_Name__c='Rawat';
        onboardingsss.Phone_Number__c='9685854545';
        onboardingsss.EMS_EM_Personal_Email__c='nagocot641@snowlash.com';
        insert onboardingsss;
        
        Blob bb=EncodingUtil.base64Decode('Unit Test Attachment Body'); 
        List<EMS_EM_CreationOnboard.relatedFile> fInfoLists = new List<EMS_EM_CreationOnboard.relatedFile>();
        EMS_EM_CreationOnboard.relatedFile singlefileInfos = new EMS_EM_CreationOnboard.relatedFile();
        singlefileInfos.PathOnClient = '/' + 'Header_Picture1' + '.jpg';
        singlefileInfos.Title = 'ABC';
        singlefileInfos.VersionData = b;
        fInfoLists.add(singlefileInfos);
        
        EMS_EM_Onboarding_Request__c onboard=[select id,EMS_EM_First_Name__c,EMS_EM_Last_Name__c,Phone_Number__c,ContactId1__c,EMS_EM_Personal_Email__c from EMS_EM_Onboarding_Request__c where EMS_EM_First_Name__c='vamsi'];
        Certifications__c Certifications = new Certifications__c();
        Certifications.Type__c = 'Certification';
        Certifications.Certification_Name__c = 'Salesforce Certified Data Architect';
        insert Certifications;
        
        List<Certifications__c> updateCerts = new List<Certifications__c>();
        updateCerts.add(new Certifications__c(Id = Certifications.Id, Certification_Name__c = 'Salesforce Certified Integration Architect'));
        
        EMS_EM_Additional_Detail__c adddetails=new EMS_EM_Additional_Detail__c();
        adddetails.EMS_EM_Job_Title__c = 'Salseforce Developer';
        adddetails.EMS_EM_Previous_Company_Name__c = 'Fission Labs';
        adddetails.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'EMS_EM_Additional_Detail__c' AND DeveloperName = 'Work_Details'].Id;
        insert adddetails;
        
        List<EMS_EM_Additional_Detail__c> updateadddetails = new List<EMS_EM_Additional_Detail__c>();
        updateadddetails.add(new EMS_EM_Additional_Detail__c(Id = adddetails.Id, EMS_EM_Previous_Company_Name__c = 'Fission Labs'));
        
         String recordId = onboardinggg.Id;
        List<EMS_EM_CreationOnboard.FileDataWP> files = new List<EMS_EM_CreationOnboard.FileDataWP>();
        EMS_EM_CreationOnboard.FileDataWP file = new EMS_EM_CreationOnboard.FileDataWP();
        file.fileName = 'Test File.txt';
        file.fileContent = 'VGhpcyBpcyBhIHRlc3QgZmlsZS4=';
        files.add(file);
        String filedata = JSON.serialize(files);
                
        Test.startTest();
        
        EMS_EM_CreationOnboard.sendEmail('Test Mail',condata.Id,'My Mail');
        EMS_EM_CreationOnboard.getUserOnboardInfo(onboard.Id);
        EMS_EM_CreationOnboard.getonOnboardformInfo('naga.karpurapu@cloudperitus.com');
        EMS_EM_CreationOnboard.getonOnboardformInfo(null);
        EMS_EM_CreationOnboard.returnOnboardingDetailsBasedOnRecordId(onboard.id);
        EMS_EM_CreationOnboard.fetchEducation(onboard.Id);
        EMS_EM_CreationOnboard.fetchCertifications(onboard.Id);
        EMS_EM_CreationOnboard.returnOnboardingDetailsBasedOnContactId(condata.Id);
        EMS_EM_CreationOnboard.dmlOnCertifications(updateCerts, Certifications.Id);
        EMS_EM_CreationOnboard.dmlOnEducation(updateadddetails, adddetails.Id);
        EMS_EM_CreationOnboard.createGuest(onboardingsss, fInfoLists);
        EMS_EM_CreationOnboard.updateonboardingDetails(onboardinggg, fInfoList);
        EMS_EM_CreationOnboard.saveFiles(recordId, filedata);
        
        Test.stopTest();
    }
    
}