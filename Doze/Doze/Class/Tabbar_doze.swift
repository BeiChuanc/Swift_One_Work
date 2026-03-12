import Foundation
import UIKit
import SnapKit

// MARK: 导航器

/// 底部导航页面
class TabBar_Doze: UITabBarController {
    
    /// 黄色背景视图
    private var tabBgView_Doze = UIView()
    
    /// 按钮容器栈视图
    private var tabStackView_Doze = UIStackView()
    
    /// 首页按钮
    private var btnHome_Doze = UIButton(type: .custom)
    
    /// 发现页按钮
    private var btnDiscover_Doze = UIButton(type: .custom)
    
    /// 发布按钮
    private var btnRelease_Doze = UIButton(type: .custom)
    
    /// 消息按钮
    private var btnMessage_Doze = UIButton(type: .custom)
    
    /// 我的按钮
    private var btnMe_Doze = UIButton(type: .custom)
    
    /// 当前选中索引
    private var currentIndex_Doze: Int = 0
    
    // MARK: - 生命周期方法
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置视图控制器
        viewControllers = [Home_Doze(), Discover_Doze(), Release_Doze(), MessageList_Doze(), Me_Doze()]
        
        setupUI_Doze()
        setupConstraints_Doze()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        tabBar.isHidden = true
    }
    
    // MARK: - UI设置

    private func setupUI_Doze() {
        // 背景视图
        tabBgView_Doze.backgroundColor = UIColor(hexstring_Doze: "#07152A")
        tabBgView_Doze.layer.masksToBounds = true
        view.addSubview(tabBgView_Doze)

        // StackView
        tabStackView_Doze.axis = .horizontal
        tabStackView_Doze.distribution = .equalSpacing
        tabStackView_Doze.alignment = .center
        tabStackView_Doze.spacing = 0
        view.addSubview(tabStackView_Doze)

        // 选中色
        let selectedColor_Doze = UIColor(hexstring_Doze: "#BE92FD")

        // 配置首页按钮（normal: 原图，selected: 主题色着色）
        configTabButton_Doze(
            btnHome_Doze,
            imageName_Doze: "home",
            tag_Doze: 0,
            selectedColor_Doze: selectedColor_Doze
        )

        // 配置发现页按钮
        configTabButton_Doze(
            btnDiscover_Doze,
            imageName_Doze: "discover",
            tag_Doze: 1,
            selectedColor_Doze: selectedColor_Doze
        )

        // 配置发布按钮（始终使用原图，无选中着色）
        btnRelease_Doze.setImage(
            UIImage(named: "publish")?.withRenderingMode(.alwaysOriginal),
            for: .normal
        )
        btnRelease_Doze.setImage(
            UIImage(named: "publish")?.withRenderingMode(.alwaysOriginal),
            for: .selected
        )
        btnRelease_Doze.tag = 2
        btnRelease_Doze.addTarget(self, action: #selector(tabButtonTapped_Doze(_:)), for: .touchUpInside)
        tabStackView_Doze.addArrangedSubview(btnRelease_Doze)

        // 配置消息按钮
        configTabButton_Doze(
            btnMessage_Doze,
            imageName_Doze: "message",
            tag_Doze: 3,
            selectedColor_Doze: selectedColor_Doze
        )

        // 配置我的按钮
        configTabButton_Doze(
            btnMe_Doze,
            imageName_Doze: "me",
            tag_Doze: 4,
            selectedColor_Doze: selectedColor_Doze
        )

        // 初始选中首页
        updateSelection_Doze(index_Doze: 0)
    }

    /// 统一配置普通 Tab 按钮
    /// - Parameters:
    ///   - button_Doze: 目标按钮
    ///   - imageName_Doze: Assets 图标名称
    ///   - tag_Doze: 按钮标识
    ///   - selectedColor_Doze: 选中时着色颜色
    private func configTabButton_Doze(
        _ button_Doze: UIButton,
        imageName_Doze: String,
        tag_Doze: Int,
        selectedColor_Doze: UIColor
    ) {
        // 普通状态：原图显示
        button_Doze.setImage(
            UIImage(named: imageName_Doze)?.withRenderingMode(.alwaysOriginal),
            for: .normal
        )
        // 选中状态：用主题色对原图着色
        button_Doze.setImage(
            tintedImage_Doze(named_Doze: imageName_Doze, color_Doze: selectedColor_Doze),
            for: .selected
        )
        button_Doze.tag = tag_Doze
        button_Doze.addTarget(self, action: #selector(tabButtonTapped_Doze(_:)), for: .touchUpInside)
        tabStackView_Doze.addArrangedSubview(button_Doze)
    }

    /// 对 Assets 图片应用纯色着色，返回着色后的图片
    /// - Parameters:
    ///   - named_Doze: 图片名称
    ///   - color_Doze: 着色颜色
    /// - Returns: 着色后的 UIImage，图片不存在时返回 nil
    private func tintedImage_Doze(named_Doze: String, color_Doze: UIColor) -> UIImage? {
        guard let original_Doze = UIImage(named: named_Doze) else { return nil }
        let renderer_Doze = UIGraphicsImageRenderer(size: original_Doze.size)
        return renderer_Doze.image { ctx_Doze in
            color_Doze.setFill()
            ctx_Doze.fill(CGRect(origin: .zero, size: original_Doze.size))
            original_Doze.draw(at: .zero, blendMode: .destinationIn, alpha: 1)
        }
    }

    /// 设置约束布局
    private func setupConstraints_Doze() {
        // 背景视图：直接对屏幕留边距，与屏幕左右各距 20pt，底部距屏幕底 24pt
        tabBgView_Doze.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-24)
            make.height.equalTo(84)
        }

        // 圆角为高度一半（胶囊形）
        tabBgView_Doze.layer.cornerRadius = 42

        // StackView：在背景视图内部左右各留 24pt 内边距，垂直居中
        tabStackView_Doze.snp.makeConstraints { make in
            make.centerY.equalTo(tabBgView_Doze)
            make.leading.equalTo(tabBgView_Doze).offset(24)
            make.trailing.equalTo(tabBgView_Doze).offset(-24)
            make.height.equalTo(56)
        }

        // 普通 Tab 图标：24x24
        [btnHome_Doze, btnDiscover_Doze, btnMessage_Doze, btnMe_Doze].forEach { btn in
            btn.snp.makeConstraints { make in
                make.width.height.equalTo(24)
            }
        }

        // 发布按钮：44x44
        btnRelease_Doze.snp.makeConstraints { make in
            make.width.height.equalTo(44)
        }
    }

    /// 统一更新所有按钮选中状态
    private func updateSelection_Doze(index_Doze: Int) {
        let allBtns_Doze = [btnHome_Doze, btnDiscover_Doze, btnRelease_Doze, btnMessage_Doze, btnMe_Doze]
        allBtns_Doze.enumerated().forEach { i_Doze, btn_Doze in
            btn_Doze.isSelected = (i_Doze == index_Doze)
        }
    }
    
    @objc private func tabButtonTapped_Doze(_ sender: UIButton) {
        let index_Doze = sender.tag
        currentIndex_Doze = index_Doze
        selectedIndex = index_Doze
        updateSelection_Doze(index_Doze: index_Doze)
    }

    // MARK: - 外部切换接口

    /// 切换到指定标签页，并同步更新底部按钮选中状态
    /// - Parameter index_Doze: 目标标签索引（0:首页 1:发现 2:发布 3:消息 4:我的）
    func switchToTab_Doze(index_Doze: Int) {
        guard index_Doze >= 0, index_Doze < (viewControllers?.count ?? 0) else { return }
        currentIndex_Doze = index_Doze
        selectedIndex = index_Doze
        updateSelection_Doze(index_Doze: index_Doze)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}
