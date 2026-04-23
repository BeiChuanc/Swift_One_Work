import Foundation
import UIKit
import SnapKit

// MARK: 导航器

/// 底部自定义 Tab 导航器：使用 Assets 原图图标、品牌色底栏与主 Tab 选中滑条
/// 设计要点：非发布 Tab 选中时在图标下方显示指示条；发布位固定 40×40，其余 24×24
class TabBar_Nest: UITabBarController {
    
    /// 底栏背景（紫色、圆角）
    private var tabBgView_Nest = UIView()
    
    /// 主 Tab 选中时图标下方的短滑条（发布 Tab 不显示）
    private var selectionBar_Nest = UIView()
    
    /// 按钮容器栈视图
    private var tabStackView_Nest = UIStackView()
    
    /// 首页按钮
    private var btnHome_Nest = UIButton(type: .custom)
    
    /// 发现页按钮
    private var btnDiscover_Nest = UIButton(type: .custom)
    
    /// 发布按钮
    private var btnRelease_Nest = UIButton(type: .custom)
    
    /// 消息按钮
    private var btnMessage_Nest = UIButton(type: .custom)
    
    /// 我的按钮
    private var btnMe_Nest = UIButton(type: .custom)
    
    /// 当前选中索引
    private var currentIndex_Nest: Int = 0
    
    /// 紫条与屏幕左/右外边距
    private let tabBarScreenEdgeInset_Nest: CGFloat = 16
    /// 紫条与内部五个图标行的左/右内边距，避免首末与圆角贴死
    private let tabBarInnerContentInset_Nest: CGFloat = 20
    
    // MARK: - 生命周期方法
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置视图控制器
        viewControllers = [Home_Nest(), Discover_Nest(), Release_Nest(), MessageList_Nest(), Me_Nest()]
        
        setupUI_Nest()
        setupConstraints_Nest()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        tabBar.isHidden = true
        keepCustomTabViewsOnTop_Nest()
    }
    
    /// 首帧时 Stack 子项 frame 才稳定，在可见后再校正一次滑条
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.layoutIfNeeded()
        tabStackView_Nest.layoutIfNeeded()
        layoutSelectionBar_Nest(animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 子控制器视图后于自定义底栏加入层级时会在上方，必须每轮布局时把底栏再提到最前，紫底与图标才可见
        keepCustomTabViewsOnTop_Nest()
        layoutSelectionBar_Nest(animated: false)
    }
    
    // MARK: - 层级与布局
    
    /// 将底栏浮于当前选中子控制器之上，避免子页全屏背景覆盖紫色底
    private func keepCustomTabViewsOnTop_Nest() {
        view.bringSubviewToFront(tabBgView_Nest)
        view.bringSubviewToFront(selectionBar_Nest)
        view.bringSubviewToFront(tabStackView_Nest)
    }
    
    // MARK: - UI设置
    
    /// 配置底栏、图标（原图）、选中滑条
    private func setupUI_Nest() {
        // 不插入 index 0：子 Tab 全屏白底会盖住底栏；底栏在 layout 时通过 bringToFront 浮在子页之上
        tabBgView_Nest.backgroundColor = UIColor(hexstring_Nest: "#9666D8")
        tabBgView_Nest.isOpaque = true
        tabBgView_Nest.layer.cornerRadius = 20
        tabBgView_Nest.layer.masksToBounds = true
        tabBgView_Nest.isUserInteractionEnabled = false
        view.addSubview(tabBgView_Nest)
        
        selectionBar_Nest.backgroundColor = .white
        selectionBar_Nest.layer.cornerRadius = 1.5
        selectionBar_Nest.layer.masksToBounds = true
        view.addSubview(selectionBar_Nest)
        selectionBar_Nest.isHidden = false
        
        // 配置StackView
        tabStackView_Nest.axis = .horizontal
        tabStackView_Nest.distribution = .equalSpacing
        tabStackView_Nest.alignment = .center
        tabStackView_Nest.spacing = 20
        view.addSubview(tabStackView_Nest)
        
        configureTabImageButton_Nest(button: btnHome_Nest, name: "home", tag: 0)
        tabStackView_Nest.addArrangedSubview(btnHome_Nest)
        
        configureTabImageButton_Nest(button: btnDiscover_Nest, name: "discover", tag: 1)
        tabStackView_Nest.addArrangedSubview(btnDiscover_Nest)
        
        configureTabImageButton_Nest(button: btnRelease_Nest, name: "publish", tag: 2)
        tabStackView_Nest.addArrangedSubview(btnRelease_Nest)
        
        configureTabImageButton_Nest(button: btnMessage_Nest, name: "message", tag: 3)
        tabStackView_Nest.addArrangedSubview(btnMessage_Nest)
        
        configureTabImageButton_Nest(button: btnMe_Nest, name: "me", tag: 4)
        tabStackView_Nest.addArrangedSubview(btnMe_Nest)
        
        btnHome_Nest.isSelected = true
        updateTabsAlpha_Nest()
    }
    
    /// 为按钮设置 Assets 原图与点击事件
    /// - Parameters:
    ///   - button: 目标按钮
    ///   - name: 资源名（与 Assets 中图片集一致）
    ///   - tag: Tab 索引
    private func configureTabImageButton_Nest(
        button: UIButton,
        name: String,
        tag: Int
    ) {
        let raw = UIImage(named: name)
        let img = raw?.withRenderingMode(.alwaysOriginal)
        button.setImage(img, for: .normal)
        button.setImage(img, for: .selected)
        button.tintColor = .clear
        button.adjustsImageWhenHighlighted = false
        button.imageView?.contentMode = .scaleAspectFit
        button.tag = tag
        button.addTarget(self, action: #selector(tabButtonTapped_Nest(_:)), for: .touchUpInside)
    }
    
    /// 设置约束布局
    private func setupConstraints_Nest() {
        // 紫条与屏幕的左右边距（外层）
        tabBgView_Nest.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(tabBarScreenEdgeInset_Nest)
        }
        // 图标行相对紫条再内缩，避免 Home / Me 贴住圆角内侧
        tabStackView_Nest.snp.makeConstraints { make in
            make.leading.equalTo(tabBgView_Nest.snp.leading).offset(tabBarInnerContentInset_Nest)
            make.trailing.equalTo(tabBgView_Nest.snp.trailing).offset(-tabBarInnerContentInset_Nest)
            make.bottom.equalToSuperview().offset(-30)
            make.height.equalTo(45)
        }
        // 紫条比图标行在竖直方向多出的留白
        tabBgView_Nest.snp.makeConstraints { make in
            make.top.equalTo(tabStackView_Nest.snp.top).offset(-15)
            make.bottom.equalTo(tabStackView_Nest.snp.bottom).offset(15)
        }
        
        btnHome_Nest.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
        btnDiscover_Nest.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
        btnRelease_Nest.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        btnMessage_Nest.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
        btnMe_Nest.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
    }
    
    /// 主 Tab 选中时展示滑条；发布 Tab 选中时隐藏
    private func layoutSelectionBar_Nest(animated: Bool) {
        if currentIndex_Nest == 2 {
            // 发布 Tab 不显示底部滑条
            selectionBar_Nest.isHidden = true
            selectionBar_Nest.alpha = 0
            return
        }
        let target: UIButton?
        switch currentIndex_Nest {
        case 0: target = btnHome_Nest
        case 1: target = btnDiscover_Nest
        case 3: target = btnMessage_Nest
        case 4: target = btnMe_Nest
        default: target = nil
        }
        guard let btn = target, btn.superview != nil else { return }
        // 必须等布局完成，否则 button.bounds 可能为 0，convert 后 midX 会落在左缘导致滑条贴最左
        view.layoutIfNeeded()
        tabStackView_Nest.layoutIfNeeded()
        btn.layoutIfNeeded()
        let barW: CGFloat = 20
        let barH: CGFloat = 3
        let btnFrameInView = tabStackView_Nest.convert(btn.frame, to: view)
        let x = btnFrameInView.midX - barW / 2
        // 滑条相对 Stack 下沿，使用 Stack 在 self.view 中的 frame
        let stackInView = tabStackView_Nest.frame
        guard stackInView.width > 1, stackInView.maxY > 1 else { return }
        let y = stackInView.maxY - barH - 4
        let newFrame = CGRect(x: x, y: y, width: barW, height: barH)
        selectionBar_Nest.isHidden = false
        if animated {
            selectionBar_Nest.alpha = 1
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
                self.selectionBar_Nest.frame = newFrame
            }
        } else {
            selectionBar_Nest.frame = newFrame
            selectionBar_Nest.alpha = 1
        }
    }
    
    /// 根据当前选中索引调整各按钮透明度（主 Tab 强调选中态）
    private func updateTabsAlpha_Nest() {
        let isSel: (Int) -> Bool = { [weak self] i in
            self?.currentIndex_Nest == i
        }
        let dim: CGFloat = 0.45
        btnHome_Nest.alpha = isSel(0) ? 1.0 : dim
        btnDiscover_Nest.alpha = isSel(1) ? 1.0 : dim
        btnRelease_Nest.alpha = isSel(2) ? 1.0 : dim
        btnMessage_Nest.alpha = isSel(3) ? 1.0 : dim
        btnMe_Nest.alpha = isSel(4) ? 1.0 : dim
    }
    
    /// 点击底栏按钮切换页面并刷新滑条与按钮状态
    @objc private func tabButtonTapped_Nest(_ sender: UIButton) {
        let index = sender.tag
        currentIndex_Nest = index
        selectedIndex = index
        
        btnHome_Nest.isSelected = (index == 0)
        btnDiscover_Nest.isSelected = (index == 1)
        btnRelease_Nest.isSelected = (index == 2)
        btnMessage_Nest.isSelected = (index == 3)
        btnMe_Nest.isSelected = (index == 4)
        
        updateTabsAlpha_Nest()
        layoutSelectionBar_Nest(animated: true)
    }
}
