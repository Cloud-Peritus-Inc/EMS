@isTest
public class UpdateTheNomsBasedOnScoringTest {
    
    @testSetup
    static void setupTestData() {
        User adminuser = TestDataFactory.createAdminUser(true);         
        System.runAs(adminuser) {
            
            Account acc = TestDataFactory.createAccount(true);
            Contact con = TestDataFactory.createResourceContact(acc.Id, false);
            con.EMS_RM_Employee_Id__c = 'CP10234';
            con.Resource_Role__c = TestDataFactory.createResourceRole(true).Id;
            con.EMS_RM_ApplicantStatus_Update__c = 'Active';
            insert con;
            
            User u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
            con.EMS_TM_User__c = u.Id;
        	update con;
            
            Id scoringRecTypeId = Schema.SObjectType.Reward_And_Recognition__c.getRecordTypeInfosByName().get('Scoring').getRecordTypeId();
            Id nomRecTypeId = Schema.SObjectType.Reward_And_Recognition__c.getRecordTypeInfosByName().get('Nominations').getRecordTypeId();
            
            Reward_And_Recognition__c nomination = new Reward_And_Recognition__c();
            nomination.Resource__c = con.Id;
            nomination.Award_Type__c = 'Going Above and Beyond';
            nomination.RecordTypeId = nomRecTypeId;
            nomination.Status__c = 'Nominated';
            nomination.Type__c = 'Annual Award';
            nomination.Recognization_By_Text__c = 'Testing Employee1';
            insert nomination;
            
            Reward_And_Recognition__c scoring = new Reward_And_Recognition__c();
            scoring.Resource__c = con.Id;
            scoring.Award_Type__c = 'Going Above and Beyond';
            scoring.RecordTypeId = scoringRecTypeId;
            scoring.Status__c = 'Nominated'; 
            scoring.Reason_for_award__c = 'Test';
            scoring.Recognization_By_Text__c = 'Testing Employee1';
            insert scoring;
        }
    }
    
    @isTest
    static void testUpdateNominationToWinner() {
        
        Contact con = [SELECT Id FROM Contact WHERE EMS_RM_Employee_Id__c = 'CP10234' LIMIT 1];
        Reward_And_Recognition__c scoring = [SELECT Id, Status__c, Resource__c, Award_Type__c FROM Reward_And_Recognition__c WHERE RecordType.Name = 'Scoring' AND Resource__c = :con.Id LIMIT 1];
        Reward_And_Recognition__c nomination = [SELECT Id, Status__c FROM Reward_And_Recognition__c WHERE RecordType.Name = 'Nominations' AND Resource__c = :con.Id LIMIT 1];
        
        Test.startTest();
        scoring.Status__c = 'Winner';
        update scoring;
        Test.stopTest();
        
        nomination = [SELECT Status__c FROM Reward_And_Recognition__c WHERE Id = :nomination.Id];
        System.assertEquals('Winner', nomination.Status__c, 'Nomination status should be updated to Winner');
    }
    
    @isTest
    static void testUpdateNominationToNotQualified() {
        
        Contact con = [SELECT Id FROM Contact WHERE EMS_RM_Employee_Id__c = 'CP10234' LIMIT 1];
        Reward_And_Recognition__c scoring = [SELECT Id, Status__c, Resource__c, Award_Type__c FROM Reward_And_Recognition__c WHERE RecordType.Name = 'Scoring' AND Resource__c = :con.Id LIMIT 1];
        Reward_And_Recognition__c nomination = [SELECT Id, Status__c FROM Reward_And_Recognition__c WHERE RecordType.Name = 'Nominations' AND Resource__c = :con.Id LIMIT 1];
        
        Test.startTest();
        scoring.Status__c = 'Not Qualified';
        scoring.Lost_Reason__c = 'Did not meet criteria';
        update scoring;
        Test.stopTest();
        
        nomination = [SELECT Status__c, Lost_Reason__c FROM Reward_And_Recognition__c WHERE Id = :nomination.Id];
        System.assertEquals('Not Qualified', nomination.Status__c, 'Nomination status should be updated to Not Qualified');
        System.assertEquals('Did not meet criteria', nomination.Lost_Reason__c, 'Lost Reason should be updated');
    }
}