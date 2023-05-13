//
//  HistoryView.swift
//  Trail Finder
//
//  Created by Shiv Shah on 4/20/23.
//
import SwiftUI
import CoreData

struct HistoryView: View {
   @ObservedObject var historyViewModel = HistoryViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(historyViewModel.historyData.suffix(10), id: \.self) { history in
                    VStack(alignment: .leading) {
                        Text(history.location ?? "Unknown location")
                            .font(.headline)
                            Text("Date: \(dateFormatter.string(from: history.timestamp ?? Date()))")
                                .font(.subheadline)
                    }
                }
            }
            .navigationBarTitle("History")
            .onAppear {
                historyViewModel.update()
            }
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()
