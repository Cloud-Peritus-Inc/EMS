/**
* @author Subba Kalavala
* @date 01/03/2023
* @description  mySkillsAndCertifcations Class to show the data on Home page for certification details
*
*               Test code coverage provided by the following test class:
*               - mySkillsAndCertifcationsTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public class mySkillsAndCertifcations {
    
@AuraEnabled(cacheable=true)
public static datawrapper getMyCertificationsAndSkills(){
        List<Certifications__c> certSkillList = new List<Certifications__c>();
        List<skillCert> skillList = new List<skillCert>();
        User uRec = [SELECT Id,ContactId FROM User WHERE Id=:Userinfo.getUserId()];
        certSkillList = [SELECT id,Name,contact__c,Certification_Name__c,Other__c,Completion_Date__c,Last_Used_Project_Name__c,Skill__r.Name,Skill__c,Skill_Rating__c,Type__c FROM Certifications__c WHERE contact__c=:uRec.ContactId];
        for(Certifications__c exp : certSkillList){
          
           skillCert ex = new skillCert();
            if(exp.Type__c == 'Skill'){
                ex.name = exp.Skill__r.Name; 
                ex.isSkill = true;
                ex.rating = exp.Skill_Rating__c;
            }else{
                ex.name = exp.Certification_Name__c != 'Other' ? exp.Certification_Name__c : exp.Other__c; 
                ex.certifcationdate = exp.Completion_Date__c;
                 ex.isSkill = false;
            }
            ex.typeval = exp.Type__c;
            ex.recordid = exp.Id;

            skillList.add(ex);
        }
        datawrapper dw = new datawrapper();
        dw.resourceId = uRec.ContactId;
        dw.skillList=skillList;
        return dw;
    }
    
    public class datawrapper {
        @AuraEnabled
        public string resourceId;
        @AuraEnabled
        public List<skillCert> skillList;
    }
    
    public class skillCert{
        @AuraEnabled
        public string name;
         @AuraEnabled
        public Date certifcationdate;
         @AuraEnabled
        public boolean isSkill;
         @AuraEnabled
        public string typeval;
        @AuraEnabled
        public string rating;
         @AuraEnabled
        public string recordid;
        
    }

}