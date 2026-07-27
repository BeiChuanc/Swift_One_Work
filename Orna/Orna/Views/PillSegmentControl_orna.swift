import Foundation
import UIKit
import SnapKit

// MARK: - 胶囊分段控件

/// 通用胶囊分段控件
/// 核心作用：以圆角胶囊 + 滑动选中背景呈现二选一（或多选一）切换控件，供各页面标签切换复用
/// 设计思路：
///   - 选中态背板不再通过手动读取按钮 frame 再转换坐标系的方式定位（该方式在容器父视图的
///     Auto Layout 尚未完成内部 UIStackView 的 fillEqually 重新分配前即被读取，会拿到过期的
///     "按内容自适应宽度"的旧帧，导致背板只包裹文字而非铺满按钮实际占位的一半宽度），
///     而是改为直接与选中按钮建立 SnapKit 约束（edges.equalTo(button)），交由 Auto Layout
///     统一求解，从根本上避免"背板与按钮实际占位不一致"的时序问题
/// 关键属性：
///   - onSelectionChanged_Orna: 用户主动点击切换时触发的回调
/// 关键方法：
///   - setSelectedIndex_Orna: 外部同步选中状态（不触发回调，避免循环刷新）
class PillSegmentControl_Orna: UIView {

    /// 选中项变化回调（用户点击触发）
    var onSelectionChanged_Orna: ((Int) -> Void)?

    private var buttons_Orna: [UIButton] = []

    private let selectedBackgroundView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Orna: "#7B61FF")
        return v
    }()

    private var selectedIndex_Orna: Int = 0

    /// 初始化
    /// 参数：
    /// - titles_Orna: 各分段标题
    init(titles_Orna: [String]) {
        super.init(frame: .zero)
        backgroundColor = UIColor(hexstring_Orna: "#EDE9FE")
        layer.cornerRadius = 20
        // 裁剪超出圆角胶囊范围的内容，避免选中态背板方形边角在容器圆角处露出不协调的直角
        clipsToBounds = true
        // 选中态背板圆角与容器保持一致，使其与容器边缘完全贴合，避免露出外层浅色边框形成"双层"视觉
        selectedBackgroundView_Orna.layer.cornerRadius = 20
        addSubview(selectedBackgroundView_Orna)

        let stack_orna = UIStackView()
        stack_orna.axis = .horizontal
        stack_orna.distribution = .fillEqually
        addSubview(stack_orna)
        // 与容器边缘完全贴合（不留内边距），使选中背板能够与容器边框完全重合，只呈现单层视觉
        stack_orna.snp.makeConstraints { $0.edges.equalToSuperview() }

        for (index_orna, title_orna) in titles_Orna.enumerated() {
            // 使用 .custom 而非 .system，避免系统在选中态下自动叠加默认强调色背板，
            // 确保选中态视觉完全由 selectedBackgroundView_Orna 单独呈现，不出现叠加的双重背景色块
            let button_orna = UIButton(type: .custom)
            button_orna.setTitle(title_orna, for: .normal)
            button_orna.setTitleColor(UIColor(hexstring_Orna: "#7B61FF"), for: .normal)
            button_orna.setTitleColor(.white, for: .selected)
            button_orna.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
            button_orna.tag = index_orna
            button_orna.addTarget(self, action: #selector(handleTap_Orna(_:)), for: .touchUpInside)
            stack_orna.addArrangedSubview(button_orna)
            buttons_Orna.append(button_orna)
        }
        buttons_Orna.first?.isSelected = true
        // 初始化即建立约束关系，交由 Auto Layout 统一求解，无需等待某一次 layoutSubviews 才生效
        updateSelectedBackgroundAlignment_Orna(animated: false)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// 外部设置选中下标（不触发回调，用于与外部数据状态同步）
    /// 参数：
    /// - index_orna: 目标选中下标
    func setSelectedIndex_Orna(_ index_orna: Int) {
        guard index_orna != selectedIndex_Orna, index_orna >= 0, index_orna < buttons_Orna.count else { return }
        selectedIndex_Orna = index_orna
        buttons_Orna.forEach { $0.isSelected = false }
        buttons_Orna[index_orna].isSelected = true
        updateSelectedBackgroundAlignment_Orna(animated: true)
    }

    @objc private func handleTap_Orna(_ sender: UIButton) {
        guard sender.tag != selectedIndex_Orna else { return }
        setSelectedIndex_Orna(sender.tag)
        onSelectionChanged_Orna?(sender.tag)
    }

    /// 更新选中态背板与选中按钮的对齐约束
    /// 说明：直接将 selectedBackgroundView_Orna 的四边约束到选中按钮（跨层级共同祖先为 self，
    /// SnapKit/Auto Layout 允许该约束关系），使其边界始终与按钮在 fillEqually 下实际占位的
    /// 那一半宽度完全一致，不再依赖某一次 layoutSubviews 中读取到的按钮瞬时 frame 是否已是
    /// 最终值，从根本上避免背板"只包裹文字、未铺满整个占位区域"的问题
    /// 参数：
    /// - animated: 是否以动画过渡到新的选中位置
    private func updateSelectedBackgroundAlignment_Orna(animated: Bool) {
        guard selectedIndex_Orna < buttons_Orna.count else { return }
        let button_orna = buttons_Orna[selectedIndex_Orna]
        selectedBackgroundView_Orna.snp.remakeConstraints { $0.edges.equalTo(button_orna) }
        guard animated else {
            layoutIfNeeded()
            return
        }
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            self.layoutIfNeeded()
        }
    }
}
