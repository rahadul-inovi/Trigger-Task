public class AccountTriggerHandler {

    public static void handleAfterInsert(List<Account> newAccounts) {
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : newAccounts) {
            accountIds.add(acc.Id);
        }

        Map<Id, Contact> existingContacts = new Map<Id, Contact>();
        for (Contact con : [
            SELECT Id, AccountId FROM Contact WHERE AccountId IN :accountIds
        ]) {
            existingContacts.put(con.AccountId, con);
        }

        List<Contact> contactsToInsert = new List<Contact>();
        for (Account acc : newAccounts) {
            if (!existingContacts.containsKey(acc.Id)) {
                Contact con = new Contact(
                    LastName = acc.Name,
                    AccountId = acc.Id
                );
                contactsToInsert.add(con);
            }
        }

        if (!contactsToInsert.isEmpty()) {
            insert contactsToInsert;
        }
    }

    public static void handleAfterUpdate(List<Account> newAccounts, Map<Id, Account> oldMap) {
        Set<Id> accountIdsToUpdate = new Set<Id>();

        for (Account acc : newAccounts) {
            Account oldAcc = oldMap.get(acc.Id);
            if (acc.Name != oldAcc.Name) {
                accountIdsToUpdate.add(acc.Id);
            }
        }

        if (!accountIdsToUpdate.isEmpty()) {
            Map<Id, List<Contact>> contactMap = new Map<Id, List<Contact>>();
            for (Contact con : [
                SELECT Id, LastName, AccountId FROM Contact WHERE AccountId IN :accountIdsToUpdate
            ]) {
                if (!contactMap.containsKey(con.AccountId)) {
                    contactMap.put(con.AccountId, new List<Contact>());
                }
                contactMap.get(con.AccountId).add(con);
            }

            List<Contact> contactsToUpdate = new List<Contact>();
            for (Account acc : newAccounts) {
                if (accountIdsToUpdate.contains(acc.Id) && contactMap.containsKey(acc.Id)) {
                    for (Contact con : contactMap.get(acc.Id)) {
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
}
