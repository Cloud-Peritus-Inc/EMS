import { LightningElement,wire } from 'lwc';
import wfoDaysCount from '@salesforce/apex/countWfoDaysForResource.RunWfoCalculations';

export default class WfoDaysCount extends LightningElement {

contextText = 'This shows your Current Month Work From Office Days';
wfodaysNo;
wfoDaysData;
showData =false;

@wire(wfoDaysCount)
    wiredWfoDaysCount({ error, data }) {  // Proper destructuring of the result
        if (data) {
            this.wfoDaysData = data;
            console.log('### this.wfoDaysData', this.wfoDaysData);
            this.showData = true;
        } else if (error) {
            console.error('Error:', error);
            this.wfoDaysData = undefined;
            this.showData = false;
        }
    }

}