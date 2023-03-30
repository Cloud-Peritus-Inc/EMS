import { LightningElement,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getTheCurrentRRTrends from '@salesforce/apex/RRController.getTheCurrentRRTrends';
import landscape from '@salesforce/resourceUrl/landscape';
export default class RewardsAndRecog extends LightningElement {
imageUrl = landscape;
disableNominations = true;
disablerecognise = true;
openshoutout = false;
fymapdata =  [];
currentdata = [];
selectedfy;

   @wire(getTheCurrentRRTrends) 
    wiredRR({error, data}){
        if(data){
        console.log('-======---=data==--=-=-'+JSON.stringify(data));
        this.expList = data.disableNominations;
        this.disablerecognise = data.disableRecognize;
        this.selectedfy = data.currentName;
        this.currentdata = data.currentList;
        var consts = data.fyListMap;
         for(var key in consts){
          this.fymapdata.push({label:key, value:consts[key]});
          }
       
    }
        if(error){
            console.log('-======---=ERROR==--=-=-'+JSON.stringify(error));
        }
    }

   handleOpenShoutClick(){
       this.openshoutout = true;
    }

    handleCancel(event) {
      this.openshoutout = false;
    }

    handleChange(event) {
        this.selectedfy = event.detail.value;
        console.log('==selectedfy===='+this.selectedfy);
    }
}