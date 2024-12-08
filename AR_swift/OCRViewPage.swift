import SwiftUI
import Vision

struct OCRViewPage: View {
    @State private var recognizedText: String = ""
    @State private var image: UIImage? = nil
    @State private var showImagePicker: Bool = false
    @State private var isPerformingOCR: Bool = false // For activity indicator

    var body: some View {
        VStack {
            // Image Display Section
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
            } else {
                Text("No image selected")
                    .foregroundColor(.gray)
                    .frame(height: 300)
                    .border(Color.gray, width: 1)
                    .padding(10)
            }

            // Text Recognition Section
            ZStack(alignment: .topLeading) {
                if recognizedText.isEmpty {
                    Text("Recognized text will appear here...")
                        .foregroundColor(.gray)
                        .padding(EdgeInsets(top: 5, leading: 30, bottom: 5, trailing: 30))
                }
                TextEditor(text: $recognizedText)
                    .frame(height: 150)
                    .padding(8)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
            }

            // Buttons Section
            HStack {
                Button("Select Image") {
                    showImagePicker = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                if isPerformingOCR {
                    ProgressView()
                        .padding()
                } else if image != nil {
                    Button("Perform OCR") {
                        if let image = image {
                            performOCR(on: image)
                        }
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
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

            Spacer()
        }
        .padding()
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: .photoLibrary) { pickedImage in
                self.image = pickedImage
                self.recognizedText = "" // Clear previous text
            }
        }
        .navigationTitle("OCR")
    }
    
    struct ImagePicker: UIViewControllerRepresentable {
        var sourceType: UIImagePickerController.SourceType
        var onImagePicked: (UIImage) -> Void

        func makeUIViewController(context: Context) -> UIImagePickerController {
            let picker = UIImagePickerController()
            picker.sourceType = sourceType
            picker.delegate = context.coordinator
            return picker
        }

        func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

        func makeCoordinator() -> Coordinator {
            Coordinator(onImagePicked: onImagePicked)
        }

        class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
            var onImagePicked: (UIImage) -> Void

            init(onImagePicked: @escaping (UIImage) -> Void) {
                self.onImagePicked = onImagePicked
            }

            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
                if let image = info[.originalImage] as? UIImage {
                    onImagePicked(image)
                }
                picker.dismiss(animated: true)
            }

            func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                picker.dismiss(animated: true)
            }
        }
    }

    // Perform OCR Method
    func performOCR(on inputImage: UIImage) {
        guard let cgImage = inputImage.cgImage else {
            print("Failed to convert UIImage to CGImage.")
            return
        }

        isPerformingOCR = true

        let request = VNRecognizeTextRequest { request, error in
            DispatchQueue.main.async {
                self.isPerformingOCR = false
            }

            if let error = error {
                print("OCR Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.recognizedText = "OCR Error: \(error.localizedDescription)"
                }
                return
            }

            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                print("No text recognized.")
                DispatchQueue.main.async {
                    self.recognizedText = "No text recognized."
                }
                return
            }

            let recognizedStrings = observations.compactMap { $0.topCandidates(1).first?.string }
            DispatchQueue.main.async {
                if recognizedStrings.isEmpty {
                    self.recognizedText = "No text found in image."
                } else {
                    self.recognizedText = recognizedStrings.joined(separator: "\n")
                }
            }
        }

        request.recognitionLevel = .accurate

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("Failed to perform OCR: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.recognizedText = "Failed to perform OCR: \(error.localizedDescription)"
                }
            }
        }
    }
}
