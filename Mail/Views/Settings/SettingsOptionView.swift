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
import SwiftUI

struct SettingsOptionView<OptionEnum>: View where OptionEnum: CaseIterable, OptionEnum: Equatable, OptionEnum: RawRepresentable,
    OptionEnum: SettingsOptionEnum, OptionEnum.AllCases: RandomAccessCollection, OptionEnum.RawValue: Hashable {
    let title: String
    let keyPath: ReferenceWritableKeyPath<UserDefaults, OptionEnum>

    private let values = OptionEnum.allCases

    @State private var selectedValue: OptionEnum {
        didSet {
            UserDefaults.shared[keyPath: keyPath] = selectedValue
        }
    }

    init(title: String, keyPath: ReferenceWritableKeyPath<UserDefaults, OptionEnum>) {
        self.title = title
        self.keyPath = keyPath
        _selectedValue = State(wrappedValue: UserDefaults.shared[keyPath: keyPath])
    }

    var body: some View {
        List(values, id: \.rawValue) { value in
            Button {
                selectedValue = value
            } label: {
                HStack {
                    Text(value.title)
                    Spacer()
                    if value == selectedValue {
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
        .navigationBarTitle(title)
    }
}

// struct SettingsOptionView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsOptionView<<#OptionEnum: SettingsOptionEnum & CaseIterable & Equatable & RawRepresentable#>>()
//    }
// }
