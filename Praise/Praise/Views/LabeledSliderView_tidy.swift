import Foundation
import UIKit
import SnapKit

// MARK: 通用滑杆组件

/// 通用带标题的滑杆组件
/// 核心作用：统一封装"标题 + 当前数值 + UISlider"的横向滑杆样式，供网格透明度、渐变强度等场景复用
/// 设计思路：标题与数值左右分布在同一行，下方为滑杆本体；数值展示格式可通过 configure_Tidy 的
///           valueFormatter_tidy 参数自定义
/// 关键属性/方法：
///   - currentValue_Tidy：只读访问滑杆当前值
///   - onValueChanged_Tidy：滑动过程中实时触发的回调
///   - configure_Tidy：配置标题、取值范围、初始值与数值格式化方式
class LabeledSliderView_Tidy: UIView {

    /// 数值变化回调（滑动过程中实时触发）
    var onValueChanged_Tidy: ((Float) -> Void)?

    /// 滑杆当前取值（外部只读访问）
    var currentValue_Tidy: Float { slider_Tidy.value }

    /// 数值格式化闭包，默认展示为百分比整数
    private var valueFormatter_Tidy: (Float) -> String = { String(format: "%.0f%%", $0 * 100) }

    private let titleLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        lb.textColor = ColorConfig_Tidy.textSecondary_Tidy
        return lb
    }()

    private let valueLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        lb.textColor = ColorConfig_Tidy.tidyMint_Tidy
        lb.textAlignment = .right
        return lb
    }()

    private let slider_Tidy: UISlider = {
        let s = UISlider()
        s.minimumTrackTintColor = ColorConfig_Tidy.tidyMint_Tidy
        s.maximumTrackTintColor = ColorConfig_Tidy.divider_Tidy
        s.thumbTintColor = ColorConfig_Tidy.tidyMint_Tidy
        return s
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Tidy()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI_Tidy()
    }

    private func setupUI_Tidy() {
        addSubview(titleLabel_Tidy)
        addSubview(valueLabel_Tidy)
        addSubview(slider_Tidy)

        titleLabel_Tidy.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }
        valueLabel_Tidy.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel_Tidy)
            make.trailing.equalToSuperview()
            make.leading.greaterThanOrEqualTo(titleLabel_Tidy.snp.trailing).offset(8)
        }
        slider_Tidy.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Tidy.snp.bottom).offset(4)
            make.leading.trailing.bottom.equalToSuperview()
        }
        slider_Tidy.addTarget(self, action: #selector(onSliderChanged_Tidy(_:)), for: .valueChanged)
    }

    /// 配置滑杆标题、取值范围、初始值与数值展示格式
    /// 参数：
    /// - title_tidy: 标题文案
    /// - min_tidy: 最小值，默认 0
    /// - max_tidy: 最大值，默认 1
    /// - value_tidy: 初始值
    /// - valueFormatter_tidy: 数值格式化闭包（可选，默认百分比展示）
    func configure_Tidy(
        title_tidy: String,
        min_tidy: Float = 0,
        max_tidy: Float = 1,
        value_tidy: Float,
        valueFormatter_tidy: ((Float) -> String)? = nil
    ) {
        titleLabel_Tidy.text = title_tidy
        slider_Tidy.minimumValue = min_tidy
        slider_Tidy.maximumValue = max_tidy
        slider_Tidy.value = value_tidy
        if let valueFormatter_tidy = valueFormatter_tidy {
            self.valueFormatter_Tidy = valueFormatter_tidy
        }
        valueLabel_Tidy.text = self.valueFormatter_Tidy(value_tidy)
    }

    /// 滑杆数值变化事件：更新数值文案并转发回调
    @objc private func onSliderChanged_Tidy(_ sender: UISlider) {
        valueLabel_Tidy.text = valueFormatter_Tidy(sender.value)
        onValueChanged_Tidy?(sender.value)
    }
}
