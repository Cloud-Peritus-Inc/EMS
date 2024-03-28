/**
* @author Subba Kalavala
* @date 2/22/2023
* @description  Test class for resourceTileController.
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
@isTest
public class resourceTileControllerTest {
    public static testmethod void checkTheLoggedInUserResourceDetails(){
            EMS_LM_Leave__c  annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
            EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
            EMS_LM_Leave__c paidTimeOff = TestDataFactory.createLeaveType('Paid time off',true);
         Resource_Role__c role = TestDataFactory.createResourceRole(true);
         
         //TestDataFactory.createLeaveType(true);
        List<Grid_Configuration__c> gCon = new List<Grid_Configuration__c>();
        List<Grid_Configuration__c> gCon1 = new List<Grid_Configuration__c>();
        List<Grid_Configuration__c> gCon2 = new List<Grid_Configuration__c>();
        gCon.add(Testdatafactory.createGridConfig('namevalue','test description','Org Level Alert',null,false));
        insert gCon;
        gCon1.add(Testdatafactory.createGridConfig1('namevalue','test description','Resource Role Alert',role.id,false));
        insert gCon1;
        //smaske : Test Class failed for 'Videocast' value replacing with 'Resource Role Level Goal'
        gCon2.add(Testdatafactory.createGridConfig1('namevalue','test description','Resource Role Level Goal',role.id,false));
        insert gCon2;
      
        Account acc = TestDataFactory.createAccount(true);
        Contact con=  TestDataFactory.createResourceContact(acc.id, false);
        con.EMS_RM_Employee_Id__c = 'CP10234';
        con.Resource_Role__c = role.Id;
        insert con;
        
        Contact con1=  TestDataFactory.createResourceContact(acc.id, false);
        con1.EMS_RM_Employee_Id__c = 'CP10235';
        con1.Resource_Role__c = role.Id;
        con1.Email = 'testEmail+test1@cloudperitus.com';
        insert con1;
		 
        
        
        
        Resource_Resource_Relationship__c resourceRelationship = new Resource_Resource_Relationship__c();
        resourceRelationship.Resource__c = con.Id;
        resourceRelationship.Resource_Reports_To__c=con.Id;
        //smaske : adding Required Relationship_Type__c value
        resourceRelationship.Relationship_Type__c = 'Mentor';
        insert resourceRelationship;
        
        

         User u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
        User u1 = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con1.Id,false);
        u1.Username='test@admin.com';
        //insert u1;
         con.ReportsToId=u1.contactId;
        //update con;
        Contact con2=  TestDataFactory.createResourceContact(acc.id, false);
        con2.EMS_RM_Employee_Id__c = 'CP10236';
        con2.Resource_Role__c = role.Id;
         con2.ReportsToId=u.contactId;
        con2.EMS_RM_ApplicantStatus_Update__c='active';
        con2.Email = 'testEmail+test1@cloudperitus1.com';
        insert con2;
        
       EMS_EM_Benefits__c benifit=new EMS_EM_Benefits__c(Amount__c=500000,EMS_EM_Nominee__c=con2.Id,Type__c='Medical Insurence');
        insert benifit;
        
   
        
        
        
        resourceTileController.datawrapper datawrap=new resourceTileController.datawrapper();
        datawrap.resourceName = con.Name;
        datawrap.resourcePhotoURL = con.EMS_TM_User__r.FullPhotoUrl;
        datawrap.resourceCpId = con.EMS_RM_Employee_Id__c;
        datawrap.resourceRole = con.Resource_Role__r.Name;
        datawrap.resourceReportTo = con.ReportsTo.Name;
        datawrap.resourceUserId = con.EMS_TM_User__c;
        datawrap.resourceContactId = con.Id;
         Test.startTest();
          resourceTileController.getTheCurrentAlerts();
          system.runAs(u){
              resourceTileController.getContactInfo(con.Id);
             resourceTileController.getUserInfo(u.Id);
              resourceTileController.getUserHiearchyInfo(u.Id);
               resourceTileController.fileWrapper filewrap=new resourceTileController.fileWrapper();
              resourceTileController.getUserReportees(u.Id);
              resourceTileController.getMyInsurenceBenf(con2);
           }
        resourceTileController.getRelatedFilesByRecordId();
         Test.stopTest();
    }
   
}