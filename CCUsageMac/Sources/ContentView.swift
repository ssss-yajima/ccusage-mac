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
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Claude Usage")
                        .font(.headline)
                    Text("Today's Usage")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: { appState.refresh() }) {
                    Image(systemName: "arrow.clockwise")
                        .imageScale(.medium)
                }
                .buttonStyle(.plain)
                .disabled(appState.isLoading)
            }
            .padding()
            
            Divider()
            
            // Content
            if appState.isLoading && appState.todaysUsage == nil {
                ProgressView("Loading usage data...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
            } else if let error = appState.lastError {
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
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else if let usage = appState.todaysUsage {
                UsageDetailView(usage: usage)
                    .padding()
            } else {
                Text("No data available")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
            }
            
            Divider()
            
            // Footer
            HStack {
                if let lastUpdate = appState.lastUpdate {
                    Text("Updated \(lastUpdate, formatter: relativeDateFormatter)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .font(.caption)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .frame(width: 350, height: 400)
    }
}