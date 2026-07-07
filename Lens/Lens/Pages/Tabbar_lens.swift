import Foundation
import UIKit
import SnapKit

// MARK: 导航器

/// 屏幕高宽
enum APPSCREEN_Lens {

    static let WIDTH_Lens = UIScreen.main.bounds.width

    static let HEIGHT_Lens = UIScreen.main.bounds.height
}

/// 底部导航页面
/// 核心作用：承载五个主 Tab，使用 Assets 原图图标 + 选中着色
class TabBar_Lens: UITabBarController {

    /// 自定义 Tab 自屏幕底边向上的可视占用高度
    static let tabOverlayHeight_Lens: CGFloat = 62

    /// 按钮容器左右内边距
    private let tabHorizontalInset_Lens: CGFloat = 20

    /// Tab 背景顶部圆角
    private let tabTopCornerRadius_Lens: CGFloat = 20

    /// Tab 背景容器
    private var tabBgView_Lens = UIView()

    /// 按钮容器栈视图
    private var tabStackView_Lens = UIStackView()

    /// 首页按钮
    private var btnHome_Lens = UIButton(type: .custom)

    /// 发现页按钮
    private var btnDiscover_Lens = UIButton(type: .custom)

    /// 发布按钮
    private var btnRelease_Lens = UIButton(type: .custom)

    /// 消息按钮
    private var btnMessage_Lens = UIButton(type: .custom)

    /// 我的按钮
    private var btnMe_Lens = UIButton(type: .custom)

    /// 当前选中索引
    private var currentIndex_Lens: Int = 0

    /// Tab 图标尺寸
    private let tabIconSize_Lens: CGFloat = 25

    /// 选中图标着色
    private let tabSelectedColor_Lens = UIColor(hexstring_Lens: "#CCCCCC")

    // MARK: - 生命周期方法

    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [Home_Lens(), Discover_Lens(), Release_Lens(), MessageList_Lens(), Me_Lens()]
        setupUI_Lens()
        setupConstraints_Lens()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if navigationController?.topViewController === self {
            navigationController?.setNavigationBarHidden(true, animated: animated)
            tabStackView_Lens.isHidden = false
            tabBgView_Lens.isHidden = false
        }
        tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabStackView_Lens.isHidden = true
        tabBgView_Lens.isHidden = true
    }

    // MARK: - UI 设置

    private func setupUI_Lens() {
        tabBgView_Lens.backgroundColor = UIColor(hexstring_Lens: "#8529FE")
        tabBgView_Lens.layer.cornerRadius = tabTopCornerRadius_Lens
        tabBgView_Lens.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tabBgView_Lens.layer.masksToBounds = true
        view.addSubview(tabBgView_Lens)

        tabStackView_Lens.axis = .horizontal
        tabStackView_Lens.distribution = .equalSpacing
        tabStackView_Lens.alignment = .center
        tabBgView_Lens.addSubview(tabStackView_Lens)

        configTabButton_Lens(btnHome_Lens, imageName_Lens: "home", tag_Lens: 0)
        configTabButton_Lens(btnDiscover_Lens, imageName_Lens: "discover", tag_Lens: 1)
        configTabButton_Lens(btnRelease_Lens, imageName_Lens: "publish", tag_Lens: 2)
        configTabButton_Lens(btnMessage_Lens, imageName_Lens: "message", tag_Lens: 3)
        configTabButton_Lens(btnMe_Lens, imageName_Lens: "me", tag_Lens: 4)

        updateSelection_Lens(index_Lens: 0)
    }

    /// 统一配置 Tab 按钮（普通态原图，选中态 #CCCCCC 着色）
    /// - Parameters:
    ///   - button_Lens: 目标按钮
    ///   - imageName_Lens: Assets 图标名
    ///   - tag_Lens: Tab 索引
    private func configTabButton_Lens(
        _ button_Lens: UIButton,
        imageName_Lens: String,
        tag_Lens: Int
    ) {
        button_Lens.setImage(
            scaledOriginalImage_Lens(named_Lens: imageName_Lens),
            for: .normal
        )
        button_Lens.setImage(
            tintedImage_Lens(named_Lens: imageName_Lens, color_Lens: tabSelectedColor_Lens),
            for: .selected
        )
        button_Lens.tag = tag_Lens
        button_Lens.addTarget(self, action: #selector(tabButtonTapped_Lens(_:)), for: .touchUpInside)
        tabStackView_Lens.addArrangedSubview(button_Lens)
    }

    /// 获取 Assets 原图并按 25x25 缩放
    /// - Parameter named_Lens: 图片名称
    /// - Returns: 原图渲染模式的 UIImage
    private func scaledOriginalImage_Lens(named_Lens: String) -> UIImage? {
        guard let image_Lens = UIImage(named: named_Lens) else { return nil }
        let targetSize_Lens = CGSize(width: tabIconSize_Lens, height: tabIconSize_Lens)
        let renderer_Lens = UIGraphicsImageRenderer(size: targetSize_Lens)
        let scaled_Lens = renderer_Lens.image { _ in
            image_Lens.draw(in: CGRect(origin: .zero, size: targetSize_Lens))
        }
        return scaled_Lens.withRenderingMode(.alwaysOriginal)
    }

    /// 对 Assets 图片应用纯色着色
    /// - Parameters:
    ///   - named_Lens: 图片名称
    ///   - color_Lens: 着色颜色
    /// - Returns: 着色后的 UIImage
    private func tintedImage_Lens(named_Lens: String, color_Lens: UIColor) -> UIImage? {
        guard let original_Lens = scaledOriginalImage_Lens(named_Lens: named_Lens) else { return nil }
        let renderer_Lens = UIGraphicsImageRenderer(size: original_Lens.size)
        return renderer_Lens.image { ctx_Lens in
            color_Lens.setFill()
            ctx_Lens.fill(CGRect(origin: .zero, size: original_Lens.size))
            original_Lens.draw(at: .zero, blendMode: .destinationIn, alpha: 1)
        }.withRenderingMode(.alwaysOriginal)
    }

    /// 设置约束布局
    private func setupConstraints_Lens() {
        tabBgView_Lens.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-Self.tabOverlayHeight_Lens)
        }

        tabStackView_Lens.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(tabHorizontalInset_Lens)
            make.trailing.equalToSuperview().offset(-tabHorizontalInset_Lens)
            make.top.equalToSuperview().offset(6)
            make.height.equalTo(40)
        }

        [btnHome_Lens, btnDiscover_Lens, btnRelease_Lens, btnMessage_Lens, btnMe_Lens].forEach { btn_Lens in
            btn_Lens.snp.makeConstraints { make in
                make.width.height.equalTo(tabIconSize_Lens)
            }
        }
    }

    /// 统一更新所有按钮选中状态
    /// - Parameter index_Lens: 当前选中索引
    private func updateSelection_Lens(index_Lens: Int) {
        let allBtns_Lens = [btnHome_Lens, btnDiscover_Lens, btnRelease_Lens, btnMessage_Lens, btnMe_Lens]
        allBtns_Lens.enumerated().forEach { i_Lens, btn_Lens in
            btn_Lens.isSelected = (i_Lens == index_Lens)
        }
    }

    @objc private func tabButtonTapped_Lens(_ sender: UIButton) {
        let index_Lens = sender.tag
        currentIndex_Lens = index_Lens
        selectedIndex = index_Lens
        updateSelection_Lens(index_Lens: index_Lens)
    }
}
