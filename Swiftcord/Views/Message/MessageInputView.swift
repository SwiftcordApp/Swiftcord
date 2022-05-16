//
//  MessageInputView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 24/2/22.
//

import SwiftUI

struct MessageAttachmentView: View {
    let attachment: URL
	let onRemove: () -> Void
    
    var body: some View {
        GroupBox {
            VStack(spacing: 0) {
                let mime = attachment.mimeType()
                if mime.prefix(5) == "image" {
                    AsyncImage(url: attachment) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 140, height: 120)
                            .cornerRadius(2)
                            .clipped()
                    } placeholder: { ProgressView() }
                } else {
                    Spacer()
                    Image(systemName: AttachmentView.mimeFileMapping[mime] ?? "doc")
                        .font(.system(size: 84))
                }
                Spacer(minLength: 0)
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
	@State private var inhibitingSend = false
	@State private var showingAttachmentErr = false
	@State private var attachmentErr = ""
    let onSend: (String, [URL]) -> Void
    
    private func send() {
        guard message.hasContent() || !attachments.isEmpty else { return }
        onSend(message, attachments)
        withAnimation { attachments.removeAll() }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !attachments.isEmpty {
                ScrollView([.horizontal]) {
                    HStack {
                        ForEach(attachments, id: \.absoluteURL) { item in
							MessageAttachmentView(attachment: item) {
								
							}
                        }
                    }.padding(16)
                }.fixedSize(horizontal: false, vertical: true)
                Divider()
            }
            
            HStack(alignment: .center, spacing: 17) {
                Button {
                    let panel = NSOpenPanel()
                    panel.allowsMultipleSelection = false
                    panel.canChooseDirectories = false
                    panel.treatsFilePackagesAsDirectories = true
                    panel.beginSheetModal(for: NSApp.mainWindow!, completionHandler: { num in
                        if num == NSApplication.ModalResponse.OK {
                            guard let size = try? panel.url?.resourceValues(forKeys: [URLResourceKey.fileSizeKey]).fileSize, size < 8*1024*1024 else {
                                attachmentErr = "That file's too huge! Choose something that's <= 8MiB."
								showingAttachmentErr = true
                                return
                            }
                            
                            guard !attachments.contains(panel.url!) else {
								attachmentErr = "You've already selected that file"
								showingAttachmentErr = true
								return
							}
                            withAnimation { attachments.append(panel.url!) }
                        }
                    })
                } label: { Image(systemName: "plus.circle.fill").font(.system(size: 20)).opacity(0.75) }
					.alert(attachmentErr, isPresented: $showingAttachmentErr) {
						Button("Got It!", role: .cancel) { }
					}
                    .buttonStyle(.plain)
                    .padding(.leading, 18)
            
				TextField(placeholder, text: $message) { send() }
					.textFieldStyle(.plain)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                    .lineSpacing(4)
                    .font(.system(size: 16))
                    .disableAutocorrection(false)
                    .padding([.top, .bottom], 12)
                

                Button(action: { send() }) {
					Image(systemName: "arrow.up").font(.system(size: 20)).opacity(0.75)
                }
				.keyboardShortcut(.return, modifiers: [])
                .buttonStyle(.plain)
                .padding(.trailing, 15)
            }
        }
        .frame(minHeight: 40)
		.background(RoundedRectangle(cornerRadius: 7, style: .continuous)
			.fill(.regularMaterial)
			.overlay(
				RoundedRectangle(cornerRadius: 7, style: .continuous)
					.stroke(Color(nsColor: .separatorColor), lineWidth: 1)
			)
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
