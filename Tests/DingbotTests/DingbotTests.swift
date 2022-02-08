import XCTest
@testable import Dingbot

final class DingbotTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
        Dingbot.shared.configure = Dingbot.Configure(accessToken: "YOUR_ACCESS_TOKEN", signKey: "YOUR_SIGN_KEY")
        
        // Send text message
        try await Dingbot.shared.send(Dingbot.TextMessage("test"))
        // Send link message
        try await Dingbot.shared.send(Dingbot.LinkMessage(title: "标题", text: "test, 内容", messageUrl: "https://iiiam.in", picUrl: nil))
        // Send markdown message
        try await Dingbot.shared.send(Dingbot.MarkdownMessage(title: "markdown title", content: "#### test markdown content\n\n> build 1214", at: nil))
        
        // Send to specific dingbot with accessToken (and signKey `nullable`)
        try await Dingbot.shared.send(Dingbot.TextMessage("Only test text message"), configure: Dingbot.Configure(accessToken: "", signKey: ""))
    }
}
