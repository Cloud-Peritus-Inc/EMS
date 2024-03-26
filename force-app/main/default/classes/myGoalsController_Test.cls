/**
* @author Shubham Maske 
* @date 29/02/2024
* @description  Test class for myGoalsController

* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* 29/02/2024    Shubham Maske           Initial Version
* ====================================================================================================
**/
@isTest
public class myGoalsController_Test {
    
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
            
            
            hydIndia = TestDataFactory.createOfficeLocation('Hyderabad - India',true);
            usLocation = TestDataFactory.createOfficeLocation('California - USA',true);
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
            }
            Insert userList;
            
            rrr = TestDataFactory.createRRR(contactList[0].Id, true, contactList[1].Id);
            
            Fiscal_Year__c FiscalYear = TestDataFactory.createFiscalYear(true);
            
            Fulfillment__c Ful = TestDataFactory.createFulfillment(contactList[0].Id, true);
            Fulfillment__c Ful2 = TestDataFactory.createFulfillment(contactList[1].Id, true);
        }
    }
    
    testmethod static void  createTheGoalsMethod(){
        Test.startTest();
        Contact MentorCon = [Select Id,Name,EMS_RM_Employee_Id__c From Contact WHERE EMS_RM_Employee_Id__c = 'CP10230'];
        Contact MenteeCon = [Select Id,Name,EMS_RM_Employee_Id__c From Contact WHERE EMS_RM_Employee_Id__c = 'CP10231'];
		Fulfillment__c Ful = [Select Id,Resource__c From Fulfillment__c WHERE Resource__c =: MenteeCon.Id ];
        
        TestDataFactory.createKRARecords(MenteeCon.Id, MentorCon.Id,Ful,true);
        
        String name = 'Certification Goal';
        Date startdate = Date.today().addDays(1);
        Date enddate = Date.today().addDays(10);
		String descri = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit';
        myGoalsController.createTheGoals(Ful.Id, MenteeCon.Id, 'name', startdate, enddate, descri);
        Test.stopTest();
    }
    
    testmethod static void  createTheGoalsMethod2(){
        Test.startTest();
        Contact MentorCon = [Select Id,Name,EMS_RM_Employee_Id__c From Contact WHERE EMS_RM_Employee_Id__c = 'CP10230'];
        Contact MenteeCon = [Select Id,Name,EMS_RM_Employee_Id__c From Contact WHERE EMS_RM_Employee_Id__c = 'CP10231'];
		Fulfillment__c Ful = [Select Id,Resource__c From Fulfillment__c WHERE Resource__c =: MenteeCon.Id ];
        
        //TestDataFactory.createKRARecords(MenteeCon.Id, MentorCon.Id,Ful,true);
        String name = 'Certification Goal';
        Date startdate = Date.today().addDays(1);
        Date enddate = Date.today().addDays(10);
		String descri = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit';
        try {
            myGoalsController.createTheGoals(Ful.Id, Null, 'name',startdate, enddate, descri);
        } catch (Exception ex) {
            // Handle the exception here
            String errorMsg = ex.getMessage();
            System.debug('An exception occurred: ' + errorMsg);
        }
        Test.stopTest();
    }
    
    testmethod static void  createTheGoalsMethod3(){
        Test.startTest();
        Contact MentorCon = [Select Id,Name,EMS_RM_Employee_Id__c From Contact WHERE EMS_RM_Employee_Id__c = 'CP10230'];
        Contact MenteeCon = [Select Id,Name,EMS_RM_Employee_Id__c From Contact WHERE EMS_RM_Employee_Id__c = 'CP10231'];
		//Fulfillment__c Ful = [Select Id,Resource__c From Fulfillment__c WHERE Resource__c =: MenteeCon.Id ];
        //TestDataFactory.createKRARecords(MenteeCon.Id, MentorCon.Id,Ful,true);
        String name = 'Certification Goal';
        Date startdate = Date.today().addDays(1);
        Date enddate = Date.today().addDays(10);
		String descri = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit';
        try {
            myGoalsController.createTheGoals(Null, Null, 'name',startdate, enddate, descri);
        } catch (Exception ex) {
            String errorMsg = ex.getMessage();
            System.debug('An exception occurred: ' + errorMsg);
        }
        Test.stopTest();
    }
    
    testmethod static void  getAlltheGoalsMethod(){
        Test.startTest();
        Contact MentorCon = [Select Id,Name,EMS_RM_Employee_Id__c From Contact WHERE EMS_RM_Employee_Id__c = 'CP10230'];
        Contact MenteeCon = [Select Id,Name,EMS_RM_Employee_Id__c From Contact WHERE EMS_RM_Employee_Id__c = 'CP10231'];
        Fulfillment__c Ful = [Select Id,Resource__c From Fulfillment__c WHERE Resource__c =: MenteeCon.Id ];
        
        try {
            Goal__c KRA = TestDataFactory.createKRARecords(MenteeCon.Id, MentorCon.Id,Ful,true);
            String name = 'Certification Goal';
            Date startdate = Date.today().addDays(1);
            Date enddate = Date.today().addDays(10);
            String descri = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit';
            Goal__c goal = TestDataFactory.createGoalRecords(MenteeCon.Id, Name, startdate, enddate, KRA,true);
            myGoalsController.getAlltheGoals(KRA.Id);
            myGoalsController.getTheGoals(goal.Id);
            myGoalsController.saveTheGoal(goal.Id, 'finalComments from Test');
            goal.End_Date__c = Date.today().addDays(-2);
            update goal;
            myGoalsController.saveTheGoal(goal.Id, 'finalComments from Test');
            
            myGoalsController.saveTheGoal('12345', 'finalComments from Test');
        } catch (Exception ex) {
            String errorMsg = ex.getMessage();
            System.debug('An exception occurred: ' + errorMsg);
        }
        
        Test.stopTest();
    }

}