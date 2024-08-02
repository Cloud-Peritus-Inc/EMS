import { LightningElement,wire } from 'lwc';
import checkTheTeam from '@salesforce/apex/myTeamController.checkTheTeam';
export default class Performancemgntmain extends LightningElement {
 dontshowTheTeam = false;
connectedCallback() {
    this.callandCheckTheTeam();
    console.log('In Performance one');
}
//  //Commented for my team tab hiding when the HR profile having custom permission 'Performance Management Admin'--Praveen
callandCheckTheTeam() {  
          checkTheTeam()
         .then(result => {
               console.log('-====data Perf--=-=-'+JSON.stringify(result));
        this.dontshowTheTeam = result;  
         })
         .catch(error => {
            console.log('====Error======='+JSON.stringify(error.message.body));
         });    
}
}