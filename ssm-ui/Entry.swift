import Foundation
import SwiftUI

enum EntryStatus {
    case running, stopped, error
}

class Entry : ObservableObject, Codable {
    @Published var nickname: String?
    @Published var identifier: String
    @Published var env: String
    @Published var localPort: Int
    @Published var remotePort: Int
    @Published var status: EntryStatus = .stopped
    var process: ShellProcess?
    
    private enum CodingKeys: String, CodingKey {
        case nickname, identifier, env, localPort, remotePort
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(nickname, forKey: .nickname)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(env, forKey: .env)
        try container.encode(localPort, forKey: .localPort)
        try container.encode(remotePort, forKey: .remotePort)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        nickname = try container.decode(String?.self, forKey: .nickname)
        identifier = try container.decode(String.self, forKey: .identifier)
        env = try container.decode(String.self, forKey: .env)
        localPort = try container.decode(Int.self, forKey: .localPort)
        remotePort = try container.decode(Int.self, forKey: .remotePort)
        status = .stopped
    }
    
    init(nickname: String? = nil, identifier: String, env: String, localPort: Int, remotePort: Int) {
        self.nickname = nickname
        self.identifier = identifier
        self.env = env
        self.localPort = localPort
        self.remotePort = remotePort
    }
    
    func name() -> String {
        switch nickname {
        case .none:
            return self.identifier
        case .some(let wrapped):
            return wrapped
        }
    }
    
    func start() {
        if (self.process != nil) {
            return
        }
        
        process = ShellProcess.init(
            command: "/opt/homebrew/bin/aws",
            arguments: [
                "ssm",
                "start-session",
                "--target", self.identifier,
                "--document-name", "AWS-StartPortForwardingSession",
                "--parameters", "{\"portNumber\":[\"\(self.remotePort)\"],\"localPortNumber\":[\"\(self.localPort)\"]}"],
            environment: env,
            terminationHandler: {
                print("Stopped")
                DispatchQueue.main.async {
                    self.status = .stopped
                }
            }
            
        )
        
        process?.start()
        self.status = .running
    }
    
    func stop() {
        if let process = self.process {
            process.terminate()
        }
    }
}

class ShellProcess {
    private var process: Process!
    private var outputPipe: Pipe!
    private var terminationHandler: (() -> Void)?
    
    init(command: String, arguments: [String], environment: String? = nil,  terminationHandler: (() -> Void)?) {
        process = Process()
        outputPipe = Pipe()
        
        process.launchPath = command
        process.arguments = arguments
        process.standardOutput = outputPipe
        process.terminationHandler = { _ in terminationHandler?() }
        
        if let env = environment {
            var environment = ProcessInfo.processInfo.environment
            environment["PATH"] = "/usr/local/bin:" + (environment["PATH"] ?? "")
            environment["AWS_PROFILE"] = env
            process.environment = environment
        }
        
        let outputHandle = outputPipe.fileHandleForReading
        outputHandle.readabilityHandler = { fileHandle in
            if let string = String(data: fileHandle.availableData, encoding: .utf8) {
                print("Output: \(string)")
            }
        }
    }
    
    func start() {
        process.launch()
    }
    
    func terminate() {
        process.terminate()
    }
}
