//
//  AttachmentView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 24/2/22.
//
//  Renders one attachment

import SwiftUI
import AVKit
import CachedAsyncImage
import QuickLook
import DiscordKit

struct AttachmentError: View {
    let height: Int
    let width: Int
    
    var body: some View {
        Image(systemName: "exclamationmark.square")
            .font(.system(size: CGFloat(min(width, height) - 10)))
            .frame(width: CGFloat(width), height: CGFloat(height), alignment: .center)
    }
}

struct AttachmentLoading: View {
    let height: Int
    let width: Int
    
    var body: some View {
		Rectangle()
			.fill(.gray.opacity(Double.random(in: 0.15...0.3)))
			.frame(width: CGFloat(width), height: CGFloat(height), alignment: .center)
    }
}

struct AttachmentImage: View {
    let height: Int
    let width: Int
    let scale: Double
    let url: URL
    
    var body: some View {
        CachedAsyncImage(url: url, scale: scale) { phase in
            if let image = phase.image {
                image.resizable().scaledToFill()
            } else if phase.error != nil {
                AttachmentError(height: height, width: width)
            } else {
                AttachmentLoading(height: height, width: width)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .frame(idealWidth: CGFloat(width), idealHeight: CGFloat(height))
        .fixedSize()
    }
}

struct AudioAttachmentView: View {
    let attachment: Attachment
    let url: URL
    
    @EnvironmentObject var audioManager: AudioCenterManager
    @EnvironmentObject var serverCtx: ServerContext
    
    private func queueSong() {
        audioManager.append(
            source: url,
            filename: attachment.filename,
            from: "\(serverCtx.guild!.name) > #\(serverCtx.channel?.name ?? "")"
        )
    }
    
    var body: some View {
        GroupBox {
            HStack() {
                VStack(alignment: .leading, spacing: 4) {
                    Text(attachment.filename)
                        .font(.system(size: 15))
                        .fontWeight(.medium)
                        .truncationMode(.middle)
                        .lineLimit(1)
                    Text("\(attachment.size.humanReadableFileSize()) • \(attachment.filename.fileExtension.uppercased())")
                        .font(.caption)
                        .opacity(0.5)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Button { queueSong() } label: {
                    Image(systemName: "text.append").font(.system(size: 18))
                }.buttonStyle(.plain).help("Append to queue")
                
                Button {
                    queueSong()
                    audioManager.playQueued(index: 0)
                } label: {
                    Image(systemName: "play.fill").font(.system(size: 20)).frame(width: 36, height: 36)
                }
                .buttonStyle(.plain)
                .background(Circle().fill(Color.accentColor))
                .help("Play now")
            }.padding(4)
        }.frame(width: 400)
    }
}

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
        "application/zip": "doc.zipper"
    ]
    
    private func getResizedDimens(width: Int, height: Int, srcURL: URL) -> (Int, Int, URL, Double) {
        let aspectRatio = Double(attachment.width!) / Double(attachment.height!)
        let h = aspectRatio > 1.3 ? Int(400 / aspectRatio) : 300
        let w = aspectRatio > 1.3 ? 400 : Int(300 * aspectRatio)
        if width < w*2 && height < h*2 {
            let scale = max(Double(width)/Double(w), 1)
            return (
                Int(Double(width)/scale),
                Int(Double(height)/scale),
                getURLWithResizedDimens(mediaURL: srcURL, width: width, height: height),
                scale
            )
        }
        return (w, h, getURLWithResizedDimens(mediaURL: srcURL, width: w*2, height: h*2), 2)
    }
    
    private func getURLWithResizedDimens(mediaURL: URL, width: Int?, height: Int?) -> URL {
        var oURL = URLComponents(url: mediaURL, resolvingAgainstBaseURL: true)!
		if let width = width, let height = height {
			oURL.queryItems = [
				URLQueryItem(name: "width", value: String(width)),
				URLQueryItem(name: "height", value: String(height))
			]
		} else {
			oURL.queryItems = []
		}
        return oURL.url!
    }
    
    var body: some View {
        // Guard doesn't work in views
        ZStack {
            if let url = URL(string: attachment.proxy_url) {
                let mime = attachment.content_type ?? url.mimeType
                if let width = attachment.width, let height = attachment.height {
                    // This is an image/video
                    let (width, height, resizedURL, scale) = getResizedDimens(width: width, height: height, srcURL: url)
                    switch mime.prefix(5) {
                    case "image":
                        AttachmentImage(height: height, width: width, scale: scale, url: resizedURL)
                            .onTapGesture { quickLookUrl = url }
                    case "video":
                        VideoPlayer(player: AVPlayer(url: url)) // Don't use resizedURL
                            .frame(width: CGFloat(width), height: CGFloat(height))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    default: EmptyView()
                    }
                } else if mime.prefix(5) == "audio" {
                    AudioAttachmentView(attachment: attachment, url: url)
                } else {
                    // Display a generic file
                    GroupBox {
                        HStack(alignment: .center, spacing: 4) {
                            Image(systemName: AttachmentView.mimeFileMapping[attachment.content_type ?? ""] ?? "doc")
                                .font(.system(size: 36))
                                .opacity(0.8)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(attachment.filename)
                                    .font(.system(size: 15))
                                    .fontWeight(.medium)
                                    .lineLimit(1)
                                //.fixedSize(horizontal: false, vertical: true)
                                Text("\(attachment.size.humanReadableFileSize()) • \(attachment.filename.fileExtension.uppercased())")
                                    .font(.caption)
                                    .opacity(0.5)
                            }
                            Spacer()
                            
                            Button(action: {
                                if let url = URL(string: attachment.url) {
                                    quickLookUrl = loadFile(from: url)
                                }
                            }) {
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
                                    Image(systemName:
                                            downloadState == .error ?  "exclamationmark.circle" :
                                            downloadState == .success ? "checkmark.circle" : "arrow.down.circle"
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
            }
            else { AttachmentError(height: 160, width: 160) }
        }
        .quickLookPreview($quickLookUrl)
    }
    
    // Loads a file into cache and returns its URL
    private func loadFile(from url: URL) -> URL {
        // Cached file destination
        let cachedDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(getShortDateString(from: Date.now))
        
        try? FileManager.default.createDirectory(at: cachedDirectory, withIntermediateDirectories: true)
        
        let destinationURL = cachedDirectory
            .appendingPathComponent(
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
    private func downloadFile(from url: URL) {
        // Set download state
        downloadProgress = 0
        downloadState = .inProgress
        
        // Obtain downloads folder
        // Cached file destination
        let cachedDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(getShortDateString(from: Date.now))
        
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
                FileManager.default.url(for: .downloadsDirectory,
                                        in: .userDomainMask,
                                        appropriateFor: nil,
                                        create: false)
                
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
    private func download(url: URL, toFile file: URL, completion: @escaping (Error?) -> ()) {
        
        dataTask = URLSession.shared.downloadTask(with: url) {
            urlOrNil, responseOrNil, errorOrNil in
            
            do {
                // Exit on error
                if let errorOrNil = errorOrNil {
                    throw errorOrNil
                }
                
                if let response = responseOrNil as? HTTPURLResponse  {
                    // Exit on bad response
                    if !(200...299).contains(response.statusCode) {
                        print("Bad Response Code: \(response.statusCode)")
                        throw URLError(.badServerResponse)
                        
                    }
                }
                else {
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

struct AttachmentView_Previews: PreviewProvider {
    static var previews: some View {
        // AttachmentView()
        EmptyView()
    }
}

enum DownloadState {
    case notStarted, inProgress, success, error
}

func getShortDateString(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMddyyyy"
    return formatter.string(from: date)
}
