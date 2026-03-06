import Foundation
import UIKit
import SnapKit

// MARK: - 底部导航控制器

/// 底部导航控制器
/// 核心作用：渐变胶囊式自定义 Tab Bar，五个等宽槽视图均匀分配按钮位置
/// 设计思路：tabBgView（#FF7D78→#FFA546 对角渐变 + 阴影）+ 5 个等宽槽（按钮居中）
///           + indicatorView（选中时在图标正上方 5pt 显示 32×6 白色圆角滑条）
/// 关键方法：tabButtonTapped_Trace（切换页面 + 动画滑动指示条，发布 tab 隐藏指示条）
///           moveIndicator_Trace（将指示条弹性平移至目标按钮正上方）
class TabBar_Trace: UITabBarController {

    // MARK: - 渐变背景视图

    /// 渐变胶囊背景视图容器
    private let tabBgView_Trace = UIView()

    /// 背景渐变层（左上 #FF7D78 → 右下 #FFA546 对角方向）
    private let bgGradientLayer_Trace = CAGradientLayer()

    // MARK: - 选中指示滑条（宽 32 × 高 6，白色，圆角 3）

    private let indicatorView_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 3
        return v
    }()

    // MARK: - Tab 按钮

    private let btnHome_Trace     = UIButton(type: .custom)
    private let btnDiscover_Trace = UIButton(type: .custom)
    private let btnRelease_Trace  = UIButton(type: .custom)
    private let btnMessage_Trace  = UIButton(type: .custom)
    private let btnMe_Trace       = UIButton(type: .custom)

    /// 有序 Tab 按钮数组（下标与 selectedIndex 对应）
    private var allTabButtons_Trace: [UIButton] = []

    /// 当前选中 Tab 索引
    private var currentIndex_Trace: Int = 0

    /// 指示条首次定位标志（避免重复初始化）
    private var hasInitializedIndicator_Trace = false

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [Home_Trace(), Discover_Trace(), Release_Trace(), MessageList_Trace(), Me_Trace()]
        setupUI_Trace()
        setupConstraints_Trace()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 统一使用 setNavigationBarHidden 维护 UINavigationController 内部状态
        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBar.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 渐变层同步 bounds 和圆角
        bgGradientLayer_Trace.frame        = tabBgView_Trace.bounds
        bgGradientLayer_Trace.cornerRadius = tabBgView_Trace.layer.cornerRadius
        // 延迟一帧确保槽视图和按钮完成布局后再定位指示条
        if !hasInitializedIndicator_Trace {
            hasInitializedIndicator_Trace = true
            DispatchQueue.main.async {
                self.moveIndicator_Trace(to: self.btnHome_Trace, animated: false)
            }
        }
    }

    // MARK: - UI 搭建

    private func setupUI_Trace() {
        // ---- 渐变背景 ----
        bgGradientLayer_Trace.colors     = [
            UIColor(hexstring_Trace: "#FF7D78").cgColor,
            UIColor(hexstring_Trace: "#FFA546").cgColor
        ]
        bgGradientLayer_Trace.startPoint = CGPoint(x: 0, y: 0)
        bgGradientLayer_Trace.endPoint   = CGPoint(x: 1, y: 1)
        tabBgView_Trace.layer.insertSublayer(bgGradientLayer_Trace, at: 0)
        // masksToBounds 关闭使阴影可渲染到圆角外侧，渐变层本身设置了 cornerRadius
        tabBgView_Trace.layer.masksToBounds = false

        tabBgView_Trace.layer.shadowColor   = UIColor(hexstring_Trace: "#FF7D78").cgColor
        tabBgView_Trace.layer.shadowOffset  = CGSize(width: 0, height: 8)
        tabBgView_Trace.layer.shadowRadius  = 18
        tabBgView_Trace.layer.shadowOpacity = 0.40

        view.addSubview(tabBgView_Trace)
        tabBgView_Trace.addSubview(indicatorView_Trace)

        // ---- 五个 Tab 按钮配置信息 ----
        // 图标使用 alwaysOriginal 保留资源原始颜色，不受 tintColor 干预
        let buttonInfos: [(UIButton, String, Int, CGFloat)] = [
            (btnHome_Trace,     "home",     0, 36),
            (btnDiscover_Trace, "discover", 1, 36),
            (btnRelease_Trace,  "publish",  2, 42),
            (btnMessage_Trace,  "message",  3, 36),
            (btnMe_Trace,       "me",       4, 36),
        ]
        allTabButtons_Trace = buttonInfos.map { $0.0 }

        // ---- 等宽槽视图布局（彻底解决 equalSpacing 忽略 spacing 属性的问题）----
        // 每个槽占 tabBgView 等量宽度，按钮居中于槽内，位置精确无偏差
        var slots: [UIView] = []
        for (index, (btn, imageName, tag, size)) in buttonInfos.enumerated() {
            let slot_trace = UIView()
            slots.append(slot_trace)
            tabBgView_Trace.addSubview(slot_trace)
            slot_trace.addSubview(btn)

            // alwaysOriginal：使用图标本身的颜色，选中/未选中使用同一张原色图
            let img_trace = UIImage(named: imageName)
            btn.setImage(img_trace, for: .normal)
            btn.setImage(img_trace, for: .selected)
            btn.tag = tag
            btn.addTarget(self, action: #selector(tabButtonTapped_Trace(_:)), for: .touchUpInside)

            // 按钮居中于槽，尺寸固定
            btn.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.height.equalTo(size)
            }

            // 槽约束：铺满高度，首槽对齐左边，后续槽紧跟前一槽，宽度与首槽相等
            slot_trace.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                if index == 0 {
                    make.leading.equalToSuperview()
                } else {
                    make.leading.equalTo(slots[index - 1].snp.trailing)
                    make.width.equalTo(slots[0])
                }
                if index == buttonInfos.count - 1 {
                    make.trailing.equalToSuperview()
                }
            }
        }
    }

    // MARK: - 约束布局

    private func setupConstraints_Trace() {
        // 渐变胶囊 Tab Bar：左右各内缩 30pt，底部距屏幕边缘 50pt，总高 80pt（按钮区 50 + 上下各 15）
        tabBgView_Trace.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-30)
            make.height.equalTo(80)
        }
        // 圆角 = 高度一半（80 / 2 = 40）
        tabBgView_Trace.layer.cornerRadius = 40
    }

    // MARK: - 事件处理

    /// Tab 按钮点击：切换页面 + 动画滑动指示条（发布 tab 隐藏指示条）
    /// - Parameter sender: 被点击的 Tab 按钮
    @objc private func tabButtonTapped_Trace(_ sender: UIButton) {
        let index = sender.tag
        currentIndex_Trace = index
        selectedIndex      = index
        // 发布按钮（tag = 2）不显示指示条；其他 tab 恢复显示并滑动定位
        if index == 2 {
            UIView.animate(withDuration: 0.2) {
                self.indicatorView_Trace.alpha = 0
            }
        } else {
            UIView.animate(withDuration: 0.15) {
                self.indicatorView_Trace.alpha = 1
            }
            moveIndicator_Trace(to: sender, animated: true)
        }
    }

    // MARK: - 公开方法

    /// 切换到指定 Tab 索引，并触发完整的指示条动画与图标刷新
    /// - Parameter index: 目标 Tab 索引（0=首页, 1=发现, 2=发布, 3=消息, 4=我的）
    func switchToTab_Trace(index: Int) {
        guard index < allTabButtons_Trace.count else { return }
        let button = allTabButtons_Trace[index]
        tabButtonTapped_Trace(button)
    }

    // MARK: - 辅助方法

    /// 将选中指示条（32×6）平滑移动至目标按钮正上方 5pt 处
    /// - Parameters:
    ///   - button: 目标 Tab 按钮（其父视图为等宽槽，槽是 tabBgView 直接子视图）
    ///   - animated: 是否执行弹性滑动动画
    private func moveIndicator_Trace(to button: UIButton, animated: Bool) {
        // button.superview 为槽视图（tabBgView 直接子视图），坐标转换准确
        let buttonFrame_trace = tabBgView_Trace.convert(button.frame, from: button.superview)
        let indicatorW: CGFloat = 32
        let indicatorH: CGFloat = 6
        let newX_trace = buttonFrame_trace.midX - indicatorW / 2
        let newY_trace = buttonFrame_trace.minY - 5 - indicatorH  // 按钮顶边上方 5pt

        let newFrame_trace = CGRect(x: newX_trace, y: newY_trace, width: indicatorW, height: indicatorH)

        if animated {
            UIView.animate(
                withDuration: 0.35,
                delay: 0,
                usingSpringWithDamping: 0.72,
                initialSpringVelocity: 0.5,
                options: .curveEaseOut
            ) {
                self.indicatorView_Trace.frame = newFrame_trace
            }
        } else {
            indicatorView_Trace.frame = newFrame_trace
        }
    }
}
