@istest
public class CP_TasksChecklistUpdateTest {
    public static testMethod  void afterUpdateTest(){
        EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
        EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
        EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
  EMS_LM_Leave__c paidtimeof = TestDataFactory.createLeaveType('Paid time off',true);
               EMS_LM_Leave__c unpaidTimeOff = TestDataFactory.createLeaveType('UnPaid time off',true);
               EMS_LM_Leave__c floatingholiday = TestDataFactory.createLeaveType('Floating Holiday',true);        
        account acc=TestDataFactory.createAccount(True);
        
        Office_Location__c officlocRec =TestDataFactory.createOfficeLocation('Hyderabad - India',true);
        Office_Location__c officlocRec2 =TestDataFactory.createOfficeLocation('California - USA',true);
        
        contact con=TestDataFactory.createResourceContact(acc.Id,True);
 
        Task newTask = new Task(
            WhoId = con.Id,
            //Status = 'Completed',
            Status = 'In Progress',
            Onboarding_UniqueKey__c = 'uni001'
        );
        
        List<Task> taskList = new List<Task>{newTask};
        insert taskList;
        Task oldTask = new Task(
            Id = newTask.Id,
            WhoId = con.Id,
            //Status = 'In Progress',
            Status = 'Completed',
            Onboarding_UniqueKey__c = 'uni001'
        );
        List<Task> oldTaskList = new List<Task>{oldTask};
        update oldTaskList;
        Map<Id, Task> oldTaskMap = new Map<Id, Task>{oldTask.Id => oldTask};
            
        Map<string,set<String>> taskWithUniqueKeyMap = new Map<string,set<String>>();
        taskWithUniqueKeyMap.put(oldTask.Onboarding_UniqueKey__c,new Set<String>{oldTask.WhoId});
        
        Test.startTest();
        CP_TasksChecklistUpdate updateAction = new CP_TasksChecklistUpdate();
        updateAction.updateContactRec(taskList, oldTaskMap);
        Test.stopTest();
 
    }
}