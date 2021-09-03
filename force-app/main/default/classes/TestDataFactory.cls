@IsTest
// Create test data
public class TestDataFactory {

    public static final Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId(); 
    
    public static final String edgeFirstName = 'edgeFirstNameTest';
    public static final String edgeLastName = 'edgeLastNameTest';
    public static final String edgeEmailAddress = 'edge@test.com.test';
    public static final String edgeClientId = '123456';

    public static final String staticFirstName = 'staticFirstNameTest';
    public static final String staticLastName = 'staticLastNameTest';
    public static final String staticEmailAddress = 'static@test.com.test';
    public static final String staticClientId = '';

    public static final String staticApp = 'geico.com';
    public static final String edgeApp = 'EDGE';
    
    public static VA_User_Mapping__c createCustomSettingDataForVa(Id vaUserId){
        VA_User_Mapping__c usersAndQueues = VA_User_Mapping__c.getOrgDefaults();
        usersAndQueues.Automated_Process_User_ID__c = [SELECT Id FROM User WHERE Name = :TestPersonaFactory.Personal_AutomatedProcess].Id;
        usersAndQueues.Chat_VA_Queue_ID__c = TestPersonaFactory.getVAQueue().Id;
        usersAndQueues.VA_User_ID__c = vaUserId; //TestPersonaFactory.getPersona(TestPersonaFactory.Persona_VA, true).Id;
        upsert usersAndQueues;
        return usersAndQueues;
    }

    public static Account createPersonAccountForEmail(String emailAddress, Boolean doInsert){
         Account a = new Account(FirstName = 'FirstNameTest',
                                 LastName = 'LastNameTest',
                                 RecordTypeId = personAccountRecordTypeId,
                                 PersonEmail = emailAddress); 
         if(doInsert){
            insert a;
         }
         return a;
    }

    public static Account createPersonAccount(String application, Boolean doInsert){
        Account a = new Account(FirstName = application == staticApp ? staticFirstName : edgeFirstName,
                                 LastName = application == staticApp ? staticLastName : edgeLastName,
                                 ClientID__pc = application == staticApp ? staticClientId : edgeClientId,
                                 RecordTypeId = personAccountRecordTypeId,
                                 PersonEmail = application == staticApp ? staticEmailAddress : edgeEmailAddress);                                          
         if(doInsert){
             insert a;
         }
         return a;
     }

     public static Case createCaseForChatTranscript(){
        Case c = new Case(Subject = 'Virtual Assistant Generated', OwnerId = UserInfo.getUserId());
        insert c;
        return c;
     }

    public static LiveChatVisitor createChatVisitor(){
        LiveChatVisitor visitor = new LiveChatVisitor();
        insert visitor;
        return visitor;
    }

    public static LiveChatTranscript createChatTranscript(){
        Case c = TestDataFactory.createCaseForChatTranscript();
        LiveChatVisitor visitor = TestDataFactory.createChatVisitor();
        LiveChatTranscript chat = new LiveChatTranscript(LiveChatVisitorId = visitor.Id,
                                                         First_Name__c = 'fn_test',
                                                         Last_Name__c = 'ln_test',
                                                         Email_Address__c = 'test@test.com.123',
                                                         Policy_Number__c = '123',
                                                         State__c = 'MA',
                                                         Application__c = 'EDGE',
                                                         Client_ID__c = '456',
                                                         URL__c = 'https://testurl.testclasses.com/',
                                                         Language__c = 'en_US',
                                                         CaseId = c.Id);
        insert chat;        
        return chat;
    }
 
    public static LiveChatTranscript createChatTranscriptWithEncryptedFields(String application, Boolean doInsert){
        Case c = TestDataFactory.createCaseForChatTranscript();
        LiveChatVisitor visitor = TestDataFactory.createChatVisitor();
        LiveChatTranscript chat = new LiveChatTranscript(LiveChatVisitorId = visitor.Id,
                                                         First_Name__c = application == staticApp ? staticFirstName : edgeFirstName,
                                                         Last_Name__c = application == staticApp ? staticLastName : edgeLastName,
                                                         Email_Address__c = application == staticApp ? staticEmailAddress : edgeEmailAddress,
                                                         Policy_Number__c = '123',
                                                         State__c = 'MA',
                                                         Application__c = application,
                                                         Client_ID__c = application == staticApp ? staticClientId : edgeClientId,
                                                         URL__c = 'https://testurl.testclasses.com/',
                                                         Language__c = 'en_US',
                                                         CaseId = c.Id);
        if(doInsert){
            insert chat;
        }
        return chat;
    }

    public static LiveChatTranscript createChatTranscriptWithEncryptedFields(Boolean hasClientId, Boolean doInsert){
        Case c = TestDataFactory.createCaseForChatTranscript();
        LiveChatVisitor visitor = TestDataFactory.createChatVisitor();
        LiveChatTranscript chat = new LiveChatTranscript(LiveChatVisitorId = visitor.Id,
                                                         First_Name__c = 'fn_test',
                                                         Last_Name__c = 'ln_test',
                                                         Email_Address__c = 'test@test.com.123',
                                                         Policy_Number__c = '123',
                                                         State__c = 'MA',
                                                         Application__c = 'EDGE',
                                                         Client_ID__c = hasClientId ? '456' : '',
                                                         URL__c = 'https://testurl.testclasses.com/',
                                                         Language__c = 'en_US',
                                                         CaseId = c.Id);
        chat.Encrypted_First_Name__c = encrypt(chat, chat.get('First_Name__c'));
        chat.Encrypted_Last_Name__c = encrypt(chat, chat.get('Last_Name__c'));
        chat.Encrypted_Email__c = encrypt(chat, chat.get('Email_Address__c'));
        chat.Encrypted_State__c = encrypt(chat, chat.get('State__c'));
        chat.Encrypted_Policy_Number__c = encrypt(chat, chat.get('Policy_Number__c'));
        chat.Encrypted_Client_ID__c = encrypt(chat, chat.get('Client_ID__c'));                                            
        if(doInsert){
            insert chat;
        }
        return chat;
    }

    public static LiveChatTranscript createChatTranscriptWithEncryptedFields(){
        Case c = TestDataFactory.createCaseForChatTranscript();
        LiveChatVisitor visitor = TestDataFactory.createChatVisitor();
        LiveChatTranscript chat = new LiveChatTranscript(LiveChatVisitorId = visitor.Id,
                                                         First_Name__c = 'fn_test',
                                                         Last_Name__c = 'ln_test',
                                                         Email_Address__c = 'test@test.com.123',
                                                         Policy_Number__c = '123',
                                                         State__c = 'MA',
                                                         Application__c = 'EDGE',
                                                         Client_ID__c = '456',
                                                         URL__c = 'https://testurl.testclasses.com/',
                                                         Language__c = 'en_US',
                                                         CaseId = c.Id,
                                                         Token__c = 'TEST=');
        chat.Encrypted_First_Name__c = encrypt(chat, chat.get('First_Name__c'));
        chat.Encrypted_Last_Name__c = encrypt(chat, chat.get('Last_Name__c'));
        chat.Encrypted_Email__c = encrypt(chat, chat.get('Email_Address__c'));
        chat.Encrypted_State__c = encrypt(chat, chat.get('State__c'));
        chat.Encrypted_Policy_Number__c = encrypt(chat, chat.get('Policy_Number__c'));
        chat.Encrypted_Client_ID__c = String.isBlank((String)chat.get('Client_ID__c')) ? null : encrypt(chat, chat.get('Client_ID__c'));                                            
        insert chat;
        return chat;
    }
    
    private static String encrypt(LiveChatTranscript chat, Object val){
        SecurityKey__mdt keyInfo = SecurityKey__mdt.getInstance(chat.Application__c.toUpperCase()); 
        return EncodingUtil.base64Encode(Crypto.encrypt('AES256', Blob.valueOf(keyinfo.privateKey__c), Blob.valueOf(keyinfo.initializationVector__c), Blob.valueOf((String)val)));
    }

}