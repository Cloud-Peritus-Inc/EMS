@isTest public class EMS_TM_notifyMangerTest {
  @testsetup
  public static void rtestmethod() {
      profile adminProfile=[SELECT Id, Name FROM Profile WHERE Name =:'System Administrator'];
   //   UserRole roleId =[SELECT Id, Name, ParentRoleId, PortalType, PortalRole FROM UserRole where Name ='Project Manager'];
      user us =new user();
      us.FirstName='Ram';
      us.LastName='kumar';
      us.Email='ramkumar@gmail.com';
      us.Username='ramkumar123@gmail.com.testfdgj';
    //  us.UserRoleId = roleId.Id;
      us.Alias='Rkumar'; 
      us.TimeZoneSidKey='America/Los_Angeles';
      us.LocaleSidKey='en_US'; 
      us.EmailEncodingKey='UTF-8'; 
      us.ProfileId=adminProfile.Id; 
      us.LanguageLocaleKey='en_US';
      insert us;  
  }
  
  public static testmethod void testmanager(){
      recordtype rt =[SELECT Id, Name, DeveloperName, IsActive, SobjectType FROM RecordType where name ='Resource'];
      contact c1 = new contact();
      c1.lastname ='olask';
      c1.Official_Mail__c ='olaskoka@test.com';
      c1.EMS_RM_Resource_Mobile_no__c ='5647258899';
      c1.Phone ='1234567890';
      c1.EMS_Phone_Number__c = '9648573210';
      c1.Location__c ='india';
      c1.RecordTypeId = rt.id;
      c1.EMS_EM_JD__c = system.today();
      //c1.EMS_TM_User__c = u.id;
      c1.EMS_RM_Current_Job_Role__c ='Senior Project Manager - Salesforce';
      insert c1;
      user u =[select id,lastname from user where LastName ='kumar'];
        contact c = new contact();
      c.lastname ='rkolsdh';
      c.Official_Mail__c ='rkolsdh12@gmail.com';
      c.EMS_RM_Resource_Mobile_no__c ='9412584455';
      c.Phone ='1234567890';
      c.EMS_Phone_Number__c = '9341586210';
      c.Location__c ='india';
      c.EMS_TM_User__c = u.id;
      insert c;
      
      Test.startTest();
      EMS_Timesheet__c emsts = new EMS_Timesheet__c();
      emsts.EMS_TM_Status__c='New';
      emsts.User__c= u.id;
      emsts.EMS_TM_Mon__c=8;
      emsts.EMS_TM_Tue__c=8;
      emsts.EMS_TM_Wed__c=8;
      emsts.EMS_TM_Thu__c=8;
      emsts.EMS_TM_Fri__c=8;
      emsts.EMS_TM_Sat__c=8;
      emsts.EMS_TM_Week__c=date.newInstance(2022, 8, 26);
      
      insert emsts;
    
      String sch = '0 0 0 * * ?';
      EMS_TM_EscalationMailSchedule tsc = new EMS_TM_EscalationMailSchedule();
      system.schedule('Test status', sch, tsc );
      Test.stopTest();
  }
}