//
//  AttachmentView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 24/2/22.
//
//  Renders an attachment

import SwiftUI
import QuickLook
import DiscordKitCore

struct AttachmentView: View {
    let attachment: Attachment
    @State private var quickLookUrl: URL?

    // Download state
    @State private var downloadProgress = 0.0
    @State private var downloadState: DownloadState = .notStarted
    @State private var dataTask: URLSessionDownloadTask?
    @State private var observation: NSKeyValueObservation?

    public static let mimeFileMapping = [
        // Rich Documents
        "application/pdf": "doc.text.image",
        // Word
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document": "doc.richtext",
        // PowerPoint
        "application/vnd.openxmlformats-officedocument.presentationml.presentation": "doc.text.image",
        // Excel
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet": "chart.bar.doc.horizontal",
        // Plain documents
        "text/plain": "doc.plaintext",
        "text/html": "doc.richtext.fill",
        "application/json": "doc.text",
        // Archives
        "application/gzip": "doc.zipper",
        "application/zip": "doc.zipper",
		// Videos
		"video/mp4": "film",
		"video/quicktime": "film"
    ]

    var fileAttachment: some View {
        GroupBox {
            HStack(alignment: .center, spacing: 4) {
                Image(systemName: Self.mimeFileMapping[attachment.content_type ?? ""] ?? "doc")
                    .font(.system(size: 36))
                    .opacity(0.8)
                VStack(alignment: .leading, spacing: 4) {
                    Text(attachment.filename)
                        .font(.system(size: 15))
                        .fontWeight(.medium)
                        .lineLimit(1)
                    // .fixedSize(horizontal: false, vertical: true)
                    Text("\(attachment.size.humanReadableFileSize()) • \(attachment.filename.fileExtension.uppercased())")
                        .font(.caption)
                        .opacity(0.5)
                }
                Spacer()

                Button {
                    if let url = URL(string: attachment.url) {
                        quickLookUrl = loadFile(from: url)
                    }
                } label: {
                    Image(systemName: "doc.viewfinder.fill").font(.system(size: 20))
                }
                .help("Preview attachment")
                .buttonStyle(.plain)

                ZStack {
                    Button(action: {
                        if let url = URL(string: attachment.url) {
                            downloadFile(from: url)
                        }
                    }) {
                        Image(systemName: downloadState == .error
                            ? "exclamationmark.circle" : downloadState == .success
                            ? "checkmark.circle" : "arrow.down.circle"
                        )
                        .font(.system(size: 20))
                    }
                    .help("Download attachment")
                    .buttonStyle(.plain)

                    CircularProgressView(lineWidth: 4, progress: $downloadProgress)
                        .frame(width: 24, height: 24)
                        .opacity(downloadState == .inProgress ? 1 : 0)
                }
                .padding(.trailing, 4)
            }
        }.frame(width: 400)
    }

    var body: some View {
        // Guard doesn't work in views
        ZStack {
            if let url = URL(string: attachment.proxy_url) {
                let mime = attachment.content_type ?? url.mimeType
                if let width = attachment.width, let height = attachment.height {
                    // This is an image/video
					let (width, height, resizedURL, scale) = getResizedDimens(
						width: Double(width),
						height: Double(height),
						srcURL: url
					)
					if mime == "image/gif" {
						AttachmentGif(width: width, height: height, url: url)
					} else {
						switch mime.prefix(5) {
						case "image":
                            Button {
                                quickLookUrl = url
                            } label: {
                                AttachmentImage(
                                    width: width, height: height, scale: scale,
                                    url: resizedURL
                                )
                            }.buttonStyle(.borderless)
						case "video":
							AttachmentVideo(
                                width: width, height: height, scale: scale,
                                url: url, thumbnailURL: resizedURL.appendingQueryItems(URLQueryItem(name: "format", value: "png"))
                            )
						default: AttachmentError(width: width, height: height)
						}
					}
                } else if mime.prefix(5) == "audio" {
                    AttachmentAudio(attachment: attachment, url: url)
                } else {
                    // Display a generic file
                    fileAttachment
                }
            } else { AttachmentError(width: 160, height: 160) }
        }
        .quickLookPreview($quickLookUrl)
    }
}

private extension AttachmentView {
	/// Resizes image dimensions the way the official client does
	func getResizedDimens(width: Double, height: Double, srcURL: URL) -> (Double, Double, URL, Double) {
		let aspectRatio = Double(attachment.width!) / Double(attachment.height!)
		let resizedH: Double = aspectRatio > 1.3 ? 400 / aspectRatio : 300
		let resizedW: Double = aspectRatio > 1.3 ? 400 : 300 * aspectRatio
		// Check if the resized dimens are larger than the actual dimens
		if width < resizedW*2 && height < resizedH*2 {
			let scale = max(Double(width)/Double(resizedW), 1)
			return (
				Double(width)/scale,
				Double(height)/scale,
				srcURL.setSize(width: Int(width), height: Int(height)),
				scale
			)
		}
		return (
			resizedW,
			resizedH,
			srcURL.setSize(width: Int(resizedW)*2, height: Int(resizedH)*2),
			2
		)
	}
}

// File download/preview
private extension AttachmentView {
	enum DownloadState {
		case notStarted, inProgress, success, error
	}

	static let cacheDateFormatter = DateFormatter()
	static func getShortDateString(from date: Date) -> String {
		cacheDateFormatter.dateFormat = "MMddyyyy"
		return cacheDateFormatter.string(from: date)
	}

	// Loads a file into cache and returns its URL
	func loadFile(from url: URL) -> URL {
		// Cached file destination
		let cachedDirectory = FileManager.default.temporaryDirectory
			.appendingPathComponent(Self.getShortDateString(from: Date.now))

		try? FileManager.default.createDirectory(at: cachedDirectory, withIntermediateDirectories: true)

		let destinationURL = cachedDirectory.appendingPathComponent(
			url.lastPathComponent,
			isDirectory: false
		)

		// Check if cache file exists
		if FileManager.default.fileExists(atPath: destinationURL.path) {
			return destinationURL
		}

		download(url: url, toFile: destinationURL) { error in
			if let error = error { print(error) }
		}
		return destinationURL
	}

	// Specifically for downloading files to the download's folder
	func downloadFile(from url: URL) {
		// Set download state
		downloadProgress = 0
		downloadState = .inProgress

		// Obtain downloads folder
		// Cached file destination
		let cachedDirectory = FileManager.default.temporaryDirectory
			.appendingPathComponent(Self.getShortDateString(from: Date.now))

		try? FileManager.default.createDirectory(at: cachedDirectory, withIntermediateDirectories: true)

		let cachedURL = cachedDirectory
			.appendingPathComponent(
				url.lastPathComponent,
				isDirectory: false
			)

		// Updates the UI with the download's progress
		observation?.invalidate()

		// First downloads file to cache location (for faster quick look)
		// loadFile function is not called because we want to replace the file from source
		download(url: url, toFile: cachedURL) { fileError in
			do {
				if let fileError = fileError { throw fileError }

				let downloadsDirectory = try
				FileManager.default.url(
                    for: .downloadsDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: false
                )

				// Append file name to path
				let destinationURL = downloadsDirectory.appendingPathComponent(url.lastPathComponent)
				if FileManager.default.fileExists(atPath: destinationURL.path) {
					try FileManager.default.removeItem(at: destinationURL)
				}

				// Copy item from cache to destination
				try FileManager.default.copyItem(at: cachedURL, to: destinationURL)

				// Delay setting success state to show the finished progress bar
				DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(500)) {
					downloadState = .success
					downloadProgress = 0
				}
			} catch {
				print(error.localizedDescription)
				downloadState = .error
				downloadProgress = 0
			}
		}
	}

	// Downloads a file from a URL to another URL, with an optional error returned in closure
	// TODO: There might be a cleaner way to deal with errors
	func download(url: URL, toFile file: URL, completion: @escaping (Error?) -> Void) {
		dataTask = URLSession.shared.downloadTask(with: url) { urlOrNil, responseOrNil, errorOrNil in
			do {
				// Exit on error
				if let errorOrNil = errorOrNil {
					throw errorOrNil
				}

				if let response = responseOrNil as? HTTPURLResponse {
					// Exit on bad response
					if !(200...299).contains(response.statusCode) {
						print("Bad Response Code: \(response.statusCode)")
						throw URLError(.badServerResponse)
					}
				} else {
					// Exit on no response
					throw URLError(.cannotParseResponse)
				}

				// File is downloaded to a temporary URL
				guard let tempURL = urlOrNil else { return }

				// If file exists, remove it
				if FileManager.default.fileExists(atPath: file.path) {
					try FileManager.default.removeItem(at: file)
				}

				// Move item to destination
				try FileManager.default.moveItem(at: tempURL, to: file)
				completion(nil)
			} catch {
				completion(error)
			}
		}

		// Keeps track of the progress of the download
		observation = dataTask?.progress.observe(\.fractionCompleted) { observationProgress, _ in
			DispatchQueue.main.async {
				downloadProgress = observationProgress.fractionCompleted
			}
		}

		dataTask?.resume() // Calls the start of the task
	}
}
