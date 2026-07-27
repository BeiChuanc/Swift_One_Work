import Foundation
import UIKit
import SnapKit

// MARK: 导航器

/// 屏幕高宽
enum APPSCREEN_Maki {
    
    static let WIDTH_Maki = UIScreen.main.bounds.width
    
    static let HEIGHT_Maki = UIScreen.main.bounds.height
}

/// 触摸穿透式栈视图
/// 功能：仅当触摸命中其排列的子视图（如按钮）时才拦截事件，未命中任何子视图的触摸（如按钮间隙）将直接穿透给下层视图
/// 设计：重写 hitTest，避免容器自身在未命中子视图时仍默认吞掉触摸事件，导致下层页面无法接收到滑动手势
private class PassthroughStackView_Maki: UIStackView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard isUserInteractionEnabled, !isHidden, alpha > 0.01 else { return nil }
        for subview_maki in subviews {
            let convertedPoint_maki = subview_maki.convert(point, from: self)
            if let hit_maki = subview_maki.hitTest(convertedPoint_maki, with: event) {
                return hit_maki
            }
        }
        return nil
    }
}

/// 底部导航图标按钮
/// 功能：选中态在图标背后居中展示一个渐变圆角矩形背景，未选中态隐藏该背景
/// 设计：渐变背景使用独立的 UIView 承载（而非直接插入按钮自身的 layer），
///       以子视图形式插入到最底层，避免被 UIButton 内部对图标/文字图层的重新排布打乱层级，
///       导致渐变意外盖住图标；图标未选中时展示原图颜色，选中时通过外部设置的模板态图片 + tintColor 染为白色
private class TabIconButton_Maki: UIButton {

    /// 选中态渐变背景容器视图
    private let selectedGradBgView_Maki: UIView = {
        let v_maki = UIView()
        v_maki.isUserInteractionEnabled = false
        v_maki.alpha = 0
        return v_maki
    }()

    /// 渐变背景容器承载的渐变层（顶部居中 → 底部居中，FA5A00 → FF9800）
    private let selectedGradLayer_Maki = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient_Maki()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 配置渐变背景视图初始样式并插入到最底层（默认隐藏）
    private func setupGradient_Maki() {
        selectedGradLayer_Maki.colors = [
            UIColor(hexstring_Maki: "#FA5A00").cgColor,
            UIColor(hexstring_Maki: "#FF9800").cgColor
        ]
        selectedGradLayer_Maki.startPoint = CGPoint(x: 0.5, y: 0)
        selectedGradLayer_Maki.endPoint   = CGPoint(x: 0.5, y: 1)
        selectedGradBgView_Maki.layer.addSublayer(selectedGradLayer_Maki)
        insertSubview(selectedGradBgView_Maki, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        selectedGradBgView_Maki.frame = bounds
        selectedGradLayer_Maki.frame = bounds
        selectedGradBgView_Maki.layer.cornerRadius = bounds.height / 2
        selectedGradLayer_Maki.cornerRadius = bounds.height / 2
        // 兜底：防止 UIButton 内部布局时重新调整子视图顺序，导致渐变背景被移到图标上方
        if subviews.first !== selectedGradBgView_Maki {
            insertSubview(selectedGradBgView_Maki, at: 0)
        }
    }

    /// 重写选中态：切换渐变背景的显示与隐藏
    override var isSelected: Bool {
        didSet {
            selectedGradBgView_Maki.alpha = isSelected ? 1 : 0
        }
    }
}

/// 底部导航栏布局常量
/// 功能：根据屏幕宽度动态计算文字图标按钮的显示尺寸，避免固定尺寸在小屏设备上溢出导致图标裁切/重叠
private enum K_TabLayout_Maki {
    /// 左右外边距
    static let margin: CGFloat = 16
    /// 按钮间距
    static let spacing: CGFloat = 12
    /// 发布按钮固定尺寸
    static let releaseSize: CGFloat = 40
    /// 文字图标按钮原始尺寸（与素材图原始点尺寸一致）
    static let nativeIconSize = CGSize(width: 71, height: 36)

    /// 自适应缩放比例：确保 4 个文字图标按钮 + 发布按钮 + 间距 + 边距 之和不超过屏幕宽度，超出时按比例缩小，屏幕足够宽时保持原始尺寸
    static var iconScale: CGFloat {
        let availableW_maki = APPSCREEN_Maki.WIDTH_Maki - margin * 2 - spacing * 4 - releaseSize
        let scale_maki = availableW_maki / (nativeIconSize.width * 4)
        return min(1.0, max(0.5, scale_maki))
    }

    /// 缩放后的文字图标按钮尺寸
    static var iconSize: CGSize {
        CGSize(width: nativeIconSize.width * iconScale, height: nativeIconSize.height * iconScale)
    }
}

/// 底部导航页面
class TabBar_Maki: UITabBarController {
    
    /// 白色背景视图
    private var tabBgView_Maki = UIView()
    
    /// 按钮容器栈视图（触摸穿透，避免按钮间隙拦截下层页面的滑动手势）
    private var tabStackView_Maki = PassthroughStackView_Maki()
    
    /// 首页按钮（选中态显示渐变背景）
    private var btnHome_Maki = TabIconButton_Maki(type: .custom)
    
    /// 发现页按钮（选中态显示渐变背景）
    private var btnDiscover_Maki = TabIconButton_Maki(type: .custom)
    
    /// 发布按钮（不参与选中态渐变背景）
    private var btnRelease_Maki = UIButton(type: .custom)
    
    /// 消息按钮（选中态显示渐变背景）
    private var btnMessage_Maki = TabIconButton_Maki(type: .custom)
    
    /// 我的按钮（选中态显示渐变背景）
    private var btnMe_Maki = TabIconButton_Maki(type: .custom)
    
    /// 当前选中索引
    private var currentIndex_Maki: Int = 0
    
    // MARK: - 生命周期方法
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置视图控制器
        viewControllers = [Home_Maki(), Discover_Maki(), Release_Maki(), MessageList_Maki(), Me_Maki()]
        
        setupUI_Maki()
        setupConstraints_Maki()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        tabBar.isHidden = true
    }
    
    // MARK: - UI设置
    private func setupUI_Maki() {
        // 配置白色背景视图（禁用交互，避免拦截子页面底部区域的滑动手势）
        tabBgView_Maki.backgroundColor = UIColor(hexstring_Maki: "#FFFFFF")
        tabBgView_Maki.layer.masksToBounds = true
        tabBgView_Maki.isUserInteractionEnabled = false
        view.addSubview(tabBgView_Maki)
        
        // 配置StackView
        tabStackView_Maki.axis = .horizontal
        tabStackView_Maki.distribution = .equalSpacing
        tabStackView_Maki.alignment = .center
        tabStackView_Maki.spacing = K_TabLayout_Maki.spacing
        view.addSubview(tabStackView_Maki)
        
        // 配置首页按钮（未选中原图展示；选中态染为白色，渐变背景居中显示在其身后）
        btnHome_Maki.setImage(UIImage(named: "home"), for: .normal)
        btnHome_Maki.setImage(UIImage(named: "home")?.withRenderingMode(.alwaysTemplate), for: .selected)
        btnHome_Maki.tintColor = .white
        btnHome_Maki.imageView?.contentMode = .scaleAspectFit
        btnHome_Maki.tag = 0
        btnHome_Maki.addTarget(self, action: #selector(tabButtonTapped_Maki(_:)), for: .touchUpInside)
        tabStackView_Maki.addArrangedSubview(btnHome_Maki)
        
        // 配置发现页按钮（未选中原图展示；选中态染为白色，渐变背景居中显示在其身后）
        btnDiscover_Maki.setImage(UIImage(named: "discover"), for: .normal)
        btnDiscover_Maki.setImage(UIImage(named: "discover")?.withRenderingMode(.alwaysTemplate), for: .selected)
        btnDiscover_Maki.tintColor = .white
        btnDiscover_Maki.imageView?.contentMode = .scaleAspectFit
        btnDiscover_Maki.tag = 1
        btnDiscover_Maki.addTarget(self, action: #selector(tabButtonTapped_Maki(_:)), for: .touchUpInside)
        tabStackView_Maki.addArrangedSubview(btnDiscover_Maki)
        
        // 配置发布按钮（原图展示，不参与选中态渐变背景/染色）
        btnRelease_Maki.setImage(UIImage(named: "publish"), for: .normal)
        btnRelease_Maki.imageView?.contentMode = .scaleAspectFit
        btnRelease_Maki.tag = 2
        btnRelease_Maki.addTarget(self, action: #selector(tabButtonTapped_Maki(_:)), for: .touchUpInside)
        tabStackView_Maki.addArrangedSubview(btnRelease_Maki)
        
        // 配置消息按钮（未选中原图展示；选中态染为白色，渐变背景居中显示在其身后）
        btnMessage_Maki.setImage(UIImage(named: "message"), for: .normal)
        btnMessage_Maki.setImage(UIImage(named: "message")?.withRenderingMode(.alwaysTemplate), for: .selected)
        btnMessage_Maki.tintColor = .white
        btnMessage_Maki.imageView?.contentMode = .scaleAspectFit
        btnMessage_Maki.tag = 3
        btnMessage_Maki.addTarget(self, action: #selector(tabButtonTapped_Maki(_:)), for: .touchUpInside)
        tabStackView_Maki.addArrangedSubview(btnMessage_Maki)
        
        // 配置我的按钮（未选中原图展示；选中态染为白色，渐变背景居中显示在其身后）
        btnMe_Maki.setImage(UIImage(named: "me"), for: .normal)
        btnMe_Maki.setImage(UIImage(named: "me")?.withRenderingMode(.alwaysTemplate), for: .selected)
        btnMe_Maki.tintColor = .white
        btnMe_Maki.imageView?.contentMode = .scaleAspectFit
        btnMe_Maki.tag = 4
        btnMe_Maki.addTarget(self, action: #selector(tabButtonTapped_Maki(_:)), for: .touchUpInside)
        tabStackView_Maki.addArrangedSubview(btnMe_Maki)
        
        // 设置初始选中状态
        btnHome_Maki.isSelected = true
    }
    
    /// 设置约束布局
    private func setupConstraints_Maki() {
        // StackView约束
        tabStackView_Maki.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(K_TabLayout_Maki.margin)
            make.trailing.equalToSuperview().offset(-K_TabLayout_Maki.margin)
            make.bottom.equalToSuperview().offset(-50)
            make.height.equalTo(50)
        }
        
        // 按钮尺寸约束（发布按钮固定 40x40；其余按可用屏幕宽度自适应缩放，避免溢出裁切）
        let iconSize_maki = K_TabLayout_Maki.iconSize
        btnHome_Maki.snp.makeConstraints { make in
            make.width.equalTo(iconSize_maki.width)
            make.height.equalTo(iconSize_maki.height)
        }
        
        btnDiscover_Maki.snp.makeConstraints { make in
            make.width.equalTo(iconSize_maki.width)
            make.height.equalTo(iconSize_maki.height)
        }
        
        btnRelease_Maki.snp.makeConstraints { make in
            make.width.height.equalTo(K_TabLayout_Maki.releaseSize)
        }
        
        btnMessage_Maki.snp.makeConstraints { make in
            make.width.equalTo(iconSize_maki.width)
            make.height.equalTo(iconSize_maki.height)
        }
        
        btnMe_Maki.snp.makeConstraints { make in
            make.width.equalTo(iconSize_maki.width)
            make.height.equalTo(iconSize_maki.height)
        }
        
        // 白色背景视图约束（上下各距离StackView 15）
        tabBgView_Maki.snp.makeConstraints { make in
            make.leading.trailing.equalTo(tabStackView_Maki)
            make.top.equalTo(tabStackView_Maki).offset(-15)
            make.bottom.equalTo(tabStackView_Maki).offset(15)
        }
        
        // 设置圆角为高度的一半
        tabBgView_Maki.layoutIfNeeded()
        let bgHeight = 50 + 30 // StackView高度50 + 上下各15
        tabBgView_Maki.layer.cornerRadius = CGFloat(bgHeight) / 2.0
    }
    
    @objc private func tabButtonTapped_Maki(_ sender: UIButton) {
        let index = sender.tag
        
        // 更新选中状态
        currentIndex_Maki = index
        selectedIndex = index
        
        // 更新所有按钮的选中状态
        btnHome_Maki.isSelected = (index == 0)
        btnDiscover_Maki.isSelected = (index == 1)
        btnRelease_Maki.isSelected = (index == 2)
        btnMessage_Maki.isSelected = (index == 3)
        btnMe_Maki.isSelected = (index == 4)
    }
}
