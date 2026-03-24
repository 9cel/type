#!./bin/ty

import apple (..)
import os (signal, SIGINT, SIGTERM, exit)

let FLT_TRUE_MIN = 1.17549435e-38

let tracking? = false
let fired?    = false
let passthrough = 0

fn make-dock-event(phase: Int, right?: Bool) -> CGEvent {
    let ev = CGEvent()
    ev.set-int!(gesture.FIELD_TYPE,             gesture.EVENT_DOCK_CONTROL)
    ev.set-int!(gesture.FIELD_HID_TYPE,         gesture.HID_TYPE_DOCK_SWIPE)
    ev.set-int!(gesture.FIELD_PHASE,            phase)
    ev.set-int!(gesture.FIELD_SCROLL_FLAG_BITS, right? ? 1 : 0)
    ev.set-float!(gesture.FIELD_SCROLL_Y,       0.0)
    ev.set-float!(gesture.FIELD_ZOOM_DELTA_X,   FLT_TRUE_MIN)
    ev.set-int!(gesture.FIELD_SWIPE_MOTION,     gesture.MOTION_HORIZONTAL)
    ev
}

fn post-pair(dock: CGEvent) {
    let companion = CGEvent()
    companion.set-int!(gesture.FIELD_TYPE, gesture.EVENT_GESTURE)
    dock.post!()
    companion.post!()
}

fn post-switch(right?: Bool) {
    let sign = right? ? 1.0 : -1.0

    let begin = make-dock-event(gesture.BEGAN, right?)
    let end   = make-dock-event(gesture.ENDED, right?)
    end.set-float!(gesture.FIELD_SWIPE_PROGRESS,   sign * 2.0)
    end.set-float!(gesture.FIELD_SWIPE_VELOCITY_X, sign * 400.0)
    end.set-float!(gesture.FIELD_SWIPE_VELOCITY_Y, 0.0)

    passthrough += 4
    post-pair(begin)
    post-pair(end)
}

fn is-horizontal-dock-swipe?(ev: CGEvent) -> Bool {
    ev.get-int(gesture.FIELD_TYPE)            == gesture.EVENT_DOCK_CONTROL
    && ev.get-int(gesture.FIELD_HID_TYPE)     == gesture.HID_TYPE_DOCK_SWIPE
    && ev.get-int(gesture.FIELD_SWIPE_MOTION) == gesture.MOTION_HORIZONTAL
}

fn on-event(ev-type: Int, ev: CGEvent) {
    let et = ev.get-int(gesture.FIELD_TYPE)

    if passthrough > 0 && (et == gesture.EVENT_DOCK_CONTROL || et == gesture.EVENT_GESTURE) {
        passthrough -= 1
        return ev
    }

    if is-horizontal-dock-swipe?(ev) {
        let phase = ev.get-int(gesture.FIELD_PHASE)

        if phase == gesture.BEGAN {
            tracking? = true
            fired? = false
            return nil
        }

        if phase == gesture.CHANGED && tracking? {
            if !fired? {
                let p = ev.get-float(gesture.FIELD_SWIPE_PROGRESS)
                if p != 0.0 {
                    fired? = true
                    post-switch(p > 0)
                }
            }
            return nil
        }

        if phase == gesture.ENDED && tracking? {
            if !fired? {
                let v = ev.get-float(gesture.FIELD_SWIPE_VELOCITY_X)
                if v != 0.0 {
                    post-switch(v > 0)
                }
            }
            tracking? = false
            fired? = false
            return nil
        }

        if phase == gesture.CANCELLED {
            tracking? = false
            fired? = false
            return nil
        }

        return tracking? ? nil : ev
    }

    if (et == gesture.EVENT_GESTURE) && tracking? {
        return nil
    }

    ev
}

if !accessibility-trusted?() {
    eprint('Grant Accessibility permission, then re-run.')
    exit(1)
}

fn main() {
    let mask = (1 << gesture.EVENT_GESTURE)
             | (1 << gesture.EVENT_DOCK_CONTROL)

    let stop? = false

    let ^tap  = EventTap(mask, on-event)
    signal(SIGINT,  () -> (stop? = true))
    signal(SIGTERM, () -> (stop? = true))

    eprint('iss: instant swipe active')
    while !stop? {
        run-loop.run(0.1)
    }
}

main()
