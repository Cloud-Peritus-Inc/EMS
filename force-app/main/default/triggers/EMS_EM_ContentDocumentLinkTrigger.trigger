trigger EMS_EM_ContentDocumentLinkTrigger on ContentDocumentLink (after insert) {
    if (trigger.isafter && trigger.isinsert)
    {
        ContentDocumentLinkTriggerHandler.createDriveFile(trigger.new);  
    }
}