import { LightningElement,track,wire } from 'lwc';
import getTheCurrentGoals from '@salesforce/apex/onboardingTileController.getTheCurrentGoals';
import { NavigationMixin } from 'lightning/navigation';
export default class GoalMetrics extends NavigationMixin(LightningElement) {
@track goaldata ;
@track wrapdate;
numberofCompleted;
numberofInprogress;
numberofMissed;
numberofDraft;
numberofActive;
numberofstricks;
utlizationPercentage;lastPto;

connectedCallback() {
  
}

loaded = false
    @wire(getTheCurrentGoals) 
    wiredLabels({error, data}){
        if(data){
       
        this.goaldata = data.goalList;
        console.log('23');
        console.log(this.goaldata);
        this.wrapdate = data;
        console.log(this.wrapdate);
        this.numberofCompleted = data.numberofCompleted;
         this.numberofInprogress = data.numberofInprogress;
          this.numberofMissed = data.numberofMissed;
          this.numberofDraft = data.numberofDraft;
          this.numberofActive = data.numberofActive;
           //this.numberofstricks = data.numberofstricks;
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
                url: '/performance-management'
            }
        });
}

  }
