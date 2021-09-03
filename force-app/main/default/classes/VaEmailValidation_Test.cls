@isTest
private class VaEmailValidation_Test {
    
    static testMethod void testVA_EmailValidationValidEmail() {
        User runAsCSRUser = TestPersonaFactory.getPersona(TestPersonaFactory.Persona_CSR, false);
        Test.StartTest();
        system.runAs(runAsCSRUser){
            VaEmailValidation.emailInput input = new VaEmailValidation.emailInput();
            input.emailToValidate = 'test@test@test.com';
            List<VaEmailValidation.emailResult> result = VaEmailValidation.getEmailValidationStatus(new List<VaEmailValidation.emailInput>{input});
            system.assertEquals(result[0].isValid, false);
        }
    } 
    
    static testMethod void testVA_EmailValidationInvalidEmail() {
        User runAsCSRUser = TestPersonaFactory.getPersona(TestPersonaFactory.Persona_CSR, false);
        Test.StartTest();
        system.runAs(runAsCSRUser){
            VaEmailValidation.emailInput input = new VaEmailValidation.emailInput();
            input.emailToValidate = 'test@test.com';
            List<VaEmailValidation.emailResult> result = VaEmailValidation.getEmailValidationStatus(new List<VaEmailValidation.emailInput>{input});
            system.assertEquals(result[0].isValid, true);
        }
    }

}