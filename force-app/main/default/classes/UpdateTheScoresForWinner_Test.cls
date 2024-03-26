@isTest
public class UpdateTheScoresForWinner_Test {
    
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
            resourceRoleList[0].Eligible_for_Nominations__c = true;
            resourceRoleList[0].Eligible_for_Recognise__c = true;
            insert resourceRoleList;
            
            
            for(Integer i=0; i<2; i++){
                con =TestDataFactory.createResourceContact(acc.id, false);
                con.EMS_RM_Employee_Id__c = 'CP1098'+i;
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
            
            rrr = TestDataFactory.createRRR(contactList[0].Id, true, contactList[1].Id);
            
            Fulfillment__c Ful = TestDataFactory.createFulfillment(contactList[0].Id, true);
            Grid_Configuration__c gc = new Grid_Configuration__c();
            gc.Name = 'Annual Awards Noms FY FY 2023 - 2024';
            gc.Fiscal_Year__c = Ful.Fiscal_Year__c;
            gc.Grid_Configuration_Type__c = 'Annual Award Result';
            insert gc;
            
            EMS_TM_Project__c project = new EMS_TM_Project__c(); 
            project.Type_Of_Project__c ='Client Projects';
            project.Name ='Demo';
            project.EMS_TM_Status__c = 'Ongoing';
            project.EMS_TM_StartDate__c = System.today();
            project.Project_Manager__c=contactList[1].Id;
            project.Offshore_Project_Manager__c=contactList[1].Id;
            project.EMS_TM_EndDate__c=System.today().addDays(10);
            insert project;
            
            EMS_TM_Project__c project2 = new EMS_TM_Project__c(); 
            project2.Type_Of_Project__c ='Client Projects';
            project2.Name ='Demo';
            project2.EMS_TM_Status__c = 'Ongoing';
            project2.EMS_TM_StartDate__c = System.today();
            project2.Project_Manager__c=contactList[0].Id;
            project2.Offshore_Project_Manager__c=contactList[0].Id;
            project2.EMS_TM_EndDate__c=System.today().addDays(10);
            insert project2;
            
            List<EMS_TM_Assignment__c> Assignments = TestDataFactory.createProjectAssignee(contactList[0].Id,project.Id,true);   
            List<EMS_TM_Assignment__c> Assignments2 = TestDataFactory.createProjectAssignee(contactList[1].Id,project2.Id,true);   
        }
    }
    
    public testmethod static void updateTheScoresForWinnerMethod(){
        List<Fiscal_Year__c> FY = [Select Id,Name FROM Fiscal_Year__c LIMIT 1];
        Contact MenteeCon = [Select Id,Name,EMS_RM_Employee_Id__c,EMS_TM_User__c From Contact WHERE EMS_RM_Employee_Id__c = 'CP10980'];
        Contact MentorCon = [Select Id,Name,EMS_RM_Employee_Id__c,EMS_TM_User__c From Contact WHERE EMS_RM_Employee_Id__c = 'CP10981'];
        User MenteeUser = [Select Id,Name from User where Id=:MenteeCon.EMS_TM_User__c];
        User MentorUser = [Select Id,Name from User where Id=:MentorCon.EMS_TM_User__c];
        List<String> AwardTypeList = new List<String>{'Best Entrepreneur', 'Most Professional', 'Rising Star', 'Rock Star', 'Shining Star', 'Going Above and Beyond', 'Award of Excellence'};
            List<Reward_And_Recognition__c> recoListToInsert = New List<Reward_And_Recognition__c>();
        List<Reward_And_Recognition__c> recoListToUpdate = New List<Reward_And_Recognition__c>();
        
        //SCORING_RECORDTYPE records 
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
            recoListToInsert.add(rec);
        }
        insert recoListToInsert;
        
        // Update records
        for (Reward_And_Recognition__c recToUpdate : recoListToInsert) {
            if(recToUpdate.Award_Type__c =='Best Entrepreneur'){
                recToUpdate.Status__c = 'Winner';
            }else if(recToUpdate.Award_Type__c =='Most Professional'){
                recToUpdate.Status__c = 'Review In Progress';
            }else{
                recToUpdate.Award_Type__c = 'Best Entrepreneur';
                recToUpdate.Status__c = 'Review In Progress';
            }
            recoListToUpdate.add(recToUpdate);
        }
        
        Update recoListToUpdate;
    }
    
}