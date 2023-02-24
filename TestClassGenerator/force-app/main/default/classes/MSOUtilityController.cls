Public Class MSOUtilityController{
    public static void updateAccountStatus(Set<Id> accIds){
        Map<Id,Integer> AgreemnetActiveTotalCountMap = new Map<Id,Integer>();
        Map<Id,Integer> openStagesCountMap = new Map<Id,Integer>();
        Map<Id,Integer> closedStagesCountMap = new Map<Id,Integer>();
        Map<Id,Integer> closedWonStageCountMap = new Map<Id,Integer>();
        Map<Id,Integer> AgreemnetExpiredTerminatedTotalCountMap = new Map<Id,Integer>();
        Map<Id,Integer> AgreemnetTotalCountMap = new Map<Id,Integer>();
        Set<String> openStages = new Set<String>{'New Lead','Qualify','Solution','Propose','Negotiate','Contract'};
        Set<String> closedStages = new Set<String>{'Closed Lost','No Bid','Cancelled'};
        try{
        List<Apttus__APTS_Agreement__c> agrList =[select Id,Apttus__Account__c,Apttus__Status_Category__c  from Apttus__APTS_Agreement__c where Apttus__Account__c IN:accIds];
        for(Apttus__APTS_Agreement__c agr:agrList ){
            if(agr.Apttus__Status_Category__c == 'In Effect'){
                AgreemnetActiveTotalCountMap.put(agr.Apttus__Account__c,AgreemnetActiveTotalCountMap.containskey(agr.Apttus__Account__c)?AgreemnetActiveTotalCountMap.get(agr.Apttus__Account__c)+1:1);
            }
            else if(agr.Apttus__Status_Category__c == 'Expired' || agr.Apttus__Status_Category__c == 'Terminated'){
                AgreemnetExpiredTerminatedTotalCountMap.put(agr.Apttus__Account__c,AgreemnetExpiredTerminatedTotalCountMap.containskey(agr.Apttus__Account__c)?AgreemnetExpiredTerminatedTotalCountMap.get(agr.Apttus__Account__c)+1:1);
            }
            AgreemnetTotalCountMap.put(agr.Apttus__Account__c,AgreemnetTotalCountMap.containskey(agr.Apttus__Account__c)?AgreemnetTotalCountMap.get(agr.Apttus__Account__c)+1:1);
            
        }
        /*List<AggregateResult> agrTEList =[ select Apttus__Account__c, count(Id) total  from Apttus__APTS_Agreement__c where Apttus__Account__c IN:accIds and (Apttus__Status_Category__c='Expired' OR Apttus__Status_Category__c='Terminated') group by Apttus__Account__c];
        for(AggregateResult agr:agrTEList ){
            AgreemnetExpiredTerminatedTotalCountMap.put(String.valueof(agr.get('Apttus__Account__c')),(Integer)agr.get('total'));
        }
        List<AggregateResult> agrTotqList =[ select Apttus__Account__c, count(Id) total  from Apttus__APTS_Agreement__c where Apttus__Account__c IN:accIds group by Apttus__Account__c];
        for(AggregateResult agr:agrTotqList){
            AgreemnetTotalCountMap.put(String.valueof(agr.get('Apttus__Account__c')),(Integer)agr.get('total'));
        }*/
        system.debug('AgreemnetActiveTotalCountMap||||' + AgreemnetActiveTotalCountMap);
            system.debug('AgreemnetExpiredTerminatedTotalCountMap||||' + AgreemnetExpiredTerminatedTotalCountMap);
            system.debug('AgreemnetTotalCountMap||||' + AgreemnetTotalCountMap);
        List<Opportunity> oppList = [Select Id,AccountId,StageName from opportunity where AccountId IN:accIds];
        for(Opportunity opp:oppList ){
            if(openStages.contains(opp.StageName)){
                openStagesCountMap.put(opp.AccountId,openStagesCountMap.containskey(opp.AccountId)?openStagesCountMap.get(opp.AccountId)+1:1);   
            }
            
            else if(closedStages.contains(opp.StageName)){
                closedStagesCountMap.put(opp.AccountId,closedStagesCountMap.containskey(opp.AccountId)?closedStagesCountMap.get(opp.AccountId)+1:1);   
            }
        }
        List<Account> accList = [select Id,Status__c from account where Id IN:accIds];
        for(Account acc:accList){
            if((AgreemnetActiveTotalCountMap.containskey(acc.Id) && AgreemnetActiveTotalCountMap.get(acc.Id)>0) ){
                    acc.Status__c = 'Customer';
            }
            else if(AgreemnetExpiredTerminatedTotalCountMap.containskey(acc.Id) && AgreemnetExpiredTerminatedTotalCountMap.get(acc.Id)> 0){
                  acc.Status__c = 'Prior Customer';
            }
            else if(openStagesCountMap.containskey(acc.Id) && openStagesCountMap.get(acc.Id)>0){
                acc.Status__c = 'Prospect - Active';
            }
            else if((closedStagesCountMap.containskey(acc.Id) && closedStagesCountMap.get(acc.Id)>0)||(openStagesCountMap.containskey(acc.Id)==false)){
                acc.Status__c = 'Prospect - Inactive';
            }
            else {
                acc.Status__c = 'New';
            }
            
        }
        
        if(accList.size()>0) update accList;
        }
        catch(exception e){
            system.debug('=======e====='+e.getmessage());
        }
        
        
    }
    
    public Static Set<Id> getManufacturerAccounts(Set<Id> accIds){
        Id mfRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Manufacturer').getRecordTypeId();
        Map<Id,Account> accMap = new Map<Id,Account>([select Id from Account Where RecordTypeId =:mfRecordTypeId and Id IN:accIds]);
        return accMap.size()>0?accMap.keyset(): new Set<Id>();
    }
   // @InvocableMethod(label='UpdateOpptyAccount' description='Update the account base on opportunity status'  category= 'Account')
  //  public static void updateOppAccountsStatus(List<Opportunity> oppList){
  //     Set<Id> accIds = new Set<Id>();
  //     for(Opportunity opp:oppList) {
   //        accIds.add(opp.AccountId);
  //     }
  //       MSOUtilityController.updateAccountStatus(accIds);
      //Set<Id> manufacturerAccountIds = MSOUtilityController.getManufacturerAccounts(accIds);
      //if(manufacturerAccountIds.size()>0){
      //    MSOUtilityController.updateAccountStatus(manufacturerAccountIds);
      //}
   // }
}