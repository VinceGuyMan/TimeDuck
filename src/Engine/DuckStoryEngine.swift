// MARK: - TimeDuck · DuckStoryEngine.swift
// Modular procedural theatrical story engine for Wave 6.1 (Living Scenes).
// Stories OBSERVE time and NEVER own time.
// All timer, stopwatch, and pomodoro engines remain strictly authoritative and decoupled.

import Foundation

// MARK: - Story Identifier

enum DuckStoryId: String, CaseIterable, Codable {
    case off
    case auto
    case theFeast
    case theExpedition
    case nightShift
    case theWod
    case theRescue

    var displayName: String {
        switch self {
        case .off: return "Off"
        case .auto: return "Auto"
        case .theFeast: return "The Feast"
        case .theExpedition: return "The Expedition"
        case .nightShift: return "Night Shift"
        case .theWod: return "The WOD"
        case .theRescue: return "The Rescue"
        }
    }
}

// MARK: - Story Context

struct DuckStoryContext {
    var mode: Mode
    var isRunning: Bool
    var isPaused: Bool
    var isFinished: Bool
    var normalizedProgress: Double // 0.0 ... 1.0
    var sessionDuration: Double
    var remainingSeconds: Double
    var elapsedSeconds: Double
    var isCompact: Bool
    var reduceMotion: Bool
    var localHour: Int
    var currentHat: DuckHat
    var currentTheme: ThemeType
}

// MARK: - Performance Override

struct DuckStoryPerformanceOverride {
    var spriteRows: [String]?
    var x: Double?
    var y: Double?
    var flip: Bool?
}

// MARK: - Secondary Story Actor

struct DuckStoryActor {
    let id: String
    var name: String
    var x: Double
    var y: Double
    var frames: [[String]]
    var currentFrameIndex: Int = 0
    var colorMapOverride: [Character: UInt32]?
    var flip: Bool
    var isVisible: Bool
    var targetX: Double?
    var moveSpeed: Double
    var animationInterval: Double = 0.20
    var lastFrameTime: Double = 0.0

    var spriteRows: [String] {
        guard !frames.isEmpty else { return [] }
        return frames[currentFrameIndex % frames.count]
    }

    init(id: String, name: String, x: Double, y: Double, spriteRows: [String], colorMapOverride: [Character: UInt32]? = nil, flip: Bool = false, isVisible: Bool = true, targetX: Double? = nil, moveSpeed: Double = 0.0) {
        self.id = id
        self.name = name
        self.x = x
        self.y = y
        self.frames = [spriteRows]
        self.currentFrameIndex = 0
        self.colorMapOverride = colorMapOverride
        self.flip = flip
        self.isVisible = isVisible
        self.targetX = targetX
        self.moveSpeed = moveSpeed
        self.animationInterval = 0.20
        self.lastFrameTime = 0.0
    }

    init(id: String, name: String, x: Double, y: Double, frames: [[String]], colorMapOverride: [Character: UInt32]? = nil, flip: Bool = false, isVisible: Bool = true, targetX: Double? = nil, moveSpeed: Double = 0.0, animationInterval: Double = 0.20) {
        self.id = id
        self.name = name
        self.x = x
        self.y = y
        self.frames = frames
        self.currentFrameIndex = 0
        self.colorMapOverride = colorMapOverride
        self.flip = flip
        self.isVisible = isVisible
        self.targetX = targetX
        self.moveSpeed = moveSpeed
        self.animationInterval = animationInterval
        self.lastFrameTime = 0.0
    }

    mutating func updateAnimation(now: Double) {
        guard frames.count > 1 else { return }
        if now - lastFrameTime >= animationInterval {
            currentFrameIndex = (currentFrameIndex + 1) % frames.count
            lastFrameTime = now
        }
    }

    mutating func updateMovement(dt: Double) {
        guard let target = targetX else { return }
        let dx = target - x
        if abs(dx) > 0.5 {
            x += (dx > 0 ? 1 : -1) * min(abs(dx), moveSpeed * dt)
            flip = dx < 0
            if abs(target - x) <= 0.5 {
                x = target
                targetX = nil
            }
        } else {
            x = target
            targetX = nil
        }
    }
}

// MARK: - Procedural Scenery Prop

struct DuckStorySceneryProp {
    let id: String
    var x: Int
    var y: Int
    var frames: [[String]]
    var currentFrameIndex: Int = 0
    var colorMapKey: String
    var flip: Bool
    var isVisible: Bool
    var zIndex: Int // 0: background, 1: foreground
    var animationInterval: Double = 0.25
    var lastFrameTime: Double = 0.0

    var spriteRows: [String] {
        guard !frames.isEmpty else { return [] }
        return frames[currentFrameIndex % frames.count]
    }

    init(id: String, x: Int, y: Int, spriteRows: [String], colorMapKey: String, flip: Bool = false, isVisible: Bool = true, zIndex: Int = 0) {
        self.id = id
        self.x = x
        self.y = y
        self.frames = [spriteRows]
        self.currentFrameIndex = 0
        self.colorMapKey = colorMapKey
        self.flip = flip
        self.isVisible = isVisible
        self.zIndex = zIndex
        self.animationInterval = 0.25
        self.lastFrameTime = 0.0
    }

    init(id: String, x: Int, y: Int, frames: [[String]], colorMapKey: String, flip: Bool = false, isVisible: Bool = true, zIndex: Int = 0, animationInterval: Double = 0.25) {
        self.id = id
        self.x = x
        self.y = y
        self.frames = frames
        self.currentFrameIndex = 0
        self.colorMapKey = colorMapKey
        self.flip = flip
        self.isVisible = isVisible
        self.zIndex = zIndex
        self.animationInterval = animationInterval
        self.lastFrameTime = 0.0
    }

    mutating func updateAnimation(now: Double) {
        guard frames.count > 1 else { return }
        if now - lastFrameTime >= animationInterval {
            currentFrameIndex = (currentFrameIndex + 1) % frames.count
            lastFrameTime = now
        }
    }
}

// MARK: - Story Protocol

protocol DuckStory: AnyObject {
    var id: DuckStoryId { get }
    var title: String { get }
    var description: String { get }
    var activeSceneIndex: Int { get }
    var sceneElapsedTime: Double { get }
    var isFinaleActive: Bool { get }
    var finaleElapsedTime: Double { get }

    func isEligible(context: DuckStoryContext) -> Bool
    func prepare(context: DuckStoryContext, engine: DuckStoryEngine)
    func onStart(context: DuckStoryContext, engine: DuckStoryEngine)
    func onProgress(context: DuckStoryContext, progress: Double, engine: DuckStoryEngine)
    func onMilestone(milestoneIndex: Int, progress: Double, context: DuckStoryContext, engine: DuckStoryEngine)
    func onPause(context: DuckStoryContext, engine: DuckStoryEngine)
    func onResume(context: DuckStoryContext, engine: DuckStoryEngine)
    func onInteraction(type: String, context: DuckStoryContext, engine: DuckStoryEngine) -> String?
    func onComplete(context: DuckStoryContext, engine: DuckStoryEngine)
    func onEnterFinale(context: DuckStoryContext, engine: DuckStoryEngine)
    func onCancel(context: DuckStoryContext, engine: DuckStoryEngine)
    func cleanup(engine: DuckStoryEngine)
    func cleanupFinale(engine: DuckStoryEngine)

    func update(dt: Double, now: Date, context: DuckStoryContext, engine: DuckStoryEngine)
    func updateFinale(dt: Double, now: Date, context: DuckStoryContext, engine: DuckStoryEngine)
}

// MARK: - Story Engine Coordinator

final class DuckStoryEngine {
    private(set) var selectedStoryId: DuckStoryId = .auto
    private(set) var activeStory: DuckStory?
    private(set) var stories: [DuckStoryId: DuckStory] = [:]

    private(set) var currentMilestoneIndex: Int = 0
    private(set) var lastProgress: Double = 0.0
    private(set) var isPrepared: Bool = false
    private(set) var isFinaleActive: Bool = false
    private(set) var finaleElapsedTime: Double = 0.0
    private(set) var isSessionStarted: Bool = false
    private(set) var isSessionPaused: Bool = false

    private struct SessionSnapshot {
        let selectedStoryId: DuckStoryId
        let activeStory: DuckStory?
        let currentMilestoneIndex: Int
        let lastProgress: Double
        let isPrepared: Bool
        let isFinaleActive: Bool
        let finaleElapsedTime: Double
        let isSessionStarted: Bool
        let isSessionPaused: Bool
        let actors: [DuckStoryActor]
        let props: [DuckStorySceneryProp]
        let performanceOverride: DuckStoryPerformanceOverride?
    }

    private var previewSnapshot: SessionSnapshot?
    private var previewStory: DuckStory?

    // Live theatrical entities
    var actors: [DuckStoryActor] = []
    var props: [DuckStorySceneryProp] = []
    var currentPerformanceOverride: DuckStoryPerformanceOverride?

    // Callbacks to View
    var onSpeak: ((String, Double) -> Void)?
    var onDuckPose: ((DuckPose, Double) -> Void)?
    var onDropCrumb: (() -> Void)?
    var onPlaySound: ((String) -> Void)?
    var onSpawnSteamPuff: (() -> Void)?
    var onSpawnSweat: (() -> Void)?
    var onStoryCompleted: ((DuckStoryId) -> Void)?

    init(initialSelection: DuckStoryId? = nil) {
        registerDefaultStories()
        if let initial = initialSelection {
            selectedStoryId = initial
        } else {
            let saved = UserDefaults.standard.string(forKey: "td.storySelection") ?? "auto"
            selectedStoryId = DuckStoryId(rawValue: saved) ?? .auto
        }
    }

    private func registerDefaultStories() {
        for id in [DuckStoryId.theFeast, .theExpedition, .nightShift, .theWod, .theRescue] {
            stories[id] = makeStory(id)
        }
    }

    private func makeStory(_ id: DuckStoryId) -> DuckStory? {
        switch id {
        case .theFeast: return TheFeastStory()
        case .theExpedition: return TheExpeditionStory()
        case .nightShift: return NightShiftStory()
        case .theWod: return TheWodStory()
        case .theRescue: return TheRescueStory()
        case .off, .auto: return nil
        }
    }

    func setSelection(_ id: DuckStoryId) {
        if previewSnapshot != nil {
            endPreview()
        }
        selectedStoryId = id
        UserDefaults.standard.set(id.rawValue, forKey: "td.storySelection")
    }

    /// Starts an isolated developer preview without changing the persisted user selection
    /// or mutating the live story instance that belongs to an authoritative clock session.
    func beginPreview(_ id: DuckStoryId) {
        if previewSnapshot == nil {
            previewSnapshot = SessionSnapshot(
                selectedStoryId: selectedStoryId,
                activeStory: activeStory,
                currentMilestoneIndex: currentMilestoneIndex,
                lastProgress: lastProgress,
                isPrepared: isPrepared,
                isFinaleActive: isFinaleActive,
                finaleElapsedTime: finaleElapsedTime,
                isSessionStarted: isSessionStarted,
                isSessionPaused: isSessionPaused,
                actors: actors,
                props: props,
                performanceOverride: currentPerformanceOverride
            )
        } else {
            activeStory?.cleanup(engine: self)
            activeStory?.cleanupFinale(engine: self)
        }

        selectedStoryId = id
        previewStory = makeStory(id)
        activeStory = nil
        currentMilestoneIndex = 0
        lastProgress = 0
        isPrepared = false
        isFinaleActive = false
        finaleElapsedTime = 0
        isSessionStarted = false
        isSessionPaused = false
        actors.removeAll()
        props.removeAll()
        currentPerformanceOverride = nil
    }

    /// Ends developer preview and restores the exact live story coordinator state.
    func endPreview() {
        guard let snapshot = previewSnapshot else { return }
        activeStory?.cleanup(engine: self)
        activeStory?.cleanupFinale(engine: self)

        selectedStoryId = snapshot.selectedStoryId
        activeStory = snapshot.activeStory
        currentMilestoneIndex = snapshot.currentMilestoneIndex
        lastProgress = snapshot.lastProgress
        isPrepared = snapshot.isPrepared
        isFinaleActive = snapshot.isFinaleActive
        finaleElapsedTime = snapshot.finaleElapsedTime
        isSessionStarted = snapshot.isSessionStarted
        isSessionPaused = snapshot.isSessionPaused
        actors = snapshot.actors
        props = snapshot.props
        currentPerformanceOverride = snapshot.performanceOverride
        previewStory = nil
        previewSnapshot = nil
    }

    func resolveActiveStory(context: DuckStoryContext) -> DuckStory? {
        if selectedStoryId == .off {
            return nil
        }
        // Preview mode always resolves previewStory regardless of clock mode
        if previewSnapshot != nil {
            return previewStory ?? stories[selectedStoryId]
        }
        if selectedStoryId != .auto {
            return stories[selectedStoryId]
        }

        // Auto Selection Logic: Strictly Pomodoro-exclusive in Wave 8.1
        guard context.mode == .pomodoro else {
            return nil
        }

        // 1. Late night session (>= 22 or <= 5) -> Night Shift
        if context.localHour >= 22 || context.localHour <= 5 {
            return stories[.nightShift]
        }
        // 2. Long focus sprint (>= 1500s / 25m) -> The Expedition or The Rescue or The WOD
        if context.sessionDuration >= 1500 {
            let seed = Int(context.sessionDuration) % 3
            if seed == 0 { return stories[.theExpedition] }
            else if seed == 1 { return stories[.theRescue] }
            else { return stories[.theWod] }
        }
        // 3. Standard Pomodoro focus -> The Feast
        return stories[.theFeast]
    }

    // MARK: - Lifecycle Hooks

    func prepareSession(context: DuckStoryContext) {
        activeStory = resolveActiveStory(context: context)
        currentMilestoneIndex = 0
        lastProgress = 0.0
        isFinaleActive = false
        finaleElapsedTime = 0.0
        isSessionStarted = false
        isSessionPaused = false
        actors.removeAll()
        props.removeAll()
        currentPerformanceOverride = nil
        if let story = activeStory {
            story.prepare(context: context, engine: self)
            isPrepared = true
        } else {
            isPrepared = false
        }
    }

    func startSession(context: DuckStoryContext) {
        // A completed finale belongs to the previous clock session. Starting again
        // must construct a fresh story instance state and re-arm all one-shots.
        if !isPrepared || isFinaleActive {
            prepareSession(context: context)
        }

        if isSessionStarted {
            if isSessionPaused {
                resumeSession(context: context)
            }
            return
        }

        isFinaleActive = false
        finaleElapsedTime = 0.0
        activeStory?.onStart(context: context, engine: self)
        isSessionStarted = true
        isSessionPaused = false
    }

    func updateProgress(context: DuckStoryContext, now: Date) {
        guard isPrepared, isSessionStarted,
              let story = activeStory, selectedStoryId != .off else { return }

        let p = min(1.0, max(0.0, context.normalizedProgress))

        if !isFinaleActive {
            story.onProgress(context: context, progress: p, engine: self)

            // Milestone evaluations (0.2, 0.4, 0.6, 0.8, 1.0)
            let thresholds: [Double] = [0.0, 0.20, 0.40, 0.60, 0.80, 1.00]
            for (idx, threshold) in thresholds.enumerated() where idx > 0 {
                if p >= threshold && currentMilestoneIndex < idx {
                    currentMilestoneIndex = idx
                    story.onMilestone(milestoneIndex: idx, progress: p, context: context, engine: self)
                }
            }
        }

        if (context.isFinished || p >= 1.0) && !isFinaleActive {
            enterFinale(context: context)
            return
        }

        lastProgress = p
    }

    func pauseSession(context: DuckStoryContext) {
        guard isSessionStarted, !isSessionPaused else { return }
        isSessionPaused = true
        activeStory?.onPause(context: context, engine: self)
    }

    func resumeSession(context: DuckStoryContext) {
        guard isSessionStarted, isSessionPaused else { return }
        isSessionPaused = false
        activeStory?.onResume(context: context, engine: self)
    }

    func handleInteraction(type: String, context: DuckStoryContext) -> String? {
        activeStory?.onInteraction(type: type, context: context, engine: self)
    }

    func enterFinale(context: DuckStoryContext) {
        guard !isFinaleActive else { return }
        isFinaleActive = true
        finaleElapsedTime = 0.0
        activeStory?.onEnterFinale(context: context, engine: self)
        let completedId = (selectedStoryId != .off && selectedStoryId != .auto) ? selectedStoryId : (activeStory?.id ?? .off)
        if completedId != .off && completedId != .auto {
            onStoryCompleted?(completedId)
        }
    }

    func completeSession(context: DuckStoryContext) {
        enterFinale(context: context)
    }

    func cancelSession(context: DuckStoryContext) {
        activeStory?.onCancel(context: context, engine: self)
        cleanup()
    }

    func cleanupFinale() {
        isFinaleActive = false
        finaleElapsedTime = 0.0
        activeStory?.cleanupFinale(engine: self)
    }

    func cleanup() {
        let story = activeStory
        currentMilestoneIndex = 0
        lastProgress = 0.0
        isFinaleActive = false
        finaleElapsedTime = 0.0
        isSessionStarted = false
        isSessionPaused = false
        isPrepared = false
        actors.removeAll()
        props.removeAll()
        currentPerformanceOverride = nil
        story?.cleanup(engine: self)
        story?.cleanupFinale(engine: self)
        activeStory = nil
    }

    func tick(dt: Double, now: Date, context: DuckStoryContext) {
        guard isPrepared, isSessionStarted, selectedStoryId != .off else { return }
        guard !isSessionPaused || isFinaleActive else { return }

        let epoch = now.timeIntervalSince1970

        // Update secondary actors movement & animation
        for i in 0..<actors.count {
            actors[i].updateMovement(dt: dt)
            actors[i].updateAnimation(now: epoch)
        }

        // Update prop animation frames
        for i in 0..<props.count {
            props[i].updateAnimation(now: epoch)
        }

        // Tick active story living choreography or resting finale loop
        if isFinaleActive {
            finaleElapsedTime += dt
            activeStory?.updateFinale(dt: dt, now: now, context: context, engine: self)
        } else {
            activeStory?.update(dt: dt, now: now, context: context, engine: self)
        }
    }

    // MARK: - Story Action Helpers

    func setPerformanceOverride(sprite: [String]?, x: Double? = nil, y: Double? = nil, flip: Bool? = nil) {
        currentPerformanceOverride = DuckStoryPerformanceOverride(spriteRows: sprite, x: x, y: y, flip: flip)
    }

    func clearPerformanceOverride() {
        currentPerformanceOverride = nil
    }

    func addActor(_ actor: DuckStoryActor) {
        actors.removeAll { $0.id == actor.id }
        actors.append(actor)
    }

    func removeActor(id: String) {
        actors.removeAll { $0.id == id }
    }

    func clearActors() {
        actors.removeAll()
    }

    func addProp(_ prop: DuckStorySceneryProp) {
        props.removeAll { $0.id == prop.id }
        props.append(prop)
    }

    func removeProp(id: String) {
        props.removeAll { $0.id == id }
    }

    func clearProps() {
        props.removeAll()
    }

    func speak(_ text: String, duration: Double = 2.0) {
        onSpeak?(text, duration)
    }

    func setDuckPose(_ pose: DuckPose, duration: Double = 2.0) {
        onDuckPose?(pose, duration)
    }

    func dropCrumb() {
        onDropCrumb?()
    }

    func playSound(_ name: String) {
        onPlaySound?(name)
    }

    func spawnSteamPuff() {
        onSpawnSteamPuff?()
    }

    func spawnSweat() {
        onSpawnSweat?()
    }

    func getFeastSpriteOverride() -> [String]? {
        if let feast = activeStory as? TheFeastStory {
            return feast.getSpriteOverride()
        }
        return nil
    }
}

// MARK: - Story 1: The Feast

final class TheFeastStory: DuckStory {
    let id: DuckStoryId = .theFeast
    let title: String = "The Feast"
    let description: String = "TimeDuck experiences progressive fullness through continuous feeding and digestion."

    private(set) var fullnessStage: Int = 0 // 0...5
    private(set) var isDigesting = false
    private var digestionStage: Int = 5
    private var nextDigestionStep: Date = .distantPast
    private var lastCrumbStage: Int = -1
    private(set) var sceneElapsedTime: Double = 0.0
    private(set) var activeSceneIndex: Int = 0
    private(set) var isFinaleActive: Bool = false
    private(set) var finaleElapsedTime: Double = 0.0

    func isEligible(context: DuckStoryContext) -> Bool {
        context.mode == .pomodoro || context.mode == .timer
    }

    func prepare(context: DuckStoryContext, engine: DuckStoryEngine) {
        fullnessStage = 0
        isDigesting = false
        digestionStage = 0
        lastCrumbStage = -1
        sceneElapsedTime = 0.0
        activeSceneIndex = 0
        isFinaleActive = false
        finaleElapsedTime = 0.0
    }

    func onStart(context: DuckStoryContext, engine: DuckStoryEngine) {
        fullnessStage = 0
        engine.speak("FUEL ACQUIRED.", duration: 2.0)
        engine.dropCrumb()
    }

    func onProgress(context: DuckStoryContext, progress: Double, engine: DuckStoryEngine) {
        let p = min(1.0, max(0.0, progress))
        let targetStage = min(5, Int(p * 5.0))
        if targetStage != fullnessStage {
            fullnessStage = targetStage
            if targetStage > lastCrumbStage {
                lastCrumbStage = targetStage
                engine.dropCrumb()
            }
        }
    }

    func onMilestone(milestoneIndex: Int, progress: Double, context: DuckStoryContext, engine: DuckStoryEngine) {
        fullnessStage = min(5, milestoneIndex)
        if fullnessStage > lastCrumbStage {
            lastCrumbStage = fullnessStage
            engine.dropCrumb()
        }

        switch milestoneIndex {
        case 1: engine.speak("MORE BREAD?", duration: 2.0)
        case 2: engine.speak("VISIBLE BELLY.", duration: 2.0)
        case 3: engine.speak("THIS SEEMS EXCESSIVE.", duration: 2.0)
        case 4: engine.speak("I REGRET NOTHING.", duration: 2.0)
        case 5: onComplete(context: context, engine: engine)
        default: break
        }
    }

    func onPause(context: DuckStoryContext, engine: DuckStoryEngine) {
        engine.speak("DIGESTION PAUSED.", duration: 2.0)
    }

    func onResume(context: DuckStoryContext, engine: DuckStoryEngine) {
        engine.speak("RESUMING FEAST.", duration: 2.0)
    }

    func onInteraction(type: String, context: DuckStoryContext, engine: DuckStoryEngine) -> String? {
        if isFinaleActive { return "WORTH IT." }
        switch fullnessStage {
        case 0, 1: return "HUNGRY FOR FOCUS."
        case 2, 3: return "PROTECTING THE BREAD."
        case 4, 5: return "CANNOT MOVE. CONTENT."
        default: return "QUACK."
        }
    }

    func onComplete(context: DuckStoryContext, engine: DuckStoryEngine) {
        onEnterFinale(context: context, engine: engine)
    }

    func onEnterFinale(context: DuckStoryContext, engine: DuckStoryEngine) {
        guard !isFinaleActive else { return }
        isFinaleActive = true
        finaleElapsedTime = 0.0
        fullnessStage = 5
        isDigesting = true
        digestionStage = 5
        nextDigestionStep = Date().addingTimeInterval(0.6)
        engine.playSound("duckBurp")
        engine.spawnSteamPuff()
        engine.speak("WORTH IT.", duration: 2.5)
    }

    func onCancel(context: DuckStoryContext, engine: DuckStoryEngine) {
        cleanup(engine: engine)
    }

    func cleanup(engine: DuckStoryEngine) {
        fullnessStage = 0
        isDigesting = false
        digestionStage = 0
        isFinaleActive = false
        finaleElapsedTime = 0.0
        engine.clearPerformanceOverride()
    }

    func cleanupFinale(engine: DuckStoryEngine) {
        isFinaleActive = false
        finaleElapsedTime = 0.0
        isDigesting = false
        digestionStage = 0
        engine.clearPerformanceOverride()
    }

    func getSpriteOverride() -> [String]? {
        if isDigesting {
            switch digestionStage {
            case 5: return DUCK_CHONK_STAGE5
            case 4: return DUCK_CHONK_STAGE4
            case 3: return DUCK_CHONK_STAGE3
            case 2: return DUCK_CHONK_STAGE2
            case 1: return DUCK_CHONK_STAGE1
            default: return nil
            }
        }
        switch fullnessStage {
        case 1: return DUCK_CHONK_STAGE1
        case 2: return DUCK_CHONK_STAGE2
        case 3: return DUCK_CHONK_STAGE3
        case 4: return DUCK_CHONK_STAGE4
        case 5: return DUCK_CHONK_STAGE5
        default: return nil
        }
    }

    func update(dt: Double, now: Date, context: DuckStoryContext, engine: DuckStoryEngine) {
        if isDigesting {
            if now >= nextDigestionStep {
                if digestionStage > 0 {
                    digestionStage -= 1
                    nextDigestionStep = now.addingTimeInterval(0.6)
                    engine.spawnSteamPuff()
                } else {
                    isDigesting = false
                    fullnessStage = 0
                    engine.speak("WE BOTH DID OUR PART.", duration: 2.2)
                    engine.clearPerformanceOverride()
                }
            }
            return
        }

        sceneElapsedTime += dt
        let cycle = sceneElapsedTime.truncatingRemainder(dividingBy: 10.0)

        if context.reduceMotion {
            if let base = getSpriteOverride() {
                engine.setPerformanceOverride(sprite: base, x: 60, y: 58, flip: false)
            }
            return
        }

        // Natural Repeatable Feeding & Fullness Behavior Loop (10s)
        if fullnessStage == 5 {
            // Stage 5 Absolute Unit special micro-behaviors
            if cycle < 3.0 {
                engine.setPerformanceOverride(sprite: DUCK_BELLY_WOBBLE, x: 60, y: 58, flip: false)
            } else if cycle < 6.0 {
                engine.setPerformanceOverride(sprite: DUCK_CHONK_SIT, x: 60, y: 58, flip: false)
            } else if cycle < 8.0 {
                engine.setPerformanceOverride(sprite: DUCK_CHONK_PANT, x: 60, y: 58, flip: false)
            } else {
                engine.setPerformanceOverride(sprite: DUCK_CHONK_STAGE5, x: 60, y: 58, flip: false)
            }
        } else {
            // Normal & progressive feeding cycle
            let baseSprite = getSpriteOverride() ?? DUCK_BASE
            if cycle < 2.0 {
                // Neutral breathing / observation
                engine.setPerformanceOverride(sprite: baseSprite, x: 60, y: 58, flip: false)
            } else if cycle < 3.2 {
                // Anticipation: pulls head back before pecking bread
                engine.setPerformanceOverride(sprite: DUCK_PECK_ANTICIPATE, x: 58, y: 58, flip: true)
            } else if cycle < 4.8 {
                // Peck: beak contacts bread directly
                engine.setPerformanceOverride(sprite: DUCK_PECK_B, x: 52, y: 58, flip: true)
            } else if cycle < 6.5 {
                // Recovery: lifts head with crumb, swallows
                let swallow = (cycle < 5.6) ? DUCK_PECK_RECOVER : DUCK_SWALLOW
                engine.setPerformanceOverride(sprite: swallow, x: 56, y: 58, flip: true)
            } else if cycle < 8.5 {
                // Neutral settle
                engine.setPerformanceOverride(sprite: baseSprite, x: 60, y: 58, flip: false)
            } else {
                // Tail wag satisfaction
                engine.setPerformanceOverride(sprite: DUCK_IDLE_WAG, x: 60, y: 58, flip: false)
            }
        }
    }

    func updateFinale(dt: Double, now: Date, context: DuckStoryContext, engine: DuckStoryEngine) {
        finaleElapsedTime += dt

        if context.reduceMotion {
            engine.setPerformanceOverride(sprite: DUCK_BASE, x: 58, y: 58, flip: false)
            return
        }

        // Finale Entry Transition (0.0 ... 4.0s): Digestion payoff (occurs once)
        if finaleElapsedTime < 4.0 {
            let stage = max(0, min(5, 5 - Int(finaleElapsedTime / 0.8)))
            fullnessStage = stage
            digestionStage = stage
            isDigesting = (stage > 0)
            if let sprite = getSpriteOverride() {
                engine.setPerformanceOverride(sprite: sprite, x: 60, y: 58, flip: false)
            }
            return
        }

        isDigesting = false
        fullnessStage = 0
        digestionStage = 0

        // Seamless Resting Finale Loop (10s repeatable cycle)
        let t = (finaleElapsedTime - 4.0).truncatingRemainder(dividingBy: 10.0)
        let loopTime = t < 0 ? (t + 10.0) : t

        if loopTime < 2.5 {
            // Satisfied normal duck breathing
            engine.setPerformanceOverride(sprite: DUCK_BASE, x: 58, y: 58, flip: false)
        } else if loopTime < 4.5 {
            // Gentle head tilt / belly pat
            engine.setPerformanceOverride(sprite: DUCK_HEAD_TILT, x: 58, y: 58, flip: false)
        } else if loopTime < 6.5 {
            // Sits comfortably
            engine.setPerformanceOverride(sprite: DUCK_SIT_TRANSITION, x: 58, y: 58, flip: false)
        } else if loopTime < 8.5 {
            // Satisfied tail wag
            engine.setPerformanceOverride(sprite: DUCK_IDLE_WAG, x: 58, y: 58, flip: false)
        } else {
            // Calm resting breath
            engine.setPerformanceOverride(sprite: DUCK_BASE, x: 58, y: 58, flip: false)
        }
    }
}

// MARK: - Story 2: The Expedition (Living Mountain Show)

final class TheExpeditionStory: DuckStory {
    let id: DuckStoryId = .theExpedition
    let title: String = "The Expedition"
    let description: String = "TimeDuck hikes, camps, climbs, and summits a mountain."

    private(set) var sceneElapsedTime: Double = 0.0
    private(set) var activeSceneIndex: Int = 0
    private(set) var isFinaleActive: Bool = false
    private(set) var finaleElapsedTime: Double = 0.0

    func isEligible(context: DuckStoryContext) -> Bool {
        context.sessionDuration >= 300
    }

    func prepare(context: DuckStoryContext, engine: DuckStoryEngine) {
        sceneElapsedTime = 0.0
        activeSceneIndex = 0
        isFinaleActive = false
        finaleElapsedTime = 0.0
        engine.clearProps()
        engine.clearActors()
        engine.clearPerformanceOverride()
    }

    func onStart(context: DuckStoryContext, engine: DuckStoryEngine) {
        setupScene(index: 0, engine: engine)
        engine.speak("EXPEDITION COMMENCED.", duration: 2.2)
    }

    func onProgress(context: DuckStoryContext, progress: Double, engine: DuckStoryEngine) {
        let p = min(1.0, max(0.0, progress))
        let targetScene = min(4, Int(p * 5.0))
        if targetScene != activeSceneIndex {
            activeSceneIndex = targetScene
            setupScene(index: targetScene, engine: engine)
        }
    }

    func onMilestone(milestoneIndex: Int, progress: Double, context: DuckStoryContext, engine: DuckStoryEngine) {
        let sceneIdx = min(4, milestoneIndex)
        activeSceneIndex = sceneIdx
        setupScene(index: sceneIdx, engine: engine)
        if milestoneIndex >= 5 {
            onComplete(context: context, engine: engine)
        }
    }

    private func setupScene(index: Int, engine: DuckStoryEngine) {
        sceneElapsedTime = 0.0
        engine.clearProps()
        engine.clearActors()

        switch index {
        case 0: // Scene 1: Departure / Trailhead
            engine.addProp(DuckStorySceneryProp(
                id: "trail_sign", x: 26, y: 55, spriteRows: PROP_TRAIL_SIGN,
                colorMapKey: "wood", flip: false, isVisible: true, zIndex: 0
            ))

        case 1: // Scene 2: Campfire
            let campFrames = [PROP_CAMPFIRE_FRAME1, PROP_CAMPFIRE_FRAME2, PROP_CAMPFIRE_FRAME3, PROP_CAMPFIRE_FRAME4]
            engine.addProp(DuckStorySceneryProp(
                id: "campfire", x: 74, y: 58, frames: campFrames,
                colorMapKey: "fire", flip: false, isVisible: true, zIndex: 0, animationInterval: 0.20
            ))

        case 2: // Scene 3: The Climb
            engine.addProp(DuckStorySceneryProp(
                id: "rock_a", x: 42, y: 64, spriteRows: PROP_CLIMB_ROCK_A,
                colorMapKey: "metal", flip: false, isVisible: true, zIndex: 0
            ))
            engine.addProp(DuckStorySceneryProp(
                id: "rock_b", x: 96, y: 56, spriteRows: PROP_CLIMB_ROCK_B,
                colorMapKey: "metal", flip: false, isVisible: true, zIndex: 0
            ))

        case 3: // Scene 4: Final Ascent Ridge
            break // Pure wind traversal

        case 4: // Scene 5: Summit
            let flagFrames = [PROP_SUMMIT_FLAG_FRAME1, PROP_SUMMIT_FLAG_FRAME2, PROP_SUMMIT_FLAG_FRAME3]
            engine.addProp(DuckStorySceneryProp(
                id: "summit_flag", x: 82, y: 52, frames: flagFrames,
                colorMapKey: "flag", flip: false, isVisible: true, zIndex: 0, animationInterval: 0.25
            ))

        default: break
        }
    }

    func update(dt: Double, now: Date, context: DuckStoryContext, engine: DuckStoryEngine) {
        sceneElapsedTime += dt

        switch activeSceneIndex {
        case 0: // Scene 1: Trailhead Performance Loop (12s)
            let t = sceneElapsedTime.truncatingRemainder(dividingBy: 12.0)
            if t < 3.0 {
                // Studies trail sign (facing sign on left)
                engine.setPerformanceOverride(sprite: DUCK_INVESTIGATE_A, x: 42, y: 58, flip: true)
            } else if t < 5.0 {
                // Checks & rotates map
                let mapSprite = (t > 4.0) ? DUCK_MAP_CHECK_B : DUCK_MAP_CHECK_A
                engine.setPerformanceOverride(sprite: mapSprite, x: 45, y: 58, flip: false)
            } else if t < 6.0 {
                // Folds map, neutral pause
                engine.setPerformanceOverride(sprite: DUCK_BASE, x: 45, y: 58, flip: false)
            } else if t < 9.0 {
                // Confident waddle march right
                let step = Int(t * 3) % 2 == 0 ? DUCK_EXPEDITION_WADDLE_A : DUCK_EXPEDITION_WADDLE_B
                let xPos = 45.0 + (t - 6.0) * 7.0
                engine.setPerformanceOverride(sprite: step, x: xPos, y: 58, flip: false)
            } else if t < 10.2 {
                // Brakes and plants feet
                engine.setPerformanceOverride(sprite: DUCK_BRAKE_STOP, x: 66, y: 58, flip: false)
            } else {
                // Looks ahead at trail horizon
                engine.setPerformanceOverride(sprite: DUCK_INVESTIGATE_B, x: 66, y: 58, flip: false)
            }

        case 1: // Scene 2: Campfire Performance Loop (14s)
            let t = sceneElapsedTime.truncatingRemainder(dividingBy: 14.0)
            if t < 0.8 {
                // Lowers body from standing into sitting
                engine.setPerformanceOverride(sprite: DUCK_SIT_TRANSITION, x: 58, y: 58, flip: false)
            } else if t < 5.0 {
                // Warms wings by fire
                engine.setPerformanceOverride(sprite: DUCK_WARM_WINGS, x: 58, y: 58, flip: false)
            } else if t < 8.0 {
                // Pokes fire with stick
                let poke = (Int(t * 4) % 2 == 0) ? DUCK_POKE_FIRE_A : DUCK_POKE_FIRE_B
                engine.setPerformanceOverride(sprite: poke, x: 58, y: 58, flip: false)
            } else if t < 11.0 {
                // Brief cozy doze by embers
                engine.setPerformanceOverride(sprite: DUCK_DROOP_SLEEP, x: 58, y: 58, flip: false)
            } else if t < 12.5 {
                // Rises up from sit
                engine.setPerformanceOverride(sprite: DUCK_SIT_TRANSITION, x: 58, y: 58, flip: false)
            } else {
                // Wing stretch and gear adjust
                engine.setPerformanceOverride(sprite: DUCK_FEATHER_RUFFLE_A, x: 58, y: 58, flip: false)
            }

        case 2: // Scene 3: The Climb Performance Loop (12s)
            let t = sceneElapsedTime.truncatingRemainder(dividingBy: 12.0)
            if t < 2.5 {
                // Approaches rock, pauses to brace
                engine.setPerformanceOverride(sprite: DUCK_BRAKE_STOP, x: 36, y: 62, flip: false)
            } else if t < 6.0 {
                // Steps up securely onto Rock A
                let step = (Int(t * 3) % 2 == 0) ? DUCK_EXPEDITION_WADDLE_A : DUCK_EXPEDITION_WADDLE_B
                engine.setPerformanceOverride(sprite: step, x: 44, y: 56, flip: false)
            } else if t < 8.0 {
                // Balances on rock, checks footing & wipes brow
                engine.setPerformanceOverride(sprite: DUCK_INVESTIGATE_B, x: 44, y: 56, flip: false)
            } else if t < 11.0 {
                // Steps across to Rock B
                let step = (Int(t * 3) % 2 == 0) ? DUCK_EXPEDITION_WADDLE_A : DUCK_EXPEDITION_WADDLE_B
                let xPos = 44.0 + (t - 8.0) * 5.3
                engine.setPerformanceOverride(sprite: step, x: xPos, y: 54, flip: false)
            } else {
                // Stable balance on mountain ledge
                engine.setPerformanceOverride(sprite: DUCK_BASE, x: 60, y: 54, flip: false)
            }

        case 3: // Scene 4: Final Ascent / Ridge Wind Loop (10s)
            let t = sceneElapsedTime.truncatingRemainder(dividingBy: 10.0)
            if t < 8.5 {
                let lean = (Int(t * 3) % 2 == 0) ? DUCK_WIND_LEAN_A : DUCK_WIND_LEAN_B
                let xPos = 48.0 + (t / 8.5) * 24.0
                engine.setPerformanceOverride(sprite: lean, x: xPos, y: 54, flip: false)
            } else {
                engine.setPerformanceOverride(sprite: DUCK_BASE, x: 72, y: 54, flip: false)
            }

        case 4: // Scene 5: Summit Performance Loop (12s)
            let t = sceneElapsedTime.truncatingRemainder(dividingBy: 12.0)
            if t < 4.0 {
                // Flag planted, double-wing cheer
                engine.setPerformanceOverride(sprite: DUCK_SUMMIT_CHEER, x: 66, y: 52, flip: false)
            } else if t < 8.0 {
                // Imaginary summit photo snapshot pose
                engine.setPerformanceOverride(sprite: DUCK_SUMMIT_PHOTO, x: 66, y: 52, flip: false)
            } else {
                // Admires view from summit
                engine.setPerformanceOverride(sprite: DUCK_PROUD, x: 66, y: 52, flip: false)
            }

        default: break
        }
    }

    func onPause(context: DuckStoryContext, engine: DuckStoryEngine) {
        engine.speak("RESTING ON TRAIL.", duration: 2.0)
    }

    func onResume(context: DuckStoryContext, engine: DuckStoryEngine) {
        engine.speak("PUSHING ONWARD.", duration: 2.0)
    }

    func onInteraction(type: String, context: DuckStoryContext, engine: DuckStoryEngine) -> String? {
        "I'M NAVIGATING."
    }

    func onComplete(context: DuckStoryContext, engine: DuckStoryEngine) {
        onEnterFinale(context: context, engine: engine)
    }

    func onEnterFinale(context: DuckStoryContext, engine: DuckStoryEngine) {
        guard !isFinaleActive else { return }
        isFinaleActive = true
        finaleElapsedTime = 0.0
        engine.clearProps()
        engine.clearActors()
        let flagFrames = [PROP_SUMMIT_FLAG_FRAME1, PROP_SUMMIT_FLAG_FRAME2, PROP_SUMMIT_FLAG_FRAME3]
        engine.addProp(DuckStorySceneryProp(
            id: "summit_flag", x: 36, y: 52, frames: flagFrames,
            colorMapKey: "flag", flip: false, isVisible: true, zIndex: 0, animationInterval: 0.25
        ))
        engine.playSound("flagPlantFanfare")
        engine.speak("FLAG PLANTED. SUMMIT CLEAR.", duration: 2.5)
    }

    func onCancel(context: DuckStoryContext, engine: DuckStoryEngine) {
        cleanup(engine: engine)
    }

    func cleanup(engine: DuckStoryEngine) {
        isFinaleActive = false
        finaleElapsedTime = 0.0
        engine.clearProps()
        engine.clearActors()
        engine.clearPerformanceOverride()
    }

    func cleanupFinale(engine: DuckStoryEngine) {
        isFinaleActive = false
        finaleElapsedTime = 0.0
        engine.clearProps()
        engine.clearActors()
        engine.clearPerformanceOverride()
    }

    func updateFinale(dt: Double, now: Date, context: DuckStoryContext, engine: DuckStoryEngine) {
        finaleElapsedTime += dt

        if context.reduceMotion {
            engine.setPerformanceOverride(sprite: DUCK_PROUD, x: 58, y: 52, flip: false)
            return
        }

        // Finale Entry Transition (0.0 ... 4.0s): Flag planting & victory fanfare payoff (occurs once)
        if finaleElapsedTime < 4.0 {
            if finaleElapsedTime < 1.5 {
                engine.setPerformanceOverride(sprite: DUCK_BRAKE_STOP, x: 58, y: 52, flip: false)
            } else {
                engine.setPerformanceOverride(sprite: DUCK_SUMMIT_CHEER, x: 58, y: 52, flip: false)
            }
            return
        }

        // Seamless Resting Summit Finale Loop (12s repeatable cycle)
        let t = (finaleElapsedTime - 4.0).truncatingRemainder(dividingBy: 12.0)
        let loopTime = t < 0 ? (t + 12.0) : t

        if loopTime < 3.0 {
            // Calm panoramic summit survey beside waving flag
            engine.setPerformanceOverride(sprite: DUCK_PROUD, x: 58, y: 52, flip: false)
        } else if loopTime < 5.5 {
            // Looks toward distant mountain horizon
            engine.setPerformanceOverride(sprite: DUCK_INVESTIGATE_B, x: 58, y: 52, flip: false)
        } else if loopTime < 8.0 {
            // Sits peacefully on summit rock
            engine.setPerformanceOverride(sprite: DUCK_SIT_TRANSITION, x: 58, y: 52, flip: false)
        } else if loopTime < 10.5 {
            // Victorious wing stretch
            engine.setPerformanceOverride(sprite: DUCK_WING_STRETCH, x: 58, y: 58, flip: false)
        } else {
            // Calm standing mountain posture
            engine.setPerformanceOverride(sprite: DUCK_BASE, x: 58, y: 52, flip: false)
        }
    }
}

// MARK: - Story 3: Night Shift (Living Workplace Show)

final class NightShiftStory: DuckStory {
    let id: DuckStoryId = .nightShift
    let title: String = "Night Shift"
    let description: String = "TimeDuck drinks coffee, fights off sleep, and pushes through late-night operations."

    private(set) var sceneElapsedTime: Double = 0.0
    private(set) var activeSceneIndex: Int = 0
    private(set) var isFinaleActive: Bool = false
    private(set) var finaleElapsedTime: Double = 0.0

    func isEligible(context: DuckStoryContext) -> Bool {
        context.localHour >= 22 || context.localHour <= 5
    }

    func prepare(context: DuckStoryContext, engine: DuckStoryEngine) {
        sceneElapsedTime = 0.0
        activeSceneIndex = 0
        isFinaleActive = false
        finaleElapsedTime = 0.0
        engine.clearProps()
        engine.clearActors()
        engine.clearPerformanceOverride()
    }

    func onStart(context: DuckStoryContext, engine: DuckStoryEngine) {
        setupScene(index: 0, engine: engine)
        engine.speak("NIGHT OPERATIONS.", duration: 2.0)
    }

    func onProgress(context: DuckStoryContext, progress: Double, engine: DuckStoryEngine) {
        let p = min(1.0, max(0.0, progress))
        let targetScene = min(4, Int(p * 5.0))
        if targetScene != activeSceneIndex {
            activeSceneIndex = targetScene
            setupScene(index: targetScene, engine: engine)
        }
    }

    func onMilestone(milestoneIndex: Int, progress: Double, context: DuckStoryContext, engine: DuckStoryEngine) {
        let sceneIdx = min(4, milestoneIndex)
        activeSceneIndex = sceneIdx
        setupScene(index: sceneIdx, engine: engine)
        if milestoneIndex >= 5 {
            onComplete(context: context, engine: engine)
        }
    }

    private func setupScene(index: Int, engine: DuckStoryEngine) {
        sceneElapsedTime = 0.0
        engine.clearProps()
        engine.clearActors()

        let steamFrames = [PROP_COFFEE_CUP_FRAME1, PROP_COFFEE_CUP_FRAME2]

        switch index {
        case 0, 1: // Coffee cup on desk
            engine.addProp(DuckStorySceneryProp(
                id: "coffee_cup", x: 44, y: 58, frames: steamFrames,
                colorMapKey: "coffee", flip: false, isVisible: true, zIndex: 0, animationInterval: 0.30
            ))
        case 2, 3, 4: // Coffee cup stack
            engine.addProp(DuckStorySceneryProp(
                id: "coffee_stack", x: 44, y: 54, spriteRows: PROP_COFFEE_STACK,
                colorMapKey: "coffee", flip: false, isVisible: true, zIndex: 0
            ))
        default: break
        }
    }

    func update(dt: Double, now: Date, context: DuckStoryContext, engine: DuckStoryEngine) {
        sceneElapsedTime += dt

        switch activeSceneIndex {
        case 0: // Scene 1: Alert & Sips Coffee (12s loop)
            let t = sceneElapsedTime.truncatingRemainder(dividingBy: 12.0)
            if t < 3.0 {
                // Sips steaming coffee
                engine.setPerformanceOverride(sprite: DUCK_SWALLOW, x: 56, y: 58, flip: true)
            } else if t < 4.5 {
                // Sets mug down, refreshed tail wag
                engine.setPerformanceOverride(sprite: DUCK_IDLE_WAG, x: 56, y: 58, flip: false)
            } else if t < 7.0 {
                // Focus typing at desk
                engine.setPerformanceOverride(sprite: DUCK_BASE, x: 56, y: 58, flip: false)
            } else if t < 9.5 {
                // Focused pacing waddle
                let step = (Int(t * 3) % 2 == 0) ? DUCK_WADDLE_A : DUCK_WADDLE_B
                let xPos = 56.0 + (t - 7.0) * 4.0
                engine.setPerformanceOverride(sprite: step, x: xPos, y: 58, flip: false)
            } else if t < 10.8 {
                // Brakes and settles
                engine.setPerformanceOverride(sprite: DUCK_BRAKE_STOP, x: 66, y: 58, flip: false)
            } else {
                engine.setPerformanceOverride(sprite: DUCK_BASE, x: 56, y: 58, flip: false)
            }

        case 1: // Scene 2: Yawning & Droop (12s loop)
            let t = sceneElapsedTime.truncatingRemainder(dividingBy: 12.0)
            if t < 3.5 {
                engine.setPerformanceOverride(sprite: DUCK_BASE, x: 60, y: 58, flip: false)
            } else if t < 6.5 {
                engine.setPerformanceOverride(sprite: DUCK_YAWN, x: 60, y: 58, flip: false)
            } else if t < 9.5 {
                engine.setPerformanceOverride(sprite: DUCK_FEATHER_RUFFLE_A, x: 60, y: 58, flip: false)
            } else {
                engine.setPerformanceOverride(sprite: DUCK_BASE, x: 60, y: 58, flip: false)
            }

        case 2: // Scene 3: Droop Sleep & Face Splash (12s loop)
            let t = sceneElapsedTime.truncatingRemainder(dividingBy: 12.0)
            if t < 4.0 {
                // Heavy eyelids slowly droop
                engine.setPerformanceOverride(sprite: DUCK_NIGHT_DROOP, x: 65, y: 58, flip: false)
            } else if t < 6.0 {
                // Snap awake
                engine.setPerformanceOverride(sprite: DUCK_NIGHT_SNAP_AWAKE, x: 65, y: 58, flip: false)
            } else if t < 9.0 {
                // Cold face splash
                engine.setPerformanceOverride(sprite: DUCK_NIGHT_FACE_SPLASH, x: 65, y: 58, flip: false)
            } else {
                // Refreshed posture
                engine.setPerformanceOverride(sprite: DUCK_INVESTIGATE_B, x: 65, y: 58, flip: false)
            }

        case 3: // Scene 4: Blanket Battle (14s loop)
            let t = sceneElapsedTime.truncatingRemainder(dividingBy: 14.0)
            if t < 2.5 {
                // Shivers
                engine.setPerformanceOverride(sprite: DUCK_CONFUSED_A, x: 65, y: 58, flip: false)
            } else if t < 6.5 {
                // Cozy blanket burrito
                engine.setPerformanceOverride(sprite: DUCK_NIGHT_BLANKET_THROW, x: 65, y: 58, flip: false)
            } else if t < 10.0 {
                // Peaceful micro-snooze
                engine.setPerformanceOverride(sprite: DUCK_DROOP_SLEEP, x: 65, y: 58, flip: false)
            } else if t < 12.0 {
                // Tosses blanket off
                engine.setPerformanceOverride(sprite: DUCK_NIGHT_BLANKET_THROW, x: 65, y: 58, flip: false)
            } else {
                engine.setPerformanceOverride(sprite: DUCK_BASE, x: 65, y: 58, flip: false)
            }

        case 4: // Scene 5: Final Stretch & Sunrise (10s loop)
            let t = sceneElapsedTime.truncatingRemainder(dividingBy: 10.0)
            if t < 5.0 {
                engine.setPerformanceOverride(sprite: DUCK_WING_STRETCH, x: 65, y: 58, flip: false)
            } else {
                engine.setPerformanceOverride(sprite: DUCK_PROUD, x: 65, y: 58, flip: false)
            }

        default: break
        }
    }

    func onPause(context: DuckStoryContext, engine: DuckStoryEngine) {
        engine.speak("STANDBY IN DARKNESS.", duration: 2.0)
    }

    func onResume(context: DuckStoryContext, engine: DuckStoryEngine) {
        engine.speak("BACK ON SHIFT.", duration: 2.0)
    }

    func onInteraction(type: String, context: DuckStoryContext, engine: DuckStoryEngine) -> String? {
        "THAT DIDN'T HELP."
    }

    func onComplete(context: DuckStoryContext, engine: DuckStoryEngine) {
        onEnterFinale(context: context, engine: engine)
    }

    func onEnterFinale(context: DuckStoryContext, engine: DuckStoryEngine) {
        guard !isFinaleActive else { return }
        isFinaleActive = true
        finaleElapsedTime = 0.0
        engine.clearProps()
        engine.clearActors()
        engine.speak("NIGHT DUTY CLEAR. WORTH IT.", duration: 2.5)
    }

    func onCancel(context: DuckStoryContext, engine: DuckStoryEngine) {
        cleanup(engine: engine)
    }

    func cleanup(engine: DuckStoryEngine) {
        isFinaleActive = false
        finaleElapsedTime = 0.0
        engine.clearProps()
        engine.clearActors()
        engine.clearPerformanceOverride()
    }

    func cleanupFinale(engine: DuckStoryEngine) {
        isFinaleActive = false
        finaleElapsedTime = 0.0
        engine.clearProps()
        engine.clearActors()
        engine.clearPerformanceOverride()
    }

    func updateFinale(dt: Double, now: Date, context: DuckStoryContext, engine: DuckStoryEngine) {
        finaleElapsedTime += dt

        if context.reduceMotion {
            engine.setPerformanceOverride(sprite: DUCK_SLEEP_DEEP, x: 56, y: 58, flip: false)
            return
        }

        // Finale Entry Transition (0.0 ... 3.0s): Relief & collapse into sleep (occurs once)
        if finaleElapsedTime < 3.0 {
            if finaleElapsedTime < 1.5 {
                engine.setPerformanceOverride(sprite: DUCK_IDLE_WAG, x: 56, y: 58, flip: false)
            } else {
                engine.setPerformanceOverride(sprite: DUCK_NIGHT_DROOP, x: 56, y: 58, flip: false)
            }
            return
        }

        // Seamless Resting Sleep Finale Loop (8s repeatable cycle)
        let t = (finaleElapsedTime - 3.0).truncatingRemainder(dividingBy: 8.0)
        let loopTime = t < 0 ? (t + 8.0) : t

        if loopTime < 5.5 {
            // Deep peaceful sleep
            engine.setPerformanceOverride(sprite: DUCK_SLEEP_DEEP, x: 56, y: 58, flip: false)
        } else if loopTime < 6.5 {
            // Sleepy feather twitch / deep breath
            engine.setPerformanceOverride(sprite: DUCK_NIGHT_DROOP, x: 56, y: 58, flip: false)
        } else {
            // Returns to deep sleep
            engine.setPerformanceOverride(sprite: DUCK_SLEEP_DEEP, x: 56, y: 58, flip: false)
        }
    }
}

// MARK: - Story 4: The WOD (Living Gym Show)

final class TheWodStory: DuckStory {
    let id: DuckStoryId = .theWod
    let title: String = "The WOD"
    let description: String = "TimeDuck works out on elliptical, treadmill, and dumbbells in a tiny procedural gym."

    private(set) var sceneElapsedTime: Double = 0.0
    private(set) var activeSceneIndex: Int = 0
    private(set) var isFinaleActive: Bool = false
    private(set) var finaleElapsedTime: Double = 0.0
    private var lastGymTickBeat: Int = -1
    private var lastSweatBeat: Int = -1

    func isEligible(context: DuckStoryContext) -> Bool {
        context.mode == .stopwatch || context.sessionDuration >= 180
    }

    func prepare(context: DuckStoryContext, engine: DuckStoryEngine) {
        sceneElapsedTime = 0.0
        activeSceneIndex = 0
        isFinaleActive = false
        finaleElapsedTime = 0.0
        lastGymTickBeat = -1
        lastSweatBeat = -1
        engine.clearProps()
        engine.clearActors()
        engine.clearPerformanceOverride()
    }

    func onStart(context: DuckStoryContext, engine: DuckStoryEngine) {
        setupScene(index: 0, engine: engine)
        engine.speak("TODAY'S WOD: SURVIVE.", duration: 2.0)
    }

    func onProgress(context: DuckStoryContext, progress: Double, engine: DuckStoryEngine) {
        let p = min(1.0, max(0.0, progress))
        let targetScene = min(4, Int(p * 5.0))
        if targetScene != activeSceneIndex {
            activeSceneIndex = targetScene
            setupScene(index: targetScene, engine: engine)
        }
    }

    func onMilestone(milestoneIndex: Int, progress: Double, context: DuckStoryContext, engine: DuckStoryEngine) {
        let sceneIdx = min(4, milestoneIndex)
        activeSceneIndex = sceneIdx
        setupScene(index: sceneIdx, engine: engine)
        if milestoneIndex >= 5 {
            onComplete(context: context, engine: engine)
        }
    }

    private func setupScene(index: Int, engine: DuckStoryEngine) {
        sceneElapsedTime = 0.0
        lastGymTickBeat = -1
        lastSweatBeat = -1
        engine.clearProps()
        engine.clearActors()

        switch index {
        case 0: // Warmup & Chalkboard
            engine.addProp(DuckStorySceneryProp(
                id: "workout_board", x: 28, y: 52, spriteRows: PROP_WORKOUT_BOARD,
                colorMapKey: "wood", flip: false, isVisible: true, zIndex: 0
            ))

        case 1: // Elliptical Machine (Animated Pedals)
            let ellipFrames = [PROP_ELLIPTICAL_FRAME_A, PROP_ELLIPTICAL_FRAME_B]
            engine.addProp(DuckStorySceneryProp(
                id: "elliptical", x: 68, y: 52, frames: ellipFrames,
                colorMapKey: "gym", flip: false, isVisible: true, zIndex: 0, animationInterval: 0.22
            ))

        case 2: // Treadmill (Animated Moving Belt)
            let treadFrames = [PROP_TREADMILL_FRAME_A, PROP_TREADMILL_FRAME_B]
            engine.addProp(DuckStorySceneryProp(
                id: "treadmill", x: 64, y: 58, frames: treadFrames,
                colorMapKey: "gym", flip: false, isVisible: true, zIndex: 0, animationInterval: 0.16
            ))

        case 3: // Dumbbells
            engine.addProp(DuckStorySceneryProp(
                id: "dumbbells", x: 32, y: 58, spriteRows: PROP_DUMBBELLS,
                colorMapKey: "metal", flip: false, isVisible: true, zIndex: 0
            ))

        case 4: // Flex Victory
            break

        default: break
        }
    }

    func update(dt: Double, now: Date, context: DuckStoryContext, engine: DuckStoryEngine) {
        sceneElapsedTime += dt

        switch activeSceneIndex {
        case 0: // Scene 1: Jumping Jacks & Board (10s loop)
            let t = sceneElapsedTime.truncatingRemainder(dividingBy: 10.0)
            if t < 3.0 {
                engine.setPerformanceOverride(sprite: DUCK_INVESTIGATE_A, x: 50, y: 58, flip: true)
            } else if t < 7.0 {
                let jack = (Int(t * 4) % 2 == 0) ? DUCK_WOD_WARMUP_A : DUCK_WOD_WARMUP_B
                engine.setPerformanceOverride(sprite: jack, x: 58, y: 58, flip: false)
            } else {
                engine.setPerformanceOverride(sprite: DUCK_FEATHER_RUFFLE_A, x: 58, y: 58, flip: false)
            }

        case 1: // Scene 2: ON THE ELLIPTICAL MACHINE (12s loop)
            let t = sceneElapsedTime.truncatingRemainder(dividingBy: 12.0)
            if t < 9.0 {
                let beat = Int(t * 4.5)
                let pedalFrame = (beat % 2 == 0) ? DUCK_ELLIPTICAL_A : DUCK_ELLIPTICAL_B
                engine.setPerformanceOverride(sprite: pedalFrame, x: 72, y: 48, flip: false)
                if beat != lastGymTickBeat && beat % 8 == 0 {
                    engine.playSound("gymTick")
                }
                lastGymTickBeat = beat
            } else {
                // Catch breath on handlebars
                engine.setPerformanceOverride(sprite: DUCK_IDLE_B, x: 72, y: 48, flip: false)
            }

        case 2: // Scene 3: ON THE TREADMILL BELT (12s loop)
            let t = sceneElapsedTime.truncatingRemainder(dividingBy: 12.0)
            if t < 9.0 {
                let beat = Int(t * 6.0)
                let runFrame = (beat % 2 == 0) ? DUCK_TREADMILL_A : DUCK_TREADMILL_B
                engine.setPerformanceOverride(sprite: runFrame, x: 72, y: 54, flip: false)
                if beat != lastSweatBeat && beat % 6 == 0 {
                    engine.spawnSweat()
                }
                lastSweatBeat = beat
            } else {
                // Slows to walk and wipes brow
                engine.setPerformanceOverride(sprite: DUCK_INVESTIGATE_B, x: 72, y: 54, flip: false)
            }

        case 3: // Scene 4: Dumbbell Curls (12s loop)
            let t = sceneElapsedTime.truncatingRemainder(dividingBy: 12.0)
            if t < 6.0 {
                // Curls up
                let curl = (Int(t * 2.5) % 2 == 0) ? DUCK_DUMBBELL_A : DUCK_DUMBBELL_B
                engine.setPerformanceOverride(sprite: curl, x: 65, y: 56, flip: false)
            } else if t < 8.5 {
                // Holds peak contraction
                engine.setPerformanceOverride(sprite: DUCK_DUMBBELL_B, x: 65, y: 56, flip: false)
            } else if t < 10.0 {
                // Lowers smoothly
                engine.setPerformanceOverride(sprite: DUCK_DUMBBELL_A, x: 65, y: 56, flip: false)
            } else if t < 11.2 {
                // Braces knees & wings
                engine.setPerformanceOverride(sprite: DUCK_WEIGHT_BRACE, x: 65, y: 56, flip: false)
            } else {
                // Rests wings
                engine.setPerformanceOverride(sprite: DUCK_BASE, x: 65, y: 58, flip: false)
            }

        case 4: // Scene 5: Flex Victory Pose (10s loop)
            let t = sceneElapsedTime.truncatingRemainder(dividingBy: 10.0)
            if t < 5.0 {
                engine.setPerformanceOverride(sprite: DUCK_WOD_FLEX, x: 65, y: 58, flip: false)
            } else {
                engine.setPerformanceOverride(sprite: DUCK_PROUD, x: 65, y: 58, flip: false)
            }

        default: break
        }
    }

    func onPause(context: DuckStoryContext, engine: DuckStoryEngine) {
        engine.speak("WATER BREAK.", duration: 2.0)
    }

    func onResume(context: DuckStoryContext, engine: DuckStoryEngine) {
        engine.speak("BACK TO THE SET.", duration: 2.0)
    }

    func onInteraction(type: String, context: DuckStoryContext, engine: DuckStoryEngine) -> String? {
        "REST BETWEEN SETS."
    }

    func onComplete(context: DuckStoryContext, engine: DuckStoryEngine) {
        onEnterFinale(context: context, engine: engine)
    }

    func onEnterFinale(context: DuckStoryContext, engine: DuckStoryEngine) {
        guard !isFinaleActive else { return }
        isFinaleActive = true
        finaleElapsedTime = 0.0
        engine.clearProps()
        engine.clearActors()
        engine.speak("WORKOUT COMPLETE.", duration: 2.5)
    }

    func onCancel(context: DuckStoryContext, engine: DuckStoryEngine) {
        cleanup(engine: engine)
    }

    func cleanup(engine: DuckStoryEngine) {
        isFinaleActive = false
        finaleElapsedTime = 0.0
        engine.clearProps()
        engine.clearActors()
        engine.clearPerformanceOverride()
    }

    func cleanupFinale(engine: DuckStoryEngine) {
        isFinaleActive = false
        finaleElapsedTime = 0.0
        engine.clearProps()
        engine.clearActors()
        engine.clearPerformanceOverride()
    }

    func updateFinale(dt: Double, now: Date, context: DuckStoryContext, engine: DuckStoryEngine) {
        finaleElapsedTime += dt

        if context.reduceMotion {
            engine.setPerformanceOverride(sprite: DUCK_WOD_FLEX, x: 65, y: 58, flip: false)
            return
        }

        // Finale Entry Transition (0.0 ... 3.5s): Catches breath & victory celebration (occurs once)
        if finaleElapsedTime < 3.5 {
            if finaleElapsedTime < 1.5 {
                engine.setPerformanceOverride(sprite: DUCK_BRAKE_STOP, x: 65, y: 58, flip: false)
            } else {
                engine.setPerformanceOverride(sprite: DUCK_WOD_FLEX, x: 65, y: 58, flip: false)
            }
            return
        }

        // Seamless Resting Finale Loop (10s repeatable cycle)
        let t = (finaleElapsedTime - 3.5).truncatingRemainder(dividingBy: 10.0)
        let loopTime = t < 0 ? (t + 10.0) : t

        if loopTime < 2.5 {
            // Victorious bicep flex
            engine.setPerformanceOverride(sprite: DUCK_WOD_FLEX, x: 65, y: 58, flip: false)
        } else if loopTime < 5.0 {
            // Relaxes, wipes brow / sips water
            engine.setPerformanceOverride(sprite: DUCK_SWALLOW, x: 65, y: 58, flip: false)
        } else if loopTime < 7.5 {
            // Sits on gym floor to rest legs
            engine.setPerformanceOverride(sprite: DUCK_SIT_TRANSITION, x: 65, y: 58, flip: false)
        } else {
            // Stands up proud and energized
            engine.setPerformanceOverride(sprite: DUCK_PROUD, x: 65, y: 58, flip: false)
        }
    }
}

// MARK: - Story 5: The Rescue (Living Stealth Comedy Show)

final class TheRescueStory: DuckStory {
    let id: DuckStoryId = .theRescue
    let title: String = "The Rescue"
    let description: String = "An original stealth comedy where TimeDuck infiltrates, bypasses cameras/guards, and rescues Girl Duck."

    private(set) var sceneElapsedTime: Double = 0.0
    private(set) var activeSceneIndex: Int = 0
    private(set) var isFinaleActive: Bool = false
    private(set) var finaleElapsedTime: Double = 0.0

    func isEligible(context: DuckStoryContext) -> Bool {
        context.sessionDuration >= 300
    }

    func prepare(context: DuckStoryContext, engine: DuckStoryEngine) {
        sceneElapsedTime = 0.0
        activeSceneIndex = 0
        isFinaleActive = false
        finaleElapsedTime = 0.0
        engine.clearProps()
        engine.clearActors()
        engine.clearPerformanceOverride()
    }

    func onStart(context: DuckStoryContext, engine: DuckStoryEngine) {
        setupScene(index: 0, engine: engine)
        engine.speak("STEALTH LEVEL: BIRD.", duration: 2.0)
    }

    func onProgress(context: DuckStoryContext, progress: Double, engine: DuckStoryEngine) {
        let p = min(1.0, max(0.0, progress))
        let targetScene = min(4, Int(p * 5.0))
        if targetScene != activeSceneIndex {
            activeSceneIndex = targetScene
            setupScene(index: targetScene, engine: engine)
        }
    }

    func onMilestone(milestoneIndex: Int, progress: Double, context: DuckStoryContext, engine: DuckStoryEngine) {
        let sceneIdx = min(4, milestoneIndex)
        activeSceneIndex = sceneIdx
        setupScene(index: sceneIdx, engine: engine)
        if milestoneIndex >= 5 {
            onComplete(context: context, engine: engine)
        }
    }

    private func setupScene(index: Int, engine: DuckStoryEngine) {
        sceneElapsedTime = 0.0
        engine.clearProps()
        engine.clearActors()

        switch index {
        case 0: // Scene 1: Infiltration (Metal Crate)
            engine.addProp(DuckStorySceneryProp(
                id: "metal_crate", x: 62, y: 58, spriteRows: PROP_METAL_CRATE,
                colorMapKey: "metal", flip: false, isVisible: true, zIndex: 0
            ))

        case 1: // Scene 2: Security Camera Sweep (Sweeping Camera)
            let camFrames = [PROP_SECURITY_CAMERA_LEFT, PROP_SECURITY_CAMERA_CENTER, PROP_SECURITY_CAMERA_RIGHT]
            engine.addProp(DuckStorySceneryProp(
                id: "security_cam", x: 125, y: 32, frames: camFrames,
                colorMapKey: "metal", flip: false, isVisible: true, zIndex: 0, animationInterval: 0.60
            ))

        case 2: // Scene 3: Guard Duck Patrol
            engine.addProp(DuckStorySceneryProp(
                id: "metal_crate", x: 44, y: 58, spriteRows: PROP_METAL_CRATE,
                colorMapKey: "metal", flip: false, isVisible: true, zIndex: 1
            ))
            engine.addActor(DuckStoryActor(
                id: "guard_duck", name: "Guard Duck", x: 110, y: 58,
                spriteRows: ACTOR_GUARD_DUCK_PATROL_A, colorMapOverride: nil,
                flip: true, isVisible: true, targetX: nil, moveSpeed: 0.0
            ))

        case 3: // Scene 4: Girl Duck Rescue
            engine.addProp(DuckStorySceneryProp(
                id: "facility_vent", x: 120, y: 56, spriteRows: PROP_FACILITY_VENT,
                colorMapKey: "metal", flip: false, isVisible: true, zIndex: 0
            ))
            engine.addActor(DuckStoryActor(
                id: "girl_duck", name: "Girl Duck", x: 102, y: 58,
                spriteRows: ACTOR_GIRL_DUCK_BASE, colorMapOverride: nil,
                flip: true, isVisible: true, targetX: nil, moveSpeed: 0.0
            ))

        case 4: // Scene 5: Escape Sprint
            let lightFrames = [PROP_SECURITY_LIGHT_ON, PROP_SECURITY_LIGHT_OFF]
            engine.addProp(DuckStorySceneryProp(
                id: "warning_light", x: 78, y: 30, frames: lightFrames,
                colorMapKey: "flag", flip: false, isVisible: true, zIndex: 0, animationInterval: 0.35
            ))
            engine.addActor(DuckStoryActor(
                id: "girl_duck", name: "Girl Duck", x: 75, y: 58,
                spriteRows: ACTOR_GIRL_DUCK_WADDLE_A, colorMapOverride: nil,
                flip: false, isVisible: true, targetX: nil, moveSpeed: 0.0
            ))

        default: break
        }
    }

    func update(dt: Double, now: Date, context: DuckStoryContext, engine: DuckStoryEngine) {
        sceneElapsedTime += dt

        switch activeSceneIndex {
        case 0: // Scene 1: Sneak & Peek Loop (10s)
            let t = sceneElapsedTime.truncatingRemainder(dividingBy: 10.0)
            if t < 4.0 {
                let step = (Int(t * 3) % 2 == 0) ? DUCK_STEALTH_TIPTOE_A : DUCK_STEALTH_TIPTOE_B
                let xPos = 18.0 + (t / 4.0) * 30.0
                engine.setPerformanceOverride(sprite: step, x: xPos, y: 58, flip: false)
            } else if t < 5.5 {
                engine.setPerformanceOverride(sprite: DUCK_BRAKE_STOP, x: 48, y: 58, flip: false)
            } else if t < 8.5 {
                engine.setPerformanceOverride(sprite: DUCK_STEALTH_CORNER_PEEK, x: 48, y: 58, flip: false)
            } else {
                engine.setPerformanceOverride(sprite: DUCK_STEALTH_CROUCH, x: 48, y: 58, flip: false)
            }

        case 1: // Scene 2: Camera Reaction Choreography (10s)
            let t = sceneElapsedTime.truncatingRemainder(dividingBy: 10.0)
            if t < 2.5 {
                // Camera pointing away -> TimeDuck dashes forward
                let step = (Int(t * 4) % 2 == 0) ? DUCK_STEALTH_TIPTOE_A : DUCK_STEALTH_TIPTOE_B
                engine.setPerformanceOverride(sprite: step, x: 35.0 + t * 12.0, y: 58, flip: false)
            } else if t < 3.5 {
                // Camera begins sweep -> Anticipation & drop box
                engine.setPerformanceOverride(sprite: DUCK_STEALTH_BOX_DISGUISE, x: 65, y: 58, flip: false)
            } else if t < 7.0 {
                // Camera sweeping over -> Motionless inside box
                engine.setPerformanceOverride(sprite: DUCK_STEALTH_BOX_DISGUISE, x: 65, y: 58, flip: false)
            } else {
                // Camera passed -> Peeks out
                engine.setPerformanceOverride(sprite: DUCK_STEALTH_CORNER_PEEK, x: 65, y: 58, flip: false)
            }

        case 2: // Scene 3: Guard Patrol Sync (14s)
            let t = sceneElapsedTime.truncatingRemainder(dividingBy: 14.0)
            // Update Guard Duck Patrol Animation & Pivot
            if t < 4.5 {
                let guardStep = (Int(t * 3) % 2 == 0) ? ACTOR_GUARD_DUCK_PATROL_A : ACTOR_GUARD_DUCK_PATROL_B
                let guardX = 110.0 - (t / 4.5) * 38.0
                engine.addActor(DuckStoryActor(
                    id: "guard_duck", name: "Guard Duck", x: guardX, y: 58,
                    spriteRows: guardStep, colorMapOverride: nil, flip: true, isVisible: true
                ))
                engine.setPerformanceOverride(sprite: DUCK_STEALTH_CROUCH, x: 44, y: 58, flip: false)
            } else if t < 5.5 {
                engine.addActor(DuckStoryActor(
                    id: "guard_duck", name: "Guard Duck", x: 72, y: 58,
                    spriteRows: ACTOR_GUARD_DUCK_STOP, colorMapOverride: nil, flip: true, isVisible: true
                ))
                engine.setPerformanceOverride(sprite: DUCK_STEALTH_CROUCH, x: 44, y: 58, flip: false)
            } else if t < 7.0 {
                // Guard pivot turn facing front
                let guardPose = (t < 6.2) ? ACTOR_GUARD_DUCK_TURN : ACTOR_GUARD_DUCK_SUSPICIOUS
                engine.addActor(DuckStoryActor(
                    id: "guard_duck", name: "Guard Duck", x: 72, y: 58,
                    spriteRows: guardPose, colorMapOverride: nil, flip: false, isVisible: true
                ))
                engine.setPerformanceOverride(sprite: DUCK_STEALTH_CROUCH, x: 44, y: 58, flip: false)
            } else if t < 11.5 {
                let guardStep = (Int(t * 3) % 2 == 0) ? ACTOR_GUARD_DUCK_PATROL_A : ACTOR_GUARD_DUCK_PATROL_B
                let guardX = 72.0 + ((t - 7.0) / 4.5) * 38.0
                engine.addActor(DuckStoryActor(
                    id: "guard_duck", name: "Guard Duck", x: guardX, y: 58,
                    spriteRows: guardStep, colorMapOverride: nil, flip: false, isVisible: true
                ))
                // TimeDuck sneaks behind guard
                let step = (Int(t * 3) % 2 == 0) ? DUCK_STEALTH_TIPTOE_A : DUCK_STEALTH_TIPTOE_B
                let xPos = 44.0 + ((t - 7.0) / 4.5) * 32.0
                engine.setPerformanceOverride(sprite: step, x: xPos, y: 58, flip: false)
            } else if t < 12.5 {
                engine.addActor(DuckStoryActor(
                    id: "guard_duck", name: "Guard Duck", x: 110, y: 58,
                    spriteRows: ACTOR_GUARD_DUCK_STOP, colorMapOverride: nil, flip: false, isVisible: true
                ))
                engine.setPerformanceOverride(sprite: DUCK_STEALTH_CROUCH, x: 76, y: 58, flip: false)
            } else {
                engine.addActor(DuckStoryActor(
                    id: "guard_duck", name: "Guard Duck", x: 110, y: 58,
                    spriteRows: ACTOR_GUARD_DUCK_TURN, colorMapOverride: nil, flip: true, isVisible: true
                ))
                engine.setPerformanceOverride(sprite: DUCK_STEALTH_CROUCH, x: 76, y: 58, flip: false)
            }

        case 3: // Scene 4: Girl Duck Reunion & Vent Kick (12s)
            let t = sceneElapsedTime.truncatingRemainder(dividingBy: 12.0)
            if t < 3.0 {
                // TimeDuck arrives, Girl Duck notices with blush
                engine.addActor(DuckStoryActor(
                    id: "girl_duck", name: "Girl Duck", x: 102, y: 58,
                    spriteRows: ACTOR_GIRL_DUCK_NOTICE, colorMapOverride: nil, flip: true, isVisible: true
                ))
                engine.setPerformanceOverride(sprite: DUCK_HEAD_TILT, x: 74, y: 58, flip: false)
            } else if t < 5.5 {
                // Girl Duck waddles over to facility vent
                let step = (Int(t * 3) % 2 == 0) ? ACTOR_GIRL_DUCK_WADDLE_A : ACTOR_GIRL_DUCK_WADDLE_B
                let girlX = 102.0 + ((t - 3.0) / 2.5) * 10.0
                engine.addActor(DuckStoryActor(
                    id: "girl_duck", name: "Girl Duck", x: girlX, y: 58,
                    spriteRows: step, colorMapOverride: nil, flip: false, isVisible: true
                ))
                engine.setPerformanceOverride(sprite: DUCK_BASE, x: 74, y: 58, flip: false)
            } else if t < 6.8 {
                // Girl Duck winds up leg in anticipation
                engine.addActor(DuckStoryActor(
                    id: "girl_duck", name: "Girl Duck", x: 112, y: 58,
                    spriteRows: ACTOR_GIRL_DUCK_KICK_ANTICIPATE, colorMapOverride: nil, flip: false, isVisible: true
                ))
                engine.setPerformanceOverride(sprite: DUCK_INVESTIGATE_B, x: 74, y: 58, flip: false)
            } else if t < 8.2 {
                // Girl Duck kicks vent with physical foot contact!
                engine.addActor(DuckStoryActor(
                    id: "girl_duck", name: "Girl Duck", x: 112, y: 58,
                    spriteRows: ACTOR_GIRL_DUCK_KICK, colorMapOverride: nil, flip: false, isVisible: true
                ))
                engine.setPerformanceOverride(sprite: DUCK_PROUD, x: 74, y: 58, flip: false)
            } else if t < 9.5 {
                // Girl Duck recovers foot, turns back
                engine.addActor(DuckStoryActor(
                    id: "girl_duck", name: "Girl Duck", x: 112, y: 58,
                    spriteRows: ACTOR_GIRL_DUCK_KICK_RECOVER, colorMapOverride: nil, flip: true, isVisible: true
                ))
                engine.setPerformanceOverride(sprite: DUCK_PROUD, x: 74, y: 58, flip: false)
            } else {
                // Both ready for freedom leap
                engine.addActor(DuckStoryActor(
                    id: "girl_duck", name: "Girl Duck", x: 108, y: 58,
                    spriteRows: ACTOR_GIRL_DUCK_IDLE_B, colorMapOverride: nil, flip: true, isVisible: true
                ))
                engine.setPerformanceOverride(sprite: DUCK_BASE, x: 74, y: 58, flip: false)
            }

        case 4: // Scene 5: Coordinated Sprint & Freedom Leap (10s)
            let t = sceneElapsedTime.truncatingRemainder(dividingBy: 10.0)
            if t < 4.0 {
                // Coordinated sprint across stage
                let duckStep = (Int(t * 4) % 2 == 0) ? DUCK_STEALTH_TIPTOE_A : DUCK_STEALTH_TIPTOE_B
                let girlStep = (Int(t * 4) % 2 == 0) ? ACTOR_GIRL_DUCK_WADDLE_A : ACTOR_GIRL_DUCK_WADDLE_B
                let duckX = 55.0 + (t / 4.0) * 40.0
                let girlX = 75.0 + (t / 4.0) * 40.0
                engine.addActor(DuckStoryActor(
                    id: "girl_duck", name: "Girl Duck", x: girlX, y: 58,
                    spriteRows: girlStep, colorMapOverride: nil, flip: false, isVisible: true
                ))
                engine.setPerformanceOverride(sprite: duckStep, x: duckX, y: 58, flip: false)
            } else if t < 5.2 {
                // Crouch anticipation before jump
                engine.addActor(DuckStoryActor(
                    id: "girl_duck", name: "Girl Duck", x: 115, y: 58,
                    spriteRows: ACTOR_GIRL_DUCK_KICK_ANTICIPATE, colorMapOverride: nil, flip: false, isVisible: true
                ))
                engine.setPerformanceOverride(sprite: DUCK_LEAP_ANTICIPATE, x: 95, y: 58, flip: false)
            } else if t < 7.5 {
                // Airborne freedom leap together!
                let girlJump = (Int(t * 4) % 2 == 0) ? ACTOR_GIRL_DUCK_CHEER_A : ACTOR_GIRL_DUCK_CHEER_B
                engine.addActor(DuckStoryActor(
                    id: "girl_duck", name: "Girl Duck", x: 122, y: 48,
                    spriteRows: girlJump, colorMapOverride: nil, flip: false, isVisible: true
                ))
                engine.setPerformanceOverride(sprite: DUCK_STEALTH_LEAP, x: 105, y: 48, flip: false)
            } else if t < 9.0 {
                // Cushion landing
                engine.addActor(DuckStoryActor(
                    id: "girl_duck", name: "Girl Duck", x: 124, y: 58,
                    spriteRows: ACTOR_GIRL_DUCK_BASE, colorMapOverride: nil, flip: false, isVisible: true
                ))
                engine.setPerformanceOverride(sprite: DUCK_LEAP_LAND, x: 115, y: 58, flip: false)
            } else {
                // Victory celebration!
                engine.addActor(DuckStoryActor(
                    id: "girl_duck", name: "Girl Duck", x: 124, y: 58,
                    spriteRows: ACTOR_GIRL_DUCK_CHEER_A, colorMapOverride: nil, flip: true, isVisible: true
                ))
                engine.setPerformanceOverride(sprite: DUCK_YAY_A, x: 115, y: 58, flip: false)
            }

        default: break
        }
    }

    func onPause(context: DuckStoryContext, engine: DuckStoryEngine) {
        engine.speak("HOLD IN SHADOWS.", duration: 2.0)
    }

    func onResume(context: DuckStoryContext, engine: DuckStoryEngine) {
        engine.speak("RESUMING INFILTRATION.", duration: 2.0)
    }

    func onInteraction(type: String, context: DuckStoryContext, engine: DuckStoryEngine) -> String? {
        "SHHH. STEALTH OPS."
    }

    func onComplete(context: DuckStoryContext, engine: DuckStoryEngine) {
        onEnterFinale(context: context, engine: engine)
    }

    func onEnterFinale(context: DuckStoryContext, engine: DuckStoryEngine) {
        guard !isFinaleActive else { return }
        isFinaleActive = true
        finaleElapsedTime = 0.0
        engine.clearProps()
        engine.clearActors()
        engine.addActor(DuckStoryActor(
            id: "girl_duck", name: "Girl Duck", x: 74, y: 58,
            spriteRows: ACTOR_GIRL_DUCK_BASE, colorMapOverride: nil,
            flip: true, isVisible: true, targetX: nil, moveSpeed: 0.0
        ))
        engine.playSound("alertBlip")
        engine.speak("BEST. MISSION. EVER.", duration: 2.5)
    }

    func onCancel(context: DuckStoryContext, engine: DuckStoryEngine) {
        cleanup(engine: engine)
    }

    func cleanup(engine: DuckStoryEngine) {
        isFinaleActive = false
        finaleElapsedTime = 0.0
        engine.clearProps()
        engine.clearActors()
        engine.clearPerformanceOverride()
    }

    func cleanupFinale(engine: DuckStoryEngine) {
        isFinaleActive = false
        finaleElapsedTime = 0.0
        engine.clearProps()
        engine.clearActors()
        engine.clearPerformanceOverride()
    }

    func updateFinale(dt: Double, now: Date, context: DuckStoryContext, engine: DuckStoryEngine) {
        finaleElapsedTime += dt

        if context.reduceMotion {
            engine.setPerformanceOverride(sprite: DUCK_PROUD, x: 52, y: 58, flip: false)
            engine.addActor(DuckStoryActor(
                id: "girl_duck", name: "Girl Duck", x: 74, y: 58,
                spriteRows: ACTOR_GIRL_DUCK_BASE, colorMapOverride: nil, flip: true, isVisible: true
            ))
            return
        }

        // Clean, robust two-character synchronized cheer celebration loop
        // Both TimeDuck and Girl Duck stand normally side-by-side with zero distortion
        // Alternating raised wings in a reliable, charming victory loop
        let isCheerFrame = Int(finaleElapsedTime * 3.5) % 2 == 0
        let duckSprite = isCheerFrame ? DUCK_YAY_A : DUCK_YAY_B
        let girlSprite = isCheerFrame ? ACTOR_GIRL_DUCK_CHEER_A : ACTOR_GIRL_DUCK_CHEER_B

        engine.setPerformanceOverride(sprite: duckSprite, x: 52, y: 58, flip: false)
        engine.addActor(DuckStoryActor(
            id: "girl_duck", name: "Girl Duck", x: 74, y: 58,
            spriteRows: girlSprite, colorMapOverride: nil, flip: true, isVisible: true
        ))
    }
}
