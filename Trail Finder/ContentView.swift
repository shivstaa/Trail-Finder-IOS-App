//
//  ContentView.swift
//  Trail Finder
//
//  Created by Shiv Shah on 4/20/23.
//

import SwiftUI
import MapKit
import Combine

let headers = [
    "X-RapidAPI-Key": "cf2d513b0fmsh766c4a2570ba2cbp1c2330jsn7046e42b0e09",
    "X-RapidAPI-Host": "trailapi-trailapi.p.rapidapi.com"
]

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
            
            HistoryView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("History")
                }
        }
        .preferredColorScheme(.dark)
    }
   
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
