public class AccountTriggerHandler {
    
    public static void handleAfterInsert(List<Account> newAccounts) {
        List<Contact> contactsToInsert = new List<Contact>();
        for (Account acc : newAccounts) {
            Contact con = new Contact(
                LastName = acc.Name,
                AccountId = acc.Id
            );
            contactsToInsert.add(con);
        }
        if (!contactsToInsert.isEmpty()) {
            insert contactsToInsert;
        }
    }

    public static void handleAfterUpdate(List<Account> newAccounts, Map<Id, Account> oldMap) {
        List<Contact> contactsToUpdate = new List<Contact>();

        for (Account acc : newAccounts) {
            Account oldAcc = oldMap.get(acc.Id);
            if (acc.Name != oldAcc.Name) {
                // Find child contacts
                List<Contact> childContacts = [SELECT Id, LastName FROM Contact WHERE AccountId = :acc.Id];
                for (Contact con : childContacts) {
                    con.LastName = acc.Name;
                    contactsToUpdate.add(con);
                }
            }
        }

        if (!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }
    }
}
