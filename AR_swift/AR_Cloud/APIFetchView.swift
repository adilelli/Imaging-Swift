import SwiftUI

// Model for the fetched data
struct FileItem: Codable, Identifiable {
    let id = UUID() // Generate unique ID for each item
    let fileName: String // File name from the server
    
    enum CodingKeys: String, CodingKey {
        case fileName = "files"
    }
}

// Define the Codable structures to parse the JSON
struct ApiResponse: Codable {
    let response: String
    let viewModel: [ViewModel]
    let status: Bool
}

struct ViewModel: Codable {
    let id: String
    let name: String
    let description: String

    // Map "_id" to "id" for better usability
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, description
    }
}

// View to display API data
struct APIFetchView: View {
    @State private var files: [URL] = [] // Array of filenames
    @State private var displayFiles: [String] = []
    @State private var isLoading = true
    @State private var isARPageActive = false
    @State private var imageLoaded = false

    var body: some View {
        VStack {
            // AR Page Button
            NavigationLink(destination: ARViewPage( imagesLoaded: $imageLoaded, files:displayFiles), isActive: $isARPageActive) {
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
        .onAppear(perform: fetchData)
    }

    // Function to fetch data from API
//    func fetchData() {
//        guard let url = URL(string: "https://f3df-219-92-198-46.ngrok-free.app/uploads") else {
//            print("Invalid URL.")
//            return
//        }
//
//        // Create the URLSession task
//        let task = URLSession.shared.dataTask(with: url) { data, response, error in
//            // Handle errors
//            if let error = error {
//                print("Error: \(error.localizedDescription)")
//                return
//            }
//            
//            // Ensure there's valid response data
//            guard let data = data else {
//                print("No data received.")
//                return
//            }
//            
//            // Parse the JSON
//            if let jsonData = data(using: .utf8) {
//                do {
//                    // Parse the JSON
//                    if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
//                        // Access values
//                        if let viewModel = json["viewModel"] as? [[String: Any]] {
//                            let files = viewModel.compactMap { $0["name"] as? String }
//                            let fileURLs = files.map {  URL(string: url.appendingPathComponent($0).absoluteString)!}
//                            let fileStr = files.map{ url.appendingPathComponent($0).absoluteString }
//                            DispatchQueue.main.async {
//                                self.files = fileURLs
//                                self.displayFiles = files
//                                self.isLoading = false
//                            }
//                            print("Names: \(files)")
//                        }
//                    }
//                } catch {
//                    print("Failed to parse JSON: \(error)")
//                    DispatchQueue.main.async {
//                        self.isLoading = false
//                    }
//                }
//            }
//            
////            // Parse the JSON response
////            do {
////                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
////                   let files = json["viewModel"] as? [String] {
////                    let fileURLs = files.map {  URL(string: url.appendingPathComponent($0).absoluteString)!}
////                    let fileStr = files.map{ url.appendingPathComponent($0).absoluteString }
////                    DispatchQueue.main.async {
////                        self.files = fileURLs
////                        self.displayFiles = files
////                        self.isLoading = false
////                    }
////                } else {
////                    print("Invalid JSON format or missing 'files' key.")
////                    DispatchQueue.main.async {
////                        self.isLoading = false
////                    }
////                }
////            } catch {
////                print("Error parsing JSON: \(error.localizedDescription)")
////                DispatchQueue.main.async {
////                    self.isLoading = false
////                }
////            }
//        }
//
//        // Start the task
//        task.resume()
//    }
    
    func fetchData() {
        guard let url = URL(string: "https://743d-219-92-198-46.ngrok-free.app/uploads") else {
            print("Invalid URL.")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }

            guard let data = data else {
                print("No data received.")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }

            do {
                // Decode the JSON response
                let apiResponse = try JSONDecoder().decode(ApiResponse.self, from: data)
                let viewModel = apiResponse.viewModel

                // Extract file names
                let names = viewModel.map { $0.name }
                let files = names.map { url.appendingPathComponent($0) }
                let fileStr = files.map { $0.absoluteString }

                DispatchQueue.main.async {
                    // Assuming you have these properties to update your UI
                    self.displayFiles = names
                    self.isLoading = false
                }

                print("Names: \(names)")
                print("File URLs: \(fileStr)")
            } catch {
                print("Failed to parse JSON: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }

        task.resume()
    }


}



struct APIFetchView_Previews: PreviewProvider {
    static var previews: some View {
        APIFetchView()
    }
}
