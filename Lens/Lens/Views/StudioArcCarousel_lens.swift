import UIKit
import SnapKit

// MARK: - 圆弧拱形功能轮播

/// ArcFeatureItem_Lens
/// 功能：首页三大功能板块的展示数据项
struct ArcFeatureItem_Lens {
    let title_Lens: String
    let subtitle_Lens: String
    let iconName_Lens: String
    let accentHex_Lens: String
    /// 卡片背景渐变色阶（左上 → 右下，全不透明）
    let gradientHexes_Lens: [String]
    let onTap_Lens: () -> Void
}

/// ArcFeatureCarousel_Lens
/// 功能：三大功能以圆弧拱起形态横向滑动展示
/// 设计思路：中心卡片放大上浮，两侧卡片缩小下沉形成拱形视觉
class ArcFeatureCarousel_Lens: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {

    private var items_Lens: [ArcFeatureItem_Lens] = []
    private let cellId_Lens = "ArcFeatureCell_Lens"

    private lazy var collectionView_Lens: UICollectionView = {
        let layout_Lens = UICollectionViewFlowLayout()
        layout_Lens.scrollDirection = .horizontal
        layout_Lens.minimumLineSpacing = 14
        let cv_Lens = UICollectionView(frame: .zero, collectionViewLayout: layout_Lens)
        cv_Lens.backgroundColor = .clear
        cv_Lens.showsHorizontalScrollIndicator = false
        cv_Lens.decelerationRate = .fast
        cv_Lens.clipsToBounds = false
        cv_Lens.dataSource = self
        cv_Lens.delegate = self
        cv_Lens.register(ArcFeatureCell_Lens.self, forCellWithReuseIdentifier: cellId_Lens)
        return cv_Lens
    }()

    private let pageControl_Lens: UIPageControl = {
        let p = UIPageControl()
        p.currentPageIndicatorTintColor = UIColor(hexstring_Lens: "#C77DFF")
        p.pageIndicatorTintColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.2)
        return p
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = false
        addSubview(collectionView_Lens)
        addSubview(pageControl_Lens)
        collectionView_Lens.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(300)
        }
        pageControl_Lens.snp.makeConstraints {
            $0.top.equalTo(collectionView_Lens.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        refreshVisibleGradients_Lens()
        applyArcTransform_Lens()
    }

    /// 配置功能项数据
    func configure_Lens(items_Lens: [ArcFeatureItem_Lens]) {
        self.items_Lens = items_Lens
        pageControl_Lens.numberOfPages = items_Lens.count
        collectionView_Lens.reloadData()
        setNeedsLayout()
        layoutIfNeeded()
        refreshVisibleGradients_Lens()
        applyArcTransform_Lens()
    }

    /// 布局完成后刷新所有可见卡片的渐变（解决首帧不渲染）
    func refreshVisibleGradients_Lens() {
        guard collectionView_Lens.bounds.width > 1 else { return }
        for cell_Lens in collectionView_Lens.visibleCells {
            guard let arcCell_Lens = cell_Lens as? ArcFeatureCell_Lens else { continue }
            arcCell_Lens.setNeedsLayout()
            arcCell_Lens.layoutIfNeeded()
            arcCell_Lens.refreshGradientFrame_Lens()
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items_Lens.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell_Lens = collectionView.dequeueReusableCell(
            withReuseIdentifier: cellId_Lens, for: indexPath
        ) as? ArcFeatureCell_Lens else { return UICollectionViewCell() }
        let item_Lens = items_Lens[indexPath.item]
        cell_Lens.configure_Lens(
            title_Lens: item_Lens.title_Lens,
            subtitle_Lens: item_Lens.subtitle_Lens,
            icon_Lens: item_Lens.iconName_Lens,
            accentHex_Lens: item_Lens.accentHex_Lens,
            gradientHexes_Lens: item_Lens.gradientHexes_Lens,
            cardSize_Lens: CGSize(width: collectionView.bounds.width * 0.72, height: 280)
        )
        return cell_Lens
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        items_Lens[indexPath.item].onTap_Lens()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.bounds.width * 0.72, height: 280)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let inset_Lens = collectionView.bounds.width * 0.14
        return UIEdgeInsets(top: 0, left: inset_Lens, bottom: 0, right: inset_Lens)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let arcCell_Lens = cell as? ArcFeatureCell_Lens else { return }
        arcCell_Lens.setNeedsLayout()
        arcCell_Lens.layoutIfNeeded()
        arcCell_Lens.refreshGradientFrame_Lens()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        applyArcTransform_Lens()
        updatePage_Lens()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updatePage_Lens()
    }

    /// 应用圆弧拱起变换
    private func applyArcTransform_Lens() {
        let centerX_Lens = collectionView_Lens.contentOffset.x + collectionView_Lens.bounds.width / 2
        for cell_Lens in collectionView_Lens.visibleCells {
            let cellCenterX_Lens = cell_Lens.center.x
            let distance_Lens = abs(centerX_Lens - cellCenterX_Lens)
            let maxDist_Lens = collectionView_Lens.bounds.width / 2
            let ratio_Lens = min(distance_Lens / maxDist_Lens, 1.0)
            let scale_Lens = 1.0 - ratio_Lens * 0.14
            let translateY_Lens = ratio_Lens * 36
            let rotate_Lens = (cellCenterX_Lens < centerX_Lens ? 1 : -1) * ratio_Lens * 0.06
            cell_Lens.transform = CGAffineTransform(translationX: 0, y: translateY_Lens)
                .rotated(by: rotate_Lens)
                .scaledBy(x: scale_Lens, y: scale_Lens)
            cell_Lens.alpha = 1.0 - ratio_Lens * 0.1
        }
    }

    private func updatePage_Lens() {
        let centerX_Lens = collectionView_Lens.contentOffset.x + collectionView_Lens.bounds.width / 2
        var closest_Lens = 0
        var minDist_Lens = CGFloat.greatestFiniteMagnitude
        for i_Lens in 0..<items_Lens.count {
            let indexPath_Lens = IndexPath(item: i_Lens, section: 0)
            if let attr_Lens = collectionView_Lens.layoutAttributesForItem(at: indexPath_Lens) {
                let dist_Lens = abs(attr_Lens.center.x - centerX_Lens)
                if dist_Lens < minDist_Lens {
                    minDist_Lens = dist_Lens
                    closest_Lens = i_Lens
                }
            }
        }
        pageControl_Lens.currentPage = closest_Lens
    }
}

// MARK: - 圆弧功能卡片 Cell

/// ArcFeatureCell_Lens：拱形轮播中的单张功能卡片
class ArcFeatureCell_Lens: UICollectionViewCell {

    private let cardView_Lens: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 24
        v.clipsToBounds = true
        return v
    }()

    private let gradientLayer_Lens = CAGradientLayer()
    /// 卡片顶部径向光晕
    private let radialGlowLayer_Lens: CAGradientLayer = {
        let layer_Lens = CAGradientLayer()
        layer_Lens.type = .radial
        return layer_Lens
    }()
    private let arcGlow_Lens = UIView()

    private let iconWrap_Lens: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 28
        return v
    }()

    private let iconView_Lens = UIImageView()
    private let titleLabel_Lens: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 22, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    private let subtitleLabel_Lens: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.65)
        l.textAlignment = .center
        l.numberOfLines = 3
        return l
    }()

    private let enterLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "Swipe & Tap to Enter"
        l.font = .systemFont(ofSize: 11, weight: .semibold)
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.4)
        l.textAlignment = .center
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.clipsToBounds = false
        contentView.addSubview(cardView_Lens)

        gradientLayer_Lens.cornerRadius = 24
        cardView_Lens.layer.insertSublayer(gradientLayer_Lens, at: 0)

        arcGlow_Lens.isUserInteractionEnabled = false
        arcGlow_Lens.backgroundColor = .clear
        arcGlow_Lens.layer.insertSublayer(radialGlowLayer_Lens, at: 0)
        cardView_Lens.addSubview(arcGlow_Lens)
        cardView_Lens.addSubview(iconWrap_Lens)
        iconWrap_Lens.addSubview(iconView_Lens)
        cardView_Lens.addSubview(titleLabel_Lens)
        cardView_Lens.addSubview(subtitleLabel_Lens)
        cardView_Lens.addSubview(enterLabel_Lens)

        cardView_Lens.layer.borderWidth = 1
        cardView_Lens.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.1).cgColor
        cardView_Lens.layer.shadowColor = UIColor(hexstring_Lens: "#7B2FF7").cgColor
        cardView_Lens.layer.shadowOpacity = 0.35
        cardView_Lens.layer.shadowRadius = 16
        cardView_Lens.layer.shadowOffset = CGSize(width: 0, height: 8)

        cardView_Lens.snp.makeConstraints { $0.edges.equalToSuperview() }
        arcGlow_Lens.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        iconWrap_Lens.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(36)
            $0.width.height.equalTo(56)
        }
        iconView_Lens.snp.makeConstraints { $0.center.equalToSuperview() }
        titleLabel_Lens.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(iconWrap_Lens.snp.bottom).offset(18)
        }
        subtitleLabel_Lens.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(titleLabel_Lens.snp.bottom).offset(10)
        }
        enterLabel_Lens.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(20)
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()
        transform = .identity
        alpha = 1
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        refreshGradientFrame_Lens()
    }

    /// 预设卡片尺寸（布局前用于首帧渐变渲染）
    private var presetCardSize_Lens: CGSize = .zero

    /// 同步渐变图层尺寸（cell 复用或首次展示时调用）
    func refreshGradientFrame_Lens() {
        let target_Lens: CGRect
        if cardView_Lens.bounds.width > 1 {
            target_Lens = cardView_Lens.bounds
        } else if presetCardSize_Lens.width > 1 {
            target_Lens = CGRect(origin: .zero, size: presetCardSize_Lens)
        } else if contentView.bounds.width > 1 {
            target_Lens = contentView.bounds
        } else {
            return
        }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer_Lens.frame = target_Lens
        radialGlowLayer_Lens.frame = target_Lens
        radialGlowLayer_Lens.startPoint = CGPoint(x: 0.5, y: 0)
        radialGlowLayer_Lens.endPoint = CGPoint(x: 1.2, y: 1.0)
        CATransaction.commit()
    }

    /// 配置卡片内容与主题渐变背景
    func configure_Lens(
        title_Lens: String,
        subtitle_Lens: String,
        icon_Lens: String,
        accentHex_Lens: String,
        gradientHexes_Lens: [String],
        cardSize_Lens: CGSize = .zero
    ) {
        presetCardSize_Lens = cardSize_Lens
        titleLabel_Lens.text = title_Lens
        subtitleLabel_Lens.text = subtitle_Lens
        let accent_Lens = UIColor(hexstring_Lens: accentHex_Lens)
        let cfg_Lens = UIImage.SymbolConfiguration(pointSize: 26, weight: .semibold)
        iconView_Lens.image = UIImage(systemName: icon_Lens, withConfiguration: cfg_Lens)
        iconView_Lens.tintColor = accent_Lens
        iconWrap_Lens.backgroundColor = accent_Lens.withAlphaComponent(0.25)

        // 主背景：全不透明多段渐变，确保蓝/紫与黄同样醒目
        let stops_Lens = gradientHexes_Lens.isEmpty
            ? [accentHex_Lens, "#1A1A38", "#0D0D1A"]
            : gradientHexes_Lens
        gradientLayer_Lens.colors = stops_Lens.map { UIColor(hexstring_Lens: $0).cgColor }
        let locCount_Lens = stops_Lens.count
        gradientLayer_Lens.locations = (0..<locCount_Lens).map {
            NSNumber(value: Double($0) / Double(max(locCount_Lens - 1, 1)))
        }
        gradientLayer_Lens.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Lens.endPoint = CGPoint(x: 1, y: 1)

        // 顶部径向光晕：模拟 Light Studio 卡片的明亮氛围
        radialGlowLayer_Lens.colors = [
            accent_Lens.withAlphaComponent(0.55).cgColor,
            accent_Lens.withAlphaComponent(0.18).cgColor,
            UIColor.clear.cgColor
        ]
        radialGlowLayer_Lens.locations = [0, 0.42, 1]

        cardView_Lens.layer.shadowColor = accent_Lens.cgColor
        cardView_Lens.layer.shadowOpacity = 0.45
        cardView_Lens.layer.borderColor = accent_Lens.withAlphaComponent(0.35).cgColor

        setNeedsLayout()
        layoutIfNeeded()
        refreshGradientFrame_Lens()
    }
}
