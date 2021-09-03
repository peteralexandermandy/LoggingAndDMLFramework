/**
 * Flow wrapper for determining skills for
 * transfer to Agent based on supplied Intent and other context
 **/ 
global with sharing class VaSkillIds {

    global class skillsInput {
        @InvocableVariable(required=true)
        public String skill1;
        
        @InvocableVariable(required=false)
        public String skill2;
        
        @InvocableVariable(required=false)
        public String skill3;
        
        @InvocableVariable(required=false)
        public String skill4;
    }

    @InvocableMethod(label='Get Skills Ids' description='Return Ids of Skills') 
    global static List<List<Id>> getSkillsIds( List<skillsInput> skillsInputs ) {
        List<Id> skillsIds = new List<Id> ();
        try{
            String inputSkill1         = skillsInputs[0].skill1;
            String inputSkill2         = skillsInputs[0].skill2;
            String inputSkill3         = skillsInputs[0].skill3;
            String inputSkill4         = skillsInputs[0].skill4;
        
            //Get Skill IDs
            Map<String, Id> mapSkills = new Map<String, Id>();
            
            for(Skill currentSkill : [SELECT Id, MasterLabel FROM Skill]) {
                mapSkills.put(currentSkill.MasterLabel, currentSkill.Id);
            }

            if( inputSkill1 != null && mapSkills.ContainsKey( inputSkill1 ) ){        
                skillsIds.add(mapSkills.get( inputSkill1 ) );
            }

            if( inputSkill2 != null && mapSkills.ContainsKey( inputSkill2 ) ){        
                skillsIds.add(mapSkills.get( inputSkill2 ) );
            }
            
            if( inputSkill3 != null && mapSkills.ContainsKey( inputSkill3 ) ){        
                skillsIds.add(mapSkills.get( inputSkill3 ) );
            }
            
            if( inputSkill4 != null && mapSkills.ContainsKey( inputSkill4 ) ){        
                skillsIds.add(mapSkills.get( inputSkill4 ) );
            }
        }catch(Exception ex){
            LogUtil.log('VaSkillIds',ex,null);
            ApexLogging.error(ex.getMessage(), true);          
        }        
        return new List<List<Id>> {skillsIds};        
    }
    
}