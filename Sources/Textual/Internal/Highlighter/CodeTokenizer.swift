import Foundation
import os

#if canImport(JavaScriptCore)
  import JavaScriptCore
#endif

// MARK: - Overview
//
// CodeTokenizer wraps Prism.js via JavaScriptCore for syntax highlighting. The actor
// ensures thread-safe access to the JavaScript context.
//
// The tokenizer gracefully degrades when JavaScriptCore is unavailable, when the
// Prism bundle is missing, or when tokenization fails. In all cases, it returns
// a single plain token containing the entire code string.

struct CodeToken: Hashable, Sendable {
  let content: String
  let type: StructuredText.HighlighterTheme.TokenType
}

#if canImport(JavaScriptCore)
  actor CodeTokenizer {
    private let context: JSContext
    private let logger = Logger(category: .codeTokenizer)
    
    private let tokenizer: JSValue
    private let loader: JSValue
    
    private var isLoaded = false

    static let shared = CodeTokenizer()

    init?() {
      guard let context = JSContext() else {
        logger.error("JavascriptCore is not available.")
        return nil
      }

      guard
        let bundleURL = Bundle.textual?.url(
          forResource: "prism-bundle",
          withExtension: "js"
        ),
        let script = try? String(contentsOf: bundleURL, encoding: .utf8)
      else {
        logger.error("Prism JavaScript bundle is missing.")
        return nil
      }

      context.evaluateScript(script)
      self.context = context
      
      guard let loader = context.objectForKeyedSubscript("loadCustomTokens") else {
        logger.error("Prism JavaScript `loadCustomTokens` function is missing.")
        return nil
      }
      self.loader = loader
      
      guard let tokenizer = context.objectForKeyedSubscript("tokenizeCode") else {
        logger.error("Prism JavaScript `tokenizeCode` function is missing.")
        return nil
      }
      self.tokenizer = tokenizer
    }

    func tokenize(code: String, language: String) -> [CodeToken] {
      setup()
      
      guard
        let result = tokenizer.call(withArguments: [code, language]),
        let array = result.toArray() as? [[String: String]]
      else {
        logger.error("Tokenization failed.")
        return [CodeToken(content: code, type: .plain)]
      }

      return array.compactMap { token in
        guard
          let content = token["content"],
          let type = token["type"]
        else {
          return nil
        }
        return CodeToken(content: content, type: .init(rawValue: type))
      }
    }
    
    private func setup() {
      guard !isLoaded else { return }
      defer { isLoaded = true }
      
      if let isLoaded = loader.call(withArguments: []), isLoaded.toBool() {
        logger.info("Custom tokens is already loaded.")
      } else {
        logger.error("Tokenization failed.")
      }
    }
  }
#else
  actor CodeTokenizer {
    private let logger = Logger(category: .codeTokenizer)

    static let shared = CodeTokenizer()

    init?() {
      logger.error("JavascriptCore is not available in this platform.")
      return nil
    }

    func tokenize(code: String, language: String) -> [CodeToken] {
      [CodeToken(content: code, type: .plain)]
    }
  }
#endif

extension Logger.Textual.Category {
  fileprivate static let codeTokenizer = Self(rawValue: "codeTokenizer")
}
