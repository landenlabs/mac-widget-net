import Foundation
import Darwin

final class NetworkMonitor: ObservableObject {
    @Published var downloadSamples: [Double] = []
    @Published var uploadSamples:   [Double] = []
    @Published var currentDownload: Double = 0
    @Published var currentUpload:   Double = 0
    @Published var downloadPeak:    Double = 1
    @Published var uploadPeak:      Double = 1

    private var timer:         Timer?
    private var lastBytesIn:   UInt64 = 0
    private var lastBytesOut:  UInt64 = 0
    private(set) var sampleInterval: Double = 1.0
    private(set) var maxSamples:     Int    = 60

    // MARK: - Configuration

    func configure(sampleInterval: Double, maxSamples: Int) {
        let changed = self.sampleInterval != sampleInterval || self.maxSamples != maxSamples
        self.sampleInterval = sampleInterval
        self.maxSamples     = maxSamples

        if downloadSamples.count > maxSamples {
            downloadSamples = Array(downloadSamples.suffix(maxSamples))
            uploadSamples   = Array(uploadSamples.suffix(maxSamples))
        }

        if changed && timer != nil {
            stop()
            start()
        }
    }

    // MARK: - Lifecycle

    func start() {
        guard timer == nil else { return }
        let (bytesIn, bytesOut) = totalBytes()
        lastBytesIn  = bytesIn
        lastBytesOut = bytesOut

        if downloadSamples.isEmpty {
            downloadSamples = Array(repeating: 0, count: maxSamples)
            uploadSamples   = Array(repeating: 0, count: maxSamples)
        }

        timer = Timer.scheduledTimer(withTimeInterval: sampleInterval, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Sampling

    private func tick() {
        let (curIn, curOut) = totalBytes()
        let dlRate = curIn  >= lastBytesIn  ? Double(curIn  - lastBytesIn)  / sampleInterval : 0
        let ulRate = curOut >= lastBytesOut ? Double(curOut - lastBytesOut) / sampleInterval : 0
        lastBytesIn  = curIn
        lastBytesOut = curOut

        DispatchQueue.main.async {
            self.currentDownload = dlRate
            self.currentUpload   = ulRate

            self.downloadSamples.append(dlRate)
            if self.downloadSamples.count > self.maxSamples { self.downloadSamples.removeFirst() }
            self.uploadSamples.append(ulRate)
            if self.uploadSamples.count > self.maxSamples { self.uploadSamples.removeFirst() }

            self.downloadPeak = max(self.downloadSamples.max() ?? 1, 1)
            self.uploadPeak   = max(self.uploadSamples.max()   ?? 1, 1)
        }
    }

    private func totalBytes() -> (UInt64, UInt64) {
        var bytesIn:  UInt64 = 0
        var bytesOut: UInt64 = 0
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return (0, 0) }
        defer { freeifaddrs(ifaddr) }

        var ptr = ifaddr
        while let cur = ptr {
            let ifa  = cur.pointee
            let name = String(cString: ifa.ifa_name)
            if ifa.ifa_addr.pointee.sa_family == UInt8(AF_LINK),
               !name.hasPrefix("lo"),
               let data = ifa.ifa_data {
                let stats = data.assumingMemoryBound(to: if_data.self).pointee
                bytesIn  += UInt64(stats.ifi_ibytes)
                bytesOut += UInt64(stats.ifi_obytes)
            }
            ptr = ifa.ifa_next
        }
        return (bytesIn, bytesOut)
    }
}
