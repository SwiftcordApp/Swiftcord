//
//  MessageInputView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 24/2/22.
//

import SwiftUI
import DiscordKitCore

struct MessageAttachmentView: View {
    let attachment: URL
	let onRemove: () -> Void

    var body: some View {
		ZStack(alignment: .topTrailing) {
			GroupBox {
				VStack(spacing: 0) {
					let mime = attachment.mimeType
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
					Text((try? attachment.resourceValues(forKeys: [URLResourceKey.nameKey]).name) ?? "No Filename")
						.lineLimit(1)
						.truncationMode(.middle)
						.frame(maxWidth: .infinity, alignment: .leading)
				}.frame(maxWidth: .infinity, maxHeight: .infinity)
			}.frame(width: 150, height: 150)

			Button(action: onRemove) {
				Image(systemName: "trash.square.fill")
					.symbolRenderingMode(.palette)
					.foregroundStyle(.red, Color(.windowBackgroundColor))
					.font(.system(size: 32))
					.pointable()
			}
			.help("Remove attachment")
			.buttonStyle(.plain)
			.offset(x: 8, y: -8)
		}
	}
}

struct MessageInputView: View {
    let placeholder: LocalizedStringKey
    @Binding var message: String
    @Binding var attachments: [URL]
	@Binding var replying: MessagesViewModel.ReplyRef?
    let onSend: (String, [URL]) -> Void
	let preAttach: (URL) -> Bool

	@State private var inhibitingSend = false
	@State private var showingAttachmentErr = false
	@State private var attachmentErr = ""
	@EnvironmentObject var ctx: ServerContext

	@AppStorage("showSendBtn") private var showSendButton = false

	@FocusState private var messageFieldFocused: Bool

    private func send() {
        guard message.hasContent() || !attachments.isEmpty else { return }
        onSend(message, attachments)
        withAnimation { attachments.removeAll() }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
			if replying != nil {
				MessageInputReplyView(replying: $replying)
				Divider()
			}

            if !attachments.isEmpty {
                ScrollView(.horizontal) {
                    HStack {
						ForEach(attachments.indices, id: \.self) { idx in
							MessageAttachmentView(attachment: attachments[idx]) {
								guard idx < attachments.count else { return }
								withAnimation { _ = attachments.remove(at: idx) }
							}
                        }
                    }
					.padding(16)
                }
				.fixedSize(horizontal: false, vertical: true)
                Divider()
            }

			HStack(alignment: .top, spacing: 16) {
                Button {
                    let panel = NSOpenPanel()
                    panel.allowsMultipleSelection = true
                    panel.canChooseDirectories = false
                    panel.treatsFilePackagesAsDirectories = true
                    panel.beginSheetModal(for: NSApp.mainWindow!) { num in
                        if num == NSApplication.ModalResponse.OK {
							for fileURL in panel.urls {
								if preAttach(fileURL) {
									withAnimation { attachments.append(fileURL) }
								} else { break }
							}
                        }
                    }
                } label: {
					Image(systemName: "plus.circle.fill")
						.font(.system(size: 20))
						.opacity(0.75)
						.pointable()
				}
                    .buttonStyle(.plain)

				textBox

				if showSendButton {
					let canSend = message.hasContent() || !attachments.isEmpty
					Button(action: { send() }) {
						Image("SendArrow")
							.foregroundColor(.accentColor)
							.font(.system(size: 24))
							.pointable()
					}
					.keyboardShortcut(.return, modifiers: [])
					.buttonStyle(.plain)
					.disabled(!canSend)
					.animation(.easeOut(duration: 0.2), value: canSend)
				}
            }
			.padding(.vertical, 12)
			.padding(.horizontal, 16)
			.animation(.easeInOut(duration: 0.3), value: showSendButton)
        }
        .frame(minHeight: 40)
		.background(.regularMaterial)
		.overlay(
			RoundedRectangle(cornerRadius: 7)
				.strokeBorder(Color(nsColor: .separatorColor), lineWidth: 1)
		)
		.cornerRadius(7)
        .padding(.horizontal, 16)
        .offset(y: -24)
    }
}

extension MessageInputView {
	@ViewBuilder
	var textBox: some View {
		Group {
			if #available(macOS 13, *) {
				TextField(placeholder, text: $message, axis: .vertical)
					.onSubmit(send)
					.font(.system(size: 16, weight: .regular))
			} else {
				TextEditor(
					text: .init(
						get: { message },
						set: { newValue in
							var modifiableValue = newValue
							var returnIndex = modifiableValue.firstIndex { $0.isReturn }

							while let index = returnIndex {
								// Check if previous value or next value is a new line character. If so, do not
								// remove the return key since it might be needed.
								var shouldRemove = true

								let previousIndex = index > modifiableValue.startIndex ? modifiableValue.index(before: index) : nil
								let nextIndex = index < modifiableValue.endIndex ? modifiableValue.index(after: index) : nil

								if let previousIndex, previousIndex >= modifiableValue.startIndex, modifiableValue[previousIndex].isNewline {
									shouldRemove = false
								}

								if let nextIndex, nextIndex < modifiableValue.endIndex, modifiableValue[nextIndex].isNewline {
									shouldRemove = false
								}

								if shouldRemove {
									modifiableValue.remove(at: index)
								}

								returnIndex = modifiableValue.indices
									.filter { $0 > index }
									.first { modifiableValue[$0].isReturn }
							}
							message = modifiableValue
						}
					)
				)
				.onKeyDown { key in
					switch key {
					case .return:
						send()
					}
				}
				.background(
					Text(placeholder)
						.frame(maxWidth: .infinity, alignment: .leading)
						.padding(.leading, 5)
						.foregroundColor(Color(.placeholderTextColor))
						.opacity(message.count == 0 ? 1.0 : 0)
						.allowsHitTesting(false)
				)
				.font(.system(size: 16, weight: .light))
			}
		}
		.textFieldStyle(.plain)
		.fixedSize(horizontal: false, vertical: true)
		.frame(maxWidth: .infinity)
		.lineSpacing(4)
		.disableAutocorrection(false)
		.focused($messageFieldFocused)
		.onChange(of: ctx.channel) { _ in
			messageFieldFocused = true
		}
		.offset(y: 2)
	}
}

struct MessageInputView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
