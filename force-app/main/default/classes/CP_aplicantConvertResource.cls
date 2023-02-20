/**
    * @author Mukesh Rawat
    * @date 2/02/2023
    * @description  recordTypeChangeByLWC to Convert Record Type Applicant to Resource on Contact Object
    *
    *               Test code coverage provided by the following test class:
    *               - CP_ConvertButtonOnOnboardingTest     
    *
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/
public class CP_aplicantConvertResource {
    
    @AuraEnabled   
    public static Contact recordTypeChangeByLWC(String Id,Contact newcon){
        map<id, contact> oldContact;
        RecordType recordId= [SELECT Id, 
                              Name, 
                              IsActive 
                              FROM RecordType where name ='Applicant'and IsActive =true];
        RecordType recordId2= [SELECT Id, 
                               Name, 
                               IsActive 
                               FROM RecordType where name ='Resource'and IsActive =true];
        
        newcon=[Select Id,
                LastName,
                RecordTypeId 
                FROM Contact where Id=:Id ];
        
        
        newcon.RecordTypeId = recordId2.id;
        update newcon;
        return null;
        
        
    }

}