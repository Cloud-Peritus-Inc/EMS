@isTest public class Exception_LogTriggerTest {
    @testsetup static void setup() {
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
    }
    @isTest public static void testFirst() {
        List<Account> accList = new List<Account>();
        Account acc = getAccountRecord('Test');
        acc.Name = 'Test';
        accList.add(acc);
        
        String strAcc = JSON.serialize(accList);
        
        Exception_Log__c exception_log = new Exception_Log__c(
            ClassName__c = 'CDLCallBackCreation',
            ContextUser__c = Userinfo.getUserId(), ConvertedToDefect__c = false,
            ExceptionDescription__c =
            'Insert failed. First exception on row 0; first error: CANNOT_EXECUTE_FLOW_TRIGGER, We can\'t save thi',
            ExceptionDetails__c =
            'System.DmlException:Insert failed. First exception on row 0; first error: CANNOT_EXECUTE_FLOW_TRIGGER, We can\'t save this record because the “Event 1” process failed. Give your Salesforce admin these details. <b>An unhandled fault has occurred in this flow</b><br>An unhandled fault has occurred while processing the flow.  Please contact your system administrator for more information. Error ID: 1265650124-79949 (-374067804)ase contact your system administrator for more information. Error ID: 1265650124-79949 (-374067804): []Class.CDLCallBackCreation.createCallBackRecord: line 100, column 1',
            ExceptionType__c = 'System.DmlException',
            ExceptionLogTimestamp__c =
            DateTime.newInstance(2021, 8, 18, 17, 1054, 63244),
            IsHandled__c = false, MethodName__c = 'createCallBackRecord',
            NumberOfTimesOccured__c = 1.0, Status__c = 'Raised',
            Data_Log__c = strAcc, Objects__c = 'Account',
            Exception_Retry_Complete__c = false, Exception_Resolved__c = false,
            Priority__c = 'High', Retry_Count__c = 0.0,
            High_Priority_triggered__c = true, Bypass_Retry_Exception__c = false);
        insert exception_log;

        Exception_Log__c exception_logUpdated = [SELECT id,
                                                 name,
                                                 Exception_Resolved__c
                                                 FROM Exception_Log__c
                                                 WHERE id =:exception_log.Id ];
    }

    public static Account getAccountRecord(String name) {
            return [SELECT id,
                    Name
                    FROM Account
                    WHERE Name =:name ];
        }
}