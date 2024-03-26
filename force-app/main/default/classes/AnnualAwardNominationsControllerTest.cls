/**
* @author Mukesh Rawat 
* @date 04/03/2024
* @description  Test class for AnnualAwardNominationsController

* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
@isTest
public class AnnualAwardNominationsControllerTest {
    public static testMethod void testClassForAnnualAwardNominationsController() {
        EMS_LM_Leave__c  annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
        EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
        EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
        EMS_LM_Leave__c paidTimeOff = TestDataFactory.createLeaveType('Paid time off',true);
        Resource_Role__c role = TestDataFactory.createResourceRole(true);
        
        Account acc = TestDataFactory.createAccount(true);
        Contact con=  TestDataFactory.createResourceContact(acc.id, false);
        con.EMS_RM_Employee_Id__c = 'CP10234';
        con.Resource_Role__c = role.Id;
        con.EMS_RM_ApplicantStatus_Update__c = 'Active';
        insert con;
        User u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
        
        Fiscal_Year__c FiscalYear = Testdatafactory.createFiscalYear(true);
        
        List<Reward_And_Recognition__c> awardList = new List<Reward_And_Recognition__c>();
        Reward_And_Recognition__c RewardAndRecognition = Testdatafactory.AnnualAwardNominationRecords(con.Id, FiscalYear.Id, false);
        awardList.add(RewardAndRecognition);
        
        Test.startTest();
        system.runAs(u){
            AnnualAwardNominationsController.getAnnualAwardNominationRecords();
			AnnualAwardNominationsController.createAnnualAwardNominationRecords(awardList, FiscalYear.Id, 'Draft');
            AnnualAwardNominationsController.submitAnnualAwardNominationRecords(awardList, FiscalYear.Id, 'Nominated');
        }
        Test.stopTest();
        
    }

}