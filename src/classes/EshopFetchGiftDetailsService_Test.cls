/**
   @Author Joy Suarez
   @name EshopFetchGiftDetailsService_Test
   @CreateDate 02/05/2015
   @Description EshopFetchGiftDetailsService
   @Version <1.0>
   @reference <Referenced program names>
  */


@isTest(SeeAllData=true)
private class EshopFetchGiftDetailsService_Test{

    /**
    *  To test EshopFetchGiftDetailsService
    *  @name testGet
    *  @param none
    *  @return none
    *  @throws na
    */ 
   static testMethod void testGet() {
       System.debug('Entered test method');
       EshopFetchGiftDetailsService.FetchGiftDetailsServiceRequest  req = new EshopFetchGiftDetailsService.FetchGiftDetailsServiceRequest ();
       req.setpromotionId('MAG12PROMO');
       List<String> temp = new List<String>();
       temp.add('PSS');
       temp.add('NAS');
       temp.add('TTG');
       req.setgiftId(temp);
       req.setcontractDuraction('12');
       EshopFetchGiftDetailsService.FetchGiftDetailsServiceResponse resp = new EshopFetchGiftDetailsService.FetchGiftDetailsServiceResponse(null,null);
       EshopFetchGiftDetailsService.GiftDetails efgds = new EshopFetchGiftDetailsService.GiftDetails('PROMO006','12','G0003','lala',200);
       resp = EshopFetchGiftDetailsService.fetchGiftDetails(req);
       System.debug('Response is '+resp);  
    }
    
    /**
    *  To test EshopFetchGiftDetailsService
    *  @name testGet2
    *  @param none
    *  @return none
    *  @throws na
    */ 
    static testMethod void testGet2() {
       System.debug('Entered test method');
       EshopFetchGiftDetailsService.FetchGiftDetailsServiceRequest  req = new EshopFetchGiftDetailsService.FetchGiftDetailsServiceRequest ();
       req.setpromotionId('PROMO006');
       List<String> temp2 = new List<String>();
       temp2.add('G00003');
       temp2.add('G00001');
       req.setgiftId(temp2);
       req.setcontractDuraction('12');
       String Booom = req.getpromotionId();
       Booom = req.getcontractDuraction();
       List<String> BooomStr = req.getgiftId();
       EshopFetchGiftDetailsService.FetchGiftDetailsServiceResponse resp = new EshopFetchGiftDetailsService.FetchGiftDetailsServiceResponse(null,null);
       resp = EshopFetchGiftDetailsService.fetchGiftDetails(req);
       System.debug('Response is '+resp);  
    }
    
    /**
    *  To test EshopFetchGiftDetailsService
    *  @name testGet3
    *  @param none
    *  @return none
    *  @throws na
    */ 
    static testMethod void testGet3() {
       System.debug('Entered test method');
       EshopFetchGiftDetailsService.FetchGiftDetailsServiceRequest  req = new EshopFetchGiftDetailsService.FetchGiftDetailsServiceRequest ();
       req.setpromotionId(null);
       List<String> temp3 = new List<String>();
       temp3.add(null);
       temp3.add(null);
       temp3.add(null);
       req.setgiftId(temp3);
       req.setcontractDuraction('12');
       EshopFetchGiftDetailsService.FetchGiftDetailsServiceResponse resp = new EshopFetchGiftDetailsService.FetchGiftDetailsServiceResponse(null,null);
       resp = EshopFetchGiftDetailsService.fetchGiftDetails(req);
       System.debug('Response is '+resp);  
    }
    
    /**
    *  To test EshopFetchGiftDetailsService
    *  @name testGet4
    *  @param none
    *  @return none
    *  @throws na
    */ 
     static testMethod void testGet4() {
       System.debug('Entered test method');
       EshopFetchGiftDetailsService.FetchGiftDetailsServiceRequest  req = new EshopFetchGiftDetailsService.FetchGiftDetailsServiceRequest ();
       EshopFetchGiftDetailsService.FetchGiftDetailsServiceResponse resp = new EshopFetchGiftDetailsService.FetchGiftDetailsServiceResponse(null,null);
    }
}