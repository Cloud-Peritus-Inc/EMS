@istest
public class CalculateFullQuarterlyKRATEST {
    @testSetup
    static void setupTestData() {
        user adminuser = TestDataFactory.createAdminUser(true);         
        system.runAs(adminuser){
            
            User u = new User();
            Account acc = new Account();
            Contact con = new Contact();
            Contact con1 = new Contact();
            Goal__c Kra = new Goal__c();          
            
            EMS_LM_Leave__c  annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
            EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
            EMS_LM_Leave__c paidTimeOff = TestDataFactory.createLeaveType('Paid time off',true);
            Resource_Role__c role = TestDataFactory.createResourceRole(true);
            
            acc = TestDataFactory.createAccount(true);
            con=  TestDataFactory.createResourceContact(acc.id, false);
            con.EMS_RM_Employee_Id__c = 'CP10234';
            con.Resource_Role__c = role.Id;
            con.EMS_RM_ApplicantStatus_Update__c = 'Active';
            insert con;
            
            con1=  TestDataFactory.createResourceContact(acc.id, false);
            con1.EMS_RM_Employee_Id__c = 'CP10235';
            con1.Resource_Role__c = role.Id;
            con1.Email = 'testEmail+test1@cloudperitus.com';
            con.EMS_RM_ApplicantStatus_Update__c = 'Active';
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
            
            Resource_Resource_Relationship__c resourceRelationship = new Resource_Resource_Relationship__c();
            resourceRelationship.Resource__c = con.Id;
            resourceRelationship.Resource_Reports_To__c=con.Id;
            resourceRelationship.Relationship_Type__c = 'Mentor';
            insert resourceRelationship;
            
            u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
            con.EMS_TM_User__c = u.Id;
        	update con;
            
            Fiscal_Year__c FiscalYear = Testdatafactory.createFiscalYear(true);
            
            Fulfillment__c full = Testdatafactory.createFulfillment(con.Id,true);
            Kra = Testdatafactory.createKRARecords(con.Id, con1.Id, full, true);
            
             List<PM_Configure__c> pmQuestionList = new List<PM_Configure__c>(); 
        Id questionRecordTypeId = Schema.SObjectType.PM_Configure__c.getRecordTypeInfosByName().get('Question').getRecordTypeId();
            List<String> areas = new List<String>{
            'PROFESSIONAL SKILLS',
            'STRATEGIC IMPACT',
            'GOALS AND RESULTS',
            'TECHNICAL SKILLS'
        };
            
            for (String area : areas) {
       PM_Configure__c pm = new PM_Configure__c();
       pm.Name__c = 'Associate Salesforce Developer - Development';
       pm.Question__c ='Development';
        pm.Answer_Type__c ='text';
        pm.Area__c=area;
        pm.Active__c =true;
        pm.Rating_overview__c ='Adhere to coding standards, Implementations using OOB features, Know fundamentals ';
        pm.Question_overview__c ='Able to gain context of the current build with help from more senior developers, Able to reverse engineer certain classes to build their own understanding';
        pm.Configuration_Type__c ='KRA';
        pm.Description__c = '- Strives to write code that adheres to CPs Best Practices and Coding Standards documentation - Knows the fundamentals of Lightning Web Components such as wire service, security, and cross-component communication - Knows how to implement record-triggered flows and how to configure record pages for dynamic visibility without code - Is familiar with the governor limits and best practices when developing in Apex';
        pm.Resource_Role__c =role.Id;
        pm.RecordTypeId = questionRecordTypeId;
        pmQuestionList.add(pm); 
            }
       
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
    }
    
    testmethod static void  fullviewKRAMethod(){
        Test.startTest();
        Goal__c Kra = [Select Id,Name,Resource__c from Goal__c];
        Contact con = [Select Id,Name from Contact Where Id =:Kra.Resource__c ];     
        
        CalculateFullQuarterlyKRA.calculateAverageRatingForKRA(Kra.Id,'My Team');
        CalculateFullQuarterlyKRA.calculateAverageRatingForKRA(Kra.Id,'My Metric');
        
        Test.stopTest();
    }
    testmethod static void  myteamMymatricviewMethod(){
        Test.startTest();
        Goal__c Kra = [Select Id,Name,Resource__c,Mentor_KRA_submitted__c from Goal__c];
        Kra.Mentor_KRA_submitted__c =true;
        update kra;
        Contact con = [Select Id,Name from Contact Where Id =:Kra.Resource__c ];     
        
        CalculateFullQuarterlyKRA.calculateAverageRatingForKRA(Kra.Id,'My Metric');
        
        Test.stopTest();
    }
}