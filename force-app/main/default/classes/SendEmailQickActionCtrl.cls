public with sharing class SendEmailQickActionCtrl {
    public String email {get;set;}
    public String fullName {get;set;}
    public String ccEmail {get;set;}
    public String bccEmail {get;set;}
    
    public PageReference sendOnBoardingEmail() {
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        EmailTemplate emailTemplate = [SELECT Subject, DeveloperName, Name, Id, HtmlValue,EmailTemplate.Body FROM EmailTemplate WHERE DeveloperName ='EMS_EM_OnboardingEmail'];
        System.debug(emailTemplate);
        String htmlBody = emailTemplate.HtmlValue;
        htmlBody = htmlBody.replace('{!FullName}', fullName);
        htmlBody = htmlBody.replace('{!EmailId}', email); 
        
        String plainBody = emailTemplate.Body;
        plainBody = plainBody.replace('{!FullName}', fullName);
        plainBody = plainBody.replace('{!EmailId}', email);
        
        mail.setUseSignature(false);
        mail.setToAddresses(new String[] { email });
        if(ccEmail != null && ccEmail.trim() != '' ){
            if(Pattern.matches('^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[com]{2,4}$', ccEmail)){
             mail.setCCAddresses(new String[] { ccEmail });
            }
            else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter valid CC E-mail Id address'));
            return null;   
        }
        }
        
        if(bccEmail!= null&& bccEmail.trim() != ''){
            if(Pattern.matches('^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[com]{2,4}$', bccEmail)){
             mail.setBCCAddresses(new String[] { bccEmail });
            }
            else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter valid BCC E-mail Id address'));
            return null;   
        }
            
        }
        mail.setSubject('Welcome to Cloud Peritus!');
        
        //mail.setTemplateID(emailTemplate.Id); 
        mail.setHtmlBody(htmlBody);
        mail.setPlainTextBody(plainBody);
        system.debug('mail is'+mail.getToAddresses());
        // Send the email
        string checkEmail = email;
        if(!Pattern.matches('^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[com]{2,4}$', email)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter valid E-mail Id address'));
            return null;
        }
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        PageReference onPage = new PageReference ('/lightning/o/EMS_EM_Onboarding_Request__c/list?filterName=Recent'); 
        onPage.setRedirect(true);
        return onPage;
    }
    
}