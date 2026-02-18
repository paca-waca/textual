import SwiftUI

extension StructuredText {
  struct BlockContent<Content: AttributedStringProtocol>: View {
    private let parent: PresentationIntent.IntentType?
    private let content: Content

    init(parent: PresentationIntent.IntentType? = nil, content: Content) {
      self.parent = parent
      self.content = content
    }

    var body: some View {
      let runs = content.blockRuns(parent: parent)

      BlockVStack {
        ForEach(runs.indices, id: \.self) { index in
          let run = runs[index]
          Block(intent: run.intent, content: content[run.range])
        }
      }
    }
  }
}

extension StructuredText {
  struct Block: View {
    private let intent: PresentationIntent.IntentType?
    private let content: AttributedSubstring

    init(intent: PresentationIntent.IntentType?, content: AttributedSubstring) {
      self.intent = intent
      self.content = content
    }

    var body: some View {
      switch intent?.kind {
      case .paragraph where content.isMathBlock:
        MathBlock(content)
          .modifier(TextSelectionInteraction())
      case .paragraph:
        Paragraph(content)
          .modifier(TextSelectionInteraction())
      case .header(let level):
        Heading(content, level: level)
          .modifier(TextSelectionInteraction())
      case .orderedList:
        OrderedList(intent: intent, content: content)
          .modifier(TextSelectionInteraction())
      case .unorderedList:
        UnorderedList(intent: intent, content: content)
          .modifier(TextSelectionInteraction())
      case .codeBlock(let languageHint) where languageHint?.lowercased() == "math":
        MathCodeBlock(content)
          .modifier(TextSelectionInteraction())
      case .codeBlock(let languageHint):
        CodeBlock(content, languageHint: languageHint)
      case .blockQuote:
        BlockQuote(intent: intent, content: content)
          .modifier(TextSelectionInteraction())
      case .thematicBreak:
        ThematicBreak(content)
          .modifier(TextSelectionInteraction())
      case .table(let columns):
        Table(intent: intent, content: content, columns: columns)
      default:
        Paragraph(content)
          .modifier(TextSelectionInteraction())
      }
    }
  }
}
