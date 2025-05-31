public class ContactTriggerHandler {
    
    public static void handleAfterInsertOrUpdate(List<Contact> contactList) {
        Set<Id> accountIds = new Set<Id>();

        for (Contact con : contactList) {
            if (con.AccountId != null) {
                accountIds.add(con.AccountId);
            }
        }

        if (!accountIds.isEmpty()) {
            List<Account> accountsToUpdate = [SELECT Id, Rating FROM Account WHERE Id IN :accountIds];
            for (Account acc : accountsToUpdate) {
                acc.Rating = 'Cold';
            }
            update accountsToUpdate;
        }
    }
}
