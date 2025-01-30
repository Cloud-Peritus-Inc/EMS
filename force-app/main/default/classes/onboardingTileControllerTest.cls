@isTest
public class onboardingTileControllerTest {
    public static final Id Goal_Recordtype_Id = Schema.SObjectType.Goal__c.getRecordTypeInfosByDeveloperName().get('Goal').getRecordTypeId();
    public testmethod static void onboardingTileControllerMethod(){
        Task newTask = new Task(
            Status = 'Completed',
            Onboarding_UniqueKey__c = 'POS003',
            Subject = 'Testing',
            OwnerId = Userinfo.getUserId(),
            ActivityDate = system.today().addDays(2),
            Requires_Navigation__c = True
        );
        insert newTask;
        
        Task newTask1 = new Task(
            Status = 'Completed',
            Offboarding_UniqueKey__c = 'OFF00001',
            Subject = 'Testing',
            OwnerId = Userinfo.getUserId(),
            ActivityDate = system.today().addDays(2),
            Requires_Navigation__c = True
        );
        insert newTask1;
        
        user urec = [SELECT Id,ContactId FROM User WHERE Id=:Userinfo.getUserId()];
        
        Goal__c goalRec = new Goal__c();
        goalRec.Status__c = 'Active';
        goalRec.Resource__c = urec.ContactId;
        goalRec.RecordTypeId = Goal_Recordtype_Id;
        goalRec.Description__c = 'Test Description';
        goalRec.End_Date__c = System.today().addDays(10);
        goalRec.is_Navigation_Required__c = True;
        goalRec.Navigation_address__c = 'Test';
        goalRec.Type__c = 'Org Level Goal';
        insert goalRec;
        
        Goal__c goalRec1 = new Goal__c();
        goalRec1.Status__c = 'Completed';
        goalRec1.Resource__c = urec.ContactId;
        goalRec1.RecordTypeId = Goal_Recordtype_Id;
        goalRec1.Description__c = 'Test Description1';
        goalRec1.End_Date__c = System.today().addDays(10);
        goalRec1.is_Navigation_Required__c = True;
        goalRec1.Navigation_address__c = 'Test1';
        insert goalRec1;
        
        Test.startTest();
        onboardingTileController.getMyOnboardingTasks();
        onboardingTileController.getoffboardingTasks();
        onboardingTileController.updateTheTaskasComplete(newTask1.id);
        onboardingTileController.getMyActiveGoals();
        onboardingTileController.updateTheGoal(goalRec1.Id);
        onboardingTileController.getTheCurrentGoals();
        Test.stopTest();
    }
    
}