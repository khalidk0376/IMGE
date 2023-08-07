/**
 * Class to handle custom exceptions.
 */

public with sharing class InformaExceptions {

    public abstract class InformaCommonException extends Exception {
        public final Integer statusCode {get; set;}
        public final String status {get; set;}
        public final String errorMessage {get; set;}

        public InformaCommonException(Integer statusCode, String status) {
            this.statusCode = statusCode;
            this.status = status;
        }

        public InformaCommonException(Integer statusCode, String status, String errorMessage) {
            this.statusCode = statusCode;
            this.status = status;
            this.errorMessage = errorMessage;
        }

        public Boolean hasErrorMessage() {
            if(errorMessage == null) {
                return false;
            } else {
                return true;
            }
        }

        override public String getMessage() {
            String errMsg =  this.statusCode + ' ' + status + ' ';
            if(errorMessage != null) {
                errMsg += errorMessage;
            }
            return errMsg;
        }
    }

    /**
     * Exception class for http type of exceptions.
     */
    public class InformaHttpException extends InformaExceptions.InformaCommonException {

        public InformaHttpException(Integer statusCode, String status) {
            super(statusCode, status);
        }

        public InformaHttpException(Integer statusCode, String status, String errorMessage) {
            super(statusCode, status, errorMessage);
        }
    }

    /**
     * Exception class for detecting invalid inputs.
     */
    public class InformaInvalidInputException extends InformaExceptions.InformaCommonException {

        public InformaInvalidInputException(Integer statusCode, String status) {
            super(statusCode, status);
        }

        public InformaInvalidInputException(Integer statusCode, String status, String errorMessage) {
            super(statusCode, status, errorMessage);
        }
    }

    /**
     * Exception class for detecting invalid configuration parameters.
     */
    public class InformaInvalidCustomSettingsException extends InformaExceptions.InformaCommonException {

        public InformaInvalidCustomSettingsException(Integer statusCode, String status) {
            super(statusCode, status);
        }

        public InformaInvalidCustomSettingsException(Integer statusCode, String status, String errorMessage) {
            super(statusCode, status, errorMessage);
        }
    }

    public class InformaValueDoesNotExistException extends InformaExceptions.InformaCommonException{

        public InformaValueDoesNotExistException(Integer statusCode, String status){
            super(statusCode, status);
        }

        public InformaValueDoesNotExistException(Integer statusCode, String status, String errorMessage){
            super(statusCode, status, errorMessage);
        }
    }

}