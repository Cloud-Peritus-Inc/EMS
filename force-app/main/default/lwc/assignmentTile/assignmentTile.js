import { LightningElement,wire,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getMyProjectDetails from '@salesforce/apex/AssignmentTileController.getMyProjectDetails';
export default class AssignmentTile extends NavigationMixin(LightningElement) {
showThetable= false;
error;
datawrap = [];

@wire(getMyProjectDetails)
    eventObj(value){
        const {data, error} = value;
        if(data){
            this.showThetable = true;
            this.datawrap = data;
        }else if(error){
            console.log('===error==='+JSON.stringify(error));
            this.datawrap = [];
            
        }
   }

handleClick() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/recordlist/EMS_TM_Assignment__c/Default'
            }
        });
}
}