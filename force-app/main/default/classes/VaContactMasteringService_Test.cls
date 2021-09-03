@IsTest
private class VaContactMasteringService_Test {  
    /*
    TestCase1 - EDGE Flow gracefully handles brand new customer contact
    TestCase2 - EDGE Flow gracefully handles existing customer contact and reuses this record
    TestCase3 - Static Flow gracefully handles brand new customer contact
    TestCase4 - Static Flow gracefully handles existing customer contact and reuses this record
    TestCase5 - EDGE Flow mastering a new customer (with a clientId) that previously visited through Static (without a ClientId) will not match.
    */
    @testSetup
    private static void setup() {
        User runAsCSRUser = TestPersonaFactory.getPersona(TestPersonaFactory.Persona_CSR, false);
        Test.StartTest();
        system.runAs(runAsCSRUser){
            List<Account> customers = new List<Account>();
            // EDGE Existing Contact (Has ClientId)
            customers.add(TestDataFactory.createPersonAccount(TestDataFactory.edgeApp, false)); 
            // STATIC Existing Contact (Has NULL ClientId)
            customers.add(TestDataFactory.createPersonAccount(TestDataFactory.staticApp, false)); 
            insert customers;
            List<LiveChatTranscript> chats = new List<LiveChatTranscript>();
            chats.add(TestDataFactory.createChatTranscriptWithEncryptedFields(TestDataFactory.edgeApp, false)); 
            chats.add(TestDataFactory.createChatTranscriptWithEncryptedFields(TestDataFactory.staticApp, false));
            chats.add(TestDataFactory.createChatTranscriptWithEncryptedFields(false, false));
            chats.add(TestDataFactory.createChatTranscriptWithEncryptedFields(true, false));
            insert chats;
        }
        Test.StopTest();
    }

    static testMethod void testApexOnly_ContactMastering_NewCustomerEDGE() {
        User runAsCSRUser = TestPersonaFactory.getPersona(TestPersonaFactory.Persona_CSR, false);
        Test.StartTest();
        system.runAs(runAsCSRUser){
            Map<Id, Account> existingCustomerMap = new Map<Id, Account>([SELECT Id FROM Account]);
            Account edgeCustomer = [SELECT Id, LastName, FirstName, PersonEmail, ClientID__pc FROM Account WHERE PersonEmail = :TestDataFactory.edgeEmailAddress LIMIT 1];
            List<VaContactMasteringService.personInput> contactInputs = new List<VaContactMasteringService.personInput>();
            VaContactMasteringService.personInput p = new VaContactMasteringService.personInput();
            String newEmail = 'NewEdgeEmail@test.com';
            p.lastName = 'NewCustomerlast';
            p.firstName = 'NewCustomerFirst';
            p.emailAddress = newEmail;
            p.clientId = 'NewEdgeClientId';
            contactInputs.add(p);
            List<VaContactMasteringService.contactInformation> info =  VaContactMasteringService.getContact(contactInputs);
            Account newPerson = [SELECT Id FROM Account WHERE PersonEmail = :newEmail LIMIT 1];
            system.assertEquals(existingCustomerMap.ContainsKey(newPerson.Id), false);
        }
        Test.stopTest();
    }

    static testMethod void testApexOnly_ContactMastering_ExistingCustomerEDGE() {
        User runAsCSRUser = TestPersonaFactory.getPersona(TestPersonaFactory.Persona_CSR, false);
        Test.StartTest();
        system.runAs(runAsCSRUser){
            Map<Id, Account> existingCustomerMap = new Map<Id, Account>([SELECT Id FROM Account]);
            Account edgeCustomer = [SELECT Id, LastName, FirstName, PersonEmail, ClientID__pc FROM Account WHERE PersonEmail = :TestDataFactory.edgeEmailAddress LIMIT 1];
            List<VaContactMasteringService.personInput> contactInputs = new List<VaContactMasteringService.personInput>();
            VaContactMasteringService.personInput p = new VaContactMasteringService.personInput();
            String newEmail = edgeCustomer.PersonEmail;
            p.lastName = edgeCustomer.LastName;
            p.firstName = edgeCustomer.FirstName;
            p.emailAddress = newEmail;
            p.clientId = edgeCustomer.ClientID__pc;
            contactInputs.add(p);
            List<VaContactMasteringService.contactInformation> info =  VaContactMasteringService.getContact(contactInputs);
            Account newPerson = [SELECT Id FROM Account WHERE PersonEmail = :newEmail LIMIT 1];
            system.assertEquals(existingCustomerMap.ContainsKey(newPerson.Id), true);
        }
        Test.stopTest();
    }

    static testMethod void testApexOnly_ContactMastering_NewCustomerStatic() {
        User runAsCSRUser = TestPersonaFactory.getPersona(TestPersonaFactory.Persona_CSR, false);
        Test.StartTest();
        system.runAs(runAsCSRUser){
            Map<Id, Account> existingCustomerMap = new Map<Id, Account>([SELECT Id FROM Account]);
            Account staticCustomer = [SELECT Id, LastName, FirstName, PersonEmail, ClientID__pc FROM Account WHERE PersonEmail = :TestDataFactory.staticEmailAddress LIMIT 1];
            List<VaContactMasteringService.personInput> contactInputs = new List<VaContactMasteringService.personInput>();
            VaContactMasteringService.personInput p = new VaContactMasteringService.personInput();
            String newEmail = 'NewStaticEmail@test.com';
            p.lastName = 'NewCustomerlast';
            p.firstName = 'NewCustomerFirst';
            p.emailAddress = newEmail;
            contactInputs.add(p);
            List<VaContactMasteringService.contactInformation> info =  VaContactMasteringService.getContact(contactInputs);
            Account newPerson = [SELECT Id FROM Account WHERE PersonEmail = :newEmail LIMIT 1];
            system.assertEquals(existingCustomerMap.ContainsKey(newPerson.Id), false);
        }
        Test.stopTest();
    }

    static testMethod void testApexOnly_ContactMastering_ExistingCustomerStatic() {
        User runAsCSRUser = TestPersonaFactory.getPersona(TestPersonaFactory.Persona_CSR, false);
        Test.StartTest();
        system.runAs(runAsCSRUser){
            Map<Id, Account> existingCustomerMap = new Map<Id, Account>([SELECT Id FROM Account]);
            Account staticCustomer = [SELECT Id, LastName, FirstName, PersonEmail, ClientID__pc FROM Account WHERE PersonEmail = :TestDataFactory.edgeEmailAddress LIMIT 1];
            List<VaContactMasteringService.personInput> contactInputs = new List<VaContactMasteringService.personInput>();
            VaContactMasteringService.personInput p = new VaContactMasteringService.personInput();
            String newEmail = staticCustomer.PersonEmail;
            p.lastName = staticCustomer.LastName;
            p.firstName = staticCustomer.FirstName;
            p.emailAddress = newEmail;
            contactInputs.add(p);
            List<VaContactMasteringService.contactInformation> info =  VaContactMasteringService.getContact(contactInputs);
            Account newPerson = [SELECT Id FROM Account WHERE PersonEmail = :newEmail LIMIT 1];
            system.assertEquals(existingCustomerMap.ContainsKey(newPerson.Id), true);
        }
        Test.stopTest();
    }

    static testMethod void testApexOnly_ContactMastering_InitialVisitStaticThenEdge() {
        User runAsCSRUser = TestPersonaFactory.getPersona(TestPersonaFactory.Persona_CSR, false);
        Test.StartTest();
        system.runAs(runAsCSRUser){
            Map<Id, Account> existingCustomerMap = new Map<Id, Account>([SELECT Id FROM Account]);
            Account staticCustomer = [SELECT Id, LastName, FirstName, PersonEmail, ClientID__pc FROM Account WHERE PersonEmail = :TestDataFactory.staticEmailAddress LIMIT 1];
            List<VaContactMasteringService.personInput> contactInputs = new List<VaContactMasteringService.personInput>();
            VaContactMasteringService.personInput p = new VaContactMasteringService.personInput();
            String newEmail = 'NewStaticEmail@test.com';
            String firstName = 'NewCustomerFirst';
            String lastName = 'NewCustomerLast';            
            p.lastName = lastName;
            p.firstName = firstName;
            p.emailAddress = newEmail;
            contactInputs.add(p);
            List<VaContactMasteringService.contactInformation> info =  VaContactMasteringService.getContact(contactInputs);
            // Create another this time with client id
            contactInputs = new List<VaContactMasteringService.personInput>();
            p = new VaContactMasteringService.personInput();
            p.lastName = lastName;
            p.firstName = firstName;
            p.clientId = 'NewClientId';
            p.emailAddress = 'differentemail@test.com';
            contactInputs.add(p);
            info =  VaContactMasteringService.getContact(contactInputs);
            Map<Id, Account> totalCustomerMap = new Map<Id, Account>([SELECT Id FROM Account]);
            system.assertEquals(totalCustomerMap.size() - existingCustomerMap.size() == 2, true);
        }
        Test.stopTest();
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

    static testMethod void testVA_NewCustomerEDGE() {
        if(isFlowActive('Chat_Transcript_Update_After_Save')){
            User runAsCSRUser = TestPersonaFactory.getPersona(TestPersonaFactory.Persona_CSR, false);
            Map<Id, Account> existingCustomerMap = new Map<Id, Account>([SELECT Id FROM Account]);
            Set<String> existingEmails = new Set<String>{TestDataFactory.edgeEmailAddress, TestDataFactory.staticEmailAddress};
            LiveChatTranscript chatTranscriptPreFlow = [select Id, First_Name__c, Last_Name__c, Email_Address__c, Policy_Number__c, 
                                                            State__c, Application__c, Client_ID__c, URL__c, CaseId, Status, IsTesting__c
                                                        FROM LiveChatTranscript 
                                                        WHERE Email_Address__c NOT IN :existingEmails
                                                        AND Client_ID__c != null
                                                        LIMIT 1];
            Test.StartTest();
            system.runAs(runAsCSRUser){
                // Grab Chat record for New Customer
                // Runs Flow
                chatTranscriptPreFlow.IsTesting__c = true;            
                update chatTranscriptPreFlow;
            }
            Test.StopTest();   
            // Assertions to check that customer got created
            LiveChatTranscript chatTranscriptPostFlow = [select Id, AccountId
                                                    FROM LiveChatTranscript 
                                                    WHERE Id = :chatTranscriptPreFlow.Id
                                                    LIMIT 1];
            system.assertEquals(String.isNotBlank(chatTranscriptPostFlow.AccountId), true);                             
            system.assertEquals(existingCustomerMap.ContainsKey(chatTranscriptPostFlow.AccountId), false);
        }    
    } 

    static testMethod void testVA_ExistingCustomerEDGE() {
        if(isFlowActive('Chat_Transcript_Update_After_Save')){
            User runAsCSRUser = TestPersonaFactory.getPersona(TestPersonaFactory.Persona_CSR, false);
            LiveChatTranscript chatTranscriptPreFlow = [select Id, First_Name__c, Last_Name__c, Email_Address__c, Policy_Number__c, 
                                                            State__c, Application__c, Client_ID__c, URL__c, CaseId, Status, IsTesting__c
                                                        FROM LiveChatTranscript 
                                                        WHERE Email_Address__c = :TestDataFactory.edgeEmailAddress
                                                        LIMIT 1];
            Test.StartTest();
            system.runAs(runAsCSRUser){            
                chatTranscriptPreFlow.IsTesting__c = true;            
                update chatTranscriptPreFlow;
            }
            Account existingEdgeCustomer = [SELECT Id FROM Account WHERE PersonEmail = :TestDataFactory.edgeEmailAddress LIMIT 1];
            // Assertions to check that customer associated to chat is the same as the existing one
            LiveChatTranscript chatTranscriptPostFlow = [select Id, AccountId
                                                    FROM LiveChatTranscript 
                                                    WHERE Id = :chatTranscriptPreFlow.Id
                                                    LIMIT 1];
            system.assertEquals(chatTranscriptPostFlow.AccountId, existingEdgeCustomer.Id);
        }
    }
    
    static testMethod void testVA_NewCustomerSTATIC() {
        if(isFlowActive('Chat_Transcript_Update_After_Save')){
            User runAsCSRUser = TestPersonaFactory.getPersona(TestPersonaFactory.Persona_CSR, false);
            Map<Id, Account> existingCustomerMap = new Map<Id, Account>([SELECT Id FROM Account]);
            Set<String> existingEmails = new Set<String>{TestDataFactory.edgeEmailAddress, TestDataFactory.staticEmailAddress};
            LiveChatTranscript chatTranscriptPreFlow = [select Id, First_Name__c, Last_Name__c, Email_Address__c, Policy_Number__c, 
                                                            State__c, Application__c, Client_ID__c, URL__c, CaseId, Status, IsTesting__c
                                                        FROM LiveChatTranscript 
                                                        WHERE Email_Address__c NOT IN :existingEmails
                                                            AND Client_ID__c = null
                                                        LIMIT 1];
            Test.StartTest();
            system.runAs(runAsCSRUser){             
                chatTranscriptPreFlow.IsTesting__c = true;            
                update chatTranscriptPreFlow;   
            }
            Test.stopTest();
            // Assertions to check that customer got created
            LiveChatTranscript chatTranscriptPostFlow = [select Id, AccountId
                                                    FROM LiveChatTranscript 
                                                    WHERE Id = :chatTranscriptPreFlow.Id
                                                    LIMIT 1];
            system.assertEquals(String.isNotBlank(chatTranscriptPostFlow.AccountId), true);                             
            system.assertEquals(existingCustomerMap.ContainsKey(chatTranscriptPostFlow.AccountId), false);  
        } 
    } 

    static testMethod void testVA_ExistingCustomerSTATIC() {
        if(isFlowActive('Chat_Transcript_Update_After_Save')){
            User runAsCSRUser = TestPersonaFactory.getPersona(TestPersonaFactory.Persona_CSR, false);
            LiveChatTranscript chatTranscriptPreFlow = [select Id, First_Name__c, Last_Name__c, Email_Address__c, Policy_Number__c, 
                                                            State__c, Application__c, Client_ID__c, URL__c, CaseId, Status, IsTesting__c
                                                        FROM LiveChatTranscript 
                                                    WHERE Email_Address__c = :TestDataFactory.staticEmailAddress
                                                    LIMIT 1];
            Test.StartTest();
            system.runAs(runAsCSRUser){            
                chatTranscriptPreFlow.IsTesting__c = true;            
                update chatTranscriptPreFlow;
            }
            Test.stopTest();
            Account existingStaticCustomer = [SELECT Id FROM Account WHERE PersonEmail = :TestDataFactory.staticEmailAddress LIMIT 1];
            // Assertions to check that customer associated to chat is the same as the existing one
            LiveChatTranscript chatTranscriptPostFlow = [select Id, AccountId
                                                    FROM LiveChatTranscript 
                                                    WHERE Id = :chatTranscriptPreFlow.Id
                                                    LIMIT 1];
            system.assertEquals(chatTranscriptPostFlow.AccountId, existingStaticCustomer.Id);
        }
    } 

    static testMethod void testVA_ExistingCustomerInitialVisitOnStaticNowChatsFromEDGE() {
        if(isFlowActive('Chat_Transcript_Update_After_Save')){
            User runAsCSRUser = TestPersonaFactory.getPersona(TestPersonaFactory.Persona_CSR, false);
            Set<String> existingEmails = new Set<String>{TestDataFactory.edgeEmailAddress, TestDataFactory.staticEmailAddress};
            LiveChatTranscript chatTranscriptPreFlow = [select Id, First_Name__c, Last_Name__c, Email_Address__c, Policy_Number__c, 
                                                                State__c, Application__c, Client_ID__c, URL__c, CaseId, Status, IsTesting__c
                                                        FROM LiveChatTranscript 
                                                        WHERE Email_Address__c NOT IN :existingEmails
                                                        AND Client_ID__c = null
                                                        LIMIT 1];
            String newEdgeClientId = 'NEWEDGECLIENTID';                                                    
            Test.StartTest();
            system.runAs(runAsCSRUser){
                
                // static is first visit.  run flow.  creates contact.  
                chatTranscriptPreFlow.IsTesting__c = true;            
                update chatTranscriptPreFlow;
                // query contact and create LiveChatTranscript for EDGE, run flow again.
                LiveChatTranscript chatTranscriptPostFlow = [select Id, AccountId, Account.LastName, Account.FirstName, Account.PersonEmail, Account.ClientID__pc
                                                                FROM LiveChatTranscript 
                                                            WHERE Id = :chatTranscriptPreFlow.Id
                                                            LIMIT 1];
                LiveChatVisitor visitor = TestDataFactory.createChatVisitor();
                LiveChatTranscript newEdgeChat = new LiveChatTranscript(LiveChatVisitorId = visitor.Id,
                                                                        First_Name__c = chatTranscriptPostFlow.Account.LastName, 
                                                                        Last_Name__c = chatTranscriptPostFlow.Account.FirstName, 
                                                                        Email_Address__c = chatTranscriptPostFlow.Account.PersonEmail,
                                                                        Client_ID__c = newEdgeClientId,
                                                                        Policy_Number__c = '123',
                                                                        State__c = 'MA',
                                                                        Application__c = 'EDGE',
                                                                        URL__c = 'https://testurl.testclasses.com/',
                                                                        Language__c = 'en_US');
                insert newEdgeChat;
                newEdgeChat.IsTesting__c = true;            
                update newEdgeChat;
           
            }
            Test.stopTest();
            // Assert that a contact was created for Static and that a second contact was created for edge. 
            Id staticAccountId = [SELECT Id, AccountId FROM LiveChatTranscript WHERE Id = :chatTranscriptPreFlow.Id].AccountId;
            Id edgeAccountId = [SELECT Id FROM Account WHERE ClientID__pc = :newEdgeClientId].Id;
            system.assertNotEquals(staticAccountId, edgeAccountId);
        }
    } 

}