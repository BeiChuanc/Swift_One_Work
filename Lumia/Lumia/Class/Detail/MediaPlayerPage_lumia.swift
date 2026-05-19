import UIKit
import SnapKit
import Kingfisher
import AVFoundation

// MARK: - 全屏媒体浏览页

/// 全屏媒体浏览页
/// 核心作用：
///   - 图片模式：以沉浸式黑底全屏展示，支持双指缩放、双击放大/还原、下滑关闭
///   - 视频模式：通过 AVPlayer 播放 Bundle / Documents / 网络视频，支持播放/暂停、进度条、下滑关闭
/// 设计思路：
///   - 媒体路径与 MediaDisplayView_Lumia 加载策略完全对齐（Bundle → Documents → 网络）
///   - 顶部半透明导航条（关闭按钮 + 媒体类型标签）
///   - 背景 alpha 跟随下拉手势动态变化，松手回弹或关闭
/// 关键属性：
///   - mediaPath_Lumia:  媒体路径（支持 Assets / 网络 / Documents / Bundle 视频）
///   - isVideo_Lumia:    是否强制为视频模式（传 false 时由加载器自动检测）
class MediaPlayerPage_Lumia: UIViewController {

    // MARK: - 对外属性

    /// 媒体路径（支持 Assets 名 / https URL / Documents 文件名 / Bundle 资源名）
    var mediaPath_Lumia: String?

    /// 是否强制当作视频处理（false 时由加载流程自动检测）
    var isVideo_Lumia: Bool = false

    // MARK: - 私有属性

    /// 当前实际媒体类型（加载后确定）
    private var resolvedType_Lumia: MediaType_Lumia = .none_Lumia

    /// 下拉关闭时记录的起始偏移
    private var isDismissing_Lumia = false
    /// 图片原始尺寸（缩放布局用）
    private var imageSize_Lumia: CGSize = .zero

    // MARK: - AVPlayer（视频）

    private var player_Lumia: AVPlayer?
    private var playerLayer_Lumia: AVPlayerLayer?
    /// 视频进度观察者令牌
    private var timeObserverToken_Lumia: Any?
    /// 是否处于播放状态
    private var isPlaying_Lumia = false

    // MARK: - UI：黑色背景

    private let backgroundView_Lumia: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        return v
    }()

    // MARK: - UI：图片模式

    private let scrollView_Lumia: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator   = false
        sv.showsHorizontalScrollIndicator = false
        sv.contentInsetAdjustmentBehavior = .never
        sv.bouncesZoom      = true
        sv.minimumZoomScale = 1.0
        sv.maximumZoomScale = 4.0
        sv.backgroundColor  = .clear
        return sv
    }()

    private let imageView_Lumia: UIImageView = {
        let iv = UIImageView()
        iv.contentMode   = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .clear
        return iv
    }()

    // MARK: - UI：视频模式

    /// 视频渲染容器（AVPlayerLayer 附着此 View）
    private let videoContainerView_Lumia: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        v.isHidden        = true
        return v
    }()

    /// 播放/暂停中央大按钮（覆盖在视频上）
    private let playPauseButton_Lumia: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Lumia = UIImage.SymbolConfiguration(pointSize: 36, weight: .bold)
        b.setImage(UIImage(systemName: "play.circle.fill",  withConfiguration: cfg_Lumia), for: .normal)
        b.setImage(UIImage(systemName: "pause.circle.fill", withConfiguration: cfg_Lumia), for: .selected)
        b.tintColor       = .white
        b.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        b.layer.cornerRadius = 40
        b.alpha = 0   // 初始隐藏，加载完成后淡入
        return b
    }()

    /// 底部进度条背景
    private let progressBg_Lumia: UIView = {
        let v = UIView()
        v.backgroundColor    = UIColor.white.withAlphaComponent(0.25)
        v.layer.cornerRadius = 2
        v.isHidden           = true
        return v
    }()

    /// 底部进度条前景
    private let progressFill_Lumia: UIView = {
        let v = UIView()
        v.backgroundColor    = .white
        v.layer.cornerRadius = 2
        return v
    }()

    /// 进度条宽度约束（实时更新）
    private var progressWidthCon_Lumia: Constraint?

    // MARK: - UI：共用

    private let loadingIndicator_Lumia: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = .white
        ai.hidesWhenStopped = true
        return ai
    }()

    private let topBar_Lumia: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        return v
    }()

    private let closeButton_Lumia: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Lumia = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        b.setImage(UIImage(systemName: "xmark", withConfiguration: cfg_Lumia), for: .normal)
        b.tintColor          = .white
        b.backgroundColor    = UIColor.white.withAlphaComponent(0.15)
        b.layer.cornerRadius = 18
        b.layer.borderWidth  = 1
        b.layer.borderColor  = UIColor.white.withAlphaComponent(0.25).cgColor
        return b
    }()

    private let mediaTypeLabel_Lumia: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor     = UIColor.white.withAlphaComponent(0.75)
        l.textAlignment = .center
        return l
    }()

    private let bottomHint_Lumia: UILabel = {
        let l = UILabel()
        l.text          = "Swipe down to close"
        l.font          = .systemFont(ofSize: 11, weight: .regular)
        l.textColor     = UIColor.white.withAlphaComponent(0.45)
        l.textAlignment = .center
        return l
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI_Lumia()
        buildConstraints_Lumia()
        bindGestures_Lumia()
        loadMedia_Lumia()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 进场前预设透明，由 viewDidAppear 统一淡入，避免与系统转场动画叠加导致闪烁
        view.alpha = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.25) { self.view.alpha = 1 }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cleanupPlayer_Lumia()
    }

    deinit {
        cleanupPlayer_Lumia()
    }

    // MARK: - UI 搭建

    private func buildUI_Lumia() {
        view.backgroundColor = .black

        view.addSubview(backgroundView_Lumia)

        // 图片容器
        view.addSubview(scrollView_Lumia)
        scrollView_Lumia.addSubview(imageView_Lumia)
        scrollView_Lumia.delegate = self

        // 视频容器
        view.addSubview(videoContainerView_Lumia)
        videoContainerView_Lumia.addSubview(playPauseButton_Lumia)
        videoContainerView_Lumia.addSubview(progressBg_Lumia)
        progressBg_Lumia.addSubview(progressFill_Lumia)

        // 通用
        view.addSubview(loadingIndicator_Lumia)
        view.addSubview(topBar_Lumia)
        topBar_Lumia.addSubview(closeButton_Lumia)
        topBar_Lumia.addSubview(mediaTypeLabel_Lumia)
        view.addSubview(bottomHint_Lumia)
    }

    private func buildConstraints_Lumia() {
        backgroundView_Lumia.snp.makeConstraints { $0.edges.equalToSuperview() }
        scrollView_Lumia.snp.makeConstraints     { $0.edges.equalToSuperview() }
        imageView_Lumia.frame = view.bounds

        videoContainerView_Lumia.snp.makeConstraints { $0.edges.equalToSuperview() }
        playPauseButton_Lumia.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(80)
        }

        progressBg_Lumia.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(60)
            $0.height.equalTo(4)
        }
        progressFill_Lumia.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            progressWidthCon_Lumia = $0.width.equalTo(0).constraint
        }

        loadingIndicator_Lumia.snp.makeConstraints { $0.center.equalToSuperview() }

        topBar_Lumia.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        closeButton_Lumia.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(12)
            $0.width.height.equalTo(36)
        }
        mediaTypeLabel_Lumia.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(14)
        }
        bottomHint_Lumia.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topBar_Lumia.snp.updateConstraints {
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        playerLayer_Lumia?.frame = videoContainerView_Lumia.bounds
        updateImageLayout_Lumia()
    }

    // MARK: - 手势

    private func bindGestures_Lumia() {
        // 双击缩放（图片）
        let doubleTap_Lumia = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap_Lumia(_:)))
        doubleTap_Lumia.numberOfTapsRequired = 2
        scrollView_Lumia.addGestureRecognizer(doubleTap_Lumia)

        // 单击关闭 / 视频播放切换
        let singleTap_Lumia = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap_Lumia))
        singleTap_Lumia.numberOfTapsRequired = 1
        singleTap_Lumia.require(toFail: doubleTap_Lumia)
        scrollView_Lumia.addGestureRecognizer(singleTap_Lumia)

        // 视频区单击切换播放/暂停
        let videoTap_Lumia = UITapGestureRecognizer(target: self, action: #selector(handleVideoTap_Lumia))
        videoContainerView_Lumia.addGestureRecognizer(videoTap_Lumia)

        // 下滑关闭
        let pan_Lumia = UIPanGestureRecognizer(target: self, action: #selector(handlePan_Lumia(_:)))
        pan_Lumia.delegate = self
        view.addGestureRecognizer(pan_Lumia)

        // 播放/暂停按钮
        playPauseButton_Lumia.addTarget(self, action: #selector(togglePlayPause_Lumia), for: .touchUpInside)
        closeButton_Lumia.addTarget(self, action: #selector(closeTapped_Lumia), for: .touchUpInside)
    }

    // MARK: - 媒体加载

    /// 根据 mediaPath_Lumia 和 isVideo_Lumia 加载媒体
    private func loadMedia_Lumia() {
        guard let path_Lumia = mediaPath_Lumia, !path_Lumia.isEmpty else { showEmpty_Lumia(); return }
        loadingIndicator_Lumia.startAnimating()

        // 若外部明确为视频，或路径在 Bundle 中找到视频文件 → 进入视频流程
        if isVideo_Lumia, let url_Lumia = resolveVideoURL_Lumia(path_Lumia) {
            setupVideoPlayer_Lumia(url_Lumia: url_Lumia)
            return
        }
        // 自动检测：先查 Bundle 视频
        if let url_Lumia = resolveVideoURL_Lumia(path_Lumia) {
            setupVideoPlayer_Lumia(url_Lumia: url_Lumia)
            return
        }

        // 图片加载流程
        resolvedType_Lumia = .image_Lumia
        loadImage_Lumia(path_Lumia: path_Lumia)
    }

    /// 解析路径对应的视频 URL（Bundle / Documents / 网络）
    /// - Parameter path_Lumia: 媒体路径或名称
    /// - Returns: 找到时返回 URL，否则返回 nil
    private func resolveVideoURL_Lumia(_ path_Lumia: String) -> URL? {
        // Bundle 资源
        if let url_Lumia = MediaDisplayView_Lumia.bundleVideoURL_Lumia(named: path_Lumia) {
            return url_Lumia
        }
        // Documents 目录视频文件
        let docs_Lumia = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        for ext_Lumia in ["mp4", "mov", "m4v"] {
            let url_Lumia = docs_Lumia.appendingPathComponent("\(path_Lumia).\(ext_Lumia)")
            if FileManager.default.fileExists(atPath: url_Lumia.path) { return url_Lumia }
        }
        // 已带扩展名的文档目录文件
        let direct_Lumia = docs_Lumia.appendingPathComponent(path_Lumia)
        if FileManager.default.fileExists(atPath: direct_Lumia.path) { return direct_Lumia }
        // 网络视频 URL
        if (path_Lumia.hasPrefix("http://") || path_Lumia.hasPrefix("https://")),
           let url_Lumia = URL(string: path_Lumia) {
            let ext_Lumia = (path_Lumia as NSString).pathExtension.lowercased()
            if ["mp4", "mov", "m4v", "m3u8"].contains(ext_Lumia) { return url_Lumia }
        }
        return nil
    }

    /// 加载图片（与 MediaDisplayView_Lumia 策略对齐）
    /// - Parameter path_Lumia: 媒体路径
    private func loadImage_Lumia(path_Lumia: String) {
        // SF Symbols
        if let img_Lumia = UIImage(systemName: path_Lumia) { applyImage_Lumia(img_Lumia); return }
        // Assets
        if let img_Lumia = UIImage(named: path_Lumia) { applyImage_Lumia(img_Lumia); return }
        // 网络
        if path_Lumia.hasPrefix("http://") || path_Lumia.hasPrefix("https://") {
            guard let url_Lumia = URL(string: path_Lumia) else { showEmpty_Lumia(); return }
            imageView_Lumia.kf.setImage(with: url_Lumia, options: [.transition(.fade(0.3))]) { [weak self] result in
                self?.loadingIndicator_Lumia.stopAnimating()
                if case .success(let v_Lumia) = result { self?.onImageLoaded_Lumia(v_Lumia.image) }
                else { self?.showEmpty_Lumia() }
            }
            return
        }
        // Documents 文件名
        let docs_Lumia = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let docURL_Lumia = docs_Lumia.appendingPathComponent(path_Lumia)
        if let img_Lumia = UIImage(contentsOfFile: docURL_Lumia.path) { applyImage_Lumia(img_Lumia); return }
        // 完整路径
        if let img_Lumia = UIImage(contentsOfFile: path_Lumia) { applyImage_Lumia(img_Lumia); return }
        showEmpty_Lumia()
    }

    // MARK: - 视频播放器

    /// 初始化并启动 AVPlayer
    /// - Parameter url_Lumia: 视频文件 URL
    private func setupVideoPlayer_Lumia(url_Lumia: URL) {
        resolvedType_Lumia = .video_Lumia

        // 切换到视频容器
        scrollView_Lumia.isHidden         = true
        videoContainerView_Lumia.isHidden = false
        progressBg_Lumia.isHidden         = false

        mediaTypeLabel_Lumia.text = "Video"

        let player_Lumia  = AVPlayer(url: url_Lumia)
        self.player_Lumia = player_Lumia
        let layer_Lumia   = AVPlayerLayer(player: player_Lumia)
        layer_Lumia.videoGravity  = .resizeAspect
        layer_Lumia.frame         = videoContainerView_Lumia.bounds
        layer_Lumia.backgroundColor = UIColor.black.cgColor
        videoContainerView_Lumia.layer.insertSublayer(layer_Lumia, at: 0)
        playerLayer_Lumia = layer_Lumia

        // 视频就绪后淡入播放按钮
        player_Lumia.addObserver(self, forKeyPath: "status", options: [.new], context: nil)

        // 进度更新（每 0.1 秒）
        let interval_Lumia = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserverToken_Lumia = player_Lumia.addPeriodicTimeObserver(
            forInterval: interval_Lumia,
            queue: .main
        ) { [weak self] time_Lumia in
            self?.updateProgress_Lumia(currentTime_Lumia: time_Lumia)
        }

        // 播放完毕回到开头
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinish_Lumia),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player_Lumia.currentItem
        )

        loadingIndicator_Lumia.stopAnimating()
        player_Lumia.play()
        isPlaying_Lumia = true
        playPauseButton_Lumia.isSelected = true
        UIView.animate(withDuration: 0.3) { self.playPauseButton_Lumia.alpha = 1 }
    }

    /// 更新底部进度条
    /// - Parameter currentTime_Lumia: AVPlayer 当前时间
    private func updateProgress_Lumia(currentTime_Lumia: CMTime) {
        guard let duration_Lumia = player_Lumia?.currentItem?.duration,
              duration_Lumia.isNumeric, duration_Lumia.seconds > 0 else { return }
        let progress_Lumia = CGFloat(currentTime_Lumia.seconds / duration_Lumia.seconds)
        let totalW_Lumia   = progressBg_Lumia.bounds.width
        progressWidthCon_Lumia?.update(offset: totalW_Lumia * min(max(progress_Lumia, 0), 1))
    }

    /// 播放结束时回到开头并切换按钮状态
    @objc private func playerDidFinish_Lumia() {
        player_Lumia?.seek(to: .zero)
        isPlaying_Lumia = false
        playPauseButton_Lumia.isSelected = false
        progressWidthCon_Lumia?.update(offset: 0)
    }

    /// 清理 AVPlayer 资源（防止内存泄漏）
    private func cleanupPlayer_Lumia() {
        if let token_Lumia = timeObserverToken_Lumia {
            player_Lumia?.removeTimeObserver(token_Lumia)
            timeObserverToken_Lumia = nil
        }
        player_Lumia?.removeObserver(self, forKeyPath: "status")
        player_Lumia?.pause()
        player_Lumia = nil
        playerLayer_Lumia?.removeFromSuperlayer()
        playerLayer_Lumia = nil
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard keyPath == "status",
              let player_Lumia = object as? AVPlayer,
              player_Lumia.status == .failed else { return }
        DispatchQueue.main.async { self.showEmpty_Lumia() }
    }

    // MARK: - 图片辅助

    private func applyImage_Lumia(_ image_Lumia: UIImage) {
        loadingIndicator_Lumia.stopAnimating()
        imageView_Lumia.image = image_Lumia
        imageSize_Lumia       = image_Lumia.size
        mediaTypeLabel_Lumia.text = "Photo"
        updateImageLayout_Lumia()
    }

    private func onImageLoaded_Lumia(_ image_Lumia: UIImage) {
        imageSize_Lumia = image_Lumia.size
        mediaTypeLabel_Lumia.text = "Photo"
        updateImageLayout_Lumia()
    }

    private func showEmpty_Lumia() {
        loadingIndicator_Lumia.stopAnimating()
        imageView_Lumia.image       = UIImage(systemName: "photo.slash")
        imageView_Lumia.tintColor   = UIColor.white.withAlphaComponent(0.4)
        imageView_Lumia.contentMode = .center
    }

    private func updateImageLayout_Lumia() {
        guard imageSize_Lumia != .zero else {
            imageView_Lumia.frame = view.bounds
            scrollView_Lumia.contentSize = view.bounds.size
            return
        }
        let screenW_Lumia = view.bounds.width
        let screenH_Lumia = view.bounds.height
        let ratio_Lumia   = imageSize_Lumia.height / imageSize_Lumia.width
        let imgH_Lumia    = screenW_Lumia * ratio_Lumia
        let y_Lumia       = max(0, (screenH_Lumia - imgH_Lumia) / 2)
        imageView_Lumia.frame        = CGRect(x: 0, y: y_Lumia, width: screenW_Lumia, height: imgH_Lumia)
        scrollView_Lumia.contentSize = CGSize(width: screenW_Lumia,
                                              height: max(imgH_Lumia + y_Lumia * 2, screenH_Lumia))
        scrollView_Lumia.zoomScale   = 1.0
        centerImageIfNeeded_Lumia()
    }

    private func centerImageIfNeeded_Lumia() {
        let offX_Lumia = max(0, (scrollView_Lumia.bounds.width  - scrollView_Lumia.contentSize.width)  / 2)
        let offY_Lumia = max(0, (scrollView_Lumia.bounds.height - scrollView_Lumia.contentSize.height) / 2)
        imageView_Lumia.center = CGPoint(
            x: scrollView_Lumia.contentSize.width  / 2 + offX_Lumia,
            y: scrollView_Lumia.contentSize.height / 2 + offY_Lumia
        )
    }

    // MARK: - 手势响应

    @objc private func handleDoubleTap_Lumia(_ gesture_Lumia: UITapGestureRecognizer) {
        guard resolvedType_Lumia == .image_Lumia else { return }
        if scrollView_Lumia.zoomScale > 1.0 {
            scrollView_Lumia.setZoomScale(1.0, animated: true)
        } else {
            let pt_Lumia    = gesture_Lumia.location(in: imageView_Lumia)
            let rect_Lumia  = zoomRect_Lumia(scale_Lumia: 2.5, center_Lumia: pt_Lumia)
            scrollView_Lumia.zoom(to: rect_Lumia, animated: true)
        }
    }

    @objc private func handleSingleTap_Lumia() {
        guard resolvedType_Lumia != .video_Lumia,
              scrollView_Lumia.zoomScale <= 1.01 else { return }
        dismissPage_Lumia(velocity_Lumia: 0)
    }

    /// 视频区点击：切换播放/暂停
    @objc private func handleVideoTap_Lumia() {
        togglePlayPause_Lumia()
    }

    /// 播放/暂停切换
    @objc private func togglePlayPause_Lumia() {
        guard let player_Lumia = player_Lumia else { return }
        if isPlaying_Lumia {
            player_Lumia.pause()
            isPlaying_Lumia = false
            playPauseButton_Lumia.isSelected = false
        } else {
            player_Lumia.play()
            isPlaying_Lumia = true
            playPauseButton_Lumia.isSelected = true
        }
        // 短暂显示后淡出按钮
        UIView.animate(withDuration: 0.2) { self.playPauseButton_Lumia.alpha = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            guard self.isPlaying_Lumia else { return }
            UIView.animate(withDuration: 0.4) { self.playPauseButton_Lumia.alpha = 0.2 }
        }
    }

    @objc private func closeTapped_Lumia() {
        dismissPage_Lumia(velocity_Lumia: 0)
    }

    @objc private func handlePan_Lumia(_ gesture_Lumia: UIPanGestureRecognizer) {
        guard scrollView_Lumia.zoomScale <= 1.01 else { return }
        let translation_Lumia = gesture_Lumia.translation(in: view)
        let velocity_Lumia    = gesture_Lumia.velocity(in: view).y
        switch gesture_Lumia.state {
        case .changed:
            let progress_Lumia         = max(0, translation_Lumia.y / view.bounds.height)
            backgroundView_Lumia.alpha = max(0, 1 - progress_Lumia * 1.5)
            topBar_Lumia.alpha         = max(0, 1 - progress_Lumia * 2)
            bottomHint_Lumia.alpha     = max(0, 1 - progress_Lumia * 2)
            let activeView_Lumia: UIView = resolvedType_Lumia == .video_Lumia
                ? videoContainerView_Lumia : scrollView_Lumia
            activeView_Lumia.transform = CGAffineTransform(
                translationX: translation_Lumia.x * 0.3,
                y: max(0, translation_Lumia.y)
            )
        case .ended, .cancelled:
            let shouldDismiss_Lumia = translation_Lumia.y > view.bounds.height * 0.25 || velocity_Lumia > 900
            if shouldDismiss_Lumia {
                dismissPage_Lumia(velocity_Lumia: velocity_Lumia)
            } else {
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               usingSpringWithDamping: 0.85,
                               initialSpringVelocity: 0.5) {
                    self.scrollView_Lumia.transform         = .identity
                    self.videoContainerView_Lumia.transform = .identity
                    self.backgroundView_Lumia.alpha  = 1
                    self.topBar_Lumia.alpha           = 1
                    self.bottomHint_Lumia.alpha       = 1
                }
            }
        default: break
        }
    }

    // MARK: - 关闭页面

    /// 执行关闭动画并 dismiss（暂停视频）
    /// - Parameter velocity_Lumia: 下拉速度（影响动画时长）
    private func dismissPage_Lumia(velocity_Lumia: CGFloat) {
        guard !isDismissing_Lumia else { return }
        isDismissing_Lumia = true
        player_Lumia?.pause()
        let duration_Lumia = velocity_Lumia > 1200 ? 0.2 : 0.3
        UIView.animate(withDuration: duration_Lumia, animations: {
            self.view.alpha = 0
            let activeView_Lumia: UIView = self.resolvedType_Lumia == .video_Lumia
                ? self.videoContainerView_Lumia : self.scrollView_Lumia
            activeView_Lumia.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
        }) { _ in
            self.dismiss(animated: false)
        }
    }

    // MARK: - 工具

    private func zoomRect_Lumia(scale_Lumia: CGFloat, center_Lumia: CGPoint) -> CGRect {
        let w_Lumia = scrollView_Lumia.bounds.width  / scale_Lumia
        let h_Lumia = scrollView_Lumia.bounds.height / scale_Lumia
        return CGRect(x: center_Lumia.x - w_Lumia / 2,
                      y: center_Lumia.y - h_Lumia / 2,
                      width: w_Lumia, height: h_Lumia)
    }
}

// MARK: - UIScrollViewDelegate（图片缩放）

extension MediaPlayerPage_Lumia: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView_Lumia }
    func scrollViewDidZoom(_ scrollView: UIScrollView) { centerImageIfNeeded_Lumia() }
}

// MARK: - UIGestureRecognizerDelegate（下拉与缩放共存）

extension MediaPlayerPage_Lumia: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan_Lumia = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        guard scrollView_Lumia.zoomScale <= 1.01 else { return false }
        let vel_Lumia = pan_Lumia.velocity(in: view)
        return abs(vel_Lumia.y) > abs(vel_Lumia.x) && vel_Lumia.y > 0
    }
}
