//
//  AttachmentView.swift
//  Native Discord
//
//  Created by Vincent Kwok on 24/2/22.
//

import SwiftUI
import AVKit

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
        ZStack {
            Image(systemName: "square.text.square")
                .opacity(0.5)
                .font(.system(size: CGFloat(min(width, height) - 10)))
            ProgressView().progressViewStyle(.circular).controlSize(.large)
        }
        .frame(width: CGFloat(width), height: CGFloat(height), alignment: .center)
    }
}

struct AttachmentView: View {
    let attachment: Attachment
    @State private var enlarged = false
    
    private let mimeFileMapping = [
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
    
    var body: some View {
        // Guard doesn't work in views
        ZStack {
            if let url = URL(string: attachment.url) {
                if attachment.width != nil && attachment.height != nil {
                    // This is an image/video
                    let aspectRatio = Double(attachment.width!) / Double(attachment.height!)
                    let height = aspectRatio > 1.3 ? Int(400 / aspectRatio) : 300
                    let width = aspectRatio > 1.3 ? 400 : Int(300 * aspectRatio)
                    switch attachment.content_type?.prefix(5) {
                    case "image":
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image.resizable().scaledToFill()
                            } else if phase.error != nil {
                                AttachmentError(height: height, width: width)
                            } else {
                                AttachmentLoading(height: height, width: width)
                            }
                        }
                        .frame(width: CGFloat(width), height: CGFloat(height))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .onTapGesture { enlarged = true }
                    case "video":
                        VideoPlayer(player: AVPlayer(url: url))
                            .frame(width: CGFloat(width), height: CGFloat(height))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    default: EmptyView()
                    }
                }
                else if attachment.content_type?.prefix(5) == "audio" {
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(attachment.filename)
                                .font(.system(size: 15))
                                .fontWeight(.medium)
                                .lineLimit(1)
                            Text("\(attachment.size.humanReadableFileSize()) • \(attachment.filename.fileExtension.uppercased())")
                                .font(.caption)
                                .opacity(0.5)
                        }
                        .padding(.top, 8)
                        .padding([.leading, .trailing], 12)
                        VideoPlayer(player: AVPlayer(url: url))
                            .frame(maxWidth: .infinity, maxHeight: 42)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .frame(width: 400)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.gray.opacity(0.2), lineWidth: 1)
                    )
                }
                else {
                    // Display a generic file
                    GroupBox {
                        HStack(alignment: .center, spacing: 4) {
                            Image(systemName: mimeFileMapping[attachment.content_type ?? ""] ?? "doc")
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
                            Button(action: {}) {
                                Image(systemName: "arrow.down.circle")
                                    .font(.system(size: 20))
                            }
                            .help("Download attachment")
                            .buttonStyle(.plain)
                            .padding(.trailing, 4)
                        }
                    }.frame(width: 400)
                }
            }
            else { AttachmentError(height: 160, width: 160) }
        }
    }
}

struct AttachmentView_Previews: PreviewProvider {
    static var previews: some View {
        // AttachmentView()
        EmptyView()
    }
}
