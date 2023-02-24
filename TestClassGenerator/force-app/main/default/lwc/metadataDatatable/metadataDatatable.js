import { LightningElement, track, wire } from 'lwc';
import fetchDetails from '@salesforce/apex/FetchMetadataDetails.fetchDetails'
import checkConnection from '@salesforce/apex/FetchMetadataDetails.checkConnection'

export default class MetadataDatatable extends LightningElement {
    @track datatableColumns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Status', fieldName: 'Status' },
        { label: 'Modified', fieldName: 'LastModifiedDate' },
        { label: 'Size', fieldName: 'LengthWithoutComments' },
        { label: 'Coverage', fieldName: 'coverage' },
        { type: "button", typeAttributes: {  
        label: 'Generate TestClass',  
        name: 'TestClass',  
        title: 'TestClass',  
        disabled: false,  
        value: 'TestClass',
        iconName: 'utility:connected_apps',  
        iconPosition: 'left'  
    } }
    ];

    @track apexResources;
    @track error;
    @track type;
//     @wire(fetchDetails) wiredDetails({data,error}){
//         if (data) {
//              this.apexResources = data;
//         console.log('data',data); 
//         } else if (error) {
//         console.log('error', error);
//         }
//    }
   handleLoad(){
       fetchDetails()
            .then(result => {
                this.apexResources = result;
                console.log('result',result); 
            })
            .catch(error => {
                this.error = error;
                console.log('error', error);
            });
   }

   callRowAction( event ) {
       const recId =  event.detail.row.Id;  
       const actionName = event.detail.action.name; 
       checkConnection().then(result => {
                alert(result);
                console.log('result',result); 
            })
            .catch(error => {
                this.error = error;
                console.log('error', error);
            });
   }

}