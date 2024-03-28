@isTest
public class BatchToCreateGoalsForRes_Test {
    public static testMethod void testscheduleclass() {
		Test.StartTest();
		BatchToCreateGoalsForRes_Sch testsche = new BatchToCreateGoalsForRes_Sch();
		String sch = '0 0 23 * * ?';
		system.schedule('Test BatchToCalculateTheAvaiLeaves Check', sch, testsche );
		Test.stopTest();
	}
    
        public static testMethod void testBatchclass() {
       
            user adminuser = TestDataFactory.createAdminUser(true);
        Resource_Role__c role;
        Account acc;
        Contact con;
        Contact conRRR;
        Resource_Resource_Relationship__c rrr;
        EMS_LM_Leave__c annualtype;
        system.runAs(adminuser){
            role = TestDataFactory.createResourceRole('Software Engineer',true);
            annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
            EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true); 
               EMS_LM_Leave__c paidtimeof = TestDataFactory.createLeaveType('Paid time off',true);
        EMS_LM_Leave__c unpaidTimeOff = TestDataFactory.createLeaveType('UnPaid time off',true);
        EMS_LM_Leave__c floatingholiday = TestDataFactory.createLeaveType('Floating Holiday',true);
            acc = TestDataFactory.createAccount(true);
            con=TestDataFactory.createResourceContact(acc.id, false);
            con.EMS_RM_Employee_Id__c = 'CP10234';
            con.Resource_Role__c = role.Id;
            con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
            con.EMS_LM_No_Of_Leaves_Credit__c = 10;
            con.EMS_RM_ApplicantStatus_Update__c = 'Active';
            system.debug('----Contact insert----'+con);
            insert con;
        }
        User u;
        
        system.runAs(adminuser){
            u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
        }
            system.runAs(adminuser){
                    con.EMS_TM_User__c = u.Id;
                    update con;
                }
            System.runAs(u){
       Grid_Configuration__c gc = Testdatafactory.createGridConfig('namevalue','test description','Org Level Goal',null,true);
            }
        
         Test.startTest();
             BatchToCreateGoalsForRes batchExecute = new BatchToCreateGoalsForRes(); 
             Database.executeBatch(batchExecute,1);
         Test.stopTest();
    } 
    
            public static testMethod void testBatchclass2() {
      
            user adminuser = TestDataFactory.createAdminUser(true);
        Resource_Role__c role;
        Account acc;
        Contact con;
        Contact conRRR;
        Resource_Resource_Relationship__c rrr;
        EMS_LM_Leave__c annualtype;
        system.runAs(adminuser){
            role = TestDataFactory.createResourceRole('Software Engineer',true);
            annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
            EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);  
            EMS_LM_Leave__c paidtimeof = TestDataFactory.createLeaveType('Paid time off',true);
            acc = TestDataFactory.createAccount(true);
            con=TestDataFactory.createResourceContact(acc.id, false);
            con.EMS_RM_Employee_Id__c = 'CP10234';
            con.Resource_Role__c = role.Id;
            con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
            con.EMS_LM_No_Of_Leaves_Credit__c = 10;

            con.EMS_RM_ApplicantStatus_Update__c = 'Active';
           
            system.debug('----Contact insert----'+con);
            insert con;
        }
        User u;
       
        system.runAs(adminuser){
            u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
        }
                system.runAs(adminuser){
                    con.EMS_TM_User__c = u.Id;
                    update con;
                }
            System.runAs(u){
         List<Grid_Configuration__c> gCon = new List<Grid_Configuration__c>();
            
        gCon.add(Testdatafactory.createGridConfig('namevalue Role Resource','test descrsdsiption','Resource Role Level Goal',role.id,false));
        insert gCon;
            }
         Test.startTest();
             BatchToCreateGoalsForRes batchExecute = new BatchToCreateGoalsForRes(); 
             Database.executeBatch(batchExecute,1);
         Test.stopTest();
    } 
}