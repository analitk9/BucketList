//
//  ContentView.swift
//  BucketList
//
//  Created by Denis Evdokimov on 7/18/24.
//

import SwiftUI
import MapKit

struct ContentView: View {
    let startPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 56, longitude: -3),
            span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
        )
    )
    @State private var locations = [Location]()
    @State private var selectedPlace: Location?
    @State private var isHybrid = false
    @State private var viewModel = ViewModel()
    var body: some View {
        
        if viewModel.isUnlocked {
            ZStack {
                MapReader { proxy in
                    Map(initialPosition: startPosition){
                        ForEach(locations) { location in
                            Annotation(location.name, coordinate: location.coordinate) {
                                Image(systemName: "star.circle")
                                    .resizable()
                                    .foregroundStyle(.red)
                                    .frame(width: 44, height: 44)
                                    .background(.white)
                                    .clipShape(.circle)
                                    .onLongPressGesture {
                                        selectedPlace = location
                                    }
                            }
                        }
                    }
                    .mapStyle( isHybrid ? .hybrid : .standard)
                    .onTapGesture { position in
                        if let coordinate = proxy.convert(position, from: .local) {
                            viewModel.addLocation(at: coordinate)
                        }
                    }
                }
                VStack {
                    HStack {
                        Spacer()
                        Toggle(isOn: $isHybrid) {
                            HStack {
                                Spacer()
                                Text("Hybrid")
                            }
                            }
                    }.padding()
                    Spacer()
                }
            }
            .alert(isPresented: $viewModel.isShowError) {
                            Alert(title: Text("Ошибка авторизавции"),
                                  message: Text(viewModel.errorDescription),
                                  dismissButton: .default(Text("ОК")))
                        }
            .sheet(item: $selectedPlace) { place in
                EditView(viewModel: EditView.ViewModel(location: place)) {
                    viewModel.update(location: $0)
                }
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
