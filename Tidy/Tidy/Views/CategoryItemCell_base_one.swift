import UIKit
import SnapKit

// MARK: - 分类选项单元格

/// 家居分类选项单元格
/// 功能：展示单个分类的图标与名称
/// 支持两种样式：
///   - homeGrid_base_one：首页竖排大卡片（图标上、文字下）
///   - discoverTab_base_one：发现页横排胶囊（彩色图标方块 + 分类名称）
class CategoryItemCell_Base_one: UICollectionViewCell {

    // MARK: - 样式枚举
    enum DisplayStyle_Base_one {
        case homeGrid_base_one
        case discoverTab_base_one
    }

    // MARK: - UI 组件

    /// 背景容器（圆角、选中背景色）
    private let containerView_Base_one: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 14
        v.clipsToBounds = false
        v.backgroundColor = .white
        return v
    }()

    /// 渐变背景层（选中时显示）
    private var gradientLayer_Base_one: CAGradientLayer?

    // MARK: discoverTab 专用：图标彩色方块背景
    private let iconBgView_Base_one: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 8
        v.clipsToBounds = true
        return v
    }()

    /// homeGrid 专用：图标圆形背景（分类色浅 tint 圆圈）
    private let iconCircleBg_Base_one: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 24
        v.clipsToBounds = true
        return v
    }()

    /// 分类图标
    private let iconView_Base_one: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = ColorConfig_Base_one.tidyMint_Base_one
        return iv
    }()

    /// 分类名称
    private let nameLabel_Base_one: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        lb.textColor = ColorConfig_Base_one.textPrimary_Base_one
        lb.textAlignment = .center
        lb.adjustsFontSizeToFitWidth = true
        lb.minimumScaleFactor = 0.8
        return lb
    }()

    // MARK: - 私有属性
    private var category_Base_one: HomeCategory_Base_one?
    private var displayStyle_Base_one: DisplayStyle_Base_one = .homeGrid_base_one

    // MARK: - 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Base_one()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI_Base_one()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer_Base_one?.frame = containerView_Base_one.bounds
        if displayStyle_Base_one == .discoverTab_base_one {
            containerView_Base_one.layer.cornerRadius = containerView_Base_one.bounds.height / 2
        }
    }

    // MARK: - UI 搭建
    private func setupUI_Base_one() {
        backgroundColor = .clear

        // 阴影（仅 homeGrid 场景可见）
        contentView.layer.shadowColor = ColorConfig_Base_one.shadowColor_Base_one.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 3)
        contentView.layer.shadowRadius = 10
        contentView.layer.shadowOpacity = 1
        contentView.layer.masksToBounds = false

        contentView.addSubview(containerView_Base_one)
        containerView_Base_one.snp.makeConstraints { make in make.edges.equalToSuperview() }

        containerView_Base_one.addSubview(iconBgView_Base_one)
        containerView_Base_one.addSubview(iconCircleBg_Base_one)
        containerView_Base_one.addSubview(iconView_Base_one)
        containerView_Base_one.addSubview(nameLabel_Base_one)
    }

    // MARK: - 布局切换

    /// homeGrid：图标圆背景在上、名称在下，圆角大卡片
    private func applyHomeGridLayout_Base_one() {
        contentView.layer.shadowOpacity = 1
        iconBgView_Base_one.isHidden = true
        iconCircleBg_Base_one.isHidden = false

        iconCircleBg_Base_one.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(12)
            make.width.height.equalTo(48)
        }
        iconCircleBg_Base_one.layer.cornerRadius = 24

        iconView_Base_one.snp.remakeConstraints { make in
            make.center.equalTo(iconCircleBg_Base_one)
            make.width.height.equalTo(26)
        }
        nameLabel_Base_one.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(iconCircleBg_Base_one.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(4)
            make.bottom.lessThanOrEqualToSuperview().offset(-8)
        }
        containerView_Base_one.layer.cornerRadius = 18
    }

    /// discoverTab：彩色图标方块 + 文字，胶囊形
    private func applyDiscoverTabLayout_Base_one() {
        contentView.layer.shadowOpacity = 0
        iconBgView_Base_one.isHidden = false
        iconCircleBg_Base_one.isHidden = true

        iconBgView_Base_one.snp.remakeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(26)
        }
        iconView_Base_one.snp.remakeConstraints { make in
            make.center.equalTo(iconBgView_Base_one)
            make.width.height.equalTo(14)
        }
        nameLabel_Base_one.snp.remakeConstraints { make in
            make.leading.equalTo(iconBgView_Base_one.snp.trailing).offset(6)
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
        nameLabel_Base_one.textAlignment = .left
        containerView_Base_one.layer.cornerRadius = contentView.bounds.height / 2
    }

    // MARK: - 数据绑定

    /// 配置分类单元格
    /// 参数：
    /// - category_base_one: 分类数据
    /// - isSelected_base_one: 是否选中
    /// - style_base_one: 展示样式
    func configure_Base_one(category_base_one: HomeCategory_Base_one,
                            isSelected_base_one: Bool,
                            style_base_one: DisplayStyle_Base_one = .homeGrid_base_one) {
        self.category_Base_one   = category_base_one
        self.displayStyle_Base_one = style_base_one

        switch style_base_one {
        case .homeGrid_base_one:    applyHomeGridLayout_Base_one()
        case .discoverTab_base_one: applyDiscoverTabLayout_Base_one()
        }

        nameLabel_Base_one.text = category_base_one.name_Base_one

        let ptSize: CGFloat = style_base_one == .homeGrid_base_one ? 22 : 13
        let cfg = UIImage.SymbolConfiguration(pointSize: ptSize, weight: .semibold)
        iconView_Base_one.image = UIImage(systemName: category_base_one.iconName_Base_one, withConfiguration: cfg)

        updateSelectedState_Base_one(isSelected_base_one: isSelected_base_one, animated: false)
    }

    // MARK: - 选中态

    /// 更新选中视觉状态
    /// 参数：
    /// - isSelected_base_one: 是否选中
    /// - animated: 是否动画
    func updateSelectedState_Base_one(isSelected_base_one: Bool, animated: Bool = true) {
        guard let cat = category_Base_one else { return }
        let catColor = ColorConfig_Base_one.colorForCategory_Base_one(cat.id_Base_one)

        let block = {
            if isSelected_base_one {
                self.applySelectedGradient_Base_one(color_base_one: catColor)
                self.iconView_Base_one.tintColor = .white
                self.nameLabel_Base_one.textColor = .white
                // discoverTab icon 方块：白色半透明
                self.iconBgView_Base_one.backgroundColor = UIColor.white.withAlphaComponent(0.28)
                // homeGrid icon 圆背景：白色半透明
                self.iconCircleBg_Base_one.backgroundColor = UIColor.white.withAlphaComponent(0.26)
                self.containerView_Base_one.transform = CGAffineTransform(scaleX: 1.04, y: 1.04)
            } else {
                self.removeSelectedGradient_Base_one()
                self.containerView_Base_one.backgroundColor = .white
                self.iconView_Base_one.tintColor = catColor
                self.nameLabel_Base_one.textColor = ColorConfig_Base_one.textPrimary_Base_one
                // discoverTab icon 方块：分类色 15% 透明背景
                self.iconBgView_Base_one.backgroundColor = catColor.withAlphaComponent(0.12)
                // homeGrid icon 圆背景：分类色浅 tint
                self.iconCircleBg_Base_one.backgroundColor = catColor.withAlphaComponent(0.12)
                self.containerView_Base_one.transform = .identity
            }
        }

        if animated {
            UIView.animate(withDuration: AnimationConfig_Base_one.durationSpring_Base_one,
                           delay: 0,
                           usingSpringWithDamping: AnimationConfig_Base_one.springDampingNormal_Base_one,
                           initialSpringVelocity: AnimationConfig_Base_one.springVelocity_Base_one,
                           options: [.curveEaseOut],
                           animations: block)
        } else {
            block()
        }
    }

    private func applySelectedGradient_Base_one(color_base_one: UIColor) {
        gradientLayer_Base_one?.removeFromSuperlayer()
        containerView_Base_one.backgroundColor = .clear

        let grad = CAGradientLayer()
        grad.frame = containerView_Base_one.bounds.isEmpty
            ? CGRect(x: 0, y: 0, width: 100, height: 38)
            : containerView_Base_one.bounds
        grad.colors = [color_base_one.cgColor,
                       color_base_one.withAlphaComponent(0.78).cgColor]
        grad.startPoint = CGPoint(x: 0, y: 0.5)
        grad.endPoint   = CGPoint(x: 1, y: 0.5)
        grad.cornerRadius = containerView_Base_one.layer.cornerRadius
        containerView_Base_one.layer.insertSublayer(grad, at: 0)
        gradientLayer_Base_one = grad
    }

    private func removeSelectedGradient_Base_one() {
        gradientLayer_Base_one?.removeFromSuperlayer()
        gradientLayer_Base_one = nil
    }

    // MARK: - 触摸反馈
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        UIView.animate(withDuration: 0.1) {
            self.containerView_Base_one.transform = CGAffineTransform(scaleX: 0.93, y: 0.93)
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: AnimationConfig_Base_one.durationSpring_Base_one,
                       delay: 0,
                       usingSpringWithDamping: AnimationConfig_Base_one.springDampingLight_Base_one,
                       initialSpringVelocity: AnimationConfig_Base_one.springVelocity_Base_one,
                       options: []) {
            self.containerView_Base_one.transform = .identity
        }
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        UIView.animate(withDuration: 0.1) { self.containerView_Base_one.transform = .identity }
    }
}
