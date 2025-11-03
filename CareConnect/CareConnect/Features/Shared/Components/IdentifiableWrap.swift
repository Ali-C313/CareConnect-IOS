import Foundation

struct IdentifiableWrap<T>: Identifiable {
    /// Eindeutige ID
    let id = UUID()
    /// Gespeicherter Wert
    let value: T
}
