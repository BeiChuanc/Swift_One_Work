import Foundation
import UIKit
import SnapKit

// MARK: 通用横向胶囊标签栏组件

/// 通用横向可滚动胶囊标签栏
/// 核心作用：供各工具页复用的分类/模式切换标签栏（如胶片预设分类筛选、曝光计算器模式切换、
///          硬件特效分类切换），选中态使用渐变高亮，避免在多个页面重复实现同类横滑标签栏
/// 设计思路：
///   - 横向可滚动 UIStackView 承载胶囊按钮，标签数量不定时也不会挤压布局
///   - 选中态使用传入的渐变色填充，未选中态使用低透明度强调色描边式填充
/// 关键属性：
///   - onSelected_Lumia: 选中下标变化回调
class PillTabBar_Lumia: UIView {

    // MARK: - 回调

    var onSelected_Lumia: ((Int) -> Void)?

    // MARK: - 私有属性

    private let gradientStart_Lumia: UIColor
    private let gradientEnd_Lumia: UIColor
    private let unselectedTint_Lumia: UIColor

    private var buttons_Lumia: [UIButton] = []
    private var selectedIndex_Lumia: Int = 0

    private let scrollView_Lumia: UIScrollView = {
        let sv_Lumia = UIScrollView()
        sv_Lumia.showsHorizontalScrollIndicator = false
        sv_Lumia.alwaysBounceHorizontal = true
        return sv_Lumia
    }()

    private let stackView_Lumia: UIStackView = {
        let sv_Lumia = UIStackView()
        sv_Lumia.axis = .horizontal
        sv_Lumia.spacing = 8
        sv_Lumia.alignment = .center
        return sv_Lumia
    }()

    // MARK: - 初始化

    /// 初始化胶囊标签栏
    /// - Parameters:
    ///   - gradientStart_Lumia: 选中态渐变起始色
    ///   - gradientEnd_Lumia: 选中态渐变结束色
    ///   - unselectedTint_Lumia: 未选中态文字/描边强调色
    init(gradientStart_Lumia: UIColor, gradientEnd_Lumia: UIColor, unselectedTint_Lumia: UIColor) {
        self.gradientStart_Lumia = gradientStart_Lumia
        self.gradientEnd_Lumia = gradientEnd_Lumia
        self.unselectedTint_Lumia = unselectedTint_Lumia
        super.init(frame: .zero)
        setupUI_Lumia()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI设置

    private func setupUI_Lumia() {
        addSubview(scrollView_Lumia)
        scrollView_Lumia.snp.makeConstraints { make in make.edges.equalToSuperview() }

        scrollView_Lumia.addSubview(stackView_Lumia)
        stackView_Lumia.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
    }

    // MARK: - 公共方法

    /// 配置标签内容
    /// - Parameters:
    ///   - titles_Lumia: 标签文字列表
    ///   - selectedIndex_Lumia: 初始选中下标
    func configure_Lumia(titles_Lumia: [String], selectedIndex_Lumia: Int = 0) {
        stackView_Lumia.arrangedSubviews.forEach { $0.removeFromSuperview() }
        buttons_Lumia.removeAll()

        for (idx_Lumia, title_Lumia) in titles_Lumia.enumerated() {
            let btn_Lumia = makeButton_Lumia(title_Lumia: title_Lumia, index_Lumia: idx_Lumia)
            stackView_Lumia.addArrangedSubview(btn_Lumia)
            buttons_Lumia.append(btn_Lumia)
        }
        selectIndex_Lumia(selectedIndex_Lumia)
    }

    /// 以编程方式选中指定下标（不触发 onSelected_Lumia 回调）
    func selectIndex_Lumia(_ index_Lumia: Int) {
        selectedIndex_Lumia = index_Lumia
        updateSelection_Lumia()
    }

    // MARK: - 私有方法

    private func makeButton_Lumia(title_Lumia: String, index_Lumia: Int) -> UIButton {
        let btn_Lumia = UIButton(type: .custom)
        var config_Lumia = UIButton.Configuration.plain()
        config_Lumia.title = title_Lumia
        config_Lumia.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            return outgoing
        }
        config_Lumia.contentInsets = NSDirectionalEdgeInsets(top: 7, leading: 14, bottom: 7, trailing: 14)
        btn_Lumia.configuration = config_Lumia
        btn_Lumia.layer.cornerRadius = 15
        btn_Lumia.tag = index_Lumia
        btn_Lumia.addTarget(self, action: #selector(handleTap_Lumia(_:)), for: .touchUpInside)
        return btn_Lumia
    }

    private func updateSelection_Lumia() {
        for (idx_Lumia, btn_Lumia) in buttons_Lumia.enumerated() {
            btn_Lumia.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
            btn_Lumia.layer.borderWidth = 0

            if idx_Lumia == selectedIndex_Lumia {
                btn_Lumia.tintColor = .white
                btn_Lumia.configuration?.baseForegroundColor = .white
                btn_Lumia.backgroundColor = .clear
                let gradient_Lumia = CAGradientLayer()
                gradient_Lumia.colors = [gradientStart_Lumia.cgColor, gradientEnd_Lumia.cgColor]
                gradient_Lumia.startPoint = CGPoint(x: 0, y: 0)
                gradient_Lumia.endPoint = CGPoint(x: 1, y: 1)
                gradient_Lumia.cornerRadius = 15
                btn_Lumia.layer.insertSublayer(gradient_Lumia, at: 0)
                DispatchQueue.main.async { gradient_Lumia.frame = btn_Lumia.bounds }
            } else {
                btn_Lumia.tintColor = unselectedTint_Lumia
                btn_Lumia.configuration?.baseForegroundColor = unselectedTint_Lumia
                btn_Lumia.backgroundColor = unselectedTint_Lumia.withAlphaComponent(0.10)
            }
        }
    }

    // MARK: - 事件处理

    @objc private func handleTap_Lumia(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        selectedIndex_Lumia = sender.tag
        updateSelection_Lumia()
        onSelected_Lumia?(sender.tag)
    }
}
