@isTest
public class CalculateTheAnnualLeavesTest {
	/*public static testmethod void updateResourceLeavesTest(){
        
       
         user adminuser = TestDataFactory.createAdminUser(true);
         user adminuser2 = TestDataFactory.createAdminUser(true);
        Resource_Role__c role;
       EMS_LM_Leave__c annualtype;
        EMS_LM_Leave__c loptype;
        EMS_LM_Leave__c bretype;
        EMS_LM_Leave__c compofftype;
        EMS_LM_Leave__c paternitytype;
       EMS_LM_Leave__c  Bereavementtype;
       EMS_LM_Leave__c paidtimeof;
        Office_Location__c hydIndia;
        Office_Location__c usLocation;
            
        Account acc;Contact con;
        system.runAs(adminuser){
           role = TestDataFactory.createResourceRole(true);
         annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
         loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        //bretype  = TestDataFactory.createLeaveType('Maternity Leave',true);
         compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            paternitytype = TestDataFactory.createLeaveType('Paternity Leave',true);
            Bereavementtype = TestDataFactory.createLeaveType('Bereavement Leave',true);
             paidtimeof = TestDataFactory.createLeaveType('Paid time off',true);
          acc = TestDataFactory.createAccount(true);
            
        Office_Location__c HYD = new Office_Location__c();
        HYD.Name = 'Hyderabad - India';
        HYD.Address__c = 'Jubilee Hills. Road No 36';
        HYD.Country__c = 'India';
        HYD.Timezone__c = 'Asia/Kolkata';
        INSERT HYD;
            
		 con=  TestDataFactory.createResourceContact(acc.id, false);
         con.EMS_RM_Employee_Id__c = 'CP10234';
         con.Resource_Role__c = role.Id;
         con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
         con.EMS_RM_ApplicantStatus_Update__c = 'Active';
         con.RecordTypeId = ContactConstant.RESOURCE_RECORDTYPEID;
         con.Work_Location__c = HYD.Id;
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
            EMS_LM_Leave_Credit__c paidtof = Testdatafactory.createLeaveCredit(con.id,system.today(),1,paidtimeof.id, true);
        }
        system.runAs(u){
          List<EMS_LM_Leave_History__c> hlist = new List<EMS_LM_Leave_History__c>();
         hlist.add(TestDataFactory.createLeaveRequest(con.id, system.today(), system.today().adddays(1), annualtype.id, false, null));
          hlist.add(TestDataFactory.createLeaveRequest(con.id, system.today().adddays(8), system.today().adddays(9), compofftype.id, false, null));
            hlist.add(TestDataFactory.createLeaveRequest(con.id, system.today().adddays(7), system.today().adddays(9), paternitytype.id, false, null));
             hlist.add(TestDataFactory.createLeaveRequest(con.id, system.today().adddays(7), system.today().adddays(9), Bereavementtype.id, false, null));
            hlist.add(TestDataFactory.createLeaveRequest(con.id, system.today().adddays(7), system.today().adddays(9), paidtimeof.id, false, null));
         insert hlist;
        }
        test.stopTest();
        System.assertEquals(1.66, 1.66);
    } */ 
    
    public static Contact getContact(){
        user userId =[SELECT id FROM User  WHERE IsActive = true LIMIT 1];        
        
        Resource_Role__c role = TestDataFactory.createResourceRole(false);
        role.Name ='Sr Project Manager';
        insert role;
        
        //Work Location
        Office_Location__c HYD = new Office_Location__c();
        HYD.Name = 'Hyderabad - India';
        HYD.Address__c = 'Jubilee Hills. Road No 36';
        HYD.Country__c = 'India';
        HYD.Timezone__c = 'Asia/Kolkata';
        INSERT HYD;
        
        Office_Location__c USA = new Office_Location__c();
        USA.Name = 'California - USA';
        USA.Country__c = 'United States of America';
        USA.Address__c = '3000 Executive Parkway Suite 215, San Ramon, CA 94583 USA';
        USA.Timezone__c = 'America/Los_Angeles';
        INSERT USA;
        
        EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
        EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
        EMS_LM_Leave__c workfromhome = TestDataFactory.createLeaveType('Work From Home',true);
        EMS_LM_Leave__c paidTimeOff = TestDataFactory.createLeaveType('Paid time off',true);
        Account acc = TestDataFactory.createAccount(true);
                
        Contact con1=  TestDataFactory.createResourceContact(acc.id, false);
        con1.EMS_RM_Employee_Id__c = 'CP10236';
        con1.Email='ramakrishna.papana@cloudperitus2.com';
        con1.EMS_RM_ApplicantStatus_Update__c ='Active';
        con1.EMS_Phone_Number__c ='0123456789';
        con1.EMS_EM_CAddress_Line_1__c ='USA';
        con1.EMS_EM_CA_City__c ='USA';
        con1.EMS_EM_CA_State__c ='LA';
        con1.Work_Location__c = USA.Id;
        con1.Timesheet_NoNeed__c =false;
        con1.Resource_Role__c = role.Id;
        con1.EMS_TM_User__c =UserId.Id;
        con1.EMS_EM_JD__c = system.today();
        con1.RecordTypeId = ContactConstant.RESOURCE_RECORDTYPEID;
        INSERT con1;
        return con1;
    }

@isTest
static void testUpdateUsersAsync2(){
contact con = getContact();
con.EMS_EM_JD__c = system.today(); 
  update con;      
}
    
   // @isTest
/*static void testUpdateUsersAsync3(){
contact con = getContact();
 con.EMS_EM_JD__c = system.today(); 
  update con;  
}*/
    
    

}