import { LightningElement, wire, track } from 'lwc';
import getProjectsWithAssigns from '@salesforce/apex/GetProjectsController.getProjects';

export default class LeadProjectsWithAssignments extends LightningElement {
   @track gridData;
   @wire(getProjectsWithAssigns)
   projectsWithAssignments({data, error}){
       if(data){
           console.log(data);
            var tempData = JSON.parse( JSON.stringify( data ) );
            console.log( 'Data is ' + tempData );
            /*var tempjson = JSON.parse( JSON.stringify( data ).split( ‘Contacts’ ).join( ‘_children’ ) );
            console.log( ‘Temp JSON is ‘ + tempjson );*/
            
            for ( var i = 0; i < tempData.length; i++ ) {

                tempData[ i ]._children = tempData[ i ][ 'Assignments__r' ];
               // delete tempData[ i ].Assignments__r;

            }
        //     console.log('====tempData=== 11 '+JSON.stringify(tempData));
        //     this.gridData= tempData.map((ele) => ({
                
        //     ...ele,
        //      ...{'employeeName':ele.EMS_TM_EmployeeName__c}

        // }))
        // console.log('====ele=== 11 '+this.gridData);
        //     //
        this.gridData = tempData;
       }
       if(error){
           console.log('====Error=== 11 '+error);
       }
   };

    @track gridColumns = [{
        type: 'text',
        fieldName: 'Name',
        label: 'Project Name'
    },
    {
        type: 'text',
        fieldName: 'Employee_Name__c',
        label: 'Employee Name'
    },
    {
        type: 'date',
        fieldName: 'EMS_TM_StartDate_Asgn__c',
        label: 'Start Date'
    },
    {
        type: 'date',
        fieldName: 'EMS_TM_EndDate_Asgn__c',
        label: 'End Date'
    },
    {
        type: 'text',
        fieldName: 'EMS_TM_Status_Asgn__c',
        label: 'Status'
    }];
   /* @track gridData;

    @wire(fetchAccounts)
    accountTreeData({ error, data }) {

        console.log( 'Inside wire' );
        if ( data ) {

            var tempData = JSON.parse( JSON.stringify( data ) );
            console.log( 'Data is ' + tempData );
            /*var tempjson = JSON.parse( JSON.stringify( data ).split( ‘Contacts’ ).join( ‘_children’ ) );
            console.log( ‘Temp JSON is ‘ + tempjson );
            for ( var i = 0; i < tempData.length; i++ ) {

                tempData[ i ]._children = tempData[ i ][ 'Contacts' ];
                delete tempData[ i ].Contacts;

            }
            this.gridData = tempData;

        } else if ( error ) {
           
            if ( Array.isArray( error.body ) )
                console.log( 'Error is ' + error.body.map( e => e.message ).join( ', ' ) );
            else if ( typeof error.body.message === 'string' )
                console.log( 'Error is ' + error.body.message );

        }

    }*/



}