/**
* @author Shubham Maske
* @date 05/03/2024
* @description  - Test class for BatchToUpdatePridcation & BatchToUpdatePridcation_Sch
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* 05/03/2024    Shubham Maske           Initial Version
* ====================================================================================================
**/

@isTest
public class BatchToUpdatePridcation_Test {
    
    public static final Id RR_NOMINATION_RECORDTYPEID = Schema.SObjectType.Reward_And_Recognition__c.getRecordTypeInfosByDeveloperName().get('Nominations').getRecordTypeId();
    public static final Id RR_SCORING_RECORDTYPEID = Schema.SObjectType.Reward_And_Recognition__c.getRecordTypeInfosByDeveloperName().get('Scoring').getRecordTypeId();   
    
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
                con.EMS_RM_Employee_Id__c = 'CP1088'+i;
                con.Resource_Role__c = resourceRoleList[0].Id;
                con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
                con.EMS_RM_ApplicantStatus_Update__c = 'Active';
                con.RecordTypeId = ContactConstant.RESOURCE_RECORDTYPEID;
                con.EMS_EM_JD__c = system.today() - 180;
                con.Work_Location__c = OfficeLocationList[i].Id;
                con.Not_Eligible_For_Annual_Awards__c = true;
                con.EMS_EM_Exp__c = 4;
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
            
            for(Integer i=0; i<2; i++){
                contactList[i].EMS_TM_User__c = userList[i].Id;
                if(contactList[i].EMS_RM_Employee_Id__c == 'CP10880'){
                    contactList[i].Not_Eligible_For_Annual_Awards__c = false;
        			contactList[i].EMS_EM_Exp__c = 1;
                }
              /*  if(contactList[i].EMS_RM_Employee_Id__c == 'CP10881'){
                    contactList[i].Not_Eligible_For_Annual_Awards__c = true;
                }*/
            }
            update contactList;
            System.debug('Updated Contact List ' + contactList);
            
            rrr = TestDataFactory.createRRR(contactList[0].Id, true, contactList[1].Id);
            
            //Fiscal_Year__c FiscalYear = TestDataFactory.createFiscalYear(true);
            
            Fulfillment__c Ful = TestDataFactory.createFulfillment(contactList[0].Id, true);
            //Fulfillment__c Ful2 = TestDataFactory.createFulfillment(contactList[1].Id, true);
            
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
    
    public static testMethod void testscheduleclass() {
        Test.StartTest();
        BatchToUpdatePridcation_sch testsche = new BatchToUpdatePridcation_sch();
        String sch = '0 0 23 * * ?';
        system.schedule('Test BatchToUpdatePridcation_sch Check', sch, testsche );
        Test.stopTest();
    }
    
    testmethod static void  testingUpdatePridcationBatch(){
        Test.startTest();
        Contact MenteeCon = [Select Id,Name,EMS_RM_Employee_Id__c,EMS_TM_User__c,Not_Eligible_For_Annual_Awards__c From Contact WHERE EMS_RM_Employee_Id__c = 'CP10880'];
        Contact MentorCon = [Select Id,Name,EMS_RM_Employee_Id__c,EMS_TM_User__c,Not_Eligible_For_Annual_Awards__c From Contact WHERE EMS_RM_Employee_Id__c = 'CP10881'];
        
        Fulfillment__c Ful = [Select Id,Resource__c,Fiscal_Year__c From Fulfillment__c WHERE Resource__c =: MenteeCon.Id ];
        List<Fiscal_Year__c> FY = [Select Id,Name FROM Fiscal_Year__c LIMIT 1];
        List<EMS_TM_Project__c> projects = [Select Id,Name FROM EMS_TM_Project__c WHERE Name='Demo' LIMIT 1];
        
        List<String> AwardTypeList = new List<String>{'Rising Star','Best Entrepreneur', 'Most Professional','Rock Star', 'Shining Star', 'Going Above and Beyond', 'Award of Excellence','Best Entrepreneur', 'Most Professional', 'Rising Star', 'Rock Star', 'Shining Star', 'Going Above and Beyond', 'Award of Excellence'};
		
        List<Reward_And_Recognition__c> recoListToInsert = New List<Reward_And_Recognition__c>();
        
        //Nomination records 
        for(String awardType : AwardTypeList ){
            Reward_And_Recognition__c rec = new Reward_And_Recognition__c();
            rec.Fiscal_Year__c = FY[0].Id;
            rec.Resource__c = MenteeCon.Id;
            rec.Recognization_By__c = MentorCon.EMS_TM_User__c;
            rec.RecordTypeId = RR_NOMINATION_RECORDTYPEID;
            rec.Status__c = 'Nominated';
            rec.Type__c = 'Annual Award';
            rec.Reason_for_award__c = 'Good Resource , Excellent Job';
            rec.Award_Type__c = awardType;
            rec.Primary_Nomination__c = true;
            rec.Nomination_Submitted__c = true; 
            rec.of_Primary_Nominations__c =1;
            rec.of_Secondary_Nominations__c=2;
            recoListToInsert.add(rec);
        }
        
        for(String awardType : AwardTypeList ){
            Reward_And_Recognition__c rec = new Reward_And_Recognition__c();
            rec.Fiscal_Year__c = FY[0].Id;
            rec.Resource__c = MentorCon.Id;
            rec.Recognization_By__c = MenteeCon.EMS_TM_User__c;
            rec.RecordTypeId = RR_NOMINATION_RECORDTYPEID;
            rec.Status__c = 'Nominated';
            rec.Type__c = 'Annual Award';
            rec.Reason_for_award__c = 'Good Resource , Excellent Job';
            rec.Award_Type__c = awardType;
            rec.Primary_Nomination__c = true;
            rec.Nomination_Submitted__c = true; 
            rec.of_Primary_Nominations__c =1;
            rec.of_Secondary_Nominations__c=2;
            recoListToInsert.add(rec);
        }
            
            for(String awardType : AwardTypeList ){
                Reward_And_Recognition__c rec = new Reward_And_Recognition__c();
                rec.Fiscal_Year__c = FY[0].Id;
                rec.Resource__c = MenteeCon.Id;
                rec.Recognization_By__c = MentorCon.EMS_TM_User__c;
                rec.RecordTypeId = RR_SCORING_RECORDTYPEID;
                rec.Status__c = 'Review In Progress';
                rec.Type__c = 'Annual Award';
                rec.Reason_for_award__c = 'Good Resource , Excellent Job';
                rec.Award_Type__c = awardType;
                rec.Primary_Nomination__c = true;
                rec.Nomination_Submitted__c = true;
                rec.of_Primary_Nominations__c =1;
            rec.of_Secondary_Nominations__c=2;
                recoListToInsert.add(rec);
            }
        
        for(String awardType : AwardTypeList ){
                Reward_And_Recognition__c rec = new Reward_And_Recognition__c();
                rec.Fiscal_Year__c = FY[0].Id;
                rec.Resource__c = MenteeCon.Id;
                rec.Recognization_By__c = MentorCon.EMS_TM_User__c;
                rec.RecordTypeId = RR_SCORING_RECORDTYPEID;
                rec.Status__c = 'Review In Progress';
                rec.Type__c = 'Annual Award';
                rec.Reason_for_award__c = 'Good Resource , Excellent Job';
                rec.Award_Type__c = awardType;
                rec.Primary_Nomination__c = true;
                rec.Nomination_Submitted__c = true;
            rec.of_Primary_Nominations__c =1;
            rec.of_Secondary_Nominations__c=2;
                recoListToInsert.add(rec);
            }
        
        for(String awardType : AwardTypeList ){
            Reward_And_Recognition__c rec = new Reward_And_Recognition__c();
            rec.Fiscal_Year__c = FY[0].Id;
            rec.Resource__c = MentorCon.Id;
            rec.Recognization_By__c = MenteeCon.EMS_TM_User__c;
            rec.RecordTypeId = RR_SCORING_RECORDTYPEID;
            rec.Status__c = 'Review In Progress';
            rec.Type__c = 'Annual Award';
            rec.Reason_for_award__c = 'Good Resource , Excellent Job';
            rec.Award_Type__c = awardType;
            rec.Primary_Nomination__c = true;
            rec.Nomination_Submitted__c = true;
            rec.of_Primary_Nominations__c =1;
            rec.of_Secondary_Nominations__c=2;
            recoListToInsert.add(rec);
        }

		for(String awardType : AwardTypeList ){
            Reward_And_Recognition__c rec = new Reward_And_Recognition__c();
            rec.Fiscal_Year__c = FY[0].Id;
            rec.Resource__c = MentorCon.Id;
            rec.Recognization_By__c = MenteeCon.EMS_TM_User__c;
            rec.RecordTypeId = RR_SCORING_RECORDTYPEID;
            rec.Status__c = 'Review In Progress';
            rec.Type__c = 'Annual Award';
            rec.Reason_for_award__c = 'Good Resource , Excellent Job';
            rec.Award_Type__c = 'Best Entrepreneur';
            rec.Primary_Nomination__c = true;
            rec.Nomination_Submitted__c = true;
            rec.of_Primary_Nominations__c =1;
            rec.of_Secondary_Nominations__c=2;
            recoListToInsert.add(rec);
        }
        
        system.debug('recoListToInsert value ' + recoListToInsert);
        Insert  recoListToInsert;
        try {
            BatchToUpdatePridcation batchExecute = new BatchToUpdatePridcation(); 
            Database.executeBatch(batchExecute,200);
        } catch (Exception ex) {
            String errorMsg = ex.getMessage();
            System.debug('An exception occurred: ' + errorMsg);
        }
        Test.stopTest();
    }
}