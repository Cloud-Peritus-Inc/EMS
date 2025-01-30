@isTest
public class UpdateAverageRatingsOnKRATest {

    @testSetup
    static void setupTestData() {
        
        Resource_Role__c resourceRole = new Resource_Role__c(
            technical_acumen__c = 70,
            strategic_impact__c = 80,
            professional_skills__c = 75,
            goals_and_results__c = 85
        );
        insert resourceRole;
        
        Contact mentor = new Contact(LastName = 'Mentor', Resource_Role__c = resourceRole.id);
        Contact resource = new Contact(LastName = 'Resource', Resource_Role__c = resourceRole.id);
        insert new List<Contact> { mentor, resource };
        
        Goal__c goal = new Goal__c(
            Goal_Name__c = 'FQ1 FY 2024',
            Resource__c = resource.Id,
            Status__c = 'In Progress' 
        );
        insert goal;
        
        PM_Configure__c relatedQuestion = new PM_Configure__c(
            Area__c = 'TECHNICAL SKILLS',
            RecordTypeId = Schema.SObjectType.PM_Configure__c.getRecordTypeInfosByName().get('Answer').getRecordTypeId()
        );
        insert relatedQuestion;
        
        PM_Configure__c pmConfig = new PM_Configure__c(
            KRA__c = goal.Id,
            Related_Question__c = relatedQuestion.Id, 
            Rating__c = 4.5,
            Mentor_Mentee__c = mentor.Id,
            Mentee__c = resource.Id,
            Status__c = 'Submitted', 
            RecordTypeId = Schema.SObjectType.PM_Configure__c.getRecordTypeInfosByName().get('Answer').getRecordTypeId()
        );
        insert pmConfig;
    }

    @isTest
    static void testBeforeUpdate() {
        List<Goal__c> goalList = [SELECT Id, Status__c FROM Goal__c LIMIT 1];
        Goal__c goalToUpdate = goalList[0];
        goalToUpdate.Status__c = 'KRA Completed';

        Test.startTest();
        update goalToUpdate; 
        Test.stopTest();
        
        Goal__c updatedGoal = [SELECT Average_Technical_Skills_Rating__c, 
                               Average_Professional_Skills_Rating__c,
                               Average_Strategic_Impact_Rating__c,
                               Average_Goals_And_Result_Rating__c
                               FROM Goal__c
                               WHERE Id = :goalToUpdate.Id
                               LIMIT 1];
        System.debug('updatedGoal '+updatedGoal.Average_Technical_Skills_Rating__c);
        System.assertEquals(3.15, updatedGoal.Average_Technical_Skills_Rating__c, 'Average Technical Skills Rating should be 3.15');
    }

    @isTest
    static void testNoUpdateWhenStatusNotChanged() {
        List<Goal__c> goalList = [SELECT Id, Status__c FROM Goal__c LIMIT 1];
        Goal__c goalToUpdate = goalList[0];

        Test.startTest();
        update goalToUpdate; 
        Test.stopTest();
        
        Goal__c updatedGoal = [SELECT Average_Technical_Skills_Rating__c 
                               FROM Goal__c 
                               WHERE Id = :goalToUpdate.Id 
                               LIMIT 1];
        
        System.assertEquals(null, updatedGoal.Average_Technical_Skills_Rating__c, 'Average ratings should not be updated');
    }
}