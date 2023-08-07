import SwiftUI

struct EntriesLoaderView: View {
    @ObservedObject var file = JsonBackedEntries.init()
    
    var entries: Binding<[Entry]> {
        Binding<[Entry]>(
            get: {
                guard case .loaded(let entries) = file.state else {
                    return [] //TODO: Ensure unreacheable
                }
                return entries
            },
            set: {
                file.state = .loaded($0) // TODO: Should this also not be reachable?
                file.save()
            }
        )
    }
    
    init() {
        self.file.load()
    }
    
    func load() {
        file.load()
    }
    
    mutating func removeAction(id: String) {
        guard case .loaded(let entries) = file.state else {
            return
        }
        let filtered = entries.filter { $0.identifier == id }
        file.state = .loaded(filtered)
        file.save()
    }
    
    var body: some View {
        switch file.state {
        case .idle:
            Button(action: load) {
                Label("Load", systemImage: "filemenu.and.selection")
            }
        case .loading:
            VStack {
                Text("Not Loaded")
                ProgressView()
            }
        case .loaded(_):
            EntriesView(entries: entries, removeAction: { id in })
        case .failed(let error):
            Text("Failed to load: \(error.localizedDescription)")
        }
        
    }
}

struct EntriesView: View {
    @State var showingModal = false;
    @Binding var entries: Array<Entry>
    var removeAction: (String) -> Void
    
    func newEntry() {
        showingModal = true
    }
    
    var body: some View {
        VStack {
            VStack {
                ForEach(entries, id: \.identifier) { entry in
                    EntryView(entry: entry, removeAction: removeAction)
                }
            }
            VStack(alignment: .trailing) {
                Button(action: newEntry) {
                    Text("Add a new entry")
                }
            }.frame(maxWidth: .infinity, alignment: .trailing)
        }.padding().sheet(isPresented: $showingModal) {
            NewEntryView { newEntry in
                entries.append(newEntry)
                showingModal = false
            }
        }
    }
}

struct NewEntryView: View {
    var completion: (Entry) -> Void
    @State private var nickname: String = ""
    @State private var identifier: String = ""
    @State private var env: String = ""
    @State private var localPort: Int = 0
    @State private var remotePort: Int = 0
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    
    var body: some View {
        Form {
            TextField("Name", text: $nickname)
            TextField("Instance Name", text: $identifier)
            TextField("Local Port", value: $localPort, formatter: formatter)
            TextField("Remote Port", value: $remotePort, formatter: formatter)
            Button("Create") {
                let entry = Entry.init(nickname: nickname, identifier: identifier, env: env, localPort: localPort, remotePort: remotePort)
                completion(entry)
            }
        }.padding().frame(minWidth: 350)
    }
}

struct EntriesView_Previews: PreviewProvider {
    static var previews: some View {
        @State var entries = [
            Entry(identifier: "i-1234567890", env: "smallapps-dev", localPort: 3389, remotePort: 3389)
        ]
        
        EntriesView(entries: $entries, removeAction: {_ in } )
    }
}
