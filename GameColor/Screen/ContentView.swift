//
//  ContentView.swift
//  GameColor
//
//  Created by Thanh Dao on 8/7/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            StartView()
        }
        .navigationViewStyle(.stack)
    }
}

#Preview {
    ContentView()
}
