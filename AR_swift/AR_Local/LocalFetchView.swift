//
//  LocalFetchView.swift
//  AR_swift
//
//  Created by Adil Elli on 05/01/2025.
//

import SwiftUI

// View to display API data
struct LocalFetchView: View {
    @State private var files: [URL] = [] // Array of filenames
    @State private var displayFiles: [String] = []
    @State private var isLoading = true
    @State private var isARPageActive = false
    @State private var imageLoaded = false
    
    var body: some View {
        VStack {
            // AR Page Button
            NavigationLink(destination: ARViewLocalPage( imagesLoaded: $imageLoaded, files:displayFiles), isActive: $isARPageActive) {
                Text("Open AR Page")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .frame(width: 250)
            }
            
            if isLoading {
                ProgressView("Loading data...")
            } else if displayFiles.isEmpty {
                Text("No files found.")
                    .font(.headline)
                    .foregroundColor(.gray)
            } else {
                List(displayFiles, id: \.self) { displayFile in
                    Text(displayFile)
                        .font(.headline)
                }
            }
        }
        .navigationTitle("API Data")
        .onAppear(perform: fetchDataLocally)
    }
    
    func fetchDataLocally() {
        // Access the app's document directory
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to access documents directory.")
            return
        }
        
        do {
            // Get all files in the documents directory
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
            
            // Filter out non-image files (if necessary)
            let imageFiles = fileURLs.filter { $0.pathExtension == "png" || $0.pathExtension == "jpg" }
            
            // Map files to FileItem instances (or any model you're using)
            let fileItems = imageFiles.map { url -> FileItem in
                let fileName = url.lastPathComponent
                return FileItem(fileName: fileName)
            }
            
            DispatchQueue.main.async {
                // Update the UI
                self.displayFiles = fileItems.map { $0.fileName }
                self.isLoading = false
            }
            
            print("Local Files: \(fileItems)")
        } catch {
            print("Error fetching local files: \(error.localizedDescription)")
        }
    }
    
    
    
    
    struct APIFetchView_Previews: PreviewProvider {
        static var previews: some View {
            APIFetchView()
        }
    }
}
