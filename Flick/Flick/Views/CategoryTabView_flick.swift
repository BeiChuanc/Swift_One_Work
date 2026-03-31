import UIKit
import SnapKit

// MARK: - 分类标签栏组件

/// 横向滚动分类标签栏
/// 核心作用：在首页顶部展示可横滑的分类标签，支持选中态渐变高亮和弹性切换动画。
/// 关键属性：titles_Flick（标签文字数组）、onSelectIndex_Flick（选中回调）
class CategoryTabView_Flick: UIView {
    
    // MARK: - 属性
    
    /// 标签文字数组（外部赋值后调用 reload_Flick）
    var titles_Flick: [String] = [] {
        didSet { buildTabs_Flick() }
    }
    
    /// 当前选中下标
    private(set) var selectedIndex_Flick: Int = 0
    
    /// 选中回调，参数为选中下标
    var onSelectIndex_Flick: ((Int) -> Void)?
    
    // MARK: - UI 组件
    
    private let scrollView_Flick: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    
    private let stackView_Flick: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 10
        sv.alignment = .center
        return sv
    }()
    
    /// 每个标签按钮
    private var tabButtons_Flick: [UIButton] = []
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Flick()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI 布局
    
    /// 搭建滚动视图和栈视图
    private func setupUI_Flick() {
        backgroundColor = .clear
        addSubview(scrollView_Flick)
        scrollView_Flick.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        scrollView_Flick.addSubview(stackView_Flick)
        stackView_Flick.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalToSuperview()
        }
    }
    
    // MARK: - 公共方法
    
    /// 根据 titles_Flick 重建所有标签按钮
    func buildTabs_Flick() {
        // 清除旧按钮
        stackView_Flick.arrangedSubviews.forEach { $0.removeFromSuperview() }
        tabButtons_Flick.removeAll()
        
        for (index_flick, title_flick) in titles_Flick.enumerated() {
            let btn_Flick = makeTabButton_Flick(title_Flick: title_flick, index_Flick: index_flick)
            tabButtons_Flick.append(btn_Flick)
            stackView_Flick.addArrangedSubview(btn_Flick)
        }
        
        // 默认选中第0项
        updateSelection_Flick(index_Flick: selectedIndex_Flick, animated_Flick: false)
    }
    
    /// 外部强制切换选中项
    /// - Parameters:
    ///   - index_flick: 目标下标
    ///   - animated_flick: 是否带动画
    func selectIndex_Flick(_ index_flick: Int, animated_Flick: Bool = true) {
        guard index_flick < tabButtons_Flick.count else { return }
        updateSelection_Flick(index_Flick: index_flick, animated_Flick: animated_Flick)
    }
    
    // MARK: - 私有方法
    
    /// 创建单个标签按钮
    private func makeTabButton_Flick(title_Flick: String, index_Flick: Int) -> UIButton {
        let btn_Flick = UIButton(type: .custom)
        btn_Flick.setTitle(title_Flick, for: .normal)
        btn_Flick.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        btn_Flick.setTitleColor(ColorConfig_Flick.textSecondary_Flick, for: .normal)
        btn_Flick.setTitleColor(.white, for: .selected)
        btn_Flick.layer.cornerRadius = 16
        btn_Flick.contentEdgeInsets = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
        btn_Flick.tag = index_Flick
        btn_Flick.addTarget(self, action: #selector(handleTabTap_Flick(_:)), for: .touchUpInside)
        return btn_Flick
    }
    
    /// 更新选中状态（含动画）
    private func updateSelection_Flick(index_Flick: Int, animated_Flick: Bool) {
        let oldIndex_Flick = selectedIndex_Flick
        selectedIndex_Flick = index_Flick
        
        let update_Flick = { [weak self] in
            guard let self = self else { return }
            for (i, btn) in self.tabButtons_Flick.enumerated() {
                let selected_Flick = (i == index_Flick)
                btn.isSelected = selected_Flick
                
                if selected_Flick {
                    // 应用渐变背景
                    self.applyGradientBackground_Flick(to: btn)
                    btn.layer.shadowColor = ColorConfig_Flick.primaryGradientStart_Flick.cgColor
                    btn.layer.shadowOffset = CGSize(width: 0, height: 4)
                    btn.layer.shadowRadius = 8
                    btn.layer.shadowOpacity = 0.4
                    if animated_Flick {
                        btn.animatePressUp_Flick()
                    }
                } else {
                    // 移除渐变背景
                    btn.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
                    btn.backgroundColor = ColorConfig_Flick.backgroundPrimary_Flick
                    btn.layer.shadowOpacity = 0
                    if animated_Flick && i == oldIndex_Flick {
                        btn.animatePressDown_Flick { btn.animatePressUp_Flick() }
                    }
                }
            }
        }
        
        if animated_Flick {
            UIView.animate(withDuration: AnimationConfig_Flick.durationNormal_Flick,
                           delay: 0,
                           usingSpringWithDamping: AnimationConfig_Flick.springDampingLight_Flick,
                           initialSpringVelocity: AnimationConfig_Flick.springVelocity_Flick,
                           options: [.curveEaseOut],
                           animations: update_Flick)
        } else {
            update_Flick()
        }
    }
    
    /// 给按钮添加渐变背景图层
    private func applyGradientBackground_Flick(to button_Flick: UIButton) {
        // 先移除旧渐变
        button_Flick.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        button_Flick.backgroundColor = .clear
        
        let grad_Flick = CAGradientLayer()
        grad_Flick.frame = button_Flick.bounds.isEmpty
            ? CGRect(x: 0, y: 0, width: 80, height: 32)
            : button_Flick.bounds
        grad_Flick.colors = [
            ColorConfig_Flick.primaryGradientStart_Flick.cgColor,
            ColorConfig_Flick.primaryGradientEnd_Flick.cgColor
        ]
        grad_Flick.startPoint = CGPoint(x: 0, y: 0.5)
        grad_Flick.endPoint = CGPoint(x: 1, y: 0.5)
        grad_Flick.cornerRadius = button_Flick.layer.cornerRadius
        button_Flick.layer.insertSublayer(grad_Flick, at: 0)
    }
    
    // MARK: - 事件处理
    
    @objc private func handleTabTap_Flick(_ sender: UIButton) {
        let index_Flick = sender.tag
        guard index_Flick != selectedIndex_Flick else { return }
        
        let generator_Flick = UIImpactFeedbackGenerator(style: .light)
        generator_Flick.impactOccurred()
        
        updateSelection_Flick(index_Flick: index_Flick, animated_Flick: true)
        onSelectIndex_Flick?(index_Flick)
    }
    
    // MARK: - 布局后刷新渐变尺寸
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 选中按钮的渐变层需跟随尺寸更新
        if let selectedBtn_Flick = tabButtons_Flick[safe_Flick: selectedIndex_Flick] {
            selectedBtn_Flick.layer.sublayers?
                .compactMap { $0 as? CAGradientLayer }
                .first?
                .frame = selectedBtn_Flick.bounds
        }
    }
}

// MARK: - Array 安全下标扩展（局部使用）

private extension Array {
    subscript(safe_Flick index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
