@IsTest
private class VaFlowPreChatContext_Test {

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

    static testMethod void testVA_Pre_Chat() {
        if(isFlowActive('VA_Pre_Chat_Context')){
            User runAsVAUser = TestPersonaFactory.getPersona(TestPersonaFactory.Persona_VA, false);
            Test.StartTest();
            system.runAs(runAsVAUser){
                LiveChatTranscript chatTranscript = [select Id, First_Name__c, Last_Name__c, Email_Address__c, Policy_Number__c, 
                                                            State__c, Application__c, Client_ID__c, URL__c 
                                                    FROM LiveChatTranscript LIMIT 1];
                Map<String, Object> inputs = new Map<String, Object>();
                inputs.put('varRoutableID', String.valueOf(chatTranscript.Id));
                Flow.Interview.VA_Pre_Chat_Context preChatFlow = new Flow.Interview.VA_Pre_Chat_Context(inputs);
                preChatFlow.start();
                // Confirm that Flow sets proper variables from Chat Transcript.
                system.assertEquals(true, preChatFlow != null, 'Flow failed to start.'); 
                system.assertEquals((String)preChatFlow.getVariableValue('varApplication'), chatTranscript.Application__c);
                system.assertEquals((String)preChatFlow.getVariableValue('varClientID'), chatTranscript.Client_ID__c);
                system.assertEquals((String)preChatFlow.getVariableValue('varEmail'), chatTranscript.Email_Address__c);
                system.assertEquals((String)preChatFlow.getVariableValue('varFirstName'), chatTranscript.First_Name__c);
                system.assertEquals((String)preChatFlow.getVariableValue('varLastName'), chatTranscript.Last_Name__c);
                system.assertEquals((String)preChatFlow.getVariableValue('varPolicyNumber'), chatTranscript.Policy_Number__c);
                system.assertEquals((String)preChatFlow.getVariableValue('varState'), chatTranscript.State__c);
                system.assertEquals((String)preChatFlow.getVariableValue('varURL'), chatTranscript.URL__c);
            }
            Test.StopTest();
        } 
    }

    static testMethod void testVA_Case_Update() {
        if(isFlowActive('VA_Case_Update')){
            User runAsCsrUser = TestPersonaFactory.getPersona(TestPersonaFactory.Persona_CSR, false);
            Id caseId;
            String intent = '';
            LiveChatTranscript chatTranscript = [select Id, First_Name__c, Last_Name__c, Email_Address__c, Policy_Number__c, 
                                                        State__c, Application__c, Client_ID__c, URL__c, CaseId 
                                                FROM LiveChatTranscript LIMIT 1];
            Test.StartTest();
            system.runAs(runAsCsrUser){
                Map<String, Object> inputs = new Map<String, Object>();
                inputs.put('varRoutableID', String.valueOf(chatTranscript.Id)); 
                inputs.put('varIntent', intent);
                Flow.Interview.VA_Case_Update vaCaseUpdateFlow = new Flow.Interview.VA_Case_Update(inputs);
                vaCaseUpdateFlow.start();
                // Confirm that Flow sets proper variables from Chat Transcript.
                system.assertEquals(true, vaCaseUpdateFlow != null, 'Flow failed to start.');      
            }
            Test.StopTest(); 
            Case c = [SELECT Id, Origin, Status, Subject, Type FROM Case WHERE Id = :chatTranscript.CaseId LIMIT 1];
            system.assertEquals(c.Origin, 'Chat'); 
            system.assertEquals(c.Status, 'New'); 
            system.assertEquals(c.Subject, 'Contact Us - Auto' + intent);  
            system.assertEquals(c.Type, 'Auto - Service');     
        }     
    }
    static testMethod void testChat_Transcript_Update_After_Save() {
        if(isFlowActive('Chat_Transcript_Update_After_Save')){
            User runAsCsrUser = TestPersonaFactory.getPersona(TestPersonaFactory.Persona_CSR, false);
            Test.StartTest();
            system.runAs(runAsCsrUser){
                LiveChatTranscript chatTranscript = [select Id, First_Name__c, Last_Name__c, Email_Address__c, Policy_Number__c, 
                                                            State__c, Application__c, Client_ID__c, URL__c, CaseId, Status, IsTesting__c
                                                    FROM LiveChatTranscript LIMIT 1];
                chatTranscript.IsTesting__c = true;
                update chatTranscript;
            }
            Test.StopTest();     
            
            LiveChatTranscript chatTranscript = [select Id, First_Name__c, Last_Name__c, Email_Address__c, Policy_Number__c, 
                                                        State__c, Application__c, Client_ID__c, URL__c, CaseId, Status, IsTesting__c
                                                    FROM LiveChatTranscript LIMIT 1];
            system.assertEquals(chatTranscript.IsTesting__c, true);   
            
            // Check Case exists, PersonAccount exists, and all are set on LiveChatTranscript.
            LiveChatTranscript chatTranscriptPostFlow = [select Id, First_Name__c, Last_Name__c, Email_Address__c, Policy_Number__c, 
                                                                State__c, Application__c, Client_ID__c, URL__c, CaseId, Status,
                                                                AccountId, ContactId
                                                        FROM LiveChatTranscript LIMIT 1];

            //Check error log
            List<ApplicationErrorLog__c> errorLogs = [SELECT Id FROM ApplicationErrorLog__c];
            system.assertEquals(errorLogs.isEmpty(), true);                
            // Check Chat Transcript Lookups
            system.assertEquals(String.isNotBlank(chatTranscriptPostFlow.AccountId), true);
            system.assertEquals(String.isNotBlank(chatTranscriptPostFlow.ContactId), true);
            system.assertEquals(String.isNotBlank(chatTranscriptPostFlow.CaseId), true);
        }
    }

    static testMethod void testChat_Transcript_Update_After_Save_CaseOwner_To_CSR_When_InProgress() {
        if(isFlowActive('Chat_Transcript_Update_After_Save')){
            User runAsCSRUser = TestPersonaFactory.getPersona(TestPersonaFactory.Persona_CSR, true);
            Test.StartTest();
            system.runAs(runAsCSRUser){
                LiveChatTranscript chatTranscript = [select Id, First_Name__c, Last_Name__c, Email_Address__c, Policy_Number__c, 
                                                            State__c, Application__c, Client_ID__c, URL__c, CaseId, Status, IsTesting__c
                                                    FROM LiveChatTranscript LIMIT 1];
                
                // Update Case to CSR User which is what happens
                chatTranscript.IsTesting__c = true;
                chatTranscript.OwnerId = runAsCSRUser.Id;
                chatTranscript.Status = 'InProgress';
                update chatTranscript;
            }
            Test.StopTest();     
            
            LiveChatTranscript chatTranscriptPostFlow = [select Id, First_Name__c, Last_Name__c, Email_Address__c, Policy_Number__c, 
                                                        State__c, Application__c, Client_ID__c, URL__c, CaseId, Status, IsTesting__c, 
                                                        OwnerId, Case.OwnerId, AccountId, ContactId
                                                    FROM LiveChatTranscript LIMIT 1];
            system.assertEquals(chatTranscriptPostFlow.IsTesting__c, true);   
            //Check error log
            List<ApplicationErrorLog__c> errorLogs = [SELECT Id FROM ApplicationErrorLog__c];
            system.assertEquals(errorLogs.isEmpty(), true);                
            // Check Case Owned by CSR
            system.assertEquals(chatTranscriptPostFlow.Case.OwnerId, runAsCSRUser.Id);
        }
    }

    static testMethod void testChat_Transcript_Update_After_Save_VA_Completed() {
        if(isFlowActive('Chat_Transcript_Update_After_Save')){
            User runAsVAUser = TestPersonaFactory.getPersona(TestPersonaFactory.Persona_VA, true);
            Test.StartTest();
            system.runAs(runAsVAUser){
                LiveChatTranscript chatTranscript = [select Id, First_Name__c, Last_Name__c, Email_Address__c, Policy_Number__c, 
                                                            State__c, Application__c, Client_ID__c, URL__c, CaseId, Status, IsTesting__c
                                                    FROM LiveChatTranscript LIMIT 1];
                chatTranscript.IsTesting__c = true;
                chatTranscript.Status = 'Completed';
                update chatTranscript;
            }
            Test.StopTest();     
            
            LiveChatTranscript chatTranscript = [select Id, First_Name__c, Last_Name__c, Email_Address__c, Policy_Number__c, 
                                                        State__c, Application__c, Client_ID__c, URL__c, CaseId, Status, IsTesting__c
                                                    FROM LiveChatTranscript LIMIT 1];
            system.assertEquals(chatTranscript.IsTesting__c, true);   
            
            // Check Case exists, PersonAccount exists, and all are set on LiveChatTranscript.
            LiveChatTranscript chatTranscriptPostFlow = [select Id, First_Name__c, Last_Name__c, Email_Address__c, Policy_Number__c, 
                                                                State__c, Application__c, Client_ID__c, URL__c, CaseId, Status, OwnerId, Case.OwnerId,
                                                                AccountId, ContactId
                                                        FROM LiveChatTranscript LIMIT 1];

            //Check error log
            List<ApplicationErrorLog__c> errorLogs = [SELECT Id FROM ApplicationErrorLog__c];
            system.assertEquals(errorLogs.isEmpty(), true);                
            // Check Chat Transcript and Case Owned by CSR
            VA_User_Mapping__c vaIds = VA_User_Mapping__c.getOrgDefaults();    
            system.assertEquals(chatTranscriptPostFlow.Case.OwnerId, vaIds.VA_User_ID__c);
            system.assertEquals(chatTranscriptPostFlow.OwnerId, vaIds.VA_User_ID__c);
        }
    }

    static testMethod void testChat_Transcript_Update_After_Save_InvalidEmail() {
        if(isFlowActive('Chat_Transcript_Update_After_Save')){
            User runAsCsrUser = TestPersonaFactory.getPersona(TestPersonaFactory.Persona_CSR, false);
            Test.StartTest();
            system.runAs(runAsCsrUser){

                LiveChatTranscript chatTranscript = [select Id, First_Name__c, Last_Name__c, Email_Address__c, Policy_Number__c, 
                                                            State__c, Application__c, Client_ID__c, URL__c, CaseId, Status, IsTesting__c
                                                    FROM LiveChatTranscript LIMIT 1];
                chatTranscript.IsTesting__c = true;
                chatTranscript.Email_Address__c = 'test@test@test.com';
                update chatTranscript;
            }
            Test.StopTest();     
            
            LiveChatTranscript chatTranscript = [select Id, First_Name__c, Last_Name__c, Email_Address__c, Policy_Number__c, 
                                                        State__c, Application__c, Client_ID__c, URL__c, CaseId, Status, IsTesting__c
                                                    FROM LiveChatTranscript LIMIT 1];
            system.assertEquals(chatTranscript.IsTesting__c, true);   
            
            LiveChatTranscript chatTranscriptPostFlow = [select Id, First_Name__c, Last_Name__c, Email_Address__c, Policy_Number__c, 
                                                                State__c, Application__c, Client_ID__c, URL__c, CaseId, Status,
                                                                AccountId, ContactId, Contact.Invalid_Email_Provided__c, Contact.Email
                                                        FROM LiveChatTranscript LIMIT 1];

            //Check error log
            List<ApplicationErrorLog__c> errorLogs = [SELECT Id FROM ApplicationErrorLog__c];
            system.assertEquals(errorLogs.isEmpty(), true);                
            // Check Contact Email is NULL and Contact Invalid Email has a value
            system.assertEquals(String.isNotBlank(chatTranscriptPostFlow.Contact.Invalid_Email_Provided__c), true);
            system.assertEquals(String.isBlank(chatTranscriptPostFlow.Contact.Email), true);    
        }     
    }

    static testMethod void testValidateUserQueueProfile() {
        // Need to be certain that the following exist so that the Custom Setting can be created:
        //  Profile: 'Virtual Assistant Minimum Access Profile'    
        //  Profile: 'CSR'  
        //  User: 'Automated Process'
        //  Queue = 'Chat - Virtual Assistant TEST' (Cannot test for Queue in Org unless you use SeeAllData = true so would need a new class -- this test only looks for the one we create so not as meaningful.)
        List<Profile> vaProfile = [SELECT Id FROM Profile WHERE Name = 'Virtual Assistant Minimum Access Profile'];
        List<Profile> csrProfile = [SELECT Id FROM Profile WHERE Name = 'CSR'];
        List<User> automatedProcessUser = [SELECT Id FROM User WHERE Name = 'Automated Process'];
        List<Group> vaQueue = [SELECT Id FROM Group WHERE Name = 'Chat - Virtual Assistant TEST' AND Type = 'Queue'];
        system.assertEquals(vaProfile.isEmpty(), false);     
        system.assertEquals(csrProfile.isEmpty(), false);     
        system.assertEquals(automatedProcessUser.isEmpty(), false);     
        system.assertEquals(vaQueue.isEmpty(), false);
    }

}