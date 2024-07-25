import { LightningElement, wire, api, track } from 'lwc';
import getMyResources from '@salesforce/apex/myTeamController.getMyResources';
import getTheCurrentFY from '@salesforce/apex/myMetricsController.getTheCurrentFY';
import getResourceKRAs from '@salesforce/apex/myMetricsController.getResourceKRAs';
import createCheckIn from '@salesforce/apex/checkInController.createCheckIn';
import getTheCheckInInfo from '@salesforce/apex/checkInController.getTheCheckInInfo';
//smaske:New
import getReporteesInHierarchy from '@salesforce/apex/myTeamController.getReporteesInHierarchy';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Myteam extends LightningElement {
    @api tab = 'My Team'; //smaske
    @track selectedresource = '';
    @track showcombobox = false; //sangharsh
    @track secondarySelectedResource = '';
    @track tertiarySelectedResource = ''; //Mukesh
    @track quaternarySelectedResource = ''; //Mukesh
    resourceId;
    resourcemapdata = [];
    secondaryreporteesmapdata = [];//smaske : [EN_13]
    tertiaryreporteesmapdata = []; //Mukesh
    quaternaryreporteesmapdata = []; //Mukesh
    selectedfy;
    showtheFY = false;
    fymapdata = [];
    showcheckin = false;
    showpulse = false;
    showkras = false;
    showGenPerKra = false;
    @track kratable = [];
    @track cintable = [];
    myVal = '';
    @track viewonlymode = false;//smaske : [EN_13]

    @wire(getMyResources)
    wiredRR({ error, data }) {
        if (data) {
            //console.log('-======---=getMyResources==--=-=-' + JSON.stringify(data));
            var consts = data;
            var optionlist = [];
            for (var key in consts) {
                optionlist.push({ label: key, value: consts[key] });
            }
            this.resourcemapdata = optionlist;
        }
        if (error) {
            console.log('-======---=ERROR==--=-=-' + JSON.stringify(error));
        }
    }

    @wire(getTheCurrentFY)
    wiredFYS({ error, data }) {
        if (data) {
            //console.log('-======---=getTheCurrentFY==-data-=-=-' + JSON.stringify(data));
            this.selectedfy = data.currentName;
            this.resourceId = data.currentResId;
            this.showGenPerKra = data.showGenPerKra;
            var consts = data.fyListMap;
            var optionlist = [];
            for (var key in consts) {
                optionlist.push({ label: key, value: consts[key] });
            }
            this.fymapdata = optionlist;
        }
        if (error) {
            console.log('-======---=ERROR==--=-=-' + JSON.stringify(error));
        }
    }
    handlerichChange(event) {
        this.myVal = event.target.value;
    }

    handleFYChange(event) {
        this.selectedfy = event.detail.value;
        //console.log('==selectedfy====' + this.selectedfy);
        this.getTheKRA();
        this.getCheckInfo();
    }
    handleResourceChange(event) {
        this.showtheFY = true;
        this.selectedresource = event.detail.value;
        //console.log('==selectedresource====' + this.selectedresource);
        this.myVal = '';
        //smaske : [EN_13]: Reseting Values and fetching Reportees till root
        this.secondarySelectedResource = null;
        this.tertiarySelectedResource = null;
        this.quaternarySelectedResource = null;
        this.viewonlymode = false;
        this.secondaryreporteesmapdata = null;
        this.tertiaryreporteesmapdata = null; //mukesh
        this.quaternaryreporteesmapdata = null; // mukesh
        this.GetReporteesHierarchy(this.selectedresource)
            .then((optionlist) => {
                // Assign optionlist to variable
                this.secondaryreporteesmapdata = optionlist;
            })
            .catch((error) => {
                console.error('Error occurred: ' + JSON.stringify(error));
            });

        this.getTheKRA();
        //smaske : Calling getCheckInfo() method on resource change
        //Fix for Defect PM_009
        this.getCheckInfo();
    }

    //smaske : [EN_13]: New dropdown handler
    /*  handleSecondaryResourceChange(event) {
         this.secondarySelectedResource = event.detail.value;
         console.log('==secondarySelectedResource====' + this.secondarySelectedResource);
         if (this.secondarySelectedResource != null) {
             this.viewonlymode = true;
             this.myVal = '';
             this.getTheKRA();
             this.getCheckInfo();
         }else{
             this.viewonlymode = false;
             this.myVal = '';
             this.getTheKRA();
             this.getCheckInfo();
         }
     } */
    //mukesh: for new requirement New dropdown handler 
    handleSecondaryResourceChange(event) {
        //Onchange based on Dropdown Name
        let name = event.target.name;
        //console.log('Name clciked lable :: ' + name);
        //console.log('Name clciked lable :: ' + event.detail.value);

        let selectedresocure = event.detail.value;
        if (name == 'secondary') {
            if (selectedresocure != null) {
                this.secondarySelectedResource = selectedresocure;
                this.tertiaryreporteesmapdata = null; //mukesh
                this.quaternaryreporteesmapdata = null; // mukesh
                this.tertiarySelectedResource = null;
                this.quaternarySelectedResource = null;
                this.viewonlymode = true;
                this.myVal = '';
                this.getTheKRA();
                this.getCheckInfo();
                //geting reportees through selected resource id
                this.GetReporteesHierarchy(this.secondarySelectedResource)
                    .then((optionlist) => {
                        // Assign optionlist to variable
                        this.tertiaryreporteesmapdata = optionlist;
                    })
                    .catch((error) => {
                        console.error('Error occurred: ' + JSON.stringify(error));
                    });
            } else {
                this.viewonlymode = false;//smaske [PM_Def_081] [24/july/2024] : Enabling the CreateGoal button when secondary is null
                this.tertiaryreporteesmapdata = [];
                this.quaternaryreporteesmapdata = [];
                this.secondarySelectedResource = null;
                this.tertiarySelectedResource = null;
                this.quaternarySelectedResource = null;
                this.kratable = [];
                this.cintable = [];
                this.getTheKRA();
                this.getCheckInfo();
            }

        } else if (name == 'tertiary') {
            if (selectedresocure != null) {
                this.tertiarySelectedResource = selectedresocure;
                this.quaternaryreporteesmapdata = null; // mukesh
                this.quaternarySelectedResource = null;
                this.viewonlymode = true;
                this.myVal = '';
                this.getTheKRA();
                this.getCheckInfo();
                //geting reporees through selected resource id
                this.GetReporteesHierarchy(this.tertiarySelectedResource)
                    .then((optionlist) => {
                        // Assign optionlist to variable
                        this.quaternaryreporteesmapdata = optionlist;
                    })
                    .catch((error) => {
                        console.error('Error occurred: ' + JSON.stringify(error));
                    });
            }else{
                this.quaternaryreporteesmapdata = [];
                this.tertiarySelectedResource = null;
                this.quaternarySelectedResource = null;
                this.kratable = [];
                this.cintable = [];
                this.getTheKRA();
                this.getCheckInfo();
            }

        } else if (name == 'quaternary') {
            if (selectedresocure != null) {
                this.quaternarySelectedResource = selectedresocure;
                this.viewonlymode = true;
                this.myVal = '';
                this.getTheKRA();
                this.getCheckInfo();
            }else{
                this.quaternarySelectedResource = null;
                this.kratable = [];
                this.cintable = [];
                this.getTheKRA();
                this.getCheckInfo();
            }

        } else {
            this.viewonlymode = false;
            this.myVal = '';
            this.getTheKRA();
            this.getCheckInfo();
        }

    }

    checkInToggle(event) {
        if (event.target.checked) {
            this.getCheckInfo();
        }
        this.showcheckin = event.target.checked;

    }
    pulseToggle(event) {
        this.showpulse = event.target.checked;
    }
    kraToggle(event) {
        if (event.target.checked) {
            this.getTheKRA();
        }
        this.showkras = event.target.checked;
    }

    getTheKRA() {
        console.log("IN GET KRA LWC");
        //smaske : [EN_13]: fetching records for selected records.
        let resourceId;
        if (this.selectedresource) {
            resourceId = this.selectedresource;
        }
        if (this.secondarySelectedResource) {
            resourceId = this.secondarySelectedResource;
        }
        if (this.tertiarySelectedResource) {
            resourceId = this.tertiarySelectedResource;
        }
        if (this.quaternarySelectedResource) {
            resourceId = this.quaternarySelectedResource;
        }

        getResourceKRAs({
            resourceId: resourceId,
            fyId: this.selectedfy
        })
            .then(result => {
                //console.log('====result getResourceKRAs =======' + JSON.stringify(result));
                //smaske : [EN_13]: Disabling Edit KRA button when Indirect Reportee are selected
                result.forEach(item => {
                    item.qualList.forEach(qualItem => {
                        if (this.viewonlymode == true) {
                            console.log("videmode is true");
                            qualItem.allowedit = false;
                        }
                        if (qualItem.mentorSubmitted == true) {
                            console.log("Set value of  allowedit");
                            qualItem.allowedit = false;
                        }
                        //smaske : [PM_Def_047] : Copy button should not be visible in MY TEAM section.
                        if (this.tab == 'My Team') {
                            qualItem.allowCopy = false;
                        }
                    });
                });

                //smaske : [EN_13]: Disabling CREATE GOAL button when Indirect Reportee are selected
                if(result.length > 0){
                    if (this.viewonlymode == true) {
                    result[0].dontallowCreateGoals = true;
                }
                }
                this.kratable = result;
                
            })
            .catch(error => {
                console.log('====Error=======' + JSON.stringify(error));
            });

    }

    getCheckInfo() {
        console.log("IN getCheckInfo LWC");
        //smaske : [EN_13]: fetching records for selected records.
        let resourceId;
        if (this.selectedresource) {
            resourceId = this.selectedresource;
        }
        if (this.secondarySelectedResource) {
            resourceId = this.secondarySelectedResource;
        }
        if (this.tertiarySelectedResource) {
            resourceId = this.tertiarySelectedResource;
        }
        if (this.quaternarySelectedResource) {
            resourceId = this.quaternarySelectedResource;
        } 

        getTheCheckInInfo({
            resourceId: resourceId,
            fyId: this.selectedfy
        })
            .then(result => {
                //console.log('====cintable=======' + JSON.stringify(result));
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

    handleCheckInSave() {
        console.log('==Resource Id==' + this.selectedresource);
        console.log('==Mentor Id==' + this.resourceId);
        console.log('==Comments Id==' + this.myVal);
        if (this.myVal === '' || this.myVal === null) {
            const evt = new ShowToastEvent({
                title: 'Notes Required',
                message: 'Please enter the check-in notes',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        } else {
            console.log('==Not Id==' + this.myVal);
            createCheckIn({
                resourceId: this.selectedresource,
                mentorId: this.resourceId,
                checkInComments: this.myVal
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
        console.log("vfv",this.isShowGeneratePerformaneKraModal);
        console.log("Current User Id :" + this.resourceId);
        console.log("Selected Team Member Id :" + this.selectedresource);

    }

    hideGeneratePerformaneKraModalBox() {
        this.isShowGeneratePerformaneKraModal = false;
    }

    modalCloseHandler() {
        this.isShowGeneratePerformaneKraModal = false;
        this.getTheKRA();
    }

    //smaske:[EN_13] New apex method call for fetching Reportees
    /* GetReporteesHierarchy(resourceId) {
        getReporteesInHierarchy({ selectedResourceId: resourceId })
            .then((result) => {
                console.log('#IN GetReporteesInHierarchy Result LWC ' + JSON.stringify(result));
                if (Object.keys(result).length > 0) {
                    var consts = result;
                    var optionlist = [];
                    for (var key in consts) {
                        optionlist.push({ label: key, value: consts[key] });
                    }
                    optionlist.unshift({ label: '--None--', value: null });
                    this.secondaryreporteesmapdata = optionlist;
                }

            })
            .catch((error) => {
                console.log(JSON.stringify(error));
            });
    } */

    //Mukesh : New apex method call for fetching Reportees
    GetReporteesHierarchy(resourceId) {
        return new Promise((resolve, reject) => {
            getReporteesInHierarchy({ selectedResourceId: resourceId })
                .then((result) => {
                    //console.log('#IN GetReporteesInHierarchy Result LWC ' + JSON.stringify(result));
                    if (Object.keys(result).length > 0) {
                        var consts = result;
                        var optionlist = [];
                        for (var key in consts) {
                            optionlist.push({ label: key, value: consts[key] });
                        }
                        optionlist.unshift({ label: '--None--', value: null });
                        resolve(optionlist);
                    } else {
                        resolve([]); // Return an empty array if no result
                    }
                })
                .catch((error) => {
                    console.log(JSON.stringify(error));
                    reject(error);
                });
        });
    }


    //smaske : [EN_13]: Setting Visibility of DROPDOWN
    @api
    get setReporteesHierarchyVisibility() {
        if (this.secondaryreporteesmapdata && this.secondaryreporteesmapdata.length > 0 && this.showGenPerKra == false) {
            return true;
        }
        return false;
    }
    //Mukesh : []: Setting Visibility of DROPDOWN
    get setReporteesHierarchyVisibility2() {
        if (this.tertiaryreporteesmapdata && this.tertiaryreporteesmapdata.length > 0 && this.showGenPerKra == false) {
            return true;
        }
        return false;
    }

    get setReporteesHierarchyVisibility3() {
        if (this.quaternaryreporteesmapdata && this.quaternaryreporteesmapdata.length > 0 && this.showGenPerKra == false) {
            return true;
        }
        return false;
    }
    //@Mukesh setting check-In Button Visibility
    get setCheckInVisibility() {
        if (this.secondarySelectedResource || this.tertiarySelectedResource || this.quaternarySelectedResource) {
            return false;
        }
        return true;
    }


    //@sangharsh Show Project Assignment
    ProjectAssignToggle(event) {
        //this.selectedresource
        if (event.target.checked) {
            this.showcombobox = true;
            console.log('====Is checked=======');
        }else{
                this.showcombobox = false;
        }
    }

}