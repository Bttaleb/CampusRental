//
//  AuthState.swift
//  SoftwareEng
//
//  Created by Bassel Taleb on 2/13/26.
//

import Foundation
// MARK: OOP — Abstraction
enum AuthenticationState { // OOP: Abstraction — named cases abstract auth lifecycle into discrete states
    case authenticated
    case notAuthenticated
    case notDetermined
}
