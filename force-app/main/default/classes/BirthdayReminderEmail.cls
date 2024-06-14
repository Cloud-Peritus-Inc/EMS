public class BirthdayReminderEmail implements Database.Batchable<sObject>, schedulable{
    
    public void execute(System.SchedulableContext sc){
        Database.executeBatch(new BirthdayReminderEmail());
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(
            'select id, EMS_RM_Employee_Id__c, EMS_EM_DOB__c, Name, EMS_RM_ApplicantStatus_Update__c from Contact where (EMS_RM_ApplicantStatus_Update__c = \'Active\' or EMS_RM_ApplicantStatus_Update__c = \'Active - Probation\' OR EMS_RM_ApplicantStatus_Update__c = \'Notice Period\' ) and EMS_EM_DOB__c != null' 
        );
    }    
    
    public void execute(Database.BatchableContext bc, List<Contact> contactList){
        getBirthdays(contactList);
    }
    
    public static void getBirthdays(List<Contact> birthdayList){
        Date todayDate = System.today();
        List<Contact> birthdaysInSameWeek = new List<Contact>();
        
        for(Contact contactRec : birthdayList){
            Date birthdayCurrentYearDate = Date.newInstance(todayDate.year(), contactRec.EMS_EM_DOB__c.month(), contactRec.EMS_EM_DOB__c.day());
            if(todayDate.toStartOfWeek() == birthdayCurrentYearDate.toStartOfWeek()){
                birthdaysInSameWeek.add(contactRec);
            }
        } 
        
        for(Contact con : birthdaysInSameWeek){
            System.debug('Contact => '+con);
        }
        
        if(birthdaysInSameWeek.size() > 0){
            String emailContent = prepareEmailContent(birthdaysInSameWeek);
            sendEmailToHr(emailContent);
        }
    }
    
    private Static String prepareEmailContent(List<Contact> employees) {
        
        String gridLogo = System.label.Grid_Logo;
        String cpLogo = System.label.CP_Logo;
        
        //String imageUrl = 'https://cpprd--dev.sandbox.file.force.com/servlet/servlet.ImageServer?id=015520000010400&oid=00D52000000L5oZ&lastMod=1674198511000'; 
        //String imageUrl2 = 'https://cpprd--dev.sandbox.file.force.com/servlet/servlet.ImageServer?id=015520000010Wtm&oid=00D52000000L5oZ&lastMod=1675396590000'; 
        
        
        //String imageUrl = URL.getSalesforceBaseUrl().toExternalForm() + PageReference.forResource('CP_Logo').getUrl();
        
        
        String htmlBody = '<html><body style="padding: 25px; border-style: groove;">';
        htmlBody += '<img src="' + gridLogo + '" alt="Image Description"' + 'width="'+ 60 + '"' + ' height="' + 90+ '" >';
        //htmlBody += '<img src="{$Resource.CP_Logo}"' + '" alt="{$Resource.CP_Logo}"' + 'width="'+ 100 + '"' + ' height="' + 100 + '" >';
        htmlBody += '<br>';
        htmlBody += 'Dear HR Team,';
        htmlBody += '<br><br>';
        htmlBody += 'Please find the attached list of employees celebrating their birthdays this week. Please plan to celebrate the birthdays in the office.';
        htmlBody += '<br><br>';
        htmlBody += 'Birthdays are an opportunity to celebrate the unique individuals who contribute to our company\'s success. By acknowledging and rejoicing in our employees\' special days, we foster a culture of appreciation, unity, and motivation. Let\'s make every birthday a reminder of our commitment to creating a positive and supportive work environment.';
        htmlBody += '<br><br>';
        htmlBody += '<table border="2" style="width:80%; border-collapse: collapse; margin-left: auto; margin-right: auto; text-align: center;"><tr><th style="width:20%; background-color:#6904c8; color: #FFFFFF;">CP ID</th><th style="width:40%; background-color:#6904c8; color: #FFFFFF;">Name of the Employee</th><th style="width:20%; background-color:#6904c8; color: #FFFFFF;">Date of Birth</th></tr>';
        
        
        for(Contact employee : employees){            
            
            String cpId = employee.EMS_RM_Employee_Id__c; if(employee.EMS_RM_Employee_Id__c == null){cpId = '[Not Provided]';}
            String empName = employee.Name; if(employee.Name == null){empName = '[Not Provided]';}
            String empDOB = employee.EMS_EM_DOB__c.format(); if(employee.EMS_EM_DOB__c == null){empName = '[Not Provided]';}
            
            htmlBody += '<tr><td>' + cpId + '</td><td>' + empName + '</td><td>' + empDOB + '</td></tr>';  
        
        htmlBody += '</table>';
        htmlBody += '<br>';
        htmlBody += 'Regards,';
        htmlBody += '<br>';
        htmlBody += 'The Cloud Peritus Team';
        htmlBody += '<br><br>';
        htmlBody += '<p style="text-align:center;" ><img src="' + cpLogo + '" alt="Image Description"' + 'width="'+ 100 + '"' + ' height="' + 50+ '"></p>';
        htmlBody += '</body></html>';
        }
        return htmlBody;
    }
    
    public static void sendEmailToHr(String emailContent){
        
        String hrEmail = [SELECT id, DeveloperName, Email__c from Employee_Details__mdt WHERE DeveloperName = 'HR_Team' LIMIT 1].Email__c;
        List<String> hrEmailList = new List<String>();
        hrEmailList.add(hrEmail);
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(hrEmailList);
        email.setSubject('Birthday Reminder - Upcoming Birthdays this week');
        email.setHTMLbody(emailContent);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }
    
    public void finish(Database.BatchableContext bc){ 
        
    }
    
}