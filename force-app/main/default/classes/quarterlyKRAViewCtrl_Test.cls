/**
* @author Mukesh Rawat 
* @date 01/03/2024
* @description  Test class for quarterlyKRAViewCtrl

* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* 02/Sep/2024   Shubham Maske			Updated test class code for pahase 2 
* ====================================================================================================
**/
@isTest
public class quarterlyKRAViewCtrl_Test {
    public static testMethod void testClassForquarterlyKRAViewCtrl() {
        EMS_LM_Leave__c  annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
        EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
        EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
        EMS_LM_Leave__c paidTimeOff = TestDataFactory.createLeaveType('Paid time off',true);
        Resource_Role__c role = TestDataFactory.createResourceRole(true);
        System.debug('role created ' + role);
        
        //create Questions Records
        List<PM_Configure__c> Questions =  TestDataFactory.createPMConfigQuestionRec(role.Id,true);
        System.debug('Questions :: ' + Questions.size() );
        for(PM_Configure__c acc : Questions){
            System.debug('Area ' + acc.Area__c);
        }
        
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
        con1.EMS_RM_ApplicantStatus_Update__c = 'Active';
        insert con1;
        
        
        Resource_Role__c role2 = TestDataFactory.createResourceRole(true);
        
        Resource_Resource_Relationship__c resourceRelationship = new Resource_Resource_Relationship__c();
        resourceRelationship.Resource__c = con.Id;
        resourceRelationship.Resource_Reports_To__c=con.Id;
        resourceRelationship.Relationship_Type__c = 'Mentor';
        insert resourceRelationship;
        
        User u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
        
        Fiscal_Year__c FiscalYear = Testdatafactory.createFiscalYear(true);
        
        TriggerBase.bypass('Contact');
        con.EMS_TM_User__c = u.Id;
        con.Resource_Role__c = role.Id;
        update con;
        TriggerBase.clearBypass('Contact');
        System.debug('con role ' + con.Resource_Role__c);
        System.debug('con role ' + con.Resource_Role__r.Name);
        
        Fulfillment__c full = Testdatafactory.createFulfillment(con.Id,true);
        System.debug('full Resource ResourceRole :: ' + full.Resource__c );
        
        User u1 = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con1.Id,false);
        u1.Username='test001@admin.com';
        insert u1;
        
        Goal__c Kra = Testdatafactory.createKRARecords(con.Id, con.Id, full, false);
        //kra.Mentor_KRA_submitted__c = true;
        Kra.Resource__c = full.Resource__c;
        insert Kra;
         System.debug('Kra Resource ResourceRole :: ' + Kra.Resource__r.Resource_Role__c );
        Contact kraChaCon = [Select Id,Name,Resource_Role__c,Resource_Role__r.Name from Contact Where Id =: Kra.Resource__c ];
        Resource_Role__c roleContact = [Select Id,name from Resource_Role__c WHERE Id =:kraChaCon.Resource_Role__c ];
        System.debug('Kra roleContact :: ' + roleContact );
        System.debug('kraChaCon roleContact :: ' + kraChaCon.Resource_Role__c );
        System.debug('kraChaCon roleContact :: ' + kraChaCon.Resource_Role__r.Name );
        
        
        List<PM_Configure__c> gridPmConfigAns = [SELECT Id, Status__c, KRA__c FROM PM_Configure__c WHERE KRA__c =:Kra.Id ];
        System.debug('gridPmConfigAns :: ' + gridPmConfigAns);
        System.debug('gridPmConfigAns size :: ' + gridPmConfigAns.size());
        // Create a Set to store the Ids
        Set<Id> pmConfigIds = new Set<Id>();
        List<String> pmConfigIdList = new List<String>();
        for (PM_Configure__c pmConfig : gridPmConfigAns) {
            pmConfigIds.add(pmConfig.Id);
        }
        for (Id id : pmConfigIds) {
            pmConfigIdList.add(id);
        }

        
        Test.startTest();
        system.runAs(u){
        	quarterlyKRAViewCtrl.getCurrentUserConDetails();
            quarterlyKRAViewCtrl.getSelectedResourceConDetails(con.Id);
            quarterlyKRAViewCtrl.fetchKRARecords(Kra.Id, con.Id);
            quarterlyKRAViewCtrl.getReviewerDetails(Kra, con.Id);
            quarterlyKRAViewCtrl.getReviewerDetails(Kra, '');
            quarterlyKRAViewCtrl.saveKraRecord(Kra);
            quarterlyKRAViewCtrl.submitKraRecord(Kra,'My Team');
            //smaske : new methods
            quarterlyKRAViewCtrl.getPMConfigKRAData(Kra,'My Team',true,'123456',Kra.Resource__r.Id);
            quarterlyKRAViewCtrl.getPMConfigKRAData(Kra,'MyTest',true,'123456',Kra.Resource__r.Id);
            quarterlyKRAViewCtrl.cancelPMAnswerRecords(Kra);
            quarterlyKRAViewCtrl.updatePMAnswerRecordsStatus(pmConfigIdList,'Save','My Team');
            //quarterlyKRAViewCtrl.updatePMAnswerRecordsStatus(pmConfigIdList,'Submit','My Metric'); run in 2nd method
            System.debug('Kra Resource ResourceRole :: ' + Kra.Resource__r.Resource_Role__c );
            quarterlyKRAViewCtrl.calculateAverageRatingForKRA(pmConfigIdList,Kra,'My Team');
            
        }
               
        
        Test.stopTest();
    }
    
    public static testMethod void testClassForquarterlyKRAViewCtrl2() {
         EMS_LM_Leave__c  annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
        EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
        EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
        EMS_LM_Leave__c paidTimeOff = TestDataFactory.createLeaveType('Paid time off',true);
        Resource_Role__c role = TestDataFactory.createResourceRole(true);
        System.debug('role created ' + role);
        
        //create Questions Records
        List<PM_Configure__c> Questions =  TestDataFactory.createPMConfigQuestionRec(role.Id,true);
        System.debug('Questions :: ' + Questions.size() );
        for(PM_Configure__c acc : Questions){
            System.debug('Area ' + acc.Area__c);
        }
        
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
        con1.EMS_RM_ApplicantStatus_Update__c = 'Active';
        insert con1;
        
        
        Resource_Role__c role2 = TestDataFactory.createResourceRole(true);
        
        Resource_Resource_Relationship__c resourceRelationship = new Resource_Resource_Relationship__c();
        resourceRelationship.Resource__c = con.Id;
        resourceRelationship.Resource_Reports_To__c=con.Id;
        resourceRelationship.Relationship_Type__c = 'Mentor';
        insert resourceRelationship;
        
        User u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
        
        Fiscal_Year__c FiscalYear = Testdatafactory.createFiscalYear(true);
        
        TriggerBase.bypass('Contact');
        con.EMS_TM_User__c = u.Id;
        con.Resource_Role__c = role.Id;
        update con;
        TriggerBase.clearBypass('Contact');
        System.debug('con role ' + con.Resource_Role__c);
        System.debug('con role ' + con.Resource_Role__r.Name);
        
        Fulfillment__c full = Testdatafactory.createFulfillment(con.Id,true);
        System.debug('full Resource ResourceRole :: ' + full.Resource__c );
        
        User u1 = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con1.Id,false);
        u1.Username='test001@admin.com';
        insert u1;
        
        Goal__c Kra = Testdatafactory.createKRARecords(con.Id, con.Id, full, false);
        kra.Mentor_KRA_submitted__c = true;
        Kra.Resource__c = full.Resource__c;
        insert Kra;
        
        
        List<PM_Configure__c> gridPmConfigAns = [SELECT Id, Status__c, KRA__c FROM PM_Configure__c WHERE KRA__c =:Kra.Id ];
        System.debug('gridPmConfigAns :: ' + gridPmConfigAns);
        System.debug('gridPmConfigAns size :: ' + gridPmConfigAns.size());
        // Create a Set to store the Ids
        Set<Id> pmConfigIds = new Set<Id>();
        List<String> pmConfigIdList = new List<String>();
        for (PM_Configure__c pmConfig : gridPmConfigAns) {
            pmConfigIds.add(pmConfig.Id);
        }
        for (Id id : pmConfigIds) {
            pmConfigIdList.add(id);
        }

        
        Test.startTest();
        system.runAs(u){
            quarterlyKRAViewCtrl.updatePMAnswerRecordsStatus(pmConfigIdList,'Submit','My Metric');       
            quarterlyKRAViewCtrl.updatePMAnswerRecordsStatus(pmConfigIdList,'Save','My Metric');       
        }
               
        
        Test.stopTest();
    }
    

}