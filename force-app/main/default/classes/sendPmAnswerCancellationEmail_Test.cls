/**
* @author Shubham Maske
* @date 03/09/2024
* @description  Test class for sendPmAnswerCancellationEmail

* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* 
* ====================================================================================================
**/
@isTest
public class sendPmAnswerCancellationEmail_Test {
    
    public static testMethod void testSendPmAnswerCancellationEmail() {
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
        
        Goal__c Kra = Testdatafactory.createKRARecords(con.Id, con.Id, full, true);
        
        EMS_TM_Project__c project = new EMS_TM_Project__c();
        project.Name ='Grid Test';
        project.EMS_TM_StartDate__c = system.today();
        project.EMS_TM_EndDate__c =system.today() + 365;
        project.EMS_TM_Status__c = 'Ongoing';
        project.Type_Of_Project__c ='Internal Projects';
        project.Account__c = acc.Id;
        project.Offshore_Project_Manager__c = con.Id;
        project.Project_Manager__c = con.id;
        Insert project;
        
        
        
        Test.startTest();
        
        List<PM_Configure__c> gridPmConfigAns = Testdatafactory.createPMConfigRecords(role.Id,con.Id,project.Offshore_Project_Manager__c,project.Id,kra.Id,true);
        System.debug('gridPmConfigAns :: ' + gridPmConfigAns);
        System.debug('gridPmConfigAns size :: ' + gridPmConfigAns.size());
        
        Kra.Mentor_KRA_submitted__c = true;
        kra.Status__c = 'KRA Inreview';
        update Kra;
        
        // Create a Set to store the Ids
        List<PM_Configure__c> pmConfigIdList = new List<PM_Configure__c>();
        for (PM_Configure__c pmConfig : gridPmConfigAns) {
            pmConfig.Status__c = 'Cancelled';
            pmConfigIdList.add(pmConfig);
        }
        
        If(!pmConfigIdList.isEmpty() && pmConfigIdList.size() > 0){
            Update pmConfigIdList;
        }
    }
    
}