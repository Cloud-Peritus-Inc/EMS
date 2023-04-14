import { LightningElement,track,wire } from 'lwc';
import GoalImage from '@salesforce/resourceUrl/GoalImage';
import { NavigationMixin } from 'lightning/navigation';
import getMyActiveGoals from '@salesforce/apex/onboardingTileController.getMyActiveGoals';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateTheGoal from '@salesforce/apex/onboardingTileController.updateTheGoal';
import LightningConfirm from 'lightning/confirm';
export default class MyActiveGoals extends NavigationMixin(LightningElement) {
@track imageUrl = GoalImage;
openModal = false;
showonUi = false;
@track loaded = false;
selectedgoalId;
datawrap1 = [];
datawrap2 = [];
numberOfTasks = 0;
numberofcompletedTasks = 0;
complaitionPercent = 0;

connectedCallback() {
  
}


@wire(getMyActiveGoals)
    eventObj(value){
        const {data, error} = value;
        if(data){
          
            this.datawrap1 = data.taskList;
            this.datawrap2 = data.taskList2;
            this.numberofcompletedTasks = data.numberofcompletedTasks;
            this.numberOfTasks = data.numberofTasks;
            this.showonUi = data.showUI;
        }else if(error){
            console.log('===error==='+JSON.stringify(error));
            this.datawrap1 = [];
             this.datawrap2 = [];
            
        }
   }

 handleClick(event){
    this.openModal = true;
    const clickedId = event.currentTarget.dataset.id;
    console.log('===clickedId======'+clickedId);
    this.selectedgoalId = clickedId; 
}

   handleCancel(event) {
      this.openModal = false;
    }

      handleSuccess(event) {
         
          updateTheGoal({ 
             goalid : event.detail.id   
         })
         .then(result => {
             
              this.datawrap1 = result.taskList;
            this.datawrap2 = result.taskList2;
            this.numberofcompletedTasks = result.numberofcompletedTasks;
            this.numberOfTasks = result.numberofTasks;
            this.showonUi = result.showUI;
            this.openModal = false;
             const even = new ShowToastEvent({
            message: 'Successfully Updated!',
            variant: 'success'
        });
        this.dispatchEvent(even);
         })
         .catch(error => {
             const event = new ShowToastEvent({
                 message : 'Error in updating the goal. Please Contact System Admin',
                 variant : 'error'
             });
             this.dispatchEvent(event);
         });
            
       
        
        
    }

    handleError(event){
        const evt = new ShowToastEvent({
            message: event.detail.detail,
            variant: 'error',
            mode:'dismissable'
        });
        this.dispatchEvent(evt);
    }

}