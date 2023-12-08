@isTest
public class EMS_EM_Request_Test {
    
    @isTest
    public static void  testMethod1(){
          EMS_LM_Leave__c  annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
            EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
            EMS_LM_Leave__c paidtimeof = TestDataFactory.createLeaveType('Paid time off',true);
        
        Office_Location__c officlocRec =TestDataFactory.createOfficeLocation('Hyderabad - India',true);
        Office_Location__c officlocRec2 =TestDataFactory.createOfficeLocation('California - USA',true);
        
        user Testuser=TestDataFactory.createCommunityUserWithOutAccAndContact(True);
        system.debug('Testuser ============================='+Testuser);
        Account acc = new Account();
        acc.Name ='rama';
        acc.Phone='96529015';
      //  acc.IsCustomerPortal = true;
        insert acc;
        System.debug('acc'+acc);
        Contact con = new contact();
        con.Email ='ramakrishna@gmail.com';
        con.AccountId = acc.id;
        con.FirstName ='rama111';
        con.LastName ='krishna11';
        con.EMS_Phone_Number__c ='9652107520';
        con.EMS_EM_Mstatus__c  = 'Single';
        // clinicRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(‘Resource Active’).getRecordTypeId();
        con.RecordTypeId = [SELECT Id FROM RecordType where name = 'Resource'].Id;
        
       //n.RecordTypeId=clinicRecordTypeId;
        insert con;

        
        
        
        EMS_EM_Request__c req = new EMS_EM_Request__c();
        req.EMS_EM_Request_Type__c = 'Address Details';
        req.EMS_EM_CAddress_Line_1__c = 'Line1';
        req.EMS_EM_CAddress_Line_2__c = 'Line 2';
        req.EMS_EM_CA_City__c = 'Hyderabad';
        req.EMS_EM_CA_State__c = 'Telangana';
        req.EMS_EM_CA_Zip__c = '500082';
        req.Contact__c = con.id;
        
        insert req;

        EMS_EM_Request.getUserContactInfo(Testuser.Id);
        EMS_EM_Request.getContactInfo(req.Id);
    }
    
    @isTest
    public static void  testMethod2(){
          EMS_LM_Leave__c  annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
            EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
         EMS_LM_Leave__c paidtimeof = TestDataFactory.createLeaveType('Paid time off',true);
        
        Office_Location__c officlocRec =TestDataFactory.createOfficeLocation('Hyderabad - India',true);
        Office_Location__c officlocRec2 =TestDataFactory.createOfficeLocation('California - USA',true);
            
        
        Account acc = new Account();
        acc.Name ='rama';
        acc.Phone='96529015';
      //  acc.IsCustomerPortal = true;
        insert acc;
        System.debug('acc'+acc);
        Contact con = new contact();
        con.Email ='ramakrishna@gmail.com';
        con.AccountId = acc.id;
        con.FirstName ='rama111';
        con.LastName ='krishna11';
        con.EMS_Phone_Number__c ='965210752';
        con.EMS_Phone_Number__c ='9652901075';
        con.EMS_EM_Mstatus__c  = 'Single';
       // con.RecordTypeId = [SELECT Id FROM RecordType where name = 'Resource Active'].Id;
        insert con;
        
	
        EMS_EM_Request__c req = new EMS_EM_Request__c();
        req.EMS_EM_Request_Type__c = 'Address Details';
        req.EMS_EM_CAddress_Line_1__c = 'Line1';
        req.EMS_EM_CAddress_Line_2__c = 'Line 2';
        req.EMS_EM_CA_City__c = 'Hyderabad';
        req.EMS_EM_CA_State__c = 'Telangana';
        req.EMS_EM_CA_Zip__c = '500082';
        req.Contact__c = con.id;
		
        
        EMS_EM_Request.createRequest(req);
    }
    @isTest
    public static void  testMethod3(){
        
        EMS_EM_Request__c req = new EMS_EM_Request__c();
        req.EMS_EM_Request_Type__c = 'Address Details';
        req.EMS_EM_CAddress_Line_1__c = 'Line1';
        req.EMS_EM_CAddress_Line_2__c = 'Line 2';
        req.EMS_EM_CA_City__c = 'Hyderabad';
        req.EMS_EM_CA_State__c = 'Telangana';
        req.EMS_EM_CA_Zip__c = '500082';
        
        insert req;
        
        
        
        ContentVersion cv1 = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.pdf',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        
        EMS_EM_Request.uploadFile(EncodingUtil.base64Encode(cv1.VersionData), 'sample.pdf', req.Id);
        
        
        
    }
}