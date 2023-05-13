//
//  HomeDetailView.swift
//  Trail Finder
//
//  Created by Shiv Shah on 4/21/23.
//

import SwiftUI

struct HomeDetailView: View {
    let savedTrail: Saved
    
    var body: some View {
        ScrollView {
            
            HStack {
                if let thumbnailUrl = URL(string: savedTrail.thumbnail ?? ""), let imageData = try? Data(contentsOf: thumbnailUrl), let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 150)
                        .clipped()
                    
                } else {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.gray)
                        .frame(height: 150)
                }
            }
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Name:")
                        .bold()
                    Spacer()
                    Text(savedTrail.name ?? "")
                }
                HStack {
                    Text("City:")
                        .bold()
                    Spacer()
                    Text(savedTrail.city ?? "")
                }
                HStack {
                    Text("Directions:")
                        .bold()
                    Spacer()
                    Text(savedTrail.directions ?? "")
                }
                HStack {
                    Text("Difficulty:")
                        .bold()
                    Spacer()
                    Text(savedTrail.difficulty ?? "")
                }
                HStack {
                    Text("Features:")
                        .bold()
                    Spacer()
                    Text(savedTrail.features ?? "")
                }
                HStack {
                    Text("Rating:")
                        .bold()
                    Spacer()
                    StarRatingView(rating: savedTrail.rating)
                }
                Spacer()
            }
            .padding(.horizontal)
        }
    }
}
