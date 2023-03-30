public without sharing class RRController {
public static final Id RR_WINNER_RECORDTYPEID = Schema.SObjectType.Reward_And_Recognition__c.getRecordTypeInfosByDeveloperName().get('Winners').getRecordTypeId();
public static final Id RR_NOMINATION_RECORDTYPEID = Schema.SObjectType.Reward_And_Recognition__c.getRecordTypeInfosByDeveloperName().get('Nominations').getRecordTypeId();
   
@AuraEnabled(cacheable=true)
    public static datawrapper getTheCurrentRRTrends(){
        user urecord = [SELECT Id,ContactId,Contact.Resource_Role__r.Eligible_for_Recognise__c,Contact.Resource_Role__r.Eligible_for_Nominations__c FROM User WHERE Id=:Userinfo.getUserId()];
        Boolean disableNom = true;
        Boolean disableRec = true;
                          
        if(urecord.Contact.Resource_Role__r.Eligible_for_Nominations__c){
            if(Boolean.valueOf(Label.Enable_Nominations)){
                disableNom = false;
            } 
        }
        if(urecord.Contact.Resource_Role__r.Eligible_for_Recognise__c){
            disableRec = false;
        }
        
        Map<String,String> fyMap = new Map<String,String>();
        Id currentFY;
        String currentFYName;
        Date currentdate = system.today();
        Map<String,List<Reward_And_Recognition__c>> FywithNominations = new Map<String,List<Reward_And_Recognition__c>>();
        List<winnerdetails> currentList = new List<winnerdetails>();
        
        for(Fiscal_Year__c fy : [SELECT Id,Name,Start_Date__c,End_Date__c FROM Fiscal_Year__c Order BY Start_Date__c ASC]){
            if(fy.Start_Date__c <= currentdate && fy.End_Date__c >= currentdate){
               currentFY = fy.Id;
               currentFYName = fy.Id;
            }
            fyMap.put(fy.Name,fy.Id);
        }
        
        for(Reward_And_Recognition__c rr : [SELECT Id,Name,Resource__r.Name,Resource__r.EMS_TM_User__c,Reason_for_award__c,Resource__r.EMS_TM_User__r.FullPhotoUrl,
                                            Resource__c,Award_Type__c,Fiscal_Year__c,Project__c,RecordTypeId,Fiscal_Year__r.Name,
                                            Comments__c FROM Reward_And_Recognition__c 
                                            WHERE RecordTypeId =:RR_WINNER_RECORDTYPEID
                                            AND Fiscal_Year__c IN:fyMap.values()]){
            if(currentFY == rr.Fiscal_Year__c){
                winnerdetails wd = new winnerdetails();
                wd.awardType = rr.Award_Type__c;
                 wd.currentFYName = rr.Fiscal_Year__r.Name;
                 wd.resourceName = rr.Resource__r.Name;
                 wd.resourcePhotoURL = rr.Resource__r.EMS_TM_User__r.FullPhotoUrl;
                 wd.awardComments = rr.Reason_for_award__c;
                wd.resourceId = rr.Resource__c;
            currentList.add(wd);
            }
            if(FywithNominations.containsKey(rr.Fiscal_Year__c)){
                FywithNominations.get(rr.Fiscal_Year__c).add(rr);
            }else{
                FywithNominations.put(rr.Fiscal_Year__c,new List<Reward_And_Recognition__c>{rr});  
            }
        }
        datawrapper dwrap = new datawrapper();
        dwrap.disableNominations = disableNom;
        dwrap.disableRecognize = disableRec;
        dwrap.currentFYId = currentFY;
        dwrap.currentName = currentFYName;
        dwrap.fyListMap = fyMap;
        dwrap.currentList = currentList;
        dwrap.FywithNominations = FywithNominations;
        return dwrap;
    }
    
    public class datawrapper {
        @AuraEnabled
        public boolean disableNominations;
        @AuraEnabled
        public boolean disableRecognize;
        @AuraEnabled
        public String currentFYId;
        @AuraEnabled
        public String currentName;
        @AuraEnabled
        public Map<String,String> fyListMap;
        @AuraEnabled
        public List<winnerdetails> currentList;
        @AuraEnabled
        public Map<String,List<Reward_And_Recognition__c>> FywithNominations;
    }
    
    public class winnerdetails{
        @AuraEnabled
        public String awardType;
        @AuraEnabled
        public String currentFYName;
        @AuraEnabled
        public String resourceName;
        @AuraEnabled
        public String resourcePhotoURL;
        @AuraEnabled
        public String awardComments;
         @AuraEnabled
        public String resourceId;
    }

}