public inherited sharing class DMLManager {
  
   public static List<Database.SaveResult> insertAsUser(List<SObject> objList, Boolean logTransaction){
        List<Database.SaveResult> saveResults;   
        try{
            saveResults = database.insert(objList, false);
            if(logTransaction) ApexLogging.information('Insert DML SaveResult', saveResults, true);
            for(Database.SaveResult sr:saveResults){
                if(!sr.isSuccess()){
                    for(Database.Error error : sr.getErrors()){
                        if(logTransaction) ApexLogging.error(getErrorString(error), true);
                    }
                }else{
                    if(logTransaction) ApexLogging.information('Successfully inserted ' + getsObjectTypeFromId(sr.getId()) + ' record', sr.getId(), true);
                }
            }
        }catch(Exception ex){
            ApexLogging.error(false, null, ex);
        }
        return saveResults;
    }

	public static List<Database.SaveResult> updateAsUser(List<SObject> objList, Boolean logTransaction){
        List<Database.SaveResult> saveResults;   
        try{
            saveResults = database.update(objList, false);
            if(logTransaction) ApexLogging.information('Updating Records...', saveResults, true);
            for(Database.SaveResult sr:saveResults){
                if(!sr.isSuccess()){
                    for(Database.Error error : sr.getErrors()){
                        if(logTransaction) ApexLogging.error(getErrorString(error), true);
                    }
                }else{
                    if(logTransaction) ApexLogging.information('Successfully updated ' + getsObjectTypeFromId(sr.getId()) + ' record', sr.getId(), true);
                }
            }
        }catch(Exception ex){
            ApexLogging.error(true, null, ex);
        }
        return saveResults;
    }

    public static List<Database.UpsertResult> upsertAsUser(List<SObject> objList, Schema.SObjectField externalIdField, Boolean logTransaction){
        List<Database.UpsertResult> upsertResults;
        try{
            upsertResults = database.upsert(objList, externalIdField, true);
            for(Database.UpsertResult ur:upsertResults){
                if(!ur.isSuccess()){
                    for(Database.Error error : ur.getErrors()){
                        if(logTransaction)  ApexLogging.error(getErrorString(error), true);
                    }
                }else{
                    if(logTransaction) ApexLogging.information('Successfully updated ' + getsObjectTypeFromId(ur.getId()) + ' record', ur.getId(), true);
                }
            }
        }catch(Exception ex){
            ApexLogging.error(true, null, ex);
        }
        return upsertResults;
    }

    private static String getErrorString(Database.Error err){
        String errorMsg = 'The following error has occurred.';
        errorMsg += err.getStatusCode() + ': ' + err.getMessage();
        errorMsg += 'Fields that affected this error: ' + err.getFields();
        return errorMsg;
    }

    private static Schema.SObjectType getsObjectTypeFromId(Id recordId){
        Schema.SObjectType sObjectType;
        if(String.IsNotBlank((String)recordId)){
            sObjectType = recordId.getsObjectType();
        }
        return sObjectType;
    }

}