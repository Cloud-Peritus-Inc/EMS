@IsTest
public class restrictLeaveForNoticPeriodTest { 
    @IsTest
    public static void restrictLeaveForNoticPeriodTestmtd(){
        List<EMS_LM_Leave_History__c> newlist = new List<EMS_LM_Leave_History__c>();
        date startdate = system.today();
        date enddate = system.today().adddays(10);
        EMS_LM_Leave__c leave = TestDataFactory.createLeaveType(true);
        EMS_LM_Leave__c leaveLOP = TestDataFactory.createLeaveType('Loss of Pay',true);
        EMS_LM_Leave__c paidTimeOff = TestDataFactory.createLeaveType('Paid time off',true);
        Contact Con = new Contact();
        Con.FirstName = 'Test';
        Con.LastName = 'SF Contact';
        Con.Email = 'testSF@Salesforce.com';
        Con.EMS_Phone_Number__c = '1234567890';
        RecordType rt = [select Id,name from RecordType where Name ='Resource' and SobjectType = 'Contact'];
        Con.RecordTypeId=rt.id;
        con.EMS_RM_ApplicantStatus_Update__c = 'Notice Period';
        insert Con; 
        
        EMS_LM_Leave_History__c leaveReq = new EMS_LM_Leave_History__c(); 
        leaveReq.EMS_LM_Contact__c = con.id;
        leaveReq.EMS_LM_Day__c = 'Full Day';
        leaveReq.EMS_LM_Leave_Start_Date__c = system.today();
        leaveReq.EMS_LM_Leave_End_Date__c = system.today().adddays(1);
        leaveReq.EMS_LM_Leave_Type__c = leave.Id;
        leaveReq.EMS_LM_Leave_Duration__c = 1;
        leaveReq.EMS_LM_Reason__c = 'Test Reason';
        leaveReq.EMS_LM_Status__c =  'Pending';
        leaveReq.EMS_LM_Leave_Type_Name__c = 'Annual Leave';
        try{
            Insert leaveReq;
        }catch(exception ex){
        }
        
        newlist.add(leaveReq);
        restrictLeaveForNoticPeriod obj = new restrictLeaveForNoticPeriod();
        obj.beforeInsert(newList);
    }
}