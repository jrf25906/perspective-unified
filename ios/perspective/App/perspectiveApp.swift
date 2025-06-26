//
//  perspectiveApp.swift
//  perspective
//
//  Created by James Farmer on 6/4/25.
//

import SwiftUI

@main
struct perspectiveApp: App {
    @StateObject private var apiService = APIService.shared
    @StateObject private var appStateManager = AppStateManager.shared
    @StateObject private var networkMonitor = NetworkMonitor.shared
    @StateObject private var offlineDataManager = OfflineDataManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(apiService)
                .environmentObject(appStateManager)
                .environmentObject(networkMonitor)
                .environmentObject(offlineDataManager)
        }
    }
}
