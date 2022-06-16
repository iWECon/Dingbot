# Dingbot

DingTalk bot (webhook).

钉钉自定义机器人，支持文本消息(Text Message)、链接消息（Link Message)以及Markdown Message.

支持 [Vapor](https://github.com/vapor/vapor).


# Features

支持全局统一或单独定义 accessToken、加签 signKey;

```swift
// 全局统一, 这里配置完成后, 使用 Dingbot.shared.send(_:) 默认均使用该配置
Dingbot.shared.configure = Dingbot.Configure(accessToken: String, signKey: String)

// 独立定义, 使用 .send(_:configure:) 时，将独立配置添加进去即优先使用独立配置
Dingbot.shared.send(_ message: DingbotMessage, configure: Dingbot.Configure)
```

# DingbotMessage

```swift
// 文本消息 TextMessage

Dingbot.TextMessage("Input your text message", at: `Dingbot.At?`)

// 链接消息 LinkMessage
Dingbot.LinkMessage(title: String, text: String, messageUrl: String, picUrl: String? = nil)

// 富文本 MarkdownMessage
Dingbot.MarkdownMessage(title: String, content: String, at: Dingbot.At? = nil)

// Dingbot.At
Dingbot.At(atMobiles: [String]? = nil, atUserIds: [String]? = nil, isAtAll: Bool = false)
```


# Platform version

使用 `concurrency`，可能需要支持的系统版本偏高：

iOS v13 or up;

macOS v12 or up;

# Vapor Support

```swift
import Vapor
import Dingbot

public extension Request {

    var dingbot: Dingbot {
        Dingbot.shared
    }

}

public extension Application {

    var dingbot: Dingbot {
        Dingbot.shared
    }

}
```

# Install

`.package(url: "https://github.com/iWECon/Dingbot.git", from: "2.0.0")`
