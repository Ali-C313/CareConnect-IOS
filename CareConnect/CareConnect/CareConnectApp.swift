//
//  CareConnectApp.swift
//  CareConnect
//
//  Created by Ali Chehab on 07.10.25.
//

import SwiftUI
import Firebase

@main
struct CareConnectApp: App {
    
    init() {
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()
      }
    
    var body: some Scene {
        WindowGroup {
            
        }
    }
}
