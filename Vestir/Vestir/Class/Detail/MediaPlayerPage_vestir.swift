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
///   - 媒体路径与 MediaDisplayView_Vestir 加载策略完全对齐（Bundle → Documents → 网络）
///   - 顶部半透明导航条（关闭按钮 + 媒体类型标签）
///   - 背景 alpha 跟随下拉手势动态变化，松手回弹或关闭
/// 关键属性：
///   - mediaPath_Vestir:  媒体路径（支持 Assets / 网络 / Documents / Bundle 视频）
///   - isVideo_Vestir:    是否强制为视频模式（传 false 时由加载器自动检测）
class MediaPlayerPage_Vestir: UIViewController {

    // MARK: - 对外属性

    /// 媒体路径（支持 Assets 名 / https URL / Documents 文件名 / Bundle 资源名）
    var mediaPath_Vestir: String?

    /// 是否强制当作视频处理（false 时由加载流程自动检测）
    var isVideo_Vestir: Bool = false

    // MARK: - 私有属性

    /// 当前实际媒体类型（加载后确定）
    private var resolvedType_Vestir: MediaType_Vestir = .none_Vestir

    /// 下拉关闭时记录的起始偏移
    private var isDismissing_Vestir = false
    /// 图片原始尺寸（缩放布局用）
    private var imageSize_Vestir: CGSize = .zero

    // MARK: - AVPlayer（视频）

    private var player_Vestir: AVPlayer?
    private var playerLayer_Vestir: AVPlayerLayer?
    /// 视频进度观察者令牌
    private var timeObserverToken_Vestir: Any?
    /// 是否处于播放状态
    private var isPlaying_Vestir = false

    // MARK: - UI：黑色背景

    private let backgroundView_Vestir: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        return v
    }()

    // MARK: - UI：图片模式

    private let scrollView_Vestir: UIScrollView = {
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

    private let imageView_Vestir: UIImageView = {
        let iv = UIImageView()
        iv.contentMode   = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .clear
        return iv
    }()

    // MARK: - UI：视频模式

    /// 视频渲染容器（AVPlayerLayer 附着此 View）
    private let videoContainerView_Vestir: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        v.isHidden        = true
        return v
    }()

    /// 播放/暂停中央大按钮（覆盖在视频上）
    private let playPauseButton_Vestir: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Vestir = UIImage.SymbolConfiguration(pointSize: 36, weight: .bold)
        b.setImage(UIImage(systemName: "play.circle.fill",  withConfiguration: cfg_Vestir), for: .normal)
        b.setImage(UIImage(systemName: "pause.circle.fill", withConfiguration: cfg_Vestir), for: .selected)
        b.tintColor       = .white
        b.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        b.layer.cornerRadius = 40
        b.alpha = 0   // 初始隐藏，加载完成后淡入
        return b
    }()

    /// 底部进度条背景
    private let progressBg_Vestir: UIView = {
        let v = UIView()
        v.backgroundColor    = UIColor.white.withAlphaComponent(0.25)
        v.layer.cornerRadius = 2
        v.isHidden           = true
        return v
    }()

    /// 底部进度条前景
    private let progressFill_Vestir: UIView = {
        let v = UIView()
        v.backgroundColor    = .white
        v.layer.cornerRadius = 2
        return v
    }()

    /// 进度条宽度约束（实时更新）
    private var progressWidthCon_Vestir: Constraint?

    // MARK: - UI：共用

    private let loadingIndicator_Vestir: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = .white
        ai.hidesWhenStopped = true
        return ai
    }()

    private let topBar_Vestir: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        return v
    }()

    private let closeButton_Vestir: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Vestir = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        b.setImage(UIImage(systemName: "xmark", withConfiguration: cfg_Vestir), for: .normal)
        b.tintColor          = .white
        b.backgroundColor    = UIColor.white.withAlphaComponent(0.15)
        b.layer.cornerRadius = 18
        b.layer.borderWidth  = 1
        b.layer.borderColor  = UIColor.white.withAlphaComponent(0.25).cgColor
        return b
    }()

    private let mediaTypeLabel_Vestir: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor     = UIColor.white.withAlphaComponent(0.75)
        l.textAlignment = .center
        return l
    }()

    private let bottomHint_Vestir: UILabel = {
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
        buildUI_Vestir()
        buildConstraints_Vestir()
        bindGestures_Vestir()
        loadMedia_Vestir()
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
        cleanupPlayer_Vestir()
    }

    deinit {
        cleanupPlayer_Vestir()
    }

    // MARK: - UI 搭建

    private func buildUI_Vestir() {
        view.backgroundColor = .black

        view.addSubview(backgroundView_Vestir)

        // 图片容器
        view.addSubview(scrollView_Vestir)
        scrollView_Vestir.addSubview(imageView_Vestir)
        scrollView_Vestir.delegate = self

        // 视频容器
        view.addSubview(videoContainerView_Vestir)
        videoContainerView_Vestir.addSubview(playPauseButton_Vestir)
        videoContainerView_Vestir.addSubview(progressBg_Vestir)
        progressBg_Vestir.addSubview(progressFill_Vestir)

        // 通用
        view.addSubview(loadingIndicator_Vestir)
        view.addSubview(topBar_Vestir)
        topBar_Vestir.addSubview(closeButton_Vestir)
        topBar_Vestir.addSubview(mediaTypeLabel_Vestir)
        view.addSubview(bottomHint_Vestir)
    }

    private func buildConstraints_Vestir() {
        backgroundView_Vestir.snp.makeConstraints { $0.edges.equalToSuperview() }
        scrollView_Vestir.snp.makeConstraints     { $0.edges.equalToSuperview() }
        imageView_Vestir.frame = view.bounds

        videoContainerView_Vestir.snp.makeConstraints { $0.edges.equalToSuperview() }
        playPauseButton_Vestir.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(80)
        }

        progressBg_Vestir.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(60)
            $0.height.equalTo(4)
        }
        progressFill_Vestir.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            progressWidthCon_Vestir = $0.width.equalTo(0).constraint
        }

        loadingIndicator_Vestir.snp.makeConstraints { $0.center.equalToSuperview() }

        topBar_Vestir.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        closeButton_Vestir.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(12)
            $0.width.height.equalTo(36)
        }
        mediaTypeLabel_Vestir.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(14)
        }
        bottomHint_Vestir.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topBar_Vestir.snp.updateConstraints {
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        playerLayer_Vestir?.frame = videoContainerView_Vestir.bounds
        updateImageLayout_Vestir()
    }

    // MARK: - 手势

    private func bindGestures_Vestir() {
        // 双击缩放（图片）
        let doubleTap_Vestir = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap_Vestir(_:)))
        doubleTap_Vestir.numberOfTapsRequired = 2
        scrollView_Vestir.addGestureRecognizer(doubleTap_Vestir)

        // 单击关闭 / 视频播放切换
        let singleTap_Vestir = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap_Vestir))
        singleTap_Vestir.numberOfTapsRequired = 1
        singleTap_Vestir.require(toFail: doubleTap_Vestir)
        scrollView_Vestir.addGestureRecognizer(singleTap_Vestir)

        // 视频区单击切换播放/暂停
        let videoTap_Vestir = UITapGestureRecognizer(target: self, action: #selector(handleVideoTap_Vestir))
        videoContainerView_Vestir.addGestureRecognizer(videoTap_Vestir)

        // 下滑关闭
        let pan_Vestir = UIPanGestureRecognizer(target: self, action: #selector(handlePan_Vestir(_:)))
        pan_Vestir.delegate = self
        view.addGestureRecognizer(pan_Vestir)

        // 播放/暂停按钮
        playPauseButton_Vestir.addTarget(self, action: #selector(togglePlayPause_Vestir), for: .touchUpInside)
        closeButton_Vestir.addTarget(self, action: #selector(closeTapped_Vestir), for: .touchUpInside)
    }

    // MARK: - 媒体加载

    /// 根据 mediaPath_Vestir 和 isVideo_Vestir 加载媒体
    private func loadMedia_Vestir() {
        guard let path_Vestir = mediaPath_Vestir, !path_Vestir.isEmpty else { showEmpty_Vestir(); return }
        loadingIndicator_Vestir.startAnimating()

        // 若外部明确为视频，或路径在 Bundle 中找到视频文件 → 进入视频流程
        if isVideo_Vestir, let url_Vestir = resolveVideoURL_Vestir(path_Vestir) {
            setupVideoPlayer_Vestir(url_Vestir: url_Vestir)
            return
        }
        // 自动检测：先查 Bundle 视频
        if let url_Vestir = resolveVideoURL_Vestir(path_Vestir) {
            setupVideoPlayer_Vestir(url_Vestir: url_Vestir)
            return
        }

        // 图片加载流程
        resolvedType_Vestir = .image_Vestir
        loadImage_Vestir(path_Vestir: path_Vestir)
    }

    /// 解析路径对应的视频 URL（Bundle / Documents / 网络）
    /// - Parameter path_Vestir: 媒体路径或名称
    /// - Returns: 找到时返回 URL，否则返回 nil
    private func resolveVideoURL_Vestir(_ path_Vestir: String) -> URL? {
        // Bundle 资源
        if let url_Vestir = MediaDisplayView_Vestir.bundleVideoURL_Vestir(named: path_Vestir) {
            return url_Vestir
        }
        // Documents 目录视频文件
        let docs_Vestir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        for ext_Vestir in ["mp4", "mov", "m4v"] {
            let url_Vestir = docs_Vestir.appendingPathComponent("\(path_Vestir).\(ext_Vestir)")
            if FileManager.default.fileExists(atPath: url_Vestir.path) { return url_Vestir }
        }
        // 已带扩展名的文档目录文件
        let direct_Vestir = docs_Vestir.appendingPathComponent(path_Vestir)
        if FileManager.default.fileExists(atPath: direct_Vestir.path) { return direct_Vestir }
        // 网络视频 URL
        if (path_Vestir.hasPrefix("http://") || path_Vestir.hasPrefix("https://")),
           let url_Vestir = URL(string: path_Vestir) {
            let ext_Vestir = (path_Vestir as NSString).pathExtension.lowercased()
            if ["mp4", "mov", "m4v", "m3u8"].contains(ext_Vestir) { return url_Vestir }
        }
        return nil
    }

    /// 加载图片（与 MediaDisplayView_Vestir 策略对齐）
    /// - Parameter path_Vestir: 媒体路径
    private func loadImage_Vestir(path_Vestir: String) {
        // SF Symbols
        if let img_Vestir = UIImage(systemName: path_Vestir) { applyImage_Vestir(img_Vestir); return }
        // Assets
        if let img_Vestir = UIImage(named: path_Vestir) { applyImage_Vestir(img_Vestir); return }
        // 网络
        if path_Vestir.hasPrefix("http://") || path_Vestir.hasPrefix("https://") {
            guard let url_Vestir = URL(string: path_Vestir) else { showEmpty_Vestir(); return }
            imageView_Vestir.kf.setImage(with: url_Vestir, options: [.transition(.fade(0.3))]) { [weak self] result in
                self?.loadingIndicator_Vestir.stopAnimating()
                if case .success(let v_Vestir) = result { self?.onImageLoaded_Vestir(v_Vestir.image) }
                else { self?.showEmpty_Vestir() }
            }
            return
        }
        // Documents 文件名
        let docs_Vestir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let docURL_Vestir = docs_Vestir.appendingPathComponent(path_Vestir)
        if let img_Vestir = UIImage(contentsOfFile: docURL_Vestir.path) { applyImage_Vestir(img_Vestir); return }
        // 完整路径
        if let img_Vestir = UIImage(contentsOfFile: path_Vestir) { applyImage_Vestir(img_Vestir); return }
        showEmpty_Vestir()
    }

    // MARK: - 视频播放器

    /// 初始化并启动 AVPlayer
    /// - Parameter url_Vestir: 视频文件 URL
    private func setupVideoPlayer_Vestir(url_Vestir: URL) {
        resolvedType_Vestir = .video_Vestir

        // 切换到视频容器
        scrollView_Vestir.isHidden         = true
        videoContainerView_Vestir.isHidden = false
        progressBg_Vestir.isHidden         = false

        mediaTypeLabel_Vestir.text = "Video"

        let player_Vestir  = AVPlayer(url: url_Vestir)
        self.player_Vestir = player_Vestir
        let layer_Vestir   = AVPlayerLayer(player: player_Vestir)
        layer_Vestir.videoGravity  = .resizeAspect
        layer_Vestir.frame         = videoContainerView_Vestir.bounds
        layer_Vestir.backgroundColor = UIColor.black.cgColor
        videoContainerView_Vestir.layer.insertSublayer(layer_Vestir, at: 0)
        playerLayer_Vestir = layer_Vestir

        // 视频就绪后淡入播放按钮
        player_Vestir.addObserver(self, forKeyPath: "status", options: [.new], context: nil)

        // 进度更新（每 0.1 秒）
        let interval_Vestir = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserverToken_Vestir = player_Vestir.addPeriodicTimeObserver(
            forInterval: interval_Vestir,
            queue: .main
        ) { [weak self] time_Vestir in
            self?.updateProgress_Vestir(currentTime_Vestir: time_Vestir)
        }

        // 播放完毕回到开头
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinish_Vestir),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player_Vestir.currentItem
        )

        loadingIndicator_Vestir.stopAnimating()
        player_Vestir.play()
        isPlaying_Vestir = true
        playPauseButton_Vestir.isSelected = true
        UIView.animate(withDuration: 0.3) { self.playPauseButton_Vestir.alpha = 1 }
    }

    /// 更新底部进度条
    /// - Parameter currentTime_Vestir: AVPlayer 当前时间
    private func updateProgress_Vestir(currentTime_Vestir: CMTime) {
        guard let duration_Vestir = player_Vestir?.currentItem?.duration,
              duration_Vestir.isNumeric, duration_Vestir.seconds > 0 else { return }
        let progress_Vestir = CGFloat(currentTime_Vestir.seconds / duration_Vestir.seconds)
        let totalW_Vestir   = progressBg_Vestir.bounds.width
        progressWidthCon_Vestir?.update(offset: totalW_Vestir * min(max(progress_Vestir, 0), 1))
    }

    /// 播放结束时回到开头并切换按钮状态
    @objc private func playerDidFinish_Vestir() {
        player_Vestir?.seek(to: .zero)
        isPlaying_Vestir = false
        playPauseButton_Vestir.isSelected = false
        progressWidthCon_Vestir?.update(offset: 0)
    }

    /// 清理 AVPlayer 资源（防止内存泄漏）
    private func cleanupPlayer_Vestir() {
        if let token_Vestir = timeObserverToken_Vestir {
            player_Vestir?.removeTimeObserver(token_Vestir)
            timeObserverToken_Vestir = nil
        }
        player_Vestir?.removeObserver(self, forKeyPath: "status")
        player_Vestir?.pause()
        player_Vestir = nil
        playerLayer_Vestir?.removeFromSuperlayer()
        playerLayer_Vestir = nil
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard keyPath == "status",
              let player_Vestir = object as? AVPlayer,
              player_Vestir.status == .failed else { return }
        DispatchQueue.main.async { self.showEmpty_Vestir() }
    }

    // MARK: - 图片辅助

    private func applyImage_Vestir(_ image_Vestir: UIImage) {
        loadingIndicator_Vestir.stopAnimating()
        imageView_Vestir.image = image_Vestir
        imageSize_Vestir       = image_Vestir.size
        mediaTypeLabel_Vestir.text = "Photo"
        updateImageLayout_Vestir()
    }

    private func onImageLoaded_Vestir(_ image_Vestir: UIImage) {
        imageSize_Vestir = image_Vestir.size
        mediaTypeLabel_Vestir.text = "Photo"
        updateImageLayout_Vestir()
    }

    private func showEmpty_Vestir() {
        loadingIndicator_Vestir.stopAnimating()
        imageView_Vestir.image       = UIImage(systemName: "photo.slash")
        imageView_Vestir.tintColor   = UIColor.white.withAlphaComponent(0.4)
        imageView_Vestir.contentMode = .center
    }

    private func updateImageLayout_Vestir() {
        guard imageSize_Vestir != .zero else {
            imageView_Vestir.frame = view.bounds
            scrollView_Vestir.contentSize = view.bounds.size
            return
        }
        let screenW_Vestir = view.bounds.width
        let screenH_Vestir = view.bounds.height
        let ratio_Vestir   = imageSize_Vestir.height / imageSize_Vestir.width
        let imgH_Vestir    = screenW_Vestir * ratio_Vestir
        let y_Vestir       = max(0, (screenH_Vestir - imgH_Vestir) / 2)
        imageView_Vestir.frame        = CGRect(x: 0, y: y_Vestir, width: screenW_Vestir, height: imgH_Vestir)
        scrollView_Vestir.contentSize = CGSize(width: screenW_Vestir,
                                              height: max(imgH_Vestir + y_Vestir * 2, screenH_Vestir))
        scrollView_Vestir.zoomScale   = 1.0
        centerImageIfNeeded_Vestir()
    }

    private func centerImageIfNeeded_Vestir() {
        let offX_Vestir = max(0, (scrollView_Vestir.bounds.width  - scrollView_Vestir.contentSize.width)  / 2)
        let offY_Vestir = max(0, (scrollView_Vestir.bounds.height - scrollView_Vestir.contentSize.height) / 2)
        imageView_Vestir.center = CGPoint(
            x: scrollView_Vestir.contentSize.width  / 2 + offX_Vestir,
            y: scrollView_Vestir.contentSize.height / 2 + offY_Vestir
        )
    }

    // MARK: - 手势响应

    @objc private func handleDoubleTap_Vestir(_ gesture_Vestir: UITapGestureRecognizer) {
        guard resolvedType_Vestir == .image_Vestir else { return }
        if scrollView_Vestir.zoomScale > 1.0 {
            scrollView_Vestir.setZoomScale(1.0, animated: true)
        } else {
            let pt_Vestir    = gesture_Vestir.location(in: imageView_Vestir)
            let rect_Vestir  = zoomRect_Vestir(scale_Vestir: 2.5, center_Vestir: pt_Vestir)
            scrollView_Vestir.zoom(to: rect_Vestir, animated: true)
        }
    }

    @objc private func handleSingleTap_Vestir() {
        guard resolvedType_Vestir != .video_Vestir,
              scrollView_Vestir.zoomScale <= 1.01 else { return }
        dismissPage_Vestir(velocity_Vestir: 0)
    }

    /// 视频区点击：切换播放/暂停
    @objc private func handleVideoTap_Vestir() {
        togglePlayPause_Vestir()
    }

    /// 播放/暂停切换
    @objc private func togglePlayPause_Vestir() {
        guard let player_Vestir = player_Vestir else { return }
        if isPlaying_Vestir {
            player_Vestir.pause()
            isPlaying_Vestir = false
            playPauseButton_Vestir.isSelected = false
        } else {
            player_Vestir.play()
            isPlaying_Vestir = true
            playPauseButton_Vestir.isSelected = true
        }
        // 短暂显示后淡出按钮
        UIView.animate(withDuration: 0.2) { self.playPauseButton_Vestir.alpha = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            guard self.isPlaying_Vestir else { return }
            UIView.animate(withDuration: 0.4) { self.playPauseButton_Vestir.alpha = 0.2 }
        }
    }

    @objc private func closeTapped_Vestir() {
        dismissPage_Vestir(velocity_Vestir: 0)
    }

    @objc private func handlePan_Vestir(_ gesture_Vestir: UIPanGestureRecognizer) {
        guard scrollView_Vestir.zoomScale <= 1.01 else { return }
        let translation_Vestir = gesture_Vestir.translation(in: view)
        let velocity_Vestir    = gesture_Vestir.velocity(in: view).y
        switch gesture_Vestir.state {
        case .changed:
            let progress_Vestir         = max(0, translation_Vestir.y / view.bounds.height)
            backgroundView_Vestir.alpha = max(0, 1 - progress_Vestir * 1.5)
            topBar_Vestir.alpha         = max(0, 1 - progress_Vestir * 2)
            bottomHint_Vestir.alpha     = max(0, 1 - progress_Vestir * 2)
            let activeView_Vestir: UIView = resolvedType_Vestir == .video_Vestir
                ? videoContainerView_Vestir : scrollView_Vestir
            activeView_Vestir.transform = CGAffineTransform(
                translationX: translation_Vestir.x * 0.3,
                y: max(0, translation_Vestir.y)
            )
        case .ended, .cancelled:
            let shouldDismiss_Vestir = translation_Vestir.y > view.bounds.height * 0.25 || velocity_Vestir > 900
            if shouldDismiss_Vestir {
                dismissPage_Vestir(velocity_Vestir: velocity_Vestir)
            } else {
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               usingSpringWithDamping: 0.85,
                               initialSpringVelocity: 0.5) {
                    self.scrollView_Vestir.transform         = .identity
                    self.videoContainerView_Vestir.transform = .identity
                    self.backgroundView_Vestir.alpha  = 1
                    self.topBar_Vestir.alpha           = 1
                    self.bottomHint_Vestir.alpha       = 1
                }
            }
        default: break
        }
    }

    // MARK: - 关闭页面

    /// 执行关闭动画并 dismiss（暂停视频）
    /// - Parameter velocity_Vestir: 下拉速度（影响动画时长）
    private func dismissPage_Vestir(velocity_Vestir: CGFloat) {
        guard !isDismissing_Vestir else { return }
        isDismissing_Vestir = true
        player_Vestir?.pause()
        let duration_Vestir = velocity_Vestir > 1200 ? 0.2 : 0.3
        UIView.animate(withDuration: duration_Vestir, animations: {
            self.view.alpha = 0
            let activeView_Vestir: UIView = self.resolvedType_Vestir == .video_Vestir
                ? self.videoContainerView_Vestir : self.scrollView_Vestir
            activeView_Vestir.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
        }) { _ in
            self.dismiss(animated: false)
        }
    }

    // MARK: - 工具

    private func zoomRect_Vestir(scale_Vestir: CGFloat, center_Vestir: CGPoint) -> CGRect {
        let w_Vestir = scrollView_Vestir.bounds.width  / scale_Vestir
        let h_Vestir = scrollView_Vestir.bounds.height / scale_Vestir
        return CGRect(x: center_Vestir.x - w_Vestir / 2,
                      y: center_Vestir.y - h_Vestir / 2,
                      width: w_Vestir, height: h_Vestir)
    }
}

// MARK: - UIScrollViewDelegate（图片缩放）

extension MediaPlayerPage_Vestir: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView_Vestir }
    func scrollViewDidZoom(_ scrollView: UIScrollView) { centerImageIfNeeded_Vestir() }
}

// MARK: - UIGestureRecognizerDelegate（下拉与缩放共存）

extension MediaPlayerPage_Vestir: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan_Vestir = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        guard scrollView_Vestir.zoomScale <= 1.01 else { return false }
        let vel_Vestir = pan_Vestir.velocity(in: view)
        return abs(vel_Vestir.y) > abs(vel_Vestir.x) && vel_Vestir.y > 0
    }
}
