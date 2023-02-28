import { LightningElement,track,wire } from 'lwc';
import getTheCurrentGoals from '@salesforce/apex/onboardingTileController.getTheCurrentGoals';
export default class GoalMetrics extends LightningElement {
@track goaldata ;
@track wrapdate;
numberofCompleted;
numberofInprogress;
numberofMissed;
numberofstricks;
utlizationPercentage;lastPto;

connectedCallback() {
  
}

loaded = false
    @wire(getTheCurrentGoals) 
    wiredLabels({error, data}){
        if(data){
       
        this.goaldata = data.goalList;
        this.wrapdate = data;
        this.numberofCompleted = data.numberofCompleted;
         this.numberofInprogress = data.numberofInprogress;
          this.numberofMissed = data.numberofMissed;
           this.numberofstricks = data.numberofstricks;
           this.utlizationPercentage = data.utlizationPercentage;
           this.lastPto = data.lastPto;
      
        this.loaded = true;
    }
    if(error){
        console.log('-======---=ERROR==--=-=-'+JSON.stringify(error));
    }
    }




    handleClick() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/goalmetrics'
            }
        });
}

  }