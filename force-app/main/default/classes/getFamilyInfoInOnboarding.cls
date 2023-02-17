public class getFamilyInfoInOnboarding {
    
    @AuraEnabled(cacheable=true)
    public static getFamilyInformaition getFamilyInfo(String contactId){
        List<Family_Information__c> listfamilyrecords = new List<Family_Information__c>();
        try{
            listfamilyrecords = [SELECT Id,
                                 IsDeleted, 
                                 Name, 
                                 CreatedDate, 
                                 CreatedById,
                                 Contact_Email_Address__c,
                                 Contact_Phone_Number__c,
                                 Date_of_Birth__c,
                                 Resource__c,
                                 Relationships__c,
                                 Is_It_Emergency_Contact__c,
                                 Family_Member_Name__c
                                 FROM Family_Information__c Where Resource__c =:contactId LIMIT 5];
        }Catch(Exception ex){
            System.debug('### Exception Occured With'+ex.getStackTraceString());
            System.debug('### Exception Occured With'+ex.getMessage());
            listfamilyrecords = null;
        }  
        getFamilyInformaition wrapper = new getFamilyInformaition();
        
        wrapper.listfamilyrecords = listfamilyrecords;
        return wrapper;
    }
    
    public class getFamilyInformaition{
        @AuraEnabled
        public List<Family_Information__c> listfamilyrecords;
    }
    
}