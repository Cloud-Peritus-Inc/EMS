import { LightningElement,wire,api,track } from 'lwc';
import getMyResources from '@salesforce/apex/myTeamController.getMyResources';
import getTheCurrentFY from '@salesforce/apex/myMetricsController.getTheCurrentFY';
import getResourceKRAs from '@salesforce/apex/myMetricsController.getResourceKRAs';
import createCheckIn from '@salesforce/apex/checkInController.createCheckIn';
import getTheCheckInInfo from '@salesforce/apex/checkInController.getTheCheckInInfo';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Myteam extends LightningElement {
@track selectedresource = '';
resourceId;
resourcemapdata =  [];
selectedfy;
showtheFY = false;
fymapdata =  [];
showcheckin = false;
showpulse = false;
showkras = false;
showGenPerKra = false;
@track kratable = [];
@track cintable = [];
myVal = '';

   @wire(getMyResources) 
    wiredRR({error, data}){
        if(data){
        console.log('-======---=getMyResources==--=-=-'+JSON.stringify(data));
        var consts = data;
        var optionlist = [];
         for(var key in consts){
             optionlist.push({label:key, value:consts[key]});
          }
          this.resourcemapdata = optionlist;
        }
        if(error){
            console.log('-======---=ERROR==--=-=-'+JSON.stringify(error));
        }
    }

    @wire(getTheCurrentFY) 
    wiredFYS({error, data}){
        if(data){
        console.log('-======---=getTheCurrentFY==-data-=-=-'+JSON.stringify(data));
        this.selectedfy = data.currentName;
        this.resourceId = data.currentResId;
        this.showGenPerKra = data.showGenPerKra;
        var consts = data.fyListMap;
        var optionlist = [];
         for(var key in consts){
             optionlist.push({label:key, value:consts[key]});
          }
          this.fymapdata = optionlist;       
    }
        if(error){
            console.log('-======---=ERROR==--=-=-'+JSON.stringify(error));
        }
    }
handlerichChange(event) {
        this.myVal = event.target.value;
    }

 handleFYChange(event) {
  this.selectedfy = event.detail.value;
  console.log('==selectedfy===='+this.selectedfy);
  this.getTheKRA();
 }
  handleResourceChange(event) {
  this.showtheFY = true;
  this.selectedresource = event.detail.value;
  console.log('==selectedresource===='+this.selectedresource);
  this.myVal = '';
  this.getTheKRA();
  //smaske : Calling getCheckInfo() method on resource change
  //Fix for Defect PM_009
  this.getCheckInfo();
 }

 checkInToggle(event){
     if(event.target.checked){
    this.getCheckInfo();
    }
 this.showcheckin = event.target.checked;
 
}
pulseToggle(event){
this.showpulse = event.target.checked;
}
kraToggle(event){
if(event.target.checked){
    this.getTheKRA();
}
this.showkras = event.target.checked;
}

 getTheKRA(){
     getResourceKRAs({ 
             resourceId : this.selectedresource,
             fyId : this.selectedfy   
         })
         .then(result => {
              console.log('====result======='+JSON.stringify(result));
             this.kratable = result;
         })
         .catch(error => {
            console.log('====Error======='+JSON.stringify(error));
         });
    
 }

    getCheckInfo() {
        getTheCheckInInfo({
            resourceId: this.selectedresource,
            fyId : this.selectedfy
        })
            .then(result => {
                console.log('====cintable=======' + JSON.stringify(result));
                this.cintable = result;
            })
            .catch(error => {
                console.log('====Error=======' + JSON.stringify(error));
            });
    }

@track isShowCheckInModal = false;
 showCheckInModalBox() {  
        this.isShowCheckInModal = true;
    }

    hideCheckInModalBox() {  
        this.isShowCheckInModal = false;
    }

handleCheckInSave(){
   console.log('==Resource Id=='+this.selectedresource);
   console.log('==Mentor Id=='+this.resourceId); 
   console.log('==Comments Id=='+this.myVal); 
   if(this.myVal === '' || this.myVal === null){
     const evt = new ShowToastEvent({
            title: 'Notes Required',
            message: 'Please enter the check-in notes',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
   }else{
     console.log('==Not Id=='+this.myVal); 
     createCheckIn({
            resourceId: this.selectedresource,
            mentorId: this.resourceId,
            checkInComments:this.myVal
        }).then(res => {
            const evt = new ShowToastEvent({
            //title: 'success',
            message: 'Checked In Successfully !',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
        this.isShowCheckInModal = false;
        this.myVal = '';
        this.getCheckInfo();
        }).catch(err => {
            console.log('err ', err);

        })  
   }
}

    @track isShowGeneratePerformaneKraModal = false;
    generatePerformanceKRAHandler() {
        this.isShowGeneratePerformaneKraModal = true;
        console.log("IN @ generatePerformanceKRAHandler");
        console.log("Current User Id :" + this.resourceId);
        console.log("Selected Team Member Id :" + this.selectedresource);
        
    }

    hideGeneratePerformaneKraModalBox(){
        this.isShowGeneratePerformaneKraModal = false;
    }

    modalCloseHandler(){
        this.isShowGeneratePerformaneKraModal = false;
        this.getTheKRA();
    }

}