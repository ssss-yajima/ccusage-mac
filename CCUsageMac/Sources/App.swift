import SwiftUI

@main
struct CCUsageMacApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .environmentObject(appState)
        } label: {
            MenuBarView()
                .environmentObject(appState)
        }
        .menuBarExtraStyle(.window)
    }
}

class AppState: ObservableObject {
    @Published var todaysCost: String = "$0.00"
    @Published var todaysUsage: UsageData?
    @Published var weeklyUsage: [UsageData] = []
    @Published var isLoading: Bool = false
    @Published var lastError: String?
    @Published var lastUpdate: Date?
    
    private var timer: Timer?
    private let usageLoader = UsageDataLoader()
    
    init() {
        startAutoUpdate()
    }
    
    func startAutoUpdate() {
        loadUsageData()
        
        // Update every 1 minute
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            self.loadUsageData()
        }
    }
    
    func loadUsageData() {
        Task { @MainActor in
            isLoading = true
            lastError = nil
            
            do {
                // Load both today's and weekly data
                let usage = try await usageLoader.loadTodaysUsage()
                let weekly = try await usageLoader.loadWeeklyUsage()
                
                self.todaysUsage = usage
                self.weeklyUsage = weekly
                self.todaysCost = formatCost(usage.totalCost)
                self.lastUpdate = Date()
            } catch {
                self.lastError = error.localizedDescription
                self.todaysCost = "$--"
            }
            
            isLoading = false
        }
    }
    
    func refresh() {
        loadUsageData()
    }
    
    private func formatCost(_ cost: Double) -> String {
        String(format: "$%.2f", cost)
    }
    
    deinit {
        timer?.invalidate()
    }
}