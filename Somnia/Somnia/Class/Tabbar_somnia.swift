import Foundation
import UIKit
import SnapKit

// MARK: 导航器

/// 底部自定义导航控制器
/// 核心功能：管理5个Tab页切换，非发布页选中时在图标上方展示 #FFCDDC 圆角滑条，切换时滑条执行弹簧滑动动画
/// 设计理念：纯白胶囊背景 + 四周阴影 + 原始图标 + 粉色滑条跟随动画
/// 关键属性：tabBgView_Somnia（背景胶囊）、indicatorSlider_Somnia（共享滑条）、各 btnXxx_Somnia（Tab 按钮）
class TabBar_Somnia: UITabBarController {

    // MARK: - UI 属性

    /// 底部白色胶囊背景（带四周阴影）
    private let tabBgView_Somnia = UIView()

    /// 按钮容器横向 StackView
    private let tabStackView_Somnia = UIStackView()

    /// 首页 Tab 按钮
    private var btnHome_Somnia = UIButton(type: .custom)

    /// 发现页 Tab 按钮
    private var btnDiscover_Somnia = UIButton(type: .custom)

    /// 发布 Tab 按钮（无选中滑条）
    private var btnRelease_Somnia = UIButton(type: .custom)

    /// 消息 Tab 按钮
    private var btnMessage_Somnia = UIButton(type: .custom)

    /// 我的 Tab 按钮
    private var btnMe_Somnia = UIButton(type: .custom)

    /// 共享选中滑条（在各非发布 Tab 之间横向滑动）
    private let indicatorSlider_Somnia = UIView()

    /// 当前选中索引
    private var currentIndex_Somnia: Int = 0

    /// 是否已完成首次布局（用于初始化滑条位置）
    private var hasInitializedSlider_Somnia = false

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()

        viewControllers = [Home_Somnia(), Discover_Somnia(), Release_Somnia(), MessageList_Somnia(), Me_Somnia()]

        setupUI_Somnia()
        setupConstraints_Somnia()

        // 监听切换到发现页通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(switchToDiscover_Somnia),
            name: Notification.Name("SwitchToDiscover_Somnia"),
            object: nil
        )
        // 监听切换到消息页通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(switchToMessage_Somnia),
            name: Notification.Name("SwitchToMessage_Somnia"),
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        tabBar.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // viewDidAppear 时所有子视图 frame 已完全确定，再定位滑条才能拿到准确坐标
        if !hasInitializedSlider_Somnia {
            hasInitializedSlider_Somnia = true
            placeSlider_Somnia(onButton_somnia: buttonForIndex_Somnia(currentIndex_Somnia), animated_somnia: false)
        }
    }

    // MARK: - UI 构建

    /// 初始化底部 TabBar 所有子视图
    private func setupUI_Somnia() {
        // 胶囊背景：纯白 + 四周阴影（masksToBounds 必须为 false 才能显示 shadow）
        tabBgView_Somnia.backgroundColor       = UIColor(hexstring_Somnia: "#FFFFFF")
        tabBgView_Somnia.layer.masksToBounds   = false
        tabBgView_Somnia.layer.shadowColor     = UIColor.black.withAlphaComponent(0.14).cgColor
        tabBgView_Somnia.layer.shadowOffset    = .zero
        tabBgView_Somnia.layer.shadowRadius    = 16
        tabBgView_Somnia.layer.shadowOpacity   = 1
        view.addSubview(tabBgView_Somnia)

        // StackView
        tabStackView_Somnia.axis         = .horizontal
        tabStackView_Somnia.distribution = .equalSpacing
        tabStackView_Somnia.alignment    = .center
        tabStackView_Somnia.spacing      = 20
        view.addSubview(tabStackView_Somnia)

        // 共享滑条（初始隐藏，viewDidLayoutSubviews 后定位显示）
        indicatorSlider_Somnia.backgroundColor    = UIColor(hexstring_Somnia: "#FFCDDC")
        indicatorSlider_Somnia.layer.cornerRadius = 2.5
        indicatorSlider_Somnia.frame              = CGRect(x: 0, y: 0, width: 32, height: 5)
        tabBgView_Somnia.addSubview(indicatorSlider_Somnia)

        // 构建各 Tab 按钮（原始图标，32×32）
        buildTabButton_Somnia(button: &btnHome_Somnia,     imageName_somnia: "home",    tag_somnia: 0)
        buildTabButton_Somnia(button: &btnDiscover_Somnia, imageName_somnia: "discover", tag_somnia: 1)
        buildTabButton_Somnia(button: &btnRelease_Somnia,  imageName_somnia: "publish",  tag_somnia: 2)
        buildTabButton_Somnia(button: &btnMessage_Somnia,  imageName_somnia: "message",  tag_somnia: 3)
        buildTabButton_Somnia(button: &btnMe_Somnia,       imageName_somnia: "me",       tag_somnia: 4)
    }

    /// 构建单个 Tab 按钮（原图渲染，不含单独指示器）
    /// - Parameters:
    ///   - button: 按钮引用
    ///   - imageName_somnia: Assets 中图标名称
    ///   - tag_somnia: 对应 Tab 索引（0-4）
    private func buildTabButton_Somnia(button: inout UIButton, imageName_somnia: String, tag_somnia: Int) {
        // alwaysOriginal 保留图标原色，不受 tintColor 影响
        let img = UIImage(named: imageName_somnia)?.withRenderingMode(.alwaysOriginal)
        button.setImage(img, for: .normal)
        button.setImage(img, for: .selected)
        button.imageView?.contentMode = .scaleAspectFit
        button.tag = tag_somnia
        button.addTarget(self, action: #selector(tabButtonTapped_Somnia(_:)), for: .touchUpInside)
        tabStackView_Somnia.addArrangedSubview(button)
    }

    // MARK: - 约束

    /// 布局 StackView、各按钮及胶囊背景
    private func setupConstraints_Somnia() {
        tabStackView_Somnia.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.bottom.equalToSuperview().offset(-50)
            make.height.equalTo(50)
        }

        // 非发布按钮：高度 46pt（上方留出 9pt 给滑条 + 间距，剩余 32pt 显示图标）
        [btnHome_Somnia, btnDiscover_Somnia, btnMessage_Somnia, btnMe_Somnia].forEach { btn in
            btn.snp.makeConstraints { make in
                make.width.equalTo(40)
                make.height.equalTo(46)
            }
        }
        // 发布按钮保持正方形
        btnRelease_Somnia.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }

        // 胶囊背景（stackView 四周各扩展约 22/14pt）
        tabBgView_Somnia.snp.makeConstraints { make in
            make.leading.equalTo(tabStackView_Somnia).offset(-22)
            make.trailing.equalTo(tabStackView_Somnia).offset(22)
            make.top.equalTo(tabStackView_Somnia).offset(-14)
            make.bottom.equalTo(tabStackView_Somnia).offset(14)
        }

        // 胶囊圆角（完整弧形）
        let bgHeight = 50 + 28
        tabBgView_Somnia.layer.cornerRadius = CGFloat(bgHeight) / 2.0
    }

    // MARK: - 滑条定位

    /// 将滑条移动到指定按钮的正上方
    /// - Parameters:
    ///   - button_somnia: 目标按钮（发布按钮时隐藏滑条）
    ///   - animated_somnia: 是否执行弹簧滑动动画
    private func placeSlider_Somnia(onButton_somnia button: UIButton, animated_somnia: Bool) {
        // 发布页（tag=2）不显示滑条
        let isPublish = (button.tag == 2)
        if isPublish {
            UIView.animate(withDuration: 0.2) {
                self.indicatorSlider_Somnia.alpha = 0
            }
            return
        }

        // 以公共父视图 view 为中转，准确计算按钮中心在 tabBgView 坐标系中的 X 值
        // 直接 from: button 在首次布局时可能因兄弟视图坐标链未完成而偏移
        let btnCenterInWindow = button.convert(CGPoint(x: button.bounds.midX, y: 0), to: view)
        let btnCenterInBg     = tabBgView_Somnia.convert(btnCenterInWindow, from: view)

        // 滑条贴近 tabBgView 顶部内边距 8pt（位于图标上方）
        let sliderY: CGFloat = 8
        let targetFrame = CGRect(
            x: btnCenterInBg.x - 16,
            y: sliderY,
            width: 32,
            height: 5
        )

        if animated_somnia {
            UIView.animate(
                withDuration: 0.42,
                delay: 0,
                usingSpringWithDamping: 0.68,
                initialSpringVelocity: 0.6,
                options: [.curveEaseOut]
            ) {
                self.indicatorSlider_Somnia.frame = targetFrame
                self.indicatorSlider_Somnia.alpha = 1
            }
        } else {
            indicatorSlider_Somnia.frame = targetFrame
            indicatorSlider_Somnia.alpha = 1
        }
    }

    // MARK: - 工具方法

    /// 根据索引返回对应 Tab 按钮
    /// - Parameter index_somnia: Tab 索引（0-4）
    private func buttonForIndex_Somnia(_ index_somnia: Int) -> UIButton {
        switch index_somnia {
        case 0: return btnHome_Somnia
        case 1: return btnDiscover_Somnia
        case 2: return btnRelease_Somnia
        case 3: return btnMessage_Somnia
        default: return btnMe_Somnia
        }
    }

    // MARK: - 交互

    /// 更新选中 Tab：切换页面 + 滑动滑条
    /// - Parameter index_somnia: 目标 Tab 索引（0-4）
    private func updateSelection_Somnia(index_somnia: Int) {
        currentIndex_Somnia = index_somnia
        selectedIndex       = index_somnia
        placeSlider_Somnia(onButton_somnia: buttonForIndex_Somnia(index_somnia), animated_somnia: true)
    }

    /// Tab 按钮点击
    @objc private func tabButtonTapped_Somnia(_ sender: UIButton) {
        updateSelection_Somnia(index_somnia: sender.tag)
    }

    /// 切换到发现页（索引1）
    @objc private func switchToDiscover_Somnia() {
        updateSelection_Somnia(index_somnia: 1)
    }

    /// 切换到消息列表页（索引3）
    @objc private func switchToMessage_Somnia() {
        updateSelection_Somnia(index_somnia: 3)
    }
}
