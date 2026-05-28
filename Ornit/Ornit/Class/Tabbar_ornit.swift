import Foundation
import UIKit
import SnapKit

// MARK: 导航器

/// 底部导航页面
/// 功能：自定义 Tab Bar，图标使用 Assets 原图
/// 设计：渐变胶囊背景（#3698EF → #863DE6，顶部居中到底部居中）
///       非发布页选中时在图标背后居中显示 40×40 紫色圆形（#863DE6）
///       发布图标 54×32，其余图标 24×24
class TabBar_Ornit: UITabBarController {

    // MARK: - UI 组件

    /// 渐变胶囊背景视图
    private var tabBgView_Ornit = UIView()

    /// 背景渐变图层（viewDidLayoutSubviews 中更新 frame）
    private var tabBgGradient_Ornit: CAGradientLayer?

    /// 按钮横向容器
    private var tabStackView_Ornit = UIStackView()

    /// 首页按钮
    private var btnHome_Ornit = UIButton(type: .custom)

    /// 发现页按钮
    private var btnDiscover_Ornit = UIButton(type: .custom)

    /// 发布按钮（图标 54×32，无选中圆圈）
    private var btnRelease_Ornit = UIButton(type: .custom)

    /// 消息按钮
    private var btnMessage_Ornit = UIButton(type: .custom)

    /// 我的按钮
    private var btnMe_Ornit = UIButton(type: .custom)

    /// 当前选中索引
    private var currentIndex_Ornit: Int = 0

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [Home_Ornit(), Discover_Ornit(), Release_Ornit(), MessageList_Ornit(), Me_Ornit()]
        setupUI_Ornit()
        setupConstraints_Ornit()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        tabBar.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tabBgGradient_Ornit?.frame = tabBgView_Ornit.bounds
    }

    // MARK: - UI 搭建

    private func setupUI_Ornit() {

        // 渐变胶囊背景（顶部居中 → 底部居中）
        tabBgView_Ornit.layer.masksToBounds = true
        view.addSubview(tabBgView_Ornit)

        let gradient_ornit = CAGradientLayer()
        gradient_ornit.colors = [
            UIColor(hexstring_Ornit: "#3698EF").cgColor,
            UIColor(hexstring_Ornit: "#863DE6").cgColor
        ]
        gradient_ornit.startPoint = CGPoint(x: 0.5, y: 0)
        gradient_ornit.endPoint = CGPoint(x: 0.5, y: 1)
        tabBgView_Ornit.layer.insertSublayer(gradient_ornit, at: 0)
        tabBgGradient_Ornit = gradient_ornit

        // 按钮容器
        tabStackView_Ornit.axis = .horizontal
        tabStackView_Ornit.distribution = .equalSpacing
        tabStackView_Ornit.alignment = .center
        tabStackView_Ornit.spacing = 20
        view.addSubview(tabStackView_Ornit)

        // 非发布按钮（40×40，图标 24×24，选中时圆形背景 #863DE6）
        setupRegularButton_Ornit(btnHome_Ornit, imageName: "home", tag: 0)
        setupRegularButton_Ornit(btnDiscover_Ornit, imageName: "discover", tag: 1)

        // 发布按钮（54×32，原图，无选中圆圈）
        if let pubImg_ornit = UIImage(named: "publish") {
            btnRelease_Ornit.setImage(pubImg_ornit.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        btnRelease_Ornit.backgroundColor = .clear
        btnRelease_Ornit.tag = 2
        btnRelease_Ornit.addTarget(self, action: #selector(tabButtonTapped_Ornit(_:)), for: .touchUpInside)
        tabStackView_Ornit.addArrangedSubview(btnRelease_Ornit)

        setupRegularButton_Ornit(btnMessage_Ornit, imageName: "message", tag: 3)
        setupRegularButton_Ornit(btnMe_Ornit, imageName: "me", tag: 4)

        // 默认选中首页
        updateSelectionUI_Ornit(selectedIndex: 0)
    }

    /// 配置非发布 Tab 按钮（40×40 容器，24×24 原图，选中时紫色圆圈背景）
    /// - Parameters:
    ///   - btn: 目标按钮
    ///   - imageName: Assets 中的图片名称
    ///   - tag: Tab 索引
    private func setupRegularButton_Ornit(_ btn: UIButton, imageName: String, tag: Int) {
        if let img_ornit = UIImage(named: imageName) {
            btn.setImage(img_ornit.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        // 通过 imageEdgeInsets 让 24×24 图标居中于 40×40 按钮（8pt 内缩）
        btn.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        btn.layer.cornerRadius = 20
        btn.backgroundColor = .clear
        btn.tag = tag
        btn.addTarget(self, action: #selector(tabButtonTapped_Ornit(_:)), for: .touchUpInside)
        tabStackView_Ornit.addArrangedSubview(btn)
    }

    private func setupConstraints_Ornit() {
        // StackView 约束
        tabStackView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.centerX.equalToSuperview()
            make_ornit.leading.equalToSuperview().offset(30)
            make_ornit.trailing.equalToSuperview().offset(-30)
            make_ornit.bottom.equalToSuperview().offset(-50)
            make_ornit.height.equalTo(50)
        }

        // 按钮尺寸约束
        btnHome_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.width.height.equalTo(40)
        }
        btnDiscover_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.width.height.equalTo(40)
        }
        // 发布按钮 54×32
        btnRelease_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.width.equalTo(54)
            make_ornit.height.equalTo(32)
        }
        btnMessage_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.width.height.equalTo(40)
        }
        btnMe_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.width.height.equalTo(40)
        }

        // 渐变背景视图：StackView 上下各留 15pt，左右各向外扩展 15pt
        // → 两侧按钮距背景左/右边缘各保持 15pt 间距
        tabBgView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalTo(tabStackView_Ornit).offset(-15)
            make_ornit.trailing.equalTo(tabStackView_Ornit).offset(15)
            make_ornit.top.equalTo(tabStackView_Ornit).offset(-15)
            make_ornit.bottom.equalTo(tabStackView_Ornit).offset(15)
        }

        // 胶囊圆角 = 高度 / 2（StackView 50 + 上下各 15 = 80）
        tabBgView_Ornit.layoutIfNeeded()
        tabBgView_Ornit.layer.cornerRadius = 40.0
    }

    // MARK: - 选中态更新

    /// 更新所有非发布按钮的选中圆圈背景
    /// - Parameter selectedIndex: 当前选中的 Tab 索引
    private func updateSelectionUI_Ornit(selectedIndex: Int) {
        let regularBtns_ornit: [(UIButton, Int)] = [
            (btnHome_Ornit, 0),
            (btnDiscover_Ornit, 1),
            (btnMessage_Ornit, 3),
            (btnMe_Ornit, 4)
        ]
        for (btn_ornit, idx_ornit) in regularBtns_ornit {
            // 选中时显示 #863DE6 圆形背景，未选中时清空背景
            btn_ornit.backgroundColor = (idx_ornit == selectedIndex)
                ? UIColor(hexstring_Ornit: "#863DE6")
                : .clear
        }
    }

    // MARK: - 事件处理

    @objc private func tabButtonTapped_Ornit(_ sender: UIButton) {
        let index_ornit = sender.tag
        currentIndex_Ornit = index_ornit
        selectedIndex = index_ornit
        updateSelectionUI_Ornit(selectedIndex: index_ornit)
    }
}
