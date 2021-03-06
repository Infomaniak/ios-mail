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
import MailResources
import SwiftUI

struct EmptyListView: View {
    @AppStorage(UserDefaults.shared.key(.accentColor)) var accentColor = AccentColor.pink

    var body: some View {
        VStack {
            Image(resource: accentColor.zeroMailImage)
                .padding(24)
            Text(MailResourcesStrings.Localizable.noEmailTitle)
                .textStyle(.header2)
                .padding(.bottom, 4)
            Text(MailResourcesStrings.Localizable.noEmailDescription)
                .textStyle(.bodySecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(48)
        .background(MailResourcesAsset.backgroundColor.swiftUiColor)
    }
}

struct EmptyListView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyListView()
    }
}
