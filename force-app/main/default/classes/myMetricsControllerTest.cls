/**
* @author Mukesh Rawat 
* @date 01/03/2024
* @description  Test class for myMetricsController

* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
@isTest
public class myMetricsControllerTest {
    public static testMethod void testClassForMyMetricsController() {
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
        
        Contact con1=  TestDataFactory.createResourceContact(acc.id, false);
        con1.EMS_RM_Employee_Id__c = 'CP10235';
        con1.Resource_Role__c = role.Id;
        con1.Email = 'testEmail+test1@cloudperitus.com';
        con.EMS_RM_ApplicantStatus_Update__c = 'Active';
        insert con1;
        
        Resource_Resource_Relationship__c resourceRelationship = new Resource_Resource_Relationship__c();
        resourceRelationship.Resource__c = con.Id;
        resourceRelationship.Resource_Reports_To__c=con.Id;
        resourceRelationship.Relationship_Type__c = 'Mentor';
        insert resourceRelationship;
        
        User u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,false);
        u.Username = 'absc@admin.com';
        Insert u;
        User u1 = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con1.Id,true);
        Fiscal_Year__c FiscalYear = Testdatafactory.createFiscalYear(true);
        Fiscal_Year__c fy = Testdatafactory.createFiscalYear(false);
        Period currentFiscalYearPeriod = [SELECT FiscalYearSettings.Name, FullyQualifiedLabel, StartDate, EndDate  FROM Period WHERE Type = 'Year' AND StartDate = THIS_FISCAL_YEAR LIMIT 1];
        fy.Start_Date__c = currentFiscalYearPeriod.StartDate;
        fy.End_Date__c = currentFiscalYearPeriod.EndDate;
        Insert fy;
        Fulfillment__c full = Testdatafactory.createFulfillment(con.Id,false);
        full.Fiscal_Year__c = fy.Id;
        full.Resource__c = con.Id;
        Insert full;
        Goal__c Kra = Testdatafactory.createKRARecords(con.Id, con1.Id, full, true);
        List<Grid_Configuration__c> gridConfigs = TestDataFactory.createGridConfigurationKraData(role.Id, true);
        Goal__c Pulse = TestDataFactory.createPulseRecords(con.Id, con1.Id, full.id, true);
        
        Test.startTest();
        myMetricsController.getTheCurrentFY();
        myMetricsController.getAllKRAs(FiscalYear.Id);
        myMetricsController.getAllKRAs('');
        myMetricsController.getTheCompanyKRA();
        myMetricsController.getResourceKRAs(con.Id, fy.Id);
        myMetricsController.getAllRoleKRAs(role.Id);
        myMetricsController.createKraPulseRecords(u.ContactId, full.Id);
        myMetricsController.getKraPulseRecords(u.ContactId, fy.Id);
        system.runAs(u){
            myMetricsController.getAllKRAs(fy.Id);
        }
        
        Test.stopTest();
    }
    
}