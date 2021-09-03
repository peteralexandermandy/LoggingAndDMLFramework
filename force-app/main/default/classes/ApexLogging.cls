global class ApexLogging{

    global ApexLogging(){
    
    }
    
    global static void error(String message, Boolean save, SObject rec, Exception ex){
        Logger.error(message, rec, ex);
        if(save){
            Logger.saveLog();
        }
    }

    global static void error(Boolean save, SObject rec, Exception ex){
        Logger.error(ex.getMessage(), rec, ex);
        if(save){
            Logger.saveLog();
        }
    }

    global static void error(String message, Boolean save){
        Logger.error(message);
        if(save){
            Logger.saveLog();
        }
    }
    
    global static void warning(String message, Boolean save){
        Logger.warn(message);
        if(save){
            Logger.saveLog();
        }
    }

    global static void warning(String message, SObject rec, Boolean save){
        Logger.warn(message, rec);
        if(save){
            Logger.saveLog();
        }
    }

    global static void warning(String message, Id recordId, Boolean save){
        Logger.warn(message, recordId);
        if(save){
            Logger.saveLog();
        }
    }
    
    global static void information(String message, Boolean save){
        Logger.info(message);
        if(save){
            Logger.saveLog();
        }
    } 
    
    global static void information(String message, SObject rec, Boolean save){
        Logger.info(message, rec);
        if(save){
            Logger.saveLog();
        }
    }  
    
    global static void information(String message, List<Database.SaveResult> saveResults, Boolean save){
        Logger.info(message, saveResults);
        if(save){
            Logger.saveLog();
        }
    }

    global static void information(String message, Id recordId, Boolean save){
        Logger.info(message, recordId);
        if(save){
            Logger.saveLog();
        }
    }
    
    global static void debug(String message, Boolean save){
        Logger.debug(message);
        if(save){
            Logger.saveLog();
        }
    }
    
    global static void fine(String message, Boolean save){
        Logger.fine(message);
        if(save){
            Logger.saveLog();
        }
    }
    
    global static void finer(String message, Boolean save){
        Logger.finer(message);
        if(save){
            Logger.saveLog();
        }
    }
    
    global static void finest(String message, Boolean save){
        Logger.finest(message);
        if(save){
            Logger.saveLog();
        }
    }
    
    global static void Log(System.LoggingLevel level, Exception message){
        system.debug(level, message);
    }
   
}