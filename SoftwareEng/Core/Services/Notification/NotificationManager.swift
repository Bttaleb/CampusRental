//
//  NotificationManager.swift
//  CampusBookingSystem
//
//  Epic 5: Notifications
//  Manages local and push notifications
//

import Foundation
import UserNotifications
import Combine
import UIKit

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var hasPermission = false
    @Published var notifications: [AppNotification] = []
    @Published var unreadCount = 0
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private init() {
        checkPermissionStatus()
    }
    
    // MARK: - Permission
    
    func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.hasPermission = granted
            }
        }
    }
    
    func checkPermissionStatus() {
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.hasPermission = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - Schedule Local Notification
    
    func scheduleBookingReminder(title: String, body: String, date: Date, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = NSNumber(value: unreadCount + 1)
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    // MARK: - Cancel Notification
    
    func cancelNotification(identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    // MARK: - Fetch Notifications
    
    func fetchNotifications() async {
        // In a real app, this would fetch from the backend
        // For now, using placeholder data
    }
    
    // MARK: - Mark as Read
    
    func markAsRead(notificationId: String) {
        if let index = notifications.firstIndex(where: { $0.id == notificationId }) {
            notifications[index].isRead = true
            updateUnreadCount()
        }
    }
    
    func markAllAsRead() {
        notifications.indices.forEach { notifications[$0].isRead = true }
        updateUnreadCount()
    }
    
    // MARK: - Update Unread Count
    
    private func updateUnreadCount() {
        unreadCount = notifications.filter { !$0.isRead }.count
        notificationCenter.setBadgeCount(unreadCount)
    }
}
