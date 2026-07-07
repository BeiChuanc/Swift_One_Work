import UIKit
import SnapKit

// MARK: - 首页三大功能区入口

/// HomeFeatureItem_Lens
/// 功能：首页工作室三大功能入口数据项
struct HomeFeatureItem_Lens {
    let title_Lens: String
    let subtitle_Lens: String
    let iconName_Lens: String
    let accentHex_Lens: String
    /// 卡片背景渐变色阶（左上 → 右下）
    let gradientHexes_Lens: [String]
    let onTap_Lens: () -> Void
}

/// HomeFeatureHubView_Lens
/// 功能：以圆弧拱形展示 Creation / Acrylic / Light 三大工作室入口
/// 设计：中间卡片上浮放大，两侧下沉缩小形成拱形视觉
class HomeFeatureHubView_Lens: UIView {

    private var items_Lens: [HomeFeatureItem_Lens] = []
    private var cardViews_Lens: [HomeFeatureCardView_Lens] = []
    private var baseTransforms_Lens: [CGAffineTransform] = []

    private let titleIconView_Lens: UIImageView = {
        let v = UIImageView(image: UIImage(systemName: "square.grid.3x1.fill"))
        v.tintColor = UIColor(hexstring_Lens: "#C77DFF", alpha_Lens: 0.7)
        v.contentMode = .scaleAspectFit
        return v
    }()

    private let titleLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "STUDIO TOOLS"
        l.font = .systemFont(ofSize: 11, weight: .semibold)
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.35)
        return l
    }()

    /// 圆弧卡片容器
    private let arcContainer_Lens: UIView = {
        let v = UIView()
        v.clipsToBounds = false
        return v
    }()

    /// 单卡高度
    private let cardHeight_Lens: CGFloat = 158

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = false
        addSubview(titleIconView_Lens)
        addSubview(titleLabel_Lens)
        addSubview(arcContainer_Lens)
        titleIconView_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(4)
            $0.top.equalToSuperview()
            $0.width.height.equalTo(14)
        }
        titleLabel_Lens.snp.makeConstraints {
            $0.leading.equalTo(titleIconView_Lens.snp.trailing).offset(6)
            $0.centerY.equalTo(titleIconView_Lens)
        }
        arcContainer_Lens.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(titleIconView_Lens.snp.bottom).offset(10)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(196)
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyArcLayout_Lens()
    }

    /// 配置三大功能入口
    func configure_Lens(items_Lens: [HomeFeatureItem_Lens]) {
        self.items_Lens = items_Lens
        cardViews_Lens.forEach { $0.removeFromSuperview() }
        cardViews_Lens.removeAll()
        baseTransforms_Lens.removeAll()

        for (index_Lens, item_Lens) in items_Lens.enumerated() {
            let card_Lens = HomeFeatureCardView_Lens()
            card_Lens.configure_Lens(item_Lens: item_Lens)
            card_Lens.tag = index_Lens
            card_Lens.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(handleCardTap_Lens(_:)))
            )
            arcContainer_Lens.addSubview(card_Lens)
            cardViews_Lens.append(card_Lens)
        }
        setNeedsLayout()
    }

    /// 应用圆弧拱形布局：左低右低，中间抬高
    private func applyArcLayout_Lens() {
        guard cardViews_Lens.count == 3, arcContainer_Lens.bounds.width > 10 else { return }

        let containerW_Lens = arcContainer_Lens.bounds.width
        let cardW_Lens = containerW_Lens * 0.30
        let sideInset_Lens = (containerW_Lens - cardW_Lens * 3) / 4
        let centerYBase_Lens = cardHeight_Lens * 0.52 + 18

        let arcConfigs_Lens: [(centerX_Lens: CGFloat, yOffset_Lens: CGFloat, scale_Lens: CGFloat, rotate_Lens: CGFloat)] = [
            (sideInset_Lens + cardW_Lens * 0.5, 34, 0.86, -0.07),
            (containerW_Lens * 0.5, 0, 1.0, 0),
            (containerW_Lens - sideInset_Lens - cardW_Lens * 0.5, 34, 0.86, 0.07)
        ]

        baseTransforms_Lens = []
        for (index_Lens, card_Lens) in cardViews_Lens.enumerated() {
            let cfg_Lens = arcConfigs_Lens[index_Lens]
            card_Lens.bounds = CGRect(x: 0, y: 0, width: cardW_Lens, height: cardHeight_Lens)
            card_Lens.center = CGPoint(
                x: cfg_Lens.centerX_Lens,
                y: centerYBase_Lens + cfg_Lens.yOffset_Lens
            )
            let transform_Lens = CGAffineTransform(rotationAngle: cfg_Lens.rotate_Lens)
                .scaledBy(x: cfg_Lens.scale_Lens, y: cfg_Lens.scale_Lens)
            card_Lens.transform = transform_Lens
            card_Lens.alpha = index_Lens == 1 ? 1.0 : 0.92
            baseTransforms_Lens.append(transform_Lens)
        }
        arcContainer_Lens.bringSubviewToFront(cardViews_Lens[1])
    }

    /// 卡片点击跳转（保留圆弧变换基础上做按压反馈）
    @objc private func handleCardTap_Lens(_ gesture_Lens: UITapGestureRecognizer) {
        guard let card_Lens = gesture_Lens.view,
              let index_Lens = cardViews_Lens.firstIndex(where: { $0 === card_Lens }),
              items_Lens.indices.contains(index_Lens) else { return }
        let base_Lens = baseTransforms_Lens.indices.contains(index_Lens)
            ? baseTransforms_Lens[index_Lens]
            : .identity
        UIView.animate(withDuration: 0.08, animations: {
            card_Lens.transform = base_Lens.scaledBy(x: 0.94, y: 0.94)
        }) { _ in
            UIView.animate(withDuration: 0.12) {
                card_Lens.transform = base_Lens
            }
            self.items_Lens[index_Lens].onTap_Lens()
        }
    }
}

// MARK: - 功能入口单卡

/// HomeFeatureCardView_Lens
/// 功能：单个工作室功能入口卡片
private class HomeFeatureCardView_Lens: UIView {

    private let gradientLayer_Lens = CAGradientLayer()
    private let accentBar_Lens = UIView()

    private let iconWrap_Lens: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 20
        return v
    }()

    private let iconView_Lens = UIImageView()

    private let titleLabel_Lens: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    private let subtitleLabel_Lens: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 9, weight: .medium)
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.45)
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    private let arrowView_Lens: UIImageView = {
        let v = UIImageView(image: UIImage(systemName: "arrow.right"))
        v.tintColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.35)
        v.contentMode = .scaleAspectFit
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        layer.cornerRadius = 18
        layer.borderWidth = 1
        layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.1).cgColor
        clipsToBounds = true
        isUserInteractionEnabled = true

        gradientLayer_Lens.cornerRadius = 18
        layer.insertSublayer(gradientLayer_Lens, at: 0)

        addSubview(accentBar_Lens)
        addSubview(iconWrap_Lens)
        iconWrap_Lens.addSubview(iconView_Lens)
        addSubview(titleLabel_Lens)
        addSubview(subtitleLabel_Lens)
        addSubview(arrowView_Lens)

        accentBar_Lens.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(3)
        }
        iconWrap_Lens.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(18)
            $0.width.height.equalTo(40)
        }
        iconView_Lens.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        titleLabel_Lens.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(6)
            $0.top.equalTo(iconWrap_Lens.snp.bottom).offset(10)
        }
        subtitleLabel_Lens.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(6)
            $0.top.equalTo(titleLabel_Lens.snp.bottom).offset(4)
        }
        arrowView_Lens.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(10)
            $0.width.height.equalTo(10)
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer_Lens.frame = bounds
    }

    /// 配置功能卡内容与主题渐变背景
    func configure_Lens(item_Lens: HomeFeatureItem_Lens) {
        let accent_Lens = UIColor(hexstring_Lens: item_Lens.accentHex_Lens)
        let stops_Lens = item_Lens.gradientHexes_Lens.isEmpty
            ? [item_Lens.accentHex_Lens, "#1A1A38", "#0D0D1A"]
            : item_Lens.gradientHexes_Lens
        gradientLayer_Lens.colors = stops_Lens.map { UIColor(hexstring_Lens: $0).cgColor }
        let locCount_Lens = stops_Lens.count
        gradientLayer_Lens.locations = (0..<locCount_Lens).map {
            NSNumber(value: Double($0) / Double(max(locCount_Lens - 1, 1)))
        }
        gradientLayer_Lens.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Lens.endPoint = CGPoint(x: 1, y: 1)

        accentBar_Lens.backgroundColor = accent_Lens
        iconWrap_Lens.backgroundColor = accent_Lens.withAlphaComponent(0.25)
        let cfg_Lens = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        iconView_Lens.image = UIImage(systemName: item_Lens.iconName_Lens, withConfiguration: cfg_Lens)
        iconView_Lens.tintColor = accent_Lens
        titleLabel_Lens.text = item_Lens.title_Lens
        subtitleLabel_Lens.text = item_Lens.subtitle_Lens
        arrowView_Lens.tintColor = accent_Lens.withAlphaComponent(0.85)
        layer.borderColor = accent_Lens.withAlphaComponent(0.35).cgColor
    }
}
