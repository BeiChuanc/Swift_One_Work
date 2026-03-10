import Foundation
import UIKit
import SnapKit

// MARK: - 底部导航控制器
// 核心作用：自定义 Tab Bar，图标来自 Assets（home/discover/publish/message/me）
// 设计思路：全宽紫色背景（#BE92FD）贴底，5 个等宽 slot，发布按钮 54×54 居中，其余 36×36；
//           非发布 Tab 选中时在图标正下方显示白色下划线指示器
// 关键属性：tabBgView_Moode（背景）、slotStack_Moode（等宽分槽容器）、indicators_Moode（下划线数组）

/// 底部导航控制器
class TabBar_Moode: UITabBarController {

    // MARK: - 背景 & 容器

    /// 背景视图（全宽贴底，颜色 #BE92FD）
    private let tabBgView_Moode = UIView()

    /// 等宽分槽容器（fillEqually 保证每个 Tab 等宽）
    private let slotStack_Moode: UIStackView = {
        let sv = UIStackView()
        sv.axis         = .horizontal
        sv.distribution = .fillEqually
        sv.alignment    = .fill
        return sv
    }()

    // MARK: - Tab 按钮

    /// 首页按钮
    private let btnHome_Moode     = UIButton(type: .custom)
    /// 发现页按钮
    private let btnDiscover_Moode = UIButton(type: .custom)
    /// 发布按钮（54×54，无下划线）
    private let btnRelease_Moode  = UIButton(type: .custom)
    /// 消息按钮
    private let btnMessage_Moode  = UIButton(type: .custom)
    /// 我的按钮
    private let btnMe_Moode       = UIButton(type: .custom)

    // MARK: - 下划线指示器
    // 顺序：home(0)、discover(1)、message(2)、me(3)，不含 publish

    /// 非发布 Tab 选中下划线（白色圆角）
    private let indicators_Moode: [UIView] = (0..<4).map { _ in
        let v = UIView()
        v.backgroundColor  = .white
        v.layer.cornerRadius = 1.5
        v.isHidden = true
        return v
    }

    /// 当前选中索引
    private var currentIndex_Moode: Int = 0

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [
            Home_Moode(), Discover_Moode(), Release_Moode(),
            MessageList_Moode(), Me_Moode()
        ]
        setupUI_Moode()
        switchTab_Moode(to: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        tabBar.isHidden = true
    }

    // MARK: - UI 搭建

    /// 整体 UI 入口
    private func setupUI_Moode() {
        setupBackground_Moode()
        setupSlots_Moode()
    }

    /// 搭建背景视图：left=0, right=0, bottom=0（贴屏幕底部）
    private func setupBackground_Moode() {
        tabBgView_Moode.backgroundColor = UIColor(hexstring_Moode: "#BE92FD")
        view.addSubview(tabBgView_Moode)
        tabBgView_Moode.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            // 内容区 56pt，安全区在底部自动延伸
            make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-56)
        }

        tabBgView_Moode.addSubview(slotStack_Moode)
        slotStack_Moode.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }

    /// 搭建 5 个等宽 slot，每个 slot 包含图标按钮（+ 下划线）
    private func setupSlots_Moode() {
        // (按钮, Asset 图标名, tag, 下划线索引/-1=无)
        let tabData: [(UIButton, String, Int, Int)] = [
            (btnHome_Moode,     "home",    0,  0),
            (btnDiscover_Moode, "discover",1,  1),
            (btnRelease_Moode,  "publish", 2, -1),
            (btnMessage_Moode,  "message", 3,  2),
            (btnMe_Moode,       "me",      4,  3)
        ]

        for (btn, imageName, tag, indicatorIdx) in tabData {
            let isPublish  = (tag == 2)
            let iconSize: CGFloat = isPublish ? 54 : 36

            // 发布按钮保持原图不染色，其余 template 模式支持 tintColor 选中态着色
            let renderMode: UIImage.RenderingMode = isPublish ? .alwaysOriginal : .alwaysTemplate
            let img = UIImage(named: imageName)?.withRenderingMode(renderMode)
            btn.setImage(img, for: .normal)
            btn.setImage(img, for: .selected)
            btn.imageView?.contentMode = .scaleAspectFit
            btn.tag = tag
            btn.addTarget(self, action: #selector(tabButtonTapped_Moode(_:)), for: .touchUpInside)

            // slot 容器（fillEqually 会分配等宽）
            let slot = UIView()
            slotStack_Moode.addArrangedSubview(slot)

            slot.addSubview(btn)
            btn.snp.makeConstraints { make in
                make.width.height.equalTo(iconSize)
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(isPublish ? 1 : 8)
            }

            // 非发布 Tab：添加下划线指示器
            if indicatorIdx >= 0 {
                let indicator = indicators_Moode[indicatorIdx]
                slot.addSubview(indicator)
                indicator.snp.makeConstraints { make in
                    make.centerX.equalToSuperview()
                    make.top.equalTo(btn.snp.bottom).offset(3)
                    make.width.equalTo(22)
                    make.height.equalTo(3)
                }
            }
        }
    }

    // MARK: - 选中状态更新

    /// 更新所有按钮 tintColor 及下划线显示
    /// - Parameter index_Moode: 目标 Tab 索引
    private func updateSelection_Moode(index_Moode: Int) {
        let allBtns: [(UIButton, Int)] = [
            (btnHome_Moode, 0), (btnDiscover_Moode, 1), (btnRelease_Moode, 2),
            (btnMessage_Moode, 3), (btnMe_Moode, 4)
        ]
        for (btn, tabIdx) in allBtns {
            let selected   = (tabIdx == index_Moode)
            btn.isSelected = selected
            // 发布按钮使用原图，不需要 tintColor；其余按钮通过 tintColor 区分选中态
            if tabIdx != 2 {
                btn.tintColor = selected
                    ? .white
                    : UIColor.white.withAlphaComponent(0.45)
            }
        }

        // 下划线：tab index → indicator index（跳过 publish=2）
        let indicatorMap: [Int: Int] = [0: 0, 1: 1, 3: 2, 4: 3]
        for (tabIdx, indicatorIdx) in indicatorMap {
            indicators_Moode[indicatorIdx].isHidden = (index_Moode != tabIdx)
        }
    }

    // MARK: - 事件

    /// Tab 按钮点击回调
    @objc private func tabButtonTapped_Moode(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        switchTab_Moode(to: sender.tag)
    }

    /// 外部调用：切换到指定 Tab 索引，同步选中态
    /// - Parameter index_moode: 目标 Tab 索引（0=首页 1=发现 2=发布 3=消息 4=我的）
    func switchTab_Moode(to index_moode: Int) {
        currentIndex_Moode = index_moode
        selectedIndex      = index_moode
        updateSelection_Moode(index_Moode: index_moode)
    }
}
