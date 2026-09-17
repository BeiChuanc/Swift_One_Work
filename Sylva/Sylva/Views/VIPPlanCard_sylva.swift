import UIKit
import SnapKit

/// 可复用的会员套餐卡片，负责价格、套餐名称与选中状态的展示。
/// 采用独立控件与垂直内容布局，点击通过回调传递给外部，购买业务由调用方处理。
/// 关键属性为价格标签、名称标签和选择回调，配置内容与更新选中态可分别调用。
final class VIPPlanCard_sylva: UIControl {

    /// 用户点击套餐时通知调用方更新所选套餐。
    var onSelect_sylva: (() -> Void)?

    private let priceLabel_sylva = UILabel()
    private let nameLabel_sylva = UILabel()
    private let contentStack_sylva = UIStackView()

    /// 根据指定尺寸创建套餐卡片并初始化内容布局。
    /// - Parameter frame_sylva: 卡片初始位置与尺寸，默认由外部约束决定。
    /// - Returns: 初始化完成的套餐卡片实例。
    /// - Note: 不抛出异常。
    override init(frame frame_sylva: CGRect = .zero) {
        super.init(frame: frame_sylva)
        setupAppearance_sylva()
        setupLayout_sylva()
        applySelection_sylva(isSelected_sylva: false)
    }

    /// 从系统归档恢复套餐卡片并重新建立展示内容。
    /// - Parameter coder_sylva: 用于还原视图的系统归档解码器。
    /// - Returns: 解码成功时返回卡片实例，否则由父类返回空值。
    /// - Note: 不抛出异常，套餐文本需要调用方重新配置。
    required init?(coder coder_sylva: NSCoder) {
        super.init(coder: coder_sylva)
        setupAppearance_sylva()
        setupLayout_sylva()
        applySelection_sylva(isSelected_sylva: false)
    }

    /// 设置圆角、字体、自适应文本与点击回调入口。
    /// - Returns: 无返回值，不抛出异常。
    private func setupAppearance_sylva() {
        layer.cornerRadius = 14
        clipsToBounds = true
        isAccessibilityElement = true
        accessibilityTraits = .button
        addTarget(self, action: #selector(selectPlan_sylva), for: .touchUpInside)

        let priceFont_sylva = UIFont.systemFont(ofSize: 26, weight: .heavy)
        let priceDescriptor_sylva = priceFont_sylva.fontDescriptor.withDesign(.rounded)
            ?? priceFont_sylva.fontDescriptor
        priceLabel_sylva.font = UIFont(descriptor: priceDescriptor_sylva, size: 26)
        nameLabel_sylva.font = UIFont.systemFont(ofSize: 16, weight: .regular)

        for label_sylva in [priceLabel_sylva, nameLabel_sylva] {
            label_sylva.textAlignment = .center
            label_sylva.numberOfLines = 1
            label_sylva.adjustsFontSizeToFitWidth = true
            label_sylva.minimumScaleFactor = 0.65
            label_sylva.isUserInteractionEnabled = false
            label_sylva.isAccessibilityElement = false
        }

        contentStack_sylva.axis = .vertical
        contentStack_sylva.alignment = .fill
        contentStack_sylva.spacing = 10
        contentStack_sylva.isUserInteractionEnabled = false
    }

    /// 建立居中的价格与套餐名称布局，并保留四周内边距以避免文字溢出。
    /// - Returns: 无返回值，不抛出异常。
    private func setupLayout_sylva() {
        contentStack_sylva.addArrangedSubview(priceLabel_sylva)
        contentStack_sylva.addArrangedSubview(nameLabel_sylva)
        addSubview(contentStack_sylva)

        contentStack_sylva.snp.makeConstraints { make_sylva in
            make_sylva.leading.trailing.equalToSuperview().inset(10)
            make_sylva.centerY.equalToSuperview()
            make_sylva.top.greaterThanOrEqualToSuperview().offset(10)
            make_sylva.bottom.lessThanOrEqualToSuperview().inset(10)
        }
    }

    /// 更新已格式化的价格与英文套餐名称。
    /// - Parameters:
    ///   - price_sylva: 已按当前商品货币格式处理的价格文本。
    ///   - name_sylva: 在界面中展示的英文套餐名称。
    /// - Returns: 无返回值，不抛出异常。
    func configure_sylva(price_sylva: String, name_sylva: String) {
        priceLabel_sylva.text = price_sylva
        nameLabel_sylva.text = name_sylva
        accessibilityLabel = "\(name_sylva), \(price_sylva)"
    }

    /// 根据所选状态更新背景、文本颜色和辅助功能状态。
    /// - Parameter isSelected_sylva: 当前卡片是否对应已选套餐。
    /// - Returns: 无返回值，不抛出异常。
    func applySelection_sylva(isSelected_sylva: Bool) {
        isSelected = isSelected_sylva
        backgroundColor = UIColor(hexstring_Sylva: isSelected_sylva ? "#009A76" : "#FFFFFF")
        let textColor_sylva = UIColor(hexstring_Sylva: isSelected_sylva ? "#FFFFFF" : "#111111")
        priceLabel_sylva.textColor = textColor_sylva
        nameLabel_sylva.textColor = textColor_sylva
        accessibilityTraits = isSelected_sylva ? [.button, .selected] : .button
    }

    /// 将套餐点击事件转交给外部处理。
    /// - Returns: 无返回值，不抛出异常。
    @objc private func selectPlan_sylva() {
        onSelect_sylva?()
    }
}
