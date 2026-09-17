import UIKit
import SnapKit

/// VIP 订阅套餐卡片，负责展示套餐价格、货币和周期，并转发订阅点击事件。
/// 设计思路：使用固定内部间距和基线对齐的价格布局，由父视图约束卡片尺寸。
/// 关键方法：通过 configure_lens 更新展示内容，通过 onSubscribe_lens 向外传递操作。
final class VIPSubscriptionCard_lens: UIView {

    /// 订阅按钮点击回调，由页面关联对应套餐的购买操作。
    var onSubscribe_lens: (() -> Void)?

    private let titleLabel_lens: UILabel = {
        let label_lens = UILabel()
        label_lens.text = "Premium Member"
        label_lens.font = .systemFont(ofSize: 14)
        label_lens.textColor = .black
        label_lens.textAlignment = .center
        label_lens.adjustsFontSizeToFitWidth = true
        label_lens.minimumScaleFactor = 0.8
        return label_lens
    }()

    private let priceLabel_lens: UILabel = {
        let label_lens = UILabel()
        label_lens.font = .systemFont(ofSize: 36)
        label_lens.textColor = .white
        label_lens.textAlignment = .right
        label_lens.adjustsFontSizeToFitWidth = true
        label_lens.minimumScaleFactor = 0.45
        label_lens.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label_lens
    }()

    private let currencyLabel_lens: UILabel = {
        let label_lens = UILabel()
        label_lens.font = .systemFont(ofSize: 14)
        label_lens.textColor = .white
        label_lens.setContentCompressionResistancePriority(.required, for: .horizontal)
        label_lens.setContentHuggingPriority(.required, for: .horizontal)
        return label_lens
    }()

    private let priceStack_lens: UIStackView = {
        let stack_lens = UIStackView()
        stack_lens.axis = .horizontal
        stack_lens.alignment = .lastBaseline
        stack_lens.spacing = 4
        return stack_lens
    }()

    private let periodLabel_lens: UILabel = {
        let label_lens = UILabel()
        label_lens.font = .systemFont(ofSize: 20)
        label_lens.textColor = .black
        label_lens.textAlignment = .center
        label_lens.adjustsFontSizeToFitWidth = true
        label_lens.minimumScaleFactor = 0.65
        return label_lens
    }()

    private let subscribeButton_lens: UIButton = {
        let button_lens = UIButton(type: .system)
        button_lens.setTitle("Subscribe", for: .normal)
        button_lens.setTitleColor(.black, for: .normal)
        button_lens.titleLabel?.font = .systemFont(ofSize: 14)
        button_lens.backgroundColor = .white
        button_lens.layer.cornerRadius = 20
        button_lens.clipsToBounds = true
        return button_lens
    }()

    /// 创建套餐卡片并设置内部布局。
    /// - Parameter frame_lens: 卡片的初始位置和尺寸，最终尺寸由父视图约束确定。
    /// - Returns: 完成视图构建的卡片实例。
    override init(frame frame_lens: CGRect) {
        super.init(frame: frame_lens)
        setupUI_lens()
    }

    /// 从归档数据创建套餐卡片并设置内部布局。
    /// - Parameter coder_lens: 用于恢复视图的解码器。
    /// - Returns: 可选的卡片实例；父视图解码失败时返回空值。
    required init?(coder coder_lens: NSCoder) {
        super.init(coder: coder_lens)
        setupUI_lens()
    }

    /// 更新套餐展示内容，不执行购买或数据转换。
    /// - Parameters:
    ///   - price_lens: 已格式化的价格数值文本。
    ///   - currency_lens: 价格对应的货币符号或代码。
    ///   - period_lens: 已格式化的英文订阅周期。
    /// - Returns: 无返回值。
    func configure_lens(price_lens: String, currency_lens: String, period_lens: String) {
        priceLabel_lens.text = price_lens
        currencyLabel_lens.text = currency_lens
        periodLabel_lens.text = period_lens
        subscribeButton_lens.accessibilityLabel = "Subscribe, \(period_lens)"
    }

    /// 配置卡片样式、内容约束和按钮事件。
    /// - Parameters: 无参数。
    /// - Returns: 无返回值。
    private func setupUI_lens() {
        backgroundColor = UIColor(hexstring_Lens: "#8B22FF")
        layer.borderColor = UIColor(hexstring_Lens: "#B979FF").cgColor
        layer.borderWidth = 3
        layer.cornerRadius = 30
        clipsToBounds = true

        addSubview(titleLabel_lens)
        addSubview(priceStack_lens)
        addSubview(periodLabel_lens)
        addSubview(subscribeButton_lens)
        priceStack_lens.addArrangedSubview(priceLabel_lens)
        priceStack_lens.addArrangedSubview(currencyLabel_lens)

        titleLabel_lens.snp.makeConstraints { make_lens in
            make_lens.top.equalToSuperview().offset(22)
            make_lens.leading.trailing.equalToSuperview().inset(12)
            make_lens.height.equalTo(18)
        }

        priceStack_lens.snp.makeConstraints { make_lens in
            make_lens.top.equalToSuperview().offset(54)
            make_lens.centerX.equalToSuperview()
            make_lens.leading.greaterThanOrEqualToSuperview().offset(12)
            make_lens.trailing.lessThanOrEqualToSuperview().offset(-12)
            make_lens.height.equalTo(45)
        }

        periodLabel_lens.snp.makeConstraints { make_lens in
            make_lens.top.equalToSuperview().offset(108)
            make_lens.leading.trailing.equalToSuperview().inset(10)
            make_lens.height.equalTo(24)
        }

        subscribeButton_lens.snp.makeConstraints { make_lens in
            make_lens.leading.trailing.equalToSuperview().inset(8)
            make_lens.bottom.equalToSuperview().inset(10)
            make_lens.height.equalTo(40)
        }

        subscribeButton_lens.addTarget(self, action: #selector(handleSubscribe_lens), for: .touchUpInside)
    }

    /// 转发订阅按钮点击事件，由外部处理购买流程。
    /// - Parameters: 无参数。
    /// - Returns: 无返回值。
    @objc private func handleSubscribe_lens() {
        onSubscribe_lens?()
    }
}
