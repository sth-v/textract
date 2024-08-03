import Foundation
import Vision
import AppKit
import UniformTypeIdentifiers

func printHelp() {
    let helpText = """
    textract: A Swift command line tool for recognizing text in images using macOS's built-in Vision framework.

    Usage:
      textract <path> [options]
      textract --base64-input <base64 image> [options]

    Arguments:
      <path>            The path to an image file or a directory containing image files.
      <base64 image>    A base64-encoded string representing an image.

    Options:
      --file-output      Save recognized text to .txt files with the same base names as the images.
      --print-report     Print lists of processed and skipped files at the end.
      -h, --help, ?      Display this help section.

    Examples:
      1. Process a directory and output recognized text to stdout:
         ./textract /path/to/your/images

      2. Process a single image file and output recognized text to stdout:
         ./textract /path/to/your/image/file

      3. Process a directory and save recognized text to .txt files:
         ./textract /path/to/your/images --file-output

      4. Process a directory, save recognized text to .txt files, and print a report:
         ./textract /path/to/your/images --file-output --print-report

      5. Process a single image file, output recognized text to stdout, and print a report:
         ./textract /path/to/your/image/file --print-report

      6. Process a base64-encoded image string:
         ./textract --base64-input <base64 image>
    """
    print(helpText)
}

func recognizeText(from image: NSImage) -> String? {
    guard let tiffData = image.tiffRepresentation,
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

func processImageFile(_ fileURL: URL, saveToFile: Bool, includeImageFileName:Bool=false) -> (String, Bool) {
    if let image = NSImage(contentsOf: fileURL), let recognizedText = recognizeText(from: image) {
        if saveToFile {
            let textFileURL = fileURL.deletingPathExtension().appendingPathExtension("txt")
            try? recognizedText.write(to: textFileURL, atomically: true, encoding: .utf8)
            print("\(textFileURL.path)")
        } else if includeImageFileName{

            print("\(fileURL.path)\n\(recognizedText)\n")
        }else{
            print("\(recognizedText)\n")
        }
        return (fileURL.path, true)
    } else {
        print("Failed to process \(fileURL.lastPathComponent)")
        return (fileURL.path, false)
    }
}

func processImages(at path: URL, saveToFile: Bool, printReport: Bool) {
    let fileManager = FileManager.default
    var processedFiles = [String]()
    var skippedFiles = [String]()

    if fileManager.fileExists(atPath: path.path) {
        var isDirectory: ObjCBool = false
        fileManager.fileExists(atPath: path.path, isDirectory: &isDirectory)

        if isDirectory.boolValue {
            do {
                let files = try fileManager.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
                for fileURL in files {
                    if isImageFile(url: fileURL) {
                        let (filePath, success) = processImageFile(fileURL, saveToFile: saveToFile, includeImageFileName: true)
                        if success {
                            processedFiles.append(filePath)
                        } else {
                            skippedFiles.append(filePath)
                        }
                    } else {
                        //print("Skipped non-image file \(fileURL.lastPathComponent)")
                        skippedFiles.append(fileURL.path)
                    }
                }
            } catch {
                print("Error processing directory: \(error)")
            }
        } else {
            if isImageFile(url: path) {
                let (filePath, success) = processImageFile(path, saveToFile: saveToFile)
                if success {
                    processedFiles.append(filePath)
                } else {
                    skippedFiles.append(filePath)
                }
            } else {
                //print("The specified file is not an image.")
                skippedFiles.append(path.path)
            }
        }
    } else {
        print("The specified path does not exist.")
    }

    if printReport {
        print("\nProcessed files:")
        for file in processedFiles {
            print(file)
        }

        print("\nSkipped files:")
        for file in skippedFiles {
            print(file)
        }
    }
}

func processBase64Image(_ base64String: String, saveToFile: Bool) {
    guard let imageData = Data(base64Encoded: base64String), let image = NSImage(data: imageData) else {
        print("Invalid base64 image data.")
        return
    }

    if let recognizedText = recognizeText(from: image) {
        if saveToFile {
            let textFileURL = URL(fileURLWithPath: "recognized_text.txt")
            try? recognizedText.write(to: textFileURL, atomically: true, encoding: .utf8)
            print("\(textFileURL.path)")
        } else {
            print("<base64-input>\n\(recognizedText)\n")
        }
    } else {
        print("Failed to recognize text from base64 image.")
    }
}

func main() {
    let arguments = CommandLine.arguments

    guard arguments.count >= 2 else {
        printHelp()
        return
    }

    let firstArg = arguments[1]

    if ["-h", "--help", "?"].contains(firstArg) {
        printHelp()
        return
    }

    let saveToFile = arguments.contains("--file-output")
    let printReport = arguments.contains("--print-report")

    if firstArg == "--base64-input" {
        guard arguments.count >= 3 else {
            print("Usage: textract --base64-input <base64 image> [options]")
            return
        }
        let base64String = arguments[2]
        processBase64Image(base64String, saveToFile: saveToFile)
    } else {
        let directoryURL = URL(fileURLWithPath: firstArg)
        processImages(at: directoryURL, saveToFile: saveToFile, printReport: printReport)
    }
}

main()
