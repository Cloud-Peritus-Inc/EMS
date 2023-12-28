import { LightningElement,wire,api } from 'lwc';
import getTheCompanyKRA from '@salesforce/apex/myMetricsController.getTheCompanyKRA';
import getAllRoleKRAs from '@salesforce/apex/myMetricsController.getAllRoleKRAs';
export default class Companykra extends LightningElement {
selectedrole;
roledata =  [];
tablekradata = [];

   @wire(getTheCompanyKRA) 
    wiredRR({error, data}){
        if(data){
        console.log('-======---=data==--=-=-'+JSON.stringify(data));
        console.log('-======---=data.kralist==--=-=-'+JSON.stringify(data.kralist));
        this.selectedrole = data.currentName;
        this.tablekradata = data.kralist;
        var consts = data.fyListMap;
        var optionlist = [];
         for(var key in consts){
             optionlist.push({label:key, value:consts[key]});
          }
          this.roledata = optionlist;
          this.getTheroleka();
          console.log('-======---=this.roledata==--=-=-'+JSON.stringify(this.roledata)); 
       
    }
        if(error){
            console.log('-======---=ERROR==--=-=-'+JSON.stringify(error));
        }
    }

    handleFYChange(event) {
  this.selectedrole = event.detail.value;
  console.log('==selectedrole===='+this.selectedrole);
  this.getTheroleka();
 }

 getTheroleka(){
     getAllRoleKRAs({ 
             resourceRoleId : this.selectedrole   
         })
         .then(result => {
              console.log('====result======='+JSON.stringify(result));
             this.tablekradata = result;
         })
         .catch(error => {
            console.log('====Error======='+JSON.stringify(error));
         });
 }

}