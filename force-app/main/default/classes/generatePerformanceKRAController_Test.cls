/**
* @author Mukesh Rawat 
* @date 29/02/2024
* @description  Test class for generatePerformanceKRAController

* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
@isTest
public class generatePerformanceKRAController_Test {
    public static testmethod void testMethodForGetTheData(){
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
        con1.EMS_RM_Employee_Id__c = 'CP10254';
        con1.Resource_Role__c = role.Id;
        con1.EMS_RM_ApplicantStatus_Update__c = 'Active';
        con1.Email = 'Test005@admin.com';
        insert con1;
        Contact con2=  TestDataFactory.createResourceContact(acc.id, false);
        User u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
        User u1 = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con1.Id,false);
        u1.Username = 'testKra009@admin.com';
        Insert u1;
        Fiscal_Year__c FiscalYear = Testdatafactory.createFiscalYear(true);
        Fulfillment__c full = Testdatafactory.createFulfillment(con.Id,true);
        Fiscal_Year__c fy = Testdatafactory.createFiscalYear(false);
        Period currentFiscalYearPeriod = [SELECT FiscalYearSettings.Name, FullyQualifiedLabel, StartDate, EndDate  FROM Period WHERE Type = 'Year' AND StartDate = THIS_FISCAL_YEAR LIMIT 1];
        fy.Start_Date__c = currentFiscalYearPeriod.StartDate;
        fy.End_Date__c = currentFiscalYearPeriod.EndDate;
        Insert fy;
        Fulfillment__c ful = Testdatafactory.createFulfillment(con.Id,false);
        ful.Fiscal_Year__c = fy.Id;
        ful.Resource__c = con.Id;
        Insert ful;
        system.debug('Mukesh fy' +fy);
        system.debug('Mukesh ful>>>>' +fy);
        List<Goal__c> kraRecords = New List<Goal__c>();
        List<Goal__c> kraRecords1 = New List<Goal__c>();
        Goal__c Kra = Testdatafactory.createKRARecords(con.Id, con1.Id, ful, false);
        Kra.Status__c = 'KRA Completed';
        Insert Kra;
        kraRecords.add(Kra);
        
        Compensation__c Compensation = new Compensation__c();
        Compensation.Fulfillment__c = ful.id;
        Compensation.Resource__c = con.Id;
        Compensation.Reviewed_By__c = u1.Id;
        Compensation.Comments__c = 'Test';
        Compensation.Compensation_Submitted__c = true;
        Insert Compensation;
        Compensation__c Compensation1 = new Compensation__c();
        Compensation1.Fulfillment__c = full.id;
        Compensation1.Resource__c = con.Id;
        Compensation1.Reviewed_By__c = u1.Id;
        Compensation1.Comments__c = 'Test';
        Insert Compensation1;
        System.debug('Mukesh Compensation>>>' +Compensation);
        
        Date startDate = System.today().addDays(-160);
        Date endDate = System.today();
        
        Test.startTest();
        system.runAs(u1){
            generatePerformanceKRAController.getResourceDetails(con.Id);
            generatePerformanceKRAController.getResourceKraRecords(con, startDate, endDate);
            generatePerformanceKRAController.getCompensationDetails(con.Id);	
            generatePerformanceKRAController.updateContactDetails(Compensation);
            generatePerformanceKRAController.updateCompensationDetails(Compensation, kraRecords, fy.Id);
            generatePerformanceKRAController.updateFulfillmentDetails(Compensation, fy.Id);
            
            try{
            	generatePerformanceKRAController.getResourceDetails(con2.Id);
                generatePerformanceKRAController.getResourceKraRecords(con2, startDate, endDate);
                generatePerformanceKRAController.getCompensationDetails(con2.Id);
                generatePerformanceKRAController.updateContactDetails(Compensation1);
                generatePerformanceKRAController.updateFulfillmentDetails(Compensation, FiscalYear.Id);
            //
            }catch (Exception ex) {
                String errorMsg = ex.getMessage();
                System.debug('An exception occurred: ' + errorMsg);
            }
        }
        
        Test.stopTest();
        
    }
    
}