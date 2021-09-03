/**
 * Flow wrapper for creating or returning a Contact/PersonAccount for
 * information passed in from Chat.
 **/ 
global with sharing class VaContactMasteringService {

    public virtual class BaseException extends Exception {}
    public class AccountCreationException extends BaseException {}
     
    global class personInput {
        @InvocableVariable(required=true)
        public String lastName;
        
        @InvocableVariable(required=false)
        public String firstName;
        
        @InvocableVariable(required=false)
        public String emailAddress;
        
        @InvocableVariable(required=false)
        public String clientId;
    }

    global class contactInformation {    
        @InvocableVariable
        global Id contactId;
     
        @InvocableVariable
        global Id accountId;    
    }

    @InvocableMethod(label='Create or Get Contact' description='Return Contact and PersonAccount') 
    global static List<contactInformation> getContact( List<personInput> contactInputs ) {
        List<VaContactMasteringService.contactInformation> contactInfo = new List<VaContactMasteringService.contactInformation>();
        Account person; 
        try{
            
            String lastName = contactInputs[0].lastName;
            String firstName = contactInputs[0].firstName;
            String emailAddress = contactInputs[0].emailAddress;
            String invalidEmailAddress = null;
            String clientId = contactInputs[0].clientId;        
            // EMAIL CHECK
            if(String.isNotBlank(emailAddress)){
                VaEmailValidation.emailInput validationInput = new VaEmailValidation.emailInput();
                validationInput.emailToValidate = emailAddress;
                //= emailAddress;
                List<VaEmailValidation.emailResult> result = VaEmailValidation.getEmailValidationStatus(new List<VaEmailValidation.emailInput>{validationInput});
                if(!result[0].isValid){
                    invalidEmailAddress = emailAddress;
                    emailAddress = null;
                }
            }
            // Create Person Account
            Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();      
            person = new Account(FirstName = firstName,
                                 LastName = lastName,
                                 RecordTypeId = recordTypeId,
                                 PersonEmail = emailAddress,
                                 Invalid_Email_Provided__pc = invalidEmailAddress,
                                 ClientID__pc = clientId);
            //Database.SaveResult sr = database.insert(person, false);
            List<Database.SaveResult> saveResults = dmlManager.insertAsUser(new List<Account>{person}, false);
            for(Database.SaveResult sr:saveResults){
                if(!sr.isSuccess()){
                    // Check Dupe Rules
                    for(Database.Error error : sr.getErrors()){
                        if(error instanceof Database.DuplicateError){
                            Database.DuplicateError duplicateError = (Database.DuplicateError)error;
                            Datacloud.DuplicateResult duplicateResult = duplicateError.getDuplicateResult();
                            for(Datacloud.MatchResult match:duplicateResult.getMatchResults()){
                                for(Datacloud.MatchRecord record:match.getMatchRecords()){
                                    person = (Account)record.getRecord();
                                    ApexLogging.information('Contact/Person Account already exists.  Using detected duplicate.', person, false);
                                    break;
                                }
                            }
                        }else{
                            String errorMsg = 'The following error has occurred.';
                            errorMsg += error.getStatusCode() + ': ' + error.getMessage();
                            errorMsg += 'Fields that affected this error: ' + error.getFields();
                            throw new AccountCreationException(UserInfo.getUserName() + ' cannot create the Person Account and Contact because of: ' + errorMsg);
                        }
                    }
                }
                // Set return Ids
                VaContactMasteringService.contactInformation ids = new VaContactMasteringService.contactInformation();
                ids.accountId = person.Id;
                ids.contactId = [SELECT Id FROM Contact WHERE AccountId = :person.Id LIMIT 1].Id;
                contactInfo.add(ids);
            }           
        }catch(Exception ex){
            LogUtil.log('VaContactMasteringService',ex,null);     // Old
            ApexLogging.error(true, person, ex); // New
        }        
        return contactInfo;        
    }
}