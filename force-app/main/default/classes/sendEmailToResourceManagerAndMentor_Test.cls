/**
* @author Shubham Maske
* @date 04/03/2024
* @description  - Test class for sendEmailToResourceManagerAndMentor
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* 04/03/2024    Shubham Maske           Initial Version
* ====================================================================================================
**/

@isTest
public class sendEmailToResourceManagerAndMentor_Test {
    
    public static final Id RR_WINNER_RECORDTYPEID = Schema.SObjectType.Reward_And_Recognition__c.getRecordTypeInfosByDeveloperName().get('Winners').getRecordTypeId();
    
    
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
                con.EMS_RM_Employee_Id__c = 'CP1056'+i;
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
            
            EMS_TM_Project__c project = new EMS_TM_Project__c(); 
            project.Type_Of_Project__c ='Client Projects';
            project.Name ='Demo';
            project.EMS_TM_Status__c = 'ongoing';
            project.EMS_TM_StartDate__c = System.today();
            project.Project_Manager__c=contactList[1].Id;
            project.Offshore_Project_Manager__c=contactList[1].Id;
            project.EMS_TM_EndDate__c=System.today().addDays(10);
            insert project;
            
            List<EMS_TM_Assignment__c> Assignments = TestDataFactory.createProjectAssignee(contactList[0].Id);   
        }
    }
    
    testmethod static void  EmailToResourceManagerAndMentorTest(){
        
        Contact MenteeCon = [Select Id,Name,EMS_RM_Employee_Id__c,EMS_TM_User__c From Contact WHERE EMS_RM_Employee_Id__c = 'CP10560'];
        Contact MentorCon = [Select Id,Name,EMS_RM_Employee_Id__c,EMS_TM_User__c From Contact WHERE EMS_RM_Employee_Id__c = 'CP10561'];
        Fulfillment__c Ful = [Select Id,Resource__c From Fulfillment__c WHERE Resource__c =: MenteeCon.Id ];
        List<Fiscal_Year__c> FY = [Select Id,Name FROM Fiscal_Year__c LIMIT 1];
        system.debug('FY ' + FY);
        List<EMS_TM_Project__c> projects = [Select Id,Name FROM EMS_TM_Project__c WHERE Name='Demo' LIMIT 1];
        system.debug('projects ' + projects);
        
        List<Reward_And_Recognition__c> recoListToInsert = New List<Reward_And_Recognition__c>();
        for(Integer i = 1; i < 3; i++){
            Reward_And_Recognition__c rec = new Reward_And_Recognition__c();
            rec.Types_of_Recognition__c = 'Monetary Rewards';
            rec.Status__c = 'Completed';
            rec.Recognization_By__c = MentorCon.EMS_TM_User__c;
            rec.Fiscal_Year__c = FY[0].Id;
            rec.Type__c = 'Recognize';
            rec.RecordTypeId = RR_WINNER_RECORDTYPEID;
            rec.Resource__c = MenteeCon.Id;
            recoListToInsert.add(rec);
        }
        
        for(Integer i = 1; i < 3; i++){
            Reward_And_Recognition__c rec = new Reward_And_Recognition__c();
            rec.Types_of_Recognition__c = 'Performance-Based Recognition';
            rec.Status__c = 'Completed';
            rec.Recognization_By__c = MentorCon.EMS_TM_User__c;
            rec.Fiscal_Year__c = FY[0].Id;
            rec.Type__c = 'Recognize';
            rec.RecordTypeId = RR_WINNER_RECORDTYPEID;
            rec.Resource__c = MenteeCon.Id;
            recoListToInsert.add(rec);
        }
        
        for(Integer i = 1; i < 3; i++){
            Reward_And_Recognition__c rec = new Reward_And_Recognition__c();
            rec.Types_of_Recognition__c = 'Peer Recognition';
            rec.Status__c = 'Completed';
            rec.Recognization_By__c = MentorCon.EMS_TM_User__c;
            rec.Fiscal_Year__c = FY[0].Id;
            rec.Type__c = 'Recognize';
            rec.RecordTypeId = RR_WINNER_RECORDTYPEID;
            rec.Resource__c = MenteeCon.Id;
            recoListToInsert.add(rec);
        }
        
        for(Integer i = 1; i < 3; i++){
            Reward_And_Recognition__c rec = new Reward_And_Recognition__c();
            rec.Types_of_Recognition__c = 'Prize Recognition';
            rec.Status__c = 'Completed';
            rec.Recognization_By__c = MentorCon.EMS_TM_User__c;
            rec.Fiscal_Year__c = FY[0].Id;
            rec.Type__c = 'Recognize';
            rec.RecordTypeId = RR_WINNER_RECORDTYPEID;
            rec.Resource__c = MenteeCon.Id;
            recoListToInsert.add(rec);
        }
        
        Test.startTest();
        try {
            system.debug('recoListToInsert value ' + recoListToInsert);
            Insert  recoListToInsert;    
        } catch (Exception ex) {
            String errorMsg = ex.getMessage();
            System.debug('An exception occurred: ' + errorMsg);
        }
        Test.stopTest();
    }
    
}