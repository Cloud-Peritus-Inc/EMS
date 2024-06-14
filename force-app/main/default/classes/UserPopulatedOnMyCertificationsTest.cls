@isTest
public class UserPopulatedOnMyCertificationsTest {
    /*@testSetup
static void setupTestData() {

user adminuser = TestDataFactory.createAdminUser(true); 
Resource_Role__c role;
EMS_LM_Leave__c annualtype;
EMS_LM_Leave__c loptype;
EMS_LM_Leave__c bretype;
EMS_LM_Leave__c compofftype;
EMS_LM_Leave__c paternitytype;
EMS_LM_Leave__c  Bereavementtype;
EMS_LM_Leave__c paidTimeOff;
Office_Location__c hydIndia;
Office_Location__c usLocation;


Account acc;Contact con;
system.runAs(adminuser){
role = TestDataFactory.createResourceRole(true);

annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
paternitytype = TestDataFactory.createLeaveType('Paternity Leave',true);
Bereavementtype = TestDataFactory.createLeaveType('Bereavement Leave',true);
paidTimeOff = TestDataFactory.createLeaveType('Paid time off',true);


hydIndia = TestDataFactory.createOfficeLocation('Hyderabad - India',true);
//usLocation = TestDataFactory.createOfficeLocation('United States of America',true);

acc = TestDataFactory.createAccount(true);
con=  TestDataFactory.createResourceContact(acc.id, false);
con.EMS_RM_Employee_Id__c = 'CP10234';
con.Resource_Role__c = role.Id;
con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
con.EMS_RM_ApplicantStatus_Update__c = 'Active';
con.RecordTypeId = ContactConstant.RESOURCE_RECORDTYPEID;
con.Work_Location__c = hydIndia.Id;
con.EMS_EM_JD__c = system.today() - 180;
insert con;
User u;
u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
Certifications__c certi=new Certifications__c();
certi.Type__c='Certification';
certi.Completion_Date__c=system.today();
certi.Certification_Name__c='Salesforce Certified Associate';
insert certi;
}
}*/
    
    @isTest
    static void testUpdateUsersAsync1() {
        //set EMS_RM_ApplicantStatus_Update__c to 'Inactive'
        /*Contact testContact = [SELECT Id,EMS_TM_User__c FROM Contact WHERE EMS_RM_ApplicantStatus_Update__c = 'Active' LIMIT 1];
        testContact.EMS_RM_ApplicantStatus_Update__c = 'Inactive';
        update testContact;
        List<Certifications__c>  cerList=new List<Certifications__c>();
        Certifications__c certi=new Certifications__c();
        certi.Type__c='Certification';
        certi.Completion_Date__c=system.today();
        certi.Certification_Name__c='Salesforce Certified Associate';
        cerList.add(certi);
        insert cerList;
        
        Test.startTest();
        UserPopulatedOnMyCertifications ref=new UserPopulatedOnMyCertifications();
        ref.userPopulatedOnMyCertificationsMethod(cerList);
        Test.stopTest();*/
    }
    
    @isTest
    static void testUpdateUsersAsync2(){
        Contact con = getContact();
        List<Certifications__c>  cerList=new List<Certifications__c>();
        for(Integer i = 0; i < 100; i ++) {
            Certifications__c certi=new Certifications__c();
            certi.Type__c='Certification';
            certi.Contact__c = con.Id;
            certi.Completion_Date__c=system.today();
            certi.Certification_Name__c='Salesforce Certified Associate';
            cerList.add(certi);
        }
        Test.startTest();
        insert cerList;
        Test.stopTest();        
    }
    
    @isTest
    static void testUpdateUsersAsync3(){
        List<Certifications__c>  cerList=new List<Certifications__c>();
        for(Integer i = 0; i < 100; i ++) {
            Certifications__c certi=new Certifications__c();
            certi.Type__c='Certification';
            certi.Completion_Date__c=system.today();
            certi.Certification_Name__c='Salesforce Certified Associate';
            cerList.add(certi);
        }
        Test.startTest();
        insert cerList;
        Test.stopTest();        
    }
    
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
        INSERT con1;
        return con1;
    }
    
    
}