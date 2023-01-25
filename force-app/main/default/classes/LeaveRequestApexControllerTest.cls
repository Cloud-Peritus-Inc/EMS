/**
* @author Pavan 
* @date 11/01/2023
* @description  Method used to display leave request data based on the loggedIn approver user
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
public class LeaveRequestApexControllerTest {
    @testSetup
    static void testDataSetup(){
        //Contact Data
        List<Contact> testConList = new List<Contact>();
        for (Integer i=0; i < 3; i++){
            contact testConData = new Contact(LastName = 'Test con' +i,
                                              Location__c = 'India',
                                              EMS_Phone_Number__c = '123647890',
                                              Email = 'test@gmail.com');
            testConList.add(testConData);
        }
        insert testConList;
        //Leave Request Data
        List<EMS_LM_Leave_History__c> testLeaveRequestPendingList = new List<EMS_LM_Leave_History__c>();
        List<EMS_LM_Leave_History__c> testLeaveRequestApprover2List = new List<EMS_LM_Leave_History__c>();
        List<EMS_LM_Leave_History__c> testLeaveRequestApprover3List = new List<EMS_LM_Leave_History__c>();
        for (Integer i = 0; i < 2; i++) {
            EMS_LM_Leave_History__c testLeaveRequest = new EMS_LM_Leave_History__c(EMS_LM_Contact__c = testConList[0].Id, 
                                                                                   EMS_LM_Reason__c = 'Test Reason'+i, 
                                                                                   EMS_LM_Leave_Start_Date__c = Date.today(), 
                                                                                   EMS_LM_Leave_End_Date__c = Date.today()+1, 
                                                                                   EMS_LM_Leave_Duration__c = 1,
                                                                                   EMS_LM_Approver__c = UserInfo.getUserId(), 
                                                                                   EMS_LM_2nd_Approver__c = UserInfo.getUserId(),
                                                                                   Approver_3__c = UserInfo.getUserId(),
                                                                                   EMS_LM_Status__c = 'Pending');
            testLeaveRequestPendingList.add(testLeaveRequest);
        }
        for (Integer i = 0; i < 2; i++) {
            EMS_LM_Leave_History__c testLeaveRequest = new EMS_LM_Leave_History__c(EMS_LM_Contact__c = testConList[1].Id, 
                                                                                   EMS_LM_Reason__c = 'Test Reason'+i, 
                                                                                   EMS_LM_Leave_Start_Date__c = Date.today(), 
                                                                                   EMS_LM_Leave_End_Date__c = Date.today()+3, 
                                                                                   EMS_LM_Leave_Duration__c = 3,
                                                                                   EMS_LM_Approver__c = UserInfo.getUserId(), 
                                                                                   EMS_LM_2nd_Approver__c = UserInfo.getUserId(),
                                                                                   Approver_3__c = UserInfo.getUserId(),
                                                                                   EMS_LM_Status__c = 'Waiting For Approver 2');
            testLeaveRequestApprover2List.add(testLeaveRequest);
        }
        for (Integer i = 0; i < 2; i++) {
            EMS_LM_Leave_History__c testLeaveRequest = new EMS_LM_Leave_History__c(EMS_LM_Contact__c = testConList[1].Id, 
                                                                                   EMS_LM_Reason__c = 'Test Reason'+i, 
                                                                                   EMS_LM_Leave_Start_Date__c = Date.today(), 
                                                                                   EMS_LM_Leave_End_Date__c = Date.today()+3, 
                                                                                   EMS_LM_Leave_Duration__c = 3,
                                                                                   EMS_LM_Approver__c = UserInfo.getUserId(), 
                                                                                   EMS_LM_2nd_Approver__c = UserInfo.getUserId(),
                                                                                   Approver_3__c = UserInfo.getUserId(),
                                                                                   EMS_LM_Status__c = 'Waiting For Approver 3');
            testLeaveRequestApprover3List.add(testLeaveRequest);
        }
        insert testLeaveRequestPendingList;
        insert testLeaveRequestApprover2List;
        insert testLeaveRequestApprover3List;
    }
    static testMethod void testGetLeaveReqData() {
        LeaveRequestApexController.LeaveRequestStatus result = LeaveRequestApexController.getLeaveReqData();
        System.assertEquals(result.pendingList.size(), 2, 'Failed in pendingList LeaveRequestApexController');
        System.assertEquals(result.approver2List.size(), 2, 'Failed in approver2List LeaveRequestApexController');
        System.assertEquals(result.approver3List.size(), 2 , 'Failed in approver3List LeaveRequestApexController');
    }
}