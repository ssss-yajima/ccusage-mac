import SwiftUI

struct UsageDetailView: View {
    let usage: UsageData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Total Cost
            HStack {
                Label("Total Cost", systemImage: "dollarsign.circle.fill")
                    .font(.headline)
                Spacer()
                Text(String(format: "$%.2f", usage.totalCost))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            
            Divider()
            
            // Token Usage
            VStack(alignment: .leading, spacing: 12) {
                Text("Token Usage")
                    .font(.headline)
                
                TokenRow(label: "Input", value: usage.inputTokens, icon: "arrow.right.circle")
                TokenRow(label: "Output", value: usage.outputTokens, icon: "arrow.left.circle")
                TokenRow(label: "Cache Create", value: usage.cacheCreateTokens, icon: "plus.circle")
                TokenRow(label: "Cache Read", value: usage.cacheReadTokens, icon: "doc.circle")
                
                Divider()
                
                TokenRow(label: "Total", value: usage.totalTokens, icon: "sum")
                    .fontWeight(.semibold)
            }
            
            Divider()
            
            // Models Used
            if !usage.models.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Models Used")
                        .font(.headline)
                    
                    ForEach(usage.models, id: \.self) { model in
                        HStack {
                            Image(systemName: "cpu")
                                .foregroundColor(.secondary)
                            Text(formatModelName(model))
                                .font(.caption)
                            Spacer()
                        }
                    }
                }
            }
            
            Spacer()
        }
    }
    
    private func formatModelName(_ model: String) -> String {
        // Simplify model names for display
        if model.contains("opus") {
            return "Claude Opus"
        } else if model.contains("sonnet") {
            return "Claude Sonnet"
        } else if model.contains("haiku") {
            return "Claude Haiku"
        }
        return model
    }
}

struct TokenRow: View {
    let label: String
    let value: Int
    let icon: String
    
    var body: some View {
        HStack {
            Label(label, systemImage: icon)
                .foregroundColor(.secondary)
                .font(.caption)
            Spacer()
            Text(formatNumber(value))
                .font(.system(.caption, design: .monospaced))
        }
    }
    
    private func formatNumber(_ num: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: num)) ?? "\(num)"
    }
}