import { LightningElement,wire,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getTheCurrentRRTrends from '@salesforce/apex/RRController.getTheCurrentRRTrends';
import getTheCurrentFYTrends from '@salesforce/apex/RRController.getTheCurrentFYTrends';
import getShoutouts from '@salesforce/apex/RRController.getShoutouts';
import getShoutoutsReceived from '@salesforce/apex/RRController.getShoutoutsReceived';
import getRecGiven from '@salesforce/apex/RRController.getRecGiven';
import getRecReceived from '@salesforce/apex/RRController.getRecReceived';
import getMyAnnualAwards from '@salesforce/apex/RRController.getMyAnnualAwards';
import getMyNomins from '@salesforce/apex/RRController.getMyNomins';
import landscape from '@salesforce/resourceUrl/landscape';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import RR_OBJECT from '@salesforce/schema/Reward_And_Recognition__c';
import USER_ID from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
export default class RewardsAndRecog extends LightningElement {
imageUrl = landscape;
dNominations = true;
@track showTheAnnualAwards = false;
drecognise = true;
hideInputField =false;
openshoutout = false;
annualAwardpop = false;
openRecogize = false;
@track currentFY;
fymapdata =  [];
awardsdata =  [];
selectedAward = 'All';
currentdata = [];
shoutouttable = [];
shoutoutreceived = [];
showNomstab = false;
activeTab = '1';
@track selectedfy;
showscroingTab = false;
@track userId = USER_ID;
@track LogggedInUserConId;
winnerrecordTypeId;
@track name;
   @wire(getTheCurrentRRTrends) 
    wiredRR({error, data}){
        if(data){
            //smaske : [PM_052] :Assigning UserConId
            this.LogggedInUserConId = data.currentUserConId;
        this.dNominations = data.disableNominations;
        this.drecognise = data.disableRecognize;
        this.selectedfy = data.currentName;
        this.showNomstab = data.showNominationstab;
        this.showscroingTab = data.scroingtab;
        this.currentFY = data.currentName;
        this.currentdata = data.currentList;
        console.log('====data.currentList.length===='+data.currentList.length);
        this.showTheAnnualAwards = data.showtheWinners;
         console.log('====this.showTheAnnualAwards===='+this.showTheAnnualAwards);
        this.winnerrecordTypeId = data.winnerrecordtypeId;
        var consts = data.fyListMap;
        var optionlist = [];
        for(var key in consts){
             optionlist.push({label:key, value:consts[key]});
        }
        this.fymapdata = optionlist;
        var consts2 = data.awardList;

        var optionlist2 = [];
        for(var key in consts2){
             optionlist2.push({label:key, value:consts2[key]});
        }
        this.awardsdata = optionlist2;
        this.getThelatestRecrecived();
       
    }
    if(error){
            console.log('-======---=ERROR==--=-=-'+JSON.stringify(error));
    }
    }

  connectedCallback() {
      console.log('====userId===='+this.userId);
  }

  /*  @wire(getObjectInfo, { objectApiName: RR_OBJECT })
    objectInfo;

    get winnerrecordTypeId() {
        
        if ( this.objectInfo.data ) {            
            const recTyps = this.objectInfo.data.recordTypeInfos;
            return Object.keys( recTyps ).find( recTyp => recTyps[ recTyp ].name === 'Winners' );

        } else {
            return null;
        }

    }*/

   

    showShoutOutiewModalBox() { 
         this.openshoutout = true; 
         this.myReasonVal = '';
    }

    hideShoutOutModalBox() {  
        this.openshoutout = false;
        this.myReasonVal = '';
        
    }

     showRecModalBox() { 
         this.openRecogize = true; 
         this.myRecognizeReason = '';
    }

    hideRecModalBox() {  
        this.openRecogize = false;
        this.myRecognizeReason = '';
        
    }

    showAnnualModalBox() { 
         this.annualAwardpop = true; 
    }

    hideAnnualModalBox() {  
        this.annualAwardpop = false;    
    }

    handleFYChange(event) {
        this.selectedfy = event.detail.value;
        console.log('==selectedfy===='+this.selectedfy);
        this.getThelatestAwards();
        this.checkActiveTabandgetInfo();
    }
    //@Mukesh for defect UAT_007
    @track myReasonVal;
    @track myRecognizeReason;

    handleChangeReason(event){
        this.myReasonVal = event.detail.value;
    }
    handleChangeRecognize(event){
        this.myRecognizeReason = event.detail.value;
    }

    getThelatestAwards(){

    getTheCurrentFYTrends({ 
                fyId : this.selectedfy   
            })
            .then(result => {
                 this.currentdata = result.currentList;
                 this.showTheAnnualAwards = result.showtheWinners;
            })
            .catch(error => {
            }); 
    }

    handleSubmit(event) {
        event.preventDefault();
        const fields = event.detail.fields;
        //smaske : Preventing Self Recognize record creation for Loggedin User 
        // DEFECT : PM_053
        if (this.LogggedInUserConId != fields.Resource__c) {
            fields.Status__c = 'Completed';
            fields.Recognization_By__c = this.userId;
            fields.Fiscal_Year__c = this.currentFY;
            fields.Type__c = 'ShoutOut';
            //@Mukesh for defect UAT_007 making required
            if(this.myReasonVal){
                this.template.querySelector('lightning-record-edit-form').submit(fields);
            }else{
                const evt = new ShowToastEvent({
                //title: 'Warning',
                message: 'Please complete required fields.',
                variant: 'warning',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            }
            //this.template.querySelector('lightning-record-edit-form').submit(fields);
        }else{
            const evt = new ShowToastEvent({
                //title: 'Warning',
                message: 'Self Shoutout is not allowed!',
                variant: 'warning',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
    }

    handleSuccess(event) {
        const evt = new ShowToastEvent({
            //title: 'success',
            message: 'Successfully submitted your shout out!',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
        this.hideShoutOutModalBox();
        //smaske:PM_075 : Refresh data
        this.getThelatestSpotAwardGiven();
    }
    
    handleRecSubmit(event) {
        event.preventDefault();
        //smaske : Preventing Self Recognize record creation for Loggedin User 
        // DEFECT : PM_052
        const fields = event.detail.fields; 
        if (this.LogggedInUserConId != fields.Resource__c) {
            fields.Status__c = 'Completed';
            fields.Recognization_By__c = this.userId;
            fields.Fiscal_Year__c = this.currentFY;
            fields.Type__c = 'Recognize';
            //@Mukesh for defect UAT_007 making required
            if(this.myRecognizeReason){
                this.template.querySelector('lightning-record-edit-form').submit(fields);
            }else{
                const evt = new ShowToastEvent({
                //title: 'Warning',
                message: 'Please complete required fields.',
                variant: 'warning',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            }
            
        }else{
            const evt = new ShowToastEvent({
                //title: 'Warning',
                message: 'Self Recognisation is not allowed!',
                variant: 'warning',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
    }

    handleRecSuccess(event) {
        const evt = new ShowToastEvent({
            //title: 'success',
            message: 'Successfully submitted your recognization!',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
        this.hideRecModalBox();
        //smaske:PM_075 : Refresh data
        this.getThelatestRecGiven();
    }

    handleActive(event) {
     this.activeTab = event.target.value;
     console.log('==active===='+this.activeTab)
     this.checkActiveTabandgetInfo();
    }

    checkActiveTabandgetInfo(){
      if(this.activeTab == "3" ){
     this.getThelatestSpotAwardGiven();
     }else if(this.activeTab == "4"){
     this.getThelatestSpotAwardrecived();
     }else if(this.activeTab == "7"){
     this.getThelatestRecGiven();
     }else if(this.activeTab == "1"){
     this.getThelatestRecrecived();
     }else if(this.activeTab == "2"){
      this.getTheMyAwards();
     }else if(this.activeTab == "5"){
      this.getTheMyNoms();
      } else if (this.activeTab == "6") {
          //smaske :
          this.template.querySelector('c-scroingaward').handleChange2(this.selectedfy);
      }
     
    }

    getThelatestSpotAwardGiven(){
          console.log('======selectedfy===='+JSON.stringify(this.selectedfy));
        getShoutouts({ 
        fyId : this.selectedfy   
        }).then(result => {
        console.log('======result===='+JSON.stringify(result));
        this.shoutouttable = result;
        if(this.shoutouttable.length > 0){
         this.showrectable = true;
        }else{
          this.showrectable = false;   
        }
        }).catch(error => {
        }); 
    }

     getThelatestSpotAwardrecived(){
          console.log('======selectedfy===='+JSON.stringify(this.selectedfy));
        getShoutoutsReceived({ 
        fyId : this.selectedfy   
        }).then(result => {
        console.log('==shoutoutreceived====result===='+JSON.stringify(result));
        this.shoutoutreceived = result;
        if(this.shoutoutreceived.length > 0){
         this.showrectable = true;
        }else{
          this.showrectable = false;   
        }
        }).catch(error => {
        }); 
    }

    recreceived = [];
    showrectable = false;
    recgiven = [];
    myawards = [];
    mynoms = [];

    getThelatestRecGiven(){
        getRecGiven({ 
        fyId : this.selectedfy   
        }).then(result => {
        this.recgiven = result;
         if(this.recgiven.length > 0){
         this.showrectable = true;
        }else{
          this.showrectable = false;   
        }
        }).catch(error => {
        }); 
    }

    getThelatestRecrecived(){
        getRecReceived({ 
        fyId : this.selectedfy   
        }).then(result => {
        this.recreceived = result;
        if(this.recreceived.length > 0){
         this.showrectable = true;
        }else{
          this.showrectable = false;   
        }
        }).catch(error => {
        }); 
    }

    getTheMyAwards(){
        getMyAnnualAwards({ 
        fyId : this.selectedfy   
        }).then(result => {
        this.myawards = result;
         if(this.myawards.length > 0){
         this.showrectable = true;
        }else{
          this.showrectable = false;   
        }
        }).catch(error => {
        }); 
    }

     getTheMyNoms(){
        getMyNomins({ 
        fyId : this.selectedfy   
        }).then(result => {
        this.mynoms = result;
        console.log('this.mynoms' ,this.mynoms);
        if(this.mynoms.length > 0){
         this.showrectable = true;
        }else{
          this.showrectable = false;   
        }
        }).catch(error => {
        }); 
    }

    modalCloseHandler(){
        this.hideAnnualModalBox();
    }

    //smaske : [PM_075] : Handling event for refresehing My Nomination Tab data
    handleRefreshData(event){
        console.log('INSIDE handleRefreshData ');
        this.getTheMyNoms();
    }
}