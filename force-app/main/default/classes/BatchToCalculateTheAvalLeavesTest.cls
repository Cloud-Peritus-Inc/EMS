@isTest
public class BatchToCalculateTheAvalLeavesTest {
    
    public static testMethod void testBatchclass() {
        user adminuser = TestDataFactory.createAdminUser(true);
        User testUser = [SELECT Id FROM User WHERE Username = 'lokesh.onkolu@cloudperitus.com' LIMIT 1];
        user adminuser2 = TestDataFactory.createAdminUser(true);
        Resource_Role__c role;
        Resource_Resource_Relationship__c rrr;
        Contact conRRR;
        EMS_LM_Leave__c annualtype;
        EMS_LM_Leave__c loptype1;
        EMS_LM_Leave__c loptype;
        EMS_LM_Leave__c bretype;
        EMS_LM_Leave__c compofftype;
        EMS_LM_Leave__c paternitytype;
        EMS_LM_Leave__c  Bereavementtype;
        
        Account acc;Contact con;
        system.runAs(adminuser){
            role = TestDataFactory.createResourceRole(true);
            annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            loptype1 = TestDataFactory.createLeaveType('Paid time off',true);
            //bretype  = TestDataFactory.createLeaveType('Maternity Leave',true);
            compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            paternitytype = TestDataFactory.createLeaveType('Paternity Leave',true);
            Bereavementtype = TestDataFactory.createLeaveType('Bereavement Leave',true);
            acc = TestDataFactory.createAccount(true);
            con=  TestDataFactory.createResourceContact(acc.id, false);
            con.EMS_RM_Employee_Id__c = 'CP10234';
            con.Resource_Role__c = role.Id;
            con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
            con.EMS_RM_ApplicantStatus_Update__c = 'Active';
            con.RecordTypeId = ContactConstant.RESOURCE_RECORDTYPEID;
            insert con;
            
            conRRR=TestDataFactory.createResourceContactForRRR(acc.id, false);
            conRRR.EMS_RM_Employee_Id__c = 'CP10235';
            conRRR.Resource_Role__c = role.Id;
            conRRR.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
            conRRR.EMS_LM_No_Of_Leaves_Credit__c = 10;
            insert conRRR;
            rrr = TestDataFactory.createRRR(con.Id, true, conRRR.Id);
            system.debug('---Resource Relationship---'+conRRR);
             system.debug('---Contact List---'+conRRR);
        }
        
        
        Test.startTest();
        User u;
        //system.runAs(adminuser){
            
            u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
            
        //}
        system.runAs(adminuser2){
            EMS_LM_Leave_Credit__c lcreditAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),1.6,annualtype.id, true);
            EMS_LM_Leave_Credit__c lcreditAnnual1 = Testdatafactory.createLeaveCredit(con.id,system.today(),10,loptype1.id, true);
            // EMS_LM_Leave_Credit__c bretAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),20,bretype.id, true);
            EMS_LM_Leave_Credit__c commOffAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),1,compofftype.id, true);
            EMS_LM_Leave_Credit__c patAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),1,paternitytype.id, true); 
            EMS_LM_Leave_Credit__c berveAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),1,Bereavementtype.id, true);
            
        }
        system.runAs(testUser){
            List<EMS_LM_Leave_History__c> hlist = new List<EMS_LM_Leave_History__c>();
            hlist.add(TestDataFactory.createLeaveRequest(con.id, system.today(), system.today().adddays(400), annualtype.id, false, null));
            // hlist.add(TestDataFactory.createLeaveRequest(con.id, system.today().adddays(90), system.today(440).adddays(7), loptype1.id, true, 'pending'));
            hlist.add(TestDataFactory.createLeaveRequest(con.id, system.today().adddays(8), system.today().adddays(405), compofftype.id, false, null));
            hlist.add(TestDataFactory.createLeaveRequest(con.id, system.today().adddays(7), system.today().adddays(900), paternitytype.id, false, null));
            hlist.add(TestDataFactory.createLeaveRequest(con.id, system.today().adddays(7), system.today().adddays(910), Bereavementtype.id, false, null));
            insert hlist;
            system.debug('-----Leave requests------'+hlist);
        }  
        TriggerBase.bypass('Contact');
        BatchToCalculateTheAvailableLeaves  batchExecute = new BatchToCalculateTheAvailableLeaves(); 
        Database.executeBatch(batchExecute,10);
        TriggerBase.clearBypass('Contact');
        Test.stopTest();
    }    
    
    public static testMethod void testscheduleclass() {
        Test.StartTest();
        
        BatchToCalculateTheAvaiLeaves_sch testsche = new BatchToCalculateTheAvaiLeaves_sch();
        String sch = '0 0 23 * * ?';
        system.schedule('Test BatchToCalculateTheAvaiLeaves Check', sch, testsche );
        Test.stopTest();
    }
    
}