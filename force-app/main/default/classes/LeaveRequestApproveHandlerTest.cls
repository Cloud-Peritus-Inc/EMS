@IsTest
public class LeaveRequestApproveHandlerTest {
@isTest
    public static void leaverequestmethod(){
        
         UserRole r =[Select Id from UserRole where Name = 'leadership'];
        Id sysAdminId = [select Id From Profile where Name ='System Administrator'].Id;
        Id communityId = [select Id From Profile where Name ='TM Customer Community'].Id;
        User u = [select Id, contactId, Email From User WHERE IsActive =True and ProfileId = :sysAdminId limit 1];
        system.debug(u);        
        System.runAs(u){
        contact c2 = new Contact();
        c2.FirstName = 'abcd';
        c2.LastName = 'efgh';
        c2.Official_Mail__c = u.Email;
        c2.EMS_Phone_Number__c = '8615748575';
        c2.Location__c ='India';
        c2.RecordTypeId = [SELECT Id FROM RecordType where name = 'Resource'].Id;
        c2.EMS_LM_User_1__c = u.Id;
        c2.EMS_LM_User2__c = u.Id;
        c2.EMS_TM_User__c = u.Id;
        c2.EMS_LM_Gender__c = 'Female';
        c2.EMS_LM_Marital_Status__c = 'Married';
        c2.EMS_EM_JD__c = system.today();
        c2.EMS_LM_No_of_Bereavement_Leaves_Credit__c = c2.EMS_LM_No_Of_Compensatory_Off_Credit__c = c2.EMS_LM_No_Of_Leaves_Credit__c = c2.EMS_LM_No_Of_Maternity_Leaves_Credit__c=c2.EMS_LM_No_Of_Paternity_Leaves_Credit__c = c2.EMS_LM_No_Of_Utilized_Bereavement_Leaves__c = c2.EMS_LM_No_OF_Utilized_Compensatory_Off__c = c2.EMS_LM_No_Of_Utilized_Leaves__c = c2.EMS_LM_No_Of_Utilized_Loss_Of_Pay__c = c2.EMS_LM_No_Of_Utilized_Maternity_Leaves__c = c2.No_Of_Utilized_Paternity_Leaves__c = 0;
        insert c2;  
        String cId = c2.Id;
        user us =new user();
        us.FirstName='bvhg';
        us.LastName='nbv';
        us.Email='bvhgnbv@gmail.com';
        us.Username='bvhgnbv@gmail.com.check';
        us.Alias='bvhgn'; 
        us.TimeZoneSidKey='America/Los_Angeles';
        us.LocaleSidKey='en_US'; 
        us.EmailEncodingKey='UTF-8'; 
        us.ProfileId= sysAdminId; 
        us.LanguageLocaleKey='en_US';
        us.UserRoleId = r.Id;
        insert us;
        Account acc = new Account(Name ='sriytbngvuoi',Phone='9457898547',ownerid = us.id);
        insert acc;
        /*acc = [select Id from Account where Name ='CP Test'];
        acc.Name ='sri12323434';
        acc.Phone='9652901511';
        acc.ownerid = us.id;
        insert acc;*/
        Contact c1 = new Contact();
        c1.FirstName = 'bvhg';
        c1.LastName = 'nbv';
        c1.Official_Mail__c = 'bvhgnbv@gmail.com';
        c1.EMS_Phone_Number__c = '8552748575';
        c1.Location__c ='India';
        c1.RecordTypeId = [SELECT Id FROM RecordType where name = 'Resource'].Id;
        c1.EMS_LM_User_1__c = us.Id;
        c1.EMS_LM_User2__c = us.Id;
        c1.EMS_TM_User__c = us.Id;
        c1.EMS_LM_Gender__c = 'Female';
        c1.EMS_LM_Marital_Status__c = 'Married';
        c1.EMS_EM_JD__c = system.today();
        c1.EMS_LM_Maternity_Leave__c = true;
        c1.EMS_LM_No_of_Bereavement_Leaves_Credit__c = c1.EMS_LM_No_Of_Compensatory_Off_Credit__c = c1.EMS_LM_No_Of_Leaves_Credit__c = c1.EMS_LM_No_Of_Maternity_Leaves_Credit__c=c1.EMS_LM_No_Of_Paternity_Leaves_Credit__c = c1.EMS_LM_No_Of_Utilized_Bereavement_Leaves__c = c1.EMS_LM_No_OF_Utilized_Compensatory_Off__c = c1.EMS_LM_No_Of_Utilized_Leaves__c = c1.EMS_LM_No_Of_Utilized_Loss_Of_Pay__c = c1.EMS_LM_No_Of_Utilized_Maternity_Leaves__c = c1.No_Of_Utilized_Paternity_Leaves__c = 0;
        insert c1;        
        Contact c = new Contact();
        c.FirstName = 'nbk';
        c.AccountId = acc.id;
        c.LastName = 'jj';
        c.Official_Mail__c = 'nbkjj121@gmail.com';
        c.EMS_Phone_Number__c = '8484158575';
        c.Location__c ='India';
        c.RecordTypeId = [SELECT Id FROM RecordType where name = 'Resource'].Id;
        c.EMS_LM_User_1__c = us.Id;
        c.EMS_LM_User2__c = us.Id;
        c.EMS_LM_Gender__c = 'Male';
        c.EMS_LM_Marital_Status__c = 'Married';
        c.EMS_EM_JD__c = system.today();
        c.EMS_LM_No_of_Bereavement_Leaves_Credit__c = c.EMS_LM_No_Of_Compensatory_Off_Credit__c = c.EMS_LM_No_Of_Leaves_Credit__c = c.EMS_LM_No_Of_Maternity_Leaves_Credit__c=c.EMS_LM_No_Of_Paternity_Leaves_Credit__c = c.EMS_LM_No_Of_Utilized_Bereavement_Leaves__c = c.EMS_LM_No_OF_Utilized_Compensatory_Off__c = c.EMS_LM_No_Of_Utilized_Leaves__c = c.EMS_LM_No_Of_Utilized_Loss_Of_Pay__c = c.EMS_LM_No_Of_Utilized_Maternity_Leaves__c = c.No_Of_Utilized_Paternity_Leaves__c = 0;
        insert c;
        user us1 =new user();
        us1.FirstName='nbk';
        us1.LastName='jj';
        us1.Email='nbkjj121@gmail.com';
        us1.Username='nbkjj121@gmail.com.check123';
        us1.Alias='nbkjj1'; 
        us1.TimeZoneSidKey='America/Los_Angeles';
        us1.LocaleSidKey='en_US'; 
        us1.EmailEncodingKey='UTF-8'; 
        us1.ProfileId= communityId; 
        us1.LanguageLocaleKey='en_US';
        us1.ContactId = c.Id;
        insert us1;
        c.EMS_TM_User__c = us1.Id;
        update c;
            
             Date startdate = system.today() + 5 ;
        String startd = string.valueOf(startdate);
        Date enddate = startdate + 4;
        String endd = string.valueOf(enddate);
        list<EMS_LM_Leave_History__c> leaveList =New list<EMS_LM_Leave_History__c>();
        list<Id> LeaveId =New List<Id>();
            
        EMS_LM_Leave_History__c lh2 = new EMS_LM_Leave_History__c();
        lh2.EMS_LM_Approver__c = us1.Id;
        lh2.EMS_LM_2nd_Approver__c = us1.Id;
        lh2.Approver_3__c = us1.Id;
        lh2.EMS_LM_Contact__c = c2.Id;
        lh2.EMS_LM_Leave_Duration__c = 2;
        lh2.EMS_LM_Leave_End_Date__c = enddate;
        lh2.EMS_LM_Leave_Start_Date__c = startdate;
        lh2.EMS_LM_Leave_Type_Name__c = 'Annual Leave';
        lh2.EMS_LM_Status__c='Pending';
        insert lh2;
        leaveList.add(lh2);
        LeaveId.add(lh2.Id);
        string LeaveRequestId2=lh2.Id;
            
        EMS_LM_Leave_History__c lh3 = new EMS_LM_Leave_History__c();
        lh3.EMS_LM_Approver__c = us1.Id;
        lh3.EMS_LM_2nd_Approver__c = us1.Id;
        lh3.Approver_3__c = us1.Id;
        lh3.EMS_LM_Contact__c = c2.Id;
        lh3.EMS_LM_Leave_Duration__c = 2;
        lh3.EMS_LM_Leave_End_Date__c = enddate;
        lh3.EMS_LM_Leave_Start_Date__c = startdate;
        lh3.EMS_LM_Leave_Type_Name__c = 'Annual Leave';
        lh3.EMS_LM_Status__c='Waiting For Approver 2';
        insert lh3;
        leaveList.add(lh3);
        LeaveId.add(lh3.Id);
        string LeaveRequestId3=lh3.Id;
            
        EMS_LM_Leave_History__c lh4 = new EMS_LM_Leave_History__c();
        lh4.EMS_LM_Approver__c = us1.Id;
        lh4.EMS_LM_2nd_Approver__c =us1.Id;
        lh4.Approver_3__c = us1.Id;
        lh4.EMS_LM_Contact__c = c2.Id;
        lh4.EMS_LM_Leave_Duration__c = 2;
        lh4.EMS_LM_Leave_End_Date__c = enddate;
        lh4.EMS_LM_Leave_Start_Date__c = startdate;
        lh4.EMS_LM_Leave_Type_Name__c = 'Annual Leave';
        lh4.EMS_LM_Status__c='Waiting For Approver 3';
        insert lh4;
        LeaveId.add(lh4.Id);
        string LeaveRequestId4=lh4.Id;
        test.startTest();
             
     //   LeaveRequestRejectHandler.updateRejecteStatusAndComments(leaveRequestId2, 'comments');
     //   LeaveRequestRejectHandler.updateRejecteStatusAndComments(LeaveRequestId3, 'comments');
     //   LeaveRequestRejectHandler.updateRejecteStatusAndComments(LeaveRequestId4, 'comments');
      //      LeaveRequestRejectHandler.bulkLeaveReqReject(LeaveId, 'comments');
            
            
        LeaveRequestApproveHandler.updateApproveStatusAndComments(leaveRequestId2, 'comments');
        LeaveRequestApproveHandler.updateApproveStatusAndComments(LeaveRequestId3, 'comments');
     //  List<LeaveRequestApproveHandler.LeaveRequestConstant> wrapperList = LeaveRequestApproveHandler.updateApproveStatusAndComments(LeaveRequestId4, 'comments');
        LeaveRequestApproveHandler.updateApproveStatusAndComments(LeaveRequestId4, 'comments');
        LeaveRequestApproveHandler.bulkLeaveReqApproval(LeaveId, 'comments');
        test.stopTest();
    	} 
}
}