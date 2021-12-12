public with sharing class BadgeDataWrapperService {

    public static List<BadgeDataWrapper> getBadgeDataForContact(String recordId, String accountId) {
        List<Contact_Badge_Definition__mdt> lstDefinitions = getSortedDefinitions();
        List<BadgeDataWrapper> lstBadgeData = getBadgeDataWrappers(lstDefinitions, recordId, accountId);
        return lstBadgeData;
    }

    public class BadgeDataWrapper {
        @AuraEnabled
        public Id id {get;set;}
        @AuraEnabled
        public String objType {get;set;}
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String colorStyle {get;set;}
        @AuraEnabled
        public String labelStyle {get;set;}
        @AuraEnabled
        public String iconName {get;set;}
        @AuraEnabled
        public String fieldSet {get;set;}
        @AuraEnabled
        public Boolean hasAlert {get;set;}
        @AuraEnabled
        public String alertMessage {get;set;}
    }

    private static List<Contact_Badge_Definition__mdt> getSortedDefinitions() {
        List<Contact_Badge_Definition__mdt> lstUnsortedDefinitions = Contact_Badge_Definition__mdt.getAll().values();
        List<Contact_Badge_Definition__mdt> lstDefinitions = ContactBadgesHelper.sortContactBadgeDefinitions(lstUnsortedDefinitions);
        return lstDefinitions;
    }

    private static List<BadgeDataWrapper> getBadgeDataWrappers(
        List<Contact_Badge_Definition__mdt> lstDefinitions,
        String recordId, 
        String accountId
    ) {
        // Create empty list of wrappers to return
        List<BadgeDataWrapper> lstBadgeData = new List<BadgeDataWrapper>();
        // Create set to store label names to avoid duplicates
        Set<String> setLabelNames = new Set<String>();
        for (Contact_Badge_Definition__mdt definition : lstDefinitions) {
            if (!definition.Active__c) {
                continue;
            }
            // Query for related records
            String query = ContactBadgesHelper.getQueryFromDefinition(definition);
            List<SObject> queryResults = Database.query(query);
            // Create wrapper from mdt details and add to list
            for (SObject obj : queryResults) {
                BadgeDataWrapper badge = new BadgeDataWrapper();
                badge.id         = obj.Id;
                badge.objType    = definition.Object_Type__c;
                badge.label      = ContactBadgesHelper.getBadgeLabel(definition, obj);
                badge.colorStyle = ContactBadgesHelper.getBadgeColorStyle(definition);
                badge.labelStyle = ContactBadgesHelper.getBadgeLabelStyle(definition);
                badge.iconName   = ContactBadgesHelper.getBadgeIconName(definition);
                badge.fieldSet   = definition.Additional_Detail_Fields__c;
                if (definition.Alert__c) {
                    badge.hasAlert = true;
                    badge.alertMessage = definition.Alert_Message__c;
                } else {
                    badge.hasAlert = false;
                }
                if (setLabelNames.contains(badge.label)) {
                    continue;
                }
                setLabelNames.add(badge.label);
                lstBadgeData.add(badge);
            }
        }
        return lstBadgeData;
    }

}