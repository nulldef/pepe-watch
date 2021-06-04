//
//  ContentView.swift
//  RandomPepega WatchKit Extension
//
//  Created by nulldef on 29.05.2021.
//

import SwiftUI
import Combine

struct ContentView: View {
    @ObservedObject var model = ViewModel()

    var body: some View {
        ZStack {
            if model.loading {
                VStack {
                    Text("RandomPepega")
                        .font(.headline)
                        .padding()
                    Text("Wait for it...")
                        .font(.subheadline)
                }
            } else {
                if let image = model.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                }
            }
        }
        .padding()
        .onAppear(perform: model.refresh)
        .onTapGesture(perform: model.refresh)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
