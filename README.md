# DENLiteStore

DENLiteStore is a simple key-value store intended to be a "drop-in" replacement for NSUserDefaults, with only a few differences.

It's often necessary to store and persist small bits of data or app state, and traditional persistence frameworks like Core Data may not be necessary or ideal. A common anti-pattern is to store this data in the system-provided NSUserDefaults. Unless you're storing user preferences, this isn't the right solution. That's where DENLiteStore comes in.

## Multiple Stores

The primary difference between DENLiteStore and NSUserDefaults is that you can create multiple stores, each with their own name. That name is unique and is used to persist the store in a plist on the filesystem.

## Threading

Each DENLiteStore performs store access within dispatch_sync on it's own serial queue. As such, you should be able to access a given store from multiple threads without any trouble.