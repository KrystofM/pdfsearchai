//
//  ContentView.swift
//  ViewAI
//
//  Created by Krystof Mitka on 5/1/23.
//

import SwiftUI
import PDFKit
import Combine
import OpenAI


struct AppView: View {
    @Binding var pdf: PDFReadWrite
    @State var nextDestination: PDFDestination?
    @State var selectedOutline: PDFOutline?
    @State var searchText: String = ""
    let searchTextPublisher = PassthroughSubject<String, Never>()
    @State var searchResults: [PDFSelection] = []
    @State var selectedSelection: PDFSelection?
    @StateObject var viewModel: AppViewModel
    @StateObject var chatStore: ChatStore
    @AppStorage("openAIKey") var openAIKey: String = ""
    
    @Environment(\.idProviderValue) var idProvider
    @Environment(\.dateProviderValue) var dateProvider
    
    init(pdf: Binding<PDFReadWrite>, idProvider: @escaping () -> String, dateProvider: @escaping () -> Date, openAIKey: Binding<String>) {
        _pdf = pdf
        _viewModel = StateObject(
            wrappedValue: AppViewModel(pdf: pdf.wrappedValue, openAIKey: openAIKey.wrappedValue)
        )
        _chatStore = StateObject(
            wrappedValue: ChatStore(
                idProvider: idProvider,
                dateProvider: dateProvider,
                openAPIKey: openAIKey.wrappedValue
            )
        )
    }
    
    var body: some View {
        NavigationSplitView {
            if searchText.isEmpty {
                ContentTable(document: pdf.document, selectedOutline: $selectedOutline)
                    .onChange(of: selectedOutline) {
                        nextDestination = $0?.destination ?? nextDestination
                    }
            } else {
                Text("Search results:")
                SearchResults(
                    searchResults: searchResults,
                    selectedSelection: $selectedSelection
                )
                    .onChange(of: selectedSelection) { newValue in
                nextDestination = selectedSelection?.destination ?? nextDestination
                    }
            }
        } content: {
            ChatView(chatStore: chatStore, embedStore: viewModel) { selection in
                print("this was clicked")
                nextDestination = selection.destination
                pdf.document.annotateSearchResults([selection])
            }
                .frame(width: 350)
        } detail: {
            PDFViewWrapper(document: pdf.document, pdfDestination: nextDestination)
        }
        .searchable(text: $searchText, placement: .toolbar, prompt: viewModel.isEmbeddingLoaded ? "Search in document" : "Loading embeddings...")
        .onChange(of: searchText) { searchText in
            if !searchText.isEmpty && viewModel.isEmbeddingLoaded  {
                searchTextPublisher.send(searchText)
            } else {
                pdf.document.removeSearchResults()
            }
        }
        .onReceive(searchTextPublisher.debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)) { debouncedSearchText in
            Task {
                print("Search")
                self.searchResults = try! await viewModel.embeddedDocument?.searchDocument(query: debouncedSearchText) ?? []
                pdf.document.removeSearchResults()
                pdf.document.annotateSearchResults(searchResults)
                selectedSelection = searchResults[0]
            }
        }
        .onChange(of: openAIKey) { newKey in
            print(newKey)
            
            viewModel.updateOpenAIKey(newKey)
            chatStore.updateOpenAIKey(newKey)
        }
        .navigationTitle("ViewAI")
        .task {
            await viewModel.loadEmbedding()
        }
    }
    
}
