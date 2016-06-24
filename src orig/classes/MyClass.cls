global class MyClass {
     @future(callout=true)
     Public static void myMethod()
     {
        AsiaOneFacade a1F = new AsiaOneFacade();
        Map<String, String> sReqVO = new Map<String, String>();
        sReqVO.put('uuu','cso1008');
        sReqVO.put('ppp','password');
        sReqVO.put('svc', 'stp');
        AsiaOneServiceRequestVO serviceRequestVO = new AsiaOneServiceRequestVO();
        serviceRequestVO.setReqValueObject(sReqVO);
        serviceRequestVO.setasia1APIFunction('apiEnableService');
        System.debug('################ before');
        a1F.delegateAsiaOneCall(serviceRequestVO);
        System.debug('################ after');
     }
}