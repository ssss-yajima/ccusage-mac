import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack(spacing: 4) {
            if appState.isLoading {
                ProgressView()
                    .controlSize(.small)
                    .scaleEffect(0.7)
            } else {
                Image(systemName: "brain")
                    .font(.system(size: 14))
                Text(appState.todaysCost)
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
            }
        }
    }
}