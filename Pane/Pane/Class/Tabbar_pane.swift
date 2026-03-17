import Foundation
import UIKit
import SnapKit

// MARK: 底部导航栏

/// 底部导航页面
/// 核心作用：自定义 Tab Bar，包含首页、发现、发布、消息、我的五个入口
/// 设计思路：隐藏系统 tabBar，用自定义 tabBgView_Pane 承载按钮 StackView；
///          背景白色，顶部左右 15pt 圆角；距屏幕底/左/右均为 0；
///          普通按钮 30×30（原图 + Template 着色），发布按钮 40×40（原图不染色）；
///          选中颜色 #FF6630，未选中默认灰色
class TabBar_Pane: UITabBarController {

    // MARK: - 属性

    /// Tab 背景容器
    private let tabBgView_Pane: UIView = {
        let v = UIView()
        v.backgroundColor    = UIColor(hexstring_Pane: "#FFFFFF")
        v.layer.cornerRadius = 15
        // 仅裁剪顶部左右两角
        v.layer.maskedCorners  = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.layer.masksToBounds  = true
        return v
    }()

    /// 按钮水平排列容器
    private let tabStackView_Pane: UIStackView = {
        let sv = UIStackView()
        sv.axis         = .horizontal
        sv.distribution = .equalSpacing
        sv.alignment    = .center
        return sv
    }()

    /// 首页按钮（tag=0）
    private let btnHome_Pane     = UIButton(type: .custom)
    /// 发现页按钮（tag=1）
    private let btnDiscover_Pane = UIButton(type: .custom)
    /// 发布按钮（tag=2，原图，40×40）
    private let btnRelease_Pane  = UIButton(type: .custom)
    /// 消息按钮（tag=3）
    private let btnMessage_Pane  = UIButton(type: .custom)
    /// 我的按钮（tag=4）
    private let btnMe_Pane       = UIButton(type: .custom)

    /// 选中色
    private let selectedColor_Pane  = UIColor(hexstring_Pane: "#FF6630")
    /// 未选中色
    private let normalColor_Pane    = UIColor(hexstring_Pane: "#AAAAAA")

    /// 当前选中索引
    private var currentIndex_Pane: Int = 0

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [
            Home_Pane(),
            Discover_Pane(),
            Release_Pane(),
            MessageList_Pane(),
            Me_Pane()
        ]
        setupUI_Pane()
        setupConstraints_Pane()
        // 初始选中首页
        updateButtonStates_Pane(selectedIndex_Pane: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        tabBar.isHidden = true
    }

    // MARK: - UI 搭建

    private func setupUI_Pane() {
        view.addSubview(tabBgView_Pane)
        tabBgView_Pane.addSubview(tabStackView_Pane)

        // 配置首页按钮：原图 Template 模式，支持 tintColor 着色
        configNormalButton_Pane(
            btnHome_Pane,
            imageName_Pane: "home",
            tag_Pane: 0
        )

        // 配置发现页按钮
        configNormalButton_Pane(
            btnDiscover_Pane,
            imageName_Pane: "discover",
            tag_Pane: 1
        )

        // 配置发布按钮：原图，不染色，固定 40×40
        configPublishButton_Pane()

        // 配置消息按钮
        configNormalButton_Pane(
            btnMessage_Pane,
            imageName_Pane: "message",
            tag_Pane: 3
        )

        // 配置我的按钮
        configNormalButton_Pane(
            btnMe_Pane,
            imageName_Pane: "me",
            tag_Pane: 4
        )
    }

    /// 配置普通 Tab 按钮（Template 模式，支持选中染色 + 橙色方形背景）
    /// - Parameters:
    ///   - button_Pane:    目标按钮
    ///   - imageName_Pane: Assets 中的图片名称
    ///   - tag_Pane:       按钮 tag，对应页面索引
    private func configNormalButton_Pane(
        _ button_Pane: UIButton,
        imageName_Pane: String,
        tag_Pane: Int
    ) {
        // Template 模式：图标形状保留原样，颜色由 tintColor 控制
        let img_pane = UIImage(named: imageName_Pane)?
            .withRenderingMode(.alwaysTemplate)
        button_Pane.setImage(img_pane, for: .normal)
        button_Pane.setImage(img_pane, for: .selected)
        button_Pane.tintColor = normalColor_Pane

        // 选中时显示 30×30 方形圆角 5 橙色背景，通过 backgroundColor 切换实现
        button_Pane.layer.cornerRadius = 5
        button_Pane.clipsToBounds      = true
        button_Pane.backgroundColor    = .clear

        button_Pane.tag = tag_Pane
        button_Pane.addTarget(
            self,
            action: #selector(tabButtonTapped_Pane(_:)),
            for: .touchUpInside
        )
        tabStackView_Pane.addArrangedSubview(button_Pane)
    }

    /// 配置发布按钮（原图，不染色）
    private func configPublishButton_Pane() {
        // alwaysOriginal：完全保留图片原始颜色，不受 tintColor 影响
        let img_pane = UIImage(named: "publish")?
            .withRenderingMode(.alwaysOriginal)
        btnRelease_Pane.setImage(img_pane, for: .normal)
        btnRelease_Pane.setImage(img_pane, for: .selected)
        btnRelease_Pane.tag = 2
        btnRelease_Pane.addTarget(
            self,
            action: #selector(tabButtonTapped_Pane(_:)),
            for: .touchUpInside
        )
        tabStackView_Pane.addArrangedSubview(btnRelease_Pane)
    }

    // MARK: - 约束

    private func setupConstraints_Pane() {
        // tabBgView：左/右/底 紧贴屏幕边缘（距离为 0），高度自适应内容
        tabBgView_Pane.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(tabStackView_Pane.snp.top).offset(-10)
        }

        // StackView：水平铺满（左右各 24pt 内边距），bottom 锚定到安全区底部上方 10pt
        tabStackView_Pane.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
            $0.height.equalTo(50)
        }

        // 普通按钮：30×30
        [btnHome_Pane, btnDiscover_Pane, btnMessage_Pane, btnMe_Pane].forEach {
            $0.snp.makeConstraints { $0.width.height.equalTo(30) }
        }

        // 发布按钮：40×40
        btnRelease_Pane.snp.makeConstraints {
            $0.width.height.equalTo(40)
        }
    }

    // MARK: - 事件处理

    /// Tab 按钮点击：切换页面并更新图标着色状态
    /// - Parameter sender: 被点击的按钮，通过 tag 识别页面索引
    @objc private func tabButtonTapped_Pane(_ sender: UIButton) {
        let index_pane = sender.tag
        currentIndex_Pane = index_pane
        selectedIndex     = index_pane
        updateButtonStates_Pane(selectedIndex_Pane: index_pane)
    }

    /// 根据选中索引刷新所有普通按钮的 tintColor 和 isSelected 状态
    /// - Parameter selectedIndex_Pane: 当前选中页面的索引
    private func updateButtonStates_Pane(selectedIndex_Pane: Int) {
        // (按钮, 对应索引) 映射，发布按钮（index 2）跳过着色
        let normalBtns_pane: [(UIButton, Int)] = [
            (btnHome_Pane,     0),
            (btnDiscover_Pane, 1),
            (btnMessage_Pane,  3),
            (btnMe_Pane,       4)
        ]
        for (btn_pane, idx_pane) in normalBtns_pane {
            let isSelected_pane     = (idx_pane == selectedIndex_Pane)
            btn_pane.isSelected     = isSelected_pane
            // 选中：橙色方形背景 + 白色图标；未选中：透明背景 + 灰色图标
            btn_pane.backgroundColor = isSelected_pane ? selectedColor_Pane : .clear
            btn_pane.tintColor       = isSelected_pane ? .white : normalColor_Pane
        }
        // 发布按钮始终保持 isSelected = false（原图不染色）
        btnRelease_Pane.isSelected = false
    }
}
