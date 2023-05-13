//
//  SearchView.swift
//  Trail Finder
//
//  Created by Shiv Shah on 4/20/23.
//

import Foundation
import SwiftUI
import MapKit

enum LengthValue: Decodable {
    case string(String)
    case double(Double)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else if let doubleValue = try? container.decode(Double.self) {
            self = .double(doubleValue)
        } else {
            throw DecodingError.typeMismatch(LengthValue.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected String or Double"))
        }
    }
}

struct traildata: Decodable {
    let results: Int
    let data: [trail]
}

struct trail: Decodable {
    var id: Int
    var name: String
    var url: String
    var length: LengthValue?
    var description: String
    var directions: String
    var city: String
    var region: String
    var country: String
    var lat: String
    var lon: String
    var difficulty: String
    var features: String
    var rating: Double
    var thumbnail: String?
}

struct Location: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

struct SearchView: View {
    @State private var cityName: String = ""

    @State private var trailNames: [String] = []
    @State private var trailCity: [String] = []
    @State private var trailThumbnail: [String] = []
    
    @State private var defaultLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 33.4255, longitude: -111.9400)
    
    @State private var region = MKCoordinateRegion()
    
    @State private var markers: [Location] = []
    
    @State private var searchText = ""
    @State private var lon: String = ""
    @State private var lat: String = ""
    
    @State private var storeData: traildata?
    
    var body: some View {
        VStack {
            Map(coordinateRegion: $region,
                interactionModes: .all,
                annotationItems: markers) { location in
                
                //Using map annotation, will display a pin for each search result
                MapAnnotation(coordinate: location.coordinate) {
                    Image(systemName: "pin.fill").foregroundColor(.red)
                    Text(location.name)
                }
            }
            .ignoresSafeArea()
            
            //Calls function to search for coordinates for the city we are interested in
                .onAppear {
                    findCoord(city: cityName) { coordinate in
                        //Sets location to be the current coordinate
                        self.defaultLocation = coordinate

                        //Sets region to be focused on the city
                        self.region.center = coordinate

                        //Map will display +/- 0.2
                        self.region.span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)

                        //Stores all markers found at the location
                        self.markers = [Location(name: cityName, coordinate: coordinate)]

                        //Sets the coordinates that are found within the area
                        self.lat = String(format: "%.4f", coordinate.latitude)
                        self.lon = String(format: "%.4f", coordinate.longitude)
                    }
                }
            
            searchBar
            Spacer()
        }

    }
    
    private func findCoord(city: String, completion: @escaping (CLLocationCoordinate2D) -> ()) {
        //Primary: Set the coordinates to be within the city
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(city) { (placemarks, error) in
            
            //Will rank cities off of promixity of current location (if there are cities with the same name)
            guard let placemarks = placemarks, let location = placemarks.first?.location else {
            
                //If city does not exist, return no location
                print("No location found for city: \(city)")
                return
            }
            completion(location.coordinate)
            lat = String(format: "%.4f", location.coordinate.latitude)
            lon = String(format: "%.4f", location.coordinate.longitude)
            
        }
    }
    
    private func findTrail(lat: String, lon: String) {

        let request = NSMutableURLRequest(url: NSURL(string: "https://trailapi-trailapi.p.rapidapi.com/trails/explore/?lat=\(lat)&lon=\(lon)")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {print(error)}
            else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse?.statusCode)
            }
            do {
                let decodedData = try JSONDecoder().decode(traildata.self, from: data!)
                
                DispatchQueue.main.async {
                    self.storeData = decodedData
                }
                
                let count = decodedData.data.count
                
                trailNames = []
                trailCity = []
                trailThumbnail = []
                
                if count > 10 {
                    for i in 0...9 {
                        var trail = decodedData.data[i]
                        var coord = CLLocationCoordinate2D(latitude: Double(trail.lat)!, longitude: Double(trail.lon)!)
                        var location = Location(name: trail.name, coordinate: coord)
                        self.markers.append(location)
                        trailNames.append(decodedData.data[i].name)
                        trailCity.append(decodedData.data[i].city)
                        if (decodedData.data[i].thumbnail != nil) {
                            trailThumbnail.append(decodedData.data[i].thumbnail ?? "")
                        }
                        else {
                            trailThumbnail.append("")
                        }
                    }
                }
                else if count < 0 {
                    for i in 0...count-1 {
                        var trail = decodedData.data[i]
                        var coord = CLLocationCoordinate2D(latitude: Double(trail.lat)!, longitude: Double(trail.lon)!)
                        var location = Location(name: trail.name, coordinate: coord)
                        self.markers.append(location)
                        trailNames.append(decodedData.data[i].name)
                        trailCity.append(decodedData.data[i].city)
                        if (decodedData.data[i].thumbnail != nil) {
                            trailThumbnail.append(decodedData.data[i].thumbnail ?? "")
                        }
                        else {
                            trailThumbnail.append("")
                        }
                    }
                }
                print("trailNames", trailNames)
                print("trailCities", trailCity)
                print("trailthumbnail", trailThumbnail)
            } catch let jsonError{
                print("Error parsing JSON \(jsonError)")
            }

        })
        dataTask.resume()
    }
    
    private var searchBar: some View {
        VStack {
            HStack {
                Button {
                    let searchRequest = MKLocalSearch.Request()
                    searchRequest.naturalLanguageQuery = searchText
                    searchRequest.region = region
                    
                    MKLocalSearch(request: searchRequest).start { response, error in
                        guard let response = response else {
                            print("Error: \(error?.localizedDescription ?? "Unknown error)").")
                            return
                        }
                        region = response.boundingRegion
                        markers = response.mapItems.map { item in
                            Location (
                                name: item.name ?? "",
                                coordinate: item.placemark.coordinate
                            )
                        }
                        
                        //Sets coordinates to be the closest result found
                        if let first = response.mapItems.first {
                            //Set to nearest searched coordinates to be displayed
                            lat = String(format: "%.4f", first.placemark.coordinate.latitude)
                            lon = String(format: "%.4f", first.placemark.coordinate.longitude)
                        }
                        findTrail(lat: lat, lon: lon)
                    }
                    
                } label: {
                    VStack {
                        HStack {
                            //Display search button and bar (User must click button to search)
                            Image(systemName: "location.magnifyingglass")
                                .resizable()
                                .foregroundColor(.accentColor)
                                .frame(width: 24, height: 24, alignment: .leading)
                            TextField("Search e.g. Mill Cue Club", text: $searchText)
                        }
                    }
                }
                
            }
            ZStack {
                NavigationView {
                    if let storeData = storeData {
                        List(trailNames.indices, id: \.self) {index in
                            
                            NavigationLink(destination: TrailDetailView(Trail: (storeData.data[index]) )) {
                                
                                HStack{
                                    if let urlString = storeData.data[index].thumbnail, let imageURL = URL(string: urlString) {
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
                                        Text(trailNames[index])
                                            .font(.headline)
                                        Text(trailCity[index])
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                }
                            }
                        }
                    } else {
                        Text("Data is Unavailable for the Following Location")
                            .font(.headline)
                            .padding()
                    }
                }
                .edgesIgnoringSafeArea(.all)
                .navigationViewStyle(.stack)
            }
        }
    }
}

