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
  @State private var showModal = false
  
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
    EntryCard(status: entry.status, name: entry.name(), running: toggleBinding, showModal: $showModal)
      .sheet(isPresented: $showModal) {
        ModalView(entry: entry)
      }
  }
}

struct EntryCard: View {
  let status: EntryStatus
  let name: String
  let localPort: Int = 1337
  let remotePort: Int = 1337
  @Binding var running: Bool
  @Binding var showModal: Bool
  
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
      Button(action: edit) {
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
      EntryCard(status: .running, name: "i12345678", running: $a, showModal: $a)
      EntryCard(status: .stopped, name: "DWH", running: $b, showModal: $a)
      EntryCard(status: .error, name: "Database", running: $a, showModal: $a)
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
