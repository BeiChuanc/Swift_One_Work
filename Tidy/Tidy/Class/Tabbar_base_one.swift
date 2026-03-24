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
///   - currentIndex_Base_one：当前选中的 Tab 索引
///   - switchTab_Base_one(to:)：切换 Tab，更新选中状态与指示器
class TabBar_Base_one: UITabBarController {

    // MARK: - 布局常量

    /// 普通内容区高度（拱形顶边以下）
    private let kBarH_Base_one: CGFloat        = 60
    /// 拱顶相对两侧边的上升高度
    private let kArchRise_Base_one: CGFloat    = 26
    /// 普通 Tab 图标按钮尺寸
    private let kNormalSize_Base_one: CGFloat  = 34
    /// 发布按钮尺寸
    private let kPublishSize_Base_one: CGFloat = 64
    /// 发布按钮相对普通按钮向上偏移
    private let kPublishLift_Base_one: CGFloat = 10

    // MARK: - UI 组件

    /// 拱形背景视图
    private let tabBgView_Base_one = UIView()

    /// 拱形填充 ShapeLayer
    private let archShapeLayer_Base_one = CAShapeLayer()

    // Tab 按钮
    private let btnHome_Base_one     = UIButton(type: .custom)
    private let btnDiscover_Base_one = UIButton(type: .custom)
    private let btnRelease_Base_one  = UIButton(type: .custom)
    private let btnMessage_Base_one  = UIButton(type: .custom)
    private let btnMe_Base_one       = UIButton(type: .custom)

    // 选中下划线指示器（发布按钮无指示器）
    private let indHome_Base_one     = UIView()
    private let indDiscover_Base_one = UIView()
    private let indMessage_Base_one  = UIView()
    private let indMe_Base_one       = UIView()

    /// 当前选中索引
    private var currentIndex_Base_one: Int = 0

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [
            Home_Base_one(),
            Discover_Base_one(),
            Release_Base_one(),
            MessageList_Base_one(),
            Me_Base_one()
        ]
        setupUI_Base_one()
        setupConstraints_Base_one()
        switchTab_Base_one(to: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        tabBar.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateArchPath_Base_one()
    }

    // MARK: - UI 搭建

    private func setupUI_Base_one() {
        /// 背景视图：不裁切，使 ShapeLayer 阴影可见
        tabBgView_Base_one.backgroundColor = .clear
        tabBgView_Base_one.layer.shadowColor = UIColor(hexstring_Base_one: "#00C3BA").withAlphaComponent(0.35).cgColor
        tabBgView_Base_one.layer.shadowOffset = CGSize(width: 0, height: -6)
        tabBgView_Base_one.layer.shadowRadius = 16
        tabBgView_Base_one.layer.shadowOpacity = 1
        tabBgView_Base_one.layer.masksToBounds = false
        view.addSubview(tabBgView_Base_one)

        /// 拱形 CAShapeLayer（填充品牌色）
        archShapeLayer_Base_one.fillColor   = UIColor(hexstring_Base_one: "#00C3BA").cgColor
        archShapeLayer_Base_one.strokeColor = UIColor.clear.cgColor
        tabBgView_Base_one.layer.addSublayer(archShapeLayer_Base_one)

        /// 普通 Tab 按钮
        buildNormalBtn_Base_one(btnHome_Base_one,     image: "home",     tag: 0)
        buildNormalBtn_Base_one(btnDiscover_Base_one, image: "discover", tag: 1)
        buildNormalBtn_Base_one(btnMessage_Base_one,  image: "message",  tag: 3)
        buildNormalBtn_Base_one(btnMe_Base_one,       image: "me",       tag: 4)

        /// 发布按钮（原图，无选中态切换）
        let publishImg_Base_one = UIImage(named: "publish")?.withRenderingMode(.alwaysOriginal)
        btnRelease_Base_one.setImage(publishImg_Base_one, for: .normal)
        btnRelease_Base_one.setImage(publishImg_Base_one, for: .selected)
        btnRelease_Base_one.tag = 2
        btnRelease_Base_one.addTarget(self, action: #selector(tabButtonTapped_Base_one(_:)), for: .touchUpInside)
        tabBgView_Base_one.addSubview(btnRelease_Base_one)

        /// 下划线指示器（白色圆角胶囊，初始隐藏）
        [indHome_Base_one, indDiscover_Base_one, indMessage_Base_one, indMe_Base_one].forEach { ind in
            ind.backgroundColor = .white
            ind.layer.cornerRadius = 1.5
            ind.isHidden = true
            tabBgView_Base_one.addSubview(ind)
        }

        tabBgView_Base_one.addSubview(btnHome_Base_one)
        tabBgView_Base_one.addSubview(btnDiscover_Base_one)
        tabBgView_Base_one.addSubview(btnMessage_Base_one)
        tabBgView_Base_one.addSubview(btnMe_Base_one)
    }

    /// 配置普通 Tab 按钮（使用原图，不进行 tint 染色）
    /// - Parameters:
    ///   - btn: 目标按钮
    ///   - image: Assets 图片名称
    ///   - tag: Tab 索引
    private func buildNormalBtn_Base_one(_ btn: UIButton, image: String, tag: Int) {
        let img = UIImage(named: image)?.withRenderingMode(.alwaysOriginal)
        btn.setImage(img, for: .normal)
        btn.setImage(img, for: .selected)
        btn.tag  = tag
        btn.addTarget(self, action: #selector(tabButtonTapped_Base_one(_:)), for: .touchUpInside)
    }

    // MARK: - 约束布局

    /// 设置 SnapKit 约束
    /// 背景视图从安全区底部向上延伸（archRise + barH），覆盖安全区到底边
    private func setupConstraints_Base_one() {
        let bgTotalH_Base_one = kArchRise_Base_one + kBarH_Base_one

        /// 背景视图从安全区底部往上 bgTotalH，再延伸到屏幕底边
        tabBgView_Base_one.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-bgTotalH_Base_one)
        }

        /// 普通按钮的 centerY：位于拱区 (archRise) 之下、内容区的垂直中心
        let normalCenterYOffset_Base_one = kArchRise_Base_one + kBarH_Base_one / 2

        /// 发布按钮 centerY：比普通按钮高 kPublishLift
        let publishCenterYOffset_Base_one = normalCenterYOffset_Base_one - kPublishLift_Base_one

        /// 五个按钮从左到右等分 5 份
        let seg_Base_one = UIScreen.main.bounds.width / 5

        // Home（索引 0）
        btnHome_Base_one.snp.makeConstraints { make in
            make.centerX.equalTo(tabBgView_Base_one.snp.leading).offset(seg_Base_one * 0.5)
            make.centerY.equalTo(tabBgView_Base_one.snp.top).offset(normalCenterYOffset_Base_one)
            make.width.height.equalTo(kNormalSize_Base_one)
        }
        // Discover（索引 1）
        btnDiscover_Base_one.snp.makeConstraints { make in
            make.centerX.equalTo(tabBgView_Base_one.snp.leading).offset(seg_Base_one * 1.5)
            make.centerY.equalTo(tabBgView_Base_one.snp.top).offset(normalCenterYOffset_Base_one)
            make.width.height.equalTo(kNormalSize_Base_one)
        }
        // Publish（索引 2，凸出拱顶）
        btnRelease_Base_one.snp.makeConstraints { make in
            make.centerX.equalTo(tabBgView_Base_one.snp.leading).offset(seg_Base_one * 2.5)
            make.centerY.equalTo(tabBgView_Base_one.snp.top).offset(publishCenterYOffset_Base_one)
            make.width.height.equalTo(kPublishSize_Base_one)
        }
        // Message（索引 3）
        btnMessage_Base_one.snp.makeConstraints { make in
            make.centerX.equalTo(tabBgView_Base_one.snp.leading).offset(seg_Base_one * 3.5)
            make.centerY.equalTo(tabBgView_Base_one.snp.top).offset(normalCenterYOffset_Base_one)
            make.width.height.equalTo(kNormalSize_Base_one)
        }
        // Me（索引 4）
        btnMe_Base_one.snp.makeConstraints { make in
            make.centerX.equalTo(tabBgView_Base_one.snp.leading).offset(seg_Base_one * 4.5)
            make.centerY.equalTo(tabBgView_Base_one.snp.top).offset(normalCenterYOffset_Base_one)
            make.width.height.equalTo(kNormalSize_Base_one)
        }

        /// 下划线：位于对应按钮正下方 5pt，宽 18pt，高 3pt
        let indicatorPairs_Base_one: [(UIView, UIButton)] = [
            (indHome_Base_one,     btnHome_Base_one),
            (indDiscover_Base_one, btnDiscover_Base_one),
            (indMessage_Base_one,  btnMessage_Base_one),
            (indMe_Base_one,       btnMe_Base_one)
        ]
        indicatorPairs_Base_one.forEach { ind, btn in
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
    private func updateArchPath_Base_one() {
        let b = tabBgView_Base_one.bounds
        guard b.width > 0 else { return }

        let rise = kArchRise_Base_one
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

        archShapeLayer_Base_one.path  = path.cgPath
        archShapeLayer_Base_one.frame = b
    }

    // MARK: - 事件处理

    /// Tab 按钮点击
    @objc private func tabButtonTapped_Base_one(_ sender: UIButton) {
        switchTab_Base_one(to: sender.tag)
    }

    // MARK: - Tab 切换

    /// 切换到指定 Tab 索引，更新选中状态和下划线指示器
    /// - Parameter index_base_one: 目标索引（0 首页，1 发现，2 发布，3 消息，4 我的）
    func switchTab_Base_one(to index_base_one: Int) {
        currentIndex_Base_one = index_base_one
        selectedIndex = index_base_one

        btnHome_Base_one.isSelected     = (index_base_one == 0)
        btnDiscover_Base_one.isSelected  = (index_base_one == 1)
        btnRelease_Base_one.isSelected   = (index_base_one == 2)
        btnMessage_Base_one.isSelected   = (index_base_one == 3)
        btnMe_Base_one.isSelected        = (index_base_one == 4)

        /// 下划线只在非发布 Tab 选中时显示
        indHome_Base_one.isHidden     = (index_base_one != 0)
        indDiscover_Base_one.isHidden  = (index_base_one != 1)
        indMessage_Base_one.isHidden   = (index_base_one != 3)
        indMe_Base_one.isHidden        = (index_base_one != 4)

        /// 选中缩放反馈（发布按钮用脉冲，普通 Tab 用弹簧缩放）
        let activeBtn_Base_one: UIButton
        switch index_base_one {
        case 0: activeBtn_Base_one = btnHome_Base_one
        case 1: activeBtn_Base_one = btnDiscover_Base_one
        case 2: activeBtn_Base_one = btnRelease_Base_one
        case 3: activeBtn_Base_one = btnMessage_Base_one
        default: activeBtn_Base_one = btnMe_Base_one
        }
        UIView.animate(withDuration: 0.12,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.8,
                       options: .curveEaseOut) {
            activeBtn_Base_one.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        } completion: { _ in
            UIView.animate(withDuration: 0.10) {
                activeBtn_Base_one.transform = .identity
            }
        }
    }

    /// 切换到发现页
    func switchToDiscover_Base_one() {
        switchTab_Base_one(to: 1)
    }
}
