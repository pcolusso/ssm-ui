
import SwiftUI
import Foundation

let FILENAME = "connections.json"


class JsonBackedEntries : ObservableObject {
    enum State {
        case idle
        case loading
        case loaded
        case failed(Error)
    }
    
    @Published var state = State.idle
    @Published var entries: [Entry] = [] {
        didSet {
            save()
        }
    }
    
    func save() {
        guard case .loaded = state else {
            return // cannot save an unloaded state
        }
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(entries) {
            let url = getDocumentsDirectory().appendingPathComponent(FILENAME)
            try? encoded.write(to: url)
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func load() {
        self.state = .loading
        
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            let url = getDocumentsDirectory().appendingPathComponent(FILENAME)
            if FileManager.default.fileExists(atPath: url.path) {
                do {
                    let data = try Data(contentsOf: url)
                    let decoder = JSONDecoder()
                    let decoded = try decoder.decode([Entry].self, from: data)
                    DispatchQueue.main.async {
                        self.state = .loaded
                        self.entries = decoded
                    }
                } catch { // The file exists, but could not be loaded. Bubble up that the file needs to be recovered.
                    DispatchQueue.main.async {
                        self.state = .failed(error)
                    }
                }
            } else { // The file does not exist, create a new empty one.
                DispatchQueue.main.async {
                    self.state = .loaded
                    self.entries = []
                    // Optional: You may also want to save the empty array to create the file
                    self.save()
                }
            }
        }
    }
}
