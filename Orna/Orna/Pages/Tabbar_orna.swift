import Foundation
import UIKit
import SnapKit

// MARK: 导航器

/// 屏幕高宽
enum APPSCREEN_Orna {
    
    static let WIDTH_Orna = UIScreen.main.bounds.width
    
    static let HEIGHT_Orna = UIScreen.main.bounds.height
}

/// 底部导航页面
/// 核心作用：以悬浮胶囊形式承载 首页/发现/发布/消息/我的 五个 Tab 入口
/// 设计思路：
///   - 图标统一使用 Assets 中 home / discover / publish / message / me 原图，不做模板渲染与染色，
///     保留素材本身的配色；除发布按钮为 40x40 外，其余图标均为 30x30
///   - 除发布按钮外，其余 Tab 选中时会在图标正后方显示一个 48x48、圆角 15 的白色背景，
///     用于突出当前选中项，未选中时该背景隐藏
///   - 悬浮胶囊背板统一使用主题紫 #6440FB，圆角固定为 20
class TabBar_Orna: UITabBarController {

    /// 悬浮底部导航栏在屏幕底部占用的遮挡高度（背板顶部距容器底部的距离，再加一些安全余量）。
    /// 由于导航栏以自定义悬浮胶囊形式叠加在各 Tab 页面内容之上（而非系统标准 UITabBar 挤压布局），
    /// 各 Tab 页面的可滚动内容需在底部预留不小于该值的安全间距，避免可交互内容被悬浮导航栏遮挡、
    /// 或导致内容滚动到底后仍有一部分停留在导航栏后方无法完全露出
    static let floatingBarClearance_Orna: CGFloat = 130

    /// 选中态图标背景的固定尺寸与圆角
    private static let selectionBgSize_Orna: CGFloat = 48
    private static let selectionBgCornerRadius_Orna: CGFloat = 15

    /// 悬浮胶囊背景视图（主题紫）
    private var tabBgView_Orna = UIView()
    
    /// 按钮容器栈视图
    private var tabStackView_Orna = UIStackView()
    
    /// 首页按钮
    private var btnHome_Orna = UIButton(type: .custom)
    
    /// 发现页按钮
    private var btnDiscover_Orna = UIButton(type: .custom)
    
    /// 发布按钮
    private var btnRelease_Orna = UIButton(type: .custom)
    
    /// 消息按钮
    private var btnMessage_Orna = UIButton(type: .custom)
    
    /// 我的按钮
    private var btnMe_Orna = UIButton(type: .custom)

    /// 首页按钮选中态背景（圆角白底）
    private var homeSelectionBgView_Orna = UIView()

    /// 发现页按钮选中态背景
    private var discoverSelectionBgView_Orna = UIView()

    /// 消息按钮选中态背景
    private var messageSelectionBgView_Orna = UIView()

    /// 我的按钮选中态背景
    private var meSelectionBgView_Orna = UIView()

    /// 当前选中索引
    private var currentIndex_Orna: Int = 0
    
    // MARK: - 生命周期方法
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置视图控制器
        viewControllers = [Home_Orna(), Discover_Orna(), Release_Orna(), MessageList_Orna(), Me_Orna()]
        
        setupUI_Orna()
        setupConstraints_Orna()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        tabBar.isHidden = true
    }
    
    // MARK: - UI设置
    private func setupUI_Orna() {
        // 配置悬浮胶囊背景视图
        tabBgView_Orna.backgroundColor = UIColor(hexstring_Orna: "#6440FB")
        tabBgView_Orna.layer.masksToBounds = true
        view.addSubview(tabBgView_Orna)

        // 选中态圆角白底需位于胶囊背景之上、图标按钮之下，因此在 StackView 之前加入视图层级，
        // 避免直接作为 UIButton 的子视图（现代 UIButton 内部内容视图层级会导致自定义子视图层级不受控）
        setupSelectionBg_Orna(homeSelectionBgView_Orna)
        setupSelectionBg_Orna(discoverSelectionBgView_Orna)
        setupSelectionBg_Orna(messageSelectionBgView_Orna)
        setupSelectionBg_Orna(meSelectionBgView_Orna)

        // 配置StackView
        // 通过 layoutMargins + isLayoutMarginsRelativeArrangement 让首尾按钮与容器左右边缘保持 16 的间距，
        // .equalSpacing 分布会在扣除该左右边距后的剩余宽度内，于 5 个按钮间的 4 段间隙中自动均分多余空间，
        // 从而联动完成"内部按钮间距"的调整，不必再手动计算固定间距数值
        tabStackView_Orna.axis = .horizontal
        tabStackView_Orna.distribution = .equalSpacing
        tabStackView_Orna.alignment = .center
        tabStackView_Orna.spacing = 20
        tabStackView_Orna.isLayoutMarginsRelativeArrangement = true
        tabStackView_Orna.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        view.addSubview(tabStackView_Orna)
        
        // 配置首页按钮：原图展示，选中态白底见 homeSelectionBgView_Orna
        btnHome_Orna.setImage(UIImage(named: "home"), for: .normal)
        btnHome_Orna.tag = 0
        btnHome_Orna.addTarget(self, action: #selector(tabButtonTapped_Orna(_:)), for: .touchUpInside)
        tabStackView_Orna.addArrangedSubview(btnHome_Orna)
        
        // 配置发现页按钮：原图展示，选中态白底见 discoverSelectionBgView_Orna
        btnDiscover_Orna.setImage(UIImage(named: "discover"), for: .normal)
        btnDiscover_Orna.tag = 1
        btnDiscover_Orna.addTarget(self, action: #selector(tabButtonTapped_Orna(_:)), for: .touchUpInside)
        tabStackView_Orna.addArrangedSubview(btnDiscover_Orna)
        
        // 配置发布按钮：原图展示，不参与选中态白底逻辑
        btnRelease_Orna.setImage(UIImage(named: "publish"), for: .normal)
        btnRelease_Orna.tag = 2
        btnRelease_Orna.addTarget(self, action: #selector(tabButtonTapped_Orna(_:)), for: .touchUpInside)
        tabStackView_Orna.addArrangedSubview(btnRelease_Orna)
        
        // 配置消息按钮：原图展示，选中态白底见 messageSelectionBgView_Orna
        btnMessage_Orna.setImage(UIImage(named: "message"), for: .normal)
        btnMessage_Orna.tag = 3
        btnMessage_Orna.addTarget(self, action: #selector(tabButtonTapped_Orna(_:)), for: .touchUpInside)
        tabStackView_Orna.addArrangedSubview(btnMessage_Orna)
        
        // 配置我的按钮：原图展示，选中态白底见 meSelectionBgView_Orna
        btnMe_Orna.setImage(UIImage(named: "me"), for: .normal)
        btnMe_Orna.tag = 4
        btnMe_Orna.addTarget(self, action: #selector(tabButtonTapped_Orna(_:)), for: .touchUpInside)
        tabStackView_Orna.addArrangedSubview(btnMe_Orna)
        
        // 设置初始选中状态
        btnHome_Orna.isSelected = true
        updateSelectionBackgrounds_Orna(selectedIndex_orna: 0)
    }

    /// 配置选中态圆角白底的通用样式（白色填充、圆角 15、初始隐藏、不拦截触摸）
    /// 参数：
    /// - bgView_orna: 待配置的选中态背景视图
    private func setupSelectionBg_Orna(_ bgView_orna: UIView) {
        bgView_orna.backgroundColor = .white
        bgView_orna.layer.cornerRadius = Self.selectionBgCornerRadius_Orna
        bgView_orna.isHidden = true
        bgView_orna.isUserInteractionEnabled = false
        view.addSubview(bgView_orna)
    }
    
    /// 设置约束布局
    private func setupConstraints_Orna() {
        // StackView约束
        tabStackView_Orna.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-50)
            make.height.equalTo(50)
        }
        
        // 按钮尺寸约束：除发布按钮 40x40 外，其余均为 30x30
        btnHome_Orna.snp.makeConstraints { make in
            make.width.height.equalTo(30)
        }
        
        btnDiscover_Orna.snp.makeConstraints { make in
            make.width.height.equalTo(30)
        }
        
        btnRelease_Orna.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        
        btnMessage_Orna.snp.makeConstraints { make in
            make.width.height.equalTo(30)
        }
        
        btnMe_Orna.snp.makeConstraints { make in
            make.width.height.equalTo(30)
        }

        // 选中态圆角白底约束：居中对齐各自图标按钮，固定 48x48
        homeSelectionBgView_Orna.snp.makeConstraints { make in
            make.center.equalTo(btnHome_Orna)
            make.width.height.equalTo(Self.selectionBgSize_Orna)
        }
        discoverSelectionBgView_Orna.snp.makeConstraints { make in
            make.center.equalTo(btnDiscover_Orna)
            make.width.height.equalTo(Self.selectionBgSize_Orna)
        }
        messageSelectionBgView_Orna.snp.makeConstraints { make in
            make.center.equalTo(btnMessage_Orna)
            make.width.height.equalTo(Self.selectionBgSize_Orna)
        }
        meSelectionBgView_Orna.snp.makeConstraints { make in
            make.center.equalTo(btnMe_Orna)
            make.width.height.equalTo(Self.selectionBgSize_Orna)
        }
        
        // 悬浮胶囊背景视图约束（上下各距离StackView 15）
        tabBgView_Orna.snp.makeConstraints { make in
            make.leading.trailing.equalTo(tabStackView_Orna)
            make.top.equalTo(tabStackView_Orna).offset(-15)
            make.bottom.equalTo(tabStackView_Orna).offset(15)
        }
        
        // 圆角固定为 20
        tabBgView_Orna.layer.cornerRadius = 30
    }
    
    @objc private func tabButtonTapped_Orna(_ sender: UIButton) {
        let index = sender.tag
        
        // 更新选中状态
        currentIndex_Orna = index
        selectedIndex = index
        
        // 更新所有按钮的选中状态
        btnHome_Orna.isSelected = (index == 0)
        btnDiscover_Orna.isSelected = (index == 1)
        btnRelease_Orna.isSelected = (index == 2)
        btnMessage_Orna.isSelected = (index == 3)
        btnMe_Orna.isSelected = (index == 4)

        updateSelectionBackgrounds_Orna(selectedIndex_orna: index)
    }

    /// 根据当前选中下标同步显示/隐藏各 Tab 的选中态圆角白底（发布按钮不参与）
    /// 参数：
    /// - selectedIndex_orna: 当前选中的 Tab 下标
    private func updateSelectionBackgrounds_Orna(selectedIndex_orna: Int) {
        homeSelectionBgView_Orna.isHidden = selectedIndex_orna != 0
        discoverSelectionBgView_Orna.isHidden = selectedIndex_orna != 1
        messageSelectionBgView_Orna.isHidden = selectedIndex_orna != 3
        meSelectionBgView_Orna.isHidden = selectedIndex_orna != 4
    }
}
