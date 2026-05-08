import Foundation
import UIKit
import SnapKit

// MARK: 底部导航栏

/// 底部 Tab 导航控制器
/// 核心作用：承载五个子页面，并提供自定义底部导航栏（Assets 原图图标 + 选中变色 + 全宽白底圆角上角）。
/// 设计思路：隐藏系统 UITabBar，用自定义 tabBgView_Posture + UIStackView 实现全宽底部导航，
///          支持选中色 #A76AFF；发布按钮始终显示原图，不受选中状态影响。
/// 关键属性：tabBgView_Posture 承载背景，tabStackView_Posture 均匀排列五个图标按钮。
/// 关键方法：updateTabSelection_Posture(index:) 切换选中样式，selectTab_Posture(index:) 供外部调用切页。
class TabBar_Posture: UITabBarController {

    /// 选中高亮颜色 #A76AFF
    private let selectedColor_Posture = UIColor(hexstring_Posture: "#A76AFF")

    /// 未选中颜色
    private let normalColor_Posture   = UIColor(hexstring_Posture: "#BDBDBD")

    /// 底部背景视图（白底 + 左右上角 25 圆角）
    private let tabBgView_Posture = UIView()

    /// 按钮横向容器
    private let tabStackView_Posture = UIStackView()

    /// 首页按钮
    private let btnHome_Posture     = UIButton(type: .custom)

    /// 发现页按钮
    private let btnDiscover_Posture = UIButton(type: .custom)

    /// 发布按钮
    private let btnRelease_Posture  = UIButton(type: .custom)

    /// 消息按钮
    private let btnMessage_Posture  = UIButton(type: .custom)

    /// 我的按钮
    private let btnMe_Posture       = UIButton(type: .custom)

    /// 当前选中索引
    private var currentIndex_Posture: Int = 0

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [Home_Posture(), Discover_Posture(), Release_Posture(), MessageList_Posture(), Me_Posture()]
        setupUI_Posture()
        setupConstraints_Posture()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        tabBar.isHidden = true
    }

    // MARK: - UI 搭建

    /// 搭建底部导航 UI（背景视图 + 五个图标按钮）
    private func setupUI_Posture() {
        // 背景视图：纯白 + 左右上角 25pt 圆角 + 顶部投影
        tabBgView_Posture.backgroundColor = UIColor(hexstring_Posture: "#FFFFFF")
        tabBgView_Posture.layer.cornerRadius = 25
        tabBgView_Posture.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tabBgView_Posture.layer.masksToBounds = false
        tabBgView_Posture.layer.shadowColor   = UIColor.black.withAlphaComponent(0.08).cgColor
        tabBgView_Posture.layer.shadowOpacity = 1
        tabBgView_Posture.layer.shadowRadius  = 16
        tabBgView_Posture.layer.shadowOffset  = CGSize(width: 0, height: -6)
        view.addSubview(tabBgView_Posture)

        // 按钮容器
        tabStackView_Posture.axis         = .horizontal
        tabStackView_Posture.distribution = .equalSpacing
        tabStackView_Posture.alignment    = .center
        view.addSubview(tabStackView_Posture)

        // 配置并添加按钮（发布按钮标记 isPublish_Posture: true）
        configureTabButton_Posture(button_Posture: btnHome_Posture,     index_Posture: 0, assetName_Posture: "home")
        configureTabButton_Posture(button_Posture: btnDiscover_Posture, index_Posture: 1, assetName_Posture: "discover")
        configureTabButton_Posture(button_Posture: btnRelease_Posture,  index_Posture: 2, assetName_Posture: "publish",  isPublish_Posture: true)
        configureTabButton_Posture(button_Posture: btnMessage_Posture,  index_Posture: 3, assetName_Posture: "message")
        configureTabButton_Posture(button_Posture: btnMe_Posture,       index_Posture: 4, assetName_Posture: "me")

        [btnHome_Posture, btnDiscover_Posture, btnRelease_Posture, btnMessage_Posture, btnMe_Posture].forEach {
            tabStackView_Posture.addArrangedSubview($0)
        }

        // 设置初始选中
        updateTabSelection_Posture(index_Posture: 0)
    }

    /// 配置单个 Tab 按钮（Assets 图标 + 渲染模式 + 点击事件）
    /// - Parameters:
    ///   - button_Posture: 目标按钮
    ///   - index_Posture: 按钮在 Tab 中的索引
    ///   - assetName_Posture: Assets 中的图片名称
    ///   - isPublish_Posture: 是否为发布按钮（始终原图，不受选中色影响）
    private func configureTabButton_Posture(
        button_Posture: UIButton,
        index_Posture: Int,
        assetName_Posture: String,
        isPublish_Posture: Bool = false
    ) {
        let rawImage_Posture = UIImage(named: assetName_Posture)

        if isPublish_Posture {
            // 发布按钮两种状态均显示原图
            let original_Posture = rawImage_Posture?.withRenderingMode(.alwaysOriginal)
            button_Posture.setImage(original_Posture, for: .normal)
            button_Posture.setImage(original_Posture, for: .selected)
            button_Posture.setImage(original_Posture, for: .highlighted)
        } else {
            // 普通按钮：未选中显示原图，选中切换为模板模式以便着色
            button_Posture.setImage(rawImage_Posture?.withRenderingMode(.alwaysOriginal),  for: .normal)
            button_Posture.setImage(rawImage_Posture?.withRenderingMode(.alwaysTemplate),  for: .selected)
        }

        button_Posture.imageView?.contentMode          = .scaleAspectFit
        button_Posture.adjustsImageWhenHighlighted     = false
        button_Posture.backgroundColor                 = .clear
        button_Posture.tag                             = index_Posture
        button_Posture.addTarget(self, action: #selector(tabButtonTapped_Posture(_:)), for: .touchUpInside)
    }

    // MARK: - 约束布局

    /// 设置约束：tabBgView 左右底为 0；图标容器贴底安全区；按钮尺寸规格化
    private func setupConstraints_Posture() {
        // 图标栈：水平居中，左右各留 28pt，底部对齐安全区上 8pt
        tabStackView_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(28)
            make.trailing.equalToSuperview().offset(-28)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-8)
            make.height.equalTo(40)
        }

        // 背景视图：左右底为 0，顶部与栈顶上方留 14pt
        tabBgView_Posture.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(tabStackView_Posture.snp.top).offset(-14)
        }

        // 发布按钮：40×40
        btnRelease_Posture.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }

        // 其余按钮：27 宽 × 40 高
        [btnHome_Posture, btnDiscover_Posture, btnMessage_Posture, btnMe_Posture].forEach { btn_posture in
            btn_posture.snp.makeConstraints { make in
                make.width.equalTo(27)
                make.height.equalTo(40)
            }
        }
    }

    // MARK: - 事件处理

    /// 处理 Tab 按钮点击
    @objc private func tabButtonTapped_Posture(_ sender: UIButton) {
        selectTab_Posture(index_Posture: sender.tag)
    }

    /// 供外部调用切换到指定 Tab
    /// - Parameter index_Posture: 目标页面索引（0~4）
    func selectTab_Posture(index_Posture: Int) {
        guard let vcs_posture = viewControllers,
              index_Posture >= 0,
              index_Posture < vcs_posture.count else { return }
        currentIndex_Posture = index_Posture
        selectedIndex        = index_Posture
        updateTabSelection_Posture(index_Posture: index_Posture)
    }

    /// 更新所有 Tab 按钮的选中 / 未选中样式
    /// - Parameter index_Posture: 当前选中索引
    private func updateTabSelection_Posture(index_Posture: Int) {
        btnHome_Posture.isSelected     = (index_Posture == 0)
        btnDiscover_Posture.isSelected = (index_Posture == 1)
        btnRelease_Posture.isSelected  = (index_Posture == 2)
        btnMessage_Posture.isSelected  = (index_Posture == 3)
        btnMe_Posture.isSelected       = (index_Posture == 4)

        // 非发布按钮：选中时将模板图染色为 #A76AFF，未选中时无色（原图已含颜色）
        [btnHome_Posture, btnDiscover_Posture, btnMessage_Posture, btnMe_Posture].forEach { btn_posture in
            btn_posture.tintColor = btn_posture.isSelected ? selectedColor_Posture : .clear
        }
    }
}
