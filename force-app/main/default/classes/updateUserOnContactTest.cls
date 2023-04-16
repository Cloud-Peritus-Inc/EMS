/**
* @author Pallavi and Mukesh 
* @date 10/01/2023
* @description  whenever user created, related contact to get updated
*            
*
*               
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
@isTest
public class updateUserOnContactTest {
    @testSetup
    public static void  updateContact(){
        
        user adminuser = TestDataFactory.createAdminUser(true);
        Resource_Role__c techLead;
        Resource_Role__c role1;
        Account acc;
        Contact con;
        Contact conRRR;
        Contact leadcontact;
        EMS_LM_Leave__c annualtype;
        Resource_Resource_Relationship__c rrr;
        
          system.runAs(adminuser){
            
            techLead = TestDataFactory.createResourceRole('Software Engineer',true);
            role1 = TestDataFactory.createResourceRole('tech Engineer',true);
            annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
            EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
            
            acc = TestDataFactory.createAccount(true);
            
            con=TestDataFactory.createResourceContact(acc.id, false);
            con.EMS_RM_Employee_Id__c = 'CP10234';
            con.Resource_Role__c = techLead.id;
            con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
            con.EMS_LM_No_Of_Leaves_Credit__c = 15;
            con.Override_the_standard_level_of_approval__c = false;
            con.Level_of_Approval__c = 2;
            con.Ems_TM_user__c =userinfo.getUserId();
            insert con;
           
       /* Account accRecord = new Account();
        accRecord.Name ='pallavi';
        accRecord.Phone='9652901599';
        insert accRecord; 
        Contact conRecord = new Contact();
        conRecord.Email ='pallavi@gmail.com';
        conRecord.AccountId = accRecord.id;
        conRecord.FirstName ='pallavi111';
        conRecord.LastName ='thummaluru11';
        conRecord.EMS_Phone_Number__c ='9652107529';
        conRecord.EMS_RM_Phone_Number__c ='9652901075';
        conRecord.RecordTypeId = ContactConstant.RESOURCE_RECORDTYPEID;
        conRecord.EMS_EM_JD__c = system.today();
        
        insert conRecord;*/
        
    }
    }
    
    public static testmethod void updateCommunityUserTest(){
        Contact contactList = [SELECT id,FirstName FROM Contact WHERE EMS_RM_Employee_Id__c ='CP10234'];
        
        test.startTest();
        Profile communityProfile = [SELECT id FROM profile WHERE name='TM Customer Community'];
        User newUser = new User(Alias = 'PT0', 
                          Email='pallaviuser@testmethod.com', 
                          EmailEncodingKey='UTF-8',
                          LastName='Testing111',
                          FirstName = 'one', 
                          LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', 
                          ProfileId = communityProfile.Id, 
                          TimeZoneSidKey='America/Los_Angeles', 
                          UserName='standarduser@testuser.com', 
                          IsActive = true ,ContactId=contactList.id );      
        insert newUser; 
        test.stopTest();
        Contact updatecontact = [SELECT id,FirstName,EMS_TM_User__c,Official_Mail__c FROM Contact WHERE EMS_RM_Employee_Id__c ='CP10234'];
      //  updatecontact.Official_Mail__c ='pt@pt.com';
        //update updatecontact;
       // System.assertEquals([SELECT EMAIL FROM CONTACT LIMIT 1].EMAIL, 'pt@pt.com');
        
        
    }
    
}