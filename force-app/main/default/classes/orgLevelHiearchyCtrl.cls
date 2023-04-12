public class orgLevelHiearchyCtrl {

    
    @AuraEnabled(cacheable=true)
    public static string getinfo(){
        user urec = [SELECT Id,FullPhotoUrl,ContactId FROM User Where Id=:Userinfo.getUserId()];
        Id conId = '0035200000n04s2AAA';
        return 'String';
    }
}