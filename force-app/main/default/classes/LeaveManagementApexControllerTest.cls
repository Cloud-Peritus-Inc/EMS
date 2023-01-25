@isTest
public class LeaveManagementApexControllerTest {
    
    public static testMethod void testGetLeaveManagement() {
        
          UserRole r =[Select Id from UserRole where Name = 'leadership'];
        Id sysAdminId = [select Id From Profile where Name ='System Administrator'].Id;
        Id communityId = [select Id From Profile where Name ='TM Customer Community'].Id;
        User u = [select Id, contactId,ContactId__c, Email From User WHERE IsActive =True and ProfileId = :communityId limit 1];
     //   Contact empLeaveBalance = [SELECT Id,EMS_LM_No_Of_Availble_Leaves__c FROM Contact WHERE Id =: u.ContactId__c ];
       
        contact c2 = new Contact();
        c2.FirstName = 'ab123';
        c2.LastName = 'efgh';
        c2.Official_Mail__c = u.Email;
        c2.EMS_Phone_Number__c = '8615748522';
        c2.Location__c ='India';
        c2.RecordTypeId = [SELECT Id FROM RecordType where name = 'Resource'].Id;
        c2.EMS_LM_User_1__c = u.Id;
        c2.EMS_LM_User2__c = u.Id;
        c2.EMS_TM_User__c = u.Id;
        c2.EMS_LM_Gender__c = 'Female';
        c2.EMS_LM_Marital_Status__c = 'Married';
        c2.EMS_LM_Maternity_Leave__c = true;
        c2.EMS_EM_JD__c = system.today();
        insert c2;  
        Date startdate = system.today() + 5 ;
        String startd = string.valueOf(startdate);
        Date enddate = startdate + 4;
        String endd = string.valueOf(enddate);
        EMS_LM_Leave_History__c lh2 = new EMS_LM_Leave_History__c();
        lh2.EMS_LM_2nd_Approver__c = u.Id;
        lh2.EMS_LM_Approver__c = u.Id;
        lh2.EMS_LM_Contact__c = c2.Id;
        lh2.EMS_LM_Leave_Duration__c = 5;
        lh2.EMS_LM_Leave_End_Date__c = enddate;
        lh2.EMS_LM_Leave_Start_Date__c = startdate;
        lh2.EMS_LM_Leave_Type_Name__c = 'Compensatory Off';
        insert lh2;
        string leaveId =lh2.Id;
        test.startTest();
        LeaveManagementApexController.getLeaveRequest();
        LeaveManagementApexController.getLeaveRequestHr();
       LeaveManagementApexController.cancleLeaveRequest(leaveId);
        // LeaveManagementApexController.leaveBanlance();
        test.stopTest();
    }

}