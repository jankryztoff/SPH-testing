//Generated by wsdl2apex

public class wwwSphComArWsSchemaCamSearchaccouR {
    public class AccType {
        public String CusN;
        public String AccN;
        public String AccTyp;
        public String AccCreDte;
        public String CrTrm;
        public String CrTrmRef;
        public String CrLmtInt;
        public String CrLmtExt;
        public String DbtExp;
        public String DbtStrt;
        public String CusGrAccN;
        public String CusGrBnkN;
        public String BizSctr;
        public String CoyCd;
        public String SOASup;
        public String TrnI;
        private String[] CusN_type_info = new String[]{'CusN','http://www.sph.com/ar/ws/schema/cam/searchAccountResponse',null,'0','1','false'};
        private String[] AccN_type_info = new String[]{'AccN','http://www.sph.com/ar/ws/schema/cam/searchAccountResponse',null,'0','1','false'};
        private String[] AccTyp_type_info = new String[]{'AccTyp','http://www.sph.com/ar/ws/schema/cam/searchAccountResponse',null,'0','1','false'};
        private String[] AccCreDte_type_info = new String[]{'AccCreDte','http://www.sph.com/ar/ws/schema/cam/searchAccountResponse',null,'0','1','false'};
        private String[] CrTrm_type_info = new String[]{'CrTrm','http://www.sph.com/ar/ws/schema/cam/searchAccountResponse',null,'0','1','false'};
        private String[] CrTrmRef_type_info = new String[]{'CrTrmRef','http://www.sph.com/ar/ws/schema/cam/searchAccountResponse',null,'0','1','false'};
        private String[] CrLmtInt_type_info = new String[]{'CrLmtInt','http://www.sph.com/ar/ws/schema/cam/searchAccountResponse',null,'0','1','false'};
        private String[] CrLmtExt_type_info = new String[]{'CrLmtExt','http://www.sph.com/ar/ws/schema/cam/searchAccountResponse',null,'0','1','false'};
        private String[] DbtExp_type_info = new String[]{'DbtExp','http://www.sph.com/ar/ws/schema/cam/searchAccountResponse',null,'0','1','false'};
        private String[] DbtStrt_type_info = new String[]{'DbtStrt','http://www.sph.com/ar/ws/schema/cam/searchAccountResponse',null,'0','1','false'};
        private String[] CusGrAccN_type_info = new String[]{'CusGrAccN','http://www.sph.com/ar/ws/schema/cam/searchAccountResponse',null,'0','1','false'};
        private String[] CusGrBnkN_type_info = new String[]{'CusGrBnkN','http://www.sph.com/ar/ws/schema/cam/searchAccountResponse',null,'0','1','false'};
        private String[] BizSctr_type_info = new String[]{'BizSctr','http://www.sph.com/ar/ws/schema/cam/searchAccountResponse',null,'0','1','false'};
        private String[] CoyCd_type_info = new String[]{'CoyCd','http://www.sph.com/ar/ws/schema/cam/searchAccountResponse',null,'1','1','false'};
        private String[] SOASup_type_info = new String[]{'SOASup','http://www.sph.com/ar/ws/schema/cam/searchAccountResponse',null,'0','1','false'};
        private String[] TrnI_type_info = new String[]{'TrnI','http://www.sph.com/ar/ws/schema/cam/searchAccountResponse',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.sph.com/ar/ws/schema/cam/searchAccountResponse','true','false'};
        private String[] field_order_type_info = new String[]{'CusN','AccN','AccTyp','AccCreDte','CrTrm','CrTrmRef','CrLmtInt','CrLmtExt','DbtExp','DbtStrt','CusGrAccN','CusGrBnkN','BizSctr','CoyCd','SOASup','TrnI'};
    }
    public class L_AccType {
        public wwwSphComArWsSchemaCamSearchaccouR.AccType[] Acc;
        private String[] Acc_type_info = new String[]{'Acc','http://www.sph.com/ar/ws/schema/cam/searchAccountResponse',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.sph.com/ar/ws/schema/cam/searchAccountResponse','true','false'};
        private String[] field_order_type_info = new String[]{'Acc'};
    }
    public class AccSrchResp_element {
        public String SysId;
        public String RtnSts;
        public String RtnMsg;
        public String NRec;
        public wwwSphComArWsSchemaCamSearchaccouR.L_AccType L_Acc;
        private String[] SysId_type_info = new String[]{'SysId','http://www.sph.com/ar/ws/schema/cam/searchAccountResponse',null,'1','1','false'};
        private String[] RtnSts_type_info = new String[]{'RtnSts','http://www.sph.com/ar/ws/schema/cam/searchAccountResponse',null,'1','1','false'};
        private String[] RtnMsg_type_info = new String[]{'RtnMsg','http://www.sph.com/ar/ws/schema/cam/searchAccountResponse',null,'0','1','false'};
        private String[] NRec_type_info = new String[]{'NRec','http://www.sph.com/ar/ws/schema/cam/searchAccountResponse',null,'1','1','false'};
        private String[] L_Acc_type_info = new String[]{'L_Acc','http://www.sph.com/ar/ws/schema/cam/searchAccountResponse',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.sph.com/ar/ws/schema/cam/searchAccountResponse','true','false'};
        private String[] field_order_type_info = new String[]{'SysId','RtnSts','RtnMsg','NRec','L_Acc'};
    }
}