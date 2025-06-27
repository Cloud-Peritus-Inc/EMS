@isTest
public class countWfoDaysForResourceTest {
    
    @testSetup
static void setupTestData() {
    //User userId = [SELECT Id FROM User WHERE IsActive = true AND Profile.Name = 'System Administrator' LIMIT 1];
    User usrConId = [SELECT Id, ContactId FROM User WHERE Id =: LeaveRequestConstant.LOGGEDIN_USERID];

    Resource_Role__c role = TestDataFactory.createResourceRole(true);        
    Account acc = TestDataFactory.createAccount(true);
    Contact con = TestDataFactory.createResourceContact(acc.Id, false);
    con.EMS_RM_Employee_Id__c = 'CP10288';
    con.EMS_RM_ApplicantStatus_Update__c = 'Active';
    con.EMS_Phone_Number__c = '0123456789';
    con.EMS_EM_CAddress_Line_1__c = 'Hyd';
    con.EMS_EM_CA_City__c = 'Hyd';
    con.EMS_EM_CA_State__c = 'AP';
    con.Timesheet_NoNeed__c = false;
    con.Resource_Role__c = role.Id;
    con.EMS_TM_User__c = usrConId.Id;
    insert con;


Date monthStart = Date.today().toStartOfMonth(); 
Date startOfWeek = monthStart.addDays(2);       
Date endOfWeek = startOfWeek.addDays(5);        

EMS_Timesheet__c ts = new EMS_Timesheet__c(
    Resource__c = usrConId.ContactId,
    Week_Start_Date__c = startOfWeek,
    EMS_TM_Week__c = endOfWeek,
    WFH_Mon__c = true,
    WFH_Tue__c = false,
    WFH_Wed__c = true,
    WFH_Thu__c = false,
    WFH_Fri__c = true,
    WFH_Sat__c = false,
    WFH_Sun__c = false
);
insert ts;
}


    @isTest
    static void testGetWfoDaysForCurrentMonth() {
        Test.startTest();
        Integer result = countWfoDaysForResource.GetWfoDaysForCurrentMonth();
        Test.stopTest();
        System.assert(result >= 0, 'The WFO days should be 0 or more.');
    }

    @isTest
    static void testRunWfoCalculations() {
        Test.startTest();
        Integer wfoDays = countWfoDaysForResource.RunWfoCalculations();
        Test.stopTest();
        System.assertNotEquals(null, wfoDays, 'WFO calculation should return a number.');
    }
}