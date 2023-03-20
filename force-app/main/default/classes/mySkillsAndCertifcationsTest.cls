@isTest
public class mySkillsAndCertifcationsTest {
    public testmethod static void skillCreationTest(){
         Resource_Role__c role = TestDataFactory.createResourceRole(true);
         TestDataFactory.createLeaveType(true);
         Account acc = TestDataFactory.createAccount(true);
		 Contact con=  TestDataFactory.createResourceContact(acc.id, false);
         con.EMS_RM_Employee_Id__c = 'CP10234';
         con.Resource_Role__c = role.Id;
         insert con;
        User u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
        Skill__c sl = new Skill__c();
        sl.Name = 'Test Skill';
        insert sl;
        system.runAs(u){
         Certifications__c cert = new Certifications__c();
         cert.Certification_Name__c = 'Other';
         cert.Other__c = 'Test Other';
         cert.Completion_Date__c = system.today();
         cert.Contact__c = con.Id;
         cert.Type__c = 'Certification';
         insert cert;
            
         Certifications__c cert2 = new Certifications__c();
         cert2.Contact__c = con.Id;
         cert2.Type__c = 'Skill';
         cert2.Skill_Rating__c = '5';
         cert2.Skill__c = sl.Id;
         insert cert2;
         Test.startTest();
          mySkillsAndCertifcations.getMyCertificationsAndSkills();
         Test.stopTest();
        } 
    }
}