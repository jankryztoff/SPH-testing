/**
 * Class Name: <CustomCallbackController>
 * @authors: <KarlWilsonTan>
 * Date: <7//2014>
 * Requirement/Project Name: <SPH>
 * @description <Custom Callback for Credit Card Change used in Custom Callback Page>
 */


public with sharing class CustomCallbackController extends zqu.ZCheckoutBaseCallbackController {

  public CustomCallbackController() {
    this.hostedPageSettingName = 'Default';

  }
  
  public String refId {get; set;}
  public String objectId {get;set;}


  public override void processCallbackParameters() {
    super.processCallbackParameters();
    this.refId = callbackparameters.get('refId');
    this.objectId = callbackparameters.get('field_passthrough1');

  }


}