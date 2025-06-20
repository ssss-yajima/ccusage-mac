import SwiftUI

struct SettingsView: View {
    @ObservedObject private var settings = AppSettings.shared
    @State private var tempPath: String = ""
    @State private var validationError: String? = nil
    @State private var validationWarning: String? = nil
    @State private var showingFileDialog = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.title2)
                .bold()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Claude Data Path")
                    .font(.headline)
                
                HStack {
                    TextField("Enter path (e.g., ~/.claude)", text: $tempPath)
                        .textFieldStyle(.roundedBorder)
                        .disabled(false)  // 明示的に編集可能にする
                        .textSelection(.enabled)  // テキスト選択を有効化
                        .onSubmit {
                            validatePath()
                        }
                        .onChange(of: tempPath) { _ in
                            validatePath()
                        }
                    
                    Button("Browse...") {
                        showingFileDialog = true
                    }
                    .buttonStyle(.bordered)
                }
                
                if let error = validationError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                } else if !tempPath.isEmpty {
                    Text("✓ Valid path")
                        .font(.caption)
                        .foregroundColor(.green)
                    
                    if let warning = validationWarning {
                        Text(warning)
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                Text("Default: ~/.claude")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            HStack {
                Button("Reset to Default") {
                    tempPath = "~/.claude"
                    validatePath()
                }
                .buttonStyle(.plain)
                .foregroundColor(.blue)
                
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.escape)
                
                Button("Save") {
                    saveSettings()
                }
                .keyboardShortcut(.return)
                .disabled(validationError != nil || tempPath.isEmpty)
            }
        }
        .padding(20)
        .frame(width: 400)
        .onAppear {
            tempPath = settings.claudeDataPath
            validatePath()
        }
        .fileImporter(
            isPresented: $showingFileDialog,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    tempPath = url.path
                    validatePath()
                }
            case .failure:
                break
            }
        }
    }
    
    private func validatePath() {
        guard !tempPath.isEmpty else {
            validationError = nil
            validationWarning = nil
            return
        }
        
        let expandedPath = NSString(string: tempPath).expandingTildeInPath
        let url = URL(fileURLWithPath: expandedPath)
        let fileManager = FileManager.default
        
        // Check if path exists
        guard fileManager.fileExists(atPath: url.path) else {
            validationError = "Path does not exist"
            validationWarning = nil
            return
        }
        
        // Check if it's a directory
        var isDirectory: ObjCBool = false
        fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory)
        guard isDirectory.boolValue else {
            validationError = "Path is not a directory"
            validationWarning = nil
            return
        }
        
        // Check if projects subdirectory exists
        let projectsPath = url.appendingPathComponent("projects")
        guard fileManager.fileExists(atPath: projectsPath.path) else {
            validationError = "No 'projects' subdirectory found"
            validationWarning = nil
            return
        }
        
        validationError = nil
        
        // Check for JSONL files
        var hasJSONLFiles = false
        if let enumerator = fileManager.enumerator(
            at: projectsPath,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) {
            for case let fileURL as URL in enumerator {
                if fileURL.pathExtension == "jsonl" {
                    hasJSONLFiles = true
                    break
                }
            }
        }
        
        if !hasJSONLFiles {
            validationWarning = "⚠️ No JSONL files found in projects directory"
        } else {
            validationWarning = nil
        }
    }
    
    private func saveSettings() {
        settings.claudeDataPath = tempPath
        dismiss()
    }
}