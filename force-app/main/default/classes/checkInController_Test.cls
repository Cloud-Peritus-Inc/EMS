/**
* @author Shubham Maske 
* @date 29/02/2024
* @description  Test class for checkInController

* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
@isTest
public class checkInController_Test {
    
    @testSetup
    static void setupTestData() {
        
        user adminuser = TestDataFactory.createAdminUser(true); 
        Resource_Role__c role;
        EMS_LM_Leave__c annualtype;
        EMS_LM_Leave__c loptype;
        EMS_LM_Leave__c bretype;
        EMS_LM_Leave__c compofftype;
        EMS_LM_Leave__c paternitytype;
        EMS_LM_Leave__c  Bereavementtype;
        EMS_LM_Leave__c paidTimeOff;
        Office_Location__c hydIndia;
        Office_Location__c usLocation;
        
        Resource_Role__c techLead;
        Resource_Resource_Relationship__c rrr;
        List<Resource_Role__c> resourceRoleList = new List<Resource_Role__c>();
        List<Contact> contactList = new List<Contact>();
        List<User> userList = new List<User>();
        
        Account acc;Contact con;
        system.runAs(adminuser){
            role = TestDataFactory.createResourceRole(true);
            
            annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            paternitytype = TestDataFactory.createLeaveType('Paternity Leave',true);
            Bereavementtype = TestDataFactory.createLeaveType('Bereavement Leave',true);
            paidTimeOff = TestDataFactory.createLeaveType('Paid time off',true);
            
            
            hydIndia = TestDataFactory.createOfficeLocation('Hyderabad - India',true);
            usLocation = TestDataFactory.createOfficeLocation('California - USA',true);
            List<Office_Location__c> OfficeLocationList = new List<Office_Location__c>();
            OfficeLocationList.add(hydIndia);
            OfficeLocationList.add(usLocation);
            acc = TestDataFactory.createAccount(true);
            
            resourceRoleList.add(techLead = TestDataFactory.createResourceRole('Software Engineer',false));
            insert resourceRoleList;
            
            
            for(Integer i=0; i<2; i++){
                con =TestDataFactory.createResourceContact(acc.id, false);
                con.EMS_RM_Employee_Id__c = 'CP1023'+i;
                con.Resource_Role__c = resourceRoleList[0].Id;
                con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
                con.EMS_RM_ApplicantStatus_Update__c = 'Active';
                con.RecordTypeId = ContactConstant.RESOURCE_RECORDTYPEID;
                con.EMS_EM_JD__c = system.today() - 180;
                con.Work_Location__c = OfficeLocationList[i].Id;
                contactList.add(con);              
            }
            insert contactList;
           
            for(Contact cont : contactList){
                User u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,cont.Id,false);
                u.Username = u.Username + cont.Id;
                u.ContactId = cont.Id;
                userList.add(u);
            }
            Insert userList;
            
            rrr = TestDataFactory.createRRR(contactList[0].Id, true, contactList[1].Id);
            
            Fiscal_Year__c FiscalYear = TestDataFactory.createFiscalYear(true);
        }
    }
    
    testmethod static void  createCheckInTest(){
        Test.startTest();
        Contact MentorCon = [Select Id,Name,EMS_RM_Employee_Id__c From Contact WHERE EMS_RM_Employee_Id__c = 'CP10230'];
        Contact MenteeCon = [Select Id,Name,EMS_RM_Employee_Id__c From Contact WHERE EMS_RM_Employee_Id__c = 'CP10231'];
        String Result = checkInController.createCheckIn(MenteeCon.Id, MentorCon.Id,'Test Checkin Records');
        Goal__c createdCheckIn = TestDataFactory.createCheckIn(MenteeCon.Id, MentorCon.Id,'Test Checkin Records',true);
        checkInController.getTheCheckInRecord(createdCheckIn.Id); 
        Fiscal_Year__c FiscalYear = [Select Id,Name,Start_Date__c,End_Date__c FROM Fiscal_Year__c];
        checkInController.getTheCheckInInfo(MenteeCon.Id, FiscalYear.Id);
        checkInController.getTheCheckInInfo(MenteeCon.Id, Null);
        checkInController.getTheCheckInInfo(Null, FiscalYear.Id);
        
        Fulfillment__c Ful = TestDataFactory.createFulfillment(MentorCon.Id, true);
        Goal__c createdPulse = TestDataFactory.createPulseRecords(MenteeCon.Id, MentorCon.Id, Ful.Id, true);
        System.debug('createdPulse ' + createdPulse);
        User u = [SELECT Id, Username, ContactId FROM User WHERE ContactId =: MentorCon.Id];
        system.runAs(u){
            checkInController.getThePulseInfo(MentorCon.Id, FiscalYear.Id);
            checkInController.getThePulseInfo(MentorCon.Id, null);
            checkInController.getThePulseInfo(null, FiscalYear.Id);
            //
            checkInController.getThePulseInfo(MenteeCon.Id, FiscalYear.Id);
        }
        Test.stopTest();
    } 
    
    

}