import Foundation
import UIKit
import SnapKit

// MARK: 标注滑块行组件

/// 标注滑块行组件
/// 核心作用：统一样式的"标签 + 数值 + 滑块"行，供胶片参数手动调节面板、硬件特效面板等
///          需要多个连续数值调节项的页面复用，避免重复实现相同布局
/// 设计思路：
///   - 顶部左侧为参数名称，右侧为当前数值（格式化闭包可自定义展示形式，如百分号/正负号）
///   - 底部为系统 UISlider，最小值轨道与滑块颜色跟随传入的强调色，与所在页面主题呼应
/// 关键属性：
///   - onValueChanged_Lumia: 数值变化回调，用于驱动本地实时渲染预览
///   - valueFormatter_Lumia: 数值展示格式化闭包
class LabeledSliderRow_Lumia: UIView {

    // MARK: - 回调与配置

    /// 滑块数值变化回调（实时触发）
    var onValueChanged_Lumia: ((Float) -> Void)?

    /// 数值展示格式化闭包，默认展示为百分比整数
    var valueFormatter_Lumia: (Float) -> String = { value_Lumia in
        "\(Int(value_Lumia * 100))%"
    }

    /// 内部滑块（暴露给外部以便必要时读取当前值）
    let slider_Lumia = UISlider()

    // MARK: - UI组件

    private let titleLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        return lbl_Lumia
    }()

    private let valueLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        lbl_Lumia.textAlignment = .right
        return lbl_Lumia
    }()

    // MARK: - 初始化

    /// 初始化标注滑块行
    /// - Parameters:
    ///   - title_Lumia: 参数名称
    ///   - titleColor_Lumia: 标签与数值文字颜色
    ///   - accentColor_Lumia: 滑块高亮色（轨道已滑过部分 + 拖动圆点）
    init(title_Lumia: String, titleColor_Lumia: UIColor, accentColor_Lumia: UIColor) {
        super.init(frame: .zero)
        titleLabel_Lumia.text = title_Lumia
        titleLabel_Lumia.textColor = titleColor_Lumia
        valueLabel_Lumia.textColor = titleColor_Lumia.withAlphaComponent(0.75)
        setupUI_Lumia(accentColor_Lumia: accentColor_Lumia)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI设置

    private func setupUI_Lumia(accentColor_Lumia: UIColor) {
        addSubview(titleLabel_Lumia)
        titleLabel_Lumia.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }

        addSubview(valueLabel_Lumia)
        valueLabel_Lumia.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel_Lumia)
            make.trailing.equalToSuperview()
            make.leading.greaterThanOrEqualTo(titleLabel_Lumia.snp.trailing).offset(8)
            make.width.greaterThanOrEqualTo(40)
        }

        slider_Lumia.minimumTrackTintColor = accentColor_Lumia
        slider_Lumia.thumbTintColor = accentColor_Lumia
        slider_Lumia.maximumTrackTintColor = accentColor_Lumia.withAlphaComponent(0.18)
        slider_Lumia.addTarget(self, action: #selector(handleValueChanged_Lumia), for: .valueChanged)
        addSubview(slider_Lumia)
        slider_Lumia.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Lumia.snp.bottom).offset(4)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    // MARK: - 公共方法

    /// 配置滑块范围与当前值
    /// - Parameters:
    ///   - minValue_Lumia: 最小值
    ///   - maxValue_Lumia: 最大值
    ///   - currentValue_Lumia: 当前值
    func configure_Lumia(minValue_Lumia: Float, maxValue_Lumia: Float, currentValue_Lumia: Float) {
        slider_Lumia.minimumValue = minValue_Lumia
        slider_Lumia.maximumValue = maxValue_Lumia
        slider_Lumia.value = currentValue_Lumia
        valueLabel_Lumia.text = valueFormatter_Lumia(currentValue_Lumia)
    }

    // MARK: - 事件处理

    @objc private func handleValueChanged_Lumia() {
        valueLabel_Lumia.text = valueFormatter_Lumia(slider_Lumia.value)
        onValueChanged_Lumia?(slider_Lumia.value)
    }
}
