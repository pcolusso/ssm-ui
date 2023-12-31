//
//  EntryView.swift
//  ssm-ui
//
//  Created by Paul Colusso on 3/8/2023.
//

import SwiftUI

func color(forStatus status: EntryStatus) -> Color {
    switch status {
    case .running:
        return Color.green
    case .stopped:
        return Color.red
    case .error:
        return Color.yellow
    }
}

struct EntryView: View {
    @ObservedObject var entry: Entry
    let removeAction: (String) -> Void
    @State private var showModal = false
    
    
    func wrappedRemoveAction() {
        removeAction(entry.identifier)
    }
    
    private var toggleBinding: Binding<Bool> { Binding (
        get: { entry.status == .running },
        set: { newvalue in
            if (newvalue == true) {
                entry.start()
            } else {
                entry.stop()
            }
        }
    )}
    
    var body: some View {
        EntryCard(status: entry.status, name: entry.name(), localPort: entry.localPort, remotePort: entry.remotePort, running: toggleBinding, showModal: $showModal, removeAction: wrappedRemoveAction)
            .sheet(isPresented: $showModal) {
                ModalView(entry: entry)
            }
    }
}

struct EntryCard: View {
    let status: EntryStatus
    let name: String
    let localPort: Int
    let remotePort: Int
    @Binding var running: Bool
    @Binding var showModal: Bool
    let removeAction: () -> Void
    
    var subtitle: String {
        switch status {
        case .running:
            return "Running, accessing \(remotePort) at localhost:\(localPort)"
        case .stopped:
            return "Not running"
        case .error:
            return "Connection failed"
        }
    }
    
    func edit() {
        showModal.toggle()
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(name)
                HStack {
                    Circle().fill(color(forStatus: status)).frame(width: 10, height: 10)
                    Text(subtitle).font(.system(size: 11)).foregroundStyle(.gray)
                }
            }
            Spacer(minLength: 3)
            Button(action: removeAction) {
                Label("Delete", systemImage: "trash")
            }.labelStyle(.iconOnly)
            Button(action: edit) {
                Label("Edit", systemImage: "pencil")
            }.labelStyle(.iconOnly)
            Toggle("", isOn: $running).toggleStyle(.switch)
        }.padding().overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 0.1))
    }
}

struct EntryView_Previews: PreviewProvider {
    static var previews: some View {
        @State var a = false
        @State var b = true
        
        VStack {
            EntryCard(status: .running, name: "i12345678", localPort: 1337, remotePort: 42069, running: $a, showModal: $a, removeAction: { })
            EntryCard(status: .stopped, name: "DWH", localPort: 1337, remotePort: 42069, running: $b, showModal: $a, removeAction: { })
            EntryCard(status: .error, name: "Database", localPort: 1337, remotePort: 42069, running: $a, showModal: $a, removeAction: { })
        }.padding()
    }
}

let numberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter
}()

struct ModalView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var entry: Entry
    
    var nicknameBinding: Binding<String> {
        Binding<String>(
            get: { entry.nickname ?? "" },
            set: { entry.nickname = $0.isEmpty ? nil : $0 }
        )
    }
    
    var body: some View {
        Form {
            TextField("Name", text: nicknameBinding)
            TextField("Instance Name", text: $entry.identifier)
            TextField("Environment", text: $entry.env)
            TextField("Local Port", value: $entry.localPort, formatter: numberFormatter)
            TextField("Remote Port", value: $entry.remotePort, formatter: numberFormatter)
            Button("Save") {
                dismiss()
            }
        }.padding().frame(minWidth: 350)
    }
}


struct ModalView_Previews: PreviewProvider {
    static var previews: some View {
        @ObservedObject var entry = Entry(identifier: "i-123", env: "Cool EC2 Instance", localPort: 12, remotePort: 21)
        ModalView(entry: entry)
    }
}
