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
import SwiftUI

struct SettingsToggleCell: View {
    let title: String
    let userDefaults: UserDefaults.Keys

    @AppStorage private var value: Bool

    init(title: String, userDefaults: UserDefaults.Keys) {
        self.title = title
        self.userDefaults = userDefaults
        _value = AppStorage(wrappedValue: false, userDefaults.rawValue, store: .shared)
    }

    var body: some View {
        Toggle(isOn: $value) {
            Text(title)
                .textStyle(.body)
        }
        .onTapGesture {
            if userDefaults == .appLock {
                Task {
                    do {
                        if try await !AppLockHelper.shared.evaluatePolicy(reason: "Coucou") {
                            value.toggle()
                        }
                    } catch {
                        value.toggle()
                    }
                }
            }
        }
        .tint(.accentColor)
    }
}

struct SettingsToggleCell_Previews: PreviewProvider {
   static var previews: some View {
       SettingsToggleCell(title: "Code lock", userDefaults: .appLock)
   }
}
