//  MidiLog.swift
//  created by musesum on 11/4/22.

import Foundation
import MuFlo

class MidiLog {
    static func log(_ icon: String, _ msg: String) {
        switch icon {
        case "∅","♪": DebugLog { P(" \(icon) \(msg)") }
        case "􀖓"   : TimeLog(icon, interval: 0.25) { P("\(icon) \(msg)") }
        case "􀩿"   : break // ignore system messages
        default     : TimeLog(icon, interval: 0.25) { P("\(icon) \(msg)") }
        }
    }
}
