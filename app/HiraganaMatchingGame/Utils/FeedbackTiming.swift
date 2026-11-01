import Foundation

/// 回答のあと、次の問題へ進むまでの待ち方（#82）
enum FeedbackTiming {
    /// 間違えたときに読み上げの完了を待つ最長の時間。声が出ない・終わらないときに止まらないため
    static let maxRevealDuration: TimeInterval = 5.0

    /// operation が終わるか、limit 秒経つまで待つ。
    /// 読み上げの完了待ちは途中で打ち切れない作りなので、別の Task で走らせて終わりだけを見る
    static func wait(atMost limit: TimeInterval, for operation: @escaping () async -> Void) async {
        let finished = FinishedFlag()
        Task {
            await operation()
            await finished.markFinished()
        }
        let deadline = Date().addingTimeInterval(limit)
        while Date() < deadline {
            if await finished.isFinished {
                return
            }
            try? await Task.sleep(nanoseconds: 50_000_000)
        }
    }

    /// 今より早く次の問題へ進まないための、最低の待ち時間の残り
    static func remainingWait(elapsed: TimeInterval, minimum: TimeInterval) -> TimeInterval {
        max(0, minimum - elapsed)
    }
}

private actor FinishedFlag {
    private(set) var isFinished = false

    func markFinished() {
        isFinished = true
    }
}
