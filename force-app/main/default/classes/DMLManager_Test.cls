@IsTest 
/**
 * Test Class for DML Manager and Logging Wrapper.
 **/ 
private class DMLManager_Test {
    static testMethod void testInsert() {
        User vaUser = TestPersonaFactory.getPersona(TestPersonaFactory.Persona_CSR, false);
        Test.startTest();
        system.runAs(vaUser){
            LiveChatTranscript chat = TestDataFactory.createChatTranscriptWithEncryptedFields('EDGE', false);
            DMLManager.insertAsUser(new List<LiveChatTranscript>{chat}, true);
        }
        Test.stopTest();
        List<Log__c> logs = [SELECT Id FROM Log__c];
        system.assertEquals(logs.isEmpty(), false);
    }

    static testMethod void testUpdate() {
        User vaUser = TestPersonaFactory.getPersona(TestPersonaFactory.Persona_CSR, false);
        Test.startTest();
        system.runAs(vaUser){
            LiveChatTranscript chat = TestDataFactory.createChatTranscriptWithEncryptedFields('EDGE', false);
            DMLManager.insertAsUser(new List<LiveChatTranscript>{chat}, true);
            DMLManager.updateAsUser(new List<LiveChatTranscript>{chat}, true);
        }
        Test.stopTest();
        List<Log__c> logs = [SELECT Id FROM Log__c];
        system.assertEquals(logs.isEmpty(), false);
    }

    static testMethod void testUpsert() {
        User vaUser = TestPersonaFactory.getPersona(TestPersonaFactory.Persona_CSR, false);
        Test.startTest();
        system.runAs(vaUser){
            LiveChatTranscript chat = TestDataFactory.createChatTranscriptWithEncryptedFields('EDGE', false);
            Schema.DescribeFieldResult field = LiveChatTranscript.Id.getDescribe();
            Schema.sObjectField sObjectField = field.getSObjectField();
            DMLManager.upsertAsUser(new List<LiveChatTranscript>{chat}, sObjectField, true);
        }
        Test.stopTest();
        List<Log__c> logs = [SELECT Id FROM Log__c];
        system.assertEquals(logs.isEmpty(), false);
    }

    //Error DML Testing
    static testMethod void testInsertWithErrors() {
        User vaUser = TestPersonaFactory.getPersona(TestPersonaFactory.Persona_CSR, false);
        Test.startTest();
        system.runAs(vaUser){
            LiveChatTranscript chat = TestDataFactory.createChatTranscriptWithEncryptedFields('EDGE', false);
            chat.First_Name__c = '1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890EXTRALONG'; //too long intentionally
            DMLManager.insertAsUser(new List<LiveChatTranscript>{chat}, true);
        }
        Test.stopTest();
        List<Log__c> logs = [SELECT Id FROM Log__c];
        system.assertEquals(logs.isEmpty(), false);
    }

    static testMethod void testUpdateWithErrors() {
        User vaUser = TestPersonaFactory.getPersona(TestPersonaFactory.Persona_CSR, false);
        Test.startTest();
        system.runAs(vaUser){
            LiveChatTranscript chat = TestDataFactory.createChatTranscriptWithEncryptedFields('EDGE', false);
            DMLManager.insertAsUser(new List<LiveChatTranscript>{chat}, true);
            chat.First_Name__c = '1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890EXTRALONG'; //too long intentionally
            DMLManager.updateAsUser(new List<LiveChatTranscript>{chat}, true);
        }
        Test.stopTest();
        List<Log__c> logs = [SELECT Id FROM Log__c];
        system.assertEquals(logs.isEmpty(), false);
    }

    static testMethod void testUpsertWithErrors() {
        User vaUser = TestPersonaFactory.getPersona(TestPersonaFactory.Persona_CSR, false);
        Test.startTest();
        system.runAs(vaUser){
            LiveChatTranscript chat = TestDataFactory.createChatTranscriptWithEncryptedFields('EDGE', false);
            Schema.DescribeFieldResult field = LiveChatTranscript.Id.getDescribe();
            Schema.sObjectField sObjectField = field.getSObjectField();
            chat.First_Name__c = '1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890EXTRALONG'; //too long intentionally
            DMLManager.upsertAsUser(new List<LiveChatTranscript>{chat}, sObjectField, true);
        }
        Test.stopTest();
        List<Log__c> logs = [SELECT Id FROM Log__c];
        system.assertEquals(logs.isEmpty(), false);
    }

    // Other Logging Method coverage
    static testMethod void testOtherLoggingMethods() {
        User vaUser = TestPersonaFactory.getPersona(TestPersonaFactory.Persona_CSR, false);
        Test.startTest();
        system.runAs(vaUser){
            LiveChatTranscript chat = TestDataFactory.createChatTranscriptWithEncryptedFields('EDGE', false);
            DMLManager.insertAsUser(new List<LiveChatTranscript>{chat}, true);
            ApexLogging.debug('Test', true);
            ApexLogging.fine('Test', true);
            ApexLogging.finer('Test', true);
            ApexLogging.finest('Test', true);
            ApexLogging.information('Test', chat, false);
            ApexLogging.warning('Test', chat.Id, true);
            ApexLogging.warning('Test', chat, true);
        }
        Test.stopTest();
    }
    
}
