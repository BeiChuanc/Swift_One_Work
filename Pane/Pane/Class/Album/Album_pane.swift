import UIKit
import SnapKit

// MARK: - 窗景册详情页

/// 窗景册详情页面（丰富UI版）
/// 核心作用：展示用户自定义窗景册内的所有图片，支持从相册添加/删除图片及删除整本相册
/// 设计思路：
///   - 大图渐变头部（装饰圆弧 + 多层光晕 + 信息条）
///   - 内容区带淡色背景渐变，图片网格卡片带阴影
///   - 全屏居中空状态覆盖层，底部渐变悬浮按钮
/// 关键方法：
///   - album_Pane：传入的窗景册对象（必须在展示前赋值）
///   - loadData_Pane：从相册读取本地图片路径列表并刷新
///   - saveImageToDocuments_Pane：将 UIImage 持久化到 Documents 目录并返回文件名
class Album_Pane: UIViewController {

    // MARK: - 公共属性

    var album_Pane: WindowAlbum_Pane!

    // MARK: - 私有常量

    private let imageCellId_Pane = "AlbumImageCell_Pane"

    // MARK: - UI：头部容器

    private let headerView_Pane: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        return v
    }()

    private var headerGradient_Pane: CAGradientLayer?

    // 装饰元素：大光晕圆（右上）
    private let haloLarge_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.alpha_Pane(0.1)
        v.layer.cornerRadius = 100
        return v
    }()

    // 装饰元素：中光晕圆（中右）
    private let haloMedium_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.alpha_Pane(0.07)
        v.layer.cornerRadius = 60
        return v
    }()

    // 装饰元素：小光晕圆（左下）
    private let haloSmall_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.alpha_Pane(0.06)
        v.layer.cornerRadius = 40
        return v
    }()

    // 返回按钮
    private let backButton_Pane: UIButton = {
        let b = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        b.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg), for: .normal)
        b.tintColor = .white
        b.backgroundColor = UIColor.white.alpha_Pane(0.22)
        b.layer.cornerRadius = 17
        b.layer.borderWidth = 0.5
        b.layer.borderColor = UIColor.white.alpha_Pane(0.3).cgColor
        return b
    }()

    // 删除按钮（右上角）
    private let deleteButton_Pane: UIButton = {
        let b = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(UIImage(systemName: "trash", withConfiguration: cfg), for: .normal)
        b.tintColor = .white
        b.backgroundColor = UIColor.white.alpha_Pane(0.22)
        b.layer.cornerRadius = 17
        b.layer.borderWidth = 0.5
        b.layer.borderColor = UIColor.white.alpha_Pane(0.3).cgColor
        return b
    }()

    // Emoji
    private let emojiLabel_Pane: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 56)
        l.textAlignment = .center
        return l
    }()

    // 相册名称
    private let albumTitleLabel_Pane: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 24, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        l.numberOfLines = 2
        l.layer.shadowColor = UIColor.black.alpha_Pane(0.25).cgColor
        l.layer.shadowOffset = CGSize(width: 0, height: 1)
        l.layer.shadowRadius = 3
        l.layer.shadowOpacity = 1
        return l
    }()

    // 描述
    private let descLabel_Pane: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .regular)
        l.textColor = UIColor.white.alpha_Pane(0.8)
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    // 底部信息条（图片数量 + 创建日期）
    private let infoBarView_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.alpha_Pane(0.18)
        v.layer.cornerRadius = 12
        return v
    }()

    private let countIconView_Pane: UIImageView = {
        let cfg = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        let iv = UIImageView(image: UIImage(systemName: "photo.stack", withConfiguration: cfg))
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let countLabel_Pane: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor = .white
        return l
    }()

    private let separatorDot_Pane: UILabel = {
        let l = UILabel()
        l.text = "·"
        l.font = .systemFont(ofSize: 12, weight: .bold)
        l.textColor = UIColor.white.alpha_Pane(0.5)
        return l
    }()

    private let dateIconView_Pane: UIImageView = {
        let cfg = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        let iv = UIImageView(image: UIImage(systemName: "calendar", withConfiguration: cfg))
        iv.tintColor = UIColor.white.alpha_Pane(0.8)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let dateLabel_Pane: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .regular)
        l.textColor = UIColor.white.alpha_Pane(0.8)
        return l
    }()

    // MARK: - UI：内容区

    private lazy var collectionView_Pane: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: buildLayout_Pane())
        cv.backgroundColor     = .clear
        cv.alwaysBounceVertical = true
        cv.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 110, right: 0)
        cv.dataSource = self
        cv.delegate   = self
        cv.register(AlbumImageCell_Pane.self, forCellWithReuseIdentifier: imageCellId_Pane)
        return cv
    }()

    // 内容区背景（极淡渐变，提升质感）
    private let contentBgView_Pane: UIView = {
        let v = UIView()
        return v
    }()

    private var contentBgGradient_Pane: CAGradientLayer?

    // 全屏空状态覆盖层
    private let emptyOverlay_Pane: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()

    // 底部浮动添加按钮
    private let addButton_Pane: UIButton = {
        let b = UIButton(type: .custom)
        b.setTitle("  Add Photos", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(UIImage(systemName: "photo.badge.plus", withConfiguration: cfg), for: .normal)
        b.tintColor = .white
        b.layer.cornerRadius = 26
        b.layer.shadowColor  = ColorConfig_Pane.primaryGradientStart_Pane.cgColor
        b.layer.shadowOpacity = 0.5
        b.layer.shadowOffset = CGSize(width: 0, height: 8)
        b.layer.shadowRadius = 16
        return b
    }()

    private var addButtonGradient_Pane: CAGradientLayer?

    // 按钮底部毛玻璃背景
    private let addButtonBg_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    private var addButtonBgGradient_Pane: CAGradientLayer?

    // MARK: - 状态

    private var imagePaths_Pane: [String] = []

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = ColorConfig_Pane.backgroundPrimary_Pane
        setupContentBg_Pane()
        setupUI_Pane()
        setupEmptyOverlay_Pane()
        loadData_Pane()
        observeNotifications_Pane()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradient_Pane?.frame         = headerView_Pane.bounds
        addButtonGradient_Pane?.frame      = addButton_Pane.bounds
        addButtonBgGradient_Pane?.frame    = addButtonBg_Pane.bounds
        contentBgGradient_Pane?.frame      = contentBgView_Pane.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    /// 搭建内容区淡色背景渐变
    private func setupContentBg_Pane() {
        view.addSubview(contentBgView_Pane)
        contentBgView_Pane.snp.makeConstraints { $0.edges.equalToSuperview() }

        let cgl_pane = CAGradientLayer()
        cgl_pane.colors = [
            ColorConfig_Pane.backgroundPrimary_Pane.cgColor,
            ColorConfig_Pane.primaryGradientStart_Pane.alpha_Pane(0.04).cgColor,
            ColorConfig_Pane.backgroundPrimary_Pane.cgColor
        ]
        cgl_pane.startPoint = CGPoint(x: 0, y: 0)
        cgl_pane.endPoint   = CGPoint(x: 1, y: 1)
        contentBgView_Pane.layer.insertSublayer(cgl_pane, at: 0)
        contentBgGradient_Pane = cgl_pane
    }

    /// 搭建主界面：头部 + 内容网格 + 浮动按钮
    private func setupUI_Pane() {
        // ─── 头部 ───
        view.addSubview(headerView_Pane)
        headerView_Pane.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(260)
        }

        // 渐变背景
        let gl_pane = CAGradientLayer()
        gl_pane.colors = [
            ColorConfig_Pane.primaryGradientStart_Pane.cgColor,
            ColorConfig_Pane.primaryGradientEnd_Pane.cgColor
        ]
        gl_pane.startPoint = CGPoint(x: 0, y: 0)
        gl_pane.endPoint   = CGPoint(x: 1, y: 1)
        headerView_Pane.layer.insertSublayer(gl_pane, at: 0)
        headerGradient_Pane = gl_pane

        // 光晕装饰
        headerView_Pane.addSubview(haloLarge_Pane)
        haloLarge_Pane.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(50)
            $0.top.equalToSuperview().offset(-50)
            $0.width.height.equalTo(200)
        }
        headerView_Pane.addSubview(haloMedium_Pane)
        haloMedium_Pane.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-30)
            $0.centerY.equalToSuperview().offset(20)
            $0.width.height.equalTo(120)
        }
        headerView_Pane.addSubview(haloSmall_Pane)
        haloSmall_Pane.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(20)
            $0.width.height.equalTo(80)
        }

        // 导航按钮
        headerView_Pane.addSubview(backButton_Pane)
        headerView_Pane.addSubview(deleteButton_Pane)
        backButton_Pane.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(34)
        }
        deleteButton_Pane.snp.makeConstraints {
            $0.centerY.equalTo(backButton_Pane)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.height.equalTo(34)
        }

        // Emoji
        headerView_Pane.addSubview(emojiLabel_Pane)
        emojiLabel_Pane.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(backButton_Pane.snp.bottom).offset(12)
            $0.height.equalTo(64)
        }

        // 名称
        headerView_Pane.addSubview(albumTitleLabel_Pane)
        albumTitleLabel_Pane.snp.makeConstraints {
            $0.top.equalTo(emojiLabel_Pane.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        // 描述
        headerView_Pane.addSubview(descLabel_Pane)
        descLabel_Pane.snp.makeConstraints {
            $0.top.equalTo(albumTitleLabel_Pane.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        // 信息条
        headerView_Pane.addSubview(infoBarView_Pane)
        infoBarView_Pane.snp.makeConstraints {
            $0.top.equalTo(descLabel_Pane.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(28)
        }

        let infoStack_pane = UIStackView(arrangedSubviews: [
            countIconView_Pane, countLabel_Pane,
            separatorDot_Pane,
            dateIconView_Pane, dateLabel_Pane
        ])
        infoStack_pane.axis      = .horizontal
        infoStack_pane.spacing   = 5
        infoStack_pane.alignment = .center

        infoBarView_Pane.addSubview(infoStack_pane)
        infoStack_pane.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(14)
            $0.top.bottom.equalToSuperview().inset(6)
        }
        countIconView_Pane.snp.makeConstraints { $0.width.height.equalTo(14) }
        dateIconView_Pane.snp.makeConstraints { $0.width.height.equalTo(14) }

        // ─── 内容区 ───
        view.addSubview(collectionView_Pane)
        collectionView_Pane.snp.makeConstraints {
            $0.top.equalTo(headerView_Pane.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        // ─── 底部按钮背景渐变 ───
        view.addSubview(addButtonBg_Pane)
        addButtonBg_Pane.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(110)
        }
        let bgGl_pane = CAGradientLayer()
        bgGl_pane.colors = [
            UIColor.clear.cgColor,
            ColorConfig_Pane.backgroundPrimary_Pane.alpha_Pane(0.85).cgColor,
            ColorConfig_Pane.backgroundPrimary_Pane.cgColor
        ]
        bgGl_pane.startPoint = CGPoint(x: 0.5, y: 0)
        bgGl_pane.endPoint   = CGPoint(x: 0.5, y: 1)
        addButtonBg_Pane.layer.insertSublayer(bgGl_pane, at: 0)
        addButtonBgGradient_Pane = bgGl_pane

        // ─── 浮动按钮 ───
        view.addSubview(addButton_Pane)
        addButton_Pane.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(52)
            $0.width.equalTo(190)
        }

        let addGl_pane = CAGradientLayer()
        addGl_pane.colors = [
            ColorConfig_Pane.primaryGradientStart_Pane.cgColor,
            ColorConfig_Pane.primaryGradientEnd_Pane.cgColor
        ]
        addGl_pane.startPoint = CGPoint(x: 0, y: 0.5)
        addGl_pane.endPoint   = CGPoint(x: 1, y: 0.5)
        addGl_pane.cornerRadius = 26
        addButton_Pane.layer.insertSublayer(addGl_pane, at: 0)
        addButtonGradient_Pane = addGl_pane

        backButton_Pane.addTarget(self, action: #selector(backTapped_Pane), for: .touchUpInside)
        deleteButton_Pane.addTarget(self, action: #selector(deleteTapped_Pane), for: .touchUpInside)
        addButton_Pane.addTarget(self, action: #selector(addPhotosTapped_Pane), for: .touchUpInside)
    }

    /// 搭建全屏居中空状态覆盖层
    private func setupEmptyOverlay_Pane() {
        view.addSubview(emptyOverlay_Pane)
        emptyOverlay_Pane.snp.makeConstraints {
            $0.top.equalTo(headerView_Pane.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        // 卡片容器
        let card_pane = UIView()
        card_pane.backgroundColor   = .white
        card_pane.layer.cornerRadius = 28
        card_pane.layer.shadowColor  = ColorConfig_Pane.primaryGradientStart_Pane.alpha_Pane(0.15).cgColor
        card_pane.layer.shadowOpacity = 1
        card_pane.layer.shadowOffset  = CGSize(width: 0, height: 8)
        card_pane.layer.shadowRadius  = 24
        emptyOverlay_Pane.addSubview(card_pane)
        card_pane.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(32)
        }

        // 卡片内渐变顶部装饰条
        let topBar_pane = UIView()
        topBar_pane.layer.cornerRadius = 28
        topBar_pane.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        topBar_pane.clipsToBounds = true
        card_pane.addSubview(topBar_pane)
        topBar_pane.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(6)
        }
        let barGl_pane = CAGradientLayer()
        barGl_pane.colors = [
            ColorConfig_Pane.primaryGradientStart_Pane.cgColor,
            ColorConfig_Pane.primaryGradientEnd_Pane.cgColor
        ]
        barGl_pane.startPoint = CGPoint(x: 0, y: 0.5)
        barGl_pane.endPoint   = CGPoint(x: 1, y: 0.5)
        // 在 layoutSubviews 时更新 frame，此处用一个包装 view 来处理
        DispatchQueue.main.async { barGl_pane.frame = topBar_pane.bounds }
        topBar_pane.layer.addSublayer(barGl_pane)

        // 图标容器（带浅色背景）
        let iconBg_pane = UIView()
        iconBg_pane.backgroundColor = ColorConfig_Pane.primaryGradientStart_Pane.alpha_Pane(0.08)
        iconBg_pane.layer.cornerRadius = 24
        card_pane.addSubview(iconBg_pane)
        iconBg_pane.snp.makeConstraints {
            $0.top.equalTo(topBar_pane.snp.bottom).offset(28)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(72)
        }

        let cfg_pane = UIImage.SymbolConfiguration(pointSize: 32, weight: .light)
        let icon_pane = UIImageView(image: UIImage(systemName: "photo.on.rectangle.angled", withConfiguration: cfg_pane))
        icon_pane.tintColor   = ColorConfig_Pane.primaryGradientStart_Pane
        icon_pane.contentMode = .scaleAspectFit
        iconBg_pane.addSubview(icon_pane)
        icon_pane.snp.makeConstraints { $0.center.equalToSuperview(); $0.width.height.equalTo(36) }

        // 文字
        let title_pane = UILabel()
        title_pane.text          = "No photos yet"
        title_pane.font          = .systemFont(ofSize: 18, weight: .bold)
        title_pane.textColor     = ColorConfig_Pane.textPrimary_Pane
        title_pane.textAlignment = .center

        let sub_pane = UILabel()
        sub_pane.text          = "Tap the button below to\nadd your first window photo"
        sub_pane.font          = .systemFont(ofSize: 13, weight: .regular)
        sub_pane.textColor     = ColorConfig_Pane.textSecondary_Pane
        sub_pane.textAlignment = .center
        sub_pane.numberOfLines = 2

        // 入口按钮（渐变样式）
        let addBtn_pane = UIButton(type: .custom)
        addBtn_pane.setTitle("  Add Photos", for: .normal)
        addBtn_pane.setTitleColor(.white, for: .normal)
        addBtn_pane.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        let btnCfg_pane = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        addBtn_pane.setImage(UIImage(systemName: "photo.badge.plus", withConfiguration: btnCfg_pane), for: .normal)
        addBtn_pane.tintColor = .white
        addBtn_pane.layer.cornerRadius = 20
        addBtn_pane.layer.shadowColor  = ColorConfig_Pane.primaryGradientStart_Pane.cgColor
        addBtn_pane.layer.shadowOpacity = 0.35
        addBtn_pane.layer.shadowOffset  = CGSize(width: 0, height: 4)
        addBtn_pane.layer.shadowRadius  = 10
        addBtn_pane.addTarget(self, action: #selector(addPhotosTapped_Pane), for: .touchUpInside)
        // 渐变背景通过 layoutSubviews 添加
        let emptyBtnGl_pane = CAGradientLayer()
        emptyBtnGl_pane.colors = [
            ColorConfig_Pane.primaryGradientStart_Pane.cgColor,
            ColorConfig_Pane.primaryGradientEnd_Pane.cgColor
        ]
        emptyBtnGl_pane.startPoint  = CGPoint(x: 0, y: 0.5)
        emptyBtnGl_pane.endPoint    = CGPoint(x: 1, y: 0.5)
        emptyBtnGl_pane.cornerRadius = 20
        DispatchQueue.main.async { emptyBtnGl_pane.frame = addBtn_pane.bounds }
        addBtn_pane.layer.insertSublayer(emptyBtnGl_pane, at: 0)

        let stack_pane = UIStackView(arrangedSubviews: [title_pane, sub_pane])
        stack_pane.axis      = .vertical
        stack_pane.spacing   = 8
        stack_pane.alignment = .center

        card_pane.addSubview(stack_pane)
        card_pane.addSubview(addBtn_pane)

        stack_pane.snp.makeConstraints {
            $0.top.equalTo(iconBg_pane.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        addBtn_pane.snp.makeConstraints {
            $0.top.equalTo(stack_pane.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(28)
            $0.height.equalTo(42)
            $0.width.equalTo(160)
        }
    }

    // MARK: - 数据加载

    /// 加载相册图片路径列表并刷新界面
    private func loadData_Pane() {
        guard let album_pane = album_Pane else { return }
        imagePaths_Pane = album_pane.imagePaths_Pane ?? []

        // 更新头部信息
        emojiLabel_Pane.text      = album_pane.albumEmoji_Pane
        albumTitleLabel_Pane.text = album_pane.albumName_Pane
        descLabel_Pane.text       = album_pane.albumDesc_Pane.isEmpty
            ? "Your curated window collection"
            : album_pane.albumDesc_Pane
        countLabel_Pane.text      = "\(imagePaths_Pane.count) photos"
        dateLabel_Pane.text       = album_pane.createdAt_Pane

        // 空 / 有内容状态
        let isEmpty_pane          = imagePaths_Pane.isEmpty
        emptyOverlay_Pane.isHidden = !isEmpty_pane
        collectionView_Pane.isHidden = isEmpty_pane
        addButton_Pane.isHidden      = isEmpty_pane
        addButtonBg_Pane.isHidden    = isEmpty_pane

        collectionView_Pane.reloadData()
    }

    /// 监听帖子/相册状态变更通知
    private func observeNotifications_Pane() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onTitleStateChange_Pane),
            name: TitleViewModel_Pane.titleStateDidChangeNotification_Pane,
            object: nil
        )
    }

    @objc private func onTitleStateChange_Pane() {
        if let updated_pane = TitleViewModel_Pane.shared_Pane.getUserAlbums_Pane()
            .first(where: { $0.albumId_Pane == album_Pane.albumId_Pane }) {
            album_Pane = updated_pane
        }
        loadData_Pane()
    }

    // MARK: - 布局构建

    /// 构建两列等宽网格布局（每格高度 195，间距 8）
    private func buildLayout_Pane() -> UICollectionViewLayout {
        let item_pane = NSCollectionLayoutItem(layoutSize: .init(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalHeight(1.0)
        ))
        item_pane.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6)

        let group_pane = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(195)),
            subitems: [item_pane]
        )
        let section_pane = NSCollectionLayoutSection(group: group_pane)
        section_pane.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10)
        return UICollectionViewCompositionalLayout(section: section_pane)
    }

    // MARK: - 图片存储工具

    /// 将 UIImage 存储到 Documents 目录并返回文件名（UUID.jpg）
    private func saveImageToDocuments_Pane(image_pane: UIImage) -> String? {
        guard let data_pane = image_pane.jpegData(compressionQuality: 0.85) else { return nil }
        let fileName_pane = "\(UUID().uuidString).jpg"
        let url_pane = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName_pane)
        do {
            try data_pane.write(to: url_pane)
            return fileName_pane
        } catch {
            print("图片存储失败: \(error.localizedDescription)")
            return nil
        }
    }

    /// 从 Documents 目录删除指定图片文件
    private func deleteImageFile_Pane(fileName_pane: String) {
        let url_pane = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName_pane)
        try? FileManager.default.removeItem(at: url_pane)
    }

    // MARK: - 动作

    @objc private func backTapped_Pane() {
        Navigation_Pane.pop_Pane()
    }

    /// 右上角删除整本相册（带确认）
    @objc private func deleteTapped_Pane() {
        let alert_pane = UIAlertController(
            title: "Delete Album",
            message: "This will permanently delete the album and all its photos.",
            preferredStyle: .alert
        )
        alert_pane.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self_pane = self else { return }
            (self_pane.album_Pane.imagePaths_Pane ?? []).forEach {
                self_pane.deleteImageFile_Pane(fileName_pane: $0)
            }
            TitleViewModel_Pane.shared_Pane.deleteAlbum_Pane(albumId_pane: self_pane.album_Pane.albumId_Pane)
            Navigation_Pane.pop_Pane()
        })
        alert_pane.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert_pane, animated: true)
    }

    /// 从相册选取图片添加到窗景册
    @objc private func addPhotosTapped_Pane() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        let picker_pane        = UIImagePickerController()
        picker_pane.sourceType = .photoLibrary
        picker_pane.delegate   = self
        present(picker_pane, animated: true)
    }
}

// MARK: - UICollectionViewDataSource / Delegate

extension Album_Pane: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ cv: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagePaths_Pane.count
    }

    func collectionView(_ cv: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_pane = cv.dequeueReusableCell(
            withReuseIdentifier: imageCellId_Pane, for: indexPath) as! AlbumImageCell_Pane
        let path_pane = imagePaths_Pane[indexPath.item]
        cell_pane.configure_Pane(imagePath_pane: path_pane, index_pane: indexPath.item + 1)
        cell_pane.onDelete_Pane = { [weak self] in
            guard let self_pane = self else { return }
            TitleViewModel_Pane.shared_Pane.removeImageFromAlbum_Pane(
                imagePath_pane: path_pane,
                albumId_pane: self_pane.album_Pane.albumId_Pane
            )
            self_pane.deleteImageFile_Pane(fileName_pane: path_pane)
        }
        return cell_pane
    }
}

// MARK: - UIImagePickerControllerDelegate

extension Album_Pane: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        guard let img_pane = info[.originalImage] as? UIImage else { return }
        guard let fileName_pane = saveImageToDocuments_Pane(image_pane: img_pane) else {
            Utils_Pane.showError_Pane(message_Pane: "Failed to save photo.")
            return
        }
        TitleViewModel_Pane.shared_Pane.addImageToAlbum_Pane(
            imagePath_pane: fileName_pane,
            albumId_pane: album_Pane.albumId_Pane
        )
        Utils_Pane.showSuccess_Pane(
            message_Pane: "Photo added.",
            image_Pane: UIImage(systemName: "checkmark.circle.fill")
        )
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - 图片单元格

/// 窗景册图片单元格（丰富UI版）
/// 核心作用：展示本地图片，底部渐变叠层 + 序号标签，右上角删除按钮，卡片阴影增强层次感
private class AlbumImageCell_Pane: UICollectionViewCell {

    var onDelete_Pane: (() -> Void)?

    // MARK: - UI

    // 外层阴影容器（使 clipsToBounds 不影响阴影）
    private let shadowContainer_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 18
        v.layer.shadowColor   = UIColor.black.alpha_Pane(0.15).cgColor
        v.layer.shadowOpacity = 1
        v.layer.shadowOffset  = CGSize(width: 0, height: 4)
        v.layer.shadowRadius  = 10
        return v
    }()

    // 内层图片容器（圆角裁剪）
    private let imageContainer_Pane: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 18
        v.clipsToBounds = true
        return v
    }()

    private let imageView_Pane: UIImageView = {
        let iv = UIImageView()
        iv.contentMode   = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = ColorConfig_Pane.divider_Pane
        return iv
    }()

    // 底部渐变叠层
    private let bottomGradient_Pane: CAGradientLayer = {
        let gl = CAGradientLayer()
        gl.colors = [UIColor.clear.cgColor,
                     UIColor.black.alpha_Pane(0.1).cgColor,
                     UIColor.black.alpha_Pane(0.45).cgColor]
        gl.startPoint = CGPoint(x: 0.5, y: 0.3)
        gl.endPoint   = CGPoint(x: 0.5, y: 1.0)
        return gl
    }()

    // 序号标签（左下角）
    private let indexLabel_Pane: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 10, weight: .bold)
        l.textColor = UIColor.white.alpha_Pane(0.85)
        return l
    }()

    // 删除按钮（右上角）
    private let deleteButton_Pane: UIButton = {
        let b = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
        b.setImage(UIImage(systemName: "xmark", withConfiguration: cfg), for: .normal)
        b.tintColor = .white
        b.backgroundColor = UIColor.black.alpha_Pane(0.5)
        b.layer.cornerRadius = 12
        b.layer.borderWidth = 0.5
        b.layer.borderColor = UIColor.white.alpha_Pane(0.3).cgColor
        return b
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Pane()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI_Pane() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        // 阴影容器
        contentView.addSubview(shadowContainer_Pane)
        shadowContainer_Pane.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 图片容器（与阴影容器等大，但 clipsToBounds）
        shadowContainer_Pane.addSubview(imageContainer_Pane)
        imageContainer_Pane.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 图片
        imageContainer_Pane.addSubview(imageView_Pane)
        imageView_Pane.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 底部渐变
        imageContainer_Pane.layer.addSublayer(bottomGradient_Pane)

        // 序号标签
        imageContainer_Pane.addSubview(indexLabel_Pane)
        indexLabel_Pane.snp.makeConstraints {
            $0.leading.bottom.equalToSuperview().inset(10)
        }

        // 删除按钮
        imageContainer_Pane.addSubview(deleteButton_Pane)
        deleteButton_Pane.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(8)
            $0.width.height.equalTo(24)
        }
        deleteButton_Pane.addTarget(self, action: #selector(deleteTapped_Pane), for: .touchUpInside)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        bottomGradient_Pane.frame = imageView_Pane.bounds
    }

    // MARK: - 数据配置

    /// 配置图片单元格
    /// - Parameters:
    ///   - imagePath_pane: 图片文件名（Documents 目录）
    ///   - index_pane: 序号（从 1 开始）
    func configure_Pane(imagePath_pane: String, index_pane: Int) {
        let docs_pane = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url_pane  = docs_pane.appendingPathComponent(imagePath_pane)
        if let img_pane = UIImage(contentsOfFile: url_pane.path) {
            imageView_Pane.image = img_pane
        } else {
            imageView_Pane.image = UIImage(named: imagePath_pane)
                ?? UIImage(systemName: "photo")?.withTintColor(
                    ColorConfig_Pane.textPlaceholder_Pane, renderingMode: .alwaysOriginal)
        }
        indexLabel_Pane.text = "#\(index_pane)"
    }

    // MARK: - 动作

    @objc private func deleteTapped_Pane() {
        onDelete_Pane?()
    }

    // MARK: - 触摸动画

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        UIView.animate(withDuration: 0.12) {
            self.shadowContainer_Pane.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: 0.22, delay: 0, usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.4,
                       animations: { self.shadowContainer_Pane.transform = .identity })
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        UIView.animate(withDuration: 0.15) { self.shadowContainer_Pane.transform = .identity }
    }
}
