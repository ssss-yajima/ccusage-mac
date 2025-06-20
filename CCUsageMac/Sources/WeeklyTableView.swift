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
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
                .disabled(appState.isLoading)
                .help("Refresh usage data")
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Table
            ScrollView {
                VStack(spacing: 0) {
                    // Table Header
                    TableHeaderRow()
                        .padding(.horizontal, 20)
                    
                    // Table Body
                    ForEach(weeklyData, id: \.date) { usage in
                        TableDataRow(usage: usage, 
                                   dateFormatter: dateFormatter,
                                   numberFormatter: numberFormatter)
                            .padding(.horizontal, 20)
                    }
                    
                    // Separator
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 20)
                    
                    // Total Row
                    TotalRow(weeklyData: weeklyData, numberFormatter: numberFormatter)
                        .padding(.horizontal, 20)
                }
                .padding(.vertical, 12)
            }
            
            Divider()
            
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
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(NSColor.controlBackgroundColor))
        }
        .frame(width: 940, height: 520)
        .background(Color(NSColor.windowBackgroundColor))
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
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(6)
    }
}

struct TableDataRow: View {
    let usage: UsageData
    let dateFormatter: DateFormatter
    let numberFormatter: NumberFormatter
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 0) {
            Text(dateFormatter.string(from: usage.date))
                .frame(width: 100, alignment: .leading)
            
            Text(formatModels(usage.models))
                .frame(width: 200, alignment: .leading)
                .lineLimit(1)
                .truncationMode(.tail)
                .help(usage.models.joined(separator: ", "))
            
            Text(formatNumber(usage.inputTokens))
                .frame(width: 90, alignment: .trailing)
                .foregroundColor(usage.inputTokens > 0 ? .primary : .secondary)
            
            Text(formatNumber(usage.outputTokens))
                .frame(width: 90, alignment: .trailing)
                .foregroundColor(usage.outputTokens > 0 ? .primary : .secondary)
            
            Text(formatNumber(usage.cacheCreateTokens))
                .frame(width: 110, alignment: .trailing)
                .foregroundColor(usage.cacheCreateTokens > 0 ? .primary : .secondary)
            
            Text(formatNumber(usage.cacheReadTokens))
                .frame(width: 110, alignment: .trailing)
                .foregroundColor(usage.cacheReadTokens > 0 ? .primary : .secondary)
            
            Text(formatNumber(usage.totalTokens))
                .frame(width: 110, alignment: .trailing)
                .fontWeight(usage.totalTokens > 0 ? .medium : .regular)
            
            Text("$\(String(format: "%.2f", usage.totalCost))")
                .frame(width: 90, alignment: .trailing)
                .foregroundColor(usage.totalCost > 0 ? .primary : .secondary)
                .fontWeight(usage.totalCost > 0 ? .medium : .regular)
        }
        .font(.system(.caption, design: .monospaced))
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(isHovered ? Color.accentColor.opacity(0.1) : (usage.totalCost > 0 ? Color.gray.opacity(0.05) : Color.clear))
        )
        .onHover { hovering in
            isHovered = hovering
        }
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
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
    
    private func formatNumber(_ number: Int) -> String {
        return numberFormatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}