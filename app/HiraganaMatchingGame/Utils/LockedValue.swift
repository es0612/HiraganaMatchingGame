import Foundation

/// 複数スレッドから読み書きされる値を NSLock で守る入れ物。
/// StarUnlock 系のシングルトンが持つ provider closure を、並列テストが同時に上書きして
/// 二重解放（SIGSEGV）になったため導入した。構造の整理（シングルトンの provider 方式をやめる）は #36。
final class LockedValue<Value> {
    private let lock = NSLock()
    private var storage: Value

    init(_ value: Value) {
        storage = value
    }

    var value: Value {
        get {
            lock.lock()
            defer { lock.unlock() }
            return storage
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            storage = newValue
        }
    }
}
