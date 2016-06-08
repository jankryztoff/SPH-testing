global class ErrorResponseWrapper {
    private String svc_status;
    private String error_code;
    private String error_message;
    
    public ErrorResponseWrapper (String svc_status, String error_code, String error_message){
        this.svc_status = svc_status;
        this.error_code = error_code;
        this.error_message = error_message;
    }
        
}