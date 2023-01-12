@isTest
public class EMS_EM_MedicalInsuranceControllerTest {
    private static testmethod void MedicalInsuranceMethodTest(){
        List<EMS_EM_Dependents__c> listEmsEmDependents = new List<EMS_EM_Dependents__c>();
        contact Con = new Contact();
        con.firstname = 'Test';
        con.lastname = 'data';
        insert con;
        EMS_EM_Dependents__c dependentRecord = new EMS_EM_Dependents__c();
        dependentRecord.Name = 'Test1';
        dependentRecord.EMS_EM_Date_of_Birth__c = date.parse('06/07/2012');
        dependentRecord.EMS_EM_Relationship_to_Nominee__c = 'Child';
        dependentRecord.EMS_EM_Contact__c = con.Id;
        insert dependentRecord;
        EMS_EM_Benefits__c benefitRecord = new EMS_EM_Benefits__c();
        benefitRecord.EMS_EM_Nominee__c = con.Id;
        benefitRecord.EMS_EM_Valid_From__c = date.parse('06/07/2022');
        benefitRecord.EMS_EM_Membership_No__c = '5842gh';
        benefitRecord.EMS_EM_Relationship__c = 'Employee';
        insert benefitRecord;
        test.startTest();
        EMS_EM_MedicalInsuranceController.MedicalInsuranceMethod(con.Id);
        test.stopTest();
    }
    
}