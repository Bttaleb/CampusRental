//
//  KeychainService.swift
//  CampusBookingSystem
//
//  Secure storage for tokens and sensitive data
//

import Foundation
import Security

class KeychainService {
    static let shared = KeychainService()
    private init() {}
    
    // MARK: - Save Token
    func saveToken(_ token: String, key: String) {
        let data = token.data(using: .utf8)!
        saveData(data, key: key)
    }
    
    // MARK: - Get Token
    func getToken(key: String) -> String? {
        guard let data = getData(key: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    // MARK: - Delete Token
    func deleteToken(key: String) {
        deleteData(key: key)
    }
    
    // MARK: - Save Data
    func saveData(_ data: Data, key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        // Delete any existing item
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        SecItemAdd(query as CFDictionary, nil)
    }
    
    // MARK: - Get Data
    func getData(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else { return nil }
        return result as? Data
    }
    
    // MARK: - Delete Data
    func deleteData(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
    
    // MARK: - Clear All
    func clearAll() {
        let secItemClasses = [
            kSecClassGenericPassword,
            kSecClassInternetPassword,
            kSecClassCertificate,
            kSecClassKey,
            kSecClassIdentity
        ]
        
        for secItemClass in secItemClasses {
            let query: [String: Any] = [
                kSecClass as String: secItemClass
            ]
            SecItemDelete(query as CFDictionary)
        }
    }
}
