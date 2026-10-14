import UIKit
import SnapKit

final class VideoQualityPickerView: UIView {
    var onSelect: ((PusherVideoQualitySetting) -> Void)?

    private var selectedQuality: PusherVideoQualitySetting = .hd
    private var rows: [(PusherVideoQualitySetting, VideoQualityRowView)] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(_ quality: PusherVideoQualitySetting) {
        selectedQuality = quality
        rows.forEach { item, row in
            row.setSelected(item == quality)
        }
    }

    private func configureUI() {
        let options: [(PusherVideoQualitySetting, String)] = [
            (.fhd, LiveKitResources.localizedString("tuilivekit.pusher.quality.fhd_option")),
            (.hd, LiveKitResources.localizedString("tuilivekit.pusher.quality.hd_option")),
            (.sd, LiveKitResources.localizedString("tuilivekit.pusher.quality.sd_option")),
        ]
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        addSubview(stack)

        options.forEach { quality, title in
            let row = VideoQualityRowView(title: title)
            row.addAction(UIAction { [weak self] _ in
                guard let self, self.selectedQuality != quality else { return }
                self.selectedQuality = quality
                self.bind(quality)
                self.onSelect?(quality)
            }, for: .touchUpInside)
            rows.append((quality, row))
            stack.addArrangedSubview(row)
        }

        stack.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
}

private final class VideoQualityRowView: UIControl {
    private let titleLabel = LiveText(.itemTitle, tone: .secondary)
    private let checkLabel = UILabel()
    private let selectedGradient = CAGradientLayer()

    init(title: String) {
        super.init(frame: .zero)
        layer.cornerRadius = 12
        layer.borderWidth = 1

        selectedGradient.colors = [
            PusherSettingsSelectionStyle.selectedTop.cgColor,
            PusherSettingsSelectionStyle.selectedBottom.cgColor,
        ]
        selectedGradient.startPoint = CGPoint(x: 0, y: 0)
        selectedGradient.endPoint = CGPoint(x: 0, y: 1)
        selectedGradient.cornerRadius = 12
        layer.insertSublayer(selectedGradient, at: 0)

        titleLabel.text = title
        addSubview(titleLabel)

        checkLabel.text = "✓"
        checkLabel.textColor = .white
        checkLabel.font = VideoQualityRowViewTypography.checkFont
        checkLabel.textAlignment = .center
        addSubview(checkLabel)

        snp.makeConstraints { make in
            make.height.equalTo(48)
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        checkLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(14)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        selectedGradient.frame = bounds
    }

    func setSelected(_ selected: Bool) {
        selectedGradient.isHidden = !selected
        backgroundColor = selected ? .clear : PusherSettingsSelectionStyle.idleBackground
        layer.borderColor = selected
            ? LiveTheme.Color.brandBlue.cgColor
            : PusherSettingsSelectionStyle.idleBorder.cgColor
        titleLabel.tone = selected ? .primary : .secondary
        titleLabel.isEmphasized = selected
        checkLabel.isHidden = !selected
    }
}

enum PusherSettingsSelectionStyle {
    static let selectedTop: UIColor = LiveTheme.Color.brandBlue.withAlphaComponent(0.42)
    static let selectedBottom: UIColor = LiveTheme.Color.brandDeepBlue.withAlphaComponent(0.26)
    static let idleBackground: UIColor = UIColor.white.withAlphaComponent(0.045)
    static let idleBorder: UIColor = UIColor.white.withAlphaComponent(0.14)
}

// Styles owned by this component or feature. Values preserve the existing design.
private enum VideoQualityRowViewTypography {
    static let checkFont: UIFont = UIFont.systemFont(ofSize: 14, weight: .bold)
}
