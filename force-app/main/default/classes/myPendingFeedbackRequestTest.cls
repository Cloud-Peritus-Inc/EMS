@isTest
public class myPendingFeedbackRequestTest {

    @testSetup
    static void setupData() {
        
        User accountOwner = [SELECT Id, Name, UserRoleId FROM User WHERE IsActive = true AND UserRoleId != NULL LIMIT 1];
        
        Account account = new Account(
            Name = 'Test Account',
            OwnerId = accountOwner.Id 
        );
        insert account;
         Id contactResourceId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Resource').getRecordTypeId();

        Contact contact = new Contact(LastName = 'Test Contact',AccountId = account.Id,RecordTypeId = contactResourceId);
        insert contact;

        User testUser = new User(
            Username = 'testuser@test22.com',
            LastName = 'Test',
            Email = 'testuser@test.com',
            Alias = 'test',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Employee - HR(Community)'].Id,
            LanguageLocaleKey = 'en_US',
            ContactId = contact.Id
        );
        
        System.runAs(accountOwner) {
            insert testUser;
        }
        
        Goal__c goal1 = new Goal__c(Goal_Name__c = 'FQ1 FY 2024',Resource__c = testUser.ContactId);
        insert new List<Goal__c>{goal1};

        
        Id AnswerRecordTypeId = Schema.SObjectType.PM_Configure__c.getRecordTypeInfosByName().get('Answer').getRecordTypeId();
        List<Contact> contactsToInsert = new List<Contact>();
        
        for (Integer i = 1; i <= 2; i++) {
            
            Contact newContact = new Contact(
                LastName = 'User' + i,
                EMS_TM_User__c = UserInfo.getUserId(),
                Email = 'mentee' + i +'@example.com'
            );
            
            contactsToInsert.add(newContact);
        }
        insert contactsToInsert;

        EMS_TM_Project__c project1 = new EMS_TM_Project__c(Name = 'Project 1',
                                                           EMS_TM_EndDate__c = Date.today().addMonths(6), 
                                                           EMS_TM_StartDate__c = Date.today(), 
                                                           Project_Manager__c = contactsToInsert[0].Id, 
                                                           Type_Of_Project__c = 'Internal Projects', 
                                                           Offshore_Project_Manager__c = contactsToInsert[1].Id
                                                          );
        
        insert new List<EMS_TM_Project__c>{project1};
        
        PM_Configure__c pmConfig1 = new PM_Configure__c(
            KRA__c = goal1.Id,
            Project_Name__c = project1.Id,
            Reporting_Contact__c = contact.Id,
            Status__c = 'Awaiting Response',
            RecordTypeId = AnswerRecordTypeId
        );

        insert new List<PM_Configure__c>{pmConfig1};

        
        EMS_TM_Assignment__c assignment1 = new EMS_TM_Assignment__c(
            EMS_TM_ProjectName_Asgn__c = project1.Id,
            EMS_TM_EmployeeName__c = testUser.ContactId,
            EMS_TM_StartDate_Asgn__c = Date.today(),
            EMS_TM_EndDate_Asgn__c = Date.today().addMonths(6),
            EMS_TM_AssignedAs__c = 'Administrator', 
            Project_Allocation__c = 1
        );

        insert new List<EMS_TM_Assignment__c>{assignment1};
    }

    @isTest
    static void testGetKRARecordsOfContact() {
        
        User testUser = [SELECT Id, ContactId FROM User WHERE Username = 'testuser@test22.com' LIMIT 1];
        System.runAs(testUser) {
            
            List<myPendingFeedbackRequest.goalWrapper> result = myPendingFeedbackRequest.getKRARecordsOfContact();

            
            System.assertNotEquals(0, result.size(), 'Expected KRA records to be returned');
            for (myPendingFeedbackRequest.goalWrapper gw : result) {
                System.assertNotEquals(null, gw.goalName, 'Goal name should not be null');
                System.assertNotEquals(null, gw.ProjectName, 'Project name should not be null');
                System.assertNotEquals(null, gw.resourceName, 'Resource name should not be null');
            }
        }
    }

    @isTest
    static void testUpdatePMConfigureRecord() {
        
        User testUser = [SELECT Id, ContactId FROM User WHERE Username = 'testuser@test22.com' LIMIT 1];
        
        
        PM_Configure__c pmConfig = [SELECT Id, KRA__c, Project_Name__c, KRA__r.Resource__c, Status__c 
                                    FROM PM_Configure__c 
                                    WHERE Status__c = 'Awaiting Response' 
                                    LIMIT 1];
        
        System.runAs(testUser) {
            List<myPendingFeedbackRequest.goalWrapper> result = myPendingFeedbackRequest.updatePMConfigureRecord(
                pmConfig.Project_Name__c, pmConfig.KRA__c, pmConfig.KRA__r.Resource__c, 'accept', null
            );
        }
        
        PM_Configure__c updatedConfig = [SELECT Status__c FROM PM_Configure__c WHERE Id = :pmConfig.Id];
       
        System.assertEquals('Accepted', updatedConfig.Status__c, 'Expected the status to be updated to Accepted');
    }
}