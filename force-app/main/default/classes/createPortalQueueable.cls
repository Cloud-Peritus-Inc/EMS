public without sharing class createPortalQueueable implements Queueable {
    public String contactupdate;
    public createPortalQueueable(String contactupdate) {
        this.contactupdate = contactupdate;
       
    }
    public void execute(QueueableContext context) {
       List<Contact> conList = (List<Contact>) JSON.deserialize(contactupdate, List<Contact>.class);
       
         try{
       
       update conList;  
        
        }catch(exception ex){
           system.debug('==ex=='+ex);
             LogException.logHandledException(ex, 'createPortalQueueable', 'execute');  
        }
       
    }
    
    

}