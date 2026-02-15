import SwiftUI
import UniformTypeIdentifiers

extension StructuredText {
  /// A proxy for a rendered code block that custom code block styles can use.
  public struct CodeBlockProxy {
    private let content: AttributedSubstring

    internal init(_ content: AttributedSubstring) {
      self.content = content
    }

    /// Copies the code block contents to the system pasteboard.
    ///
    /// Textual writes both a plain-text and an HTML representation when possible.
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public func copyToPasteboard(_ types: Set<UTType> = [.plainText]) {
      #if TEXTUAL_ENABLE_TEXT_SELECTION && canImport(AppKit)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        let formatter = Formatter(AttributedString(content))
        types.forEach {
          switch $0 {
          case .plainText:
            pasteboard.setString(formatter.plainText(), forType: .string)
          case .html:
            pasteboard.setString(formatter.html(), forType: .html)
          default:
            assertionFailure("Unsupported UTType for code block pasteboard")
          }
        }
        
        pasteboard.setString(formatter.html(), forType: .html)
      #elseif TEXTUAL_ENABLE_TEXT_SELECTION && canImport(UIKit)
        let formatter = Formatter(AttributedString(content))
        let itemsToCopy = types.reduce(into: [String: Any]()) { acc, val in
          switch val {
          case .plainText:
            acc[UTType.plainText.identifier] = formatter.plainText()
          case .html:
            acc[UTType.html.identifier] = formatter.html()
          default:
            assertionFailure("Unsupported UTType for code block pasteboard")
          }
        }
      
        UIPasteboard.general.setItems([itemsToCopy])
      #endif
    }
  }
}
