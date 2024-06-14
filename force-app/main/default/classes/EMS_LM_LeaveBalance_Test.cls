/**
* @author Shubham Maske
* @date 24/November/2023
* @description  Test class for EMS_LM_LeaveBalance.
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
@isTest
public class EMS_LM_LeaveBalance_Test {
       
    @isTest
    public static  void getLeaveBalanceWithContact(){
        User testUser = getUser();
        Test.startTest();
        Contact con = EMS_LM_LeaveBalance.getLeaveBalance(testUser.Id);
        Assert.isNotNull(con);
        Test.stopTest();
    }
    @isTest
    public static  void getLeaveBalanceWithOutContact(){   
        try {
            User testUser = getUser2();
            Contact con = EMS_LM_LeaveBalance.getLeaveBalance(testUser.Id);
            Assert.isNotNull(con);
        } catch (QueryException e) {
            System.assertEquals('List has no rows for assignment to SObject', e.getMessage());
        } catch (Exception e) {
            System.assert(false, 'Caught unexpected exception: ' + e.getMessage());
        }
    }
    
    public static User getUser(){
        user userId =[SELECT id FROM User  WHERE IsActive = true LIMIT 1];        
        
        Resource_Role__c role = TestDataFactory.createResourceRole(false);
        role.Name ='Sr Project Manager';
        insert role;
        
        //Work Location
        Office_Location__c HYD = new Office_Location__c();
        HYD.Name = 'Hyderabad - India';
        HYD.Address__c = 'Jubilee Hills. Road No 36';
        HYD.Country__c = 'India';
        HYD.Timezone__c = 'Asia/Kolkata';
        INSERT HYD;
        
        Office_Location__c USA = new Office_Location__c();
        USA.Name = 'California - USA';
        USA.Country__c = 'United States of America';
        USA.Address__c = '3000 Executive Parkway Suite 215, San Ramon, CA 94583 USA';
        USA.Timezone__c = 'America/Los_Angeles';
        INSERT USA;
        
        EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
        EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
        EMS_LM_Leave__c workfromhome = TestDataFactory.createLeaveType('Work From Home',true);
        EMS_LM_Leave__c paidTimeOff = TestDataFactory.createLeaveType('Paid time off',true);
        Account acc = TestDataFactory.createAccount(true);
                
        Contact con1=  TestDataFactory.createResourceContact(acc.id, false);
        con1.EMS_RM_Employee_Id__c = 'CP10236';
        con1.Email='ramakrishna.papana@cloudperitus2.com';
        con1.EMS_RM_ApplicantStatus_Update__c ='Active';
        con1.EMS_Phone_Number__c ='0123456789';
        con1.EMS_EM_CAddress_Line_1__c ='USA';
        con1.EMS_EM_CA_City__c ='USA';
        con1.EMS_EM_CA_State__c ='LA';
        con1.Work_Location__c = USA.Id;
        con1.Timesheet_NoNeed__c =false;
        con1.Resource_Role__c = role.Id;
        con1.EMS_TM_User__c =UserId.Id;
        INSERT con1;
        
        User testUser = new User(
            ContactId = con1.Id,
            FirstName = 'John',
            IsActive = true,
            LastName = 'Doe',
            Alias = 'jdoe',
            Email = 'testUser@cloudperitus.com',
            Username = 'jdoe@example.com',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Employee - Operations(Community)'].Id, // Replace with the desired Profile
            TimeZoneSidKey = 'America/New_York', // Set the desired timezone
            LocaleSidKey = 'en_US', // Set the desired locale
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        return testUser;
    }
    
    public static User getUser2(){
        User testUser = new User(
            FirstName = 'John',
            IsActive = true,
            LastName = 'Doie',
            Alias = 'jdoie',
            Email = 'testUser@cloudperitus.com',
            Username = 'jdoie@example.com',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id, // Replace with the desired Profile
            TimeZoneSidKey = 'America/New_York', // Set the desired timezone
            LocaleSidKey = 'en_US', // Set the desired locale
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        return testUser;
    }
    
    
}