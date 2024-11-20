# Pigeon

Pigeon is a lightweight Swift framework that enables seamless communication between your main iOS app and its extensions through various transport methods.

## Features

- 🔄 Bidirectional communication between app and extensions
- 📦 Multiple data transport options:
  - File-based communication
  - Coordinated file handling
  - WatchConnectivity session support (iOS 11.0+)
- 💪 Type-safe message passing
- 🔍 Easy message listening and handling
- ⚡️ Darwin notification support for real-time updates

## Requirements

- iOS 12.0+ / watchOS 4.0+ / macOS 10.13+ / tvOS 12.0+
- Swift 5.10+
- Xcode 15+

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/CodingIran/Pigeon.git", from: "0.0.7")
]
```

## Usage

### Basic Setup

1. First, configure your app group identifier in your project capabilities.

2. Initialize Pigeon:

```swift
let pigeon = Pigeon(applicationGroupIdentifier: "group.com.your.app")
```

### Sending Messages

```swift
// Send a message
try pigeon.passMessage("Hello Extensions!", for: "greeting")

// Send with reply handler
try pigeon.passMessage("Ping", for: "ping") { reply in
    print("Received reply: \(reply ?? "no reply")")
}
```

### Listening for Messages

```swift
// Start listening
pigeon.listenMessage(for: "greeting") { message, reply in
    print("Received: \(message ?? "no message")")
    // Send reply if needed
    try? reply("Message received!")
}

// Stop listening
pigeon.stopListeningMessage(for: "greeting")
```

### Transport Types

Pigeon supports multiple transport types:

```swift
// File-based transport (default)
let pigeon = Pigeon(applicationGroupIdentifier: "group.com.your.app", 
                    transitingType: .file)

// Coordinated file transport
let pigeon = Pigeon(applicationGroupIdentifier: "group.com.your.app", 
                    transitingType: .coordinatedFile)

// WatchConnectivity session transport (iOS 11.0+)
let pigeon = Pigeon(applicationGroupIdentifier: "group.com.your.app", 
                    transitingType: .sessionMessage)
```

## Message Cleanup

```swift
// Clear specific message
try pigeon.clearMessageContents(for: "greeting")

// Clear all messages
try pigeon.clearAllMessageContents()
```

## Error Handling

Pigeon provides detailed error handling through `Pigeon.Error`:

- `applicationGroupIdentifierNotConfigured`
- `messageIdentifierInvalid`
- `sessionUnReachable`
- `fileCoordinatorFailed`

## License

MIT License

## Author
    
CodingIran@gmail.com

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.