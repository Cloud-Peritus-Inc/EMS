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
       Contact con = new Contact();
        con.lastName = 'Test';
        con.EMS_Phone_Number__c = '8645823254';
        con.Official_Mail__c = null;
        con.Email = 'test@gmail.com';
        insert con;
        List<EMS_LM_Leave_History__c> leaveHistoryList = new List<EMS_LM_Leave_History__c>();
        List<EMS_LM_Leave_History__c> leaveHistoryOldList = new List<EMS_LM_Leave_History__c>();
        EMS_LM_Leave_History__c leaveHistory = new EMS_LM_Leave_History__c();
        leaveHistory.EMS_LM_Leave_Type_Name__c = 'Annual Leave';
        leaveHistory.EMS_LM_Status__c = 'Approved';
        leaveHistory.EMS_LM_Leave_Duration__c = 3;
        leaveHistory.EMS_LM_Contact__c = con.Id;
        leaveHistory.EMS_LM_Leave_End_Date__c = date.parse('1/20/2023');
        leaveHistory.EMS_LM_Leave_Start_Date__c = date.parse('1/23/2023');
        insert leaveHistory;
        EMS_LM_Leave_History__c leaveHistoryOld = new EMS_LM_Leave_History__c();
        leaveHistoryOld.EMS_LM_Leave_Type_Name__c = 'Bereavement Leave';
        leaveHistoryOld.EMS_LM_Status__c = 'Approved';
        leaveHistoryOld.EMS_LM_Leave_Duration__c = 5;
        leaveHistoryOld.EMS_LM_Contact__c = con.Id;
        leaveHistoryOld.EMS_LM_Leave_End_Date__c = date.parse('1/5/2023');
        leaveHistoryOld.EMS_LM_Leave_Start_Date__c = date.parse('5/5/2023');
        insert leaveHistoryOld;
        EMS_LM_Leave_History__c leaveHistory1 = new EMS_LM_Leave_History__c();
        leaveHistory1.EMS_LM_Leave_Type_Name__c = 'Bereavement Leave';
        leaveHistory1.EMS_LM_Status__c = 'Approved';
        leaveHistory1.EMS_LM_Leave_Duration__c = 5;
        leaveHistory1.EMS_LM_Contact__c = con.Id;
        leaveHistory1.EMS_LM_Leave_End_Date__c = date.parse('1/5/2023');
        leaveHistory1.EMS_LM_Leave_Start_Date__c = date.parse('5/5/2023');
        insert leaveHistory1;
        leaveHistoryOldList.add(leaveHistoryOld);
        leaveHistoryList.add(leaveHistory);
        leaveHistoryList.add(leaveHistory1);
        test.startTest();
        CP_utilizedLeaveBalance.utilizedLeaveBalanceCalculation(leaveHistoryList);
        CP_utilizedLeaveBalance.afterUpdate(leaveHistoryList,leaveHistoryOldList);
        test.stopTest();
        
        
    }
}