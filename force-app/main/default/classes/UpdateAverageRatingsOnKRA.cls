public class UpdateAverageRatingsOnKRA implements TriggerAction.BeforeUpdate {
    
    public void beforeUpdate(List<Goal__c> newList, List<Goal__c> oldList) {
        updateAverageRatings(newList, new Map<Id, Goal__c>(oldList));
    }
    
    public void updateAverageRatings(List<Goal__c> newList, Map<Id, Goal__c> oldMap) {
        System.debug('method ');
        Set<Id> completedKRAIds = new Set<Id>(); 
        
        for (Goal__c gl : newList) {
            if (gl.Status__c != oldMap.get(gl.Id).Status__c && gl.Status__c == 'KRA Completed' ) {
                System.debug('Status__c '+gl.Status__c);
                completedKRAIds.add(gl.Id);
                System.debug('completedKRAIds '+completedKRAIds);
            }
        }
        
        List<PM_Configure__c> filteredPmConfigList = getFilteredPMConfigList(completedKRAIds);
        System.debug('filteredPmConfigList2 '+filteredPmConfigList);
        calculateAndSetAverageRatings(completedKRAIds, filteredPmConfigList);
    }
    
    private List<PM_Configure__c> getFilteredPMConfigList(Set<Id> completedKRAIds) {
        
        List<PM_Configure__c> filteredPmConfigList = new List<PM_Configure__c>();
        Id answerRecordTypeId = Schema.SObjectType.PM_Configure__c.getRecordTypeInfosByName().get('Answer').getRecordTypeId();
        
       
         List<PM_Configure__c> pmConfigList = [SELECT Id
                                               , Name
                                               , KRA__c
                                               , Related_Question__r.Area__c
                                               , Mentor_Mentee__c
                                               , KRA__r.Resource__c
                                               , Rating__c 
            									FROM PM_Configure__c 
            									WHERE RecordTypeId = :answerRecordTypeId AND KRA__c IN :completedKRAIds
                                                AND Related_Question__c != NULL 
                                                AND Related_Question__r.Area__c != NULL];
        
        System.debug('pmConfigList '+pmConfigList);
        
        if(!pmConfigList.isEmpty()){
            for (PM_Configure__c pmConfig : pmConfigList) {
                if (pmConfig.Mentor_Mentee__c != pmConfig.KRA__r.Resource__c) {
                    filteredPmConfigList.add(pmConfig);
                }
            }
        }
        System.debug('filteredPmConfigList '+filteredPmConfigList);
        return filteredPmConfigList;
    } 
    
    private void calculateAndSetAverageRatings(Set<Id> completedKRAIds, List<PM_Configure__c> filteredPmConfigList) {
        
        Set<Id> resourceIds = new Set<Id>();
        Decimal techSkillSum = 0;
        Integer techSkillNo = 0;
        Decimal profSkillSum = 0;
        Integer profSkillNo = 0;
        Decimal strategicSum = 0;
        Integer strategicNo = 0;
        Decimal goalResultSum = 0;
        Integer goalResultNo = 0;
        
        System.debug('filteredPmConfigList size: ' + filteredPmConfigList.size());
        
        if (filteredPmConfigList != null) {
            for (PM_Configure__c pmAns : filteredPmConfigList) {
                if (pmAns.Related_Question__r != null && pmAns.Related_Question__r.Area__c != null && pmAns.Rating__c != null) {
                    if (pmAns.Related_Question__r.Area__c == 'TECHNICAL SKILLS') {
                        techSkillSum += pmAns.Rating__c;
                        techSkillNo++;
                    } else if (pmAns.Related_Question__r.Area__c == 'PROFESSIONAL SKILLS') {
                        profSkillSum += pmAns.Rating__c;
                        profSkillNo++;
                    } else if (pmAns.Related_Question__r.Area__c == 'STRATEGIC IMPACT') {
                        strategicSum += pmAns.Rating__c;
                        strategicNo++;
                    } else if (pmAns.Related_Question__r.Area__c == 'GOALS AND RESULTS') {
                        goalResultSum += pmAns.Rating__c;
                        System.debug('Rating ' + pmAns.Rating__c);
                        System.debug('goalResultSum ' + goalResultSum);
                        goalResultNo++;
                        System.debug('goalResultNo ' + goalResultNo);
                    }
                }
            }
        }
        
        Decimal avgTechSkillRating = techSkillNo > 0 ? techSkillSum / techSkillNo : 0;
        Decimal avgProfSkillRating = profSkillNo > 0 ? profSkillSum / profSkillNo : 0;
        Decimal avgStrategicRating = strategicNo > 0 ? strategicSum / strategicNo : 0;
        Decimal avgGoalResultRating = goalResultNo > 0 ? goalResultSum / goalResultNo : 0;
        System.debug('avgGoalResultRating '+avgGoalResultRating);
        
        avgTechSkillRating = avgTechSkillRating.setScale(1);
        avgProfSkillRating = avgProfSkillRating.setScale(1);
        avgStrategicRating = avgStrategicRating.setScale(1);
        avgGoalResultRating = avgGoalResultRating.setScale(1);
        System.debug('avgGoalResultRating '+avgGoalResultRating);
        
        List<Goal__c> goalList = [SELECT Id, Resource__c FROM Goal__c WHERE Id IN :completedKRAIds];
        System.debug('goalList: ' + goalList);
        
        if(!goalList.isEmpty()){
            for (Goal__c goal : goalList) {
                System.debug('Goal Resource: ' + goal.Resource__c);
                if (goal.Resource__c != null) {
                    resourceIds.add(goal.Resource__c);
                }
            }
        }
        
        System.debug('resourceIds: ' + resourceIds);
        List<Contact> conList = [SELECT Id
                                 , Name
                                 , Resource_Role__c 
                                 FROM Contact 
                                 WHERE Id IN :resourceIds];
        System.debug('conList: ' + conList);
        if(!conList.isEmpty()){
            for (Contact con : conList) {
                System.debug('Contact ID: ' + con.Id);
                if (con.Resource_Role__c != null) {
                    resourceIds.add(con.Resource_Role__c);
                }
            }
        }
        System.debug('resourceIds: ' + resourceIds);
        List<Resource_Role__c> resourceRoleList = [SELECT Id
                                                   , technical_acumen__c
                                                   , strategic_impact__c
                                                   , professional_skills__c
                                                   , goals_and_results__c 
            										FROM Resource_Role__c 
            										WHERE Id IN :resourceIds
            										LIMIT 1];
        
        System.debug('resourceRoleList size: ' + resourceRoleList.size());
        
        if (!resourceRoleList.isEmpty()) {
            for (Goal__c goal : goalList) {
                Resource_Role__c role = resourceRoleList[0];
                
                if (role != null) {
                    System.debug('Role is not null');
                    goal.Average_Technical_Skills_Rating__c = (avgTechSkillRating * (role.technical_acumen__c / 100)).setScale(1);
                    goal.Average_Professional_Skills_Rating__c = (avgProfSkillRating * (role.professional_skills__c / 100)).setScale(1);
                    goal.Average_Strategic_Impact_Rating__c = (avgStrategicRating * (role.strategic_impact__c / 100)).setScale(1);
                    goal.Average_Goals_And_Result_Rating__c = (avgGoalResultRating * (role.goals_and_results__c / 100)).setScale(1); 
                } else {
                    System.debug('Role is null');
                }
            }
        } else {
            System.debug('Resource role list is empty');
        }
    } 
}