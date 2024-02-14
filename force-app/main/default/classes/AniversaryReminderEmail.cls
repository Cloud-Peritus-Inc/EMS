public class AniversaryReminderEmail implements Database.Batchable<sObject>, schedulable{
    integer years;
        
        public void execute(System.SchedulableContext sc){
            Database.executeBatch(new AniversaryReminderEmail());
        }
        
        public Database.QueryLocator start(Database.BatchableContext bc){
            string query='select id, EMS_RM_Employee_Id__c,EMS_EM_JD__c, Name, EMS_RM_ApplicantStatus_Update__c  from Contact where (EMS_RM_ApplicantStatus_Update__c = \'Active\' OR EMS_RM_ApplicantStatus_Update__c = \'Active - Probation\' OR EMS_RM_ApplicantStatus_Update__c = \'Notice Period\') AND EMS_EM_JD__c!= null';
                 system.debug('query  ================'+query);
            return Database.getQueryLocator(query);
           
        }    
        
        public void execute(Database.BatchableContext bc, List<Contact> AnniversaryList){
            List<Contact> AnniversaryInSameWeek = new List<Contact>();
            Date todayDate = System.today();
            for(Contact contactRec : AnniversaryList){
                Date aniversaryCurrentYearDate = Date.newInstance(todayDate.year(), contactRec.EMS_EM_JD__c.month(), contactRec.EMS_EM_JD__c.day());
                system.debug('aniversaryCurrentYearDate ---------------------'+aniversaryCurrentYearDate);
                  years=calculateYearsWithCP(contactRec.EMS_EM_JD__c);
                if( years >= 1 && todayDate.toStartOfWeek() == aniversaryCurrentYearDate.toStartOfWeek()){
                AnniversaryInSameWeek.add(contactRec);
                    years=calculateYearsWithCP(contactRec.EMS_EM_JD__c);
                    system.debug('years---------------------------------------------------'+years);
            }
            }
            if (!AnniversaryInSameWeek.isEmpty()) {
                    system.debug('years============================================'+years);
                    String emailContent = prepareEmailContent(AnniversaryInSameWeek);
               
                                 sendEmailToHR(emailContent);                    
               
                
                          
        }
            }
        
             
        public void finish(Database.BatchableContext bc){ 
            
        }
       public  Integer calculateYearsWithCP(Date joiningDate) {
        // Calculate the number of years the employee has been with CP
        Date today = Date.today();
        Integer years = today.year() - joiningDate.year();
          system.debug('years  ========================='+years);
        return years;
    }
    	 @TestVisible
          private String prepareEmailContent(List<Contact> employees) {
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
        htmlBody += 'Please find the attached list of employees celebrating their Anniversary  this week. Please plan to celebrate the anniversary in the office.';
        htmlBody += '<br><br>';
        htmlBody += 'Anniversary are an opportunity to celebrate the unique individuals who contribute to our company\'s success. By acknowledging and rejoicing in our employees\' special days, we foster a culture of appreciation, unity, and motivation. Let\'s make every birthday a reminder of our commitment to creating a positive and supportive work environment.';
        htmlBody += '<br><br>';
        htmlBody += '<table border="2" style="width:80%; border-collapse: collapse; margin-left: auto; margin-right: auto; text-align: center;"><tr><th style="width:20%; background-color:#6904c8; color: #FFFFFF;">CP ID</th><th style="width:40%; background-color:#6904c8; color: #FFFFFF;">Name of the Employee</th><th style="width:20%; background-color:#6904c8; color: #FFFFFF;">Date of Joining</th><th style="width:40%; background-color:#6904c8; color: #FFFFFF;">Number Of years</th></tr>';
        
        
           for(Contact employee : employees){            
            
            String cpId = employee.EMS_RM_Employee_Id__c; if(employee.EMS_RM_Employee_Id__c == null){cpId = '[Not Provided]';}
            String empName = employee.Name; if(employee.Name == null){empName = '[Not Provided]';}
            String empJOD = employee.EMS_EM_JD__c.format(); if(employee.EMS_EM_JD__c == null){empName = '[Not Provided]';}
            integer years=calculateYearsWithCP(employee.EMS_EM_JD__c);
            
            htmlBody += '<tr><td>' + cpId + '</td><td>' + empName + '</td><td>' + empJOD + '</td><td>' + years + '</td></tr>';  
        }
        htmlBody += '</table>';
        htmlBody += '<br>';
        htmlBody += 'Regards,';
        htmlBody += '<br>';
        htmlBody += 'The Cloud Peritus Team';
        htmlBody += '<br><br>';
        htmlBody += '<p style="text-align:center;" ><img src="' + cpLogo + '" alt="Image Description"' + 'width="'+ 100 + '"' + ' height="' + 50+ '"></p>';
        htmlBody += '</body></html>';
        
        return htmlBody;
        
    } 
        @TestVisible
        private void sendEmailToHR(String emailContent) {
        String hrEmail = [SELECT id, DeveloperName, Email__c from Employee_Details__mdt WHERE DeveloperName = 'HR_Team' LIMIT 1].Email__c;
        List<String> hrEmailList = new List<String>();
        hrEmailList.add(hrEmail);
        // Send the email to HR with the employee anniversary details
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(hrEmailList);
        email.setSubject('Work Anniversary Reminder - Upcoming Work Anniversaries this week');
        email.setHtmlBody(emailContent);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }
    }