import Foundation
import UIKit
import SnapKit

// MARK: 导航器

/// 底部导航页面
/// 核心作用：自定义拱形 Tab 栏
/// 设计思路：
///   背景使用二次贝塞尔曲线绘制拱形顶边（中间高、两侧低），颜色 #00C3BA；
///   发布按钮 64×64 相对其他按钮上移 10pt 凸出拱顶；
///   其余按钮 34×34，选中时图标正下方显示白色下划线指示器；
///   所有图标使用 Assets 原图（alwaysOriginal），不做颜色染色。
/// 关键属性/方法：
///   - currentIndex_Tidy：当前选中的 Tab 索引
///   - switchTab_Tidy(to:)：切换 Tab，更新选中状态与指示器
class TabBar_Tidy: UITabBarController {

    // MARK: - 布局常量

    /// 普通内容区高度（拱形顶边以下）
    private let kBarH_Tidy: CGFloat        = 60
    /// 拱顶相对两侧边的上升高度
    private let kArchRise_Tidy: CGFloat    = 26
    /// 普通 Tab 图标按钮尺寸
    private let kNormalSize_Tidy: CGFloat  = 34
    /// 发布按钮尺寸
    private let kPublishSize_Tidy: CGFloat = 64
    /// 发布按钮相对普通按钮向上偏移
    private let kPublishLift_Tidy: CGFloat = 10

    // MARK: - UI 组件

    /// 拱形背景视图
    private let tabBgView_Tidy = UIView()

    /// 拱形填充 ShapeLayer
    private let archShapeLayer_Tidy = CAShapeLayer()

    // Tab 按钮
    private let btnHome_Tidy     = UIButton(type: .custom)
    private let btnDiscover_Tidy = UIButton(type: .custom)
    private let btnRelease_Tidy  = UIButton(type: .custom)
    private let btnMessage_Tidy  = UIButton(type: .custom)
    private let btnMe_Tidy       = UIButton(type: .custom)

    // 选中下划线指示器（发布按钮无指示器）
    private let indHome_Tidy     = UIView()
    private let indDiscover_Tidy = UIView()
    private let indMessage_Tidy  = UIView()
    private let indMe_Tidy       = UIView()

    /// 当前选中索引
    private var currentIndex_Tidy: Int = 0

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [
            Home_Tidy(),
            Discover_Tidy(),
            Release_Tidy(),
            MessageList_Tidy(),
            Me_Tidy()
        ]
        setupUI_Tidy()
        setupConstraints_Tidy()
        switchTab_Tidy(to: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 使用 setNavigationBarHidden 而非直接赋值 isHidden，
        // 确保 UINavigationController 内部状态与视觉同步，避免子页面调用 setNavigationBarHidden(false) 失效
        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBar.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateArchPath_Tidy()
    }

    // MARK: - UI 搭建

    private func setupUI_Tidy() {
        /// 背景视图：不裁切，使 ShapeLayer 阴影可见
        tabBgView_Tidy.backgroundColor = .clear
        tabBgView_Tidy.layer.shadowColor = UIColor(hexstring_Tidy: "#00C3BA").withAlphaComponent(0.35).cgColor
        tabBgView_Tidy.layer.shadowOffset = CGSize(width: 0, height: -6)
        tabBgView_Tidy.layer.shadowRadius = 16
        tabBgView_Tidy.layer.shadowOpacity = 1
        tabBgView_Tidy.layer.masksToBounds = false
        view.addSubview(tabBgView_Tidy)

        /// 拱形 CAShapeLayer（填充品牌色）
        archShapeLayer_Tidy.fillColor   = UIColor(hexstring_Tidy: "#00C3BA").cgColor
        archShapeLayer_Tidy.strokeColor = UIColor.clear.cgColor
        tabBgView_Tidy.layer.addSublayer(archShapeLayer_Tidy)

        /// 普通 Tab 按钮
        buildNormalBtn_Tidy(btnHome_Tidy,     image: "home",     tag: 0)
        buildNormalBtn_Tidy(btnDiscover_Tidy, image: "discover", tag: 1)
        buildNormalBtn_Tidy(btnMessage_Tidy,  image: "message",  tag: 3)
        buildNormalBtn_Tidy(btnMe_Tidy,       image: "me",       tag: 4)

        /// 发布按钮（原图，无选中态切换）
        let publishImg_Tidy = UIImage(named: "publish")?.withRenderingMode(.alwaysOriginal)
        btnRelease_Tidy.setImage(publishImg_Tidy, for: .normal)
        btnRelease_Tidy.setImage(publishImg_Tidy, for: .selected)
        btnRelease_Tidy.tag = 2
        btnRelease_Tidy.addTarget(self, action: #selector(tabButtonTapped_Tidy(_:)), for: .touchUpInside)
        tabBgView_Tidy.addSubview(btnRelease_Tidy)

        /// 下划线指示器（白色圆角胶囊，初始隐藏）
        [indHome_Tidy, indDiscover_Tidy, indMessage_Tidy, indMe_Tidy].forEach { ind in
            ind.backgroundColor = .white
            ind.layer.cornerRadius = 1.5
            ind.isHidden = true
            tabBgView_Tidy.addSubview(ind)
        }

        tabBgView_Tidy.addSubview(btnHome_Tidy)
        tabBgView_Tidy.addSubview(btnDiscover_Tidy)
        tabBgView_Tidy.addSubview(btnMessage_Tidy)
        tabBgView_Tidy.addSubview(btnMe_Tidy)
    }

    /// 配置普通 Tab 按钮（使用原图，不进行 tint 染色）
    /// - Parameters:
    ///   - btn: 目标按钮
    ///   - image: Assets 图片名称
    ///   - tag: Tab 索引
    private func buildNormalBtn_Tidy(_ btn: UIButton, image: String, tag: Int) {
        let img = UIImage(named: image)?.withRenderingMode(.alwaysOriginal)
        btn.setImage(img, for: .normal)
        btn.setImage(img, for: .selected)
        btn.tag  = tag
        btn.addTarget(self, action: #selector(tabButtonTapped_Tidy(_:)), for: .touchUpInside)
    }

    // MARK: - 约束布局

    /// 设置 SnapKit 约束
    /// 背景视图从安全区底部向上延伸（archRise + barH），覆盖安全区到底边
    private func setupConstraints_Tidy() {
        let bgTotalH_Tidy = kArchRise_Tidy + kBarH_Tidy

        /// 背景视图从安全区底部往上 bgTotalH，再延伸到屏幕底边
        tabBgView_Tidy.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-bgTotalH_Tidy)
        }

        /// 普通按钮的 centerY：位于拱区 (archRise) 之下、内容区的垂直中心
        let normalCenterYOffset_Tidy = kArchRise_Tidy + kBarH_Tidy / 2

        /// 发布按钮 centerY：比普通按钮高 kPublishLift
        let publishCenterYOffset_Tidy = normalCenterYOffset_Tidy - kPublishLift_Tidy

        /// 五个按钮从左到右等分 5 份
        let seg_Tidy = UIScreen.main.bounds.width / 5

        // Home（索引 0）
        btnHome_Tidy.snp.makeConstraints { make in
            make.centerX.equalTo(tabBgView_Tidy.snp.leading).offset(seg_Tidy * 0.5)
            make.centerY.equalTo(tabBgView_Tidy.snp.top).offset(normalCenterYOffset_Tidy)
            make.width.height.equalTo(kNormalSize_Tidy)
        }
        // Discover（索引 1）
        btnDiscover_Tidy.snp.makeConstraints { make in
            make.centerX.equalTo(tabBgView_Tidy.snp.leading).offset(seg_Tidy * 1.5)
            make.centerY.equalTo(tabBgView_Tidy.snp.top).offset(normalCenterYOffset_Tidy)
            make.width.height.equalTo(kNormalSize_Tidy)
        }
        // Publish（索引 2，凸出拱顶）
        btnRelease_Tidy.snp.makeConstraints { make in
            make.centerX.equalTo(tabBgView_Tidy.snp.leading).offset(seg_Tidy * 2.5)
            make.centerY.equalTo(tabBgView_Tidy.snp.top).offset(publishCenterYOffset_Tidy)
            make.width.height.equalTo(kPublishSize_Tidy)
        }
        // Message（索引 3）
        btnMessage_Tidy.snp.makeConstraints { make in
            make.centerX.equalTo(tabBgView_Tidy.snp.leading).offset(seg_Tidy * 3.5)
            make.centerY.equalTo(tabBgView_Tidy.snp.top).offset(normalCenterYOffset_Tidy)
            make.width.height.equalTo(kNormalSize_Tidy)
        }
        // Me（索引 4）
        btnMe_Tidy.snp.makeConstraints { make in
            make.centerX.equalTo(tabBgView_Tidy.snp.leading).offset(seg_Tidy * 4.5)
            make.centerY.equalTo(tabBgView_Tidy.snp.top).offset(normalCenterYOffset_Tidy)
            make.width.height.equalTo(kNormalSize_Tidy)
        }

        /// 下划线：位于对应按钮正下方 5pt，宽 18pt，高 3pt
        let indicatorPairs_Tidy: [(UIView, UIButton)] = [
            (indHome_Tidy,     btnHome_Tidy),
            (indDiscover_Tidy, btnDiscover_Tidy),
            (indMessage_Tidy,  btnMessage_Tidy),
            (indMe_Tidy,       btnMe_Tidy)
        ]
        indicatorPairs_Tidy.forEach { ind, btn in
            ind.snp.makeConstraints { make in
                make.centerX.equalTo(btn)
                make.top.equalTo(btn.snp.bottom).offset(5)
                make.width.equalTo(18)
                make.height.equalTo(3)
            }
        }
    }

    // MARK: - 拱形路径绘制

    /// 根据背景视图当前 bounds 重新计算并绘制拱形顶边 Bezier 路径
    /// 路径说明：左右两端起始于 y = archRise，中央控制点为 y = 0（最高点），
    ///           形成平滑拱顶，向下延伸填充整个背景区域
    private func updateArchPath_Tidy() {
        let b = tabBgView_Tidy.bounds
        guard b.width > 0 else { return }

        let rise = kArchRise_Tidy
        let path = UIBezierPath()

        /// 从左侧低点开始
        path.move(to: CGPoint(x: 0, y: rise))
        /// 二次贝塞尔曲线：左低点 → 中央顶点（控制点）→ 右低点，形成拱顶
        path.addQuadCurve(
            to: CGPoint(x: b.width, y: rise),
            controlPoint: CGPoint(x: b.width / 2, y: 0)
        )
        /// 沿右边、底边、左边封闭矩形区域
        path.addLine(to: CGPoint(x: b.width, y: b.height))
        path.addLine(to: CGPoint(x: 0,       y: b.height))
        path.close()

        archShapeLayer_Tidy.path  = path.cgPath
        archShapeLayer_Tidy.frame = b
    }

    // MARK: - 事件处理

    /// Tab 按钮点击
    @objc private func tabButtonTapped_Tidy(_ sender: UIButton) {
        switchTab_Tidy(to: sender.tag)
    }

    // MARK: - Tab 切换

    /// 切换到指定 Tab 索引，更新选中状态和下划线指示器
    /// - Parameter index_tidy: 目标索引（0 首页，1 发现，2 发布，3 消息，4 我的）
    func switchTab_Tidy(to index_tidy: Int) {
        currentIndex_Tidy = index_tidy
        selectedIndex = index_tidy

        btnHome_Tidy.isSelected     = (index_tidy == 0)
        btnDiscover_Tidy.isSelected  = (index_tidy == 1)
        btnRelease_Tidy.isSelected   = (index_tidy == 2)
        btnMessage_Tidy.isSelected   = (index_tidy == 3)
        btnMe_Tidy.isSelected        = (index_tidy == 4)

        /// 下划线只在非发布 Tab 选中时显示
        indHome_Tidy.isHidden     = (index_tidy != 0)
        indDiscover_Tidy.isHidden  = (index_tidy != 1)
        indMessage_Tidy.isHidden   = (index_tidy != 3)
        indMe_Tidy.isHidden        = (index_tidy != 4)

        /// 选中缩放反馈（发布按钮用脉冲，普通 Tab 用弹簧缩放）
        let activeBtn_Tidy: UIButton
        switch index_tidy {
        case 0: activeBtn_Tidy = btnHome_Tidy
        case 1: activeBtn_Tidy = btnDiscover_Tidy
        case 2: activeBtn_Tidy = btnRelease_Tidy
        case 3: activeBtn_Tidy = btnMessage_Tidy
        default: activeBtn_Tidy = btnMe_Tidy
        }
        UIView.animate(withDuration: 0.12,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.8,
                       options: .curveEaseOut) {
            activeBtn_Tidy.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        } completion: { _ in
            UIView.animate(withDuration: 0.10) {
                activeBtn_Tidy.transform = .identity
            }
        }
    }

    /// 切换到发现页
    func switchToDiscover_Tidy() {
        switchTab_Tidy(to: 1)
    }
}
