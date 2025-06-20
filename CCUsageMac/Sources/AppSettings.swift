import Foundation
import SwiftUI

class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    @Published var claudeDataPath: String {
        didSet {
            UserDefaults.standard.set(claudeDataPath, forKey: "claudeDataPath")
        }
    }
    
    var claudeDataURL: URL {
        if claudeDataPath.isEmpty {
            // Default to ~/.claude
            return FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".claude")
        } else {
            // Expand tilde if present
            let expandedPath = NSString(string: claudeDataPath).expandingTildeInPath
            return URL(fileURLWithPath: expandedPath)
        }
    }
    
    private init() {
        // Initialize with stored value or default
        let stored = UserDefaults.standard.string(forKey: "claudeDataPath") ?? ""
        if stored.isEmpty {
            self.claudeDataPath = "~/.claude"
        } else {
            self.claudeDataPath = stored
        }
    }
    
    func validatePath() -> (isValid: Bool, error: String?) {
        let fileManager = FileManager.default
        let url = claudeDataURL
        
        // Check if path exists
        guard fileManager.fileExists(atPath: url.path) else {
            return (false, "Path does not exist")
        }
        
        // Check if it's a directory
        var isDirectory: ObjCBool = false
        fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory)
        guard isDirectory.boolValue else {
            return (false, "Path is not a directory")
        }
        
        // Check if projects subdirectory exists
        let projectsPath = url.appendingPathComponent("projects")
        guard fileManager.fileExists(atPath: projectsPath.path) else {
            return (false, "No 'projects' subdirectory found")
        }
        
        return (true, nil)
    }
    
    func resetToDefault() {
        claudeDataPath = "~/.claude"
    }
}