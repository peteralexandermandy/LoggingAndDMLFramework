@IsTest 
/**
 * Test Class for Virtual Assistant skills mapping
 **/ 
private class VaSkillIds_Test {
   
    static testMethod void testSkillsSetUp() {
        User vaUser = TestPersonaFactory.getPersona(TestPersonaFactory.Persona_VA, false);
        system.runAs(vaUser){
            List<Skill> allSkills = [SELECT Id, MasterLabel FROM Skill];
            system.assertEquals(allSkills.size() > 0, true, 'You must set up Skills for the implementation.');
        }
    }

    static testMethod void testSkillsAllValid() {
        User vaUser = TestPersonaFactory.getPersona(TestPersonaFactory.Persona_VA, false);
        system.runAs(vaUser){
            List<Skill> allSkills = [SELECT Id, MasterLabel FROM Skill];
            vaSkillIds.skillsInput skillInput = new vaSkillIds.skillsInput();
            // vaSkillIds.getSkillIds Class Takes up to 4 Skills currently.
            for(integer i=0; i<4; i++){
               if(allSkills.size() >= i+1){
                    if(i==0){skillInput.skill1 = allSkills[i].MasterLabel;}
                    if(i==1){skillInput.skill2 = allSkills[i].MasterLabel;}
                    if(i==2){skillInput.skill3 = allSkills[i].MasterLabel;}
                    if(i==3){skillInput.skill4 = allSkills[i].MasterLabel;}
               }
            }
            List<List<Id>> skillIds = vaSkillIds.getSkillsIds(new List<vaSkillIds.skillsInput>{skillInput});
            system.assertEquals(skillIds[0].size(), (allSkills.size() >= 4 ? 4 : allSkills.size()), 'We could not find all of the skills you requested.');
        }    
    }

    static testMethod void testSkillsSomeNotValid() {
        User vaUser = TestPersonaFactory.getPersona(TestPersonaFactory.Persona_VA, false);
        system.runAs(vaUser){
            List<Skill> allSkills = [SELECT Id, MasterLabel FROM Skill];
            system.assertEquals(allSkills.size() > 0, true, 'You must set up Skills for the implementation.');
            vaSkillIds.skillsInput skillInput = new vaSkillIds.skillsInput();
            Integer skillCount = 0;
            for(integer i=0; i<4; i++){
               if(allSkills.size() >= i+1){
                    if(i==0){skillInput.skill1 = allSkills[i].MasterLabel;}
                    if(i==1){skillInput.skill2 = allSkills[i].MasterLabel;}
                    if(i==2){skillInput.skill3 = allSkills[i].MasterLabel;}
                    if(i==3){skillInput.skill4 = allSkills[i].MasterLabel;}
                    skillCount++;
               }
            }
            //Set Invalid Skill:
            skillInput.skill3 = 'False Test Skill';
            skillCount++;
            List<List<Id>> skillIds = vaSkillIds.getSkillsIds(new List<vaSkillIds.skillsInput>{skillInput});
            system.assertNotEquals(skillCount, skillIds[0].size());
        }    
    }

}