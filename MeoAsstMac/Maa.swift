//
//  Maa.swift
//  MeoAsstMac
//
//  Created by hguandl on 9/10/2022.
//

import Foundation
import MeoAssistant

public struct Maa {
    static var resourceLoaded = false

    private let handle: AsstHandle

    public static func loadResource(path: String) -> Bool {
        if AsstLoadResource(path) {
            resourceLoaded = true
            return true
        }
        return false
    }

    public static func setUserDirectory(path: String) -> Bool {
        AsstSetUserDir(path)
    }

    public init() {
        let callback: AsstApiCallback = { msg, details, _ in
            if msg >= 20000 {
                return
            }
            if let details = details {
                let details = String(cString: details, encoding: .utf8) ?? "<nil>"
                let message = MaaMessage(msg: msg, details: details)
                Self.publishLogMessage(message: message)
            }
        }

        self.handle = AsstCreateEx(callback, nil)
    }

    public func appendTask(taskType: String, taskConfig: String) -> Int32 {
        AsstAppendTask(handle, taskType, taskConfig)
    }

    public func connect(adbPath: String, address: String) -> Bool {
        AsstConnect(handle, adbPath, address, "General")
    }

    public func start() -> Bool {
        AsstStart(handle)
    }

    public func stop() -> Bool {
        AsstStop(handle)
    }
    
    public var running: Bool {
        AsstRunning(handle)
    }

    static func publishLogMessage(message: MaaMessage) {
        NotificationCenter.default.post(name: .MAAReceivedCallbackMessage, object: message)
    }
}

public extension Notification.Name {
    static let MAAReceivedCallbackMessage = Notification.Name("MAAReceivedCallbackMessage")
}
