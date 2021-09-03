@isTest
/**
 * Test factory that creates all of the Persona based users
 * that participate in this system.
 * Handles profiles, permissionset, and role assignments
 **/ 
public with sharing class TestPersonaFactory {

    public static final String Persona_VA = 'Virtual Assistant Minimum Access Profile';    
    public static final String Persona_CSR = 'CSR';  
    public static final String Personal_AutomatedProcess = 'Automated Process';   

    /**
     * Convenience overload, defaulting to insert=true
     **/ 
    public static User getPersona(String profileName) {
        return getPersona(profileName,true); 
    }

    public static User getPersona(String profileName, Boolean doInsert){  
        User newUser = null;
        User runningUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.RunAs(runningUser) {   
             String ms = String.valueOf(system.now().getTime());   
             newUser = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = :profileName].Id,
                                FirstName = 'TestFirstName',
                                LastName = 'TestLastName',
                                Email = 'first.last@' + ms + '.test.com.dev',
                                Username = 'first.last@' + ms + '.com.dev',
                                CompanyName = 'TEST Co',
                                Title = 'TestUser',
                                Alias = 'tstusr',
                                TimeZoneSidKey = 'America/Los_Angeles',
                                EmailEncodingKey = 'UTF-8',
                                LanguageLocaleKey = 'en_US',
                                LocaleSidKey = 'en_US');
            if(doInsert){
                insert newUser;
            }
        }     
        return newUser;
    }

    public static Group getVAQueue(){
        Group queue = new Group (Name = 'Chat - Virtual Assistant TEST', Type = 'Queue');
        insert queue;
        return queue;
    }


}