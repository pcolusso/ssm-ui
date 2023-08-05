import SwiftUI

enum EntriesState {
    case notLoaded, loaded(Array<Entry>)
}

struct EntriesLoaderView: View {
    @State var state: EntriesState = .notLoaded
    private var entriesBinding: Binding<[Entry]> {
        Binding(
            get: {
                if case .loaded(let entries) = state {
                    return entries
                } else {
                    preconditionFailure("Unreachable")
                }
            },
            set: { newEntries in
                preconditionFailure("Unreachable")
            }
        )
    }
    
    var body: some View {
        switch state {
        case .notLoaded:
            VStack {
                Text("Not Loaded")
                ProgressView()
            }
        case .loaded(_): // Technically, we can pull the array out of the sum type, but SwiftUI does not have sugar to facilitate that. As a result, we use an adapter to create the binding for us. In theory, the other branches are not reachable.
            EntriesView(entries: entriesBinding)
        }
    }
}

struct EntriesView: View {
    @State var showingModal = false;
    @Binding var entries: Array<Entry>
    
    func newEntry() {
        showingModal = true
    }
    
    var body: some View {
        VStack {
            VStack {
                ForEach(entries, id: \.identifier) { entry in
                    EntryView(entry: entry)
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
        
        EntriesView(entries: $entries)
    }
}
