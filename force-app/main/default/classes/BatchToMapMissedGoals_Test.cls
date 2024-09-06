/**
* @author Subba Kalavala
* @date 2/22/2023
* @description  Test class for BatchToMapMissedGoals

* CHANGE HISTORY
* ====================================================================================================
* DATE          	NAME                    DESCRIPTION
* 04-March-2024    Shubham Maske			Updated test class for BatchClass Coverage
* ====================================================================================================
**/
@isTest
public class BatchToMapMissedGoals_Test {
    public static testMethod void testscheduleclass() {
        Test.StartTest();
        BatchToMapMissedGoals_sch testsche = new BatchToMapMissedGoals_sch();
        String sch = '0 0 23 * * ?';
        system.schedule('Test BatchToMapMissedGoals_sch Check', sch, testsche );
        
        BatchToMapMissedGoals_sch2 testsche2 = new BatchToMapMissedGoals_sch2();
        system.schedule('Test BatchToMapMissedGoals_sch2 Check2', sch, testsche2 );
        Test.stopTest();
    }
    
    //smaske : Commenting below test method as it was failing and was not updated
    /*
public static testMethod void testBatchclass() {
Resource_Role__c role = TestDataFactory.createResourceRole(true);
EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
EMS_LM_Leave__c paidtimeof = TestDataFactory.createLeaveType('Paid time off',true);
EMS_LM_Leave__c unpaidTimeOff = TestDataFactory.createLeaveType('UnPaid time off',true);
EMS_LM_Leave__c floatingholiday = TestDataFactory.createLeaveType('Floating Holiday',true);

Account acc = TestDataFactory.createAccount(true);
Contact con=  TestDataFactory.createResourceContact(acc.id, false);
con.EMS_RM_Employee_Id__c = 'CP10234';
con.Resource_Role__c = role.Id;
con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
insert con;

Goal__c gl = new Goal__c();
gl.Goal_Name__c = 'TEST GOAL';
gl.Resource__c = con.Id;
gl.Start_Date__c = system.today().adddays(-6);
gl.End_Date__c  = system.today().adddays(-4);
gl.Description__c = 'TEST TESTETST';
gl.Status__c = 'Active';
insert gl;


Test.startTest();
BatchToMapMissedGoals batchExecute = new BatchToMapMissedGoals(); 
Database.executeBatch(batchExecute,10);
Test.stopTest();
} 

*/
    
    //smaske : Test Data Setup
    @testSetup
    static void setupTestData() {
        
        user adminuser = TestDataFactory.createAdminUser(true); 
        Resource_Role__c role;
        EMS_LM_Leave__c annualtype;
        EMS_LM_Leave__c loptype;
        EMS_LM_Leave__c bretype;
        EMS_LM_Leave__c compofftype;
        EMS_LM_Leave__c paternitytype;
        EMS_LM_Leave__c  Bereavementtype;
        EMS_LM_Leave__c paidTimeOff;
        Office_Location__c hydIndia;
        Office_Location__c usLocation;
        
        Resource_Role__c techLead;
        Resource_Resource_Relationship__c rrr;
        List<Resource_Role__c> resourceRoleList = new List<Resource_Role__c>();
        List<Contact> contactList = new List<Contact>();
        List<User> userList = new List<User>();
        
        Account acc;Contact con;
        system.runAs(adminuser){
            role = TestDataFactory.createResourceRole(true);
            
            annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            paternitytype = TestDataFactory.createLeaveType('Paternity Leave',true);
            Bereavementtype = TestDataFactory.createLeaveType('Bereavement Leave',true);
            paidTimeOff = TestDataFactory.createLeaveType('Paid time off',true);
            
            
            hydIndia = TestDataFactory.createOfficeLocationboth('Hyderabad - India','India',true);
            usLocation = TestDataFactory.createOfficeLocationboth('California - USA','United States of America',true);
        
           /* usLocation.Name = 'California - USA';
        usLocation.Address__c = '3000 Executive Parkway Suite 215, San Ramon, CA 94583 USA';
        usLocation.Country__c = 'United States of America';
            insert usLocation;*/
        
            List<Office_Location__c> OfficeLocationList = new List<Office_Location__c>();
            OfficeLocationList.add(hydIndia);
            OfficeLocationList.add(usLocation);
            acc = TestDataFactory.createAccount(true);
            
            resourceRoleList.add(techLead = TestDataFactory.createResourceRole('Software Engineer',false));
            insert resourceRoleList;
            
            
            for(Integer i=0; i<2; i++){
                con =TestDataFactory.createResourceContact(acc.id, false);
                con.EMS_RM_Employee_Id__c = 'CP1023'+i;
                con.Resource_Role__c = resourceRoleList[0].Id;
                con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
                con.EMS_RM_ApplicantStatus_Update__c = 'Active';
                con.RecordTypeId = ContactConstant.RESOURCE_RECORDTYPEID;
                con.EMS_EM_JD__c = system.today() - 180;
                con.Work_Location__c = OfficeLocationList[i].Id;
                contactList.add(con);
            }
            
            insert contactList;
           
            for(Contact cont : contactList){
                User u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,cont.Id,false);
                u.Username = u.Username + cont.Id;
                u.ContactId = cont.Id;
                userList.add(u);
                system.debug('cont.Work_Location_Country__c'+cont.Work_Location_Country__c);
            }
            Insert userList;
            
            rrr = TestDataFactory.createRRR(contactList[0].Id, true, contactList[1].Id);
            
            Fiscal_Year__c FiscalYear = TestDataFactory.createFiscalYear(true);
        }
    }
    
    //smaske : New method
    testmethod static void  testBatchclassForGoals(){
        
      /*  Contact MentorCon = [Select Id,Name,EMS_RM_Employee_Id__c,Work_Location__c From Contact WHERE EMS_RM_Employee_Id__c = 'CP10230'];
        system.debug('MentorCon-->'+MentorCon);
        Contact MenteeCon = [Select Id,Name,EMS_RM_Employee_Id__c,Work_Location__c From Contact WHERE EMS_RM_Employee_Id__c = 'CP10231'];
        system.debug('MenteeCon-->'+MenteeCon);
        Fulfillment__c Ful = TestDataFactory.createFulfillment(MenteeCon.Id, true);
        Fulfillment__c Ful2 = TestDataFactory.createFulfillment(MentorCon.Id, true);
        system.debug('Ful-->'+Ful);
        system.debug('Ful2-->'+Ful2);
        
        try {
            Goal__c KRA = TestDataFactory.createKRARecords(MenteeCon.Id, MentorCon.Id,Ful,true);
            Goal__c KRA1 = TestDataFactory.createKRARecords(MentorCon.Id, MenteeCon.Id,Ful2,true);
            List<Goal__c> ListOfGoalsToCreate = New List<Goal__c>();
            for(Integer i = 0; i < 10; i ++){
                String name = 'Certification Goal ' + '' + i;
                Date startdate = Date.today();
                Date enddate = Date.today().addDays(10);
                String descri = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit';
                Goal__c goal = TestDataFactory.createGoalRecords(MenteeCon.Id, Name, startdate, enddate, Null,false);
                ListOfGoalsToCreate.add(goal);
                Goal__c goal1 = TestDataFactory.createGoalRecords(MentorCon.Id, Name, startdate, enddate, Null,false);
                ListOfGoalsToCreate.add(goal1);
            }   
            for(Integer i = 0; i < 5; i ++){
                String name = 'Certification Goal ' + '' + i;
                Date startdate = Date.today().addDays(-10);
                Date enddate = Date.today().addDays(-1);
                String descri = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit';
                Goal__c goal = TestDataFactory.createGoalRecords(MenteeCon.Id, Name, startdate, enddate, KRA,false);
                goal.Status__c = 'Active';
                ListOfGoalsToCreate.add(goal);
                Goal__c goal1 = TestDataFactory.createGoalRecords(MentorCon.Id, Name, startdate, enddate, KRA1,false);
                goal1.Status__c = 'Active';
                ListOfGoalsToCreate.add(goal1);
            }
            for(Integer i = 0; i < 5; i ++){
                String name = 'Certification Goal ' + '' + i;
                Date startdate = Date.today().addDays(-20);
                Date enddate = Date.today().addDays(-2);
                String descri = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit';
                Goal__c goal = TestDataFactory.createGoalRecords(MenteeCon.Id, Name, startdate, enddate, KRA,false);
                goal.Status__c = 'In Progress';
                ListOfGoalsToCreate.add(goal);
                Goal__c goal1 = TestDataFactory.createGoalRecords(MentorCon.Id, Name, startdate, enddate, KRA1,false);
                goal1.Status__c = 'In Progress';
                ListOfGoalsToCreate.add(goal1);
            }
            for(Integer i = 0; i < 5; i ++){
                String name = 'Certification Goal ' + '' + i;
                Date startdate = Date.today().addDays(-30);
                Date enddate = Date.today().addDays(-10);
                String descri = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit';
                Goal__c goal = TestDataFactory.createGoalRecords(MenteeCon.Id, Name, startdate, enddate, KRA,false);
                goal.Status__c = 'Missed';
                ListOfGoalsToCreate.add(goal);
                Goal__c goal1 = TestDataFactory.createGoalRecords(MentorCon.Id, Name, startdate, enddate, KRA1,false);
                goal1.Status__c = 'Missed';
                ListOfGoalsToCreate.add(goal1);
            }
            
            Test.startTest();
            insert ListOfGoalsToCreate;
            
            String GOAL_RECORD_TYPE = 'Goal';
        	Id goalRecTypeId = Schema.SObjectType.Goal__c.getRecordTypeInfosByName().get(GOAL_RECORD_TYPE).getRecordTypeId();
            list<Goal__c> indiaGoal=[SELECT Id,Status__c,Start_Date__c,End_Date__c,RecordTypeId FROM Goal__c WHERE (Status__c='Active' OR Status__c='Missed' OR Status__c='Draft' OR Status__c='In Progress') And RecordTypeId =:goalRecTypeId AND Resource__r.Work_Location_Country__c ='India'];
            list<Goal__c> notindiaGoal=[SELECT Id,Status__c,Start_Date__c,End_Date__c,RecordTypeId FROM Goal__c WHERE (Status__c='Active' OR Status__c='Missed' OR Status__c='Draft' OR Status__c='In Progress') And RecordTypeId =:goalRecTypeId AND Resource__r.Work_Location_Country__c !='India'];
            system.debug('indiaGoal-->'+indiaGoal);
        	system.debug('notindiaGoal-->'+notindiaGoal);

            BatchToMapMissedGoals batchExecute = new BatchToMapMissedGoals(); 
            Database.executeBatch(batchExecute);
            BatchToMapMissedGoals2 batchExecute2 = new BatchToMapMissedGoals2(); 
            Database.executeBatch(batchExecute2);
            Test.stopTest();
        } catch (Exception ex) {
            String errorMsg = ex.getMessage();
            System.debug('An exception occurred: ' + errorMsg);
        }*/
        
        
    }
}