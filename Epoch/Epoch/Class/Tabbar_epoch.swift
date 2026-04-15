import Foundation
import UIKit
import SnapKit

// MARK: 导航器

/// 底部导航页面
/// 核心作用：管理5个主页面的切换，自定义底部 tab 栏
/// 设计思路：tabBgView 贴左右底、顶部双角圆角20，背景色 #F93AA7；
///          图标全部使用 Assets 原图渲染；发布页无选中指示器，其余页有白色短线指示器
class TabBar_Epoch: UITabBarController {

    /// 底部背景视图（#F93AA7，顶部左右圆角20，贴左右底）
    private let tabBgView_Epoch = UIView()

    /// 按钮水平排列容器
    private let tabStackView_Epoch = UIStackView()

    /// 首页按钮
    private let btnHome_Epoch = UIButton(type: .custom)
    /// 首页选中指示器
    private let indicatorHome_Epoch = UIView()

    /// 发现页按钮
    private let btnDiscover_Epoch = UIButton(type: .custom)
    /// 发现页选中指示器
    private let indicatorDiscover_Epoch = UIView()

    /// 发布按钮（无选中指示器）
    private let btnRelease_Epoch = UIButton(type: .custom)

    /// 消息按钮
    private let btnMessage_Epoch = UIButton(type: .custom)
    /// 消息页选中指示器
    private let indicatorMessage_Epoch = UIView()

    /// 我的按钮
    private let btnMe_Epoch = UIButton(type: .custom)
    /// 我的页选中指示器
    private let indicatorMe_Epoch = UIView()

    /// 当前选中索引
    private var currentIndex_Epoch: Int = 0

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [Home_Epoch(), Discover_Epoch(), Release_Epoch(), MessageList_Epoch(), Me_Epoch()]
        setupUI_Epoch()
        setupConstraints_Epoch()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        tabBar.isHidden = true
    }

    // MARK: - UI

    /// 构建 tab 栏界面
    private func setupUI_Epoch() {
        // 背景视图：粉色，顶部两角圆角20
        tabBgView_Epoch.backgroundColor = UIColor(hexstring_Epoch: "#F93AA7")
        tabBgView_Epoch.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tabBgView_Epoch.layer.cornerRadius = 30
        tabBgView_Epoch.layer.masksToBounds = true
        view.addSubview(tabBgView_Epoch)

        // 水平排列，等宽分布，容器充满栈高度保证触摸区域完整
        tabStackView_Epoch.axis = .horizontal
        tabStackView_Epoch.distribution = .fillEqually
        tabStackView_Epoch.alignment = .fill
        tabBgView_Epoch.addSubview(tabStackView_Epoch)

        // 构建各 tab item
        tabStackView_Epoch.addArrangedSubview(
            makeTabItem_Epoch(button: btnHome_Epoch, indicator: indicatorHome_Epoch, imageName: "home", iconSize: 36, tag: 0)
        )
        tabStackView_Epoch.addArrangedSubview(
            makeTabItem_Epoch(button: btnDiscover_Epoch, indicator: indicatorDiscover_Epoch, imageName: "discover", iconSize: 36, tag: 1)
        )
        tabStackView_Epoch.addArrangedSubview(
            makePublishItem_Epoch()
        )
        tabStackView_Epoch.addArrangedSubview(
            makeTabItem_Epoch(button: btnMessage_Epoch, indicator: indicatorMessage_Epoch, imageName: "message", iconSize: 36, tag: 3)
        )
        tabStackView_Epoch.addArrangedSubview(
            makeTabItem_Epoch(button: btnMe_Epoch, indicator: indicatorMe_Epoch, imageName: "me", iconSize: 36, tag: 4)
        )

        // 初始选中首页
        updateSelection_Epoch(index_epoch: 0)
    }

    /// 构建普通 tab item 容器（图标 + 选中下划线指示器）
    /// - Parameters:
    ///   - button: 对应按钮
    ///   - indicator: 选中指示器视图
    ///   - imageName: Assets 中的图标名称
    ///   - iconSize: 图标尺寸
    ///   - tag: 按钮 tag（对应 tab 索引）
    /// - Returns: 包含图标和指示器的容器视图
    private func makeTabItem_Epoch(
        button: UIButton,
        indicator: UIView,
        imageName: String,
        iconSize: CGFloat,
        tag: Int
    ) -> UIView {
        // 使用 Assets 原图，不做模板渲染
        let image_epoch = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal)
        button.setImage(image_epoch, for: .normal)
        button.setImage(image_epoch, for: .selected)
        button.tag = tag
        button.addTarget(self, action: #selector(tabButtonTapped_Epoch(_:)), for: .touchUpInside)

        // 白色短线指示器，初始透明
        indicator.backgroundColor = UIColor.white
        indicator.layer.cornerRadius = 1.5
        indicator.alpha = 0

        let container_epoch = UIView()
        container_epoch.addSubview(button)
        container_epoch.addSubview(indicator)

        button.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-5)
            make.width.height.equalTo(iconSize)
        }

        indicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(button.snp.bottom).offset(4)
            make.width.equalTo(20)
            make.height.equalTo(3)
        }

        return container_epoch
    }

    /// 构建发布 tab item 容器（仅图标，无选中指示器）
    /// - Returns: 包含发布图标的容器视图
    private func makePublishItem_Epoch() -> UIView {
        let image_epoch = UIImage(named: "publish")?.withRenderingMode(.alwaysOriginal)
        btnRelease_Epoch.setImage(image_epoch, for: .normal)
        btnRelease_Epoch.setImage(image_epoch, for: .selected)
        btnRelease_Epoch.tag = 2
        btnRelease_Epoch.addTarget(self, action: #selector(tabButtonTapped_Epoch(_:)), for: .touchUpInside)

        let container_epoch = UIView()
        container_epoch.addSubview(btnRelease_Epoch)

        btnRelease_Epoch.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-5)
            make.width.height.equalTo(42)
        }

        return container_epoch
    }

    // MARK: - 约束

    /// 配置 tabBgView 和 tabStackView 的布局约束
    private func setupConstraints_Epoch() {
        // 背景视图贴左右底，顶部固定在 safeArea.bottom 上方 74pt
        tabBgView_Epoch.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-74)
        }

        // StackView 占据背景顶部 74pt（安全区以上的可见区域）
        tabStackView_Epoch.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(74)
        }
    }

    // MARK: - 状态更新

    /// 更新选中状态并同步 tab 页切换
    /// - Parameter index_epoch: 目标 tab 索引（0-4）
    private func updateSelection_Epoch(index_epoch: Int) {
        currentIndex_Epoch = index_epoch
        selectedIndex = index_epoch

        let items_epoch: [(UIButton, UIView?)] = [
            (btnHome_Epoch, indicatorHome_Epoch),
            (btnDiscover_Epoch, indicatorDiscover_Epoch),
            (btnRelease_Epoch, nil),
            (btnMessage_Epoch, indicatorMessage_Epoch),
            (btnMe_Epoch, indicatorMe_Epoch)
        ]

        for (idx, (btn_epoch, indicator_epoch)) in items_epoch.enumerated() {
            btn_epoch.isSelected = (idx == index_epoch)
            UIView.animate(withDuration: 0.2) {
                indicator_epoch?.alpha = (idx == index_epoch) ? 1.0 : 0.0
            }
        }
    }

    /// 对外暴露的 tab 切换方法
    /// - Parameter index_epoch: 目标索引（0-4），超出范围自动截断
    func selectTab_Epoch(index_epoch: Int) {
        updateSelection_Epoch(index_epoch: max(0, min(index_epoch, 4)))
    }

    // MARK: - 事件

    /// 处理 tab 按钮点击
    /// - Parameter sender: 被点击的按钮，tag 对应 tab 索引
    @objc private func tabButtonTapped_Epoch(_ sender: UIButton) {
        updateSelection_Epoch(index_epoch: sender.tag)
    }
}
