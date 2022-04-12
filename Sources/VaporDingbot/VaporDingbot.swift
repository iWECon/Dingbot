//
//  Created by i on 2022/4/12.
//

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
