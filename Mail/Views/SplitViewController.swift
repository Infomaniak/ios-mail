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

import MailCore
import UIKit

class SplitViewController: UISplitViewController {
    // MARK: - Public methods

    convenience init() {
        self.init(style: .tripleColumn)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSplitViews()
    }

    // MARK: - Private

    private func setupSplitViews() {
        preferredSplitBehavior = .tile
        preferredDisplayMode = .twoBesideSecondary
        showsSecondaryOnlyButton = true

        let menuDrawerViewController = MenuDrawerViewController()
        setViewController(menuDrawerViewController, for: .primary)

        let messageListViewController = MessageListViewController(mailboxManager: AccountManager.instance.currentMailboxManager!)
        let pepNav = UINavigationController(rootViewController: messageListViewController)
        setViewController(pepNav, for: .supplementary)
        setViewController(pepNav, for: .compact)

        let threadViewController = ThreadViewController()
        setViewController(threadViewController, for: .secondary)
    }
}
