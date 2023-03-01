import { LightningElement, wire, track } from 'lwc';
import getLeaveReqData from '@salesforce/apex/LeaveRequestApexController.getLeaveReqData';
import { NavigationMixin } from 'lightning/navigation';
export default class RecentRequestTile extends NavigationMixin(LightningElement) {

    reqLeaveData;
    nodata = false;
    @track reqLeaveArray;
    @wire(getLeaveReqData)
    getLeaveReqDataWiredData({ error, data }) {
        if (data) {
            this.reqLeaveData = data;
           
            this.reqLeaveArray = [].concat.apply([], Object.values(this.reqLeaveData));
            
        } else if (error) {
            console.error('Error:', error);
        }
    }

    errorCallback(error, stack) {
        console.log("errorcallback – child" + error.message);
        console.log("Stack", stack);
    }
}