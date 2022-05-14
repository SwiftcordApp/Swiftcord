//
//  MessageInputView.swift
//  Native Discord
//
//  Created by Vincent Kwok on 24/2/22.
//

import SwiftUI

struct MessageAttachmentView: View {
    let attachment: URL
    
    var body: some View {
        GroupBox {
            VStack() {
                Spacer()
                Image(systemName: AttachmentView.mimeFileMapping[attachment.mimeType()] ?? "doc")
                    .font(.system(size: 84))
                Spacer()
                Text(try! attachment.resourceValues(forKeys: [URLResourceKey.nameKey]).name!)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }.frame(width: 150, height: 150)
    }
}

struct MessageInputView: View {
    let placeholder: String
    @Binding var message: String
    @State private var attachments: [URL] = []
    let onSend: (String, [URL]) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !attachments.isEmpty {
                ScrollView([.horizontal]) {
                    HStack {
                        ForEach(attachments, id: \.absoluteURL) { item in
                            MessageAttachmentView(attachment: item)
                        }
                    }.padding(16)
                }.fixedSize(horizontal: false, vertical: true)
                Divider()
            }
            
            HStack(alignment: .center, spacing: 14) {
                Button {
                    let panel = NSOpenPanel()
                    panel.allowsMultipleSelection = false
                    panel.canChooseDirectories = false
                    panel.treatsFilePackagesAsDirectories = true
                    panel.beginSheetModal(for: NSApp.mainWindow!, completionHandler: { num in
                        if num == NSApplication.ModalResponse.OK {
                            guard let size = try? panel.url?.resourceValues(forKeys: [URLResourceKey.fileSizeKey]).fileSize, size < 8*1024*1024 else {
                                print("file too big")
                                return
                            }
                            
                            guard !attachments.contains(panel.url!) else { return }
                            withAnimation { attachments.append(panel.url!) }
                        } else {
                            print("nothing chosen")
                        }
                    })
                } label: { Image(systemName: "plus").font(.system(size: 20)) }
                    .buttonStyle(.plain)
                    .padding(.leading, 15)
            
                TextEditor(text: $message)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                    .lineSpacing(4)
                    .font(.system(size: 16))
                    .lineLimit(4)
                    .disableAutocorrection(false)
                    .padding([.top, .bottom], 12)
                    .overlay(alignment: .leading) {
                        if message.isEmpty {
                            Text(placeholder)
                                .padding([.leading, .trailing], 4)
                                .opacity(0.5)
                                .font(.system(size: 16, weight: .light))
                                .allowsHitTesting(false)
                        }
                    }
                    .onChange(of: message) { content in
                        guard !content.isEmpty && content.last!.isNewline else { return }
                        onSend(content, attachments)
                    }
                

                Button(action: { onSend(message, attachments) }) {
                    Image(systemName: "arrow.up").font(.system(size: 20))
                }
                .buttonStyle(.plain)
                .padding(.trailing, 15)
            }
        }
        .frame(minHeight: 40)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                .background(RoundedRectangle(cornerRadius: 7)
                    .fill(Color(NSColor.textBackgroundColor)))
                .shadow(color: .gray.opacity(0.2), radius: 3)
        )
        .padding(.horizontal, 16)
        .offset(y: -24)
    }
}

struct MessageInputView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
