import { LightningElement, wire, track } from 'lwc';
import getLeaveReqData from '@salesforce/apex/LeaveRequestApexController.getLeaveReqData';
import { NavigationMixin } from 'lightning/navigation';
export default class RecentRequestTile extends NavigationMixin(LightningElement) {

    reqLeaveData;
    //isViewAll = true;
    @track reqLeaveArray;
    @wire(getLeaveReqData)
    getLeaveReqDataWiredData({ error, data }) {
        if (data) {
            this.reqLeaveData = data;
            console.log('### reqLeaveData : ', this.reqLeaveData);
            this.reqLeaveArray = [].concat.apply([], Object.values(this.reqLeaveData));
            console.log('### reqLeaveArray', JSON.stringify(this.reqLeaveArray));
        } else if (error) {
            console.error('Error:', error);
        }
    }

    errorCallback(error, stack) {
        console.log("errorcallback – child" + error.message);
        console.log("Stack", stack);
    }
}