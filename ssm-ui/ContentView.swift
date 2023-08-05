//
//  ContentView.swift
//  ssm-ui
//
//  Created by Paul Colusso on 3/8/2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            EntriesLoaderView()
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
