global with sharing class VaEmailValidation {

    global static FINAL String INVALID_EMAIL = 'INVALID_EMAIL_ADDRESS';
    
    global class emailInput {
        @InvocableVariable(required=true)
        public String emailToValidate;
    }

    global class emailResult {    
        @InvocableVariable
        global String email;
     
        @InvocableVariable
        global Boolean isValid;    
    }

    @InvocableMethod(label='Get email validation state' description='Return list of email results') 
    global static List<emailResult> getEmailValidationStatus( List<emailInput> emailInputs ) {
        List<VaEmailValidation.emailResult> validatedEmails = new List<VaEmailValidation.emailResult>();
        try{
            VaEmailValidation.emailInput emailInput = emailInputs[0];
            List<String> emails =  new List<String>{emailInput.emailToValidate};
            Savepoint sp = Database.setSavepoint();       
            List<Account> people = new List<Account>();
            Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();      
            // test emails for validity by creating Person Accounts, getting any errors, and rolling back.
            Integer count = 0;
            for(String email:emails){
                people.add(new Account(FirstName = 'FirstNameTest' + String.valueOf(count),
                                    LastName = 'LastNameTest' + String.valueOf(count),
                                    RecordTypeId = recordTypeId,
                                    PersonEmail = email));
                count++;
            }
            List<Database.SaveResult> srList = dmlManager.insertAsUser(people, false);
            Set<String> emailFailures = new Set<String>();
            // Check for errors
            for(Database.SaveResult sr:srList){
                if (!sr.isSuccess()) {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        if(String.valueOf(err.getStatusCode()) == INVALID_EMAIL 
                            && String.isNotBlank(err.getMessage())){
                            emailFailures.add(err.getMessage()); // Collect insert failures for invalid emails.
                        }
                    }
                }
            }
            for(String email:emails){
                VaEmailValidation.emailResult result = new VaEmailValidation.emailResult();
                result.email = email;
                if(String.isNotBlank(email) 
                && !emailFailures.isEmpty()){
                    for(String errMessage: emailFailures){
                        if(errMessage.Contains(email)){
                            // Result is not valid if any error messages contain the email passed in.
                            result.isValid = false; 
                            ApexLogging.warning('The Email passed in (' + email + ') is not valid by Salesforce logic so will be stored in the Invalid_Email_Provided__pc text field.', false);
                        }
                    }
                }else{
                    result.isValid = true; 
                    //ApexLogging.information('The Email passed in is valid by Salesforce logic: ' + email, false);
                }
                validatedEmails.add(result);
            }
            Database.rollback(sp); 
        }catch(Exception ex){
            LogUtil.log('VaEmailValidation',ex,null); // OLD 
            ApexLogging.error(true, null, ex);        // New
        }
        return validatedEmails;
    }

}