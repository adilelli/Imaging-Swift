import SwiftUI

struct ContentView: View {
    @State private var isARPageActive = false
    @State private var imageLoaded = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Home Page")
                    .font(.largeTitle)
                    .padding()

                // Fetch Data from API Button
                NavigationLink(destination: APIFetchView()) {
                    Text("Fetch AR")
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .frame(width: 250)
                }
                
                // OCR Button
                NavigationLink(destination: OCRViewPage()) {
                    Text("OCR")
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .frame(width: 250)
                }
                
                NavigationLink(destination: OCRCameraViewPage()) {
                    HStack{
                        Image(systemName: "camera")
                        Text("Camera")
                    }
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .frame(width: 250)
                }
                
//                // AR Page Button
//                NavigationLink(destination: ARViewPage(imageUrls: [
//                    URL(string: "https://miro.medium.com/v2/resize:fit:1200/1*tQBrh1rRDqFLRi9P-PtN9w.jpeg")!,
//                    URL(string: "https://pbs.twimg.com/media/Gaye7qYaAAMwPnD?format=png&name=240x240")!
//                ], imagesLoaded: $imageLoaded), isActive: $isARPageActive) {
//                    Text("Open AR Page")
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                        .frame(width: 250)
//                }
                
                // Cube AR Page Button
                NavigationLink(destination: PostImageView()) {
                    Text("Upload AR Image")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .frame(width: 250)
                }
                
                // Cube AR Page Button
                NavigationLink(destination: ViewCardSwiftUI()) {
                    Text("View Card")
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .frame(width: 250)
                }

//                // Display message once the image is loaded
//                if imageLoaded {
//                    Text("Image Loaded and Ready for Detection!")
//                        .foregroundColor(.green)
//                }

            }
            .navigationTitle("Home")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


