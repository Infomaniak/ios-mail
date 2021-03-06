/*
 Infomaniak Mail - iOS App
 Copyright (C) 2022 Infomaniak Network SA

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import CocoaLumberjackSwift
import Contacts
import Foundation
import InfomaniakCore
import RealmSwift

public class ContactManager: ObservableObject {
    public class ContactManagerConstants {
        private let fileManager = FileManager.default
        public let rootDocumentsURL: URL
        public let groupDirectoryURL: URL

        init() {
            groupDirectoryURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: AccountManager.appGroup)!
            rootDocumentsURL = groupDirectoryURL.appendingPathComponent("contacts", isDirectory: true)

            try? FileManager.default.createDirectory(
                atPath: rootDocumentsURL.path,
                withIntermediateDirectories: true,
                attributes: nil
            )

            DDLogInfo(
                "App contacts working path is: \(fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.absoluteString ?? "")"
            )
            DDLogInfo("Group container path is: \(groupDirectoryURL.absoluteString)")
        }
    }

    public static let constants = ContactManagerConstants()

    public var realmConfiguration: Realm.Configuration
    public var user: InfomaniakCore.UserProfile
    public private(set) var apiFetcher: MailApiFetcher

    public init(user: InfomaniakCore.UserProfile, apiFetcher: MailApiFetcher) {
        self.user = user
        self.apiFetcher = apiFetcher
        let realmName = "\(user.id).realm"
        realmConfiguration = Realm.Configuration(
            fileURL: ContactManager.constants.rootDocumentsURL.appendingPathComponent(realmName),
            schemaVersion: 1,
            deleteRealmIfMigrationNeeded: true,
            objectTypes: [
                Contact.self,
                AddressBook.self
            ]
        )
    }

    public func getRealm() -> Realm {
        do {
            return try Realm(configuration: realmConfiguration)
        } catch {
            // We can't recover from this error but at least we report it correctly on Sentry
            Logging.reportRealmOpeningError(error, realmConfiguration: realmConfiguration)
        }
    }

    private let localContactsHelper = LocalContactsHelper()

    public var mergedContacts = [String: MergedContact]()

    public func fetchContactsAndAddressBooks() async throws {
        do {
            let addressBooks = try await apiFetcher.addressBooks().addressbooks
            let contacts = try await apiFetcher.contacts()

            let realm = getRealm()

            try? realm.safeWrite {
                realm.add(addressBooks, update: .modified)
                realm.add(contacts, update: .modified)
            }

            await mergeContacts()
        } catch {
            await mergeContacts()

            throw error
        }
    }

    public func mergeContacts() async {
        var mergeableContacts = [String: (local: CNContact?, remote: Contact?)]()

        // Add local contacts
        await localContactsHelper.enumerateContacts { localContact, _ in
            for email in localContact.emailAddresses {
                let email = email.value as String
                mergeableContacts[email] = (local: localContact, remote: mergeableContacts[email]?.remote)
            }
        }

        // Add remote contacts
        let realm = getRealm()
        let contacts = realm.objects(Contact.self)
        for remoteContact in contacts {
            for email in remoteContact.emails {
                mergeableContacts[email] = (local: mergeableContacts[email]?.local, remote: remoteContact)
            }
        }

        // Merge
        var tmpMergedContacts = [String: MergedContact]()
        mergeableContacts.forEach { key, value in
            tmpMergedContacts[key] = MergedContact(email: key, remote: value.remote?.freeze(), local: value.local)
        }
        mergedContacts = tmpMergedContacts
    }

    public func getRemoteContact(with identifier: String) -> Contact? {
        let realm = getRealm()
        return realm.object(ofType: Contact.self, forPrimaryKey: identifier)
    }

    public func getLocalContact(with identifier: String) async -> CNContact? {
        return try? await localContactsHelper.getContact(with: identifier)
    }

    public func getContact(for email: String) -> MergedContact? {
        return mergedContacts[email]
    }

    public func addressBook(with id: Int) -> AddressBook? {
        let realm = getRealm()
        return realm.object(ofType: AddressBook.self, forPrimaryKey: id)
    }

    public func contacts(matching string: String) -> [MergedContact] {
        return mergedContacts.values.filter { $0.name.localizedCaseInsensitiveContains(string) || $0.email.localizedCaseInsensitiveContains(string) }
    }

    public func addContact(recipient: Recipient) async throws {
        guard let addressBook = getMainAddressBook() else { throw MailError.addressBookNotFound }

        let contactId = try await apiFetcher.addContact(recipient, to: addressBook)
        let contacts = try await apiFetcher.contacts()

        guard let newContact = contacts.first(where: { $0.id == String(contactId) }) else { throw MailError.contactNotFound }
        let realm = getRealm()
        try? realm.safeWrite {
            realm.add(newContact)
        }
        if let mergedContact = mergedContacts[recipient.email] {
            mergedContact.remote = newContact.freeze()
        } else {
            mergedContacts[recipient.email] = MergedContact(email: recipient.email, remote: newContact.freeze(), local: nil)
        }
    }

    public func getMainAddressBook() -> AddressBook? {
        let realm = getRealm()
        return realm.objects(AddressBook.self).where { $0.isPrincipal == true }.first
    }
}
