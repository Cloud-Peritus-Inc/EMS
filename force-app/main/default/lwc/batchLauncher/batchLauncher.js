import { LightningElement,track,wire } from 'lwc';
//importing the apex methods
import getJobDetails from '@salesforce/apex/batchLauncherController.getJobDetails';
import executeBatch from '@salesforce/apex/batchLauncherController.executeBatch';
import getExistingBatchDetails from '@salesforce/apex/batchLauncherController.getExistingBatchDetails';
export default class BatchLauncher extends LightningElement {
    batchJobId;
    executedPercentage;
    executedIndicator;
    executedBatch;
    totalBatch;
    @track isBatchCompleted = false;
    @track batchClassName;
    batchSize = 100;
    disableExecuteBatch = false;
    @track dataoptions = [];
    
  connectedCallback() {
      this.batchSize = 10;
      getExistingBatchDetails()
        .then(result => {
          console.log('=======result==='+JSON.stringify(result));
      var consts = result;
      let optionsare = [];
      for(var key in consts){
        optionsare.push({value:consts[key], label:key}); //Here we are creating the array to show on UI.
      }
      console.log('===d=='+JSON.stringify(this.dataoptions));
      this.dataoptions = optionsare;
        })
        .catch(error => {
          console.log('In connected call back error....');
          this.error = error;
          console.log('Error is ' + this.error);
        }); 
  }


   /*@wire(getExistingBatchDetails)
    batchInfo({ error, data }) {
    if (data) {
    console.log('=======data==='+JSON.stringify(data));
      var consts = data;
      for(var key in consts){
        this.dataoptions.push({value:consts[key], label:key}); //Here we are creating the array to show on UI.
      }
      console.log('===d=='+JSON.stringify(this.dataoptions));
    } else if (error) {
      console.error('ERROR====='+JSON.stringify(error));
    }
  }
*/

    handleBatchNameChange(event) {
       // this.batchClassName = event.currentTarget.value;
       this.batchClassName = event.detail.value;
       this.batchJobId = '';
       this.batchSize = 10;
       this.disableExecuteBatch = false;
       this.executedBatch = false;
       
    }

    handleBatchSizeChange(event) {
        this.batchSize = parseInt(event.currentTarget.value);
    }

    //execute the batch class
    handleExecuteBatch() {
        this.disableExecuteBatch = true;
        executeBatch({
            className: this.batchClassName,
            chunkSize: this.batchSize
        }).then(res => {
            console.log('response => ', res);
            if (res) {
                this.batchJobId = res;
                //this.getBatchStatus();
            }
        }).catch(err => {
            console.log('err ', err);

        })
    }
    
    //get the batch status
    getBatchStatus() {
        getJobDetails({ jobId: this.batchJobId }).then(res => {
            console.log('response => ', res);
            if (res[0]) {
                this.totalBatch = res[0].TotalJobItems;
                if (res[0].TotalJobItems == res[0].JobItemsProcessed) {
                    this.isBatchCompleted = true;
                }
                this.executedPercentage = ((res[0].JobItemsProcessed / res[0].TotalJobItems) * 100).toFixed(2);
                this.executedBatch = res[0].JobItemsProcessed;
                var executedNumber = Number(this.executedPercentage);
                this.executedIndicator = Math.floor(executedNumber);
                // this.refreshBatchOnInterval();  //enable this if you want to refresh on interval
            }
        }).catch(err => {
            console.log('err ', err);

        })
    }

    handleRefreshView() {
        this.getBatchStatus();
    }

    refreshBatchOnInterval() {
        this._interval = setInterval(() => {
            if (this.isBatchCompleted) {
                clearInterval(this._interval);
            } else {
                this.getBatchStatus();
            }
        }, 10000); //refersh view every time
    }
}