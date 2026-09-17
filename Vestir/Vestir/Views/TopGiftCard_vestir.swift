import UIKit
import SnapKit

/// 顶级一次性礼物卡片，负责横向排列礼物图片、价格、购买说明和购买按钮。
/// 采用透明背景与弹性说明区域适配不同屏宽，通过 onBuy_vestir 回传点击事件，由外部处理购买业务。
final class TopGiftCard_vestir: UIView {

    /// 购买按钮点击回调，不在组件内部执行商品购买逻辑。
    var onBuy_vestir: (() -> Void)?

    private let iconView_vestir: UIImageView = {
        let imageView_vestir = UIImageView()
        imageView_vestir.image = UIImage(named: "gift_one")?.withRenderingMode(.alwaysOriginal)
        imageView_vestir.contentMode = .scaleAspectFit
        return imageView_vestir
    }()

    private let priceLabel_vestir: UILabel = {
        let label_vestir = UILabel()
        label_vestir.font = .systemFont(ofSize: 15, weight: .heavy)
        label_vestir.textColor = .white
        label_vestir.numberOfLines = 1
        label_vestir.setContentHuggingPriority(.required, for: .horizontal)
        label_vestir.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label_vestir
    }()

    private let descriptionLabel_vestir: UILabel = {
        let label_vestir = UILabel()
        label_vestir.text = "Can Only Be Purchased Once"
        label_vestir.font = .systemFont(ofSize: 10, weight: .regular)
        label_vestir.textColor = .white
        label_vestir.numberOfLines = 2
        label_vestir.lineBreakMode = .byWordWrapping
        label_vestir.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label_vestir.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label_vestir
    }()

    private let buyButton_vestir: UIButton = {
        let button_vestir = UIButton(type: .system)
        button_vestir.setTitle("BUY", for: .normal)
        button_vestir.setTitleColor(.white, for: .normal)
        button_vestir.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button_vestir.backgroundColor = UIColor(hexstring_Vestir: "#6155D9")
        button_vestir.layer.cornerRadius = 22
        button_vestir.clipsToBounds = true
        button_vestir.accessibilityLabel = "Buy one-time gift"
        return button_vestir
    }()

    /// 创建礼物卡片并完成展示约束及点击事件绑定。
    /// - Returns: TopGiftCard_vestir 实例；无参数、无异常。
    init() {
        super.init(frame: .zero)
        buildLayout_vestir()
    }

    /// 不支持通过归档创建本组件。
    /// - Parameter coder_vestir: 界面归档解码器。
    /// - Returns: 不返回实例；调用时终止执行。
    required init?(coder coder_vestir: NSCoder) {
        fatalError("顶级礼物卡片不支持归档初始化")
    }

    /// 绑定商品价格并根据是否存在有效商品控制按钮交互。
    /// - Parameter gift_vestir: 顶级礼物模型，为空时清空价格并禁用购买。
    /// - Returns: 无返回值；无异常。
    func configure_vestir(gift_vestir: StoreModel_Vestir?) {
        priceLabel_vestir.text = gift_vestir?.goodsPrice_Vestir ?? ""
        buyButton_vestir.isEnabled = gift_vestir?.goodsId_Vestir != nil
        buyButton_vestir.alpha = buyButton_vestir.isEnabled ? 1 : 0.45
    }

    /// 组装横向内容，固定购买按钮尺寸并允许说明在窄屏换行。
    /// - Returns: 无返回值；无参数、无异常。
    private func buildLayout_vestir() {
        backgroundColor = .clear

        let contentStack_vestir = UIStackView(arrangedSubviews: [
            iconView_vestir,
            priceLabel_vestir,
            descriptionLabel_vestir,
            buyButton_vestir
        ])
        contentStack_vestir.axis = .horizontal
        contentStack_vestir.alignment = .center
        contentStack_vestir.spacing = 8
        addSubview(contentStack_vestir)

        contentStack_vestir.snp.makeConstraints { make_vestir in
            make_vestir.leading.trailing.centerY.equalToSuperview()
            make_vestir.top.greaterThanOrEqualToSuperview()
            make_vestir.bottom.lessThanOrEqualToSuperview()
        }
        iconView_vestir.snp.makeConstraints { make_vestir in
            make_vestir.width.equalTo(52).priority(750)
            make_vestir.width.greaterThanOrEqualTo(44)
            make_vestir.height.equalTo(iconView_vestir.snp.width)
        }
        buyButton_vestir.snp.makeConstraints { make_vestir in
            make_vestir.width.equalTo(68)
            make_vestir.height.equalTo(44)
        }

        buyButton_vestir.addTarget(self, action: #selector(buyTapped_vestir), for: .touchUpInside)
    }

    /// 将购买点击转发给外部绑定的事件处理器。
    /// - Returns: 无返回值；无参数、无异常。
    @objc private func buyTapped_vestir() {
        onBuy_vestir?()
    }
}
