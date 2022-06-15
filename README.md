# Dingbot

DingTalk bot (webhook).

钉钉自定义机器人，支持文本消息(Text Message)、连接消息（Link Message)以及Markdown Message.


# Features

支持全局定义accessToken、加密 key;

支持独立定义accessToken、加密 key（可将消息发送给不同机器人）;


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

#### Contains Vapor use `1.0.0 ..< 2.0.0`

`.package(url: "https://github.com/iWECon/Dingbot.git", from: "1.0.0")`


#### No Vapor use `2.0.0 ...< 3.0.0` 

`.package(url: "https://github.com/iWECon/Dingbot.git", from: "2.0.0")`
