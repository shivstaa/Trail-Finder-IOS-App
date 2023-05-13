//
//  TrailDetailView.swift
//  Trail Finder
//
//  Created by Shiv Shah on 4/21/23.
//

import Foundation
import SwiftUI

struct TrailDetailView: View {
    
    @ObservedObject var historyViewModel = HistoryViewModel()
    
    @ObservedObject var savedViewModel = SavedViewModel()
    
    let Trail: trail
    
    @State private var isSaved: Bool = false
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack {
                    HStack {
                        if let thumbnailUrl = URL(string: Trail.thumbnail ?? ""), let imageData = try? Data(contentsOf: thumbnailUrl), let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 100)
                                .clipped()
                            
                        } else {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.gray)
                                .frame(height: 100)
                        }
                        
                        Button(action: {
                            if isSaved {
                                savedViewModel.deleteData(name: Trail.name)
                            } else {
                                savedViewModel.saveData(name: Trail.name, features: Trail.features, directions: Trail.directions, difficulty: Trail.difficulty, city: Trail.city, rating: Trail.rating, thumbnail: Trail.thumbnail ?? "")
                            }
                            isSaved.toggle()
                        }) {
                            Image(systemName: isSaved ? "star.fill" : "star")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .foregroundColor(isSaved ? .yellow : .gray)
                        }
                        .padding()
                    }
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Name:")
                                .bold()
                            Spacer()
                            Text(Trail.name)
                        }
                        HStack {
                            Text("City:")
                                .bold()
                            Spacer()
                            Text(Trail.city)
                        }
                        HStack {
                            Text("Directions:")
                                .bold()
                            Spacer()
                            Text(Trail.directions)
                        }
                        HStack {
                            Text("Difficulty:")
                                .bold()
                            Spacer()
                            Text(Trail.difficulty)
                        }
                        HStack {
                            Text("Features:")
                                .bold()
                            Spacer()
                            Text(Trail.features)
                        }
                    }
                    .padding(.horizontal)
                    
                    StarRatingView(rating: Trail.rating)
                        .padding()
                    
                    Spacer()
                }
            }
        }
        .navigationBarTitle(Trail.name)
        .onAppear {
            historyViewModel.saveData(location: Trail.name, timestamp: Date())
               }
    }
    
    func checkSavedStatus() {
            isSaved = savedViewModel.savedData.contains { savedTrail in
                savedTrail.name == Trail.name
            }
        }
}


struct StarRatingView: View {
    var rating: Double
    
    var body: some View {
        HStack {
            ForEach(0..<5) {index in
                Image(systemName: "star.fill")
                    .foregroundColor(rating >= Double(index + 1) ? .yellow : .gray)
            }
        }
    }
}
