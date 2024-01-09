public without sharing class RRController {
public static final Id RR_WINNER_RECORDTYPEID = Schema.SObjectType.Reward_And_Recognition__c.getRecordTypeInfosByDeveloperName().get('Winners').getRecordTypeId();
public static final Id RR_NOMINATION_RECORDTYPEID = Schema.SObjectType.Reward_And_Recognition__c.getRecordTypeInfosByDeveloperName().get('Nominations').getRecordTypeId();
public static final Id RR_SCORING_RECORDTYPEID = Schema.SObjectType.Reward_And_Recognition__c.getRecordTypeInfosByDeveloperName().get('Scoring').getRecordTypeId();   
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
        Map<String,winnerdetails> winnerMap = new Map<String,winnerdetails>(); 
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
                                            AND Type__c = 'Annual Award' 
                                            AND Fiscal_Year__c IN:fyMap.values()]){
            if(currentFY == rr.Fiscal_Year__c){
                String uniqueKey = rr.Award_Type__c+rr.Resource__c;
                if(!winnerMap.containsKey(uniqueKey)){
                 winnerdetails wd = new winnerdetails();
                 wd.awardType = rr.Award_Type__c;
                 wd.currentFYName = rr.Fiscal_Year__r.Name;
                 wd.resourceName = rr.Resource__r.Name;
                 wd.resourcePhotoURL = rr.Resource__r.EMS_TM_User__r.FullPhotoUrl;
                 wd.awardComments = rr.Reason_for_award__c;
                 wd.resourceId = rr.Resource__c;
                 winnerMap.put(uniqueKey,wd);
                
                }
              
            }
            if(FywithNominations.containsKey(rr.Fiscal_Year__c)){
                FywithNominations.get(rr.Fiscal_Year__c).add(rr);
            }else{
                FywithNominations.put(rr.Fiscal_Year__c,new List<Reward_And_Recognition__c>{rr});  
            }
        }
         currentList.addAll(winnerMap.values());
        datawrapper dwrap = new datawrapper();
        dwrap.disableNominations = disableNom;
        dwrap.disableRecognize = disableRec;
        dwrap.showNominationstab = urecord.Contact.Resource_Role__r.Eligible_for_Nominations__c;
        dwrap.currentFYId = currentFY;
        dwrap.currentName = currentFYName;
        dwrap.scroingtab = FeatureManagement.checkPermission('Rew_and_Rec_Scoring_User');
        dwrap.awardList = getPickListValuesIntoList();
        dwrap.fyListMap = fyMap;
        dwrap.winnerrecordtypeId = RR_WINNER_RECORDTYPEID;
        dwrap.currentList = currentList;
        dwrap.FywithNominations = FywithNominations;
        return dwrap;
    }
    
     public static Map<String,String> getPickListValuesIntoList(){
       Map<String,String> pickListValuesList= new Map<String,String>();
         pickListValuesList.put('All','All');
		Schema.DescribeFieldResult fieldResult = Reward_And_Recognition__c.Award_Type__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			pickListValuesList.put(pickListVal.getlabel(),pickListVal.getValue());
		}     
		return pickListValuesList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<winnerdetails> getTheCurrentFYTrends(String fyId){
       List<winnerdetails> currentList = new List<winnerdetails>();    
         Map<String,winnerdetails> winnerMap = new Map<String,winnerdetails>(); 
        for(Reward_And_Recognition__c rr : [SELECT Id,Name,Resource__r.Name,Resource__r.EMS_TM_User__c,Reason_for_award__c,Resource__r.EMS_TM_User__r.FullPhotoUrl,
                                            Resource__c,Award_Type__c,Fiscal_Year__c,Project__c,RecordTypeId,Fiscal_Year__r.Name,
                                            Comments__c FROM Reward_And_Recognition__c 
                                            WHERE RecordTypeId =:RR_WINNER_RECORDTYPEID
                                            AND Type__c = 'Annual Award'
                                            AND Fiscal_Year__c=:fyId]){
           String uniqueKey = rr.Award_Type__c+rr.Resource__c;
                if(!winnerMap.containsKey(uniqueKey)){
                 winnerdetails wd = new winnerdetails();
                 wd.awardType = rr.Award_Type__c;
                 wd.currentFYName = rr.Fiscal_Year__r.Name;
                 wd.resourceName = rr.Resource__r.Name;
                 wd.resourcePhotoURL = rr.Resource__r.EMS_TM_User__r.FullPhotoUrl;
                 wd.awardComments = rr.Reason_for_award__c;
                wd.resourceId = rr.Resource__c;
               winnerMap.put(uniqueKey,wd);
                }
        }
       currentList.addAll(winnerMap.values());
 
        return  currentList;
    }
    
     @AuraEnabled
    public static List<winnerdetails> getShoutouts(String fyId){
         List<winnerdetails> currentList = new List<winnerdetails>();    
        system.debug('===fyId======'+fyId);
         system.debug('===Userinfo.getUserId()======'+Userinfo.getUserId());
        for(Reward_And_Recognition__c rr : [SELECT Id,Name,Resource__r.Name,Resource__r.EMS_TM_User__c,Reason_for_award__c,Resource__r.EMS_TM_User__r.FullPhotoUrl,
                                            Resource__c,Award_Type__c,Fiscal_Year__c,Project__c,Project__r.Name,RecordTypeId,Fiscal_Year__r.Name,Type__c,Type_of_Shout_Out__c,
                                            Comments__c,Shout_Out_Heading__c,CreatedDate FROM Reward_And_Recognition__c 
                                            WHERE RecordTypeId =:RR_WINNER_RECORDTYPEID
                                            AND Type__c = 'ShoutOut'
                                            AND Fiscal_Year__c=:fyId
                                            AND Recognization_By__c =:Userinfo.getUserId()]){
          
                winnerdetails wd = new winnerdetails();
                 wd.awardType = rr.Award_Type__c;
                 wd.currentFYName = rr.Fiscal_Year__r.Name;
                 wd.resourceName = rr.Resource__r.Name;
                 wd.spotType = rr.Type_of_Shout_Out__c;
                 wd.awardComments = rr.Reason_for_award__c;
                wd.resourceId = rr.Resource__c;
                wd.projectName = rr.Project__r.Name;
                wd.Title = rr.Shout_Out_Heading__c;
                wd.createdDate = Date.valueOf(rr.CreatedDate);
              currentList.add(wd);
        }
       
 
        return currentList;
    }
    
    @AuraEnabled
    public static List<winnerdetails> getRecGiven(String fyId){
         List<winnerdetails> currentList = new List<winnerdetails>();    
        system.debug('===fyId======'+fyId);
         system.debug('===Userinfo.getUserId()======'+Userinfo.getUserId());
        for(Reward_And_Recognition__c rr : [SELECT Id,Name,Resource__r.Name,Resource__r.EMS_TM_User__c,Reason_for_award__c,Resource__r.EMS_TM_User__r.FullPhotoUrl,
                                            Resource__c,Award_Type__c,Fiscal_Year__c,Project__c,Types_of_Recognition__c,Project__r.Name,RecordTypeId,Fiscal_Year__r.Name,Type__c,Type_of_Shout_Out__c,
                                            Comments__c,Shout_Out_Heading__c,CreatedDate FROM Reward_And_Recognition__c 
                                            WHERE RecordTypeId =:RR_WINNER_RECORDTYPEID
                                            AND Type__c = 'Recognize'
                                            AND Fiscal_Year__c=:fyId
                                            AND Recognization_By__c =:Userinfo.getUserId()]){
          
                winnerdetails wd = new winnerdetails();
                 wd.awardType = rr.Award_Type__c;
                 wd.currentFYName = rr.Fiscal_Year__r.Name;
                 wd.resourceName = rr.Resource__r.Name;
                 wd.spotType = rr.Types_of_Recognition__c;
                 wd.awardComments = rr.Reason_for_award__c;
                wd.resourceId = rr.Resource__c;
                wd.projectName = rr.Project__r.Name;
                wd.Title = rr.Shout_Out_Heading__c;
                wd.createdDate = Date.valueOf(rr.CreatedDate);
              currentList.add(wd);
        }
       
 
        return currentList;
    }
    
    @AuraEnabled
    public static List<winnerdetails> getRecReceived(String fyId){
         List<winnerdetails> currentList = new List<winnerdetails>();   
         User loggedinUser = [SELECT Id,ContactId FROM User WHERE Id=:Userinfo.getUserId()];
        system.debug('===fyId======'+fyId);
         system.debug('===Userinfo.getUserId()======'+Userinfo.getUserId());
        for(Reward_And_Recognition__c rr : [SELECT Id,Recognization_By__c,Recognization_By__r.Name,Name,Resource__r.Name,Resource__r.EMS_TM_User__c,Reason_for_award__c,Resource__r.EMS_TM_User__r.FullPhotoUrl,
                                            Resource__c,Award_Type__c,Fiscal_Year__c,Project__c,Types_of_Recognition__c,Project__r.Name,RecordTypeId,Fiscal_Year__r.Name,Type__c,Type_of_Shout_Out__c,
                                            Comments__c,Shout_Out_Heading__c,CreatedDate FROM Reward_And_Recognition__c 
                                            WHERE RecordTypeId =:RR_WINNER_RECORDTYPEID
                                            AND Type__c = 'Recognize'
                                            AND Fiscal_Year__c=:fyId
                                            AND Resource__c =:loggedinUser.ContactId]){
          
                winnerdetails wd = new winnerdetails();
                 wd.awardType = rr.Award_Type__c;
                 wd.currentFYName = rr.Fiscal_Year__r.Name;
                 wd.resourceName = rr.Recognization_By__r.Name;
                 wd.spotType = rr.Types_of_Recognition__c;
                 wd.awardComments = rr.Reason_for_award__c;
                wd.resourceId = rr.Recognization_By__c;
                wd.projectName = rr.Project__r.Name;
                wd.Title = rr.Shout_Out_Heading__c;
                wd.createdDate = Date.valueOf(rr.CreatedDate);
              currentList.add(wd);
        }
       
 
        return currentList;
    }
    
    @AuraEnabled
    public static List<winnerdetails> getMyAnnualAwards(String fyId){
         List<winnerdetails> currentList = new List<winnerdetails>();   
         User loggedinUser = [SELECT Id,ContactId FROM User WHERE Id=:Userinfo.getUserId()];
        system.debug('===fyId======'+fyId);
         system.debug('===Userinfo.getUserId()======'+Userinfo.getUserId());
        for(Reward_And_Recognition__c rr : [SELECT Id,Recognization_By__c,Recognization_By__r.Name,Name,Resource__r.Name,Resource__r.EMS_TM_User__c,Reason_for_award__c,Resource__r.EMS_TM_User__r.FullPhotoUrl,
                                            Resource__c,Award_Type__c,Fiscal_Year__c,Project__c,Types_of_Recognition__c,Project__r.Name,RecordTypeId,Fiscal_Year__r.Name,Type__c,Type_of_Shout_Out__c,
                                            Comments__c,Shout_Out_Heading__c,CreatedDate,Status__c FROM Reward_And_Recognition__c 
                                            WHERE RecordTypeId =:RR_WINNER_RECORDTYPEID
                                            AND Type__c = 'Annual Award'
                                            AND Resource__c =:loggedinUser.ContactId]){
          
                winnerdetails wd = new winnerdetails();
                 wd.awardType = rr.Award_Type__c;
                 wd.currentFYName = rr.Fiscal_Year__r.Name;
                 wd.resourceName = rr.Recognization_By__r.Name;
                 wd.spotType = rr.Types_of_Recognition__c;
                 wd.awardComments = rr.Reason_for_award__c;
                wd.resourceId = rr.Recognization_By__c;
                wd.projectName = rr.Project__r.Name;
                wd.Title = rr.Status__c;
                wd.createdDate = Date.valueOf(rr.CreatedDate);
              currentList.add(wd);
        }
        return currentList;
    }
    
    @AuraEnabled
    public static List<winnerdetails> getMyNomins(String fyId){
         List<winnerdetails> currentList = new List<winnerdetails>();   
         User loggedinUser = [SELECT Id,ContactId FROM User WHERE Id=:Userinfo.getUserId()];
        system.debug('===fyId======'+fyId);
         system.debug('===Userinfo.getUserId()======'+Userinfo.getUserId());
        for(Reward_And_Recognition__c rr : [SELECT Id,Recognization_By__c,Recognization_By__r.Name,Name,Resource__r.Name,Resource__r.EMS_TM_User__c,Reason_for_award__c,Resource__r.EMS_TM_User__r.FullPhotoUrl,
                                            Resource__c,Award_Type__c,Fiscal_Year__c,Project__c,Types_of_Recognition__c,Project__r.Name,RecordTypeId,Fiscal_Year__r.Name,Type__c,Type_of_Shout_Out__c,
                                            Comments__c,Shout_Out_Heading__c,CreatedDate,Status__c,RecordType.Name,of_Primary_Nominations__c,of_Secondary_Nominations__c FROM Reward_And_Recognition__c 
                                            WHERE Fiscal_Year__c=:fyId
                                            AND Type__c = 'Annual Award'
                                            AND Recognization_By__c =:loggedinUser.Id]){
          
                winnerdetails wd = new winnerdetails();
                 wd.awardType = rr.Award_Type__c;
                 wd.currentFYName = rr.of_Primary_Nominations__c != null ? string.valueOf(rr.of_Primary_Nominations__c) : '0';
                 wd.resourceName = rr.Resource__r.Name;
                 wd.spotType = rr.of_Secondary_Nominations__c != null ? String.valueOf(rr.of_Secondary_Nominations__c) : '0';
                 wd.awardComments = rr.Reason_for_award__c;
                wd.resourceId = rr.Resource__c;
                wd.projectName = rr.RecordType.Name;
                wd.Title = rr.Status__c;
                wd.createdDate = Date.valueOf(rr.CreatedDate);
              currentList.add(wd);
        }
        return currentList;
    }
    
    @AuraEnabled
    public static List<winnerdetails> getShoutoutsReceived(String fyId){
         List<winnerdetails> currentList = new List<winnerdetails>();   
         User loggedinUser = [SELECT Id,ContactId FROM User WHERE Id=:Userinfo.getUserId()];
        system.debug('===fyId======'+fyId);
         system.debug('===Userinfo.getUserId()======'+Userinfo.getUserId());
        for(Reward_And_Recognition__c rr : [SELECT Id,Recognization_By__c,Recognization_By__r.Name,Name,Resource__r.Name,Resource__r.EMS_TM_User__c,Reason_for_award__c,Resource__r.EMS_TM_User__r.FullPhotoUrl,
                                            Resource__c,Award_Type__c,Fiscal_Year__c,Project__c,Project__r.Name,RecordTypeId,Fiscal_Year__r.Name,Type__c,Type_of_Shout_Out__c,
                                            Comments__c,Shout_Out_Heading__c,CreatedDate FROM Reward_And_Recognition__c 
                                            WHERE RecordTypeId =:RR_WINNER_RECORDTYPEID
                                            AND Type__c = 'ShoutOut'
                                            AND Fiscal_Year__c=:fyId
                                            AND Resource__c =:loggedinUser.ContactId]){
          
                winnerdetails wd = new winnerdetails();
                 wd.awardType = rr.Award_Type__c;
                 wd.currentFYName = rr.Fiscal_Year__r.Name;
                 wd.resourceName = rr.Recognization_By__r.Name;
                 wd.spotType = rr.Type_of_Shout_Out__c;
                 wd.awardComments = rr.Reason_for_award__c;
                wd.resourceId = rr.Recognization_By__c;
                wd.projectName = rr.Project__r.Name;
                wd.Title = rr.Shout_Out_Heading__c;
                wd.createdDate = Date.valueOf(rr.CreatedDate);
               
              currentList.add(wd);
        }
       
 
        return currentList;
    }
    
     @AuraEnabled(cacheable=true)
    public static List<winnerdetails> getTheScoringbyAward(String fyId,String awardType){
        List<winnerdetails> currentList = new List<winnerdetails>();
        for(Reward_And_Recognition__c rr : [SELECT Id,Name,Resource__r.Name,Resource__r.EMS_TM_User__c,Reason_for_award__c,Resource__r.EMS_TM_User__r.FullPhotoUrl,System_Predicted_Status__c,
                                            Resource__c,Award_Type__c,Fiscal_Year__c,Status__c,Project__c,Project__r.Name,RecordTypeId,Fiscal_Year__r.Name,Type__c,Type_of_Shout_Out__c,
                                            Comments__c,of_Total_Nominations__c,of_Secondary_Nominations__c,of_Primary_Nominations__c,CreatedDate FROM Reward_And_Recognition__c 
                                            WHERE RecordTypeId =:RR_SCORING_RECORDTYPEID
                                            AND Fiscal_Year__c=:fyId
                                            AND Award_Type__c =:awardType]){
          
                 winnerdetails wd = new winnerdetails();
                 wd.awardType = rr.Award_Type__c;                             
                 wd.totalNoms = String.valueOf(rr.of_Total_Nominations__c);
                 wd.currentFYName = String.valueOf(rr.of_Primary_Nominations__c);                               
                 wd.resourceName = rr.Resource__r.Name;
                 wd.resourcePhotoURL = rr.Resource__r.EMS_TM_User__r.FullPhotoUrl;
                 wd.spotType = String.valueOf(rr.of_Secondary_Nominations__c);
                 wd.awardComments = rr.Reason_for_award__c;
                 wd.resourceId = rr.Id;
                 wd.projectName = rr.Comments__c;                       
                 wd.Title = rr.System_Predicted_Status__c;
                 wd.createdDate = Date.valueOf(rr.CreatedDate);
                 wd.statuss = rr.Status__c;
              currentList.add(wd);
        }
       
 
        return currentList;
    }
    
      @AuraEnabled(cacheable=true)
    public static List<datawrapper> getTheScoringbyAllAward(String fyId){
        List<winnerdetails> currentList = new List<winnerdetails>();
        Map<string,string> resourceWithImage = new Map<String,String>();
        Map<String,List<winnerdetails>> resourceWithAwards = new Map<String,List<winnerdetails>>();
        for(Reward_And_Recognition__c rr : [SELECT Id,Name,Resource__r.Name,Resource__r.EMS_TM_User__c,Reason_for_award__c,Resource__r.EMS_TM_User__r.FullPhotoUrl,System_Predicted_Status__c,
                                            Resource__c,Award_Type__c,Fiscal_Year__c,Project__c,Project__r.Name,RecordTypeId,Fiscal_Year__r.Name,Type__c,Type_of_Shout_Out__c,Status__c,
                                            Comments__c,of_Total_Nominations__c,of_Secondary_Nominations__c,of_Primary_Nominations__c,CreatedDate FROM Reward_And_Recognition__c 
                                            WHERE RecordTypeId =:RR_SCORING_RECORDTYPEID
                                            AND Fiscal_Year__c=:fyId]){
              resourceWithImage.put(rr.Resource__r.Name,rr.Resource__r.EMS_TM_User__r.FullPhotoUrl);
             if(resourceWithAwards.containsKey(rr.Resource__r.Name)){
                  winnerdetails wd = new winnerdetails();
                 wd.awardType = rr.Award_Type__c;                             
                 wd.totalNoms = String.valueOf(rr.of_Total_Nominations__c);
                 wd.currentFYName = String.valueOf(rr.of_Primary_Nominations__c);                               
                 wd.resourceName = rr.Resource__r.Name;
                 wd.resourcePhotoURL = rr.Resource__r.EMS_TM_User__r.FullPhotoUrl;
                 wd.spotType = String.valueOf(rr.of_Secondary_Nominations__c);
                 wd.awardComments = rr.Reason_for_award__c;
                 wd.resourceId = rr.Id;
                 wd.projectName = rr.Comments__c;
                 wd.Title = rr.System_Predicted_Status__c;
                 wd.createdDate = Date.valueOf(rr.CreatedDate);
                 wd.statuss = rr.Status__c;
                 resourceWithAwards.get(rr.Resource__r.Name).add(wd);
             }else{
                 winnerdetails wd = new winnerdetails();
                 wd.awardType = rr.Award_Type__c;                             
                 wd.totalNoms = String.valueOf(rr.of_Total_Nominations__c);
                 wd.currentFYName = String.valueOf(rr.of_Primary_Nominations__c);                               
                 wd.resourceName = rr.Resource__r.Name;
                 wd.resourcePhotoURL = rr.Resource__r.EMS_TM_User__r.FullPhotoUrl;
                 wd.spotType = String.valueOf(rr.of_Secondary_Nominations__c);
                 wd.awardComments = rr.Reason_for_award__c;
                 wd.resourceId = rr.Id;
                 wd.projectName = rr.Comments__c;
                 wd.Title = rr.System_Predicted_Status__c;
                 wd.createdDate = Date.valueOf(rr.CreatedDate);
                 wd.statuss = rr.Status__c;
                 resourceWithAwards.put(rr.Resource__r.Name, new List<winnerdetails>{wd}); 
             }
                 
        }
        List<datawrapper> dwList = new List<datawrapper>();
        for(String str : resourceWithAwards.keySet()){
            datawrapper des = new datawrapper();
            des.currentName = str;
            des.currentFYId = resourceWithImage.get(str);
            des.currentList = resourceWithAwards.get(str);
            dwList.add(des);
        }
        return dwList;
    }
    
    public class datawrapper {
        @AuraEnabled
        public boolean disableNominations;
        @AuraEnabled
        public boolean showNominationstab;
         @AuraEnabled
        public boolean scroingtab;
        @AuraEnabled
        public boolean disableRecognize;
        @AuraEnabled
        public String currentFYId;
        @AuraEnabled
        public String currentName;
        @AuraEnabled
        public Map<String,String> awardList;
        @AuraEnabled
        public String winnerrecordtypeId;
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
        @AuraEnabled
        public String spotType;
        @AuraEnabled
        public String Title;
        @AuraEnabled
        public String projectName;
        @AuraEnabled
        public String statuss;
        @AuraEnabled
        public Date createdDate;
        @AuraEnabled
        public String totalNoms;
    }

}