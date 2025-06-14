import Foundation

struct UsageData {
    let date: Date
    let models: [String]
    let inputTokens: Int
    let outputTokens: Int
    let cacheCreateTokens: Int
    let cacheReadTokens: Int
    let totalTokens: Int
    let totalCost: Double
}

struct JSONLEntry: Codable {
    let timestamp: String
    let version: String?
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

struct ModelPricing: Codable {
    let litellmProvider: String
    let inputCostPerToken: Double
    let outputCostPerToken: Double
    let maxTokens: Int?
    
    enum CodingKeys: String, CodingKey {
        case litellmProvider = "litellm_provider"
        case inputCostPerToken = "input_cost_per_token"
        case outputCostPerToken = "output_cost_per_token"
        case maxTokens = "max_tokens"
    }
}