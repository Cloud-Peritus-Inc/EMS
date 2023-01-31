@isTest
public class LeaveCalculateHandler_Test {
    
    @istest
    public static void leaveCalculatemethod(){
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
        EMS_TM_Calendar__c ec = new EMS_TM_Calendar__c();
        Date d = system.today() + 6;
		ec.EMS_TM_Calendar_Date__c = d;
		ec.Name = 'Test1234';
		ec.Location__c = 'India';
		ec.EMS_TM_Type_Of_Holiday__c = 'National';        

        EMS_LM_Leave_Credit__c lc1 = new EMS_LM_Leave_Credit__c();
        lc1.EMS_LM_Employee__c = c.Id;
        lc1.EMS_LM_Leave_Credited_Date__c = system.today();
        lc1.EMS_LM_Leaves_Credited__c = 5;
        lc1.EMS_LM_Select_Leave_Type__c = 'Paternity Leave';
        insert lc1;
        EMS_LM_Leave_Credit__c lc2 = new EMS_LM_Leave_Credit__c();
        lc2.EMS_LM_Employee__c = c.Id;
        lc2.EMS_LM_Leave_Credited_Date__c = system.today();
        lc2.EMS_LM_Leaves_Credited__c = 5;
        lc2.EMS_LM_Select_Leave_Type__c = 'Annual Leave';
        insert lc2;
        EMS_LM_Leave_Credit__c lc3 = new EMS_LM_Leave_Credit__c();
        lc3.EMS_LM_Employee__c = c.Id;
        lc3.EMS_LM_Leave_Credited_Date__c = system.today();
        lc3.EMS_LM_Leaves_Credited__c = 5;
        lc3.EMS_LM_Select_Leave_Type__c = 'Bereavement Leave';
        insert lc3;
        EMS_LM_Leave_Credit__c lc4 = new EMS_LM_Leave_Credit__c();
        lc4.EMS_LM_Employee__c = c.Id;
        lc4.EMS_LM_Leave_Credited_Date__c = system.today();
        lc4.EMS_LM_Leaves_Credited__c = 0;
        lc4.EMS_LM_Select_Leave_Type__c = 'Loss of Pay';
        insert lc4;
        EMS_LM_Leave_Credit__c lc5 = new EMS_LM_Leave_Credit__c();
        lc5.EMS_LM_Employee__c = c.Id;
        lc5.EMS_LM_Leave_Credited_Date__c = system.today();
        lc5.EMS_LM_Leaves_Credited__c = 5;
        lc5.EMS_LM_Select_Leave_Type__c = 'Compensatory Off';
        insert lc5;    
        Date startdate = system.today() + 5 ;
        String startd = string.valueOf(startdate);
        Date enddate = startdate + 4;
        String endd = string.valueOf(enddate);
        Date mStartDate = system.today() + 56;
        Date mEndDate = mStartDate + 182;
            
            list<EMS_LM_Leave_History__c> leaveList =new list<EMS_LM_Leave_History__c>();
            EMS_LM_Leave_History__c leavehistory =new EMS_LM_Leave_History__c();
            leavehistory.EMS_LM_Contact__c=c.Id;
            leavehistory.EMS_LM_Leave_Start_Date__c=date.newInstance(2023, 2, 1);
            leavehistory.EMS_LM_Leave_End_Date__c=date.newInstance(2023, 2, 5);
            leavehistory.EMS_LM_Leave_Type_Name__c='Annual Leave';
            leavehistory.EMS_LM_Status__c='Pending';
            insert leavehistory;
            leaveList.add(leavehistory);
            
             EMS_LM_Leave_History__c leavehistory1 =new EMS_LM_Leave_History__c();
            leavehistory1.EMS_LM_Contact__c=c.Id;
            leavehistory1.EMS_LM_Leave_Start_Date__c=date.newInstance(2023, 2, 1);
            leavehistory1.EMS_LM_Leave_End_Date__c=date.newInstance(2023, 2, 5);
            leavehistory1.EMS_LM_Leave_Type_Name__c='Annual Leave';
            leavehistory1.EMS_LM_Status__c='Approved';
            insert leavehistory1;
            leaveList.add(leavehistory1);
            
            EMS_LM_Leave_History__c leavehistory2 =new EMS_LM_Leave_History__c();
            leavehistory2.EMS_LM_Contact__c=c.Id;
            leavehistory2.EMS_LM_Leave_Start_Date__c=date.newInstance(2023, 2, 1);
            leavehistory2.EMS_LM_Leave_End_Date__c=date.newInstance(2023, 2, 5);
            leavehistory2.EMS_LM_Leave_Type_Name__c='Annual Leave';
            leavehistory2.EMS_LM_Status__c='Waiting For Approver 2';
            insert leavehistory2;
            leaveList.add(leavehistory2);
            
            EMS_LM_Leave_History__c leavehistory3 =new EMS_LM_Leave_History__c();
            leavehistory3.EMS_LM_Contact__c=c.Id;
            leavehistory3.EMS_LM_Leave_Start_Date__c=date.newInstance(2023, 2, 1);
            leavehistory3.EMS_LM_Leave_End_Date__c=date.newInstance(2023, 2, 5);
            leavehistory3.EMS_LM_Leave_Type_Name__c='Compensatory Off';
            leavehistory3.EMS_LM_Status__c='Approved';
            insert leavehistory3;
            leaveList.add(leavehistory3);
            
        Test.startTest();
           
            LeaveCalculateHandler newlist =New LeaveCalculateHandler();
            newlist.leaveCalculateMethod(leaveList);
            
            Cp_CalculateLeaveDuration calcuList=New Cp_CalculateLeaveDuration();
            calcuList.leavedurationmethod(leaveList);
        Test.stopTest();  
    }
}
}