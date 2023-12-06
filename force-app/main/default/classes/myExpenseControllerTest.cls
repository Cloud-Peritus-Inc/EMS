@Istest
public class myExpenseControllerTest {

    /*public static void getMyExpenseRepo(){
        user adminuser;
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            user adminuser2 = TestDataFactory.createAdminUser(true);
          adminuser = TestDataFactory.createAdminUser(true);
        }
        EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
        EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
        EMS_LM_Leave__c workfromhome = TestDataFactory.createLeaveType('Work From Home',true);
        EMS_LM_Leave__c paidTimeOff = TestDataFactory.createLeaveType('Paid time off',true);
        Office_Location__c officlocRec =TestDataFactory.createOfficeLocation('Hhyderabad',true);
        account acc=Testdatafactory.createAccount(True);
        
        Contact con2=  TestDataFactory.createResourceContact(acc.id, false);
        con2.EMS_RM_Employee_Id__c = 'CP10236';
        //con2.Resource_Role__c = role.Id;
         //con2.ReportsToId=adminuser2.contactId;
        con2.EMS_RM_ApplicantStatus_Update__c='active';
        con2.Email = 'testEmail+test1@cloudperitus1.com';
        con2.Work_Location__c=officlocRec.Id;
        insert con2;
        
      // system.debug('userid==================================='+userid);
        EMS_TM_Project__c projectRec = new EMS_TM_Project__c();
        projectRec.EMS_TM_StartDate__c = System.today();
        projectRec.EMS_TM_EndDate__c = System.today()+10;
        projectRec.EMS_TM_Status__c = 'ongoing';
        projectRec.Name = 'project1';
        projectRec.Project_Manager__c = con2.Id;
        projectRec.Type_Of_Project__c ='global Projects';
        INSERT projectRec;
        EMS_TM_Project__c projectRec1 = new EMS_TM_Project__c();
        projectRec1.EMS_TM_StartDate__c = System.today();
        projectRec1.EMS_TM_EndDate__c = System.today()+11;
        projectRec1.EMS_TM_Status__c = 'ongoing';
        projectRec1.Name = 'project3';
        projectRec1.Project_Manager__c = con2.Id;
        projectRec1.Type_Of_Project__c ='global Projects';
        INSERT projectRec1;
        expense__c exp=new expense__c();
        exp.Resource__c=con2.Id;
        exp.Project__c=projectRec.Id;
        exp.Expense_Type__c='Certification';
        exp.Expense_Amount__c=10000;
        exp.Status__c='Submitted';
        exp.Billing_Currency__c='INR';
        insert exp;
           system.runAs(adminuser){
             EMS_TM_Assignment__c assignmentRec = new EMS_TM_Assignment__c();
        assignmentRec.EMS_TM_EmployeeName__c = con2.Id;
        assignmentRec.EMS_TM_ProjectName_Asgn__c = projectRec.Id;
        assignmentRec.EMS_TM_StartDate_Asgn__c = system.today();
        assignmentRec.EMS_TM_Billable__c = true;
        assignmentRec.EMS_TM_AssignedAs__c='Administrator';
        assignmentRec.Project_Allocation__c=1;
               system.debug('EMS_TM_ProjectName_Asgn__c id iss========='+assignmentRec.EMS_TM_ProjectName_Asgn__c);
               system.debug('EMS_TM_ProjectName_Asgn__c id iss========='+assignmentRec.EMS_TM_EmployeeName__c);
        INSERT assignmentRec;
           }
             string getexpid= exp.Id;
            String base64 = EncodingUtil.base64Encode(Blob.valueOf('Test file contents'));
            String filename = 'TestFile.txt';
            
            
        try{
             myExpenseController.uploadFile(base64,filename,getexpid);
             myExpenseController.getMyExpenseReport();
        myExpenseController.updateAndGetData(exp.Id,'Submitted');
        myExpenseController.checkTheExpense(exp.Id);
        myExpenseController.updateforApproval(exp.Id,'Approved');
        
        //myExpenseController.getProjectsAssignedToLoggedInContact(con.Id);
        }catch(exception e){
            system.debug('error============='+e.getMessage());
        }
       
    } */
    public static testmethod void getMyExpenseReportTest(){
        user user;
             EMS_LM_Leave__c  annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
            EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
            EMS_LM_Leave__c paidTimeOff = TestDataFactory.createLeaveType('Paid time off',true);
          EMS_LM_Leave__c paidtimeof = TestDataFactory.createLeaveType('Paid time off',true);
               EMS_LM_Leave__c unpaidTimeOff = TestDataFactory.createLeaveType('UnPaid time off',true);
               EMS_LM_Leave__c floatingholiday = TestDataFactory.createLeaveType('Floating Holiday',true);
         Resource_Role__c role = TestDataFactory.createResourceRole(true);
        Account acc = TestDataFactory.createAccount(true);
         Contact contac=  TestDataFactory.createResourceContact(acc.id, false);
        contac.EMS_RM_Employee_Id__c = 'CP10234';
        contac.Resource_Role__c = role.Id;
        insert contac;
         
            
//            User u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
        
        Contact con2=  TestDataFactory.createResourceContact(acc.id, false);
        con2.EMS_RM_Employee_Id__c = 'CP10236';
        con2.Resource_Role__c = role.Id;
        con2.EMS_RM_ApplicantStatus_Update__c='active';
        con2.Email = 'testEmail+test1@cloudperitus1.com';
        con2.Work_Location__c=TestDataFactory.createOfficeLocation(true).Id;
        insert con2;
       EMS_TM_Project__c projectRec = new EMS_TM_Project__c();
        projectRec.EMS_TM_StartDate__c = System.today();
        projectRec.EMS_TM_EndDate__c = System.today()+10;
        projectRec.EMS_TM_Status__c = 'ongoing';
        projectRec.Name = 'project1';
        projectRec.Project_Manager__c = con2.Id;
        projectRec.Type_Of_Project__c ='global Projects';
        INSERT projectRec;
        EMS_TM_Project__c projectRec1 = new EMS_TM_Project__c();
        projectRec1.EMS_TM_StartDate__c = System.today();
        projectRec1.EMS_TM_EndDate__c = System.today()+12;
        projectRec1.EMS_TM_Status__c = 'ongoing';
        projectRec1.Name = 'project1';
        projectRec1.Project_Manager__c = con2.id;
        projectRec1.Type_Of_Project__c ='global Projects';
        INSERT projectRec1;
        expense__c exp=new expense__c();
        exp.Resource__c=con2.Id;
        exp.Amount1__c=100000;
        //exp.CreatedDate=System.now();
        exp.Reimbursed_Date__c=System.today()+1;
        exp.Project__c=projectRec.Id;
        exp.Expense_Type__c='Certification';
        exp.Expense_Amount__c=10000;
        exp.Status__c='Submitted';
        exp.Billing_Currency__c='INR';
        exp.is_Reimbursed__c=true;
        insert exp;
        expense__c exp1=new expense__c();
        exp1.Resource__c=con2.Id;
        exp1.Amount1__c=100000;
        //exp.CreatedDate=System.now();
        exp1.Reimbursed_Date__c=System.today()+1;
        exp1.Project__c=null;
        exp1.Expense_Type__c='Certification';
        exp1.Expense_Amount__c=10000;
        exp1.Status__c='Submitted';
        exp1.Billing_Currency__c='INR';
        exp1.is_Reimbursed__c=true;
        insert exp1;
        system.debug('the ===== ***'+exp);
            //  user userid=Userinfo.getUserId();
                User currentUser = [SELECT Id FROM User WHERE Profile.name ='System Administrator' AND IsActive =: TRUE LIMIT 1];

            system.runAs(currentUser){
       // User currentUser = [SELECT Id FROM User WHERE Profile.name ='System Administrator' AND IsActive =: TRUE LIMIT 1];
          contact contact=[select ID,Name from contact where EMS_RM_Employee_Id__c='CP10236'];
               Profile pf= [Select Id from profile where Name='Employee - Resource(Community)']; 
                             UserRole portalRole = [Select Id From UserRole Limit 1]; 
                String orgId=UserInfo.getOrganizationId(); 
                String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
                    network network=[select id,name from network where Name='Grid'];
                 Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
                String uniqueName=orgId+dateString+RandomId; 
                        contact con=new contact();
                         user=new User(firstname = 'ABC', 
                                 lastName = 'XYZ', 
                                 email = uniqueName + '@test' + orgId + '.org', 
                                 Username = uniqueName + '@test' + orgId + '.org', 
                                 EmailEncodingKey = 'ISO-8859-1', 
                                 Alias = uniqueName.substring(18, 23), 
                                 TimeZoneSidKey = 'America/Los_Angeles', 
                                 LocaleSidKey = 'en_US', 
                                 LanguageLocaleKey = 'en_US', 
                                 ProfileId = pf.Id, 
                                  contactid=contact.Id,
                                 Hr_Access__c =true,Manager_Access__c=True); 
                   insert user;
    }
            
        string getexpid= exp.Id;
            String base64 = EncodingUtil.base64Encode(Blob.valueOf('Test file contents'));
            String filename = 'TestFile.txt';
        system.debug('getexpid=================================='+getexpid);
        system.debug('base64=================================='+base64);
        system.debug('filename=================================='+filename);
        system.runAs(user){
            Test.startTest();
       
        myExpenseController.getMyExpenseReport();
        myExpenseController.updateAndGetData(exp.Id,'Submitted');
        myExpenseController.checkTheExpense(exp.Id);
        myExpenseController.updateforApproval(exp.Id,'Approved');
        myExpenseController.getProjectsAssignedToLoggedInContact(con2.id);
            try{
                 myExpenseController.uploadFile(base64,filename,getexpid);
            }catch(exception e){
                system.debug('error======='+e.getMessage());
            }
        Test.stopTest(); 
        }
    }
       

    }