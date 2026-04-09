import UIKit
import SnapKit

// MARK: - 分类选项单元格

/// 家居分类选项单元格
/// 功能：展示单个分类的图标与名称
/// 支持两种样式：
///   - homeGrid_tidy：首页竖排大卡片（图标上、文字下）
///   - discoverTab_tidy：发现页横排胶囊（彩色图标方块 + 分类名称）
class CategoryItemCell_Tidy: UICollectionViewCell {

    // MARK: - 样式枚举
    enum DisplayStyle_Tidy {
        case homeGrid_tidy
        case discoverTab_tidy
    }

    // MARK: - UI 组件

    /// 背景容器（圆角、选中背景色）
    private let containerView_Tidy: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 14
        v.clipsToBounds = false
        v.backgroundColor = .white
        return v
    }()

    /// 渐变背景层（选中时显示）
    private var gradientLayer_Tidy: CAGradientLayer?

    // MARK: discoverTab 专用：图标彩色方块背景
    private let iconBgView_Tidy: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 8
        v.clipsToBounds = true
        return v
    }()

    /// homeGrid 专用：图标圆形背景（分类色浅 tint 圆圈）
    private let iconCircleBg_Tidy: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 24
        v.clipsToBounds = true
        return v
    }()

    /// 分类图标
    private let iconView_Tidy: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = ColorConfig_Tidy.tidyMint_Tidy
        return iv
    }()

    /// 分类名称
    private let nameLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        lb.textColor = ColorConfig_Tidy.textPrimary_Tidy
        lb.textAlignment = .center
        lb.adjustsFontSizeToFitWidth = true
        lb.minimumScaleFactor = 0.8
        return lb
    }()

    // MARK: - 私有属性
    private var category_Tidy: HomeCategory_Tidy?
    private var displayStyle_Tidy: DisplayStyle_Tidy = .homeGrid_tidy

    // MARK: - 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Tidy()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI_Tidy()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer_Tidy?.frame = containerView_Tidy.bounds
        if displayStyle_Tidy == .discoverTab_tidy {
            containerView_Tidy.layer.cornerRadius = containerView_Tidy.bounds.height / 2
        }
    }

    // MARK: - UI 搭建
    private func setupUI_Tidy() {
        backgroundColor = .clear

        // 阴影（仅 homeGrid 场景可见）
        contentView.layer.shadowColor = ColorConfig_Tidy.shadowColor_Tidy.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 3)
        contentView.layer.shadowRadius = 10
        contentView.layer.shadowOpacity = 1
        contentView.layer.masksToBounds = false

        contentView.addSubview(containerView_Tidy)
        containerView_Tidy.snp.makeConstraints { make in make.edges.equalToSuperview() }

        containerView_Tidy.addSubview(iconBgView_Tidy)
        containerView_Tidy.addSubview(iconCircleBg_Tidy)
        containerView_Tidy.addSubview(iconView_Tidy)
        containerView_Tidy.addSubview(nameLabel_Tidy)
    }

    // MARK: - 布局切换

    /// homeGrid：图标圆背景在上、名称在下，圆角大卡片
    private func applyHomeGridLayout_Tidy() {
        contentView.layer.shadowOpacity = 1
        iconBgView_Tidy.isHidden = true
        iconCircleBg_Tidy.isHidden = false

        iconCircleBg_Tidy.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(12)
            make.width.height.equalTo(48)
        }
        iconCircleBg_Tidy.layer.cornerRadius = 24

        iconView_Tidy.snp.remakeConstraints { make in
            make.center.equalTo(iconCircleBg_Tidy)
            make.width.height.equalTo(26)
        }
        nameLabel_Tidy.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(iconCircleBg_Tidy.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(4)
            make.bottom.lessThanOrEqualToSuperview().offset(-8)
        }
        containerView_Tidy.layer.cornerRadius = 18
    }

    /// discoverTab：彩色图标方块 + 文字，胶囊形
    private func applyDiscoverTabLayout_Tidy() {
        contentView.layer.shadowOpacity = 0
        iconBgView_Tidy.isHidden = false
        iconCircleBg_Tidy.isHidden = true

        iconBgView_Tidy.snp.remakeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(26)
        }
        iconView_Tidy.snp.remakeConstraints { make in
            make.center.equalTo(iconBgView_Tidy)
            make.width.height.equalTo(14)
        }
        nameLabel_Tidy.snp.remakeConstraints { make in
            make.leading.equalTo(iconBgView_Tidy.snp.trailing).offset(6)
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
        nameLabel_Tidy.textAlignment = .left
        containerView_Tidy.layer.cornerRadius = contentView.bounds.height / 2
    }

    // MARK: - 数据绑定

    /// 配置分类单元格
    /// 参数：
    /// - category_tidy: 分类数据
    /// - isSelected_tidy: 是否选中
    /// - style_tidy: 展示样式
    func configure_Tidy(category_tidy: HomeCategory_Tidy,
                            isSelected_tidy: Bool,
                            style_tidy: DisplayStyle_Tidy = .homeGrid_tidy) {
        self.category_Tidy   = category_tidy
        self.displayStyle_Tidy = style_tidy

        switch style_tidy {
        case .homeGrid_tidy:    applyHomeGridLayout_Tidy()
        case .discoverTab_tidy: applyDiscoverTabLayout_Tidy()
        }

        nameLabel_Tidy.text = category_tidy.name_Tidy

        let ptSize: CGFloat = style_tidy == .homeGrid_tidy ? 22 : 13
        let cfg = UIImage.SymbolConfiguration(pointSize: ptSize, weight: .semibold)
        iconView_Tidy.image = UIImage(systemName: category_tidy.iconName_Tidy, withConfiguration: cfg)

        updateSelectedState_Tidy(isSelected_tidy: isSelected_tidy, animated: false)
    }

    // MARK: - 选中态

    /// 更新选中视觉状态
    /// 参数：
    /// - isSelected_tidy: 是否选中
    /// - animated: 是否动画
    func updateSelectedState_Tidy(isSelected_tidy: Bool, animated: Bool = true) {
        guard let cat = category_Tidy else { return }
        let catColor = ColorConfig_Tidy.colorForCategory_Tidy(cat.id_Tidy)

        let block = {
            if isSelected_tidy {
                self.applySelectedGradient_Tidy(color_tidy: catColor)
                self.iconView_Tidy.tintColor = .white
                self.nameLabel_Tidy.textColor = .white
                // discoverTab icon 方块：白色半透明
                self.iconBgView_Tidy.backgroundColor = UIColor.white.withAlphaComponent(0.28)
                // homeGrid icon 圆背景：白色半透明
                self.iconCircleBg_Tidy.backgroundColor = UIColor.white.withAlphaComponent(0.26)
                self.containerView_Tidy.transform = CGAffineTransform(scaleX: 1.04, y: 1.04)
            } else {
                self.removeSelectedGradient_Tidy()
                self.containerView_Tidy.backgroundColor = .white
                self.iconView_Tidy.tintColor = catColor
                self.nameLabel_Tidy.textColor = ColorConfig_Tidy.textPrimary_Tidy
                // discoverTab icon 方块：分类色 15% 透明背景
                self.iconBgView_Tidy.backgroundColor = catColor.withAlphaComponent(0.12)
                // homeGrid icon 圆背景：分类色浅 tint
                self.iconCircleBg_Tidy.backgroundColor = catColor.withAlphaComponent(0.12)
                self.containerView_Tidy.transform = .identity
            }
        }

        if animated {
            UIView.animate(withDuration: AnimationConfig_Tidy.durationSpring_Tidy,
                           delay: 0,
                           usingSpringWithDamping: AnimationConfig_Tidy.springDampingNormal_Tidy,
                           initialSpringVelocity: AnimationConfig_Tidy.springVelocity_Tidy,
                           options: [.curveEaseOut],
                           animations: block)
        } else {
            block()
        }
    }

    private func applySelectedGradient_Tidy(color_tidy: UIColor) {
        gradientLayer_Tidy?.removeFromSuperlayer()
        containerView_Tidy.backgroundColor = .clear

        let grad = CAGradientLayer()
        grad.frame = containerView_Tidy.bounds.isEmpty
            ? CGRect(x: 0, y: 0, width: 100, height: 38)
            : containerView_Tidy.bounds
        grad.colors = [color_tidy.cgColor,
                       color_tidy.withAlphaComponent(0.78).cgColor]
        grad.startPoint = CGPoint(x: 0, y: 0.5)
        grad.endPoint   = CGPoint(x: 1, y: 0.5)
        grad.cornerRadius = containerView_Tidy.layer.cornerRadius
        containerView_Tidy.layer.insertSublayer(grad, at: 0)
        gradientLayer_Tidy = grad
    }

    private func removeSelectedGradient_Tidy() {
        gradientLayer_Tidy?.removeFromSuperlayer()
        gradientLayer_Tidy = nil
    }

    // MARK: - 触摸反馈
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        UIView.animate(withDuration: 0.1) {
            self.containerView_Tidy.transform = CGAffineTransform(scaleX: 0.93, y: 0.93)
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: AnimationConfig_Tidy.durationSpring_Tidy,
                       delay: 0,
                       usingSpringWithDamping: AnimationConfig_Tidy.springDampingLight_Tidy,
                       initialSpringVelocity: AnimationConfig_Tidy.springVelocity_Tidy,
                       options: []) {
            self.containerView_Tidy.transform = .identity
        }
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        UIView.animate(withDuration: 0.1) { self.containerView_Tidy.transform = .identity }
    }
}
