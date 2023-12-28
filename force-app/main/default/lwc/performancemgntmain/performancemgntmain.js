import { LightningElement,wire } from 'lwc';
import checkTheTeam from '@salesforce/apex/myTeamController.checkTheTeam';
export default class Performancemgntmain extends LightningElement {
 dontshowTheTeam = true;
connectedCallback() {
    this.callandCheckTheTeam();
    console.log('In Performance one');
}

callandCheckTheTeam() {  
          checkTheTeam()
         .then(result => {
               console.log('-====data Perf--=-=-'+JSON.stringify(result));
        this.dontshowTheTeam = result;  
         })
         .catch(error => {
            console.log('====Error======='+JSON.stringify(error));
         });    
}
}