// Mark this tmux window the way Claude Code sessions are marked in the status bar:
//   hourglass = working, bell = waiting for you (permission / question), check = finished
// (the check clears when you visit the window). Shares ~/.local/bin/claude-tmux-state and the
// window's @claude_state option with the Claude hooks, so the status bar needs nothing new.
import { spawn, spawnSync } from "node:child_process"

const SCRIPT = `${process.env.HOME}/.local/bin/claude-tmux-state`

function mark(state) {
  if (!process.env.TMUX_PANE) return // not inside tmux
  try {
    spawn(SCRIPT, [state], { stdio: "ignore" }).unref()
  } catch {}
}

export const TmuxState = async () => {
  const subagents = new Set() // child sessions: their going idle doesn't mean you're needed
  let state = "clear"
  const set = (next) => {
    if (next === state) return
    state = next
    mark(next)
  }

  mark("clear")
  process.once("exit", () => {
    if (process.env.TMUX_PANE) spawnSync(SCRIPT, ["clear"], { stdio: "ignore", timeout: 2000 })
  })

  return {
    event: async ({ event }) => {
      // opencode 1.x puts the payload in `properties`, the newer API in `data`
      const p = event.properties ?? event.data ?? {}
      const info = p.info ?? p.session
      switch (event.type) {
        case "session.created":
        case "session.updated":
          if (info?.parentID) subagents.add(info.id)
          return
        case "session.status": {
          if (subagents.has(p.sessionID)) return
          const type = p.status?.type
          if (type === "busy" || type === "retry") set("working")
          else if (type === "idle" && state !== "clear") set("done")
          return
        }
        case "session.idle":
        case "session.error":
          if (!subagents.has(p.sessionID) && state !== "clear") set("done")
          return
        case "permission.asked":
        case "permission.updated": // older name for the same prompt
        case "question.asked":
          set("waiting")
          return
        case "permission.replied":
        case "question.replied":
        case "question.rejected":
          if (state === "waiting") set("working")
          return
      }
    },
  }
}
