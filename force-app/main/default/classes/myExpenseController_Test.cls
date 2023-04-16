@isTest
public class myExpenseController_Test {
    
       public static testmethod void checkTheLoggedInUserAssignmentDetails(){
 
        user adminuser = TestDataFactory.createAdminUser(true);
        Resource_Role__c role;
        Account acc;
        Contact con;
        EMS_TM_Project__c projectRec;
        EMS_LM_Leave__c annualtype;
        system.runAs(adminuser){
            
            role = TestDataFactory.createResourceRole('Software Engineer',true);
            annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
            EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
            
            Office_Location__c officlocRec =TestDataFactory.createOfficeLocation('Hhyderabad',true);
            acc = TestDataFactory.createAccount(true);
            con=TestDataFactory.createResourceContact(acc.id, false);
            con.EMS_RM_Employee_Id__c = 'CP10234';
            con.Resource_Role__c = role.Id;
            con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
            con.EMS_LM_No_Of_Leaves_Credit__c = 10;
            con.Work_Location__c = officlocRec.Id;
            insert con;       
            System.debug('con'+ con);
          projectRec = new EMS_TM_Project__c();
        projectRec.EMS_TM_StartDate__c = System.today();
        projectRec.EMS_TM_EndDate__c = System.today()+10;
        projectRec.EMS_TM_Status__c = 'ongoing';
        projectRec.Name = 'project1';
        projectRec.Project_Manager__c = con.Id;
        projectRec.Type_Of_Project__c ='Client Projects';
        INSERT projectRec; 
        }
        User u;
        Test.startTest();
        system.runAs(adminuser){
            u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
        }
           Contact conRec =[Select id,name,EMS_TM_user__c from contact where id =:con.Id];
           System.debug('****ConRec'+conRec);
          Expense__c expRec;
          system.runAs(u){
               expRec = new Expense__c();
              expRec.Expense_Amount__c =500;
              expRec.Project__c = projectRec.Id;
              expRec.Resource__c = con.Id;
              expRec.Billing_Currency__c ='USD';
              expRec.Status__c ='Submitted';
              Insert expRec;
           }
           Expense__c exp =[Select id,Status__c from Expense__c];
           System.debug('***exp'+exp);
           myExpenseController.getMyExpenseReport();
           myExpenseController.checkTheExpense(expRec.Id);
           String status ='Submitted';
          // myExpenseController.updateAndGetData(expRec.Id, status);
          //myExpenseController.updateforApproval(expRec.Id,'Submitted');
         Test.stopTest();
    }

}