import SnapKit
import SVGAPlayer
import TCEffectPlayer
import UIKit

final class LiveGiftEffectView: UIView, SVGAPlayerDelegate, TCEPAnimViewDelegate {
    private enum ResourceKind {
        case svga
        case mp4

        init?(resourceURL: String) {
            guard let url = URL(string: resourceURL) else { return nil }
            switch url.pathExtension.lowercased() {
            case "svga": self = .svga
            case "mp4": self = .mp4
            default: return nil
            }
        }
    }

    private struct PendingEffect {
        let id = UUID()
        let resourceURL: String
        let kind: ResourceKind
    }

    private let loader = LiveGiftEffectLoader()
    private let animationCanvasView = UIView()
    private let svgaPlayer = SVGAPlayer()
    private let effectPlayerView = TCEffectAnimView(frame: .zero)
    private var queue: [PendingEffect] = []
    private var currentEffect: PendingEffect?
    private var downloadTask: URLSessionDownloadTask?
    private var preloadTasks: [String: URLSessionDownloadTask] = [:]
    private var preloadInFlightURLs = Set<String>()
    private var preloadWaiters: [String: [(Result<URL, Error>) -> Void]] = [:]
    private var requestedPreloadURLs = Set<String>()
    private var parser: SVGAParser?
    private var timeoutWorkItem: DispatchWorkItem?
    private var generation = UUID()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func enqueue(resourceURL: String) {
        guard let kind = ResourceKind(resourceURL: resourceURL) else { return }
        queue.append(PendingEffect(resourceURL: resourceURL, kind: kind))
        playNextIfNeeded()
    }

    func preload(resourceURLs: [String]) {
        for resourceURL in Set(resourceURLs) {
            guard ResourceKind(resourceURL: resourceURL) != nil,
                  requestedPreloadURLs.insert(resourceURL).inserted
            else { continue }

            preloadInFlightURLs.insert(resourceURL)
            let task = loader.load(resourceURL: resourceURL) { [weak self] result in
                guard let self else { return }
                self.preloadInFlightURLs.remove(resourceURL)
                self.preloadTasks[resourceURL] = nil
                let waiters = self.preloadWaiters.removeValue(forKey: resourceURL) ?? []
                waiters.forEach { $0(result) }
            }
            preloadTasks[resourceURL] = task
        }
    }

    func reset() {
        generation = UUID()
        queue.removeAll()
        currentEffect = nil
        cleanupPlayback()
        isHidden = true
    }

    func svgaPlayerDidFinishedAnimation(_ player: SVGAPlayer) {
        finishCurrentEffect()
    }

    func tcePlayerEnd(_ player: ITCEffectPlayer) {
        finishCurrentEffect()
    }

    func tcePlayerError(_ player: ITCEffectPlayer, error: Error) {
        finishCurrentEffect()
    }

    private func configureUI() {
        isHidden = true
        isUserInteractionEnabled = false
        backgroundColor = .clear

        animationCanvasView.backgroundColor = .clear
        animationCanvasView.isUserInteractionEnabled = false
        addSubview(animationCanvasView)

        svgaPlayer.contentMode = .scaleAspectFit
        svgaPlayer.clearsAfterStop = true
        svgaPlayer.loops = 1
        svgaPlayer.delegate = self
        animationCanvasView.addSubview(svgaPlayer)

        effectPlayerView.backgroundColor = .clear
        effectPlayerView.effectPlayerDelegate = self
        effectPlayerView.setLoop(false)
        effectPlayerView.setRenderMode(.aspectFill)
        let alphaRightMode = TCEPVAPVideoFrameTextureBlendMode(rawValue: 2)!
        effectPlayerView.setVideoMode(alphaRightMode)
        effectPlayerView.isUserInteractionEnabled = false
        animationCanvasView.addSubview(effectPlayerView)

        animationCanvasView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        svgaPlayer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        effectPlayerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func playNextIfNeeded() {
        guard currentEffect == nil, !queue.isEmpty else { return }
        let effect = queue.removeFirst()
        currentEffect = effect
        let currentGeneration = generation
        isHidden = false

        let completion: (Result<URL, Error>) -> Void = { [weak self] result in
            guard let self,
                  self.generation == currentGeneration,
                  self.currentEffect?.id == effect.id
            else { return }
            self.downloadTask = nil
            switch result {
            case .success(let localURL):
                self.play(effect, localURL: localURL, generation: currentGeneration)
            case .failure:
                self.finishCurrentEffect()
            }
        }
        if preloadInFlightURLs.contains(effect.resourceURL) {
            preloadWaiters[effect.resourceURL, default: []].append(completion)
        } else {
            downloadTask = loader.load(
                resourceURL: effect.resourceURL,
                completion: completion
            )
        }
    }

    private func play(_ effect: PendingEffect, localURL: URL, generation: UUID) {
        scheduleTimeout(effectID: effect.id, generation: generation)
        switch effect.kind {
        case .svga:
            playSVGA(localURL: localURL, effectID: effect.id, generation: generation)
        case .mp4:
            playMP4(localURL: localURL)
        }
    }

    private func playSVGA(localURL: URL, effectID: UUID, generation: UUID) {
        effectPlayerView.isHidden = true
        svgaPlayer.isHidden = false
        let parser = SVGAParser()
        parser.enabledMemoryCache = true
        self.parser = parser
        parser.parse(with: localURL) { [weak self] videoItem in
            guard let self,
                  self.generation == generation,
                  self.currentEffect?.id == effectID,
                  let videoItem
            else { return }
            self.svgaPlayer.videoItem = videoItem
            self.svgaPlayer.startAnimation()
        } failureBlock: { [weak self] _ in
            guard let self,
                  self.generation == generation,
                  self.currentEffect?.id == effectID
            else { return }
            self.finishCurrentEffect()
        }
    }

    private func playMP4(localURL: URL) {
        svgaPlayer.isHidden = true
        effectPlayerView.isHidden = false
        effectPlayerView.startPlay(localURL.path)
    }

    private func scheduleTimeout(effectID: UUID, generation: UUID) {
        timeoutWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
            guard let self,
                  self.generation == generation,
                  self.currentEffect?.id == effectID
            else { return }
            self.finishCurrentEffect()
        }
        timeoutWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 30, execute: work)
    }

    private func finishCurrentEffect() {
        guard currentEffect != nil else { return }
        cleanupPlayback()
        currentEffect = nil
        isHidden = true
        playNextIfNeeded()
    }

    private func cleanupPlayback() {
        downloadTask?.cancel()
        downloadTask = nil
        timeoutWorkItem?.cancel()
        timeoutWorkItem = nil
        parser = nil
        svgaPlayer.stopAnimation()
        svgaPlayer.videoItem = nil
        effectPlayerView.stopPlay()
    }
}
