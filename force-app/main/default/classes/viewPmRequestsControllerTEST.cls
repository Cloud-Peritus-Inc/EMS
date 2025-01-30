/**
* @author Sangharsh Kamble 
* @date 02/09/2024
* @description  Test class for viewPmRequestsController

* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
@isTest
public class viewPmRequestsControllerTEST {
    @testSetup
    static void setupTestData() {
        EMS_LM_Leave__c  annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
        EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
        EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
        EMS_LM_Leave__c paidTimeOff = TestDataFactory.createLeaveType('Paid time off',true);
        Resource_Role__c role = TestDataFactory.createResourceRole(true);
        System.debug('role created ' + role.Name);
        
        //create Questions Records
        List<PM_Configure__c> Questions =  TestDataFactory.createPMConfigQuestionRec(role.Id,true);
        
        Account acc = TestDataFactory.createAccount(true);
        Contact con=  TestDataFactory.createResourceContact(acc.id, false);
        con.EMS_RM_Employee_Id__c = 'CP10234';
        con.Resource_Role__c = role.Id;
    	con.Email ='test@cloudperitus.com';
        con.EMS_RM_ApplicantStatus_Update__c = 'Active';
        insert con;
        
        Contact con1=  TestDataFactory.createResourceContact(acc.id, false);
        con1.EMS_RM_Employee_Id__c = 'CP10235';
        con1.Resource_Role__c = role.Id;
        con1.Email = 'testEmail+test1@cloudperitus.com';
        con1.EMS_RM_ApplicantStatus_Update__c = 'Active';
        insert con1;
    
       		EMS_TM_Project__c project = new EMS_TM_Project__c();
            project.Name ='Grid Test';
            project.EMS_TM_StartDate__c = system.today();
            project.EMS_TM_EndDate__c =system.today() + 365;
            project.EMS_TM_Status__c = 'Ongoing';
            project.Type_Of_Project__c ='Internal Projects';
            project.Account__c = acc.Id;
            project.Offshore_Project_Manager__c = con1.Id;
            project.Project_Manager__c = con1.id;
            Insert project;
        
        
        Resource_Role__c role2 = TestDataFactory.createResourceRole(true);
        
        Resource_Resource_Relationship__c resourceRelationship = new Resource_Resource_Relationship__c();
        resourceRelationship.Resource__c = con.Id;
        resourceRelationship.Resource_Reports_To__c=con.Id;
        resourceRelationship.Relationship_Type__c = 'Mentor';
        insert resourceRelationship;
        
        User u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
        system.debug('u-->'+u);
        Fiscal_Year__c FiscalYear = Testdatafactory.createFiscalYear(true);
        
        TriggerBase.bypass('Contact');
        con.EMS_TM_User__c = u.Id;
        con.Resource_Role__c = role.Id;
        update con;
        TriggerBase.clearBypass('Contact');
        
        Fulfillment__c full = Testdatafactory.createFulfillment(con.Id,true);
        
        User u1 = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con1.Id,false);
        u1.Username='test001@admin.com';
        insert u1;
        
        Goal__c Kra = Testdatafactory.createKRARecords(con.Id, con.Id, full, false);
        Kra.Resource__c = full.Resource__c;
        insert Kra;
    
    Contact kraChaCon = [Select Id,Name,Resource_Role__c,Resource_Role__r.Name from Contact Where Id =: Kra.Resource__c ];
     System.debug('Kra Resource ResourceRole :: ' + kraChaCon );
        Resource_Role__c roleContact = [Select Id,name from Resource_Role__c WHERE Id =:kraChaCon.Resource_Role__c ];
        System.debug('Kra roleContact :: ' + roleContact );
        
        
        List<PM_Configure__c> gridPmConfigAns = [SELECT Id, Status__c, KRA__c FROM PM_Configure__c WHERE KRA__c =:Kra.Id ];
        // Create a Set to store the Ids
        Set<Id> pmConfigIds = new Set<Id>();
        List<String> pmConfigIdList = new List<String>();
        for (PM_Configure__c pmConfig : gridPmConfigAns) {
            pmConfigIds.add(pmConfig.Id);
        }
        for (Id id : pmConfigIds) {
            pmConfigIdList.add(id);
        }
    
    List<PM_Configure__c> createPMConfigRecords = TestDataFactory.createPMConfigRecords(role.Id,con.Id,con.Id,project.Id,KRA.Id,true);    
    }
    
public static testMethod void testClassForquarterlyKRAViewCtrl() {
    //User u =[Select id from User ]
    Goal__c Kra =[Select Id from Goal__c limit 1];
    List<PM_Configure__c> createPMConfigRecords =[Select id from PM_Configure__c];
  Test.startTest();
       // system.runAs(u){
            viewPmRequestsController.viewPMRequestsTable(Kra.Id);   
          //  viewPmRequestsController.recallPmRequests(Kra.Id,con.Id,'Grid Test','Recalled');
            //viewPmRequestsController.sendEmailToPmForRecallRecords(createPMConfigRecords);
       // } 
        Test.stopTest();       
}
    
    public static testMethod void viewPMRequestsTableForSubmitted() {
    //User u =[Select id from User ]
    Goal__c Kra =[Select Id from Goal__c limit 1];
    Id answerRecordTypeId = Schema.SObjectType.PM_Configure__c.getRecordTypeInfosByName().get('Answer').getRecordTypeId();

    List<PM_Configure__c> createPMConfigRecords =[Select id,Status__c,KRA__c from PM_Configure__c WHERE RecordTypeId =: answerRecordTypeId and KRA__c =:Kra.Id ];
         List<PM_Configure__c> updateAnswer = new  List<PM_Configure__c>();
        for(PM_Configure__c ans : createPMConfigRecords){
            ans.Status__c = 'Submitted';
			updateAnswer.add(ans);            
        }
        TriggerBase.bypass('PM_Configure__c');
        update updateAnswer;
        TriggerBase.clearBypass('PM_Configure__c');
  Test.startTest();
            viewPmRequestsController.viewPMRequestsTable(Kra.Id);
        Test.stopTest();       
}
    
    public static testMethod void viewPMRequestsTableForAccepted() {
    //User u =[Select id from User ]
    Goal__c Kra =[Select Id from Goal__c limit 1];
    Id answerRecordTypeId = Schema.SObjectType.PM_Configure__c.getRecordTypeInfosByName().get('Answer').getRecordTypeId();

    List<PM_Configure__c> createPMConfigRecords =[Select id,Status__c,KRA__c from PM_Configure__c WHERE RecordTypeId =: answerRecordTypeId and KRA__c =:Kra.Id ];
         List<PM_Configure__c> updateAnswer = new  List<PM_Configure__c>();
        for(PM_Configure__c ans : createPMConfigRecords){
            ans.Status__c = 'Accepted';
			updateAnswer.add(ans);            
        }
        TriggerBase.bypass('PM_Configure__c');
        update updateAnswer;
        TriggerBase.clearBypass('PM_Configure__c');
  Test.startTest();
            viewPmRequestsController.viewPMRequestsTable(Kra.Id);
        Test.stopTest();       
}
    
    public static testMethod void viewPMRequestsTableForRejected() {
    //User u =[Select id from User ]
    Goal__c Kra =[Select Id from Goal__c limit 1];
    Id answerRecordTypeId = Schema.SObjectType.PM_Configure__c.getRecordTypeInfosByName().get('Answer').getRecordTypeId();

    List<PM_Configure__c> createPMConfigRecords =[Select id,Status__c,KRA__c from PM_Configure__c WHERE RecordTypeId =: answerRecordTypeId and KRA__c =:Kra.Id ];
         List<PM_Configure__c> updateAnswer = new  List<PM_Configure__c>();
        for(PM_Configure__c ans : createPMConfigRecords){
            ans.Status__c = 'Rejected';
			updateAnswer.add(ans);            
        }
        TriggerBase.bypass('PM_Configure__c');
        update updateAnswer;
        TriggerBase.clearBypass('PM_Configure__c');
  Test.startTest();
            viewPmRequestsController.viewPMRequestsTable(Kra.Id);
        Test.stopTest();       
}
    
    public static testMethod void viewPMRequestsTableForCancelled() {
    //User u =[Select id from User ]
    Goal__c Kra =[Select Id from Goal__c limit 1];
    Id answerRecordTypeId = Schema.SObjectType.PM_Configure__c.getRecordTypeInfosByName().get('Answer').getRecordTypeId();

    List<PM_Configure__c> createPMConfigRecords =[Select id,Status__c,KRA__c from PM_Configure__c WHERE RecordTypeId =: answerRecordTypeId and KRA__c =:Kra.Id ];
         List<PM_Configure__c> updateAnswer = new  List<PM_Configure__c>();
        for(PM_Configure__c ans : createPMConfigRecords){
            ans.Status__c = 'Cancelled';
			updateAnswer.add(ans);            
        }
        TriggerBase.bypass('PM_Configure__c');
        update updateAnswer;
        TriggerBase.clearBypass('PM_Configure__c');
  Test.startTest();
            viewPmRequestsController.viewPMRequestsTable(Kra.Id);
        Test.stopTest();       
}
    
    public static testMethod void recallPmRequests() {
        //User u =[Select id from User ]
        Goal__c Kra =[Select Id,Resource__c from Goal__c limit 1];
        Id answerRecordTypeId = Schema.SObjectType.PM_Configure__c.getRecordTypeInfosByName().get('Answer').getRecordTypeId();
        List<PM_Configure__c> createPMConfigRecords =[Select id,Status__c,Reporting_Contact__c,KRA__c from PM_Configure__c WHERE RecordTypeId =: answerRecordTypeId and KRA__c =:Kra.Id and Reporting_Contact__c != null ];
        EMS_TM_Project__c project = [Select Id,Name from EMS_TM_Project__c];
        Test.startTest();
        viewPmRequestsController.recallPmRequests(Kra.Id,kra.Resource__c,project.Id,'Test');
        Test.stopTest();       
    }
    
}