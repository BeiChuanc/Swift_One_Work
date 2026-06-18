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
///   - 媒体路径与 MediaDisplayView_Sylva 加载策略完全对齐（Bundle → Documents → 网络）
///   - 顶部半透明导航条（关闭按钮 + 媒体类型标签）
///   - 背景 alpha 跟随下拉手势动态变化，松手回弹或关闭
/// 关键属性：
///   - mediaPath_Sylva:  媒体路径（支持 Assets / 网络 / Documents / Bundle 视频）
///   - isVideo_Sylva:    是否强制为视频模式（传 false 时由加载器自动检测）
class MediaPlayerPage_Sylva: UIViewController {

    // MARK: - 对外属性

    /// 媒体路径（支持 Assets 名 / https URL / Documents 文件名 / Bundle 资源名）
    var mediaPath_Sylva: String?

    /// 是否强制当作视频处理（false 时由加载流程自动检测）
    var isVideo_Sylva: Bool = false

    // MARK: - 私有属性

    /// 当前实际媒体类型（加载后确定）
    private var resolvedType_Sylva: MediaType_Sylva = .none_Sylva

    /// 下拉关闭时记录的起始偏移
    private var isDismissing_Sylva = false
    /// 图片原始尺寸（缩放布局用）
    private var imageSize_Sylva: CGSize = .zero

    // MARK: - AVPlayer（视频）

    private var player_Sylva: AVPlayer?
    private var playerLayer_Sylva: AVPlayerLayer?
    /// 视频进度观察者令牌
    private var timeObserverToken_Sylva: Any?
    /// 是否处于播放状态
    private var isPlaying_Sylva = false

    // MARK: - UI：黑色背景

    private let backgroundView_Sylva: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        return v
    }()

    // MARK: - UI：图片模式

    private let scrollView_Sylva: UIScrollView = {
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

    private let imageView_Sylva: UIImageView = {
        let iv = UIImageView()
        iv.contentMode   = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .clear
        return iv
    }()

    // MARK: - UI：视频模式

    /// 视频渲染容器（AVPlayerLayer 附着此 View）
    private let videoContainerView_Sylva: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        v.isHidden        = true
        return v
    }()

    /// 播放/暂停中央大按钮（覆盖在视频上）
    private let playPauseButton_Sylva: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Sylva = UIImage.SymbolConfiguration(pointSize: 36, weight: .bold)
        b.setImage(UIImage(systemName: "play.circle.fill",  withConfiguration: cfg_Sylva), for: .normal)
        b.setImage(UIImage(systemName: "pause.circle.fill", withConfiguration: cfg_Sylva), for: .selected)
        b.tintColor       = .white
        b.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        b.layer.cornerRadius = 40
        b.alpha = 0   // 初始隐藏，加载完成后淡入
        return b
    }()

    /// 底部进度条背景
    private let progressBg_Sylva: UIView = {
        let v = UIView()
        v.backgroundColor    = UIColor.white.withAlphaComponent(0.25)
        v.layer.cornerRadius = 2
        v.isHidden           = true
        return v
    }()

    /// 底部进度条前景
    private let progressFill_Sylva: UIView = {
        let v = UIView()
        v.backgroundColor    = .white
        v.layer.cornerRadius = 2
        return v
    }()

    /// 进度条宽度约束（实时更新）
    private var progressWidthCon_Sylva: Constraint?

    // MARK: - UI：共用

    private let loadingIndicator_Sylva: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = .white
        ai.hidesWhenStopped = true
        return ai
    }()

    private let topBar_Sylva: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        return v
    }()

    private let closeButton_Sylva: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Sylva = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        b.setImage(UIImage(systemName: "xmark", withConfiguration: cfg_Sylva), for: .normal)
        b.tintColor          = .white
        b.backgroundColor    = UIColor.white.withAlphaComponent(0.15)
        b.layer.cornerRadius = 18
        b.layer.borderWidth  = 1
        b.layer.borderColor  = UIColor.white.withAlphaComponent(0.25).cgColor
        return b
    }()

    private let mediaTypeLabel_Sylva: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor     = UIColor.white.withAlphaComponent(0.75)
        l.textAlignment = .center
        return l
    }()

    private let bottomHint_Sylva: UILabel = {
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
        buildUI_Sylva()
        buildConstraints_Sylva()
        bindGestures_Sylva()
        loadMedia_Sylva()
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
        cleanupPlayer_Sylva()
    }

    deinit {
        cleanupPlayer_Sylva()
    }

    // MARK: - UI 搭建

    private func buildUI_Sylva() {
        view.backgroundColor = .black

        view.addSubview(backgroundView_Sylva)

        // 图片容器
        view.addSubview(scrollView_Sylva)
        scrollView_Sylva.addSubview(imageView_Sylva)
        scrollView_Sylva.delegate = self

        // 视频容器
        view.addSubview(videoContainerView_Sylva)
        videoContainerView_Sylva.addSubview(playPauseButton_Sylva)
        videoContainerView_Sylva.addSubview(progressBg_Sylva)
        progressBg_Sylva.addSubview(progressFill_Sylva)

        // 通用
        view.addSubview(loadingIndicator_Sylva)
        view.addSubview(topBar_Sylva)
        topBar_Sylva.addSubview(closeButton_Sylva)
        topBar_Sylva.addSubview(mediaTypeLabel_Sylva)
        view.addSubview(bottomHint_Sylva)
    }

    private func buildConstraints_Sylva() {
        backgroundView_Sylva.snp.makeConstraints { $0.edges.equalToSuperview() }
        scrollView_Sylva.snp.makeConstraints     { $0.edges.equalToSuperview() }
        imageView_Sylva.frame = view.bounds

        videoContainerView_Sylva.snp.makeConstraints { $0.edges.equalToSuperview() }
        playPauseButton_Sylva.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(80)
        }

        progressBg_Sylva.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(60)
            $0.height.equalTo(4)
        }
        progressFill_Sylva.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            progressWidthCon_Sylva = $0.width.equalTo(0).constraint
        }

        loadingIndicator_Sylva.snp.makeConstraints { $0.center.equalToSuperview() }

        topBar_Sylva.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        closeButton_Sylva.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(12)
            $0.width.height.equalTo(36)
        }
        mediaTypeLabel_Sylva.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(14)
        }
        bottomHint_Sylva.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topBar_Sylva.snp.updateConstraints {
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        playerLayer_Sylva?.frame = videoContainerView_Sylva.bounds
        updateImageLayout_Sylva()
    }

    // MARK: - 手势

    private func bindGestures_Sylva() {
        // 双击缩放（图片）
        let doubleTap_Sylva = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap_Sylva(_:)))
        doubleTap_Sylva.numberOfTapsRequired = 2
        scrollView_Sylva.addGestureRecognizer(doubleTap_Sylva)

        // 单击关闭 / 视频播放切换
        let singleTap_Sylva = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap_Sylva))
        singleTap_Sylva.numberOfTapsRequired = 1
        singleTap_Sylva.require(toFail: doubleTap_Sylva)
        scrollView_Sylva.addGestureRecognizer(singleTap_Sylva)

        // 视频区单击切换播放/暂停
        let videoTap_Sylva = UITapGestureRecognizer(target: self, action: #selector(handleVideoTap_Sylva))
        videoContainerView_Sylva.addGestureRecognizer(videoTap_Sylva)

        // 下滑关闭
        let pan_Sylva = UIPanGestureRecognizer(target: self, action: #selector(handlePan_Sylva(_:)))
        pan_Sylva.delegate = self
        view.addGestureRecognizer(pan_Sylva)

        // 播放/暂停按钮
        playPauseButton_Sylva.addTarget(self, action: #selector(togglePlayPause_Sylva), for: .touchUpInside)
        closeButton_Sylva.addTarget(self, action: #selector(closeTapped_Sylva), for: .touchUpInside)
    }

    // MARK: - 媒体加载

    /// 根据 mediaPath_Sylva 和 isVideo_Sylva 加载媒体
    private func loadMedia_Sylva() {
        guard let path_Sylva = mediaPath_Sylva, !path_Sylva.isEmpty else { showEmpty_Sylva(); return }
        loadingIndicator_Sylva.startAnimating()

        // 若外部明确为视频，或路径在 Bundle 中找到视频文件 → 进入视频流程
        if isVideo_Sylva, let url_Sylva = resolveVideoURL_Sylva(path_Sylva) {
            setupVideoPlayer_Sylva(url_Sylva: url_Sylva)
            return
        }
        // 自动检测：先查 Bundle 视频
        if let url_Sylva = resolveVideoURL_Sylva(path_Sylva) {
            setupVideoPlayer_Sylva(url_Sylva: url_Sylva)
            return
        }

        // 图片加载流程
        resolvedType_Sylva = .image_Sylva
        loadImage_Sylva(path_Sylva: path_Sylva)
    }

    /// 解析路径对应的视频 URL（Bundle / Documents / 网络）
    /// - Parameter path_Sylva: 媒体路径或名称
    /// - Returns: 找到时返回 URL，否则返回 nil
    private func resolveVideoURL_Sylva(_ path_Sylva: String) -> URL? {
        // Bundle 资源
        if let url_Sylva = MediaDisplayView_Sylva.bundleVideoURL_Sylva(named: path_Sylva) {
            return url_Sylva
        }
        // Documents 目录视频文件
        let docs_Sylva = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        for ext_Sylva in ["mp4", "mov", "m4v"] {
            let url_Sylva = docs_Sylva.appendingPathComponent("\(path_Sylva).\(ext_Sylva)")
            if FileManager.default.fileExists(atPath: url_Sylva.path) { return url_Sylva }
        }
        // 已带扩展名的文档目录文件
        let direct_Sylva = docs_Sylva.appendingPathComponent(path_Sylva)
        if FileManager.default.fileExists(atPath: direct_Sylva.path) { return direct_Sylva }
        // 网络视频 URL
        if (path_Sylva.hasPrefix("http://") || path_Sylva.hasPrefix("https://")),
           let url_Sylva = URL(string: path_Sylva) {
            let ext_Sylva = (path_Sylva as NSString).pathExtension.lowercased()
            if ["mp4", "mov", "m4v", "m3u8"].contains(ext_Sylva) { return url_Sylva }
        }
        return nil
    }

    /// 加载图片（与 MediaDisplayView_Sylva 策略对齐）
    /// - Parameter path_Sylva: 媒体路径
    private func loadImage_Sylva(path_Sylva: String) {
        // SF Symbols
        if let img_Sylva = UIImage(systemName: path_Sylva) { applyImage_Sylva(img_Sylva); return }
        // Assets
        if let img_Sylva = UIImage(named: path_Sylva) { applyImage_Sylva(img_Sylva); return }
        // 网络
        if path_Sylva.hasPrefix("http://") || path_Sylva.hasPrefix("https://") {
            guard let url_Sylva = URL(string: path_Sylva) else { showEmpty_Sylva(); return }
            imageView_Sylva.kf.setImage(with: url_Sylva, options: [.transition(.fade(0.3))]) { [weak self] result in
                self?.loadingIndicator_Sylva.stopAnimating()
                if case .success(let v_Sylva) = result { self?.onImageLoaded_Sylva(v_Sylva.image) }
                else { self?.showEmpty_Sylva() }
            }
            return
        }
        // Documents 文件名
        let docs_Sylva = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let docURL_Sylva = docs_Sylva.appendingPathComponent(path_Sylva)
        if let img_Sylva = UIImage(contentsOfFile: docURL_Sylva.path) { applyImage_Sylva(img_Sylva); return }
        // 完整路径
        if let img_Sylva = UIImage(contentsOfFile: path_Sylva) { applyImage_Sylva(img_Sylva); return }
        showEmpty_Sylva()
    }

    // MARK: - 视频播放器

    /// 初始化并启动 AVPlayer
    /// - Parameter url_Sylva: 视频文件 URL
    private func setupVideoPlayer_Sylva(url_Sylva: URL) {
        resolvedType_Sylva = .video_Sylva

        // 切换到视频容器
        scrollView_Sylva.isHidden         = true
        videoContainerView_Sylva.isHidden = false
        progressBg_Sylva.isHidden         = false

        mediaTypeLabel_Sylva.text = "Video"

        let player_Sylva  = AVPlayer(url: url_Sylva)
        self.player_Sylva = player_Sylva
        let layer_Sylva   = AVPlayerLayer(player: player_Sylva)
        layer_Sylva.videoGravity  = .resizeAspect
        layer_Sylva.frame         = videoContainerView_Sylva.bounds
        layer_Sylva.backgroundColor = UIColor.black.cgColor
        videoContainerView_Sylva.layer.insertSublayer(layer_Sylva, at: 0)
        playerLayer_Sylva = layer_Sylva

        // 视频就绪后淡入播放按钮
        player_Sylva.addObserver(self, forKeyPath: "status", options: [.new], context: nil)

        // 进度更新（每 0.1 秒）
        let interval_Sylva = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserverToken_Sylva = player_Sylva.addPeriodicTimeObserver(
            forInterval: interval_Sylva,
            queue: .main
        ) { [weak self] time_Sylva in
            self?.updateProgress_Sylva(currentTime_Sylva: time_Sylva)
        }

        // 播放完毕回到开头
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinish_Sylva),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player_Sylva.currentItem
        )

        loadingIndicator_Sylva.stopAnimating()
        player_Sylva.play()
        isPlaying_Sylva = true
        playPauseButton_Sylva.isSelected = true
        UIView.animate(withDuration: 0.3) { self.playPauseButton_Sylva.alpha = 1 }
    }

    /// 更新底部进度条
    /// - Parameter currentTime_Sylva: AVPlayer 当前时间
    private func updateProgress_Sylva(currentTime_Sylva: CMTime) {
        guard let duration_Sylva = player_Sylva?.currentItem?.duration,
              duration_Sylva.isNumeric, duration_Sylva.seconds > 0 else { return }
        let progress_Sylva = CGFloat(currentTime_Sylva.seconds / duration_Sylva.seconds)
        let totalW_Sylva   = progressBg_Sylva.bounds.width
        progressWidthCon_Sylva?.update(offset: totalW_Sylva * min(max(progress_Sylva, 0), 1))
    }

    /// 播放结束时回到开头并切换按钮状态
    @objc private func playerDidFinish_Sylva() {
        player_Sylva?.seek(to: .zero)
        isPlaying_Sylva = false
        playPauseButton_Sylva.isSelected = false
        progressWidthCon_Sylva?.update(offset: 0)
    }

    /// 清理 AVPlayer 资源（防止内存泄漏）
    private func cleanupPlayer_Sylva() {
        if let token_Sylva = timeObserverToken_Sylva {
            player_Sylva?.removeTimeObserver(token_Sylva)
            timeObserverToken_Sylva = nil
        }
        player_Sylva?.removeObserver(self, forKeyPath: "status")
        player_Sylva?.pause()
        player_Sylva = nil
        playerLayer_Sylva?.removeFromSuperlayer()
        playerLayer_Sylva = nil
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard keyPath == "status",
              let player_Sylva = object as? AVPlayer,
              player_Sylva.status == .failed else { return }
        DispatchQueue.main.async { self.showEmpty_Sylva() }
    }

    // MARK: - 图片辅助

    private func applyImage_Sylva(_ image_Sylva: UIImage) {
        loadingIndicator_Sylva.stopAnimating()
        imageView_Sylva.image = image_Sylva
        imageSize_Sylva       = image_Sylva.size
        mediaTypeLabel_Sylva.text = "Photo"
        updateImageLayout_Sylva()
    }

    private func onImageLoaded_Sylva(_ image_Sylva: UIImage) {
        imageSize_Sylva = image_Sylva.size
        mediaTypeLabel_Sylva.text = "Photo"
        updateImageLayout_Sylva()
    }

    private func showEmpty_Sylva() {
        loadingIndicator_Sylva.stopAnimating()
        imageView_Sylva.image       = UIImage(systemName: "photo.slash")
        imageView_Sylva.tintColor   = UIColor.white.withAlphaComponent(0.4)
        imageView_Sylva.contentMode = .center
    }

    private func updateImageLayout_Sylva() {
        guard imageSize_Sylva != .zero else {
            imageView_Sylva.frame = view.bounds
            scrollView_Sylva.contentSize = view.bounds.size
            return
        }
        let screenW_Sylva = view.bounds.width
        let screenH_Sylva = view.bounds.height
        let ratio_Sylva   = imageSize_Sylva.height / imageSize_Sylva.width
        let imgH_Sylva    = screenW_Sylva * ratio_Sylva
        let y_Sylva       = max(0, (screenH_Sylva - imgH_Sylva) / 2)
        imageView_Sylva.frame        = CGRect(x: 0, y: y_Sylva, width: screenW_Sylva, height: imgH_Sylva)
        scrollView_Sylva.contentSize = CGSize(width: screenW_Sylva,
                                              height: max(imgH_Sylva + y_Sylva * 2, screenH_Sylva))
        scrollView_Sylva.zoomScale   = 1.0
        centerImageIfNeeded_Sylva()
    }

    private func centerImageIfNeeded_Sylva() {
        let offX_Sylva = max(0, (scrollView_Sylva.bounds.width  - scrollView_Sylva.contentSize.width)  / 2)
        let offY_Sylva = max(0, (scrollView_Sylva.bounds.height - scrollView_Sylva.contentSize.height) / 2)
        imageView_Sylva.center = CGPoint(
            x: scrollView_Sylva.contentSize.width  / 2 + offX_Sylva,
            y: scrollView_Sylva.contentSize.height / 2 + offY_Sylva
        )
    }

    // MARK: - 手势响应

    @objc private func handleDoubleTap_Sylva(_ gesture_Sylva: UITapGestureRecognizer) {
        guard resolvedType_Sylva == .image_Sylva else { return }
        if scrollView_Sylva.zoomScale > 1.0 {
            scrollView_Sylva.setZoomScale(1.0, animated: true)
        } else {
            let pt_Sylva    = gesture_Sylva.location(in: imageView_Sylva)
            let rect_Sylva  = zoomRect_Sylva(scale_Sylva: 2.5, center_Sylva: pt_Sylva)
            scrollView_Sylva.zoom(to: rect_Sylva, animated: true)
        }
    }

    @objc private func handleSingleTap_Sylva() {
        guard resolvedType_Sylva != .video_Sylva,
              scrollView_Sylva.zoomScale <= 1.01 else { return }
        dismissPage_Sylva(velocity_Sylva: 0)
    }

    /// 视频区点击：切换播放/暂停
    @objc private func handleVideoTap_Sylva() {
        togglePlayPause_Sylva()
    }

    /// 播放/暂停切换
    @objc private func togglePlayPause_Sylva() {
        guard let player_Sylva = player_Sylva else { return }
        if isPlaying_Sylva {
            player_Sylva.pause()
            isPlaying_Sylva = false
            playPauseButton_Sylva.isSelected = false
        } else {
            player_Sylva.play()
            isPlaying_Sylva = true
            playPauseButton_Sylva.isSelected = true
        }
        // 短暂显示后淡出按钮
        UIView.animate(withDuration: 0.2) { self.playPauseButton_Sylva.alpha = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            guard self.isPlaying_Sylva else { return }
            UIView.animate(withDuration: 0.4) { self.playPauseButton_Sylva.alpha = 0.2 }
        }
    }

    @objc private func closeTapped_Sylva() {
        dismissPage_Sylva(velocity_Sylva: 0)
    }

    @objc private func handlePan_Sylva(_ gesture_Sylva: UIPanGestureRecognizer) {
        guard scrollView_Sylva.zoomScale <= 1.01 else { return }
        let translation_Sylva = gesture_Sylva.translation(in: view)
        let velocity_Sylva    = gesture_Sylva.velocity(in: view).y
        switch gesture_Sylva.state {
        case .changed:
            let progress_Sylva         = max(0, translation_Sylva.y / view.bounds.height)
            backgroundView_Sylva.alpha = max(0, 1 - progress_Sylva * 1.5)
            topBar_Sylva.alpha         = max(0, 1 - progress_Sylva * 2)
            bottomHint_Sylva.alpha     = max(0, 1 - progress_Sylva * 2)
            let activeView_Sylva: UIView = resolvedType_Sylva == .video_Sylva
                ? videoContainerView_Sylva : scrollView_Sylva
            activeView_Sylva.transform = CGAffineTransform(
                translationX: translation_Sylva.x * 0.3,
                y: max(0, translation_Sylva.y)
            )
        case .ended, .cancelled:
            let shouldDismiss_Sylva = translation_Sylva.y > view.bounds.height * 0.25 || velocity_Sylva > 900
            if shouldDismiss_Sylva {
                dismissPage_Sylva(velocity_Sylva: velocity_Sylva)
            } else {
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               usingSpringWithDamping: 0.85,
                               initialSpringVelocity: 0.5) {
                    self.scrollView_Sylva.transform         = .identity
                    self.videoContainerView_Sylva.transform = .identity
                    self.backgroundView_Sylva.alpha  = 1
                    self.topBar_Sylva.alpha           = 1
                    self.bottomHint_Sylva.alpha       = 1
                }
            }
        default: break
        }
    }

    // MARK: - 关闭页面

    /// 执行关闭动画并 dismiss（暂停视频）
    /// - Parameter velocity_Sylva: 下拉速度（影响动画时长）
    private func dismissPage_Sylva(velocity_Sylva: CGFloat) {
        guard !isDismissing_Sylva else { return }
        isDismissing_Sylva = true
        player_Sylva?.pause()
        let duration_Sylva = velocity_Sylva > 1200 ? 0.2 : 0.3
        UIView.animate(withDuration: duration_Sylva, animations: {
            self.view.alpha = 0
            let activeView_Sylva: UIView = self.resolvedType_Sylva == .video_Sylva
                ? self.videoContainerView_Sylva : self.scrollView_Sylva
            activeView_Sylva.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
        }) { _ in
            self.dismiss(animated: false)
        }
    }

    // MARK: - 工具

    private func zoomRect_Sylva(scale_Sylva: CGFloat, center_Sylva: CGPoint) -> CGRect {
        let w_Sylva = scrollView_Sylva.bounds.width  / scale_Sylva
        let h_Sylva = scrollView_Sylva.bounds.height / scale_Sylva
        return CGRect(x: center_Sylva.x - w_Sylva / 2,
                      y: center_Sylva.y - h_Sylva / 2,
                      width: w_Sylva, height: h_Sylva)
    }
}

// MARK: - UIScrollViewDelegate（图片缩放）

extension MediaPlayerPage_Sylva: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView_Sylva }
    func scrollViewDidZoom(_ scrollView: UIScrollView) { centerImageIfNeeded_Sylva() }
}

// MARK: - UIGestureRecognizerDelegate（下拉与缩放共存）

extension MediaPlayerPage_Sylva: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan_Sylva = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        guard scrollView_Sylva.zoomScale <= 1.01 else { return false }
        let vel_Sylva = pan_Sylva.velocity(in: view)
        return abs(vel_Sylva.y) > abs(vel_Sylva.x) && vel_Sylva.y > 0
    }
}
