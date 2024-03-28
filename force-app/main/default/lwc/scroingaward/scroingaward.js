import { LightningElement,api,track } from 'lwc';
import getTheScoringbyAward from '@salesforce/apex/RRController.getTheScoringbyAward';
import getTheScoringbyAllAward from '@salesforce/apex/RRController.getTheScoringbyAllAward';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getFinalNominsWinners from '@salesforce/apex/RRController.getFinalNominsWinners';
import updateTheWinners from '@salesforce/apex/RRController.updateTheWinners';
import checkTheAnnualAnn from '@salesforce/apex/RRController.checkTheAnnualAnn';
export default class Scroingaward extends LightningElement {
@api selectedfy;
@api awarddatalist = [];
@track selectedAward = 'All';
@track scoringTable = [];
showthecampare = false;
showcomparepop = false;
announcebutton = true;
nomstable = [];
disableconfirmbutton = false;
showtable = false;
alreadyAnnounced = false;
@api isDisabled;
connectedCallback() {
     this.getTheAllAward(); 
     
     checkTheAnnualAnn({ 
        fyId : this.selectedfy,        
        }).then(result => {      
            console.log('28');
            console.log(JSON.parse(JSON.stringify(result)));  
        this.isDisabled = JSON.parse(JSON.stringify(result));    
        }).catch(error => {
        });    
}

handleChange(event) {
        this.selectedAward = event.detail.value;
        if(event.detail.value != 'All'){
            this.showthecampare = true; 
            this.announcebutton = false;
            this.getThelInfoByAward();
        }else{
            this.getTheAllAward();
            this.showthecampare = false;
            this.announcebutton = true; 
        }
       
}

    //smaske : [PM_087] : created below method to call from Parent to fetch scoring table data based on selected FY 
    @api handleChange2(fy) {
        this.selectedfy = fy;
        if(this.selectedAward != 'All'){
            console.log('42');
            this.showthecampare = true; 
            this.announcebutton = false;
            this.getThelInfoByAward();
        }else{
            console.log('47');
            this.getTheAllAward();
            this.showthecampare = false;
            this.announcebutton = true; 
        }
    }

 getThelInfoByAward(){
     this.scoringTable = [];
          console.log('======selectedfy===='+JSON.stringify(this.selectedfy));
          let currentAward = this.selectedAward;
        getTheScoringbyAward({ 
        fyId : this.selectedfy,
         awardType : this.selectedAward  
        }).then(result => {
        console.log('======scoringTable===='+JSON.stringify(result));
        this.scoringTable = result;
        this.selectedAward=currentAward;
        }).catch(error => {
        }); 
    }

    getTheAllAward(){
        console.log('======selectedfy===='+JSON.stringify(this.selectedfy));
        getTheScoringbyAllAward({ 
        fyId : this.selectedfy
        }).then(result => {
        console.log('======result=All==='+JSON.stringify(result));
        //console.log('======result=All===');
        this.scoringTable = result;
        let modifiedArr = JSON.parse(JSON.stringify(this.scoringTable));

        modifiedArr.forEach(ele =>{      
            for(var i=0;i<ele.currentList.length;i++){   
                if(ele.currentList.length>=1){ 
                    ele.currentList[i].borderCls = (i == ele.currentList.length-1) ? "slds-wrap slds-p-around_small" : "slds-wrap borderClr slds-p-around_small";
                 }
            }                  
        })
        this.scoringTable = JSON.parse(JSON.stringify(modifiedArr));

        console.log('======Modified result=All==='+JSON.stringify(this.scoringTable));
        
        }).catch(error => {
          console.log('======error=errorAll==='+JSON.stringify(error));
        }); 
    }

    pulishTheAwards(){
         this.disableconfirmbutton = true;
        console.log('======nomstable===='+JSON.stringify(this.nomstable));
        updateTheWinners({ 
        winnerlist : this.nomstable,
        fyId : this.selectedfy
        }).then(result => {
            this.showannualann = false; 
        console.log('======result=All==='+JSON.stringify(result));
        const evt = new ShowToastEvent({
            //title: 'SUCCESS',
            message: result,
            variant: 'success',
            });
            this.dispatchEvent(evt);
        window.location.reload();
        
        }).catch(error => {
             this.disableconfirmbutton = false;
          console.log('======error=errorAll==='+JSON.stringify(error));
           const evt = new ShowToastEvent({
            //title: 'Error',
            message: 'Something went wrong..'+JSON.stringify(error),
            variant: 'error',
            });
            this.dispatchEvent(evt);

        }); 
    }

    handleAnnounceClick(){
        this.getTheMyNoms();
        console.log('====current fy====='+selectedfy);
      this.showAnnualAnnModalBox();
    }

    handleRefresh(){
        this.scoringTable = [];
        this.getThelInfoByAward();
    }

    handleCompareClick(){
        this.showCompareModalBox();
    }

    showCompareModalBox() { 
         this.showcomparepop = true; 
    }

    hideKCompareModalBox() {  
        this.showcomparepop = false; 
        
    }

     showAnnualAnnModalBox() { 
         this.showannualann = true; 
    }

    hideAnnualAnnModalBox() {  
        this.showannualann = false; 
        
    }


    showannualann = false;
   
    getTheMyNoms(){
        getFinalNominsWinners({ 
        fyId : this.selectedfy   
        }).then(result => {
            console.log('====winnnerlist===result====='+JSON.stringify(result));
        this.nomstable = result.currentList;
        this.alreadyAnnounced = result.alreadyannounced;
        //smaske : [UAT_PR_010] : updated the if condition as old condition was failing
        if(result.currentList.length > 0){
            this.showtable = true;
            this.disableconfirmbutton = false;
        }else{
            this.showtable = false;
             this.disableconfirmbutton = true;
        }
         this.showannualann = true;
        }).catch(error => {
            console.log('=======error====='+JSON.stringify(error));
        }); 
    }


    handleSubmit(event) {
        console.log('onsubmit event recordEditForm'+ event.detail.fields);
    }
    handleSuccess(event) {
        console.log('onsuccess event recordEditForm', event.detail.id);
       
        this.getThelInfoByAward();
         const evt = new ShowToastEvent({
            //title: 'SUCCESS',
            message: 'Succesfully updated the scoring.',
            variant: 'success',
            });
            this.dispatchEvent(evt);
             this.showcomparepop = false;
        }
    }