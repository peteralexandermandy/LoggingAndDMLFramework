@isTest
private class VaEncryption_Test {
  
    static testMethod void TestEncryptingDataAsVirtualAssistant() {
        User csrUser = TestPersonaFactory.getPersona(TestPersonaFactory.Persona_CSR, false);
        system.runAs(csrUser){
            List<SecurityKey__mdt> keyInformation = [SELECT MasterLabel, privateKey__c, initializationVector__c FROM SecurityKey__mdt];
            String testDataField = 'TestDataField1';
            String testDataValue = 'TestData';
            Blob encryptedBlob = Crypto.encrypt('AES256'
                                                ,Blob.valueOf(keyInformation[0].privateKey__c)
                                                ,Blob.valueOf(keyInformation[0].initializationVector__c)
                                                ,Blob.valueOf(testDataValue));             
            String encryptedText = EncodingUtil.base64Encode(encryptedBlob);
            String decryptedText = VaEncryption.decrypt(keyInformation[0].MasterLabel, 'test', encryptedText);
            system.assertEquals(testDataValue, decryptedText);
        }
    }

    static testMethod void TestEncryptingDataAsVirtualAssistantMissingKey() {
        User csrUser = TestPersonaFactory.getPersona(TestPersonaFactory.Persona_CSR, false);
        system.runAs(csrUser){
            List<SecurityKey__mdt> keyInformation = [SELECT MasterLabel, privateKey__c, initializationVector__c FROM SecurityKey__mdt];
            system.assertEquals(keyInformation.size() > 0, true);
        }
    }

    static testMethod void TestEncryptingDataAsVirtualAssistantErroneousEncryption() {
        User csrUser = TestPersonaFactory.getPersona(TestPersonaFactory.Persona_CSR, false);
        system.runAs(csrUser){
            String decryptedText;
            Boolean didTestFail = false;
            List<SecurityKey__mdt> keyInformation = [SELECT MasterLabel, privateKey__c, initializationVector__c FROM SecurityKey__mdt];
            String testDataField = 'TestDataField1';
            String testDataValue = 'TestData';
            Blob encryptedBlob = Crypto.encrypt('AES256'
                                                ,Blob.valueOf(keyInformation[0].privateKey__c)
                                                ,Blob.valueOf(keyInformation[0].initializationVector__c)
                                                ,Blob.valueOf(testDataValue)); 
            
            String encryptedText = String.valueOf(encryptedBlob); // Do a simple string conversion which will fail when we decrypt.
            try{
                decryptedText = VaEncryption.decrypt(keyInformation[0].MasterLabel, 'test', encryptedText);
                if(decryptedText == null){
                    didTestFail = true;
                }
            }catch(Exception ex){
                didTestFail = true;
            }
            system.assertEquals(didTestFail, true);
        }
    }

    static testMethod void TestDecryptionOntoLiveChatUponSave() {
        User csrUser = TestPersonaFactory.getPersona(TestPersonaFactory.Persona_CSR, false);
        Id chatid;
        Test.StartTest();
        system.runAs(csrUser){
             LiveChatTranscript chat = TestDataFactory.createChatTranscriptWithEncryptedFields();
             chatid = chat.Id;
        }
        Test.StopTest();
        LiveChatTranscript chatPostSave = [SELECT Id, Decryption_Error__c, 
                                                  Client_ID__c, Policy_Number__c, Email_Address__c, First_Name__c, Last_Name__c, State__c,             
                                                  Encrypted_Client_ID__c, Encrypted_Policy_Number__c, Encrypted_Email__c, Encrypted_First_Name__c, Encrypted_Last_Name__c, Encrypted_State__c 
                                             FROM LiveChatTranscript WHERE Id = :chatid];
        // Encrypted% Fields should be NULL Post Save.
        system.assertEquals(String.isBlank(chatPostSave.Encrypted_Client_ID__c), true);
        system.assertEquals(String.isBlank(chatPostSave.Encrypted_Policy_Number__c), true);
        system.assertEquals(String.isBlank(chatPostSave.Encrypted_Email__c), true);
        system.assertEquals(String.isBlank(chatPostSave.Encrypted_First_Name__c), true);
        system.assertEquals(String.isBlank(chatPostSave.Encrypted_Last_Name__c), true);
        system.assertEquals(String.isBlank(chatPostSave.Encrypted_State__c), true);
        // Make sure there are no errors. 
        system.assertEquals(chatPostSave.Decryption_Error__c, false);
    }
    static testMethod void TestEncryptingDataAsVirtualAssistantNullFieldValue() {
        User csrUser = TestPersonaFactory.getPersona(TestPersonaFactory.Persona_CSR, false);
        Test.StartTest();
        system.runAs(csrUser){
            List<SecurityKey__mdt> keyInformation = [SELECT MasterLabel, privateKey__c, initializationVector__c FROM SecurityKey__mdt];
            String testDataField = 'TestDataField1';
            String testDataValue = 'TestData';
            Blob encryptedBlob = Crypto.encrypt('AES256'
                                                ,Blob.valueOf(keyInformation[0].privateKey__c)
                                                ,Blob.valueOf(keyInformation[0].initializationVector__c)
                                                ,Blob.valueOf(testDataValue));             
            String encryptedText = EncodingUtil.base64Encode(encryptedBlob);
            String decryptedText = VaEncryption.decrypt(keyInformation[0].MasterLabel, 'test', '');
        }
        Test.StopTest();
        List<ApplicationErrorLog__c> logs = [SELECT Id FROM ApplicationErrorLog__c];
        system.assertEquals(logs.isEmpty(), false);
    }

}