import Foundation

// Simple CLI to test the calculation logic
struct TestCLI {
    static func test() async {
        print("Testing CCUsageMac calculation logic...")
        
        let loader = UsageDataLoader()
        
        do {
            let usage = try await loader.loadTodaysUsage()
            
            print("\nResults:")
            print("Date: \(DateFormatter.localizedString(from: usage.date, dateStyle: .short, timeStyle: .none))")
            print("Total Cost: $\(String(format: "%.2f", usage.totalCost))")
            print("Input Tokens: \(usage.inputTokens)")
            print("Output Tokens: \(usage.outputTokens)")
            print("Cache Create Tokens: \(usage.cacheCreateTokens)")
            print("Cache Read Tokens: \(usage.cacheReadTokens)")
            print("Total Tokens: \(usage.totalTokens)")
            print("Models: \(usage.models.joined(separator: ", "))")
        } catch {
            print("Error: \(error)")
        }
    }
}