import { LightningElement,track,wire } from 'lwc';
import MountainImage from '@salesforce/resourceUrl/MountainImage';
import getMyOnboardingTasks from '@salesforce/apex/onboardingTileController.getMyOnboardingTasks';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateTheTaskasComplete from '@salesforce/apex/onboardingTileController.updateTheTaskasComplete';
import LightningConfirm from 'lightning/confirm';
export default class OnboardingTaskTile extends LightningElement {
@track imageUrl = MountainImage;
showpopup = false;
showonboardingUi = false;
@track loaded = false;
selectedTaskId;
datawrap = [];
numberOfTasks = 0;
numberofcompletedTasks = 0;
complaitionPercent = 0;

connectedCallback() {
    console.log('========Nubererm=======');

}


@wire(getMyOnboardingTasks)
    eventObj(value){
        const {data, error} = value;
        if(data){
           console.log('======this.returned=data=='+JSON.stringify(data));
            this.datawrap = data.taskList;
            this.numberofcompletedTasks = data.numberofcompletedTasks;
            this.numberOfTasks = data.numberofTasks;
            this.complaitionPercent = (this.numberofcompletedTasks/this.numberOfTasks)*100;
            if(this.numberOfTasks == 0 || this.complaitionPercent==100){
             this.showonboardingUi = false;
            }else{
                this.showonboardingUi = true;
            }
        }else if(error){
            console.log('===error==='+JSON.stringify(error));
            this.datawrap = [];
            
        }
   }

async handleClick(event){
    this.loaded = true;
 const clickedId = event.target.dataset.id;
    console.log(clickedId);
    this.selectedTaskId = clickedId; 
    this.showpopup = true;
    const result = await LightningConfirm.open({
            message: 'Are you sure you want to mark this task as complete ?',
            variant: 'header',
            label: 'Please Confirm',
            theme: 'error',
        });

        if(result==true){
          updateTheTaskasComplete({ 
             taskid : clickedId
         })
         .then(result => {
             const event = new ShowToastEvent({
                 title: 'Completed',
                 message: result,
                 variant: 'success'
             });
             this.dispatchEvent(event);
             this.loaded = false;
         })
         .catch(error => {
             const event = new ShowToastEvent({
                 title : 'Error',
                 message : 'Error updating task as completed. Please Contact System Admin',
                 variant : 'error'
             });
             this.dispatchEvent(event);
             this.loaded = false;
         });

        }
}

}