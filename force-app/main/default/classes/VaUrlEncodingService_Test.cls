@IsTest
private class VaUrlEncodingService_Test {

    @testSetup
    private static void setup() {
        User runAsVAUser = TestPersonaFactory.getPersona(TestPersonaFactory.Persona_VA, true);
        VA_User_Mapping__c vaIds = TestDataFactory.createCustomSettingDataForVa(runAsVAUser.Id);
        Test.StartTest();
        system.runAs(runAsVAUser){
            LiveChatTranscript chat = TestDataFactory.createChatTranscriptWithEncryptedFields(); 
        }
        Test.StopTest();
    }

    private static Boolean isFlowActive(String flowApiName){
        List<FlowDefinitionView> activeflow = [SELECT ApiName,IsActive,Label,TriggerType 
                                           FROM FlowDefinitionView 
                                          WHERE ApiName = :flowApiName
                                            AND IsActive = true];
        if(!activeflow.isEmpty()){
            return true;
        }
        return false;
    }
    static testMethod void testVA_UrlEncode() {
        String token = 'TEST=';
        VaUrlEncodingService.dataInput svcInput = new VaUrlEncodingService.dataInput();
        svcInput.valueToUrlEncode = token;
        List<VaUrlEncodingService.urlEncodedValue> results = VaUrlEncodingService.getUrlEncodedValue(new List<VaUrlEncodingService.dataInput>{svcInput});
        system.assertEquals(token, EncodingUtil.urlDecode(results[0].result, 'UTF-8'));
    }

    static testMethod void testVA_UrlEncodeInFlow() {
        if(isFlowActive('VA_Pre_Chat_Context')){
            User runAsVAUser = TestPersonaFactory.getPersona(TestPersonaFactory.Persona_VA, false);
            Test.StartTest();
            system.runAs(runAsVAUser){
                LiveChatTranscript chatTranscript = [select Id, First_Name__c, Last_Name__c, Email_Address__c, Policy_Number__c, 
                                                            State__c, Application__c, Client_ID__c, URL__c, Token__c
                                                    FROM LiveChatTranscript LIMIT 1];
                Map<String, Object> inputs = new Map<String, Object>();
                inputs.put('varRoutableID', String.valueOf(chatTranscript.Id));
                Flow.Interview.VA_Pre_Chat_Context preChatFlow = new Flow.Interview.VA_Pre_Chat_Context(inputs);
                preChatFlow.start();
                system.assertEquals(EncodingUtil.urlDecode((String)preChatFlow.getVariableValue('varToken'), 'UTF-8'), chatTranscript.Token__c);
            }
        }
    }

}