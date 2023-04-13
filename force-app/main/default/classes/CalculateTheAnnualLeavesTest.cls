@isTest
public class CalculateTheAnnualLeavesTest {
	public static testmethod void updateResourceLeavesTest(){
        
       
         user adminuser = TestDataFactory.createAdminUser(true);
        
         user adminuser2 = TestDataFactory.createAdminUser(true);
        Resource_Role__c role;
       EMS_LM_Leave__c annualtype;
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
            con.EMS_EM_JD__c = system.today() - 180;
         insert con;
        }
       
        
         Test.startTest();
         User u;
         system.runAs(adminuser){
        
         u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
         
        }
        system.runAs(adminuser2){
         EMS_LM_Leave_Credit__c lcreditAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),1.6,annualtype.id, true);
         EMS_LM_Leave_Credit__c commOffAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),1,compofftype.id, true);
           EMS_LM_Leave_Credit__c patAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),1,paternitytype.id, true); 
            EMS_LM_Leave_Credit__c berveAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),1,Bereavementtype.id, true);
        }
        system.runAs(u){
          List<EMS_LM_Leave_History__c> hlist = new List<EMS_LM_Leave_History__c>();
         hlist.add(TestDataFactory.createLeaveRequest(con.id, system.today(), system.today().adddays(1), annualtype.id, false, null));
          hlist.add(TestDataFactory.createLeaveRequest(con.id, system.today().adddays(8), system.today().adddays(9), compofftype.id, false, null));
            hlist.add(TestDataFactory.createLeaveRequest(con.id, system.today().adddays(7), system.today().adddays(9), paternitytype.id, false, null));
             hlist.add(TestDataFactory.createLeaveRequest(con.id, system.today().adddays(7), system.today().adddays(9), Bereavementtype.id, false, null));
         insert hlist;
        }
        test.stopTest();
        System.assertEquals(1.66, 1.66);
    }    
}