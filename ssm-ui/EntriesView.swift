import SwiftUI

struct EntriesView: View {
  @State var showingModal = false;
  @State var entries = [
    Entry.init(nickname: "New Prod DWH", identifier: "i-09085d85d96472963", env: "smallapps-prod", localPort: 3389, remotePort: 3390)
  ]
  
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
    EntriesView()
  }
}
