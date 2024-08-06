public class UpdateAverageRatingsOnKRA implements TriggerAction.BeforeUpdate {
    
    public void beforeUpdate(List<Goal__c> newList, List<Goal__c> oldList) {
        updateAverageRatings(newList, new Map<Id, Goal__c>(oldList));
    }
    
    public void updateAverageRatings(List<Goal__c> newList, Map<Id, Goal__c> oldMap) {
        Set<Id> completedKRAIds = new Set<Id>(); 
        
        for (Goal__c gl : newList) {
            if (gl.Status__c != oldMap.get(gl.Id).Status__c && gl.Status__c == 'KRA Completed' ) {
                completedKRAIds.add(gl.Id);
                List<PM_Configure__c> filteredPmConfigList = getFilteredPMConfigList(completedKRAIds);
        		calculateAndSetAverageRatings(newList, filteredPmConfigList);
            }
        }
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
                                                AND Related_Question__r.Area__c != NULL
                                                ];
        
        if(!pmConfigList.isEmpty()){
            for (PM_Configure__c pmConfig : pmConfigList) {
                if (pmConfig.Mentor_Mentee__c != pmConfig.KRA__r.Resource__c) {
                    filteredPmConfigList.add(pmConfig);
                }
            }
        }
       
        return filteredPmConfigList;
    } 
    
    private void calculateAndSetAverageRatings(List<Goal__c> goalList, List<PM_Configure__c> filteredPmConfigList) {
        
        Set<Id> resourceIds = new Set<Id>();
        Decimal techSkillSum = 0;
        Integer techSkillNo = 0;
        Decimal profSkillSum = 0;
        Integer profSkillNo = 0;
        Decimal strategicSum = 0;
        Integer strategicNo = 0;
        Decimal goalResultSum = 0;
        Integer goalResultNo = 0;
        
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
                        goalResultNo++;
                    }
                }
            }
        }
        
        Decimal avgTechSkillRating = techSkillNo > 0 ? techSkillSum / techSkillNo : 0;
        Decimal avgProfSkillRating = profSkillNo > 0 ? profSkillSum / profSkillNo : 0;
        Decimal avgStrategicRating = strategicNo > 0 ? strategicSum / strategicNo : 0;
        Decimal avgGoalResultRating = goalResultNo > 0 ? goalResultSum / goalResultNo : 0;
        
        avgTechSkillRating = avgTechSkillRating.setScale(2);
        avgProfSkillRating = avgProfSkillRating.setScale(2);
        avgStrategicRating = avgStrategicRating.setScale(2);
        avgGoalResultRating = avgGoalResultRating.setScale(2);
        
        if(!goalList.isEmpty()){
            
            for (Goal__c goal : goalList) {
                
                if (goal.Resource__c != null) {
                    resourceIds.add(goal.Resource__c);
                }
            }
        }
        
        List<Contact> conList = [SELECT Id
                                 , Name
                                 , Resource_Role__c 
                                 FROM Contact 
                                 WHERE Id IN :resourceIds];
        
        if(!conList.isEmpty()){
            
            for (Contact con : conList) {
                
                if (con.Resource_Role__c != null) {
                    resourceIds.add(con.Resource_Role__c);
                }
            }
        }
        
        List<Resource_Role__c> resourceRoleList = [SELECT Id
                                                   , technical_acumen__c
                                                   , strategic_impact__c
                                                   , professional_skills__c
                                                   , goals_and_results__c 
            										FROM Resource_Role__c 
            										WHERE Id IN :resourceIds
            										LIMIT 1];
        
        if (!resourceRoleList.isEmpty()) {
            
            for (Goal__c goal : goalList) {
                
                Resource_Role__c role = resourceRoleList[0];
                if (role != null) {
                    
                    goal.Average_Technical_Skills_Rating__c = (avgTechSkillRating * (role.technical_acumen__c / 100)).setScale(2);
                    goal.Average_Professional_Skills_Rating__c = (avgProfSkillRating * (role.professional_skills__c / 100)).setScale(2);
                    goal.Average_Strategic_Impact_Rating__c = (avgStrategicRating * (role.strategic_impact__c / 100)).setScale(2);
                    goal.Average_Goals_And_Result_Rating__c = (avgGoalResultRating * (role.goals_and_results__c / 100)).setScale(2);
                    
                } else {
                    System.debug('Role is null');
                }
            }
        } else {
            System.debug('Resource role list is empty');
        }
    } 
}