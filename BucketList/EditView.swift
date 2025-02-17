//
//  EditView.swift
//  BucketList
//
//  Created by Denis Evdokimov on 7/19/24.
//


import SwiftUI

struct EditView: View {

    @Environment(\.dismiss) var dismiss

    var onSave: (Location) -> Void
    @State var viewModel: ViewModel
    
    init(viewModel: ViewModel, onSave: @escaping (Location) -> Void) {

       _viewModel = State(initialValue: viewModel)
       self.onSave = onSave

    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Place name", text: $viewModel.name)
                    TextField("Description", text:  $viewModel.description)
                }
                Section("Nearby…") {
                    switch viewModel.loadingState {
                    case .loaded:
                            ForEach(viewModel.pages, id: \.pageid) { page in
                            Text(page.title)
                                .font(.headline)
                            + Text(": ") +
                            Text(page.description)
                                .italic()
                        }
                    case .loading:
                        Text("Loading…")
                    case .failed:
                        Text("Please try again later.")
                    }
                }
            }
            .navigationTitle("Place details")
            .toolbar {
                Button("Save") {
                    var newLocation = viewModel.location
                    newLocation.id = UUID()
                    newLocation.name = viewModel.name
                    newLocation.description = viewModel.description

                    onSave(newLocation)
                    dismiss()
                }
            }
        }
        .task {
            await viewModel.fetchNearbyPlaces()
        }
    }

}

//#Preview {
//    EditView(viewModel: .example) { _ in }
//}
