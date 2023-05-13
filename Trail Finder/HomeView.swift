//
//  HomeView.swift
//  Trail Finder
//
//  Created by Shiv Shah on 4/20/23.
//

import SwiftUI
import CoreData

struct HomeView: View {
    @ObservedObject var savedViewModel = SavedViewModel()

    var body: some View {
        NavigationView {
            List {
                if savedViewModel.savedData.isEmpty {
                    Text("No favorited trails. Please favorite a trail!")
                }
                else {
                    
                    
                    ForEach(savedViewModel.savedData) { savedTrail in
                        NavigationLink(destination: HomeDetailView(savedTrail: savedTrail)) {
                            
                            HStack {
                                if let urlString = savedTrail.thumbnail, let imageURL = URL(string: urlString) {
                                    AsyncImage(url: imageURL) { image in
                                        image.resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(Color.gray)
                                    }
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(5)
                                    .clipped()
                                }
                                else {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.gray)
                                        .frame(width: 60, height: 60)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(savedTrail.name ?? "")
                                        .font(.headline)
                                    Text(savedTrail.city ?? "")
                                        .font(.subheadline)
                                }
                            }
                        }
                    }
                    .onDelete(perform: delete)
                }
            }
            .navigationTitle("Saved Trails")
            .onAppear {
                savedViewModel.update()
            }
        }
    }
    private func delete(at offsets: IndexSet) {
        offsets.forEach { index in
            let savedTrail = savedViewModel.savedData
            savedViewModel.deleteData(name: savedTrail[index].name ?? "")
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}


