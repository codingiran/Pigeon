//
//  Pigeon.swift
//  Pigeon
//
//  Created by CodingIran on 2023/6/27.
//

import Foundation

// Enforce minimum Swift version for all platforms and build systems.
#if swift(<5.5)
#error("Pigeon doesn't support Swift versions below 5.5.")
#endif

/// Current Pigeon version. Necessary since SPM doesn't use dynamic libraries. Plus this will be more accurate.
let version = "0.0.1"

public struct Pigeon {}
