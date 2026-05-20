import Foundation
import UIKit
import SnapKit

// MARK: 导航器

/// 底部导航页面
/// 核心作用：自定义顶部圆角 Tab 栏
/// 设计思路：
///   背景改为顶部左右圆角的整块蓝色承载层，弱化原有拱形结构；
///   所有 Tab 图标统一使用模板渲染，未选中为灰色，选中为白色；
///   去除下划线指示器，仅保留颜色与轻微缩放反馈。
/// 关键属性/方法：
///   - currentIndex_Tidy：当前选中的 Tab 索引
///   - switchTab_Tidy(to:)：切换 Tab，更新选中状态与颜色
class TabBar_Tidy: UITabBarController {

    // MARK: - 布局常量

    /// 普通内容区高度
    private let kBarH_Tidy: CGFloat        = 60
    /// 顶部圆角半径
    private let kCornerRadius_Tidy: CGFloat = 24
    /// 普通 Tab 图标按钮尺寸
    private let kNormalSize_Tidy: CGFloat  = 34
    /// 发布按钮尺寸
    private let kPublishSize_Tidy: CGFloat = 30

    // MARK: - UI 组件

    /// 顶部圆角背景视图
    private let tabBgView_Tidy = UIView()

    /// 顶部圆角填充 ShapeLayer
    private let archShapeLayer_Tidy = CAShapeLayer()

    // Tab 按钮
    private let btnHome_Tidy     = UIButton(type: .custom)
    private let btnDiscover_Tidy = UIButton(type: .custom)
    private let btnRelease_Tidy  = UIButton(type: .custom)
    private let btnMessage_Tidy  = UIButton(type: .custom)
    private let btnMe_Tidy       = UIButton(type: .custom)

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
        /// 背景视图：顶部左右圆角蓝色底板
        tabBgView_Tidy.backgroundColor = UIColor(hexstring_Tidy: "#4A8EFF")
        tabBgView_Tidy.layer.cornerRadius = kCornerRadius_Tidy
        tabBgView_Tidy.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tabBgView_Tidy.layer.shadowColor = UIColor(hexstring_Tidy: "#4A8EFF").withAlphaComponent(0.35).cgColor
        tabBgView_Tidy.layer.shadowOffset = CGSize(width: 0, height: -6)
        tabBgView_Tidy.layer.shadowRadius = 16
        tabBgView_Tidy.layer.shadowOpacity = 1
        tabBgView_Tidy.layer.masksToBounds = false
        view.addSubview(tabBgView_Tidy)

        /// 顶部圆角 CAShapeLayer（填充指定蓝色）
        archShapeLayer_Tidy.fillColor   = UIColor(hexstring_Tidy: "#4A8EFF").cgColor
        archShapeLayer_Tidy.strokeColor = UIColor.clear.cgColor
        tabBgView_Tidy.layer.addSublayer(archShapeLayer_Tidy)

        /// 普通 Tab 按钮
        buildNormalBtn_Tidy(btnHome_Tidy,     image: "home",     tag: 0)
        buildNormalBtn_Tidy(btnDiscover_Tidy, image: "discover", tag: 1)
        buildNormalBtn_Tidy(btnMessage_Tidy,  image: "message",  tag: 3)
        buildNormalBtn_Tidy(btnMe_Tidy,       image: "me",       tag: 4)

        /// 发布按钮（模板渲染，跟随选中态切换颜色）
        let publishImg_Tidy = UIImage(named: "publish")?.withRenderingMode(.alwaysTemplate)
        btnRelease_Tidy.setImage(publishImg_Tidy, for: .normal)
        btnRelease_Tidy.setImage(publishImg_Tidy, for: .selected)
        btnRelease_Tidy.tintColor = UIColor.white.withAlphaComponent(0.5)
        btnRelease_Tidy.tag = 2
        /// UIButton 默认图片居中不缩放，需要设置填充对齐让图片充满按钮区域
        btnRelease_Tidy.contentHorizontalAlignment = .fill
        btnRelease_Tidy.contentVerticalAlignment   = .fill
        btnRelease_Tidy.imageView?.contentMode     = .scaleAspectFit
        btnRelease_Tidy.addTarget(self, action: #selector(tabButtonTapped_Tidy(_:)), for: .touchUpInside)
        tabBgView_Tidy.addSubview(btnRelease_Tidy)

        tabBgView_Tidy.addSubview(btnHome_Tidy)
        tabBgView_Tidy.addSubview(btnDiscover_Tidy)
        tabBgView_Tidy.addSubview(btnMessage_Tidy)
        tabBgView_Tidy.addSubview(btnMe_Tidy)
    }

    /// 配置普通 Tab 按钮（使用模板图，跟随 tint 切换颜色）
    /// - Parameters:
    ///   - btn: 目标按钮
    ///   - image: Assets 图片名称
    ///   - tag: Tab 索引
    private func buildNormalBtn_Tidy(_ btn: UIButton, image: String, tag: Int) {
        let img = UIImage(named: image)?.withRenderingMode(.alwaysTemplate)
        btn.setImage(img, for: .normal)
        btn.setImage(img, for: .selected)
        /// 未选中态使用白色半透明，在蓝色背景下更柔和可见
        btn.tintColor = UIColor.white.withAlphaComponent(0.5)
        btn.tag  = tag
        btn.addTarget(self, action: #selector(tabButtonTapped_Tidy(_:)), for: .touchUpInside)
    }

    // MARK: - 约束布局

    /// 设置 SnapKit 约束
    /// 背景视图从安全区底部向上延伸 barH，覆盖安全区到底边
    private func setupConstraints_Tidy() {
        let bgTotalH_Tidy = kBarH_Tidy

        /// 背景视图从安全区底部往上 bgTotalH，再延伸到屏幕底边
        tabBgView_Tidy.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-bgTotalH_Tidy)
        }

        /// 所有按钮统一位于内容区垂直中心
        let normalCenterYOffset_Tidy = kBarH_Tidy / 2
        let publishCenterYOffset_Tidy = normalCenterYOffset_Tidy

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
    }

    // MARK: - 顶部圆角路径绘制

    /// 根据背景视图当前 bounds 重新计算并绘制顶部左右圆角路径
    /// 路径说明：顶部两个角为圆角，底部保持直角并延伸到底边形成完整底栏
    private func updateArchPath_Tidy() {
        let b = tabBgView_Tidy.bounds
        guard b.width > 0 else { return }
        let path = UIBezierPath(
            roundedRect: b,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: kCornerRadius_Tidy, height: kCornerRadius_Tidy)
        )

        archShapeLayer_Tidy.path  = path.cgPath
        archShapeLayer_Tidy.frame = b
    }

    // MARK: - 事件处理

    /// Tab 按钮点击
    @objc private func tabButtonTapped_Tidy(_ sender: UIButton) {
        switchTab_Tidy(to: sender.tag)
    }

    // MARK: - Tab 切换

    /// 切换到指定 Tab 索引，更新选中状态和图标颜色
    /// - Parameter index_tidy: 目标索引（0 首页，1 发现，2 发布，3 消息，4 我的）
    func switchTab_Tidy(to index_tidy: Int) {
        currentIndex_Tidy = index_tidy
        selectedIndex = index_tidy

        btnHome_Tidy.isSelected     = (index_tidy == 0)
        btnDiscover_Tidy.isSelected  = (index_tidy == 1)
        btnRelease_Tidy.isSelected   = (index_tidy == 2)
        btnMessage_Tidy.isSelected   = (index_tidy == 3)
        btnMe_Tidy.isSelected        = (index_tidy == 4)

        /// 未选中态统一使用白色半透明，在蓝色底板上更易辨认
        let normalColor_Tidy = UIColor.white.withAlphaComponent(0.5)
        let selectedColor_Tidy = UIColor.white
        btnHome_Tidy.tintColor = index_tidy == 0 ? selectedColor_Tidy : normalColor_Tidy
        btnDiscover_Tidy.tintColor = index_tidy == 1 ? selectedColor_Tidy : normalColor_Tidy
        btnRelease_Tidy.tintColor = index_tidy == 2 ? selectedColor_Tidy : normalColor_Tidy
        btnMessage_Tidy.tintColor = index_tidy == 3 ? selectedColor_Tidy : normalColor_Tidy
        btnMe_Tidy.tintColor = index_tidy == 4 ? selectedColor_Tidy : normalColor_Tidy

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
