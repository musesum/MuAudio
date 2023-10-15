//  MidiLog.swift
//  created by musesum on 11/4/22.


import Foundation

class MidiLog {
    static var lastIcon = ""
    static func nextIcon(_ icon: String)  -> String {
        //?? if icon == lastIcon { return "" }
        lastIcon = icon
        return icon
    }

    static func print(_ icon: String, _ msg: String, terminator: String = " ") {
        Swift.print(icon + msg)
        if !icon.isEmpty {
            lastIcon = icon
        }
    }
}
