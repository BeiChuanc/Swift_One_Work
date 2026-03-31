import Foundation
import UIKit
import SnapKit

// MARK: 导航器

/// 底部导航页面
/// 功能：自定义 Tab 背景与图标；非发布项选中时在图标下展示紫色滑条；发布项居中放大
/// 设计：背景 #0E0C1D、顶左右圆角 35、#8635F6 阴影（无描边）；图标 Assets 原色渲染
class TabBar_Flick: UITabBarController {

    /// 底部 Tab 背景（贴左右底边，仅顶部圆角）
    private let tabBgView_Flick = UIView()

    /// 按钮容器栈视图
    private let tabStackView_Flick = UIStackView()

    /// 首页按钮
    private let btnHome_Flick = UIButton(type: .custom)

    /// 发现页按钮
    private let btnDiscover_Flick = UIButton(type: .custom)

    /// 发布按钮
    private let btnRelease_Flick = UIButton(type: .custom)

    /// 消息按钮
    private let btnMessage_Flick = UIButton(type: .custom)

    /// 我的按钮
    private let btnMe_Flick = UIButton(type: .custom)

    /// 与 Tab 索引对齐的选中滑条（发布位为 nil）
    private var selectionBarViews_Flick: [UIView?] = Array(repeating: nil, count: 5)

    /// 包裹「按钮 + 滑条」的容器（发布项不用）
    private let homeColumn_Flick = UIView()
    private let discoverColumn_Flick = UIView()
    private let messageColumn_Flick = UIView()
    private let meColumn_Flick = UIView()

    /// 发布按钮外层容器（fillEqually 时保持 50×50 居中不被拉伸）
    private let releaseColumn_Flick = UIView()

    // MARK: - 生命周期方法

    override func viewDidLoad() {
        super.viewDidLoad()

        viewControllers = [Home_Flick(), Discover_Flick(), Release_Flick(), MessageList_Flick(), Me_Flick()]

        setupUI_Flick()
        setupConstraints_Flick()
        updateSelectionAppearance_Flick(index_flick: 0)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.bringSubviewToFront(tabBgView_Flick)
        view.bringSubviewToFront(tabStackView_Flick)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        tabBar.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyTabBgShadowPath_Flick()
    }

    // MARK: - UI设置

    private func setupUI_Flick() {
        configureTabBackground_Flick()

        tabStackView_Flick.axis = .horizontal
        tabStackView_Flick.distribution = .fillEqually
        tabStackView_Flick.alignment = .center
        tabStackView_Flick.spacing = 0

        view.addSubview(tabBgView_Flick)
        view.addSubview(tabStackView_Flick)

        btnHome_Flick.tag = 0
        btnDiscover_Flick.tag = 1
        btnRelease_Flick.tag = 2
        btnMessage_Flick.tag = 3
        btnMe_Flick.tag = 4

        configureTabButtonImage_Flick(button_flick: btnHome_Flick, assetName_flick: "home")
        configureTabButtonImage_Flick(button_flick: btnDiscover_Flick, assetName_flick: "discover")
        configureTabButtonImage_Flick(button_flick: btnRelease_Flick, assetName_flick: "publish")
        configureTabButtonImage_Flick(button_flick: btnMessage_Flick, assetName_flick: "message")
        configureTabButtonImage_Flick(button_flick: btnMe_Flick, assetName_flick: "me")

        [btnHome_Flick, btnDiscover_Flick, btnRelease_Flick, btnMessage_Flick, btnMe_Flick].forEach {
            $0.addTarget(self, action: #selector(tabButtonTapped_Flick(_:)), for: .touchUpInside)
        }

        assembleColumn_Flick(
            column_flick: homeColumn_Flick,
            button_flick: btnHome_Flick,
            iconSide_flick: 36,
            index_flick: 0
        )
        assembleColumn_Flick(
            column_flick: discoverColumn_Flick,
            button_flick: btnDiscover_Flick,
            iconSide_flick: 36,
            index_flick: 1
        )
        assembleColumn_Flick(
            column_flick: messageColumn_Flick,
            button_flick: btnMessage_Flick,
            iconSide_flick: 36,
            index_flick: 3
        )
        assembleColumn_Flick(
            column_flick: meColumn_Flick,
            button_flick: btnMe_Flick,
            iconSide_flick: 36,
            index_flick: 4
        )

        releaseColumn_Flick.addSubview(btnRelease_Flick)
        btnRelease_Flick.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        tabStackView_Flick.addArrangedSubview(homeColumn_Flick)
        tabStackView_Flick.addArrangedSubview(discoverColumn_Flick)
        tabStackView_Flick.addArrangedSubview(releaseColumn_Flick)
        tabStackView_Flick.addArrangedSubview(messageColumn_Flick)
        tabStackView_Flick.addArrangedSubview(meColumn_Flick)
    }

    /// Tab 背景：#0E0C1D、仅顶部圆角 35、#8635F6 阴影（无彩色描边）
    private func configureTabBackground_Flick() {
        tabBgView_Flick.backgroundColor = UIColor(hexstring_Flick: "#0E0C1D")
        tabBgView_Flick.layer.cornerRadius = 35
        tabBgView_Flick.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tabBgView_Flick.layer.borderWidth = 0
        tabBgView_Flick.layer.borderColor = nil
        tabBgView_Flick.layer.masksToBounds = false
        tabBgView_Flick.layer.shadowColor = UIColor(hexstring_Flick: "#8635F6").cgColor
        tabBgView_Flick.layer.shadowOffset = CGSize(width: 0, height: -3)
        tabBgView_Flick.layer.shadowRadius = 10
        tabBgView_Flick.layer.shadowOpacity = 0.45
    }

    /// 图标使用 Assets 原图原色（不模板染色）
    private func configureTabButtonImage_Flick(button_flick: UIButton, assetName_flick: String) {
        let img_flick = UIImage(named: assetName_flick)?.withRenderingMode(.alwaysOriginal)
        button_flick.setImage(img_flick, for: .normal)
        button_flick.setImage(img_flick, for: .selected)
        button_flick.tintColor = nil
        button_flick.adjustsImageWhenHighlighted = false
        button_flick.imageView?.contentMode = .scaleAspectFit
    }

    /// 组装单列：图标 + 距图标下 2pt 的选中滑条（高度 3）
    private func assembleColumn_Flick(
        column_flick: UIView,
        button_flick: UIButton,
        iconSide_flick: CGFloat,
        index_flick: Int
    ) {
        let bar_flick = UIView()
        bar_flick.backgroundColor = UIColor(hexstring_Flick: "#8635F6")
        bar_flick.layer.cornerRadius = 1.5
        bar_flick.alpha = 0

        column_flick.addSubview(button_flick)
        column_flick.addSubview(bar_flick)

        button_flick.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(iconSide_flick)
        }
        bar_flick.snp.makeConstraints { make in
            make.top.equalTo(button_flick.snp.bottom).offset(2)
            make.centerX.equalToSuperview()
            make.width.equalTo(22)
            make.height.equalTo(3)
            make.bottom.equalToSuperview()
        }

        selectionBarViews_Flick[index_flick] = bar_flick
    }

    /// 更新阴影路径，与顶圆角一致
    private func applyTabBgShadowPath_Flick() {
        let rect_flick = tabBgView_Flick.bounds
        guard rect_flick.width > 0, rect_flick.height > 0 else { return }
        let path_flick = UIBezierPath(
            roundedRect: rect_flick,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: 35, height: 35)
        )
        tabBgView_Flick.layer.shadowPath = path_flick.cgPath
    }

    /// 设置约束布局
    private func setupConstraints_Flick() {
        tabStackView_Flick.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.height.greaterThanOrEqualTo(56)
        }

        [homeColumn_Flick, discoverColumn_Flick, messageColumn_Flick, meColumn_Flick].forEach { col_flick in
            col_flick.snp.makeConstraints { make in
                make.height.greaterThanOrEqualTo(44)
            }
        }

        // 发布列必须给出明确高度：否则 Stack 可能把列高压成 0，父视图 bounds 不含按钮区域，系统 hitTest 不会下发到子视图，表现为点击无反应
        releaseColumn_Flick.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(56)
        }

        btnRelease_Flick.snp.makeConstraints { make in
            make.width.height.equalTo(50)
        }

        tabBgView_Flick.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(tabStackView_Flick.snp.top).offset(-16)
        }
    }

    /// 同步选中索引与滑条显隐（发布项无滑条；用 alpha 保留占位避免布局跳动）
    private func updateSelectionAppearance_Flick(index_flick: Int) {
        for idx_flick in 0..<5 {
            guard let bar_flick = selectionBarViews_Flick[idx_flick] else { continue }
            let on_flick = (idx_flick == index_flick) && (index_flick != 2)
            bar_flick.alpha = on_flick ? 1 : 0
        }
    }

    @objc private func tabButtonTapped_Flick(_ sender: UIButton) {
        let index_flick = sender.tag
        selectedIndex = index_flick
        updateSelectionAppearance_Flick(index_flick: index_flick)
    }
}
