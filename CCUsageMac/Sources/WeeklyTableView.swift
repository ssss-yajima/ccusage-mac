import SwiftUI

struct WeeklyTableView: View {
    @EnvironmentObject var appState: AppState
    let weeklyData: [UsageData]
    let onQuit: () -> Void
    @State private var showingSettings = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Claude Code Usage - Last 7 Days")
                    .font(.system(.title3, design: .monospaced))
                    .bold()
                Spacer()
                
                Button(action: { appState.refresh() }) {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.plain)
                .disabled(appState.isLoading)
            }
            .padding()
            
            // Table
            ScrollView {
                VStack(spacing: 0) {
                    // Table Header
                    TableHeaderRow()
                    
                    // Table Body
                    ForEach(weeklyData, id: \.date) { usage in
                        TableDataRow(usage: usage, 
                                   dateFormatter: dateFormatter,
                                   numberFormatter: numberFormatter)
                    }
                    
                    // Separator
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1)
                        .padding(.vertical, 2)
                    
                    // Total Row
                    TotalRow(weeklyData: weeklyData, numberFormatter: numberFormatter)
                }
                .padding(.horizontal)
            }
            
            // Footer with Settings and Quit buttons
            HStack {
                if let lastUpdate = appState.lastUpdate {
                    Text("Updated \(lastUpdate, style: .relative) ago")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("Settings") {
                    showingSettings = true
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)
                
                Button("Quit") {
                    onQuit()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
            }
            .padding()
        }
        .frame(width: 900, height: 500)
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
}

struct TableHeaderRow: View {
    var body: some View {
        HStack(spacing: 0) {
            Text("Date")
                .frame(width: 100, alignment: .leading)
            
            Text("Models")
                .frame(width: 200, alignment: .leading)
            
            Text("Input")
                .frame(width: 90, alignment: .trailing)
            
            Text("Output")
                .frame(width: 90, alignment: .trailing)
            
            Text("Cache Create")
                .frame(width: 110, alignment: .trailing)
            
            Text("Cache Read")
                .frame(width: 110, alignment: .trailing)
            
            Text("Total Tokens")
                .frame(width: 110, alignment: .trailing)
            
            Text("Cost (USD)")
                .frame(width: 90, alignment: .trailing)
        }
        .font(.system(.caption, design: .monospaced))
        .bold()
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
    }
}

struct TableDataRow: View {
    let usage: UsageData
    let dateFormatter: DateFormatter
    let numberFormatter: NumberFormatter
    
    var body: some View {
        HStack(spacing: 0) {
            Text(dateFormatter.string(from: usage.date))
                .frame(width: 100, alignment: .leading)
            
            Text(formatModels(usage.models))
                .frame(width: 200, alignment: .leading)
                .lineLimit(1)
                .truncationMode(.tail)
            
            Text(formatNumber(usage.inputTokens))
                .frame(width: 90, alignment: .trailing)
            
            Text(formatNumber(usage.outputTokens))
                .frame(width: 90, alignment: .trailing)
            
            Text(formatNumber(usage.cacheCreateTokens))
                .frame(width: 110, alignment: .trailing)
            
            Text(formatNumber(usage.cacheReadTokens))
                .frame(width: 110, alignment: .trailing)
            
            Text(formatNumber(usage.totalTokens))
                .frame(width: 110, alignment: .trailing)
            
            Text("$\(String(format: "%.2f", usage.totalCost))")
                .frame(width: 90, alignment: .trailing)
        }
        .font(.system(.caption, design: .monospaced))
        .padding(.vertical, 6)
        .background(
            Rectangle()
                .fill(Color.gray.opacity(0.05))
                .opacity(usage.totalCost > 0 ? 1 : 0)
        )
    }
    
    private func formatModels(_ models: [String]) -> String {
        if models.isEmpty {
            return "-"
        }
        // Clean up model names
        let cleanedModels = models.map { model in
            model.replacingOccurrences(of: "claude-", with: "")
                 .replacingOccurrences(of: "-20250514", with: "")
                 .replacingOccurrences(of: "-20250219", with: "")
        }
        return cleanedModels.joined(separator: ", ")
    }
    
    private func formatNumber(_ number: Int) -> String {
        if number == 0 {
            return "-"
        }
        return numberFormatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

struct TotalRow: View {
    let weeklyData: [UsageData]
    let numberFormatter: NumberFormatter
    
    private var totals: (input: Int, output: Int, cacheCreate: Int, cacheRead: Int, total: Int, cost: Double) {
        weeklyData.reduce((0, 0, 0, 0, 0, 0.0)) { result, usage in
            (result.0 + usage.inputTokens,
             result.1 + usage.outputTokens,
             result.2 + usage.cacheCreateTokens,
             result.3 + usage.cacheReadTokens,
             result.4 + usage.totalTokens,
             result.5 + usage.totalCost)
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Text("Total")
                .frame(width: 100, alignment: .leading)
                .bold()
            
            Text("")
                .frame(width: 200, alignment: .leading)
            
            Text(formatNumber(totals.input))
                .frame(width: 90, alignment: .trailing)
                .bold()
            
            Text(formatNumber(totals.output))
                .frame(width: 90, alignment: .trailing)
                .bold()
            
            Text(formatNumber(totals.cacheCreate))
                .frame(width: 110, alignment: .trailing)
                .bold()
            
            Text(formatNumber(totals.cacheRead))
                .frame(width: 110, alignment: .trailing)
                .bold()
            
            Text(formatNumber(totals.total))
                .frame(width: 110, alignment: .trailing)
                .bold()
            
            Text("$\(String(format: "%.2f", totals.cost))")
                .frame(width: 90, alignment: .trailing)
                .bold()
        }
        .font(.system(.caption, design: .monospaced))
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
    }
    
    private func formatNumber(_ number: Int) -> String {
        return numberFormatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}