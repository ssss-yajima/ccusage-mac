#!/usr/bin/env swift

import Foundation

// Copy of the relevant structures and logic for testing
struct JSONLEntry: Codable {
    let timestamp: String
    let message: Message
    let costUSD: Double?
    let requestId: String?
    
    struct Message: Codable {
        let usage: Usage
        let model: String?
        let id: String?
        
        struct Usage: Codable {
            let inputTokens: Int
            let outputTokens: Int
            let cacheCreationInputTokens: Int?
            let cacheReadInputTokens: Int?
            
            enum CodingKeys: String, CodingKey {
                case inputTokens = "input_tokens"
                case outputTokens = "output_tokens"
                case cacheCreationInputTokens = "cache_creation_input_tokens"
                case cacheReadInputTokens = "cache_read_input_tokens"
            }
        }
    }
}

func testDateFiltering() async {
    let fileManager = FileManager.default
    let decoder = JSONDecoder()
    let claudePath = fileManager.homeDirectoryForCurrentUser.appendingPathComponent(".claude/projects")
    
    var allEntries: [JSONLEntry] = []
    
    // Load all JSONL files
    let enumerator = fileManager.enumerator(
        at: claudePath,
        includingPropertiesForKeys: [.isRegularFileKey],
        options: [.skipsHiddenFiles]
    )
    
    while let fileURL = enumerator?.nextObject() as? URL {
        guard fileURL.pathExtension == "jsonl" else { continue }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let lines = String(data: data, encoding: .utf8)?.components(separatedBy: .newlines) ?? []
            
            for line in lines {
                guard !line.isEmpty else { continue }
                
                do {
                    if let lineData = line.data(using: .utf8) {
                        let entry = try decoder.decode(JSONLEntry.self, from: lineData)
                        allEntries.append(entry)
                    }
                } catch {
                    continue
                }
            }
        } catch {
            continue
        }
    }
    
    print("Total entries loaded: \(allEntries.count)")
    
    // Filter for today using ccusage logic
    let iso8601Formatter = ISO8601DateFormatter()
    iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    
    let localDateFormatter = DateFormatter()
    localDateFormatter.dateFormat = "yyyy-MM-dd"
    localDateFormatter.timeZone = TimeZone.current
    
    let todayString = localDateFormatter.string(from: Date())
    print("Filtering for date: \(todayString)")
    
    var inputTokens = 0
    var outputTokens = 0
    var cacheCreateTokens = 0
    var cacheReadTokens = 0
    var totalCost = 0.0
    var modelCounts: [String: Int] = [:]
    var processedIds = Set<String>()
    
    for entry in allEntries {
        // Deduplicate based on requestId or message.id
        let uniqueId = entry.requestId ?? entry.message.id ?? UUID().uuidString
        if processedIds.contains(uniqueId) {
            continue
        }
        processedIds.insert(uniqueId)
        // Skip synthetic model
        if entry.message.model == "<synthetic>" {
            continue
        }
        
        guard let entryDate = iso8601Formatter.date(from: entry.timestamp) else {
            continue
        }
        
        let entryDateString = localDateFormatter.string(from: entryDate)
        
        if entryDateString == todayString {
            inputTokens += entry.message.usage.inputTokens
            outputTokens += entry.message.usage.outputTokens
            cacheCreateTokens += entry.message.usage.cacheCreationInputTokens ?? 0
            cacheReadTokens += entry.message.usage.cacheReadInputTokens ?? 0
            
            if let cost = entry.costUSD {
                totalCost += cost
            } else {
                // Simple cost calculation
                let model = entry.message.model ?? "unknown"
                var entryCost = 0.0
                
                if model.contains("opus-4") {
                    entryCost += Double(entry.message.usage.inputTokens) * 15.0 / 1_000_000
                    entryCost += Double(entry.message.usage.outputTokens) * 75.0 / 1_000_000
                    entryCost += Double(entry.message.usage.cacheCreationInputTokens ?? 0) * 18.75 / 1_000_000
                    entryCost += Double(entry.message.usage.cacheReadInputTokens ?? 0) * 1.5 / 1_000_000
                } else if model.contains("sonnet-4") {
                    entryCost += Double(entry.message.usage.inputTokens) * 3.0 / 1_000_000
                    entryCost += Double(entry.message.usage.outputTokens) * 15.0 / 1_000_000
                    entryCost += Double(entry.message.usage.cacheCreationInputTokens ?? 0) * 3.75 / 1_000_000
                    entryCost += Double(entry.message.usage.cacheReadInputTokens ?? 0) * 0.3 / 1_000_000
                }
                
                totalCost += entryCost
            }
            
            if let model = entry.message.model {
                modelCounts[model, default: 0] += 1
            }
        }
    }
    
    print("\nCCUsageMac Test Results for \(todayString):")
    print("Total Cost: $\(String(format: "%.2f", totalCost))")
    print("Input Tokens: \(inputTokens)")
    print("Output Tokens: \(outputTokens)")
    print("Cache Create Tokens: \(cacheCreateTokens)")
    print("Cache Read Tokens: \(cacheReadTokens)")
    print("Total Tokens: \(inputTokens + outputTokens + cacheCreateTokens + cacheReadTokens)")
    print("Models used: \(modelCounts.keys.sorted().joined(separator: ", "))")
}

// Run the test
await testDateFiltering()