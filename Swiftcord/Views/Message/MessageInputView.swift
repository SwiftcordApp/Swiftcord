//
//  MessageInputView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 24/2/22.
//

import SwiftUI

// FIXME: This doesn't work when the TextEditor is focused
struct KeyEventHandling: NSViewRepresentable {
	class KeyView: NSView {
		override var acceptsFirstResponder: Bool { true }
		
		override func keyDown(with event: NSEvent) {
			print("keydown event")
		}

		override func flagsChanged(with event: NSEvent) {
			switch event.modifierFlags.intersection(.deviceIndependentFlagsMask) {
			case [.shift]:
				print("shift key pressed")
			default:
				print("no modifier keys are pressed")
			}
		}
	}

	func makeNSView(context: Context) -> NSView {
		let view = KeyView()
		DispatchQueue.main.async { // wait till next event cycle
			view.window?.makeFirstResponder(view)
		}
		return view
	}

	func updateNSView(_ nsView: NSView, context: Context) { }
}

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
					.overlay(KeyEventHandling().focusable())
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
                    .onChange(of: message) { _ in
						guard message.hasSuffix("\n") else { return }
						guard !inhibitingSend else {
							inhibitingSend = false
							return
						}
						send()
					}
                

                Button(action: { send() }) {
                    Image(systemName: "arrow.up").font(.system(size: 20))
                }
				.keyboardShortcut(.return, modifiers: [])
                .buttonStyle(.plain)
                .padding(.trailing, 15)
				
				Button {
					print("make a newline")
					message.append("\n")
					inhibitingSend = true
				} label: { EmptyView() }
				.buttonStyle(.plain)
				.keyboardShortcut(.return, modifiers: [.command])
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
