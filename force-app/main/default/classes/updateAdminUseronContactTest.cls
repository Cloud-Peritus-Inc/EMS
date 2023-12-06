@istest
public class updateAdminUseronContactTest {
@testSetup
    public static void  contactUpdate(){
Resource_Role__c role = TestDataFactory.createResourceRole(false);
         role.Name ='Sr Project Manager';
        insert role;
        EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
        EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
        EMS_LM_Leave__c workfromhome = TestDataFactory.createLeaveType('Work From Home',true);
          EMS_LM_Leave__c paidtimeof = TestDataFactory.createLeaveType('Paid time off',true);
               EMS_LM_Leave__c unpaidTimeOff = TestDataFactory.createLeaveType('UnPaid time off',true);
               EMS_LM_Leave__c floatingholiday = TestDataFactory.createLeaveType('Floating Holiday',true);
        Account acc = TestDataFactory.createAccount(true);
        Contact con=  TestDataFactory.createResourceContact(acc.id, false);
        con.EMS_RM_Employee_Id__c = 'CP10235';
        con.EMS_RM_ApplicantStatus_Update__c ='Active';
        con.EMS_Phone_Number__c ='0123456789';
        con.EMS_EM_CAddress_Line_1__c ='Hyd';
        con.EMS_EM_CA_City__c ='Hyd';
        con.EMS_EM_CA_State__c ='AP';
        con.Email ='ramakrishna.papana@cloudperitus.com';
        con.Timesheet_NoNeed__c =false;
        con.Resource_Role__c = role.Id;
        INSERT con;    
        
    }
    
    public static testmethod void chaneuser(){
        contact con = [Select id,FirstName from Contact where EMS_RM_Employee_Id__c ='CP10235'];
        System.debug('con'+con);
        Account a =[Select id,name  from Account limit 1];
        System.debug('a'+a);
            test.startTest();
         Profile p = [Select id from profile where name='System Administrator'];
         User u = new User(Alias = 'am0', Email='useruser@testmethod.com',
                          EmailEncodingKey='UTF-8', LastName='Testing111',FirstName = 'one', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testuser.com', 
                           IsActive = true);         
        insert u;
        System.debug('u'+u);  
          test.stopTest();
        user uu =[Select id,lastname from user where lastname ='Testing111'];
        System.debug('uu'+uu);
        contact con1 = [Select id,FirstName,EMS_TM_User__c,Official_Mail__c from Contact where EMS_RM_Employee_Id__c ='CP10235'];
        con1.Official_Mail__c ='Rm@rk.com';
        update con1;
         System.debug('c'+con1);
    }
    
}