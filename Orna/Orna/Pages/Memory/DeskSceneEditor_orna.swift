import Foundation
import UIKit
import SnapKit

// MARK: 桌面场景编辑器

/// 桌面场景编辑器视图控制器
/// 核心作用：在自由画布上摆放摆件 / 手写便签 / 迷你相框，支持拖拽移动与捏合缩放，
///           并可将当前场景截图保存为"纪念明信片"，闭环覆盖"搭建场景 → 自由摆放 → 导出留念"
/// 设计思路：
///   - 画布背景按场景主题渲染渐变（迷你书房 / 海边角落 / 森林小屋）
///   - 每个已摆放元素为独立可拖拽视图，携带小巧的删除徽标；
///     拖拽 / 缩放手势结束后将最新位置与缩放比例回写到 UserViewModel_Orna 持久状态
///   - "+"按钮弹出操作面板：摆放已拥有摆件（桌面图鉴 / 记忆摆件）、添加手写便签、添加迷你相框
///   - "相机"按钮将画布渲染为图片并保存至系统相册，形成"纪念明信片"导出闭环
/// 关键属性：
///   - sceneId_Orna: 外部传入的目标场景ID，页面自身始终以此ID重新拉取最新数据
class DeskSceneEditor_Orna: UIViewController {

    // MARK: - 数据

    /// 目标场景ID（由 Navigation_Orna 传入）
    var sceneId_Orna: Int = -1

    private var scene_Orna: DeskSceneModel_Orna?

    /// 便签背景色候选（柔和马卡龙色系）
    private static let noteColorOptions_Orna: [String] = ["#FFF3B0", "#FFD6E8", "#C9F2C7", "#C7E4FF"]

    // MARK: - UI · 顶部工具条

    private let backButton_Orna: UIButton = {
        let b = UIButton(type: .system)
        let cfg_orna = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg_orna), for: .normal)
        b.tintColor = UIColor(hexstring_Orna: "#2D2A3D")
        b.backgroundColor = .white
        b.layer.cornerRadius = 18
        b.layer.shadowColor = UIColor(hexstring_Orna: "#7B61FF").cgColor
        b.layer.shadowOpacity = 0.1
        b.layer.shadowOffset = CGSize(width: 0, height: 3)
        b.layer.shadowRadius = 6
        return b
    }()

    private let titleLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .bold)
        l.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        return l
    }()

    private let postcardButton_Orna: UIButton = {
        let b = UIButton(type: .system)
        let cfg_orna = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(UIImage(systemName: "camera.fill", withConfiguration: cfg_orna), for: .normal)
        b.tintColor = .white
        b.backgroundColor = UIColor(hexstring_Orna: "#FF6B9D")
        b.layer.cornerRadius = 18
        return b
    }()

    private let addButton_Orna: UIButton = {
        let b = UIButton(type: .system)
        let cfg_orna = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(UIImage(systemName: "plus", withConfiguration: cfg_orna), for: .normal)
        b.tintColor = .white
        b.backgroundColor = UIColor(hexstring_Orna: "#7B61FF")
        b.layer.cornerRadius = 18
        return b
    }()

    // MARK: - UI · 画布

    private let canvasCardView_Orna: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 24
        v.layer.shadowColor = UIColor(hexstring_Orna: "#7B61FF").cgColor
        v.layer.shadowOpacity = 0.1
        v.layer.shadowOffset = CGSize(width: 0, height: 8)
        v.layer.shadowRadius = 16
        return v
    }()

    /// 画布本体（渲染截图的实际范围，圆角裁剪由外层卡片承担）
    private let canvasView_Orna: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 24
        v.clipsToBounds = true
        return v
    }()

    private var canvasGradientLayer_Orna: CAGradientLayer?

    private let hintLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "Tap + to add ornaments, notes or photo frames. Drag to arrange freely."
        l.font = .systemFont(ofSize: 12, weight: .regular)
        l.textColor = UIColor(hexstring_Orna: "#8B87A0")
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    /// 已摆放元素视图集合（key: itemId）
    private var itemViews_Orna: [Int: PlacedItemView_Orna] = [:]

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Orna: "#F6F3FF")
        setupUI_Orna()
        setupConstraints_Orna()
        setupActions_Orna()
        loadScene_Orna()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        canvasGradientLayer_Orna?.frame = canvasView_Orna.bounds
        repositionAllItems_Orna()
    }

    // MARK: - UI 搭建

    private func setupUI_Orna() {
        view.addSubview(backButton_Orna)
        view.addSubview(titleLabel_Orna)
        view.addSubview(postcardButton_Orna)
        view.addSubview(addButton_Orna)
        view.addSubview(canvasCardView_Orna)
        canvasCardView_Orna.addSubview(canvasView_Orna)
        view.addSubview(hintLabel_Orna)
    }

    private func setupConstraints_Orna() {
        backButton_Orna.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(36)
        }
        titleLabel_Orna.snp.makeConstraints {
            $0.centerY.equalTo(backButton_Orna)
            $0.centerX.equalToSuperview()
        }
        addButton_Orna.snp.makeConstraints {
            $0.centerY.equalTo(backButton_Orna)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.height.equalTo(36)
        }
        postcardButton_Orna.snp.makeConstraints {
            $0.centerY.equalTo(backButton_Orna)
            $0.trailing.equalTo(addButton_Orna.snp.leading).offset(-10)
            $0.width.height.equalTo(36)
        }
        canvasCardView_Orna.snp.makeConstraints {
            $0.top.equalTo(backButton_Orna.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(canvasCardView_Orna.snp.width).multipliedBy(1.0)
        }
        canvasView_Orna.snp.makeConstraints { $0.edges.equalToSuperview() }
        hintLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(canvasCardView_Orna.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(32)
        }
    }

    // MARK: - 事件绑定

    private func setupActions_Orna() {
        backButton_Orna.addTarget(self, action: #selector(handleBackTapped_Orna), for: .touchUpInside)
        addButton_Orna.addTarget(self, action: #selector(handleAddTapped_Orna), for: .touchUpInside)
        postcardButton_Orna.addTarget(self, action: #selector(handleSavePostcardTapped_Orna), for: .touchUpInside)
    }

    // MARK: - 数据加载

    /// 加载场景数据：渲染背景主题并重建全部已摆放元素视图
    private func loadScene_Orna() {
        guard let scene_orna = UserViewModel_Orna.shared_Orna.getDeskSceneById_Orna(sceneId_orna: sceneId_Orna) else {
            Navigation_Orna.pop_Orna(from: self)
            return
        }
        self.scene_Orna = scene_orna
        titleLabel_Orna.text = scene_orna.sceneName_Orna

        let colors_orna = scene_orna.theme_Orna.backgroundColorHexes_Orna
        let gradient_orna = CAGradientLayer()
        gradient_orna.colors = [UIColor(hexstring_Orna: colors_orna.0).cgColor, UIColor(hexstring_Orna: colors_orna.1).cgColor]
        gradient_orna.startPoint = CGPoint(x: 0, y: 0)
        gradient_orna.endPoint = CGPoint(x: 1, y: 1)
        canvasView_Orna.layer.insertSublayer(gradient_orna, at: 0)
        canvasGradientLayer_Orna = gradient_orna

        itemViews_Orna.values.forEach { $0.removeFromSuperview() }
        itemViews_Orna.removeAll()
        for item_orna in scene_orna.placedItems_Orna {
            addItemView_Orna(item_orna: item_orna)
        }
    }

    /// 创建并添加单个元素视图到画布，随后立即按最新画布尺寸定位
    private func addItemView_Orna(item_orna: PlacedItemModel_Orna) {
        let itemView_orna = PlacedItemView_Orna()
        configureItemView_Orna(itemView_orna: itemView_orna, item_orna: item_orna)
        itemView_orna.itemId_Orna = item_orna.itemId_Orna
        itemView_orna.onDeleteTapped_Orna = { [weak self] in
            self?.handleRemoveItemTapped_Orna(itemId_orna: item_orna.itemId_Orna)
        }

        let panGesture_orna = UIPanGestureRecognizer(target: self, action: #selector(handleItemPan_Orna(_:)))
        let pinchGesture_orna = UIPinchGestureRecognizer(target: self, action: #selector(handleItemPinch_Orna(_:)))
        panGesture_orna.delegate = self
        pinchGesture_orna.delegate = self
        itemView_orna.addGestureRecognizer(panGesture_orna)
        itemView_orna.addGestureRecognizer(pinchGesture_orna)

        canvasView_Orna.addSubview(itemView_orna)
        itemViews_Orna[item_orna.itemId_Orna] = itemView_orna
        positionItemView_Orna(itemView_orna: itemView_orna, item_orna: item_orna)
    }

    /// 按元素类型解析展示内容（图标 / 文字 / 图片），保持视图本身"只负责展示"
    private func configureItemView_Orna(itemView_orna: PlacedItemView_Orna, item_orna: PlacedItemModel_Orna) {
        switch item_orna.type_Orna {
        case .ornament_Orna:
            if item_orna.isMemoryOrnament_Orna,
               let memoryOrnament_orna = UserViewModel_Orna.shared_Orna.getMemoryOrnamentById_Orna(ornamentId_orna: item_orna.ornamentId_Orna ?? -1) {
                itemView_orna.configureAsOrnament_Orna(
                    icon_orna: memoryOrnament_orna.currentGrowthIcon_Orna,
                    colorHex_orna: memoryOrnament_orna.colorHex_Orna,
                    label_orna: memoryOrnament_orna.customName_Orna
                )
            } else if let ornament_orna = LocalData_Orna.shared_Orna.getOrnamentById_Orna(ornamentId_orna: item_orna.ornamentId_Orna ?? -1) {
                itemView_orna.configureAsOrnament_Orna(
                    icon_orna: ornament_orna.ornamentIcon_Orna,
                    colorHex_orna: ornament_orna.ornamentColorHex_Orna,
                    label_orna: ornament_orna.ornamentName_Orna
                )
            }
        case .note_Orna:
            itemView_orna.configureAsNote_Orna(
                text_orna: item_orna.noteText_Orna ?? "",
                colorHex_orna: item_orna.noteColorHex_Orna ?? Self.noteColorOptions_Orna[0]
            )
        case .photoFrame_Orna:
            itemView_orna.configureAsPhotoFrame_Orna(
                photoPath_orna: item_orna.photoPath_Orna,
                caption_orna: item_orna.photoCaption_Orna ?? ""
            )
        }
    }

    /// 按元素保存的相对坐标与缩放，换算为画布实际像素位置
    private func positionItemView_Orna(itemView_orna: PlacedItemView_Orna, item_orna: PlacedItemModel_Orna) {
        let canvasSize_orna = canvasView_Orna.bounds.size
        guard canvasSize_orna.width > 0, canvasSize_orna.height > 0 else { return }
        itemView_orna.center = CGPoint(
            x: CGFloat(item_orna.relativeX_Orna) * canvasSize_orna.width,
            y: CGFloat(item_orna.relativeY_Orna) * canvasSize_orna.height
        )
        itemView_orna.transform = CGAffineTransform(scaleX: CGFloat(item_orna.scale_Orna), y: CGFloat(item_orna.scale_Orna))
    }

    /// 画布尺寸变化（如屏幕旋转/首次布局）后，按已保存的相对坐标重新摆放全部元素
    private func repositionAllItems_Orna() {
        guard let scene_orna = scene_Orna else { return }
        for item_orna in scene_orna.placedItems_Orna {
            guard let itemView_orna = itemViews_Orna[item_orna.itemId_Orna] else { continue }
            positionItemView_Orna(itemView_orna: itemView_orna, item_orna: item_orna)
        }
    }

    // MARK: - 事件处理

    @objc private func handleBackTapped_Orna() {
        Navigation_Orna.pop_Orna(from: self)
    }

    /// 弹出"添加元素"操作面板
    @objc private func handleAddTapped_Orna() {
        let alert_orna = UIAlertController(title: "Add to Scene", message: nil, preferredStyle: .actionSheet)
        alert_orna.addAction(UIAlertAction(title: "🪴 Add Ornament", style: .default) { [weak self] _ in
            self?.showOrnamentPickerSheet_Orna()
        })
        alert_orna.addAction(UIAlertAction(title: "📝 Add Sticky Note", style: .default) { [weak self] _ in
            self?.showAddNoteAlert_Orna()
        })
        alert_orna.addAction(UIAlertAction(title: "🖼️ Add Photo Frame", style: .default) { [weak self] _ in
            self?.showAddPhotoFrameFlow_Orna()
        })
        alert_orna.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert_orna, animated: true)
    }

    /// 展示可摆放摆件选择列表（桌面图鉴摆件 + 记忆摆件）
    private func showOrnamentPickerSheet_Orna() {
        let ownedCollection_orna = UserViewModel_Orna.shared_Orna.getOwnedOrnaments_Orna()
        let memoryOrnaments_orna = UserViewModel_Orna.shared_Orna.getMemoryOrnaments_Orna()

        guard !ownedCollection_orna.isEmpty || !memoryOrnaments_orna.isEmpty else {
            Load_Orna.showInfo_Orna(message_Orna: "You don't have any ornaments to place yet. Check in daily or create a memory ornament first!")
            return
        }

        let alert_orna = UIAlertController(title: "Choose an Ornament", message: nil, preferredStyle: .actionSheet)
        for ornament_orna in ownedCollection_orna {
            alert_orna.addAction(UIAlertAction(title: "🪄 \(ornament_orna.ornamentName_Orna)", style: .default) { [weak self] _ in
                self?.addOrnamentToScene_Orna(ornamentId_orna: ornament_orna.ornamentId_Orna, isMemoryOrnament_orna: false)
            })
        }
        for ornament_orna in memoryOrnaments_orna {
            alert_orna.addAction(UIAlertAction(title: "🌱 \(ornament_orna.customName_Orna)", style: .default) { [weak self] _ in
                self?.addOrnamentToScene_Orna(ornamentId_orna: ornament_orna.ornamentId_Orna, isMemoryOrnament_orna: true)
            })
        }
        alert_orna.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert_orna, animated: true)
    }

    private func addOrnamentToScene_Orna(ornamentId_orna: Int, isMemoryOrnament_orna: Bool) {
        if let item_orna = UserViewModel_Orna.shared_Orna.addPlacedItem_Orna(
            sceneId_orna: sceneId_Orna,
            type_orna: .ornament_Orna,
            ornamentId_orna: ornamentId_orna,
            isMemoryOrnament_orna: isMemoryOrnament_orna
        ) {
            scene_Orna = UserViewModel_Orna.shared_Orna.getDeskSceneById_Orna(sceneId_orna: sceneId_Orna)
            addItemView_Orna(item_orna: item_orna)
        }
    }

    /// 弹出手写便签输入框
    private func showAddNoteAlert_Orna() {
        let alert_orna = UIAlertController(title: "Add a Sticky Note", message: "Write a short note to place on your desk", preferredStyle: .alert)
        alert_orna.addTextField { tf in tf.placeholder = "e.g. Best trip ever 🌊" }
        alert_orna.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert_orna.addAction(UIAlertAction(title: "Add", style: .default) { [weak self, weak alert_orna] _ in
            guard let self else { return }
            let text_orna = (alert_orna?.textFields?.first?.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text_orna.isEmpty else { return }
            let colorHex_orna = Self.noteColorOptions_Orna.randomElement() ?? Self.noteColorOptions_Orna[0]
            if let item_orna = UserViewModel_Orna.shared_Orna.addPlacedItem_Orna(
                sceneId_orna: self.sceneId_Orna, type_orna: .note_Orna, noteText_orna: text_orna, noteColorHex_orna: colorHex_orna
            ) {
                self.scene_Orna = UserViewModel_Orna.shared_Orna.getDeskSceneById_Orna(sceneId_orna: self.sceneId_Orna)
                self.addItemView_Orna(item_orna: item_orna)
            }
        })
        present(alert_orna, animated: true)
    }

    /// 选择照片并弹出配文输入框
    private func showAddPhotoFrameFlow_Orna() {
        MediaPickerHelper_Orna.pickImage_Orna(from: self) { [weak self] image_orna in
            guard let self, let image_orna else { return }
            let alert_orna = UIAlertController(title: "Add a Caption", message: "Optional caption for your mini photo frame", preferredStyle: .alert)
            alert_orna.addTextField { tf in tf.placeholder = "e.g. Sunset at the beach" }
            alert_orna.addAction(UIAlertAction(title: "Skip", style: .cancel) { [weak self, weak alert_orna] _ in
                self?.finishAddingPhotoFrame_Orna(image_orna: image_orna, caption_orna: alert_orna?.textFields?.first?.text ?? "")
            })
            alert_orna.addAction(UIAlertAction(title: "Add", style: .default) { [weak self, weak alert_orna] _ in
                self?.finishAddingPhotoFrame_Orna(image_orna: image_orna, caption_orna: alert_orna?.textFields?.first?.text ?? "")
            })
            self.present(alert_orna, animated: true)
        }
    }

    private func finishAddingPhotoFrame_Orna(image_orna: UIImage, caption_orna: String) {
        if let item_orna = UserViewModel_Orna.shared_Orna.addPlacedItem_Orna(
            sceneId_orna: sceneId_Orna, type_orna: .photoFrame_Orna, photoImage_orna: image_orna, photoCaption_orna: caption_orna
        ) {
            scene_Orna = UserViewModel_Orna.shared_Orna.getDeskSceneById_Orna(sceneId_orna: sceneId_Orna)
            addItemView_Orna(item_orna: item_orna)
        }
    }

    /// 移除元素二次确认
    private func handleRemoveItemTapped_Orna(itemId_orna: Int) {
        let alert_orna = UIAlertController(title: "Remove this item?", message: nil, preferredStyle: .actionSheet)
        alert_orna.addAction(UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
            guard let self else { return }
            UserViewModel_Orna.shared_Orna.removePlacedItem_Orna(sceneId_orna: self.sceneId_Orna, itemId_orna: itemId_orna)
            self.itemViews_Orna[itemId_orna]?.removeFromSuperview()
            self.itemViews_Orna.removeValue(forKey: itemId_orna)
            self.scene_Orna = UserViewModel_Orna.shared_Orna.getDeskSceneById_Orna(sceneId_orna: self.sceneId_Orna)
        })
        alert_orna.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert_orna, animated: true)
    }

    /// 拖拽手势：自由移动元素位置，手势结束后回写相对坐标
    @objc private func handleItemPan_Orna(_ gesture_orna: UIPanGestureRecognizer) {
        guard let itemView_orna = gesture_orna.view as? PlacedItemView_Orna else { return }
        let translation_orna = gesture_orna.translation(in: canvasView_Orna)
        itemView_orna.center = CGPoint(
            x: itemView_orna.center.x + translation_orna.x,
            y: itemView_orna.center.y + translation_orna.y
        )
        gesture_orna.setTranslation(.zero, in: canvasView_Orna)

        if gesture_orna.state == .ended || gesture_orna.state == .cancelled {
            persistItemTransform_Orna(itemView_orna: itemView_orna)
        }
    }

    /// 捏合手势：自由缩放元素大小，手势结束后回写缩放比例
    @objc private func handleItemPinch_Orna(_ gesture_orna: UIPinchGestureRecognizer) {
        guard let itemView_orna = gesture_orna.view as? PlacedItemView_Orna else { return }
        let currentScale_orna = sqrt(abs(itemView_orna.transform.a * itemView_orna.transform.d))
        let proposedScale_orna = currentScale_orna * gesture_orna.scale
        let clampedScale_orna = min(max(proposedScale_orna, 0.5), 2.0)
        itemView_orna.transform = CGAffineTransform(scaleX: clampedScale_orna, y: clampedScale_orna)
        gesture_orna.scale = 1.0

        if gesture_orna.state == .ended || gesture_orna.state == .cancelled {
            persistItemTransform_Orna(itemView_orna: itemView_orna)
        }
    }

    /// 将元素当前位置与缩放比例换算为相对坐标并回写持久状态
    private func persistItemTransform_Orna(itemView_orna: PlacedItemView_Orna) {
        let canvasSize_orna = canvasView_Orna.bounds.size
        guard canvasSize_orna.width > 0, canvasSize_orna.height > 0 else { return }
        let relativeX_orna = Double(itemView_orna.center.x / canvasSize_orna.width)
        let relativeY_orna = Double(itemView_orna.center.y / canvasSize_orna.height)
        let scale_orna = Double(sqrt(abs(itemView_orna.transform.a * itemView_orna.transform.d)))
        UserViewModel_Orna.shared_Orna.updatePlacedItemTransform_Orna(
            sceneId_orna: sceneId_Orna,
            itemId_orna: itemView_orna.itemId_Orna,
            relativeX_orna: relativeX_orna,
            relativeY_orna: relativeY_orna,
            scale_orna: scale_orna
        )
    }

    /// 将画布渲染为图片并保存至系统相册，作为"纪念明信片"
    @objc private func handleSavePostcardTapped_Orna() {
        itemViews_Orna.values.forEach { $0.setDeleteButtonHidden_Orna(true) }

        let renderer_orna = UIGraphicsImageRenderer(bounds: canvasView_Orna.bounds)
        let postcardImage_orna = renderer_orna.image { _ in
            canvasView_Orna.drawHierarchy(in: canvasView_Orna.bounds, afterScreenUpdates: true)
        }

        itemViews_Orna.values.forEach { $0.setDeleteButtonHidden_Orna(false) }

        UIImageWriteToSavedPhotosAlbum(postcardImage_orna, self, #selector(handlePostcardSaveCompletion_Orna(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    /// 明信片保存完成回调
    @objc private func handlePostcardSaveCompletion_Orna(_ image_orna: UIImage, didFinishSavingWithError error_orna: Error?, contextInfo: UnsafeRawPointer) {
        if error_orna != nil {
            Load_Orna.showError_Orna(message_Orna: "Couldn't save postcard. Please allow photo access in Settings.")
        } else {
            Load_Orna.showSuccess_Orna(message_Orna: "Postcard saved to your Photos! 💌")
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension DeskSceneEditor_Orna: UIGestureRecognizerDelegate {
    /// 允许同一元素上的拖拽与缩放手势同时识别，实现自然的"边拖边捏"摆放体验
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}

// MARK: - 场景元素视图

/// 场景元素视图
/// 核心作用：纯展示型视图，按类型呈现摆件圆形图标 / 便签卡片 / 迷你相框，
///           自身不包含任何业务逻辑，拖拽与持久化均由 DeskSceneEditor_Orna 统一处理
class PlacedItemView_Orna: UIView {

    /// 元素ID，用于手势结束后回传给控制器定位需要持久化的数据
    var itemId_Orna: Int = -1

    /// 删除按钮点击回调
    var onDeleteTapped_Orna: (() -> Void)?

    private let deleteButton_Orna: UIButton = {
        let b = UIButton(type: .system)
        let cfg_orna = UIImage.SymbolConfiguration(pointSize: 9, weight: .bold)
        b.setImage(UIImage(systemName: "xmark", withConfiguration: cfg_orna), for: .normal)
        b.tintColor = .white
        b.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        b.layer.cornerRadius = 9
        return b
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(deleteButton_Orna)
        deleteButton_Orna.addTarget(self, action: #selector(handleDeleteTapped_Orna), for: .touchUpInside)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// 配置为摆件展示形态：圆形图标徽标 + 下方名称
    func configureAsOrnament_Orna(icon_orna: String, colorHex_orna: String, label_orna: String) {
        subviews.filter { $0 != deleteButton_Orna }.forEach { $0.removeFromSuperview() }
        bounds = CGRect(x: 0, y: 0, width: 64, height: 78)

        let circleView_orna = UIView()
        circleView_orna.backgroundColor = UIColor(hexstring_Orna: colorHex_orna).withAlphaComponent(0.85)
        circleView_orna.layer.cornerRadius = 26
        circleView_orna.layer.shadowColor = UIColor.black.cgColor
        circleView_orna.layer.shadowOpacity = 0.15
        circleView_orna.layer.shadowOffset = CGSize(width: 0, height: 3)
        circleView_orna.layer.shadowRadius = 4

        let iconView_orna = UIImageView(image: UIImage(systemName: icon_orna))
        iconView_orna.tintColor = .white
        iconView_orna.contentMode = .scaleAspectFit

        let nameLabel_orna = UILabel()
        nameLabel_orna.text = label_orna
        nameLabel_orna.font = .systemFont(ofSize: 10, weight: .semibold)
        nameLabel_orna.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        nameLabel_orna.textAlignment = .center
        nameLabel_orna.numberOfLines = 1

        addSubview(circleView_orna)
        circleView_orna.addSubview(iconView_orna)
        addSubview(nameLabel_orna)
        bringSubviewToFront(deleteButton_Orna)

        circleView_orna.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
            $0.width.height.equalTo(52)
        }
        iconView_orna.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        nameLabel_orna.snp.makeConstraints {
            $0.top.equalTo(circleView_orna.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview()
        }
        layoutDeleteButton_Orna()
    }

    /// 配置为手写便签展示形态：彩色卡片 + 手写风格文字
    func configureAsNote_Orna(text_orna: String, colorHex_orna: String) {
        subviews.filter { $0 != deleteButton_Orna }.forEach { $0.removeFromSuperview() }
        bounds = CGRect(x: 0, y: 0, width: 96, height: 96)

        let cardView_orna = UIView()
        cardView_orna.backgroundColor = UIColor(hexstring_Orna: colorHex_orna)
        cardView_orna.layer.cornerRadius = 6
        cardView_orna.layer.shadowColor = UIColor.black.cgColor
        cardView_orna.layer.shadowOpacity = 0.2
        cardView_orna.layer.shadowOffset = CGSize(width: 2, height: 3)
        cardView_orna.layer.shadowRadius = 4

        let textLabel_orna = UILabel()
        textLabel_orna.text = text_orna
        textLabel_orna.font = .systemFont(ofSize: 12, weight: .medium)
        textLabel_orna.textColor = UIColor(hexstring_Orna: "#4A4A4A")
        textLabel_orna.numberOfLines = 4
        textLabel_orna.textAlignment = .center

        addSubview(cardView_orna)
        cardView_orna.addSubview(textLabel_orna)
        addSubview(deleteButton_Orna)

        cardView_orna.snp.makeConstraints { $0.edges.equalToSuperview() }
        textLabel_orna.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(10)
        }
        layoutDeleteButton_Orna()
    }

    /// 配置为迷你相框展示形态：白色相框边框 + 照片 + 手写配文
    func configureAsPhotoFrame_Orna(photoPath_orna: String?, caption_orna: String) {
        subviews.filter { $0 != deleteButton_Orna }.forEach { $0.removeFromSuperview() }
        bounds = CGRect(x: 0, y: 0, width: 90, height: 108)

        let frameView_orna = UIView()
        frameView_orna.backgroundColor = .white
        frameView_orna.layer.cornerRadius = 6
        frameView_orna.layer.shadowColor = UIColor.black.cgColor
        frameView_orna.layer.shadowOpacity = 0.2
        frameView_orna.layer.shadowOffset = CGSize(width: 2, height: 3)
        frameView_orna.layer.shadowRadius = 4

        let photoView_orna = MediaDisplayView_Orna()
        photoView_orna.layer.cornerRadius = 2
        photoView_orna.showsBuiltInPlaceholder_Orna = false
        photoView_orna.configure_Orna(mediaPath_Orna: photoPath_orna)

        let captionLabel_orna = UILabel()
        captionLabel_orna.text = caption_orna.isEmpty ? " " : caption_orna
        captionLabel_orna.font = .systemFont(ofSize: 9, weight: .medium)
        captionLabel_orna.textColor = UIColor(hexstring_Orna: "#4A4A4A")
        captionLabel_orna.textAlignment = .center
        captionLabel_orna.numberOfLines = 1

        addSubview(frameView_orna)
        frameView_orna.addSubview(photoView_orna)
        frameView_orna.addSubview(captionLabel_orna)
        addSubview(deleteButton_Orna)

        frameView_orna.snp.makeConstraints { $0.edges.equalToSuperview() }
        photoView_orna.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(6)
            $0.height.equalTo(76)
        }
        captionLabel_orna.snp.makeConstraints {
            $0.top.equalTo(photoView_orna.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(4)
        }
        layoutDeleteButton_Orna()
    }

    private func layoutDeleteButton_Orna() {
        deleteButton_Orna.snp.remakeConstraints {
            $0.top.equalToSuperview().offset(-6)
            $0.trailing.equalToSuperview().offset(6)
            $0.width.height.equalTo(18)
        }
        bringSubviewToFront(deleteButton_Orna)
    }

    /// 控制删除徽标显隐（导出明信片截图前隐藏，避免出现在成片中）
    func setDeleteButtonHidden_Orna(_ hidden: Bool) {
        deleteButton_Orna.isHidden = hidden
    }

    @objc private func handleDeleteTapped_Orna() { onDeleteTapped_Orna?() }
}
