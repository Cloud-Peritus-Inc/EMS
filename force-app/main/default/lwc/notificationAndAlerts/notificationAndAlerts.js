import { LightningElement,wire,track } from 'lwc';
import getTheCurrentAlerts from '@salesforce/apex/resourceTileController.getTheCurrentAlerts';
import alertNoti from '@salesforce/resourceUrl/AlertNoti';
export default class NotificationAndAlerts extends LightningElement {
dateimage = alertNoti;
@track datawrap;
showdata = false;

@wire(getTheCurrentAlerts)
    eventObj(value){
        const {data, error} = value;
        if(data){ 
            this.datawrap = data;
            if(data.length > 0){
             this.showdata = true;
            }
        }else if(error){
            console.log('===error==='+JSON.stringify(error));
            this.datawrap = [];
            
        }
   }

}