//
//  main.swift
//  NextSpaceID
//
//  Created by xuyecan on 2021/11/15.
//

import Foundation
import Cocoa

let beginTime = Date().timeIntervalSince1970 * 1000

func printTimeElapse(label: String) {
    print("\(label) elapsed time: \(Date().timeIntervalSince1970 * 1000 - beginTime)")
}

func getOperCodeFromArgument() -> (Bool, String) {
    if (CommandLine.arguments.count <= 1) {
        return (false, "N/A")
    }
    return (true, CommandLine.arguments[1])
}

func findSpaceIndexIn(display: NSDictionary, activeDisplay: String) -> (Bool, Int) {
    guard
        let current = display["Current Space"] as? [String: Any],
        let spaces = display["Spaces"] as? [[String: Any]],
        let dispID = display["Display Identifier"] as? String
        else {
            return (false, 0)
    }

    var activeSpaceId = -1

    switch dispID {
    case "Main", activeDisplay:
        activeSpaceId = current["ManagedSpaceID"] as! Int
    default:
        return (false, 0)
    }

    for (index, space) in spaces.enumerated() {
        let isFullscreen = space["TileLayoutManager"] as? [String: Any] != nil
        if isFullscreen {
            continue
        }

        let spaceId = space["ManagedSpaceID"] as! Int
        if spaceId == activeSpaceId {
            return (true, index)
        }
    }

    return (false, 0)
}

func calSpaceIndex(displays: [NSDictionary], displayIndex: Int, spaceIndex: Int, operCode: String) -> Int {
    let spaceSumAhead = displays[..<displayIndex]
        .reduce(0, {(sum: Int, display: NSDictionary) -> Int in return sum + (display["Spaces"] as! [Any]).count })

    let currentDisplayLength = (displays[displayIndex]["Spaces"] as! [Any]).count

    switch (operCode) {
    case "next":
        let next = spaceIndex + 1 + 1
        if (next > currentDisplayLength) {
            return -1
        }
        return spaceSumAhead + next
    case "prev":
        let prev = spaceIndex - 1 + 1
        if (prev < 1) {
            return -1
        }
        return spaceSumAhead + prev
    default:
        return -1
    }
}

func doit() {
    let (valid, operCode) = getOperCodeFromArgument()
    if (!valid) {
        return
    }

    printTimeElapse(label: "before getting conn")
    let conn = _CGSDefaultConnection()
    print("conn: \(conn)")
    printTimeElapse(label: "after getting conn1")
    let displays = CGSCopyManagedDisplaySpaces(conn) as! [NSDictionary]
    printTimeElapse(label: "after getting conn2")
    let activeDisplay = CGSCopyActiveMenuBarDisplayIdentifier(conn) as! String
    printTimeElapse(label: "after getting conn3")

    var currentDisplayIndex = -1
    var currentSpaceIndexInDisplay = -1

    for (index, display) in displays.enumerated() {
        let (isSpaceInThisDisplay, spaceIndexInDisplay) = findSpaceIndexIn(display: display, activeDisplay: activeDisplay)
        if (!isSpaceInThisDisplay) {
            continue
        }

        currentDisplayIndex = index
        currentSpaceIndexInDisplay = spaceIndexInDisplay
        break
    }

    if (currentDisplayIndex == -1 || currentSpaceIndexInDisplay == -1) {
        return
    }

    let output = calSpaceIndex(displays: displays, displayIndex: currentDisplayIndex, spaceIndex: currentSpaceIndexInDisplay, operCode: operCode)
    print("\(output)")
}

printTimeElapse(label: "begin")
doit()
printTimeElapse(label: "end")
