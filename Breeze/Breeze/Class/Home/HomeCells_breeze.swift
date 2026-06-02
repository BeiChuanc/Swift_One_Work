import Foundation
import UIKit
import SnapKit

// MARK: - 通用 Section 头部工厂

extension UIView {
    /// 创建首页各 Section 统一风格的标题行（左侧竖条 + 标题 + 右侧 "See All" 按钮）
    static func homeSectionHeader_Breeze(title_breeze: String,
                                          showSeeAll_breeze: Bool = true,
                                          action_breeze: (() -> Void)? = nil) -> UIView {
        let container_breeze = UIView()
        
        let bar_breeze = UIView()
        bar_breeze.backgroundColor = ColorConfig_Breeze.primaryGradientStart_Breeze
        bar_breeze.layer.cornerRadius = 2
        
        let titleLbl_breeze = UILabel()
        titleLbl_breeze.text = title_breeze
        titleLbl_breeze.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        titleLbl_breeze.textColor = ColorConfig_Breeze.textPrimary_Breeze
        
        container_breeze.addSubview(bar_breeze)
        container_breeze.addSubview(titleLbl_breeze)
        
        bar_breeze.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(4)
            make.height.equalTo(18)
        }
        titleLbl_breeze.snp.makeConstraints { make in
            make.left.equalTo(bar_breeze.snp.right).offset(8)
            make.centerY.equalToSuperview()
        }
        
        if showSeeAll_breeze, let action_breeze {
            let seeAllBtn_breeze = UIButton(type: .system)
            seeAllBtn_breeze.setTitle("See All", for: .normal)
            seeAllBtn_breeze.setTitleColor(ColorConfig_Breeze.primaryGradientStart_Breeze, for: .normal)
            seeAllBtn_breeze.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
            container_breeze.addSubview(seeAllBtn_breeze)
            seeAllBtn_breeze.snp.makeConstraints { make in
                make.right.equalToSuperview()
                make.centerY.equalToSuperview()
            }
            seeAllBtn_breeze.addAction(UIAction { _ in action_breeze() }, for: .touchUpInside)
        }
        
        return container_breeze
    }
}

// MARK: - 四季主题露营专区

/// 四季主题露营专区 Section
/// 核心作用：展示当季攻略（装备/穿搭/摄影/路线）的横向卡片滚动列表，点击单张卡片弹出详情
class SeasonTipsSection_Breeze: UIView {
    
    var onSeeAll_Breeze: (() -> Void)?
    /// 点击某张 Tip 卡片的回调（传出完整 Tip 数据）
    var onCardTap_Breeze: ((SeasonalTip_Breeze) -> Void)?
    
    private let headerView_Breeze = UIView()
    private let scrollView_Breeze: UIScrollView = {
        let sv_breeze = UIScrollView()
        sv_breeze.showsHorizontalScrollIndicator = false
        sv_breeze.clipsToBounds = false
        return sv_breeze
    }()
    private let cardsStack_Breeze: UIStackView = {
        let stack_breeze = UIStackView()
        stack_breeze.axis = .horizontal
        stack_breeze.spacing = 14
        stack_breeze.alignment = .top
        return stack_breeze
    }()
    
    private var tipCards_Breeze: [SeasonTipCard_Breeze] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Breeze()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI_Breeze() {
        backgroundColor = ColorConfig_Breeze.backgroundPrimary_Breeze
        addSubview(headerView_Breeze)
        addSubview(scrollView_Breeze)
        scrollView_Breeze.addSubview(cardsStack_Breeze)
        
        headerView_Breeze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(24)
        }
        scrollView_Breeze.snp.makeConstraints { make in
            make.top.equalTo(headerView_Breeze.snp.bottom).offset(14)
            make.left.right.equalToSuperview()
            make.height.equalTo(170)
            make.bottom.equalToSuperview().offset(-20)
        }
        cardsStack_Breeze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.bottom.equalToSuperview()
        }
    }
    
    /// 配置当季 Tips 数据
    func configure_Breeze(season_breeze: Season_Breeze, tips_breeze: [SeasonalTip_Breeze]) {
        // 更新 Section Header
        headerView_Breeze.subviews.forEach { $0.removeFromSuperview() }
        let header_breeze = UIView.homeSectionHeader_Breeze(
            title_breeze: "\(season_breeze.rawValue) Camping Tips",
            showSeeAll_breeze: true,
            action_breeze: { [weak self] in self?.onSeeAll_Breeze?() }
        )
        headerView_Breeze.addSubview(header_breeze)
        header_breeze.snp.makeConstraints { make in make.edges.equalToSuperview() }
        
        // 重建卡片
        cardsStack_Breeze.arrangedSubviews.forEach { $0.removeFromSuperview() }
        tipCards_Breeze.removeAll()
        
        for tip_breeze in tips_breeze {
            let card_breeze = SeasonTipCard_Breeze(tip_breeze: tip_breeze)
            // 点击卡片回调
            card_breeze.onTap_Breeze = { [weak self] tappedTip_breeze in
                self?.onCardTap_Breeze?(tappedTip_breeze)
            }
            cardsStack_Breeze.addArrangedSubview(card_breeze)
            card_breeze.snp.makeConstraints { make in
                make.width.equalTo(180)
                make.height.equalTo(160)
            }
            tipCards_Breeze.append(card_breeze)
        }
    }
}

// MARK: - 单张 Tip 卡片

/// 季节攻略卡片
/// 核心作用：展示一条露营 Tip（渐变背景 + 图标 + 类别 + 标题 + 内容摘要），点击触发详情回调
class SeasonTipCard_Breeze: UIView {
    
    /// 点击回调（传出当前 Tip 数据，由父级展示详情）
    var onTap_Breeze: ((SeasonalTip_Breeze) -> Void)?
    
    private var tip_Breeze: SeasonalTip_Breeze?
    
    private var gradientLayer_Breeze: CAGradientLayer?
    private let iconBg_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        v_breeze.layer.cornerRadius = 16
        return v_breeze
    }()
    private let iconView_Breeze: UIImageView = {
        let iv_breeze = UIImageView()
        iv_breeze.tintColor = .white
        iv_breeze.contentMode = .scaleAspectFit
        return iv_breeze
    }()
    private let categoryLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label_breeze.textColor = UIColor.white.withAlphaComponent(0.8)
        return label_breeze
    }()
    private let titleLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        label_breeze.textColor = .white
        label_breeze.numberOfLines = 2
        return label_breeze
    }()
    private let contentLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        label_breeze.textColor = UIColor.white.withAlphaComponent(0.82)
        label_breeze.numberOfLines = 2
        return label_breeze
    }()
    
    /// 按分类对应的渐变色（internal 供 TipDetailSheet 使用）
    static func exposedGradientColors_Breeze(for category_breeze: String) -> [CGColor] {
        return gradientColors_Breeze(for: category_breeze)
    }
    
    private static func gradientColors_Breeze(for category_breeze: String) -> [CGColor] {
        switch category_breeze {
        case "Gear":
            return [ColorConfig_Breeze.primaryGradientStart_Breeze.cgColor,
                    ColorConfig_Breeze.primaryGradientEnd_Breeze.cgColor]
        case "Outfit":
            return [ColorConfig_Breeze.accentDusk_Breeze.cgColor,
                    UIColor(hexstring_Breeze: "#6C5CE7").cgColor]
        case "Photography":
            return [ColorConfig_Breeze.secondaryGradientStart_Breeze.cgColor,
                    ColorConfig_Breeze.accentCoral_Breeze.cgColor]
        default: // Routes
            return [ColorConfig_Breeze.tertiaryGradientStart_Breeze.cgColor,
                    ColorConfig_Breeze.tertiaryGradientEnd_Breeze.cgColor]
        }
    }
    
    init(tip_breeze: SeasonalTip_Breeze) {
        super.init(frame: .zero)
        layer.cornerRadius = 18
        clipsToBounds = true
        layer.shadowColor = ColorConfig_Breeze.shadowColor_Breeze.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.12
        
        addSubview(iconBg_Breeze)
        iconBg_Breeze.addSubview(iconView_Breeze)
        addSubview(categoryLabel_Breeze)
        addSubview(titleLabel_Breeze)
        addSubview(contentLabel_Breeze)
        
        iconBg_Breeze.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(14)
            make.width.height.equalTo(32)
        }
        iconView_Breeze.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }
        categoryLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(iconBg_Breeze.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(14)
        }
        titleLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel_Breeze.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(14)
        }
        contentLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Breeze.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(14)
            make.bottom.lessThanOrEqualToSuperview().offset(-10)
        }
        
        let iconConf_breeze = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        iconView_Breeze.image = UIImage(systemName: tip_breeze.iconName_Breeze, withConfiguration: iconConf_breeze)
        categoryLabel_Breeze.text = tip_breeze.category_Breeze.uppercased()
        titleLabel_Breeze.text = tip_breeze.title_Breeze
        contentLabel_Breeze.text = tip_breeze.content_Breeze
        tip_Breeze = tip_breeze
        
        // 渐变背景在 layoutSubviews 中应用
        _gradientColors_Breeze = SeasonTipCard_Breeze.gradientColors_Breeze(for: tip_breeze.category_Breeze)
        
        // 点击手势
        let tap_breeze = UITapGestureRecognizer(target: self, action: #selector(handleTap_Breeze))
        addGestureRecognizer(tap_breeze)
        isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    @objc private func handleTap_Breeze() {
        guard let tip_breeze = tip_Breeze else { return }
        onTap_Breeze?(tip_breeze)
    }
    
    private var _gradientColors_Breeze: [CGColor] = []
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer_Breeze?.removeFromSuperlayer()
        guard !bounds.isEmpty else { return }
        let gradient_breeze = CAGradientLayer()
        gradient_breeze.frame = bounds
        gradient_breeze.colors = _gradientColors_Breeze
        gradient_breeze.startPoint = CGPoint(x: 0, y: 0)
        gradient_breeze.endPoint = CGPoint(x: 1, y: 1)
        layer.insertSublayer(gradient_breeze, at: 0)
        gradientLayer_Breeze = gradient_breeze
    }
}

// MARK: - 个人露营纪念相册入口 Section

/// 相册入口 Section
/// 核心作用：展示最近 4 张相册缩略图 + 添加按钮，点击进入完整相册页
class AlbumEntrySection_Breeze: UIView {
    
    var onOpenAlbum_Breeze: (() -> Void)?
    var onAddPhoto_Breeze: (() -> Void)?
    
    private let card_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.backgroundColor = .white
        v_breeze.layer.cornerRadius = 20
        v_breeze.layer.shadowColor = ColorConfig_Breeze.shadowColor_Breeze.cgColor
        v_breeze.layer.shadowOffset = CGSize(width: 0, height: 4)
        v_breeze.layer.shadowRadius = 12
        v_breeze.layer.shadowOpacity = 0.1
        return v_breeze
    }()
    
    private let headerView_Breeze = UIView()
    private let photoGrid_Breeze: UIStackView = {
        let stack_breeze = UIStackView()
        stack_breeze.axis = .horizontal
        stack_breeze.spacing = 8
        stack_breeze.distribution = .fillEqually
        return stack_breeze
    }()
    private let emptyHint_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.text = "Add your first camping memory +"
        label_breeze.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label_breeze.textColor = ColorConfig_Breeze.textPlaceholder_Breeze
        label_breeze.textAlignment = .center
        return label_breeze
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Breeze()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI_Breeze() {
        backgroundColor = ColorConfig_Breeze.backgroundPrimary_Breeze
        addSubview(card_Breeze)
        card_Breeze.addSubview(headerView_Breeze)
        card_Breeze.addSubview(photoGrid_Breeze)
        card_Breeze.addSubview(emptyHint_Breeze)
        
        card_Breeze.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(10)
            make.left.right.equalToSuperview().inset(20)
        }
        headerView_Breeze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(24)
        }
        photoGrid_Breeze.snp.makeConstraints { make in
            make.top.equalTo(headerView_Breeze.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(80)
            make.bottom.equalToSuperview().offset(-16)
        }
        emptyHint_Breeze.snp.makeConstraints { make in
            make.top.equalTo(headerView_Breeze.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        // 点击卡片跳转相册
        let tap_breeze = UITapGestureRecognizer(target: self, action: #selector(handleCardTap_Breeze))
        card_Breeze.addGestureRecognizer(tap_breeze)
        card_Breeze.isUserInteractionEnabled = true
    }
    
    func configure_Breeze(items_breeze: [CampingAlbumItem_Breeze]) {
        // Section Header
        headerView_Breeze.subviews.forEach { $0.removeFromSuperview() }
        let header_breeze = UIView.homeSectionHeader_Breeze(
            title_breeze: "My Camping Album",
            showSeeAll_breeze: true,
            action_breeze: { [weak self] in self?.onOpenAlbum_Breeze?() }
        )
        headerView_Breeze.addSubview(header_breeze)
        header_breeze.snp.makeConstraints { make in make.edges.equalToSuperview() }
        
        // 清空缩略图
        photoGrid_Breeze.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if items_breeze.isEmpty {
            photoGrid_Breeze.isHidden = true
            emptyHint_Breeze.isHidden = false
        } else {
            photoGrid_Breeze.isHidden = false
            emptyHint_Breeze.isHidden = true
            
            // 展示最多 3 张 + 1 个添加按钮
            let displayItems_breeze = Array(items_breeze.prefix(3))
            for item_breeze in displayItems_breeze {
                let thumb_breeze = makeThumb_Breeze(item_breeze: item_breeze)
                photoGrid_Breeze.addArrangedSubview(thumb_breeze)
            }
            // 最后一格：添加按钮
            let addBtn_breeze = makeAddThumb_Breeze()
            photoGrid_Breeze.addArrangedSubview(addBtn_breeze)
            // 不足 4 格时补 spacer
            while photoGrid_Breeze.arrangedSubviews.count < 4 {
                let spacer_breeze = UIView()
                photoGrid_Breeze.addArrangedSubview(spacer_breeze)
            }
        }
    }
    
    private func makeThumb_Breeze(item_breeze: CampingAlbumItem_Breeze) -> UIView {
        let container_breeze = UIView()
        container_breeze.layer.cornerRadius = 12
        container_breeze.clipsToBounds = true
        let media_breeze = MediaDisplayView_Breeze()
        media_breeze.configure_Breeze(mediaPath_Breeze: item_breeze.imagePath_Breeze)
        container_breeze.addSubview(media_breeze)
        media_breeze.snp.makeConstraints { make in make.edges.equalToSuperview() }
        return container_breeze
    }
    
    private func makeAddThumb_Breeze() -> UIView {
        let btn_breeze = UIButton(type: .system)
        btn_breeze.backgroundColor = ColorConfig_Breeze.tagBackground_Breeze
        btn_breeze.layer.cornerRadius = 12
        btn_breeze.layer.borderWidth = 1.5
        btn_breeze.layer.borderColor = ColorConfig_Breeze.border_Breeze.cgColor
        let config_breeze = UIImage.SymbolConfiguration(pointSize: 22, weight: .light)
        btn_breeze.setImage(UIImage(systemName: "plus", withConfiguration: config_breeze), for: .normal)
        btn_breeze.tintColor = ColorConfig_Breeze.primaryGradientStart_Breeze
        btn_breeze.addAction(UIAction { [weak self] _ in self?.onAddPhoto_Breeze?() }, for: .touchUpInside)
        return btn_breeze
    }
    
    @objc private func handleCardTap_Breeze() {
        onOpenAlbum_Breeze?()
    }
}

// MARK: - 热门帖子轮播 Section

/// 热门帖子轮播 Section
/// 核心作用：横向分页轮播展示点赞最多的帖子，点击进入详情
class HotPostsSection_Breeze: UIView {
    
    var onPostTap_Breeze: ((TitleModel_Breeze) -> Void)?
    
    private let headerView_Breeze = UIView()
    
    private let scrollView_Breeze: UIScrollView = {
        let sv_breeze = UIScrollView()
        sv_breeze.showsHorizontalScrollIndicator = false
        sv_breeze.clipsToBounds = false
        return sv_breeze
    }()
    
    private let cardsStack_Breeze: UIStackView = {
        let stack_breeze = UIStackView()
        stack_breeze.axis = .horizontal
        stack_breeze.spacing = 14
        stack_breeze.alignment = .center
        return stack_breeze
    }()
    
    private var posts_Breeze: [TitleModel_Breeze] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Breeze()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI_Breeze() {
        backgroundColor = ColorConfig_Breeze.backgroundPrimary_Breeze
        addSubview(headerView_Breeze)
        addSubview(scrollView_Breeze)
        scrollView_Breeze.addSubview(cardsStack_Breeze)
        
        headerView_Breeze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(24)
        }
        scrollView_Breeze.snp.makeConstraints { make in
            make.top.equalTo(headerView_Breeze.snp.bottom).offset(14)
            make.left.right.equalToSuperview()
            make.height.equalTo(220)
            make.bottom.equalToSuperview().offset(-20)
        }
        cardsStack_Breeze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.bottom.equalToSuperview()
        }
    }
    
    func configure_Breeze(posts_breeze: [TitleModel_Breeze]) {
        self.posts_Breeze = posts_breeze
        
        // Section Header
        headerView_Breeze.subviews.forEach { $0.removeFromSuperview() }
        let header_breeze = UIView.homeSectionHeader_Breeze(
            title_breeze: "Hot Stories",
            showSeeAll_breeze: false
        )
        headerView_Breeze.addSubview(header_breeze)
        header_breeze.snp.makeConstraints { make in make.edges.equalToSuperview() }
        
        // 重建卡片
        cardsStack_Breeze.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index_breeze, post_breeze) in posts_breeze.enumerated() {
            let card_breeze = HotPostCard_Breeze(post_breeze: post_breeze)
            card_breeze.tag = index_breeze
            let tap_breeze = UITapGestureRecognizer(target: self, action: #selector(handleCardTap_Breeze(_:)))
            card_breeze.addGestureRecognizer(tap_breeze)
            card_breeze.isUserInteractionEnabled = true
            cardsStack_Breeze.addArrangedSubview(card_breeze)
            card_breeze.snp.makeConstraints { make in
                make.width.equalTo(200)
                make.height.equalTo(210)
            }
        }
    }
    
    @objc private func handleCardTap_Breeze(_ gesture_breeze: UITapGestureRecognizer) {
        guard let tag_breeze = gesture_breeze.view?.tag, tag_breeze < posts_Breeze.count else { return }
        onPostTap_Breeze?(posts_Breeze[tag_breeze])
    }
}

// MARK: - 热门帖子卡片

/// 热门帖子卡片（竖排卡片：媒体封面 + 底部渐变遮罩 + 标题 + 作者 + 点赞数）
class HotPostCard_Breeze: UIView {
    
    private let mediaView_Breeze = MediaDisplayView_Breeze()
    private let overlayView_Breeze = UIView()
    private var overlayGradient_Breeze: CAGradientLayer?
    private let titleLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label_breeze.textColor = .white
        label_breeze.numberOfLines = 2
        return label_breeze
    }()
    private let authorLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        label_breeze.textColor = UIColor.white.withAlphaComponent(0.85)
        return label_breeze
    }()
    private let likeLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        label_breeze.textColor = ColorConfig_Breeze.accentCoral_Breeze
        return label_breeze
    }()
    
    init(post_breeze: TitleModel_Breeze) {
        super.init(frame: .zero)
        layer.cornerRadius = 18
        clipsToBounds = true
        layer.shadowColor = ColorConfig_Breeze.shadowColor_Breeze.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowRadius = 12
        layer.shadowOpacity = 0.12
        
        addSubview(mediaView_Breeze)
        addSubview(overlayView_Breeze)
        addSubview(titleLabel_Breeze)
        addSubview(authorLabel_Breeze)
        addSubview(likeLabel_Breeze)
        
        mediaView_Breeze.snp.makeConstraints { make in make.edges.equalToSuperview() }
        overlayView_Breeze.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(110)
        }
        titleLabel_Breeze.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(14)
            make.bottom.equalToSuperview().offset(-32)
        }
        authorLabel_Breeze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.bottom.equalToSuperview().offset(-12)
        }
        likeLabel_Breeze.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-14)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        mediaView_Breeze.configure_Breeze(mediaPath_Breeze: post_breeze.titleMeidas_Breeze.first)
        titleLabel_Breeze.text = post_breeze.title_Breeze
        authorLabel_Breeze.text = "by \(post_breeze.titleUserName_Breeze)"
        likeLabel_Breeze.text = "♥ \(post_breeze.likes_Breeze)"
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if overlayGradient_Breeze == nil {
            let gradient_breeze = CAGradientLayer()
            gradient_breeze.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.72).cgColor]
            gradient_breeze.locations = [0.0, 1.0]
            overlayView_Breeze.layer.insertSublayer(gradient_breeze, at: 0)
            overlayGradient_Breeze = gradient_breeze
        }
        overlayGradient_Breeze?.frame = overlayView_Breeze.bounds
    }
}

// MARK: - 季节 Tips 详情弹窗页

/// 季节 Tips 详情页（Sheet 弹出）
/// 核心作用：展示当季全部 Tips，以分类卡片列表形式呈现
class SeasonTipsDetailPage_Breeze: UIViewController {
    
    var season_Breeze: Season_Breeze = .spring_breeze
    var tips_Breeze: [SeasonalTip_Breeze] = []
    
    private let tableView_Breeze: UITableView = {
        let tv_breeze = UITableView(frame: .zero, style: .plain)
        tv_breeze.backgroundColor = ColorConfig_Breeze.backgroundPrimary_Breeze
        tv_breeze.separatorStyle = .none
        tv_breeze.showsVerticalScrollIndicator = false
        return tv_breeze
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Breeze.backgroundPrimary_Breeze
        
        let titleLabel_breeze = UILabel()
        titleLabel_breeze.text = "\(season_Breeze.rawValue) Camping Guide"
        titleLabel_breeze.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel_breeze.textColor = ColorConfig_Breeze.textPrimary_Breeze
        
        view.addSubview(titleLabel_breeze)
        view.addSubview(tableView_Breeze)
        
        titleLabel_breeze.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.left.equalToSuperview().offset(22)
        }
        tableView_Breeze.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_breeze.snp.bottom).offset(16)
            make.left.right.bottom.equalToSuperview()
        }
        
        tableView_Breeze.register(TipDetailCell_Breeze.self, forCellReuseIdentifier: TipDetailCell_Breeze.reuseId_Breeze)
        tableView_Breeze.dataSource = self
        tableView_Breeze.rowHeight = UITableView.automaticDimension
        tableView_Breeze.estimatedRowHeight = 120
    }
}

extension SeasonTipsDetailPage_Breeze: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { tips_Breeze.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell_breeze = tableView.dequeueReusableCell(withIdentifier: TipDetailCell_Breeze.reuseId_Breeze, for: indexPath) as! TipDetailCell_Breeze
        cell_breeze.configure_Breeze(tip_breeze: tips_Breeze[indexPath.row])
        return cell_breeze
    }
}

// MARK: - Tip 详情 Cell

class TipDetailCell_Breeze: UITableViewCell {
    
    static let reuseId_Breeze = "TipDetailCell_Breeze"
    
    private let card_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.backgroundColor = .white
        v_breeze.layer.cornerRadius = 16
        v_breeze.layer.shadowColor = ColorConfig_Breeze.shadowColor_Breeze.cgColor
        v_breeze.layer.shadowOffset = CGSize(width: 0, height: 3)
        v_breeze.layer.shadowRadius = 8
        v_breeze.layer.shadowOpacity = 0.08
        return v_breeze
    }()
    private let iconView_Breeze: UIImageView = {
        let iv_breeze = UIImageView()
        iv_breeze.tintColor = ColorConfig_Breeze.primaryGradientStart_Breeze
        iv_breeze.contentMode = .scaleAspectFit
        return iv_breeze
    }()
    private let categoryLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label_breeze.textColor = ColorConfig_Breeze.primaryGradientStart_Breeze
        return label_breeze
    }()
    private let titleLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label_breeze.textColor = ColorConfig_Breeze.textPrimary_Breeze
        label_breeze.numberOfLines = 0
        return label_breeze
    }()
    private let contentLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label_breeze.textColor = ColorConfig_Breeze.textSecondary_Breeze
        label_breeze.numberOfLines = 0
        return label_breeze
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(card_Breeze)
        card_Breeze.addSubview(iconView_Breeze)
        card_Breeze.addSubview(categoryLabel_Breeze)
        card_Breeze.addSubview(titleLabel_Breeze)
        card_Breeze.addSubview(contentLabel_Breeze)
        
        card_Breeze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.bottom.equalToSuperview().offset(-6)
            make.left.right.equalToSuperview().inset(16)
        }
        iconView_Breeze.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(16)
            make.width.height.equalTo(22)
        }
        categoryLabel_Breeze.snp.makeConstraints { make in
            make.centerY.equalTo(iconView_Breeze)
            make.left.equalTo(iconView_Breeze.snp.right).offset(8)
        }
        titleLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(iconView_Breeze.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(16)
        }
        contentLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Breeze.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure_Breeze(tip_breeze: SeasonalTip_Breeze) {
        let iconConf_breeze = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        iconView_Breeze.image = UIImage(systemName: tip_breeze.iconName_Breeze, withConfiguration: iconConf_breeze)
        categoryLabel_Breeze.text = tip_breeze.category_Breeze.uppercased()
        titleLabel_Breeze.text = tip_breeze.title_Breeze
        contentLabel_Breeze.text = tip_breeze.content_Breeze
    }
}

// MARK: - Tip 详情弹窗 Sheet

/// 季节 Tip 详情 Sheet（点击卡片后弹出）
/// 核心作用：以渐变头部卡 + 白色上浮内容卡结构全文展示露营攻略，带关闭按钮与标签区
/// 设计思路：固定高度渐变头（180pt）+ 白色上浮内容卡（圆角顶角，覆盖渐变下沿）+ 可滚动正文
class TipDetailSheet_Breeze: UIViewController {
    
    var tip_Breeze: SeasonalTip_Breeze?
    
    // MARK: - UI：渐变头部
    
    private let heroView_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.clipsToBounds = true
        return v_breeze
    }()
    private var heroGradient_Breeze: CAGradientLayer?
    
    /// 装饰大圆
    private let decorCircle_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        v_breeze.layer.cornerRadius = 60
        return v_breeze
    }()
    
    /// 关闭按钮
    private let closeButton_Breeze: UIButton = {
        let btn_breeze = UIButton(type: .system)
        let config_breeze = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
        btn_breeze.setImage(UIImage(systemName: "xmark", withConfiguration: config_breeze), for: .normal)
        btn_breeze.tintColor = .white
        btn_breeze.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        btn_breeze.layer.cornerRadius = 18
        return btn_breeze
    }()
    
    /// 大图标圆形背景
    private let iconRing_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        v_breeze.layer.cornerRadius = 32
        return v_breeze
    }()
    private let iconView_Breeze: UIImageView = {
        let iv_breeze = UIImageView()
        iv_breeze.tintColor = .white
        iv_breeze.contentMode = .scaleAspectFit
        return iv_breeze
    }()
    
    /// 分类标签胶囊
    private let categoryChip_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        v_breeze.layer.cornerRadius = 11
        return v_breeze
    }()
    private let categoryLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        label_breeze.textColor = .white
        return label_breeze
    }()
    
    /// 标题
    private let heroTitle_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 24, weight: .heavy)
        label_breeze.textColor = .white
        label_breeze.numberOfLines = 0
        return label_breeze
    }()
    
    // MARK: - UI：上浮内容卡
    
    private let contentCard_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.backgroundColor = .white
        v_breeze.layer.cornerRadius = 26
        v_breeze.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return v_breeze
    }()
    
    private let scrollView_Breeze: UIScrollView = {
        let sv_breeze = UIScrollView()
        sv_breeze.showsVerticalScrollIndicator = false
        sv_breeze.backgroundColor = .clear
        return sv_breeze
    }()
    
    private let contentLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label_breeze.textColor = ColorConfig_Breeze.textPrimary_Breeze
        label_breeze.numberOfLines = 0
        // 行高 1.5 倍提升可读性
        return label_breeze
    }()
    
    /// 季节标签
    private let seasonTag_Breeze = TipDetailSheet_Breeze.makeTag_Breeze(icon_breeze: "leaf.fill", color_breeze: ColorConfig_Breeze.tertiaryGradientEnd_Breeze)
    
    /// 分类标签
    private let categoryTag_Breeze = TipDetailSheet_Breeze.makeTag_Breeze(icon_breeze: "tag.fill", color_breeze: ColorConfig_Breeze.accentDusk_Breeze)
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Breeze.backgroundPrimary_Breeze
        guard let tip_breeze = tip_Breeze else { return }
        buildUI_Breeze(tip_breeze: tip_breeze)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshHeroGradient_Breeze()
    }
    
    // MARK: - UI 搭建
    
    private func buildUI_Breeze(tip_breeze: SeasonalTip_Breeze) {
        // 渐变头部
        view.addSubview(heroView_Breeze)
        heroView_Breeze.addSubview(decorCircle_Breeze)
        heroView_Breeze.addSubview(closeButton_Breeze)
        heroView_Breeze.addSubview(iconRing_Breeze)
        iconRing_Breeze.addSubview(iconView_Breeze)
        heroView_Breeze.addSubview(categoryChip_Breeze)
        categoryChip_Breeze.addSubview(categoryLabel_Breeze)
        heroView_Breeze.addSubview(heroTitle_Breeze)
        
        // 上浮内容卡
        view.addSubview(contentCard_Breeze)
        contentCard_Breeze.addSubview(scrollView_Breeze)
        scrollView_Breeze.addSubview(contentLabel_Breeze)
        scrollView_Breeze.addSubview(seasonTag_Breeze)
        scrollView_Breeze.addSubview(categoryTag_Breeze)
        
        // 渐变头部：固定高度 200pt
        heroView_Breeze.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(200)
        }
        decorCircle_Breeze.snp.makeConstraints { make in
            make.width.height.equalTo(120)
            make.right.equalToSuperview().offset(28)
            make.top.equalToSuperview().offset(-22)
        }
        closeButton_Breeze.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(14)
            make.right.equalToSuperview().offset(-18)
            make.width.height.equalTo(36)
        }
        iconRing_Breeze.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(14)
            make.left.equalToSuperview().offset(22)
            make.width.height.equalTo(64)
        }
        iconView_Breeze.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }
        categoryChip_Breeze.snp.makeConstraints { make in
            make.top.equalTo(iconRing_Breeze.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(22)
            make.height.equalTo(22)
        }
        categoryLabel_Breeze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }
        heroTitle_Breeze.snp.makeConstraints { make in
            make.top.equalTo(categoryChip_Breeze.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(22)
        }
        
        // 内容卡：从头部底部上浮 24pt
        contentCard_Breeze.snp.makeConstraints { make in
            make.top.equalTo(heroView_Breeze.snp.bottom).offset(-24)
            make.left.right.bottom.equalToSuperview()
        }
        scrollView_Breeze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentLabel_Breeze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(28)
            make.left.right.equalToSuperview().inset(22)
            make.width.equalToSuperview().offset(-44)
        }
        seasonTag_Breeze.snp.makeConstraints { make in
            make.top.equalTo(contentLabel_Breeze.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(22)
            make.height.equalTo(28)
            make.bottom.equalToSuperview().offset(-40)
        }
        categoryTag_Breeze.snp.makeConstraints { make in
            make.top.height.equalTo(seasonTag_Breeze)
            make.left.equalTo(seasonTag_Breeze.snp.right).offset(10)
        }
        
        // 填充数据
        let iconConf_breeze = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        iconView_Breeze.image = UIImage(systemName: tip_breeze.iconName_Breeze, withConfiguration: iconConf_breeze)
        categoryLabel_Breeze.text = tip_breeze.category_Breeze.uppercased()
        heroTitle_Breeze.text = tip_breeze.title_Breeze
        
        // 内容文字设置行距
        let paragraphStyle_breeze = NSMutableParagraphStyle()
        paragraphStyle_breeze.lineSpacing = 6
        paragraphStyle_breeze.lineBreakMode = .byWordWrapping
        let attrContent_breeze = NSAttributedString(
            string: tip_breeze.content_Breeze,
            attributes: [
                .font: UIFont.systemFont(ofSize: 16, weight: .regular),
                .foregroundColor: ColorConfig_Breeze.textPrimary_Breeze,
                .paragraphStyle: paragraphStyle_breeze
            ]
        )
        contentLabel_Breeze.attributedText = attrContent_breeze
        
        // 标签数据
        (seasonTag_Breeze.subviews.compactMap { $0 as? UILabel }.first)?.text = tip_breeze.season_Breeze.rawValue
        (categoryTag_Breeze.subviews.compactMap { $0 as? UILabel }.first)?.text = tip_breeze.category_Breeze
        
        closeButton_Breeze.addTarget(self, action: #selector(handleClose_Breeze), for: .touchUpInside)
    }
    
    private func refreshHeroGradient_Breeze() {
        heroGradient_Breeze?.removeFromSuperlayer()
        guard !heroView_Breeze.bounds.isEmpty else { return }
        let gradient_breeze = CAGradientLayer()
        gradient_breeze.frame = heroView_Breeze.bounds
        gradient_breeze.colors = tip_Breeze.map {
            SeasonTipCard_Breeze.exposedGradientColors_Breeze(for: $0.category_Breeze)
        } ?? [ColorConfig_Breeze.primaryGradientStart_Breeze.cgColor,
               ColorConfig_Breeze.primaryGradientEnd_Breeze.cgColor]
        gradient_breeze.startPoint = CGPoint(x: 0, y: 0)
        gradient_breeze.endPoint = CGPoint(x: 1, y: 1)
        heroView_Breeze.layer.insertSublayer(gradient_breeze, at: 0)
        heroGradient_Breeze = gradient_breeze
    }
    
    @objc private func handleClose_Breeze() {
        dismiss(animated: true)
    }
    
    // MARK: - 工厂
    
    /// 创建底部信息标签（图标 + 文字胶囊）
    private static func makeTag_Breeze(icon_breeze: String, color_breeze: UIColor) -> UIView {
        let container_breeze = UIView()
        container_breeze.backgroundColor = color_breeze.withAlphaComponent(0.12)
        container_breeze.layer.cornerRadius = 14
        
        let iconConf_breeze = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        let iv_breeze = UIImageView(image: UIImage(systemName: icon_breeze, withConfiguration: iconConf_breeze))
        iv_breeze.tintColor = color_breeze
        iv_breeze.contentMode = .scaleAspectFit
        
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label_breeze.textColor = color_breeze
        
        container_breeze.addSubview(iv_breeze)
        container_breeze.addSubview(label_breeze)
        iv_breeze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(13)
        }
        label_breeze.snp.makeConstraints { make in
            make.left.equalTo(iv_breeze.snp.right).offset(5)
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }
        return container_breeze
    }
}
