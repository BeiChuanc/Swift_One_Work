import UIKit
import SnapKit

// MARK: - 首页横向窗景册 Section Cell

/// 首页专属窗景册区块容器单元格
/// 核心作用：展示区头（标题 + 快速记录按钮）+ 横向滚动相册列表（无数据时显示空状态）
/// 设计思路：区头渐变标题 + 快速记录悬浮按钮 + 嵌套 UICollectionView + 空状态引导
/// 关键回调：
///   - onCreateAlbum_Pane:   点击「+」新建窗景册
///   - onSelectAlbum_Pane:   点击某个窗景册卡片
///   - onQuickRecord_Pane:   点击「Quick Record」按钮
class HomeAlbumSectionCell_Pane: UICollectionViewCell {

    // MARK: - 常量

    static let reuseId_Pane       = "HomeAlbumSectionCell_Pane"
    private static let innerCellId_Pane  = "AlbumInnerCell_Pane"
    private static let createCellId_Pane = "AlbumCreateCell_Pane"

    // MARK: - UI 组件 — 区头

    private let sectionTitleLabel_Pane: UILabel = {
        let l = UILabel()
        l.text      = "My Window Albums"
        l.font      = .systemFont(ofSize: 16, weight: .bold)
        l.textColor = ColorConfig_Pane.textPrimary_Pane
        return l
    }()

    private let titleDecoBar_Pane: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 2
        return v
    }()

    private var decoBarGradient_Pane: CAGradientLayer?

    private let quickRecordButton_Pane: UIButton = {
        let b = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        b.setImage(UIImage(systemName: "camera.fill", withConfiguration: cfg), for: .normal)
        b.setTitle("  Quick Record", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.tintColor       = .white
        b.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        b.layer.cornerRadius = 15
        b.layer.shadowColor  = ColorConfig_Pane.primaryGradientStart_Pane.cgColor
        b.layer.shadowOpacity = 0.3
        b.layer.shadowOffset  = CGSize(width: 0, height: 4)
        b.layer.shadowRadius  = 8
        b.contentEdgeInsets   = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 14)
        b.imageEdgeInsets     = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -4)
        return b
    }()

    private var qrButtonGradient_Pane: CAGradientLayer?

    // MARK: - UI 组件 — 内容区

    private lazy var innerCV_Pane: UICollectionView = {
        let layout_pane = UICollectionViewFlowLayout()
        layout_pane.scrollDirection           = .horizontal
        layout_pane.itemSize                  = CGSize(width: 110, height: 128)
        layout_pane.minimumInteritemSpacing   = 12
        layout_pane.minimumLineSpacing        = 12
        layout_pane.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        let cv_pane = UICollectionView(frame: .zero, collectionViewLayout: layout_pane)
        cv_pane.backgroundColor        = .clear
        cv_pane.showsHorizontalScrollIndicator = false
        cv_pane.alwaysBounceHorizontal = true
        cv_pane.dataSource             = self
        cv_pane.delegate               = self
        cv_pane.register(AlbumInnerCard_Pane.self,
                         forCellWithReuseIdentifier: HomeAlbumSectionCell_Pane.innerCellId_Pane)
        cv_pane.register(AlbumCreateCard_Pane.self,
                         forCellWithReuseIdentifier: HomeAlbumSectionCell_Pane.createCellId_Pane)
        return cv_pane
    }()

    // MARK: - 空状态视图

    private let emptyView_Pane: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()

    // MARK: - 状态属性

    private var albums_Pane: [WindowAlbum_Pane] = []

    // MARK: - 回调

    var onCreateAlbum_Pane:  (() -> Void)?
    var onSelectAlbum_Pane:  ((WindowAlbum_Pane) -> Void)?
    var onQuickRecord_Pane:  (() -> Void)?
    /// 点击删除按钮时回调，携带对应的窗景册
    var onDeleteAlbum_Pane:  ((WindowAlbum_Pane) -> Void)?

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupHeader_Pane()
        setupContentArea_Pane()
        setupEmptyState_Pane()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        qrButtonGradient_Pane?.frame = quickRecordButton_Pane.bounds
        decoBarGradient_Pane?.frame  = titleDecoBar_Pane.bounds
    }

    // MARK: - UI 搭建

    private func setupHeader_Pane() {
        // 装饰竖条
        contentView.addSubview(titleDecoBar_Pane)
        titleDecoBar_Pane.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview().offset(4)
            $0.width.equalTo(4)
            $0.height.equalTo(18)
        }
        let dgl_pane = CAGradientLayer()
        dgl_pane.colors     = [ColorConfig_Pane.primaryGradientStart_Pane.cgColor,
                               ColorConfig_Pane.primaryGradientEnd_Pane.cgColor]
        dgl_pane.startPoint = CGPoint(x: 0, y: 0)
        dgl_pane.endPoint   = CGPoint(x: 0, y: 1)
        dgl_pane.cornerRadius = 2
        titleDecoBar_Pane.layer.addSublayer(dgl_pane)
        decoBarGradient_Pane = dgl_pane

        contentView.addSubview(sectionTitleLabel_Pane)
        sectionTitleLabel_Pane.snp.makeConstraints {
            $0.leading.equalTo(titleDecoBar_Pane.snp.trailing).offset(8)
            $0.centerY.equalTo(titleDecoBar_Pane)
        }

        // 快速记录按钮
        contentView.addSubview(quickRecordButton_Pane)
        quickRecordButton_Pane.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalTo(titleDecoBar_Pane)
            $0.height.equalTo(30)
        }

        let qgl_pane = CAGradientLayer()
        qgl_pane.colors     = [ColorConfig_Pane.primaryGradientStart_Pane.cgColor,
                               ColorConfig_Pane.primaryGradientEnd_Pane.cgColor]
        qgl_pane.startPoint = CGPoint(x: 0, y: 0.5)
        qgl_pane.endPoint   = CGPoint(x: 1, y: 0.5)
        qgl_pane.cornerRadius = 15
        quickRecordButton_Pane.layer.insertSublayer(qgl_pane, at: 0)
        qrButtonGradient_Pane = qgl_pane

        quickRecordButton_Pane.addTarget(self, action: #selector(quickRecordTapped_Pane), for: .touchUpInside)
    }

    private func setupContentArea_Pane() {
        contentView.addSubview(innerCV_Pane)
        innerCV_Pane.snp.makeConstraints {
            $0.top.equalTo(sectionTitleLabel_Pane.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(128)
        }
    }

    /// 搭建空状态视图（垂直居中布局）
    private func setupEmptyState_Pane() {
        contentView.addSubview(emptyView_Pane)
        emptyView_Pane.snp.makeConstraints {
            $0.top.equalTo(sectionTitleLabel_Pane.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(128)
        }

        // 背景卡片
        let bg_pane = UIView()
        bg_pane.backgroundColor  = ColorConfig_Pane.primaryGradientStart_Pane.alpha_Pane(0.04)
        bg_pane.layer.cornerRadius = 16
        bg_pane.layer.borderWidth  = 1
        bg_pane.layer.borderColor  = ColorConfig_Pane.primaryGradientStart_Pane.alpha_Pane(0.12).cgColor
        emptyView_Pane.addSubview(bg_pane)
        bg_pane.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        }

        let cfg_pane = UIImage.SymbolConfiguration(pointSize: 24, weight: .ultraLight)
        let icon_pane = UIImageView(image: UIImage(systemName: "rectangle.stack.badge.plus",
                                                   withConfiguration: cfg_pane))
        icon_pane.tintColor   = ColorConfig_Pane.primaryGradientStart_Pane.alpha_Pane(0.6)
        icon_pane.contentMode = .scaleAspectFit
        icon_pane.snp.makeConstraints { $0.width.height.equalTo(32) }

        let desc_pane = UILabel()
        desc_pane.text          = "Create your first window album"
        desc_pane.font          = .systemFont(ofSize: 13, weight: .medium)
        desc_pane.textColor     = ColorConfig_Pane.textSecondary_Pane
        desc_pane.textAlignment = .center

        let createBtn_pane = UIButton(type: .system)
        createBtn_pane.setTitle("+ Create Album", for: .normal)
        createBtn_pane.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        createBtn_pane.setTitleColor(ColorConfig_Pane.primaryGradientStart_Pane, for: .normal)
        createBtn_pane.layer.borderWidth  = 1
        createBtn_pane.layer.borderColor  = ColorConfig_Pane.primaryGradientStart_Pane.alpha_Pane(0.45).cgColor
        createBtn_pane.layer.cornerRadius = 14
        createBtn_pane.contentEdgeInsets  = UIEdgeInsets(top: 6, left: 18, bottom: 6, right: 18)
        createBtn_pane.addTarget(self, action: #selector(emptyCreateTapped_Pane), for: .touchUpInside)

        let stack_pane = UIStackView(arrangedSubviews: [icon_pane, desc_pane, createBtn_pane])
        stack_pane.axis      = .vertical
        stack_pane.spacing   = 10
        stack_pane.alignment = .center

        bg_pane.addSubview(stack_pane)
        stack_pane.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    // MARK: - 数据配置

    /// 配置窗景册数据
    func configure_Pane(albums_pane: [WindowAlbum_Pane]) {
        albums_Pane = albums_pane
        let isEmpty_pane = albums_pane.isEmpty
        innerCV_Pane.isHidden  = isEmpty_pane
        emptyView_Pane.isHidden = !isEmpty_pane
        innerCV_Pane.reloadData()
    }

    // MARK: - 动作

    @objc private func quickRecordTapped_Pane() {
        let gen_pane = UIImpactFeedbackGenerator(style: .medium)
        gen_pane.impactOccurred()
        onQuickRecord_Pane?()
    }

    @objc private func emptyCreateTapped_Pane() {
        onCreateAlbum_Pane?()
    }
}

// MARK: - UICollectionViewDataSource / Delegate

extension HomeAlbumSectionCell_Pane: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 1 + albums_Pane.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: HomeAlbumSectionCell_Pane.createCellId_Pane,
                for: indexPath
            ) as! AlbumCreateCard_Pane
        }
        let album_pane = albums_Pane[indexPath.item - 1]
        let cell_pane  = collectionView.dequeueReusableCell(
            withReuseIdentifier: HomeAlbumSectionCell_Pane.innerCellId_Pane,
            for: indexPath
        ) as! AlbumInnerCard_Pane
        cell_pane.configure_Pane(album_pane: album_pane)
        cell_pane.onDelete_Pane = { [weak self] in
            guard let self = self else { return }
            self.onDeleteAlbum_Pane?(album_pane)
        }
        return cell_pane
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            onCreateAlbum_Pane?()
        } else {
            onSelectAlbum_Pane?(albums_Pane[indexPath.item - 1])
        }
    }
}

// MARK: - 相册卡片（内嵌）

/// 单个窗景册卡片
/// 核心作用：展示窗景册封面（Emoji + 名称 + 数量），右上角提供删除按钮
private class AlbumInnerCard_Pane: UICollectionViewCell {

    /// 删除按钮点击回调
    var onDelete_Pane: (() -> Void)?

    private let deleteButton_Pane: UIButton = {
        let b = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 9, weight: .bold)
        b.setImage(UIImage(systemName: "xmark", withConfiguration: cfg), for: .normal)
        b.tintColor = .white
        b.backgroundColor = UIColor.black.alpha_Pane(0.4)
        b.layer.cornerRadius = 10
        return b
    }()

    private let emojiLabel_Pane: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 30)
        l.textAlignment = .center
        return l
    }()

    private let nameLabel_Pane: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 11, weight: .semibold)
        l.textColor     = ColorConfig_Pane.textPrimary_Pane
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    private let countLabel_Pane: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 10, weight: .regular)
        l.textColor     = ColorConfig_Pane.primaryGradientStart_Pane
        l.textAlignment = .center
        return l
    }()

    private var gradientLayer_Pane: CAGradientLayer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Pane()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI_Pane() {
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = ColorConfig_Pane.primaryGradientStart_Pane.alpha_Pane(0.18).cgColor

        let gl_pane = CAGradientLayer()
        gl_pane.colors     = [UIColor(hexstring_Pane: "#F2EEFF").cgColor,
                              UIColor(hexstring_Pane: "#E9F3FF").cgColor]
        gl_pane.startPoint = CGPoint(x: 0, y: 0)
        gl_pane.endPoint   = CGPoint(x: 1, y: 1)
        contentView.layer.insertSublayer(gl_pane, at: 0)
        gradientLayer_Pane = gl_pane

        contentView.addSubview(emojiLabel_Pane)
        contentView.addSubview(nameLabel_Pane)
        contentView.addSubview(countLabel_Pane)
        contentView.addSubview(deleteButton_Pane)

        emojiLabel_Pane.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(36)
        }
        nameLabel_Pane.snp.makeConstraints {
            $0.top.equalTo(emojiLabel_Pane.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview().inset(6)
        }
        countLabel_Pane.snp.makeConstraints {
            $0.top.equalTo(nameLabel_Pane.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(6)
        }

        // 右上角删除按钮
        deleteButton_Pane.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(6)
            $0.width.height.equalTo(20)
        }
        deleteButton_Pane.addTarget(self, action: #selector(deleteTapped_Pane), for: .touchUpInside)
    }

    /// 删除按钮点击
    @objc private func deleteTapped_Pane() {
        onDelete_Pane?()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer_Pane?.frame = contentView.bounds
    }

    func configure_Pane(album_pane: WindowAlbum_Pane) {
        emojiLabel_Pane.text = album_pane.albumEmoji_Pane
        nameLabel_Pane.text  = album_pane.albumName_Pane
        let cnt_pane         = album_pane.postIds_Pane.count
        countLabel_Pane.text = cnt_pane > 0 ? "\(cnt_pane) window\(cnt_pane > 1 ? "s" : "")" : "Empty"
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        UIView.animate(withDuration: 0.12) { self.transform = CGAffineTransform(scaleX: 0.94, y: 0.94) }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: 0.2, delay: 0,
                       usingSpringWithDamping: 0.6, initialSpringVelocity: 0.4,
                       animations: { self.transform = .identity })
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        UIView.animate(withDuration: 0.2) { self.transform = .identity }
    }
}

// MARK: - 「新建」创建卡片

/// 「+」新建窗景册入口卡片
private class AlbumCreateCard_Pane: UICollectionViewCell {

    private let plusIcon_Pane: UIImageView = {
        let cfg = UIImage.SymbolConfiguration(pointSize: 20, weight: .light)
        let iv  = UIImageView(image: UIImage(systemName: "plus", withConfiguration: cfg))
        iv.tintColor   = ColorConfig_Pane.primaryGradientStart_Pane
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let createLabel_Pane: UILabel = {
        let l = UILabel()
        l.text          = "New Album"
        l.font          = .systemFont(ofSize: 11, weight: .medium)
        l.textColor     = ColorConfig_Pane.primaryGradientStart_Pane
        l.textAlignment = .center
        return l
    }()

    private let dashedLayer_Pane = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Pane()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI_Pane() {
        contentView.layer.cornerRadius = 16
        contentView.backgroundColor    = ColorConfig_Pane.primaryGradientStart_Pane.alpha_Pane(0.04)

        dashedLayer_Pane.strokeColor     = ColorConfig_Pane.primaryGradientStart_Pane.alpha_Pane(0.45).cgColor
        dashedLayer_Pane.fillColor       = nil
        dashedLayer_Pane.lineWidth       = 1.5
        dashedLayer_Pane.lineDashPattern = [6, 4]
        contentView.layer.addSublayer(dashedLayer_Pane)

        contentView.addSubview(plusIcon_Pane)
        contentView.addSubview(createLabel_Pane)

        plusIcon_Pane.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-12)
            $0.width.height.equalTo(30)
        }
        createLabel_Pane.snp.makeConstraints {
            $0.top.equalTo(plusIcon_Pane.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview().inset(6)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let path_pane        = UIBezierPath(roundedRect: contentView.bounds, cornerRadius: 16)
        dashedLayer_Pane.path  = path_pane.cgPath
        dashedLayer_Pane.frame = contentView.bounds
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        UIView.animate(withDuration: 0.12) { self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95) }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: 0.2, delay: 0,
                       usingSpringWithDamping: 0.6, initialSpringVelocity: 0.4,
                       animations: { self.transform = .identity })
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        UIView.animate(withDuration: 0.2) { self.transform = .identity }
    }
}
