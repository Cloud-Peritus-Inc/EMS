/**
 * Description: This Apex class represents Test class of pulseKraRecordFromController.
 * Author: Shubham Maske
 * Created Date: March 1, 2024
 * Version: 1.0
 */
@istest
public class pulseKraRecordFromControllerTest {
 public static testMethod void pulsekrarecords() {
         
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
            pulseKraRecordFromController controller = new pulseKraRecordFromController(); 
      Goal__c Goal=new Goal__c();
       insert Goal;
                    System.assertEquals(true, true); // Example assertion, replace with your own
         Goal__c fetchedRecord1 = pulseKraRecordFromController.fetchPulseRecord(Kra.Id);
             System.assertNotEquals(null, fetchedRecord1);
             System.assertEquals(Kra.Id, fetchedRecord1.Id);
             System.assertEquals(Kra.Status__c, fetchedRecord1.Status__c);
         Goal__c fetchedRecordnull = pulseKraRecordFromController.fetchPulseRecord(null);
            
     try{
          Goal__c fetchedRecordinvalid= pulseKraRecordFromController.fetchPulseRecord(null);
                      System.assertNotEquals(null, fetchedRecord1);
      }catch (AuraHandledException e) {
            // Ensure the AuraHandledException is caught
            System.assertNotEquals('', e.getMessage());
        }

         Goal__c fetchedRecord2 =  pulseKraRecordFromController.updatePulseRecord(Pulse);
                 fetchedRecord2.Status__c = 'Completed';
   
                 pulseKraRecordFromController.updatePulseRecord(fetchedRecord2);
                             System.assertEquals('Completed', fetchedRecord2.Status__c);
                  Goal__c updatedRecord = [SELECT Id, Status__c FROM Goal__c WHERE Id = :fetchedRecord2.Id];
                  System.assertEquals('Completed', updatedRecord.Status__c);
     try{
                           pulseKraRecordFromController.updatePulseRecord(null);

     }catch(exception e){
          System.assertEquals('Script-thrown exception',e.getmessage());
     }
       
     
     
}
}