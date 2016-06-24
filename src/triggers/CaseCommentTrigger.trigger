/**
 * Class Name: <CaseCommentTrigger>
 * @author: <Karl Tan>
 * Date: <12/18/2014>
 * Requirement/Project Name: <SPH>
 * @description<Trigger for Case Comment>
 */

trigger CaseCommentTrigger on CaseComment (after delete, after insert, after update, before delete, before insert, before update) {
    TriggerFactory.createHandler(CaseCommentTriggerHandler.class);
}