//
//  UploadARImageLocal.swift
//  AR_swift
//
//  Created by Adil Elli on 05/01/2025.
//

import SwiftUI
import UIKit

struct PostImageViewLocal: View {
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var isSubmitting = false
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
//                 Text Field for Name
                TextField("Enter your name", text: $name)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                
                TextField("Enter your name", text: $description)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                
                // Display Selected Image
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(8)
                } else {
                    Text("No image selected")
                        .foregroundColor(.gray)
                }
                
                // Buttons for Image Selection
                HStack {
                    Button(action: {
                        showImagePicker = true
                    }) {
                        Text("Select Image")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        showCamera = true
                    }) {
                        Text("Take Photo")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }

                // Submit Button
                // Save Text button
                Button("Save") {
                    submitForm()
                }
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(isSubmitting || selectedImage == nil )

                // Error Message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
            .navigationTitle("Post Image")
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(sourceType: .photoLibrary) { image in
                    selectedImage = image
                }
            }
            .sheet(isPresented: $showCamera) {
                ImagePicker(sourceType: .camera) { image in
                    selectedImage = image
                }
            }
        }
    }
    
    // Submit Form
    func submitForm() {
        print("Run Start")
        guard let image = selectedImage else { return }
        isSubmitting = true
        errorMessage = nil
        print(isSubmitting)
        
        // Convert UIImage to Data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            errorMessage = "Failed to process image."
            isSubmitting = false
            return
        }
        
        // Get the Documents directory
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            errorMessage = "Unable to access documents directory."
            isSubmitting = false
            return
        }
        
        // Create a unique file name
        let fileName = "image_\(UUID().uuidString).jpg"
        let fileURL = documentsURL.appendingPathComponent(fileName)
        
        do {
            // Save the image data to the file
            try imageData.write(to: fileURL)
            print("File saved to: \(fileURL)")
            
            // Update UI to indicate success
            DispatchQueue.main.async {
                isSubmitting = false
                name = ""
                selectedImage = nil
                errorMessage = "Successfully saved image locally at \(fileURL.path)"
            }
        } catch {
            print("Error saving file: \(error)")
            DispatchQueue.main.async {
                isSubmitting = false
                errorMessage = "Error saving file: \(error.localizedDescription)"
            }
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

}
