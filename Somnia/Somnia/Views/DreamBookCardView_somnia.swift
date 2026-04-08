import Foundation
import UIKit
import SnapKit

// MARK: - 梦境册卡片视图

/// 梦境册卡片视图
/// 核心功能：以渐变卡片形式展示单个梦境册，包含封面图标、名称、梦境数量徽章
/// 设计理念：圆角卡片 + 主题渐变色 + 柔和阴影，支持点击回调
/// 使用场景：首页梦境册横向滚动区域中的单个卡片
class DreamBookCardView_Somnia: UIView {

    // MARK: - 私有 UI 属性

    /// 渐变背景图层
    private var gradientLayer_Somnia: CAGradientLayer?

    /// 封面图标
    private let iconView_Somnia = UIImageView()

    /// 梦境册名称标签
    private let titleLabel_Somnia = UILabel()

    /// 梦境数量徽章容器
    private let countBadge_Somnia = UIView()

    /// 梦境数量文字
    private let countLabel_Somnia = UILabel()

    /// 装饰性月亮图标
    private let moonDecor_Somnia = UIImageView()

    // MARK: - 回调

    /// 卡片点击回调，携带梦境册模型
    var onTapped_Somnia: ((DreamBookModel_Somnia) -> Void)?

    // MARK: - 数据模型

    private var bookModel_Somnia: DreamBookModel_Somnia?

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Somnia()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI_Somnia()
    }

    // MARK: - UI 构建

    /// 初始化卡片内部子视图和样式
    private func setupUI_Somnia() {
        layer.cornerRadius = 20
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.withAlphaComponent(0.15).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 6)
        layer.shadowRadius = 12
        layer.shadowOpacity = 1

        // 渐变背景层（颜色在 configure 时动态更新）
        let grad_Somnia = CAGradientLayer()
        grad_Somnia.cornerRadius = 20
        grad_Somnia.startPoint = CGPoint(x: 0, y: 0)
        grad_Somnia.endPoint = CGPoint(x: 1, y: 1)
        layer.insertSublayer(grad_Somnia, at: 0)
        gradientLayer_Somnia = grad_Somnia

        // 装饰月亮
        moonDecor_Somnia.image = UIImage(systemName: "moon.stars.fill")
        moonDecor_Somnia.tintColor = UIColor.white.withAlphaComponent(0.18)
        moonDecor_Somnia.contentMode = .scaleAspectFit
        addSubview(moonDecor_Somnia)

        // 图标
        iconView_Somnia.contentMode = .scaleAspectFit
        iconView_Somnia.tintColor = .white
        addSubview(iconView_Somnia)

        // 名称
        titleLabel_Somnia.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        titleLabel_Somnia.textColor = .white
        titleLabel_Somnia.numberOfLines = 2
        titleLabel_Somnia.textAlignment = .left
        addSubview(titleLabel_Somnia)

        // 数量徽章
        countBadge_Somnia.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        countBadge_Somnia.layer.cornerRadius = 10
        addSubview(countBadge_Somnia)

        countLabel_Somnia.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        countLabel_Somnia.textColor = .white
        countLabel_Somnia.textAlignment = .center
        countBadge_Somnia.addSubview(countLabel_Somnia)

        setupConstraints_Somnia()

        // 点击手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap_Somnia))
        addGestureRecognizer(tap)
    }

    /// 设置内部子视图约束
    private func setupConstraints_Somnia() {
        moonDecor_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-10)
            make.trailing.equalToSuperview().offset(10)
            make.width.height.equalTo(70)
        }

        iconView_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(28)
        }

        titleLabel_Somnia.snp.makeConstraints { make in
            make.top.equalTo(iconView_Somnia.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-12)
        }

        countBadge_Somnia.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-14)
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(22)
        }

        countLabel_Somnia.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        }
    }

    // MARK: - 数据配置

    /// 用梦境册数据配置卡片显示内容
    /// - Parameter book_somnia: 梦境册模型
    func configure_Somnia(book_somnia: DreamBookModel_Somnia) {
        bookModel_Somnia = book_somnia
        titleLabel_Somnia.text = book_somnia.bookTitle_Somnia
        iconView_Somnia.image = UIImage(systemName: book_somnia.bookIcon_Somnia)

        let dreamText = "\(book_somnia.dreamCount_Somnia) dreams"
        countLabel_Somnia.text = dreamText

        // 根据主题色生成渐变：主色 → 加深版
        let baseColor = UIColor(hexstring_Somnia: book_somnia.bookColorHex_Somnia)
        let deepColor  = baseColor.adjustBrightness_Somnia(by_somnia: -0.15)
        gradientLayer_Somnia?.colors = [baseColor.cgColor, deepColor.cgColor]

        setNeedsLayout()
    }

    // MARK: - 布局更新

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer_Somnia?.frame = bounds
    }

    // MARK: - 交互事件

    /// 卡片点击处理
    @objc private func handleTap_Somnia() {
        guard let model = bookModel_Somnia else { return }
        animatePressDown_Somnia {
            self.animatePressUp_Somnia()
        }
        onTapped_Somnia?(model)
    }
}

// MARK: - 新建梦境册卡片

/// 「新建梦境册」引导卡片
/// 核心功能：首页梦境册列表末尾展示的「+ 新建」卡片，点击触发创建流程
class DreamBookNewCardView_Somnia: UIView {

    // MARK: - 私有 UI 属性

    private let plusIcon_Somnia   = UIImageView()
    private let hintLabel_Somnia  = UILabel()

    // MARK: - 回调

    /// 点击回调
    var onTapped_Somnia: (() -> Void)?

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Somnia()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI_Somnia()
    }

    // MARK: - UI 构建

    private func setupUI_Somnia() {
        backgroundColor = ColorConfig_Somnia.backgroundPrimary_Somnia
        layer.cornerRadius = 20
        layer.borderWidth = 1.5
        layer.borderColor = ColorConfig_Somnia.primaryGradientStart_Somnia.withAlphaComponent(0.4).cgColor
        layer.shadowColor = UIColor.black.withAlphaComponent(0.06).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        layer.shadowOpacity = 1

        plusIcon_Somnia.image = UIImage(systemName: "plus.circle.fill")
        plusIcon_Somnia.tintColor = ColorConfig_Somnia.primaryGradientStart_Somnia
        plusIcon_Somnia.contentMode = .scaleAspectFit
        addSubview(plusIcon_Somnia)

        hintLabel_Somnia.text = "New Book"
        hintLabel_Somnia.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        hintLabel_Somnia.textColor = ColorConfig_Somnia.primaryGradientStart_Somnia
        hintLabel_Somnia.textAlignment = .center
        addSubview(hintLabel_Somnia)

        plusIcon_Somnia.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-10)
            make.width.height.equalTo(32)
        }

        hintLabel_Somnia.snp.makeConstraints { make in
            make.top.equalTo(plusIcon_Somnia.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap_Somnia))
        addGestureRecognizer(tap)
    }

    @objc private func handleTap_Somnia() {
        animatePressDown_Somnia {
            self.animatePressUp_Somnia()
        }
        onTapped_Somnia?()
    }
}

// MARK: - UIColor 亮度调整扩展

extension UIColor {

    /// 调整颜色亮度
    /// - Parameter by_somnia: 正值增亮，负值变暗（范围 -1 ~ 1）
    /// - Returns: 调整后的颜色
    func adjustBrightness_Somnia(by_somnia delta: CGFloat) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            return UIColor(hue: h, saturation: s, brightness: max(0, min(1, b + delta)), alpha: a)
        }
        return self
    }
}
