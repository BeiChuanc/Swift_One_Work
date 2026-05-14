import Foundation
import UIKit
import SnapKit

// MARK: 底部导航栏
// 设计思路：
//   白色圆角胶囊背景；图标使用 Assets 原图（alwaysOriginal）；
//   发布图标 40×40，其余 24×24（触摸区统一 44×44）；
//   使用「单个滑动下划线」——切换 Tab 时以弹簧动画从旧图标位置滑向新图标位置，
//   下划线始终位于当前选中图标下方 10pt 处；发布 Tab 无下划线。

/// 底部 Tab 导航控制器
class TabBar_Echd: UITabBarController {

    // MARK: - UI 组件

    /// 白色圆角胶囊背景
    private var tabBgView_Echd = UIView()

    /// 按钮水平容器
    private var tabStackView_Echd = UIStackView()

    /// 五个 Tab 按钮
    private var btnHome_Echd    = UIButton(type: .custom)
    private var btnDiscover_Echd = UIButton(type: .custom)
    private var btnRelease_Echd  = UIButton(type: .custom)
    private var btnMessage_Echd  = UIButton(type: .custom)
    private var btnMe_Echd       = UIButton(type: .custom)

    /// 滑动下划线指示器（单个，在非发布 Tab 间滑动）
    private let indicator_Echd = UIView()

    /// 当前选中索引
    private var currentIndex_Echd: Int = 0

    /// 是否已完成首次布局（用于区分首次定位和动画切换）
    private var hasInitialLayout_Echd = false

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [Home_Echd(), Discover_Echd(), Release_Echd(), MessageList_Echd(), Me_Echd()]
        setupUI_Echd()
        setupConstraints_Echd()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        tabBar.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tabBgView_Echd.layer.cornerRadius = tabBgView_Echd.frame.height / 2

        // 首次布局完成后，无动画地将指示器定位到初始 Tab（Home）
        if !hasInitialLayout_Echd {
            if let frame_Echd = indicatorFrame_Echd(for: btnHome_Echd) {
                indicator_Echd.frame = frame_Echd
                indicator_Echd.isHidden = false
                hasInitialLayout_Echd = true
            }
        }
    }

    // MARK: - UI 设置

    private func setupUI_Echd() {
        // 白色圆角胶囊背景（带顶部轻阴影）
        tabBgView_Echd.backgroundColor = UIColor(hexstring_Echd: "#FFFFFF")
        tabBgView_Echd.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        tabBgView_Echd.layer.shadowOffset = CGSize(width: 0, height: -2)
        tabBgView_Echd.layer.shadowRadius = 8
        tabBgView_Echd.layer.shadowOpacity = 1
        view.addSubview(tabBgView_Echd)

        // 水平 StackView
        tabStackView_Echd.axis = .horizontal
        tabStackView_Echd.distribution = .equalSpacing
        tabStackView_Echd.alignment = .center
        view.addSubview(tabStackView_Echd)

        // 配置五个按钮
        configureNormalButton_Echd(btnHome_Echd,     imageName: "home",     tag: 0)
        configureNormalButton_Echd(btnDiscover_Echd,  imageName: "discover", tag: 1)
        configurePublishButton_Echd()
        configureNormalButton_Echd(btnMessage_Echd,   imageName: "message",  tag: 3)
        configureNormalButton_Echd(btnMe_Echd,         imageName: "me",       tag: 4)

        tabStackView_Echd.addArrangedSubview(btnHome_Echd)
        tabStackView_Echd.addArrangedSubview(btnDiscover_Echd)
        tabStackView_Echd.addArrangedSubview(btnRelease_Echd)
        tabStackView_Echd.addArrangedSubview(btnMessage_Echd)
        tabStackView_Echd.addArrangedSubview(btnMe_Echd)

        // 单个滑动下划线：frame-only 定位，初始隐藏，首次 layout 后显示
        indicator_Echd.backgroundColor = UIColor(hexstring_Echd: "#FF1569")
        indicator_Echd.layer.cornerRadius = 1
        indicator_Echd.isHidden = true
        indicator_Echd.frame = CGRect(x: 0, y: 0, width: 24, height: 2)  // 初始占位尺寸
        // 加到 view 最顶层，确保显示在 tabBgView 之上
        view.addSubview(indicator_Echd)

        btnHome_Echd.isSelected = true
    }

    /// 配置普通 Tab 按钮（图标 24×24，alwaysOriginal，触摸区 44×44）
    private func configureNormalButton_Echd(_ button: UIButton, imageName: String, tag: Int) {
        let img_Echd = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal)
        button.setImage(img_Echd, for: .normal)
        button.setImage(img_Echd, for: .selected)
        // 24×24 图标居中在 44×44 触摸区内，上下左右各 10pt 内边距
        let inset_Echd: CGFloat = (44 - 24) / 2
        button.imageEdgeInsets = UIEdgeInsets(top: inset_Echd, left: inset_Echd,
                                              bottom: inset_Echd, right: inset_Echd)
        button.tag = tag
        button.addTarget(self, action: #selector(tabButtonTapped_Echd(_:)), for: .touchUpInside)
    }

    /// 配置发布 Tab 按钮（图标 40×40，alwaysOriginal）
    private func configurePublishButton_Echd() {
        let img_Echd = UIImage(named: "publish")?.withRenderingMode(.alwaysOriginal)
        btnRelease_Echd.setImage(img_Echd, for: .normal)
        btnRelease_Echd.setImage(img_Echd, for: .selected)
        btnRelease_Echd.tag = 2
        btnRelease_Echd.addTarget(self, action: #selector(tabButtonTapped_Echd(_:)), for: .touchUpInside)
    }

    // MARK: - 约束布局

    private func setupConstraints_Echd() {
        tabStackView_Echd.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-10)
            make.height.equalTo(44)
        }

        // 普通按钮触摸区 44×44
        for btn_Echd in [btnHome_Echd, btnDiscover_Echd, btnMessage_Echd, btnMe_Echd] {
            btn_Echd.snp.makeConstraints { make in make.width.height.equalTo(44) }
        }

        // 发布按钮触摸区 44×44，图标 40×40（内边距 2pt）
        btnRelease_Echd.snp.makeConstraints { make in make.width.height.equalTo(44) }
        let pubInset_Echd: CGFloat = (44 - 40) / 2
        btnRelease_Echd.imageEdgeInsets = UIEdgeInsets(top: pubInset_Echd, left: pubInset_Echd,
                                                        bottom: pubInset_Echd, right: pubInset_Echd)

        // 白色胶囊背景：左右与 StackView 齐，垂直延伸 12pt
        tabBgView_Echd.snp.makeConstraints { make in
            make.leading.trailing.equalTo(tabStackView_Echd)
            make.top.equalTo(tabStackView_Echd).offset(-12)
            make.bottom.equalTo(tabStackView_Echd).offset(12)
        }

        // 指示器完全使用 frame 定位，不添加 SnapKit 约束
        // （SnapKit 会将 translatesAutoresizingMaskIntoConstraints 设为 false，
        //   导致后续 frame 赋值被 Auto Layout 覆盖而无效）
        indicator_Echd.translatesAutoresizingMaskIntoConstraints = true
    }

    // MARK: - 下划线位置计算

    /// 计算指定按钮对应的下划线 frame（在 self.view 坐标系中）
    /// 下划线水平居中于图标，y = 图标底部 + 10pt
    /// - Parameter btn: 目标 Tab 按钮
    /// - Returns: 下划线的 CGRect，按钮尚未布局时返回 nil
    private func indicatorFrame_Echd(for btn: UIButton) -> CGRect? {
        guard let superView_Echd = btn.superview else { return nil }
        let btnFrame_Echd = superView_Echd.convert(btn.frame, to: view)
        guard btnFrame_Echd.width > 0 else { return nil }  // 尚未布局时跳过

        let iconInset_Echd: CGFloat = (44 - 24) / 2  // 10pt，图标上方内边距
        let iconBottom_Echd = btnFrame_Echd.maxY - iconInset_Echd  // 图标底部（从按钮底部减去下方内边距）
        return CGRect(
            x: btnFrame_Echd.midX - 12,   // 24pt 宽，水平居中于图标
            y: iconBottom_Echd + 10,        // 图标底部下方 10pt
            width: 24,
            height: 2
        )
    }

    /// 根据 Tab 下标返回对应按钮（仅非发布 Tab，发布 Tab 返回 nil）
    private func buttonForIndex_Echd(_ index: Int) -> UIButton? {
        switch index {
        case 0: return btnHome_Echd
        case 1: return btnDiscover_Echd
        case 3: return btnMessage_Echd
        case 4: return btnMe_Echd
        default: return nil  // 发布 Tab：无下划线
        }
    }

    // MARK: - 事件处理

    @objc private func tabButtonTapped_Echd(_ sender: UIButton) {
        switchToTab_Echd(index_Echd: sender.tag)
    }

    /// 切换 Tab，更新按钮选中状态，并用弹簧动画将下划线滑向新位置
    /// - Parameter index_Echd: 目标 Tab 下标（0=Home 1=Discover 2=Release 3=Message 4=Me）
    func switchToTab_Echd(index_Echd: Int) {
        currentIndex_Echd = index_Echd
        selectedIndex = index_Echd

        btnHome_Echd.isSelected     = (index_Echd == 0)
        btnDiscover_Echd.isSelected = (index_Echd == 1)
        btnRelease_Echd.isSelected  = (index_Echd == 2)
        btnMessage_Echd.isSelected  = (index_Echd == 3)
        btnMe_Echd.isSelected       = (index_Echd == 4)

        if let targetBtn_Echd = buttonForIndex_Echd(index_Echd),
           let targetFrame_Echd = indicatorFrame_Echd(for: targetBtn_Echd) {
            // 发布 → 普通 Tab：先显示再动画
            if indicator_Echd.isHidden {
                indicator_Echd.frame = targetFrame_Echd
                indicator_Echd.isHidden = false
            } else {
                // 弹簧动画：从上一个图标位置滑动到当前图标位置
                UIView.animate(
                    withDuration: 0.36,
                    delay: 0,
                    usingSpringWithDamping: 0.72,
                    initialSpringVelocity: 0.5,
                    options: [.curveEaseInOut],
                    animations: {
                        self.indicator_Echd.frame = targetFrame_Echd
                    }
                )
            }
        } else {
            // 切换到发布 Tab：隐藏下划线
            UIView.animate(withDuration: 0.18) {
                self.indicator_Echd.alpha = 0
            } completion: { _ in
                self.indicator_Echd.isHidden = true
                self.indicator_Echd.alpha = 1
            }
        }
    }
}
