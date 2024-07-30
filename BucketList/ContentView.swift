//
//  ContentView.swift
//  BucketList
//
//  Created by Ayrton Parkinson on 2024/07/28.
//

import LocalAuthentication
import MapKit
import SwiftUI

struct ContentView: View {
    @State private var viewModel = ViewModel()
    @State private var mapStyle = MapStyle.standard
    @State private var showingMapStyle = false
    
    let startPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 56, longitude: -3),
            span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
        )
    )

    var body: some View {
        if viewModel.isUnlocked {
            ZStack(alignment: .topTrailing) {
                MapReader { proxy in
                    Map(initialPosition: startPosition) {
                        ForEach(viewModel.locations) { location in
                            Annotation(location.name, coordinate: location.coordinate) {
                                Image(systemName: "star.circle")
                                    .resizable()
                                    .foregroundStyle(.red)
                                    .frame(width: 44, height: 44)
                                    .background(.white)
                                    .clipShape(.circle)
                                    .onLongPressGesture {
                                        viewModel.selectedPlace = location
                                    }
                            }
                        }
                    }
                    .mapStyle(mapStyle)
                    .onTapGesture { position in
                        if let coordinate = proxy.convert(position, from: .local) {
                            viewModel.addLocation(at: coordinate)
                        }
                    }
                    .sheet(item: $viewModel.selectedPlace) { place in
                        EditView(location: place) {
                            viewModel.update(location: $0)
                        }
                    }
                    .confirmationDialog("Select map style", isPresented: $showingMapStyle) {
                        Button("Standard") { mapStyle = .standard }
                        Button("Imagery") { mapStyle = .imagery }
                        Button("Hybrid") { mapStyle = .hybrid }
                    }
                }
                Button {
                    showingMapStyle = true
                } label: {
                    Image(systemName: "map.fill")
                        .padding()
                        .background(.white)
                        .clipShape(.circle)
                }
                .padding(.trailing)
            }
        } else {
            Button("Unlock Places", action: viewModel.authenticate)
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(.capsule)
        }
    }
}

#Preview {
    ContentView()
}
