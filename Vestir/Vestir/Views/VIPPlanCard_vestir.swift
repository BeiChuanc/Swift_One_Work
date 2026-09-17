import UIKit
import SnapKit

/// VIP 套餐卡片：以居中的价格和套餐名称展示单个订阅商品，仅负责展示与点击事件。
/// 设计思路：保持深色圆角背景，通过系统选中状态统一切换紫色文字、细边框及无障碍状态。
/// 关键属性：model_vestir 保存展示模型，isSelected 控制选中样式，外部通过系统事件绑定交互。
final class VIPPlanCard_vestir: UIControl {

    let model_vestir: StoreModel_Vestir
    private let priceLabel_vestir = UILabel()
    private let nameLabel_vestir = UILabel()

    /// 系统选中状态变化时同步刷新卡片外观。
    override var isSelected: Bool {
        didSet { refreshAppearance_vestir() }
    }

    /// 卡片默认高度为 80 点，宽度由父容器按照可用空间决定。
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 80)
    }

    /// 创建绑定订阅商品的套餐卡片。
    /// 参数：model_vestir 为订阅商品模型，读取其中的价格和套餐名称。
    /// 返回值：VIP 套餐卡片实例；异常：商品文字为空时不显示对应内容，不影响点击。
    init(model_vestir: StoreModel_Vestir) {
        self.model_vestir = model_vestir
        super.init(frame: .zero)
        buildUI_vestir()
        refreshAppearance_vestir()
    }

    /// 声明归档初始化入口，本组件仅支持代码创建。
    /// 参数：coder_vestir 为归档解码器；返回值：无；异常：调用时终止并提示不支持。
    required init?(coder coder_vestir: NSCoder) {
        fatalError("VIP 套餐卡片仅支持代码初始化")
    }

    /// 构建两行居中文字，并通过缩放和水平内边距避免窄屏文字裁切。
    /// 参数：无；返回值：无（Void）；异常：无。
    private func buildUI_vestir() {
        backgroundColor = UIColor(hexstring_Vestir: "#20162D")
        layer.cornerRadius = 14
        layer.borderWidth = 0.8
        clipsToBounds = true
        isAccessibilityElement = true
        accessibilityLabel = "\(model_vestir.goodsName_Vestir ?? "Premium"), \(model_vestir.goodsPrice_Vestir ?? "")"

        priceLabel_vestir.text = model_vestir.goodsPrice_Vestir
        priceLabel_vestir.font = .systemFont(ofSize: 22, weight: .heavy)
        priceLabel_vestir.textAlignment = .center
        priceLabel_vestir.adjustsFontSizeToFitWidth = true
        priceLabel_vestir.minimumScaleFactor = 0.75
        priceLabel_vestir.isAccessibilityElement = false
        addSubview(priceLabel_vestir)

        nameLabel_vestir.text = model_vestir.goodsName_Vestir
        nameLabel_vestir.font = .systemFont(ofSize: 14, weight: .bold)
        nameLabel_vestir.textAlignment = .center
        nameLabel_vestir.adjustsFontSizeToFitWidth = true
        nameLabel_vestir.minimumScaleFactor = 0.75
        nameLabel_vestir.isAccessibilityElement = false
        addSubview(nameLabel_vestir)

        priceLabel_vestir.snp.makeConstraints { make_vestir in
            make_vestir.top.equalToSuperview().offset(11)
            make_vestir.leading.trailing.equalToSuperview().inset(10)
            make_vestir.height.equalTo(26)
        }
        nameLabel_vestir.snp.makeConstraints { make_vestir in
            make_vestir.top.equalTo(priceLabel_vestir.snp.bottom).offset(12)
            make_vestir.leading.trailing.equalToSuperview().inset(8)
            make_vestir.height.equalTo(19)
            make_vestir.bottom.lessThanOrEqualToSuperview().offset(-10)
        }
    }

    /// 更新选中文字和细边框，并为辅助功能同步选中标记。
    /// 参数：无；返回值：无（Void）；异常：无。
    private func refreshAppearance_vestir() {
        let selectedColor_vestir = UIColor(hexstring_Vestir: "#655BE8")
        let textColor_vestir: UIColor = isSelected ? selectedColor_vestir : .white
        priceLabel_vestir.textColor = textColor_vestir
        nameLabel_vestir.textColor = textColor_vestir
        layer.borderColor = (isSelected ? selectedColor_vestir : UIColor.clear).cgColor
        accessibilityTraits = isSelected ? [.button, .selected] : [.button]
    }
}
