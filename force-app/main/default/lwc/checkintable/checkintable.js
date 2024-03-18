import { LightningElement,wire,api,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getTheCheckInRecord from '@salesforce/apex/checkInController.getTheCheckInRecord';
export default class Checkintable extends NavigationMixin(LightningElement) {
@api tabledata = [];
@api resourceid;
@api fyid;
selectedcheckinrec;
wrapperdata;
@track checkInsTableAvailble=false;
connectedCallback() {
    console.log('====tabledata======'+JSON.stringify(this.tabledata));
    this.tbData= JSON.parse(JSON.stringify(this.tabledata))

    if(this.tbData.length>0){
        this.checkInsTableAvailble=true;
    }else{
        this.checkInsTableAvailble=false;
    }
}

    handleNavClick(event){
       let node = event.currentTarget.dataset.id;
       this.selectedcheckinrec =  event.currentTarget.dataset.id;
       console.log('==node===='+node);
       this.showCheckInModalBox();
      
    }

    @track isShowCheckInModal = false;
    showCheckInModalBox() {  
         console.log('====this.selectedcheckinrec======='+JSON.stringify(this.selectedcheckinrec));
        
        getTheCheckInRecord({ 
             checkiin : this.selectedcheckinrec   
         })
         .then(result => {
              console.log('====wrapperdata======='+JSON.stringify(result));
             this.wrapperdata = result;
             this.isShowCheckInModal = true;
         })
         .catch(error => {
            console.log('====Error======='+JSON.stringify(error));
         }); 
    }

    hideCheckInModalBox() {  
        this.isShowCheckInModal = false;
        
    }

}