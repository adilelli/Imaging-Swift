import UIKit

func saveImageToDocuments(image: UIImage, fileName: String) {
    // Convert image to data
    guard let imageData = image.jpegData(compressionQuality: 1.0) else {
        print("Failed to convert image to data")
        return
    }

    // Get Documents directory
    let fileManager = FileManager.default
    guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
        print("Failed to get Documents directory")
        return
    }

    // Specify file path
    let fileURL = documentsURL.appendingPathComponent(fileName)

    // Write data to file
    do {
        try imageData.write(to: fileURL, options: .atomic)
        print("Image saved successfully at \(fileURL.path)")
    } catch {
        print("Failed to save image: \(error.localizedDescription)")
    }
}

func loadImageFromDocuments(fileName: String) -> UIImage? {
    // Get Documents directory
    let fileManager = FileManager.default
    guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
        print("Failed to get Documents directory")
        return nil
    }

    // Specify file path
    let fileURL = documentsURL.appendingPathComponent(fileName)

    // Load image from file
    return UIImage(contentsOfFile: fileURL.path)
}
