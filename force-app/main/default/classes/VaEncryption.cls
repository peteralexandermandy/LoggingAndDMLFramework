/**
 * Virtual Assistant helper class to decrypt encrypted pre-chat variables
 **/ 
public with sharing class VaEncryption {
   
    public static String decrypt(String source, String fieldName, String encryptedValue){  
        try{
            if(String.isBlank(encryptedValue)){
                LogUtil.log('EDGE','The ' + fieldName + ' field is null so cannot be decrypted.', null);  // OLD
                ApexLogging.warning('The ' + fieldName + ' field is null so cannot be decrypted.', true); // NEW          
                return null;
            }else{
                SecurityKey__mdt keyInfo = SecurityKey__mdt.getInstance(source.toUpperCase());                     
                Blob decrypted = Crypto.decrypt('AES256', 
                                                Blob.valueOf(keyInfo.privateKey__c), 
                                                Blob.valueOf(keyInfo.initializationVector__c),
                                                EncodingUtil.base64Decode(encryptedValue)); 
                return decrypted.toString();
            }
        }catch(Exception ex){
            // The BOT will not process errors, nor render them to the Agent/Customer, 
            // so any exception will return null and the BOT will carry on processing without
            // persisting the information it was unable to decrypt. 
            // We will need to log the error or do an email alert to an admin or something here
            // Potential Errors: CMT gets changed or deleted
            //                   Encryption method is changed without altering decryption code

            LogUtil.log(source,ex,null); //OLD
            ApexLogging.error(ex.getMessage(), true); //NEW
            return null;
        }
    }
    
}