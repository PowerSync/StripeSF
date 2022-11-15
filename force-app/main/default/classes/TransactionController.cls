/**
 * @description       : 
 * @author            : horobei
 * @group             : 
 * @last modified on  : 08-08-2022
 * @last modified by  : horobei
**/
public without sharing class TransactionController {
    private static final String STATUS = 'Succeeded';
    /**
    * @description 
    * @author horobei | 08-04-2022 
    * @param recordId 
    * @return TransactionWrapper 
    **/
    @AuraEnabled
    public static TransactionWrapper getTransaction(String recordId){
        try{
            String fieldName = setReletedObject(recordId);
            if (String.isBlank(fieldName)) {
                return null;
            }
            String  query = 'Select Id, Receipt__c, Status__c From Transaction__c Where Status__c = :STATUS And '
                +String.escapeSingleQuotes(fieldName)+' =:recordId Order by CreatedDate DESC limit 1';
        // if (Schema.sObjectType.Transaction__c.fields.Receipt__c.isAccessible() && 
        //     Schema.sObjectType.Transaction__c.fields.Status__c.isAccessible() && 
        //     Schema.sObjectType.Transaction__c.fields.Case__c.isAccessible() && 
        //     Schema.sObjectType.Transaction__c.fields.Opportunity__c.isAccessible() && 
        //     Schema.sObjectType.Transaction__c.fields.Order__c.isAccessible()) {
            Transaction__c t = Database.query(query);
                return new TransactionWrapper(t);
        // }
            // return null;
        }catch(System.QueryException e){
            return null;
        }
    }

    /**
    * @description 
    * @author horobei | 08-04-2022 
    * @param recordId 
    * @return String 
    **/
    private static String setReletedObject(String recordId){
        String objApiName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();  
        switch on objApiName {
            when 'Case' {
                return 'Case__c';
            }
            when 'Opportunity' {
                return 'Opportunity__c';
            }
            when 'Order' {
                return 'Order__c';
            }
        }
        return null;
    }

    /** @description TransactionWrapper **/
    public class TransactionWrapper {
        /** @description id **/
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        /** @description receipt **/
        public String receipt {get;set;}
        @AuraEnabled
        /** @description status **/
        public String status {get;set;}

        /**
        * @description 
        * @author horobei | 08-04-2022 
        * @param tr 
        **/
        public TransactionWrapper(Transaction__c tr){
            this.id = tr.Id;
            this.receipt = tr.Receipt__c;
            this.status = tr.Status__c;
        }
    }
}