trigger AccountTrigger on Account (before insert) {
AccountHandler.updateAccountNumber(Trigger.New);
}