/**
* @author Suneel and Rakshitha 
* @date 11/01/2023
* @description  This Test class is used for leave balance updating after utilized leaves
*            
*
*               
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
@isTest
public class CP_utilizedLeaveBalanceTest {

    public static testmethod void utilizedLeaveBalanceCalculationTest(){
        /*
        Resource_Role__c role = TestDataFactory.createResourceRole(true);
        Account acc = TestDataFactory.createAccount(true);
        
        
        
         EMS_LM_Leave__c  annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
            EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
            EMS_LM_Leave__c paidTimeOff = TestDataFactory.createLeaveType('Paid time off',true);
            EMS_LM_Leave__c Bereavement = TestDataFactory.createLeaveType('Bereavement Leave',true);
       Contact con = new Contact();
        con.lastName = 'Test';
        con.EMS_Phone_Number__c = '8645823254';
        con.Official_Mail__c = null;
        con.Email = 'test@gmail.com';
        insert con;
        List<EMS_LM_Leave_History__c> leaveHistoryList = new List<EMS_LM_Leave_History__c>();
        List<EMS_LM_Leave_History__c> leaveHistoryOldList = new List<EMS_LM_Leave_History__c>();
         EMS_LM_Leave_History__c leaveHistory = new EMS_LM_Leave_History__c(); 
            leaveHistory.EMS_LM_Contact__c = con.Id;
            leaveHistory.EMS_LM_Day__c = 'Full Day';
            leaveHistory.EMS_LM_Leave_Start_Date__c = date.parse('1/23/2024');
            leaveHistory.EMS_LM_Leave_End_Date__c = date.parse('1/23/2024');
            leaveHistory.EMS_LM_Leave_Type__c = [SELECT Id FROM EMS_LM_Leave__c WHERE Name = 'Annual Leave'].Id;
            leaveHistory.EMS_LM_Leave_Duration__c = 1;
            leaveHistory.EMS_LM_Reason__c = 'Test Reason';
            leaveHistory.EMS_LM_Status__c =  'Pending';
            leaveHistory.EMS_LM_Leave_Type_Name__c = 'Annual Leave';
            insert leaveHistory;
              Test.setCreatedDate(leaveHistory.Id, DateTime.newInstance(2024,01,01));
                system.debug('leaveHistory leaveHistory '+leaveHistory);

        system.debug('leaveHistory creadted '+leaveHistory.CreatedDate);
         system.debug('leaveHistory type '+leaveHistory.Leave_Type_Name__c);
        
        EMS_LM_Leave_History__c leaveHistoryOld = new EMS_LM_Leave_History__c();
        leaveHistoryOld.EMS_LM_Leave_Type_Name__c = 'Paid time off';
        leaveHistoryOld.EMS_LM_Status__c = 'Pending';
        leaveHistoryOld.EMS_LM_Leave_Duration__c = 5;
        leaveHistoryOld.EMS_LM_Contact__c = con.Id;
        leaveHistoryOld.EMS_LM_Leave_End_Date__c = date.parse('1/5/2024');
        leaveHistoryOld.EMS_LM_Leave_Start_Date__c = date.parse('5/5/2024');
        insert leaveHistoryOld;
        EMS_LM_Leave_History__c leaveHistory1 = new EMS_LM_Leave_History__c();
        leaveHistory1.EMS_LM_Leave_Type_Name__c = 'Bereavement Leave';
        leaveHistory1.EMS_LM_Status__c = 'Approved';
        leaveHistory1.EMS_LM_Leave_Duration__c = 5;
        leaveHistory1.EMS_LM_Contact__c = con.Id;
        leaveHistory1.EMS_LM_Leave_End_Date__c = date.parse('6/5/2024');
        leaveHistory1.EMS_LM_Leave_Start_Date__c = date.parse('7/5/2024');
        insert leaveHistory1;
        leaveHistoryOldList.add(leaveHistoryOld);
        leaveHistoryList.add(leaveHistory);
        leaveHistoryList.add(leaveHistory1);
        test.startTest();
        CP_utilizedLeaveBalance.utilizedLeaveBalanceCalculation(leaveHistoryList);
        CP_utilizedLeaveBalance.afterUpdate(leaveHistoryList,leaveHistoryOldList);
        CP_utilizedLeaveBalance.leaveCheck();
        test.stopTest(); 
       */ 
        
    }

}