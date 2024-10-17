@isTest
public class quarterlyKRAFullViewCtrl_TEST {
	@testSetup
    static void setupTestData() {
  		Resource_Role__c role = TestDataFactory.createResourceRole(true);
        Account acc = TestDataFactory.createAccount(true);
        Contact con=  TestDataFactory.createResourceContact(acc.id, false);
        con.EMS_RM_Employee_Id__c = 'CP10234';
        con.Resource_Role__c = role.Id;
        con.EMS_RM_ApplicantStatus_Update__c = 'Active';
        TriggerBase.bypass('Contact');
        insert con;
        
        Contact con1=  TestDataFactory.createResourceContact(acc.id, false);
        con1.EMS_RM_Employee_Id__c = 'CP10235';
        con1.Resource_Role__c = role.Id;
        con1.Email = 'testEmail+test1@cloudperitus.com';
        con.EMS_RM_ApplicantStatus_Update__c = 'Active';
        insert con1;
        TriggerBase.clearBypass('Contact');
        
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
        
        Resource_Resource_Relationship__c resourceRelationship = new Resource_Resource_Relationship__c();
        resourceRelationship.Resource__c = con.Id;
        resourceRelationship.Resource_Reports_To__c=con.Id;
        resourceRelationship.Relationship_Type__c = 'Mentor';
        insert resourceRelationship;
        
        User u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,false);
        u.Username = 'absc@admin.com';
        Insert u;
            
            User u1 = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con1.Id,true);
        con.EMS_TM_User__c = u1.Id;
        update con;
        
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
        
        List<PM_Configure__c> pmQuestionList = new List<PM_Configure__c>(); 
        Id questionRecordTypeId = Schema.SObjectType.PM_Configure__c.getRecordTypeInfosByName().get('Question').getRecordTypeId();
       PM_Configure__c pm = new PM_Configure__c();
       pm.Name__c = 'Associate Salesforce Developer - Development';
       pm.Question__c ='Development';
        pm.Answer_Type__c ='text';
        pm.Area__c='TECHNICAL SKILLS';
        pm.Active__c =true;
        pm.Rating_overview__c ='Adhere to coding standards, Implementations using OOB features, Know fundamentals ';
        pm.Question_overview__c ='Able to gain context of the current build with help from more senior developers, Able to reverse engineer certain classes to build their own understanding';
        pm.Configuration_Type__c ='KRA';
        pm.Description__c = '- Strives to write code that adheres to CPs Best Practices and Coding Standards documentation - Knows the fundamentals of Lightning Web Components such as wire service, security, and cross-component communication - Knows how to implement record-triggered flows and how to configure record pages for dynamic visibility without code - Is familiar with the governor limits and best practices when developing in Apex';
        pm.Resource_Role__c =role.Id;
        pm.RecordTypeId = questionRecordTypeId;
        pmQuestionList.add(pm);
       
            if(!pmQuestionList.Isempty()){
               insert pmQuestionList;
               system.debug('pmQuestionList----'+pmQuestionList);
             }          
   
        //try{
       List<PM_Configure__c> createPMConfigRecords = TestDataFactory.createPMConfigRecords(role.Id,con.Id,con.Id,project.Id,KRA.Id,true);
       system.debug('createPMConfigRecords----'+createPMConfigRecords);
       List<PM_Configure__c> updatedPmConfigRec = new List<PM_Configure__c>();
        for(PM_Configure__c createPMConfigRecords1 : createPMConfigRecords){
            createPMConfigRecords1.Rating__c=5;
            createPMConfigRecords1.Description__c='Test';
          createPMConfigRecords1.Status__c ='Submitted';
           updatedPmConfigRec.add(createPMConfigRecords1);
    }
        test.starttest();
        if(!updatedPmConfigRec.IsEmpty()){
          system.debug('updatedPmConfigRec----'+updatedPmConfigRec);

        update updatedPmConfigRec;
         }
        test.stoptest();
 
    }
    
    
    @isTest
    Public static void updateKraStatus(){           
        Goal__c Kra =[SELECT id from Goal__c limit 1];    
        Resource_Role__c role =[SELECT id from Resource_Role__c limit 1];  
        Contact con =[SELECT id FROM Contact where EMS_RM_Employee_Id__c = 'CP10234' limit 1];
        Contact con1 =[SELECT id FROM Contact where EMS_RM_Employee_Id__c = 'CP10235' limit 1];
         
        quarterlyKRAFullViewCtrl.getLoginAnswerdata(Kra.Id,'My Team');
        quarterlyKRAFullViewCtrl.getLoginAnswerdata(Kra.Id,'My Metric'); 
        quarterlyKRAFullViewCtrl.getPMConfigKRAFullDetails(Kra.Id,'My Team');
        quarterlyKRAFullViewCtrl.getPMConfigKRAFullDetails(Kra.Id,'My Metric');
        }
    
    @isTest
    Public static void submittedKraStatus(){           
        Goal__c Kra =[SELECT id from Goal__c limit 1];
        Kra.Mentor_KRA_submitted__c=true;
        update Kra;
        Resource_Role__c role =[SELECT id from Resource_Role__c limit 1];  
        Contact con =[SELECT id FROM Contact where EMS_RM_Employee_Id__c = 'CP10234' limit 1];
        Contact con1 =[SELECT id FROM Contact where EMS_RM_Employee_Id__c = 'CP10235' limit 1];
          
        quarterlyKRAFullViewCtrl.getPMConfigKRAFullDetails(Kra.Id,'My Metric');
        
        }
    
    @isTest
    Public static void completekraMethodStatus(){           
        Goal__c Kra =[SELECT id from Goal__c limit 1];
        quarterlyKRAFullViewCtrl.completekraMethod(Kra.Id);       
    }
}