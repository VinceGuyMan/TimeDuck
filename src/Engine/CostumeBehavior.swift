// MARK: - TimeDuck · CostumeBehavior.swift
// Costume-specific micro-actions, reactions, and personality hooks (Wave 2).
// Decoupled architecture: pure presentation hooks with zero coupling to timing engine.

import Foundation

enum CostumeAction {
    case customPose(DuckPose, duration: Double, phrase: String?)
    case customPhrase(String)
}

enum CostumeBehavior {
    /// Evaluates if the current costume provides a custom micro-reaction upon timer pause.
    static func onTimerPause(hat: DuckHat) -> CostumeAction? {
        switch hat {
        case .detective:
            let lines = ["INVESTIGATING CLUES.", "TIMELINE SUSPENDED.", "THE CLOCK DID IT."]
            return .customPose(.sideEye, duration: 2.2, phrase: lines.randomElement())
        case .bandanaMidnight, .bandanaCrimson, .bandanaForestCamo, .bandanaDesertCamo:
            let lines = ["HOLDING POSITION.", "TACTICAL REGROUP.", "PERIMETER SECURED."]
            return .customPose(.tactical, duration: 2.0, phrase: lines.randomElement())
        default:
            return nil
        }
    }

    /// Evaluates if the current costume provides a custom micro-reaction upon timer completion.
    static func onTimerComplete(hat: DuckHat) -> CostumeAction? {
        switch hat {
        case .wizard:
            let lines = ["SPELLCASTING COMPLETE!", "ARCANE RESTORATION.", "MAGIC RUN SUCCESSFUL!"]
            return .customPose(.celebrating, duration: 3.5, phrase: lines.randomElement())
        case .crown:
            let lines = ["ROYAL DECREE: VICTORY!", "ALL HAIL THE TIME DUCK.", "IMPERIAL FOCUS CLEAR."]
            return .customPose(.celebrating, duration: 3.5, phrase: lines.randomElement())
        case .cyber:
            let lines = ["SYSTEM OVERCLOCK 100%.", "CHRONO-CIRCUIT CLEAR.", "NEO-MISSION SUCCESS."]
            return .customPose(.celebrating, duration: 3.0, phrase: lines.randomElement())
        default:
            return nil
        }
    }

    /// Evaluates if the current costume provides a custom micro-reaction upon starting a break.
    static func onBreakStart(hat: DuckHat) -> CostumeAction? {
        switch hat {
        case .barista:
            let lines = ["ESPRESSO BREAK.", "STEAMING FRESH MILK.", "CAFFEINE RELAXATION."]
            return .customPose(.relaxing, duration: 3.0, phrase: lines.randomElement())
        case .sleepcap:
            let lines = ["COZY NAP TIME.", "POWER NAP ENGAGED.", "RESTING THE BEAK."]
            return .customPose(.sleeping, duration: 3.0, phrase: lines.randomElement())
        default:
            return nil
        }
    }

    /// Evaluates preferred idle pose bias for specific costumes.
    static func preferredIdlePose(hat: DuckHat) -> DuckPose? {
        switch hat {
        case .bandanaMidnight, .bandanaCrimson, .bandanaForestCamo, .bandanaDesertCamo:
            return .tactical
        case .detective:
            return .sideEye
        case .barista:
            return .relaxing
        case .sleepcap:
            return .sitting
        case .cyber:
            return .headTilt
        default:
            return nil
        }
    }
}
