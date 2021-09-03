trigger LiveChatTranscript on LiveChatTranscript (before insert, before update) {
        
    if(trigger.isBefore){
 
        if(trigger.isInsert){
            for (LiveChatTranscript recordNew : Trigger.new) {
                    String application = recordNew.Application__c;
                
                if ( application == 'EDGE') {         
                    
                    ApexLogging.information('EDGE Chat Field decryption and then set encrypted values to NULL.', true);
                    
                    String firstName                 = VaEncryption.decrypt(application, 'firstName', recordNew.Encrypted_First_Name__c);
                    String lastName                  = VaEncryption.decrypt(application, 'lastName', recordNew.Encrypted_Last_Name__c);
                    String email                     = VaEncryption.decrypt(application, 'email', recordNew.Encrypted_Email__c);
                    String state                     = VaEncryption.decrypt(application, 'state', recordNew.Encrypted_State__c);
                    String policyNumber              = VaEncryption.decrypt(application, 'policyNumber', recordNew.Encrypted_Policy_Number__c);
                    String clientID                  = VaEncryption.decrypt(application, 'clientID', recordNew.Encrypted_Client_ID__c);
                    
                    Boolean decryptionError = false;
                    if (firstName == null || lastName == null || email == null || state == null || policyNumber == null || clientID == null) {
                        decryptionError = true;  
                        ApexLogging.warning('One more more EDGE Chat Fields are NULL.', false);                   
                    }                    
                    recordNew.First_Name__c               = firstName;
                    recordNew.Last_Name__c                = lastName;
                    recordNew.Email_Address__c            = email;
                    recordNew.State__c                    = state;
                    recordNew.Policy_Number__c            = policyNumber;
                    recordNew.Client_ID__c                = clientID;
                    
                    recordNew.Decryption_Error__c         = decryptionError;
                    
                    recordNew.Encrypted_First_Name__c     = null;
                    recordNew.Encrypted_Last_Name__c      = null;
                    recordNew.Encrypted_Email__c          = null;
                    recordNew.Encrypted_State__c          = null;
                    recordNew.Encrypted_Policy_Number__c  = null;
                    recordNew.Encrypted_Client_ID__c      = null;  
                }
            }  
        }

        if(trigger.isUpdate){
            for (LiveChatTranscript recordNew : Trigger.new) {
                recordNew.Encrypted_First_Name__c     = null;
                recordNew.Encrypted_Last_Name__c      = null;
                recordNew.Encrypted_Email__c          = null;
                recordNew.Encrypted_State__c          = null;
                recordNew.Encrypted_Policy_Number__c  = null;
                recordNew.Encrypted_Client_ID__c      = null;
                ApexLogging.information('ENCRYPTED Fields set to NULL.', false);
            }
        }
        
    }

}