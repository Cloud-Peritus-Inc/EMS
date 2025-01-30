@IsTest
public class sendEmailToMentorTest {
    
    @testSetup
    static void setupTestData() {
        User adminuser = TestDataFactory.createAdminUser(true);         
        System.runAs(adminuser) {
            
            Account acc = TestDataFactory.createAccount(true);
            
            List<Contact> contactsToInsert = new List<Contact>();
            List<User> usersToInsert = new List<User>();
            
            for (Integer i = 1; i <= 3; i++) {
                Contact con = TestDataFactory.createResourceContact(acc.Id, false);
                con.EMS_RM_Employee_Id__c = 'CP10234 '+ i;
                con.Resource_Role__c = TestDataFactory.createResourceRole(true).Id;
                con.EMS_RM_ApplicantStatus_Update__c = 'Active';
                contactsToInsert.add(con);
            }
            insert contactsToInsert;
            
            for (Integer i = 0; i < contactsToInsert.size(); i++) {
                User u = TestDataFactory.createMultipleCommunityUserWithAccAndContact(acc.Id, contactsToInsert[i].Id, true);
                usersToInsert.add(u);
            }
            update usersToInsert;
            
            
            for (Integer i = 0; i < contactsToInsert.size(); i++) {
                contactsToInsert[i].EMS_TM_User__c = usersToInsert[i].Id;
            }
            update contactsToInsert;
            
            Goal__c goal = new Goal__c(
                Resource__c = contactsToInsert[0].Id
            );
            insert goal;
            
            Resource_Resource_Relationship__c rrr = new Resource_Resource_Relationship__c(
                Resource__c = contactsToInsert[0].Id,
                Resource_Reports_To__c = contactsToInsert[1].Id,
                Relationship_Type__c = 'Mentor'
            );
            insert rrr;
            
            PM_Configure__c pmConfig1 = new PM_Configure__c(
                Mentee__c = contactsToInsert[0].Id,
                Mentor__c = contactsToInsert[1].Id,
                Status__c = 'Awaiting Response',
                KRA__c = goal.Id,
                Reporting_Contact__c = contactsToInsert[2].Id
            );
            insert pmConfig1;
            
            PM_Configure__c pmConfig2 = new PM_Configure__c(
                Mentee__c = contactsToInsert[0].Id,
                Mentor__c = contactsToInsert[1].Id,
                Status__c = 'Awaiting Response',
                KRA__c = goal.Id,
                Reporting_Contact__c = contactsToInsert[2].Id
            );
            insert pmConfig2;
            
            List<PM_Configure__c> pmConfigs = [
                SELECT Id, Status__c 
                FROM PM_Configure__c 
                WHERE Id IN :new Set<Id>{pmConfig1.Id, pmConfig2.Id}
            ];
            
            if (!pmConfigs.isEmpty()) {
                pmConfigs[0].Status__c = 'Submitted';
                pmConfigs[1].Status__c = 'Rejected';
                
                update pmConfigs;
            }
        }
    }
    
    @isTest
    static void testSendEmail() {
        
        Contact mentor = [SELECT Id, Email FROM Contact WHERE EMS_RM_Employee_Id__c = 'CP10234 2' LIMIT 1];
        PM_Configure__c pmConfig = [SELECT Id, Status__c FROM PM_Configure__c WHERE Status__c = 'Submitted' LIMIT 1];
        
        Test.StartTest();
        sendEmailToMentor.sendEmail(mentor, pmConfig);
        Test.stopTest();
    }
    
    @isTest
    static void testOffshoreOnshoresendEmail() {
        
        PM_Configure__c pmConfig = [SELECT Id, Status__c FROM PM_Configure__c WHERE Status__c = 'Rejected' LIMIT 1];
        
        Test.StartTest();
        sendEmailToMentor.OffshoreOnshoresendEmail(pmConfig);
        Test.stopTest();
    }
}