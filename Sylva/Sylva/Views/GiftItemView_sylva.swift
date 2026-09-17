import UIKit
import SnapKit

/// 可复用礼物卡片，仅负责图标、数量、价格和选中态的展示。
/// 设计采用独立的商品点击区域与赠送按钮，避免二者事件相互拦截；通过回调交由外部处理业务。
/// 关键属性包括商品内容区域、赠送按钮和选择回调，配置方法与选中态方法可独立调用。
final class GiftItemView_sylva: UIView {

    /// 点击商品内容时通知外部选择当前礼物。
    var onSelect_sylva: (() -> Void)?

    /// 点击赠送按钮时通知外部执行赠送流程。
    var onGiveAway_sylva: (() -> Void)?

    private let contentControl_sylva = UIControl()
    private let iconView_sylva = UIImageView()
    private let quantityLabel_sylva = UILabel()
    private let priceLabel_sylva = UILabel()
    private let giveAwayButton_sylva = UIButton(type: .system)

    /// 创建指定图标的礼物卡片，由调用方设置卡片在网格中的尺寸。
    /// - Parameter iconName_sylva: 资源目录中的礼物图标名称。
    /// - Returns: 初始化完成的礼物卡片实例。
    /// - Note: 不抛出异常，资源不存在时保留空白图标区域。
    init(iconName_sylva: String) {
        super.init(frame: .zero)
        iconView_sylva.image = UIImage(named: iconName_sylva)?.withRenderingMode(.alwaysOriginal)
        setupAppearance_sylva()
        setupLayout_sylva()
        applySelection_sylva(isSelected_sylva: false)
    }

    /// 从归档恢复卡片的基础视图结构。
    /// - Parameter coder_sylva: 用于还原视图的系统归档解码器。
    /// - Returns: 解码成功时返回卡片实例，否则由父类返回空值。
    /// - Note: 不抛出异常，图标与商品文本需要调用方重新配置。
    required init?(coder coder_sylva: NSCoder) {
        super.init(coder: coder_sylva)
        setupAppearance_sylva()
        setupLayout_sylva()
        applySelection_sylva(isSelected_sylva: false)
    }

    /// 配置颜色、字体与独立点击事件。
    /// - Returns: 无返回值，不抛出异常。
    private func setupAppearance_sylva() {
        backgroundColor = .clear
        layer.cornerRadius = 12
        layer.shadowColor = UIColor(hexstring_Sylva: "#004D37").cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 3

        contentControl_sylva.backgroundColor = UIColor(hexstring_Sylva: "#FFFFFF", alpha_Sylva: 0.12)
        contentControl_sylva.layer.cornerRadius = 12
        contentControl_sylva.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        contentControl_sylva.clipsToBounds = true
        contentControl_sylva.isAccessibilityElement = true
        contentControl_sylva.accessibilityTraits = .button
        contentControl_sylva.addTarget(self, action: #selector(selectGift_sylva), for: .touchUpInside)

        iconView_sylva.contentMode = .scaleAspectFit
        quantityLabel_sylva.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        priceLabel_sylva.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
        for label_sylva in [quantityLabel_sylva, priceLabel_sylva] {
            label_sylva.textColor = UIColor(hexstring_Sylva: "#000000")
            label_sylva.textAlignment = .center
            label_sylva.numberOfLines = 1
            label_sylva.adjustsFontSizeToFitWidth = true
            label_sylva.minimumScaleFactor = 0.8
        }

        giveAwayButton_sylva.setTitle("Give Away", for: .normal)
        giveAwayButton_sylva.setTitleColor(UIColor(hexstring_Sylva: "#000000"), for: .normal)
        giveAwayButton_sylva.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        giveAwayButton_sylva.titleLabel?.adjustsFontSizeToFitWidth = true
        giveAwayButton_sylva.titleLabel?.minimumScaleFactor = 0.8
        giveAwayButton_sylva.backgroundColor = UIColor(hexstring_Sylva: "#009C73")
        giveAwayButton_sylva.layer.cornerRadius = 12
        giveAwayButton_sylva.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        giveAwayButton_sylva.clipsToBounds = true
        giveAwayButton_sylva.addTarget(self, action: #selector(giveAway_sylva), for: .touchUpInside)
    }

    /// 建立商品主体与固定赠送区域的布局，窄屏下自动限制图标宽度以避免溢出。
    /// - Returns: 无返回值，不抛出异常。
    private func setupLayout_sylva() {
        addSubview(contentControl_sylva)
        addSubview(giveAwayButton_sylva)
        contentControl_sylva.addSubview(iconView_sylva)
        contentControl_sylva.addSubview(quantityLabel_sylva)
        contentControl_sylva.addSubview(priceLabel_sylva)

        contentControl_sylva.snp.makeConstraints { make_sylva in
            make_sylva.top.leading.trailing.equalToSuperview()
            make_sylva.height.equalTo(96)
        }
        giveAwayButton_sylva.snp.makeConstraints { make_sylva in
            make_sylva.top.equalTo(contentControl_sylva.snp.bottom)
            make_sylva.leading.trailing.equalToSuperview()
            make_sylva.height.equalTo(22)
            make_sylva.bottom.equalToSuperview()
        }
        iconView_sylva.snp.makeConstraints { make_sylva in
            make_sylva.top.equalToSuperview().offset(4)
            make_sylva.centerX.equalToSuperview()
            make_sylva.height.equalTo(54)
            make_sylva.width.equalTo(54).priority(999)
            make_sylva.width.lessThanOrEqualTo(contentControl_sylva.snp.width).offset(-8)
        }
        quantityLabel_sylva.snp.makeConstraints { make_sylva in
            make_sylva.top.equalTo(iconView_sylva.snp.bottom).offset(2)
            make_sylva.leading.trailing.equalToSuperview().inset(4)
            make_sylva.height.equalTo(14)
        }
        priceLabel_sylva.snp.makeConstraints { make_sylva in
            make_sylva.top.equalTo(quantityLabel_sylva.snp.bottom)
            make_sylva.leading.trailing.equalToSuperview().inset(4)
            make_sylva.height.equalTo(18)
            make_sylva.bottom.equalToSuperview().inset(4)
        }
    }

    /// 更新礼物数量和已格式化的价格文本。
    /// - Parameters:
    ///   - quantity_sylva: 英文界面展示的数量，例如“1x”。
    ///   - price_sylva: 英文界面展示的价格，例如“$4.99”。
    /// - Returns: 无返回值，不抛出异常。
    func configure_sylva(quantity_sylva: String, price_sylva: String) {
        quantityLabel_sylva.text = quantity_sylva
        priceLabel_sylva.text = price_sylva
        contentControl_sylva.accessibilityLabel = "\(quantity_sylva), \(price_sylva)"
    }

    /// 切换卡片描边、阴影与赠送按钮显示状态，隐藏时保留底部区域避免网格位移。
    /// - Parameter isSelected_sylva: 当前卡片是否为已选中的礼物。
    /// - Returns: 无返回值，不抛出异常。
    func applySelection_sylva(isSelected_sylva: Bool) {
        layer.borderWidth = isSelected_sylva ? 1 : 0
        layer.borderColor = UIColor(hexstring_Sylva: "#009C73").cgColor
        layer.shadowOpacity = isSelected_sylva ? 0.24 : 0
        giveAwayButton_sylva.isHidden = !isSelected_sylva
        contentControl_sylva.accessibilityTraits = isSelected_sylva ? [.button, .selected] : .button
    }

    /// 将商品点击事件转交给调用方。
    /// - Returns: 无返回值，不抛出异常。
    @objc private func selectGift_sylva() {
        onSelect_sylva?()
    }

    /// 将赠送点击事件转交给调用方。
    /// - Returns: 无返回值，不抛出异常。
    @objc private func giveAway_sylva() {
        onGiveAway_sylva?()
    }
}
