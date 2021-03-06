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

import Atlantis
import CocoaLumberjackSwift
import Foundation
import InfomaniakCore
import MailResources
import UIKit
import UserNotifications

public enum NotificationsHelper {
    public enum CategoryIdentifier {
        public static let general = "com.mail.notification.general"
    }

    private enum NotificationIdentifier {
        static let disconnected = "accountDisconnected"
    }

    public static var isNotificationEnabled: Bool {
        return UserDefaults.shared.isNotificationEnabled
    }

    public static func askForPermissions() async {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge, .provisional, .providesAppNotificationSettings]
        do {
            try await UNUserNotificationCenter.current().requestAuthorization(options: options)
        } catch {
            DDLogError("User has declined notifications")
        }
    }

    public static func sendDisconnectedNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Error"
        content.body = "Refresh token error"
        content.categoryIdentifier = CategoryIdentifier.general
        content.sound = .default
        sendImmediately(notification: content, id: NotificationIdentifier.disconnected)
    }

    private static func sendImmediately(notification: UNMutableNotificationContent, id: String,
                                        action: IKSnackBar.Action? = nil) {
        DispatchQueue.main.async {
            let isInBackground = Bundle.main.isExtension || UIApplication.shared.applicationState != .active

            if isInBackground {
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
                let request = UNNotificationRequest(identifier: id, content: notification, trigger: trigger)
                UNUserNotificationCenter.current().add(request)
            } else {
                let snackbar = IKSnackBar.make(message: notification.body, duration: .lengthLong)
                if let action = action {
                    snackbar?.setAction(action).show()
                } else {
                    snackbar?.show()
                }
            }
        }
    }
}
