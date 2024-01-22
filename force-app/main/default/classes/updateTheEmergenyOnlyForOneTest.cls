@isTest
public class updateTheEmergenyOnlyForOneTest {
    public testmethod static void deleteWorkDetails(){
        user adminuser = TestDataFactory.createAdminUser(true);
        
        system.runAs(adminuser){
            Office_Location__c hydofficlocRec =TestDataFactory.createOfficeLocation('Hyderabad - India',true);
            Office_Location__c usofficlocRec =TestDataFactory.createOfficeLocation('California - USA',true);
            Resource_Role__c role = TestDataFactory.createResourceRole(true);
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
            con.Timesheet_NoNeed__c =false;
            con.Resource_Role__c = role.Id;
            con.Email = 'Test@gmail.com';
            con.EMS_EM_JD__c = System.today().addDays(-30);
            insert con; 
            
            Family_Information__c fam = TestDataFactory.createFamilyInfo(con.id,true,true,true);
            Family_Information__c fam2 = TestDataFactory.createFamilyInfo(con.id,true,false,true);
            
            Test.startTest();
            updateTheEmergenyOnlyForOne obj = new updateTheEmergenyOnlyForOne();
            obj.afterUpdate(new List<Family_Information__c>{fam, fam2}, new List<Family_Information__c>{fam, fam2});
            Test.stopTest();
            
        }      
    }
}