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

import Introspect
import MailCore
import RealmSwift
import SwiftUI

struct SplitView: View {
    var mailboxManager = AccountManager.instance.currentMailboxManager!
    var selectedFolder: Folder?
    @State var splitViewController: UISplitViewController?
    @Environment(\.horizontalSizeClass) var sizeClass

    init() {
        selectedFolder = mailboxManager.getRealm().objects(Folder.self).filter("role = 'INBOX'").first
    }

    var body: some View {
        NavigationView {
            if sizeClass == .compact {
                ThreadList(mailboxManager: mailboxManager, folder: selectedFolder, isCompact: sizeClass == .compact)
            } else {
                MenuDrawerView(mailboxManager: mailboxManager, isCompact: sizeClass == .compact)

                ThreadList(mailboxManager: mailboxManager, folder: selectedFolder, isCompact: sizeClass == .compact)

                EmptyThreadView()
            }
        }
        .onRotate { orientation in
            guard let interfaceOrientation = orientation else { return }
            setupBehaviour(orientation: interfaceOrientation)
        }
        .introspectNavigationController { navController in
            guard let splitViewController = navController.splitViewController,
                  let interfaceOrientation = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.windowScene?
                  .interfaceOrientation else { return }
            self.splitViewController = splitViewController
            setupBehaviour(orientation: interfaceOrientation)
            splitViewController.preferredDisplayMode = .twoDisplaceSecondary
        }
    }

    func setupBehaviour(orientation: UIInterfaceOrientation) {
        if orientation.isLandscape {
            splitViewController?.preferredSplitBehavior = .displace
        } else if orientation.isPortrait {
            splitViewController?.preferredSplitBehavior = .overlay
        } else {
            splitViewController?.preferredSplitBehavior = .automatic
        }
    }
}