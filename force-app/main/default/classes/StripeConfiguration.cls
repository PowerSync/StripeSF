/**
 * @description       : 
 * @author            : horobei
 * @group             : 
 * @last modified on  : 08-04-2022
 * @last modified by  : horobei
**/
public without sharing class StripeConfiguration {
    /**
    * @description 
    * @author horobei | 08-04-2022 
    * @return Configuration 
    **/
    @AuraEnabled(cacheable=true) 
    public static Configuration getCustomSettings(){
        Stripe_Configurations__c configs = Stripe_Configurations__c.getOrgDefaults();
        return new Configuration(configs);
    }

    /**
    * @description 
    * @author horobei| 08-04-2022 
    * @param configs 
    * @return Configuration 
    **/
    @AuraEnabled
    public static Configuration saveCustomSettings(String configs){
        Configuration configsObj = (Configuration) JSON.deserializeStrict(configs, Configuration.class);
        if(Stripe_Configurations__c.SObjectType.getDescribe().isAccessible() && 
            Stripe_Configurations__c.SObjectType.getDescribe().isCreateable() &&
            Stripe_Configurations__c.SObjectType.getDescribe().isUpdateable() && 
            Schema.SObjectType.Stripe_Configurations__c.fields.Base_URL__c.isCreateable() && 
            Schema.SObjectType.Stripe_Configurations__c.fields.Base_URL__c.isUpdateable() && 
            Schema.SObjectType.Stripe_Configurations__c.fields.Secret_key__c.isCreateable() && 
            Schema.SObjectType.Stripe_Configurations__c.fields.Secret_key__c.isUpdateable()) {
            upsert new Stripe_Configurations__c(Id = configsObj.id, Base_URL__c = configsObj.baseUrl, Secret_key__c = configsObj.secretKey);
        }
        
        return getCustomSettings();
    }

    /**
    * @description 
    * @author horobei | 08-04-2022 
    * @return Boolean 
    **/
    @AuraEnabled
    public static Boolean checkConnection() {
        try{
            Stripe_Configurations__c sc = Stripe_Configurations__c.getOrgDefaults();
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(sc.Base_URL__c+'v1/accounts?limit=1');
            request.setMethod('GET');
            request.setHeader('Authorization', 'Bearer ' + sc.Secret_key__c);
            HttpResponse response = http.send(request);
            if (response.getStatusCode()== 200) {
                return true;
            } else {
                return false;
            }
        }catch (Exception e) {
            return false;
        }
    }
    /** @description Configuration **/
    public class Configuration {
        /** @description id **/
        @AuraEnabled
        public String id {get;set;}
        /** @description baseUrl **/
        @AuraEnabled
        public String baseUrl {get;set;}
        /** @description secretKey **/
        @AuraEnabled
        public String secretKey {get;set;}

        /**
        * @description 
        * @author horobei | 08-04-2022 
        * @param configs 
        **/
        public Configuration(Stripe_Configurations__c configs){
            this.baseUrl = configs.Base_URL__c;
            this.secretKey = configs.Secret_key__c;
            this.id = configs.id;
        }
    }
}