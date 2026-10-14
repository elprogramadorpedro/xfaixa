import AVFoundation
import Observation
import OSLog

/// Plays 30-second song previews. A single shared instance owns the only `AVPlayer`,
/// so starting a new song always stops the previous one.
@MainActor
@Observable
final class PlayerService {

    // MARK: - Properties

    private(set) var currentSong: Song?
    private(set) var isPlaying = false
    /// Playback position from 0 to 1.
    private(set) var progress: Double = 0

    @ObservationIgnored private let player = AVPlayer()
    @ObservationIgnored private var timeObserver: Any?
    @ObservationIgnored private var endObserver: (any NSObjectProtocol)?
    @ObservationIgnored private var statusObservation: NSKeyValueObservation?
    @ObservationIgnored private var isSessionActive = false

    private let previewLength: Double = 30
    private let logger = Logger(subsystem: "devpedrovillalba.Xfaixa", category: "Player")

    // MARK: - Init

    init() {
        // The observer is delivered on the main queue, which is what makes assumeIsolated safe here.
        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.25, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            MainActor.assumeIsolated {
                self?.updateProgress(at: time)
            }
        }
    }

    isolated deinit {
        if let timeObserver {
            player.removeTimeObserver(timeObserver)
        }
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
        }
    }

    // MARK: - Public API

    func isPlaying(_ song: Song) -> Bool {
        isPlaying && currentSong?.id == song.id
    }

    /// Plays the song, or pauses and resumes it when it's already the current one.
    func toggle(_ song: Song) {
        if currentSong?.id == song.id {
            togglePlayback()
        } else {
            play(song)
        }
    }

    func togglePlayback() {
        isPlaying ? pause() : resume()
    }

    func play(_ song: Song) {
        guard let previewURL = song.previewURL else { return }
        activateSessionIfNeeded()

        let item = AVPlayerItem(url: previewURL)
        observe(item)
        // Replacing the item stops whatever was playing, which is the "one song at a time" guarantee.
        player.replaceCurrentItem(with: item)

        currentSong = song
        progress = 0
        player.play()
        isPlaying = true
    }

    func pause() {
        player.pause()
        isPlaying = false
    }

    func resume() {
        guard currentSong != nil else { return }
        if progress >= 1 {
            player.seek(to: .zero)
            progress = 0
        }
        player.play()
        isPlaying = true
    }

    func stop() {
        player.pause()
        player.replaceCurrentItem(with: nil)
        removeItemObservers()
        currentSong = nil
        isPlaying = false
        progress = 0
    }

    // MARK: - Private Helpers

    /// `.playback` keeps previews audible with the silent switch on, as users expect from a music app.
    private func activateSessionIfNeeded() {
        guard !isSessionActive else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            isSessionActive = true
        } catch {
            logger.error("Failed to activate the audio session: \(error.localizedDescription)")
        }
    }

    private func observe(_ item: AVPlayerItem) {
        removeItemObservers()

        endObserver = NotificationCenter.default.addObserver(
            forName: AVPlayerItem.didPlayToEndTimeNotification,
            object: item,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.isPlaying = false
                self?.progress = 1
            }
        }

        statusObservation = item.observe(\.status) { [weak self] item, _ in
            guard item.status == .failed else { return }
            let message = item.error?.localizedDescription ?? "unknown"
            Task { @MainActor in
                self?.logger.error("Preview failed to load: \(message)")
                self?.isPlaying = false
            }
        }
    }

    private func removeItemObservers() {
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
        }
        endObserver = nil
        statusObservation?.invalidate()
        statusObservation = nil
    }

    private func updateProgress(at time: CMTime) {
        guard isPlaying, let item = player.currentItem else { return }
        let duration = item.duration.isNumeric ? item.duration.seconds : previewLength
        guard duration > 0 else { return }
        progress = min(max(time.seconds / duration, 0), 1)
    }
}
