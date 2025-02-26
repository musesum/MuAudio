//  MidiLog.swift
//  created by musesum on 11/4/22.


import Foundation
import MuFlo
class MidiLog {
    static var lastIcon = ""
    static func nextIcon(_ icon: String)  -> String {
        //?? if icon == lastIcon { return "" }
        lastIcon = icon
        return icon
    }

    static func log(_ icon: String, _ msg: String) {
        PrintLog(icon + msg)
        if !icon.isEmpty {
            lastIcon = icon
        }
    }
}
