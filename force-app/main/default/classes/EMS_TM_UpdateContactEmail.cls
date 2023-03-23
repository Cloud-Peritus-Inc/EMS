public class EMS_TM_UpdateContactEmail {
    
    public static void updatecontactEmail(List<contact> conList){
        System.debug('conList'+conList);
        set<id> conids = new set<id>();
        for(contact con: conList){
            
            //  con.Email = con.EMS_RM_Resource_Email_id__c;
            con.EMS_RM_Resource_Email_id__c = Con.Official_Mail__c;  
            con.Email = Con.Official_Mail__c;
            conids.add(con.id);
        }
        
    }
    
    public static void sendWelcomeMailtoEmployee(List<contact> conList, map<id, contact> oldContact){
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>(); 
        List<string>  oficialMailIds = new List<string>(); 
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where name ='Welcome to  Cloud Peritus mail'];
        OrgWideEmailAddress emailid = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress where DisplayName ='Cloud Peritus'];
        
        System.debug('emailTemplate'+emailTemplate);
        for(contact conData:conList){
            if( conData.Official_Mail__c != oldContact.get(conData.id).Official_Mail__c){
                oficialMailIds.add(conData.Official_Mail__c);
                
                System.debug('oficialMailIds'+oficialMailIds);
                Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
                
                mail.setToAddresses(oficialMailIds);
                mail.setOrgWideEmailAddressId(emailid.Id);
                mail.setTemplateID(emailTemplate.Id);
                mail.setTargetObjectId(conData.id);
                mail.setSaveAsActivity(false);         
                mail.setTreatTargetObjectAsRecipient(false);
                
                System.debug('mail '+mail); 
                mails.add(mail);
                
            }        
        }
        System.debug('mails'+mails);
        Messaging.sendEmail(mails);
    }
    
    public static void updateAnnualLeave(List<contact> conList) {
        List<EMS_LM_Leave_Credit__c> leaveCreditList = new List<EMS_LM_Leave_Credit__c>();
        List<Contact> cList = new List<Contact>();
        Id rTypeId = [SELECT Id FROM RecordType where name = 'Resource'].Id;
        for(Contact cnt: conList) {
        if(cnt.RecordTypeId == rTypeId){
        cList.add(cnt);
        }
        }
        
        for(Contact cntct: cList) {
            date myDate = cntct.EMS_EM_JD__c;
            Integer day = myDate.day();
            Integer month = myDate.month();
            
            EMS_LM_Leave_Credit__c leaveCredit = new EMS_LM_Leave_Credit__c();
            leaveCredit.EMS_LM_Employee__c = cntct.Id;
            leaveCredit.EMS_LM_Leave_Credited_Date__c = System.today();
            leaveCredit.EMS_LM_Select_Leave_Type__c = 'Annual Leave';
            
            if(month == 1 || month == 4 || month == 7 || month == 10) {
                if(day <= 15 ) {
                    leaveCredit.EMS_LM_Leaves_Credited__c = 5;
                    leaveCreditList.add(leaveCredit);
                } else {
                    leaveCredit.EMS_LM_Leaves_Credited__c = 3.33;
                    leaveCreditList.add(leaveCredit);
                }
            } 
            else if(month == 2 || month == 5 || month == 8 || month == 11) {
                if(day <= 15 ) {
                    leaveCredit.EMS_LM_Leaves_Credited__c = 3.33;
                    leaveCreditList.add(leaveCredit);
                } else {
                    leaveCredit.EMS_LM_Leaves_Credited__c = 1.66;
                    leaveCreditList.add(leaveCredit);
                }
            } 
            else if(month == 3 || month == 6 || month == 9 || month == 12) {
                if(day <= 15 ) {
                    leaveCredit.EMS_LM_Leaves_Credited__c = 1.66;
                    leaveCreditList.add(leaveCredit);
                } else {
                    leaveCredit.EMS_LM_Leaves_Credited__c = 0;
                    leaveCreditList.add(leaveCredit);
                }
            }
        }
        
        try {
            if(leaveCreditList.Size() > 0) {
                insert leaveCreditList;
            }
        } catch(Exception e) {
            System.debug(e);
        }
    }
}