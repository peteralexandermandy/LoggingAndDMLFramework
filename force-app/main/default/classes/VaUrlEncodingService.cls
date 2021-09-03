/**
 * Flow wrapper for URL Encoding the TOKEN for
 * a value passed in from the Flow.
 **/ 
global with sharing class  VaUrlEncodingService {

    global class dataInput {
        @InvocableVariable(required=true)
        public String valueToUrlEncode;
    }

    global class urlEncodedValue {    
        @InvocableVariable
        global string result;    
    }

    @InvocableMethod(label='URL Encode a String' description='Return the URL Encoded String value') 
    global static List<urlEncodedValue> getUrlEncodedValue( List<dataInput> inputValues ) {
        List<VaUrlEncodingService.urlEncodedValue> urlEncodedResults = new List<VaUrlEncodingService.urlEncodedValue>();
        try{            
            VaUrlEncodingService.urlEncodedValue urlEncodedResult = new VaUrlEncodingService.urlEncodedValue();
            urlEncodedResult.result = EncodingUtil.urlEncode(inputValues[0].valueToUrlEncode, 'UTF-8');
            urlEncodedResults.add(urlEncodedResult);
            ApexLogging.information('The URL has been properly encoded.', false);
        }catch(Exception ex){
            LogUtil.log('VaUrlEncodingService',ex,null); // OLD
            ApexLogging.error(ex.getMessage(), true);    // NEW      
        }        
        return urlEncodedResults;        
    }
}