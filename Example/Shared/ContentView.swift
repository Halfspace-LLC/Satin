//
//  ContentView.swift
//  Shared
//
//  Created by Taylor Holliday on 8/3/22.
//  Copyright © 2022 Hi-Rez. All rights reserved.
//

import SwiftUI
import Forge

struct ContentView: View {
    var body: some View {
        ForgeView(renderer: Renderer())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
