import SwiftUI

private let relativeDateFormatter: RelativeDateTimeFormatter = {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .abbreviated
    return formatter
}()

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        if appState.isLoading && appState.weeklyUsage.isEmpty {
            // Loading state
            VStack {
                ProgressView("Loading usage data...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: 900, height: 500)
        } else if let error = appState.lastError {
            // Error state
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.largeTitle)
                    .foregroundColor(.orange)
                Text("Error loading data")
                    .font(.headline)
                Text(error)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
                    .frame(height: 40)
                
                HStack {
                    Button("Retry") {
                        appState.refresh()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Quit") {
                        NSApplication.shared.terminate(nil)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .frame(width: 400, height: 300)
            .padding()
        } else {
            // Weekly table view
            WeeklyTableView(
                weeklyData: appState.weeklyUsage,
                onQuit: {
                    NSApplication.shared.terminate(nil)
                }
            )
        }
    }
}