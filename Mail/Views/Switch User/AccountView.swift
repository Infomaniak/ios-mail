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
import SwiftUI

struct AccountView: View {
    @Binding var isPresented: Bool

    @Environment(\.window) private var window

    @State private var avatarImage = Image(resource: MailResourcesAsset.placeholderAvatar)
    @State private var account = AccountManager.instance.currentAccount!

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                avatarImage
                    .resizable()
                    .frame(width: 110, height: 110)
                    .clipShape(Circle())

                VStack(spacing: 8) {
                    Text(account.user.email)
                        .textStyle(.header2)

                    NavigationLink {
                        AccountListView()
                    } label: {
                        Text(MailResourcesStrings.Localizable.buttonAccountSwitch)
                            .textStyle(.button)
                    }
                }

                // Email list button
                Button {
                    // TODO: Show email list
                } label: {
                    VStack(alignment: .leading, spacing: 24) {
                        IKDivider()
                            .padding(.horizontal, 8)
                        HStack {
                            Text(MailResourcesStrings.Localizable.buttonAccountAssociatedEmailAddresses)
                                .textStyle(.body)
                                .multilineTextAlignment(.leading)
                            Spacer()
                            ChevronIcon(style: .right)
                        }
                        .padding(.horizontal, 24)
                        IKDivider()
                            .padding(.horizontal, 8)
                    }
                }

                // TODO: Device list
                Spacer()

                // Buttons
                LargeButton(title: MailResourcesStrings.Localizable.buttonAccountDisconnect, action: logout)
                Button {
                    // TODO: Delete account
                } label: {
                    Text(MailResourcesStrings.Localizable.buttonAccountDelete)
                        .textStyle(.button)
                }
            }
            .navigationBarTitle(MailResourcesStrings.Localizable.titleMyAccount, displayMode: .inline)
            .backButtonDisplayMode(.minimal)
            .navigationBarItems(leading: Button {
                isPresented = false
            } label: {
                Image(systemName: "xmark")
            })
            .padding(.vertical, 42)
            .appShadow(withPadding: true)
        }
        .navigationBarAppStyle()
        .task {
            avatarImage = await account.user.getAvatar()
        }
    }

    private func logout() {
        AccountManager.instance.removeTokenAndAccount(token: account.token)
        if let nextAccount = AccountManager.instance.accounts.first {
            (window?.windowScene?.delegate as? SceneDelegate)?.switchAccount(nextAccount)
        } else {
            (window?.windowScene?.delegate as? SceneDelegate)?.showLoginView()
        }
        AccountManager.instance.saveAccounts()
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView(isPresented: .constant(true))
    }
}
