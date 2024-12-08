import SwiftUI
import Vision
import AVFoundation

struct OCRCameraViewPage: View {
    @State private var recognizedText: String = ""
    @State private var image: UIImage? = nil
    @State private var showImagePicker = false
    @State private var isPerformingOCR = false // For activity indicator

    var body: some View {
        VStack {
            // Image Display Section
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .padding(30)
            } else {
                Text("No image selected")
                    .foregroundColor(.gray)
                    .frame(width: 200, height: 300)
                    .border(Color.gray, width: 1)
                    .padding(10)
            }

            // Text Recognition Section
            ZStack(alignment: .topLeading) {
                if recognizedText.isEmpty {
                    Text("Recognized text will appear here...")
                        .foregroundColor(.gray)
                        .padding(30)
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
                Button(action: {
                    showImagePicker = true // Trigger your action here
                }) {
                    Image(systemName: "camera")
                        .font(.title) // Optional: Set the size of the icon
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

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
                    
                    // Save Text button
                    Button("Save") {
                        saveRecognizedText()
                    }
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }

            Spacer()
        }
        .padding()
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: .camera) { pickedImage in
                self.image = pickedImage
                self.recognizedText = "" // Clear previous text
            }
        }
        .navigationTitle("OCR")
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }

    // Image Picker Component
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

    // Perform OCR on the selected image
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
    
    func saveRecognizedText() {
        guard !recognizedText.isEmpty else {
            print("No text to save.")
            return
        }
        
//        let fileName = "RecognizedText.txt"
//        let fileManager = FileManager.default
//        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
//        let fileURL = documentDirectory?.appendingPathComponent(fileName)
        
        do {
            print("Text saved")
            print(self.recognizedText)
        }
    }
}

extension UIApplication {
    func endEditing() {
        self.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
