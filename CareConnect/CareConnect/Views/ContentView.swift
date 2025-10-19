//
//  ContentView.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppStateViewModel
    
    var body: some View {
        if appState.isLoggedIn {
            MainTabView()
        } else {
            AuthView()
        }
    }
}

#Preview {
    ContentView()
}
