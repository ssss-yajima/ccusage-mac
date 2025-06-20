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
            VStack(spacing: 16) {
                Spacer()
                
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 48))
                    .foregroundColor(.orange)
                    .symbolRenderingMode(.hierarchical)
                
                VStack(spacing: 8) {
                    Text("Error loading data")
                        .font(.headline)
                    
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 300)
                }
                
                HStack(spacing: 12) {
                    Button("Retry") {
                        appState.refresh()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    
                    Button("Quit") {
                        NSApplication.shared.terminate(nil)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
                .padding(.top, 8)
                
                Spacer()
            }
            .frame(width: 450, height: 350)
            .padding(40)
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