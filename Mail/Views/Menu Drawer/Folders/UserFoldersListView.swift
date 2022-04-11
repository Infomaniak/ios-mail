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

import InfomaniakCore
import MailCore
import MailResources
import RealmSwift
import UIKit
import SwiftUI

struct UserFoldersListView: View {
    // swiftlint:disable empty_count
    @ObservedResults(Folder.self, where: { $0.parentLink.count == 0 && $0.role == nil }) var folders

    @EnvironmentObject var accountManager: AccountManager

    @State private var unfoldFolders = false

    @Binding var selectedFolderId: String?

    weak var splitViewController: UISplitViewController?

    private let foldersSortDescriptors = [
        SortDescriptor(keyPath: \Folder.isFavorite, ascending: false),
        SortDescriptor(keyPath: \Folder.unreadCount, ascending: false),
        SortDescriptor(keyPath: \Folder.name)
    ]

    init(mailboxManager: MailboxManager, splitViewController: UISplitViewController?, selectedFolderId: Binding<String?>) {
        _folders = .init(Folder.self, configuration: AccountManager.instance.currentMailboxManager!.realmConfiguration) { $0.parentLink.count == 0 && $0.role == nil }
        self.splitViewController = splitViewController
        _selectedFolderId = selectedFolderId
    }

    var body: some View {
        DisclosureGroup(isExpanded: $unfoldFolders) {
            VStack {
                ForEach(AnyRealmCollection(folders.sorted(by: foldersSortDescriptors))) { folder in
                    FolderCellView(folder: folder,
                                   selectedFolderId: $selectedFolderId,
                                   icon: folder.isFavorite ? MailResourcesAsset.folderStar : MailResourcesAsset.folder,
                                   withSmallIcon: true,
                                   splitViewController: splitViewController)
                }
                .accentColor(Color(InfomaniakCoreAsset.infomaniakColor.color))
            }
            .padding(.top, 9)
        } label: {
            Text("Dossiers")
                .padding(.trailing, 7)

            Button(action: addNewFolder) {
                Image(uiImage: MailResourcesAsset.addFolder.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16)
            }
        }
        .accentColor(Color(MailResourcesAsset.primaryTextColor.color))
        .onAppear {
            Task {
                await fetchFolders()
                MatomoUtils.track(view: ["MenuDrawer"])
            }
        }
        .onChange(of: accountManager.currentMailboxId) { _ in
            Task {
                await fetchFolders()
            }
        }
    }

    // MARK: - Private functions

    private func fetchFolders() async {
        guard let mailboxManager = accountManager.currentMailboxManager else { return }
        do {
            try await mailboxManager.folders()
        } catch {
            print("Error while getting folders: \(error.localizedDescription)")
        }
    }

    private func updateSplitView(with folder: Folder) {
        guard let mailboxManager = accountManager.currentMailboxManager else { return }
        let messageListVC = ThreadListViewController(mailboxManager: mailboxManager, folder: folder)
        splitViewController?.setViewController(messageListVC, for: .supplementary)
    }

    private func addNewFolder() {
        // add new folder
    }
}