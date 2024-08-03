import Foundation
import Vision
import AppKit
import UniformTypeIdentifiers

func recognizeText(from imageURL: URL) -> String? {
    guard let image = NSImage(contentsOf: imageURL),
          let tiffData = image.tiffRepresentation,
          let ciImage = CIImage(data: tiffData) else {
        return nil
    }

    let requestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
    let request = VNRecognizeTextRequest()

    do {
        try requestHandler.perform([request])
        guard let observations = request.results as? [VNRecognizedTextObservation] else {
            return nil
        }

        let recognizedText = observations.compactMap { observation in
            observation.topCandidates(1).first?.string
        }.joined(separator: "\n")

        return recognizedText
    } catch {
        print("Error recognizing text: \(error)")
        return nil
    }
}

func isImageFile(url: URL) -> Bool {
    let imageTypes: [UTType] = [.jpeg, .png, .tiff, .gif, .bmp, .heic, .heif]
    guard let type = UTType(filenameExtension: url.pathExtension) else {
        return false
    }
    return imageTypes.contains(type)
}

func processImages(in directory: URL) {
    let fileManager = FileManager.default

    do {
        let files = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])

        for fileURL in files {
            if isImageFile(url: fileURL) {
                if let recognizedText = recognizeText(from: fileURL) {
                    let textFileURL = fileURL.deletingPathExtension().appendingPathExtension("txt")
                    try recognizedText.write(to: textFileURL, atomically: true, encoding: .utf8)
                    print("Processed \(fileURL.lastPathComponent)")
                } else {
                    print("Failed to process \(fileURL.lastPathComponent)")
                }
            } else {
                print("Skipped non-image file \(fileURL.lastPathComponent)")
            }
        }
    } catch {
        print("Error processing images: \(error)")
    }
}

func main() {
    let arguments = CommandLine.arguments

    guard arguments.count == 2 else {
        print("Usage: textrecognizer <directory_path>")
        return
    }

    let directoryPath = arguments[1]
    let directoryURL = URL(fileURLWithPath: directoryPath)

    processImages(in: directoryURL)
}

main()