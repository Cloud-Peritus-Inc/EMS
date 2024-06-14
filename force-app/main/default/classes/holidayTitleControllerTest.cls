@isTest
public class holidayTitleControllerTest {
 public testmethod static void HolidayCreationTest(){
         Resource_Role__c role = TestDataFactory.createResourceRole(true);
       EMS_LM_Leave__c paidtimeof = TestDataFactory.createLeaveType('Paid time off',true);
               EMS_LM_Leave__c unpaidTimeOff = TestDataFactory.createLeaveType('UnPaid time off',true);
               EMS_LM_Leave__c floatingholiday = TestDataFactory.createLeaveType('Floating Holiday',true);
         TestDataFactory.createLeaveType(true);
      Office_Location__c offLocHyd = TestDataFactory.createOfficeLocation(true);
     Office_Location__c offLocBlore = TestDataFactory.createOfficeLocation('Bangalore',true);
         Account acc = TestDataFactory.createAccount(true);
		 Contact con=  TestDataFactory.createResourceContact(acc.id, false);
         con.EMS_RM_Employee_Id__c = 'CP10234';
         con.Resource_Role__c = role.Id;
         con.Work_Location__c = offLocHyd.Id;
         insert con;
        User u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
       EMS_TM_Calendar__c cal1 = new EMS_TM_Calendar__c();
      cal1.Office_Location__c = offLocHyd.Id;
      cal1.EMS_TM_Calendar_Date__c = system.today().adddays(20);
      cal1.EMS_TM_Type_Of_Holiday__c = 'Regional';
      insert cal1;
     EMS_TM_Calendar__c cal11 = new EMS_TM_Calendar__c();
      cal11.Office_Location__c = offLocBlore.Id;
      cal11.EMS_TM_Calendar_Date__c = system.today().adddays(5);
      cal11.EMS_TM_Type_Of_Holiday__c = 'Regional';
      insert cal11;
     
     system.runAs(u){
         holidayTitleController.getMyUpcomingHoliday();
         holidayTitleController.getSelectLocList(offLocBlore.Id);
     }
 
 }
}