@isTest
public class createProjectAfterOppWonTest {
    public static testmethod void oppclosedcreateProj(){
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
         con.Timesheet_NoNeed__c =false;
         con.Resource_Role__c = role.Id;
         INSERT con;
        Integer count =1;
        List<Opportunity> oppList =TestDataFactory.createOpportunity(acc.id,count,false);
       Date newDate = System.today();
       Date futureDate = myDate.addDays(5);
        oppList[0].Project_Manager__c =con.Id;
        oppList[0].Contract_Start_Date__c = System.today();
          oppList[0].ACV__c='Yes';
            oppList[0].Lead_Generation__c='referral';
            oppList[0].Identify_Target_Market__c='Advisory Services';
            oppList[0].Final_Agreement_Date__c=system.today();
            oppList[0].Expected_Kick_off_Date__c=futureDate;
        INSERT oppList;
        
        test.startTest();
        Opportunity opp =[SELECT Id, StageName FROM Opportunity LIMIT 1];
        opp.StageName ='Closed Won';
        UPDATE opp;
        test.stopTest();
        
       List<EMS_TM_Project__c> projectRec =[SELECT Id FROM EMS_TM_Project__c WHERE Opportunity__c =:opp.Id];
        System.assertEquals(1, projectRec.size());
    }

}
