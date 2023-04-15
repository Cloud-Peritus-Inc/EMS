@istest
public class CP_TasksChecklistUpdateTest {
    public static testMethod  void afterUpdateTest(){
        EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
        EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
        EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
        
        account acc=TestDataFactory.createAccount(True);
        
        contact con=TestDataFactory.createResourceContact(acc.Id,True);
 
        Task newTask = new Task(
            WhoId = con.Id,
            Status = 'In Progress',
            Onboarding_UniqueKey__c = 'PRE003',
            Subject = 'Testing'
            
        );
        
        Task newTask2 = new Task(
            WhoId = con.Id,
            Status = 'In Progress',
            Onboarding_UniqueKey__c = 'PRE004',
            Subject = 'Testing2'
            
        );
        
        List<Task> taskList = new List<Task>{newTask};
        insert taskList;
        insert newTask2;
        newTask2.Status = 'Completed';
        update newTask2;
        newTask.Status = 'Completed';
        update newTask;
        
    }
}