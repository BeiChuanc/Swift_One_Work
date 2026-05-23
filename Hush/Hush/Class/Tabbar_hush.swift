import Foundation
import UIKit
import SnapKit

// MARK: 底部导航栏

/// 底部导航控制器
/// 功能：管理 App 的五个主要 Tab（Home / Discover / Publish / Message / Me）
/// 设计：浮动圆角底栏，渐变背景（白→橙红），Assets 原图图标，非发布 Tab 选中时显示白色下划线指示器
/// 关键属性：_currentIndex_Hush（当前选中 Tab 索引）
class TabBar_Hush: UITabBarController {

    // MARK: - UI 组件

    /// 浮动底栏容器
    private let _floatingBar_Hush = UIView()

    /// 底栏渐变背景层（FFFFFF → F0411B → FF5817，顶部居中→底部居中）
    private var _bgGradient_Hush: CAGradientLayer?

    /// 五个 Tab 按钮
    private let _btnHome_Hush    = UIButton(type: .custom)
    private let _btnDiscover_Hush = UIButton(type: .custom)
    private let _btnRelease_Hush  = UIButton(type: .custom)
    private let _btnMessage_Hush  = UIButton(type: .custom)
    private let _btnMe_Hush       = UIButton(type: .custom)

    /// 滑动式选中指示器（单条白色下划线，切换时平滑滑动到目标 Tab）
    private let _slidingIndicator_Hush: UIView = {
        let v_hush = UIView()
        v_hush.backgroundColor = .white
        v_hush.layer.cornerRadius = 1.5
        return v_hush
    }()
    /// 指示器 centerX 约束引用，用于动画更新
    private var _indicatorCX_Hush: Constraint?

    /// 当前选中 Tab 索引（0=Home 1=Discover 2=Publish 3=Message 4=Me）
    private var _currentIndex_Hush: Int = 0

    // MARK: - 常量

    private let _barHeight_Hush: CGFloat = 68
    private let _barHInset_Hush: CGFloat = 24
    private let _barRadius_Hush: CGFloat = 34

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        _setupViewControllers_Hush()
        _setupFloatingBar_Hush()
        _updateStates_Hush(selectedIndex: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        tabBar.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 渐变 frame 跟随布局更新
        _bgGradient_Hush?.frame = _floatingBar_Hush.bounds
    }

    // MARK: - ViewControllers 初始化

    /// 设置五个 Tab 对应的视图控制器
    private func _setupViewControllers_Hush() {
        viewControllers = [
            Home_Hush(),
            Discover_Hush(),
            Release_Hush(),
            MessageList_Hush(),
            Me_Hush()
        ]
    }

    // MARK: - 浮动底栏构建

    /// 构建浮动圆角底栏：渐变背景 + 阴影 + 按钮 + 指示器
    private func _setupFloatingBar_Hush() {
        tabBar.isHidden = true

        // 外层阴影（不能开 clipsToBounds）
        _floatingBar_Hush.layer.cornerRadius = _barRadius_Hush
        _floatingBar_Hush.layer.masksToBounds = false
        _floatingBar_Hush.layer.shadowColor   = UIColor.black.cgColor
        _floatingBar_Hush.layer.shadowOffset  = CGSize(width: 0, height: 8)
        _floatingBar_Hush.layer.shadowOpacity = 0.15
        _floatingBar_Hush.layer.shadowRadius  = 16
        view.addSubview(_floatingBar_Hush)

        // 渐变背景（需要内层裁剪圆角，单独加一个 clipsToBounds 容器）
        let gradContainer_hush = UIView()
        gradContainer_hush.layer.cornerRadius = _barRadius_Hush
        gradContainer_hush.clipsToBounds = true
        _floatingBar_Hush.addSubview(gradContainer_hush)
        gradContainer_hush.snp.makeConstraints { $0.edges.equalToSuperview() }

        let grad_hush = CAGradientLayer()
        grad_hush.colors = [
            UIColor(hexstring_Hush: "#FFFFFF").cgColor,
            UIColor(hexstring_Hush: "#F0411B").cgColor,
            UIColor(hexstring_Hush: "#FF5817").cgColor,
        ]
        grad_hush.locations = [0.0, 0.41, 1.0]
        grad_hush.startPoint = CGPoint(x: 0.5, y: 0)
        grad_hush.endPoint   = CGPoint(x: 0.5, y: 1)
        gradContainer_hush.layer.insertSublayer(grad_hush, at: 0)
        _bgGradient_Hush = grad_hush

        _floatingBar_Hush.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(_barHInset_Hush)
            make.trailing.equalToSuperview().offset(-_barHInset_Hush)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-12)
            make.height.equalTo(_barHeight_Hush)
        }

        _setupTabButtons_Hush()
        _setupSlidingIndicator_Hush()
    }

    /// 配置五个 Tab 按钮（Assets 原图，指定图标尺寸）
    private func _setupTabButtons_Hush() {
        let barWidth_hush   = UIScreen.main.bounds.width - _barHInset_Hush * 2
        let sectionW_hush   = barWidth_hush / 5

        // (按钮, Assets 图片名, tag, 图标尺寸)
        let items_hush: [(UIButton, String, Int, CGSize)] = [
            (_btnHome_Hush,    "home",    0, CGSize(width: 24, height: 24)),
            (_btnDiscover_Hush,"discover",1, CGSize(width: 24, height: 24)),
            (_btnRelease_Hush, "publish", 2, CGSize(width: 54, height: 32)),
            (_btnMessage_Hush, "message", 3, CGSize(width: 24, height: 24)),
            (_btnMe_Hush,      "me",      4, CGSize(width: 24, height: 24)),
        ]

        for (idx_hush, (btn_hush, name_hush, tag_hush, iconSize_hush)) in items_hush.enumerated() {
            // 加载原图并缩放至指定尺寸
            if let raw_hush = UIImage(named: name_hush) {
                let resized_hush = _resizeImage_Hush(raw_hush, to: iconSize_hush)
                // alwaysOriginal：保持图片原色，不受 tintColor 影响
                btn_hush.setImage(resized_hush.withRenderingMode(.alwaysOriginal), for: .normal)
                btn_hush.setImage(resized_hush.withRenderingMode(.alwaysOriginal), for: .selected)
            }
            btn_hush.imageView?.contentMode = .scaleAspectFit
            btn_hush.tag = tag_hush
            btn_hush.addTarget(self, action: #selector(_onTabTap_Hush(_:)), for: .touchUpInside)
            _floatingBar_Hush.addSubview(btn_hush)

            let cx_hush = sectionW_hush * (CGFloat(idx_hush) + 0.5) - barWidth_hush / 2
            btn_hush.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.width.equalTo(sectionW_hush)
                make.height.equalToSuperview()
                make.centerX.equalToSuperview().offset(cx_hush)
            }
        }
    }

    /// 创建单条滑动式白色下划线指示器，初始位置在 index 0（Home）
    private func _setupSlidingIndicator_Hush() {
        let barWidth_hush = UIScreen.main.bounds.width - _barHInset_Hush * 2
        let sectionW_hush = barWidth_hush / 5
        // 初始位置：Home（index 0）
        let initCX_hush = sectionW_hush * 0.5 - barWidth_hush / 2

        _floatingBar_Hush.addSubview(_slidingIndicator_Hush)
        _slidingIndicator_Hush.snp.makeConstraints { make in
            make.width.equalTo(20)
            make.height.equalTo(3)
            _indicatorCX_Hush = make.centerX.equalToSuperview().offset(initCX_hush).constraint
            make.bottom.equalToSuperview().offset(-8)
        }
    }

    // MARK: - 状态更新

    /// 更新所有 Tab 按钮的选中状态：指示器滑动 + 图标透明度 + 缩放动画
    /// - Parameter selectedIndex: 当前选中 Tab 索引（0~4）
    private func _updateStates_Hush(selectedIndex: Int) {
        let allBtns_hush = [_btnHome_Hush, _btnDiscover_Hush, _btnRelease_Hush, _btnMessage_Hush, _btnMe_Hush]
        let barWidth_hush = UIScreen.main.bounds.width - _barHInset_Hush * 2
        let sectionW_hush = barWidth_hush / 5

        for (idx_hush, btn_hush) in allBtns_hush.enumerated() {
            let isSelected_hush = idx_hush == selectedIndex
            // 图标透明度：选中完全不透明，未选中半透明
            btn_hush.alpha = isSelected_hush ? 1.0 : 0.55
            // 选中时弹性缩放动画
            if isSelected_hush {
                UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseOut) {
                    btn_hush.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                } completion: { _ in
                    UIView.animate(withDuration: 0.12) { btn_hush.transform = .identity }
                }
            }
        }

        // 指示器：发布 Tab（index 2）时淡出隐藏，其余 Tab 滑动到对应位置
        let isPublish_hush = selectedIndex == 2
        if isPublish_hush {
            UIView.animate(withDuration: AnimationConfig_Hush.durationFast_Hush) {
                self._slidingIndicator_Hush.alpha = 0
            }
        } else {
            // 计算目标 centerX offset
            let targetCX_hush = sectionW_hush * (CGFloat(selectedIndex) + 0.5) - barWidth_hush / 2
            _indicatorCX_Hush?.update(offset: targetCX_hush)
            // 弹性滑动动画
            UIView.animate(
                withDuration: 0.32,
                delay: 0,
                usingSpringWithDamping: 0.72,
                initialSpringVelocity: 0.6,
                options: [.curveEaseInOut]
            ) {
                self._slidingIndicator_Hush.alpha = 1
                self._floatingBar_Hush.layoutIfNeeded()
            }
        }
    }

    // MARK: - 事件处理

    /// Tab 按钮点击：切换对应视图控制器
    @objc private func _onTabTap_Hush(_ sender: UIButton) {
        let index_hush = sender.tag
        _currentIndex_Hush = index_hush
        selectedIndex      = index_hush
        _updateStates_Hush(selectedIndex: index_hush)
    }

    // MARK: - 外部接口

    /// 切换到指定 Tab（供子视图控制器调用，如首页头像点击）
    /// - Parameter index_hush: 目标 Tab 索引（0~4）
    func switchTab_Hush(to index_hush: Int) {
        guard index_hush < (viewControllers?.count ?? 0) else { return }
        _currentIndex_Hush = index_hush
        selectedIndex      = index_hush
        _updateStates_Hush(selectedIndex: index_hush)
    }

    // MARK: - 工具方法

    /// 将图片缩放到指定尺寸
    /// - Parameters:
    ///   - image_hush: 原始图片
    ///   - size_hush:  目标尺寸
    /// - Returns: 缩放后的 UIImage
    private func _resizeImage_Hush(_ image_hush: UIImage, to size_hush: CGSize) -> UIImage {
        let renderer_hush = UIGraphicsImageRenderer(size: size_hush)
        return renderer_hush.image { _ in
            image_hush.draw(in: CGRect(origin: .zero, size: size_hush))
        }
    }
}
