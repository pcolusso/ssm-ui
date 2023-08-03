//
//  Status.swift
//  ssm-ui
//
//  Created by Paul Colusso on 3/8/2023.
//

import SwiftUI

enum Status {
  case unchecked, okay, failed
}

func color(forStatus status: Status) -> Color {
    switch status {
    case .unchecked:
      return Color.yellow
    case .okay:
        return Color.green
    case .failed:
        return Color.red
    }
}

func iamge(forStatus status: Status) -> String {
  switch status {
  case .unchecked:
      return "circle.circle.fill"
  case .okay:
      return "checkmark.circle.fill"
  case .failed:
      return "multiply.circle.fill"
  }
}

struct StatusTag: View {
  let status: Status
  let name: String
  
  
  var body: some View {
    HStack {
      Image(systemName: iamge(forStatus: status))
        .foregroundColor(color(forStatus: status))
      Text(name)
        .foregroundColor(.black)
    }.padding(.leading, 10)
     .padding(.trailing, 10)
     .padding(.bottom, 1)
     .padding(.top, 1)
     .background(Capsule(style: .continuous))
  }
}

struct StatusView_Preview: PreviewProvider {
  static var previews: some View {
    VStack {
      StatusTag(status: .unchecked, name: "Unchecked")
      StatusTag(status: .okay, name: "Okay")
      StatusTag(status: .failed, name: "Failed")
    }.padding()
  }
}
