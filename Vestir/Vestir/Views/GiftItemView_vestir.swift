import UIKit
import SnapKit

/// 普通礼物卡片：按图标、数量、价格纵向排列，仅负责展示与点击事件。
/// 设计思路：图标随列宽缩放、文字限制在卡片内部，通过系统选中状态统一刷新样式。
/// 关键属性：礼物模型用于显示商品信息，选中状态用于控制边框和无障碍标记。
final class GiftItemView_vestir: UIControl {

    let gift_vestir: StoreModel_Vestir
    private let iconView_vestir = UIImageView()
    private let quantityLabel_vestir = UILabel()
    private let priceLabel_vestir = UILabel()

    override var isSelected: Bool {
        didSet { refreshAppearance_vestir() }
    }

    /// 创建绑定商品和图标的礼物卡片。
    /// 参数：gift_vestir 为商品模型，iconName_vestir 为资源名称。
    /// 返回值：礼物卡片实例；异常：图标不存在时图片为空，不影响文字和点击。
    init(gift_vestir: StoreModel_Vestir, iconName_vestir: String) {
        self.gift_vestir = gift_vestir
        super.init(frame: .zero)
        iconView_vestir.image = UIImage(named: iconName_vestir)?.withRenderingMode(.alwaysOriginal)
        buildUI_vestir()
        refreshAppearance_vestir()
    }

    /// 声明归档初始化入口，本组件仅支持代码创建。
    /// 参数：coder_vestir 为归档解码器；返回值：无；异常：调用时终止并提示不支持。
    required init?(coder coder_vestir: NSCoder) {
        fatalError("礼物卡片仅支持代码初始化")
    }

    /// 构建自适应图标和两行文字，预留上下内边距以避免拥挤和裁切。
    /// 参数：无；返回值：无（Void）；异常：无。
    private func buildUI_vestir() {
        layer.cornerRadius = 15
        layer.borderWidth = 2
        clipsToBounds = true
        isAccessibilityElement = true
        accessibilityLabel = "\(gift_vestir.goodsName_Vestir ?? "") gifts, \(gift_vestir.goodsPrice_Vestir ?? "")"

        iconView_vestir.contentMode = .scaleAspectFit
        iconView_vestir.isUserInteractionEnabled = false
        addSubview(iconView_vestir)

        quantityLabel_vestir.text = gift_vestir.goodsName_Vestir
        quantityLabel_vestir.font = .systemFont(ofSize: 11, weight: .medium)
        quantityLabel_vestir.textAlignment = .center
        quantityLabel_vestir.adjustsFontSizeToFitWidth = true
        quantityLabel_vestir.minimumScaleFactor = 0.8
        addSubview(quantityLabel_vestir)

        priceLabel_vestir.text = gift_vestir.goodsPrice_Vestir
        priceLabel_vestir.font = .systemFont(ofSize: 14, weight: .semibold)
        priceLabel_vestir.textAlignment = .center
        priceLabel_vestir.adjustsFontSizeToFitWidth = true
        priceLabel_vestir.minimumScaleFactor = 0.8
        addSubview(priceLabel_vestir)

        iconView_vestir.snp.makeConstraints { make_vestir in
            make_vestir.top.equalToSuperview().offset(6)
            make_vestir.centerX.equalToSuperview()
            make_vestir.width.equalTo(60).priority(750)
            make_vestir.width.lessThanOrEqualToSuperview().offset(-12)
            make_vestir.height.equalTo(iconView_vestir.snp.width)
        }
        priceLabel_vestir.snp.makeConstraints { make_vestir in
            make_vestir.leading.trailing.equalToSuperview().inset(5)
            make_vestir.bottom.equalToSuperview().offset(-10)
            make_vestir.height.equalTo(18)
        }
        quantityLabel_vestir.snp.makeConstraints { make_vestir in
            make_vestir.leading.trailing.equalToSuperview().inset(5)
            make_vestir.bottom.equalTo(priceLabel_vestir.snp.top).offset(-3)
            make_vestir.top.greaterThanOrEqualTo(iconView_vestir.snp.bottom).offset(4)
            make_vestir.height.equalTo(14)
        }
    }

    /// 切换选中背景、文字颜色及无障碍状态。
    /// 参数：无；返回值：无（Void）；异常：无。
    private func refreshAppearance_vestir() {
        backgroundColor = UIColor(hexstring_Vestir: isSelected ? "#6155D9" : "#2353E4")
        layer.borderColor = (isSelected ? UIColor.white : UIColor.clear).cgColor
        quantityLabel_vestir.textColor = UIColor(hexstring_Vestir: "#FFFFFF", alpha_Vestir: 0.85)
        priceLabel_vestir.textColor = .white
        accessibilityTraits = isSelected ? [.button, .selected] : [.button]
    }
}
