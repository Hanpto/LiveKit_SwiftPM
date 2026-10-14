import UIKit
import SnapKit

final class PrepareMoreSettingsView: BottomSheetView {
    weak var actionHandler: PusherSettingsActionHandling?

    private enum Page {
        case main
        case videoQuality
        case audioEffect

        var title: String {
            switch self {
            case .main: return LiveKitResources.localizedString("tuilivekit.pusher.settings.more")
            case .videoQuality: return LiveKitResources.localizedString("tuilivekit.pusher.video_quality")
            case .audioEffect: return LiveKitResources.localizedString("tuilivekit.pusher.audio_effects")
            }
        }

        var sheetHeight: CGFloat {
            switch self {
            case .main: return 191
            case .videoQuality: return 280
            case .audioEffect: return 466
            }
        }
    }

    private let mainContentView = UIView()
    private let qualityItem = PusherSettingsItemView(
        title: LiveKitResources.localizedString("tuilivekit.pusher.quality.hd"),
        assetName: "livekit_settings_quality"
    )
    private let mirrorItem = PusherSettingsItemView(
        title: LiveKitResources.localizedString("tuilivekit.pusher.mirror"),
        assetName: "livekit_settings_mirror"
    )
    private let audioEffectItem = PusherSettingsItemView(
        title: LiveKitResources.localizedString("tuilivekit.pusher.audio_effects"),
        assetName: "livekit_settings_audio_effect"
    )
    private let videoQualityPicker = VideoQualityPickerView()
    private let audioEffectView = AudioEffectView()
    private var settings = PusherSettingsState()
    private var page: Page = .main

    override var sheetHeight: CGFloat { page.sheetHeight }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    func bind(_ settings: PusherSettingsState) {
        self.settings = settings
        qualityItem.setTitle(settings.videoQuality.title)
        mirrorItem.setIcon(assetName: settings.isMirrorEnabled
            ? "livekit_settings_mirror_on"
            : "livekit_settings_mirror_off")
        videoQualityPicker.bind(settings.videoQuality)
        audioEffectView.bindCaptureVolume(settings.captureVolume)
    }

    func show() {
        showPage(.main, animated: false)
        present()
    }

    /// The panel always reopens on its main page.
    override func sheetDidDismiss() {
        showPage(.main, animated: false)
    }

    override func sheetWillPresent() {
        audioEffectView.setActive(page == .audioEffect)
    }

    override func sheetWillDismiss() {
        audioEffectView.setActive(false)
    }

    private func configureUI() {
        contentView.addSubview(mainContentView)

        let mainStack = UIStackView(arrangedSubviews: [qualityItem, mirrorItem, audioEffectItem])
        mainStack.axis = .horizontal
        mainStack.distribution = .fillEqually
        mainContentView.addSubview(mainStack)

        qualityItem.addTarget(self, action: #selector(showVideoQuality), for: .touchUpInside)
        mirrorItem.addTarget(self, action: #selector(toggleMirror), for: .touchUpInside)
        audioEffectItem.addTarget(self, action: #selector(showAudioEffect), for: .touchUpInside)

        videoQualityPicker.onSelect = { [weak self] quality in
            self?.actionHandler?.updateVideoQuality(quality)
            self?.dismiss()
        }
        contentView.addSubview(videoQualityPicker)

        audioEffectView.onSetCaptureVolume = { [weak self] volume in
            self?.actionHandler?.setCaptureVolume(volume)
        }
        contentView.addSubview(audioEffectView)

        mainContentView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(75)
            make.height.equalTo(84)
        }
        mainStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        videoQualityPicker.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(67)
            make.height.equalTo(160)
        }
        audioEffectView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(60)
            make.height.equalTo(372)
        }

        showPage(.main, animated: false)
    }

    private func showPage(_ page: Page, animated: Bool) {
        self.page = page
        sheetTitle = page.title
        mainContentView.isHidden = page != .main
        videoQualityPicker.isHidden = page != .videoQuality
        audioEffectView.isHidden = page != .audioEffect
        audioEffectView.setActive(page == .audioEffect && !isHidden)
        updateSheetHeight(animated: animated)
    }

    @objc private func showVideoQuality() {
        videoQualityPicker.bind(settings.videoQuality)
        showPage(.videoQuality, animated: true)
    }

    @objc private func toggleMirror() {
        actionHandler?.toggleMirror()
    }

    @objc private func showAudioEffect() {
        audioEffectView.bindCaptureVolume(settings.captureVolume)
        showPage(.audioEffect, animated: true)
    }
}
