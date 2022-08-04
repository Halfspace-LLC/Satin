//
//  ContentView.swift
//  Shared
//
//  Created by Taylor Holliday on 8/3/22.
//  Copyright © 2022 Hi-Rez. All rights reserved.
//

import SwiftUI
import Forge

struct MasterView: View {
    var body: some View {
        Form {
            Group {
                NavigationLink("2D", destination: ForgeView(renderer: Renderer()).ignoresSafeArea())
            }
        }
    }
}

struct DetailView: View {
    var body: some View {
        Text("Satin")
    }
}

struct ExamplesView: View {
    var body: some View {
        NavigationView {
            MasterView()
            DetailView()
        }.navigationViewStyle(DoubleColumnNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ExamplesView()
    }
}
