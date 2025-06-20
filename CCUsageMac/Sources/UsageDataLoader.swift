import Foundation

class UsageDataLoader {
    private let fileManager = FileManager.default
    private let decoder = JSONDecoder()
    private let calendar: Calendar = {
        var cal = Calendar.current
        cal.timeZone = TimeZone.current
        return cal
    }()
    private let settings = AppSettings.shared
    
    private var claudePath: URL {
        return settings.claudeDataURL
    }
    
    func loadTodaysUsage() async throws -> UsageData {
        let today = Date()
        let projectsPath = claudePath.appendingPathComponent("projects")
        
        guard fileManager.fileExists(atPath: projectsPath.path) else {
            throw UsageError.claudeDirectoryNotFound
        }
        
        let allEntries = try await loadAllJSONLFiles(in: projectsPath)
        #if DEBUG
        print("DEBUG: Total entries loaded: \(allEntries.count)")
        #endif
        
        // Use the same date format as ccusage (YYYY-MM-DD)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.current
        let todayString = dateFormatter.string(from: today)
        
        let todaysEntries = filterEntriesByDate(allEntries, dateString: todayString)
        #if DEBUG
        print("DEBUG: Today's entries (\(todayString)): \(todaysEntries.count)")
        #endif
        
        #if DEBUG
        // Debug: Show timestamp range
        if !todaysEntries.isEmpty {
            let sortedEntries = todaysEntries.sorted { $0.timestamp < $1.timestamp }
            print("DEBUG: First entry: \(sortedEntries.first!.timestamp)")
            print("DEBUG: Last entry: \(sortedEntries.last!.timestamp)")
        }
        #endif
        
        let usage = aggregateUsageData(from: todaysEntries, for: today)
        #if DEBUG
        print("DEBUG: Total cost: $\(String(format: "%.2f", usage.totalCost))")
        print("DEBUG: Token breakdown - Input: \(usage.inputTokens), Output: \(usage.outputTokens), Cache Create: \(usage.cacheCreateTokens), Cache Read: \(usage.cacheReadTokens)")
        print("DEBUG: Models used: \(usage.models.joined(separator: ", "))")
        #endif
        
        return usage
    }
    
    func loadWeeklyUsage() async throws -> [UsageData] {
        let today = Date()
        let projectsPath = claudePath.appendingPathComponent("projects")
        
        guard fileManager.fileExists(atPath: projectsPath.path) else {
            throw UsageError.claudeDirectoryNotFound
        }
        
        let allEntries = try await loadAllJSONLFiles(in: projectsPath)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.current
        
        var weeklyData: [UsageData] = []
        
        // Get data for the last 7 days
        for daysAgo in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else { continue }
            let dateString = dateFormatter.string(from: date)
            
            let dayEntries = filterEntriesByDate(allEntries, dateString: dateString)
            let usage = aggregateUsageData(from: dayEntries, for: date)
            
            weeklyData.append(usage)
        }
        
        // Sort by date ascending (oldest first)
        return weeklyData.reversed()
    }
    
    private func loadAllJSONLFiles(in directory: URL) async throws -> [JSONLEntry] {
        var allEntries: [JSONLEntry] = []
        
        let enumerator = fileManager.enumerator(
            at: directory,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        )
        
        while let fileURL = enumerator?.nextObject() as? URL {
            guard fileURL.pathExtension == "jsonl" else { continue }
            
            do {
                let entries = try await loadJSONLFile(at: fileURL)
                allEntries.append(contentsOf: entries)
            } catch {
                // Skip files that can't be read
                #if DEBUG
                print("Failed to load file: \(fileURL.lastPathComponent)")
                #endif
            }
        }
        
        return allEntries
    }
    
    private func loadJSONLFile(at url: URL) async throws -> [JSONLEntry] {
        let data = try Data(contentsOf: url)
        let lines = String(data: data, encoding: .utf8)?.components(separatedBy: .newlines) ?? []
        
        var entries: [JSONLEntry] = []
        
        for line in lines {
            guard !line.isEmpty else { continue }
            
            do {
                if let lineData = line.data(using: .utf8) {
                    let entry = try decoder.decode(JSONLEntry.self, from: lineData)
                    entries.append(entry)
                }
            } catch {
                // Skip malformed lines
                continue
            }
        }
        
        return entries
    }
    
    private func filterEntriesByDate(_ entries: [JSONLEntry], dateString: String) -> [JSONLEntry] {
        let iso8601Formatter = ISO8601DateFormatter()
        iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let localDateFormatter = DateFormatter()
        localDateFormatter.dateFormat = "yyyy-MM-dd"
        localDateFormatter.timeZone = TimeZone.current
        
        var foundCount = 0
        
        return entries.filter { entry in
            guard let entryDate = iso8601Formatter.date(from: entry.timestamp) else {
                // Only print first few failures to avoid spam
                #if DEBUG
                if foundCount < 5 {
                    print("DEBUG: Failed to parse timestamp: \(entry.timestamp)")
                }
                #endif
                return false
            }
            
            // Convert to local date string (same as ccusage's formatDate function)
            let entryDateString = localDateFormatter.string(from: entryDate)
            let matches = entryDateString == dateString
            
            if matches {
                foundCount += 1
                #if DEBUG
                if foundCount <= 5 {
                    print("DEBUG: Found entry #\(foundCount): \(entry.timestamp) -> \(entryDateString)")
                }
                #endif
            }
            
            return matches
        }
    }
    
    private func aggregateUsageData(from entries: [JSONLEntry], for date: Date) -> UsageData {
        var inputTokens = 0
        var outputTokens = 0
        var cacheCreateTokens = 0
        var cacheReadTokens = 0
        var totalCost = 0.0
        var modelsSet = Set<String>()
        
        // Remove duplicates based on requestId or message.id
        let uniqueEntries = removeDuplicates(from: entries)
        #if DEBUG
        print("DEBUG: Entries after deduplication: \(uniqueEntries.count) (removed \(entries.count - uniqueEntries.count) duplicates)")
        #endif
        
        var modelCosts: [String: Double] = [:]
        var skippedSynthetic = 0
        
        for entry in uniqueEntries {
            // Skip synthetic model entries completely
            if entry.message.model == "<synthetic>" {
                skippedSynthetic += 1
                continue
            }
            
            let usage = entry.message.usage
            inputTokens += usage.inputTokens
            outputTokens += usage.outputTokens
            cacheCreateTokens += usage.cacheCreationInputTokens ?? 0
            cacheReadTokens += usage.cacheReadInputTokens ?? 0
            
            if let model = entry.message.model {
                modelsSet.insert(model)
            }
            
            // Use pre-calculated cost if available, otherwise calculate
            var entryCost = 0.0
            if let cost = entry.costUSD {
                entryCost = cost
            } else {
                // Simple cost calculation based on model pricing
                // This is a temporary solution - should fetch from LiteLLM
                let model = entry.message.model ?? "unknown"
                let inputCost = calculateInputCost(model: model, tokens: usage.inputTokens)
                let outputCost = calculateOutputCost(model: model, tokens: usage.outputTokens)
                let cacheCreateCost = calculateCacheCreateCost(model: model, tokens: usage.cacheCreationInputTokens ?? 0)
                let cacheReadCost = calculateCacheReadCost(model: model, tokens: usage.cacheReadInputTokens ?? 0)
                entryCost = inputCost + outputCost + cacheCreateCost + cacheReadCost
            }
            
            totalCost += entryCost
            
            // Track cost per model (exclude synthetic model)
            let modelKey = entry.message.model ?? "unknown"
            if modelKey != "<synthetic>" {
                modelCosts[modelKey, default: 0.0] += entryCost
            }
        }
        
        let totalTokens = inputTokens + outputTokens + cacheCreateTokens + cacheReadTokens
        
        #if DEBUG
        if skippedSynthetic > 0 {
            print("DEBUG: Skipped \(skippedSynthetic) synthetic model entries")
        }
        #endif
        
        #if DEBUG
        // Debug: print cost breakdown by model
        print("DEBUG: Cost breakdown by model:")
        for (model, cost) in modelCosts.sorted(by: { $0.key < $1.key }) {
            print("  \(model): $\(String(format: "%.2f", cost))")
        }
        #endif
        
        return UsageData(
            date: date,
            models: Array(modelsSet).sorted(),
            inputTokens: inputTokens,
            outputTokens: outputTokens,
            cacheCreateTokens: cacheCreateTokens,
            cacheReadTokens: cacheReadTokens,
            totalTokens: totalTokens,
            totalCost: totalCost
        )
    }
    
    private func removeDuplicates(from entries: [JSONLEntry]) -> [JSONLEntry] {
        var seen = Set<String>()
        var uniqueEntries: [JSONLEntry] = []
        
        for entry in entries {
            // Create unique hash like ccusage
            var shouldSkip = false
            
            if let messageId = entry.message.id,
               let requestId = entry.requestId {
                let hash = "\(messageId):\(requestId)"
                if seen.contains(hash) {
                    shouldSkip = true
                } else {
                    seen.insert(hash)
                }
            }
            
            // Only add if not a duplicate
            if !shouldSkip {
                uniqueEntries.append(entry)
            }
        }
        
        return uniqueEntries
    }
    
    // Temporary pricing calculation - should be fetched from LiteLLM
    private func calculateInputCost(model: String, tokens: Int) -> Double {
        let costPerMillionTokens: Double
        
        if model.contains("opus-4") {
            costPerMillionTokens = 15.0
        } else if model.contains("sonnet-4") {
            costPerMillionTokens = 3.0
        } else if model.contains("haiku") {
            costPerMillionTokens = 0.25
        } else {
            costPerMillionTokens = 3.0 // Default to Sonnet pricing
        }
        
        return Double(tokens) * costPerMillionTokens / 1_000_000
    }
    
    private func calculateOutputCost(model: String, tokens: Int) -> Double {
        let costPerMillionTokens: Double
        
        if model.contains("opus-4") {
            costPerMillionTokens = 75.0
        } else if model.contains("sonnet-4") {
            costPerMillionTokens = 15.0
        } else if model.contains("haiku") {
            costPerMillionTokens = 1.25
        } else {
            costPerMillionTokens = 15.0 // Default to Sonnet pricing
        }
        
        return Double(tokens) * costPerMillionTokens / 1_000_000
    }
    
    private func calculateCacheCreateCost(model: String, tokens: Int) -> Double {
        let costPerMillionTokens: Double
        
        if model.contains("opus-4") {
            costPerMillionTokens = 18.75  // 25% more than input
        } else if model.contains("sonnet-4") {
            costPerMillionTokens = 3.75   // 25% more than input
        } else if model.contains("haiku") {
            costPerMillionTokens = 0.3125 // 25% more than input
        } else {
            costPerMillionTokens = 3.75   // Default to Sonnet pricing
        }
        
        return Double(tokens) * costPerMillionTokens / 1_000_000
    }
    
    private func calculateCacheReadCost(model: String, tokens: Int) -> Double {
        let costPerMillionTokens: Double
        
        if model.contains("opus-4") {
            costPerMillionTokens = 1.5    // 10% of input
        } else if model.contains("sonnet-4") {
            costPerMillionTokens = 0.3    // 10% of input
        } else if model.contains("haiku") {
            costPerMillionTokens = 0.025  // 10% of input
        } else {
            costPerMillionTokens = 0.3    // Default to Sonnet pricing
        }
        
        return Double(tokens) * costPerMillionTokens / 1_000_000
    }
}

enum UsageError: LocalizedError {
    case claudeDirectoryNotFound
    case noDataAvailable
    
    var errorDescription: String? {
        switch self {
        case .claudeDirectoryNotFound:
            return "Claude data directory not found. Please ensure Claude Code is installed."
        case .noDataAvailable:
            return "No usage data available for today."
        }
    }
}