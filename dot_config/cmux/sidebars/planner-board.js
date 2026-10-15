// planner-board: the planner's item workspaces (the ones `planner-open` made, titled "<ref> · <title>"), loudest
// first. On every write the planner CLI sets each item's description (a state line that ends with its worklist
// progress, then the next action) and a progress bar (tools/planner/src/cmux.rs). The board groups an item by its agent first (waiting for input,
// working), then by how the state line starts. Other workspaces follow in a quiet list, so the board can stand in for
// the left sidebar too.
//   cmux sidebar open planner-board                 (a pane)
//   cmux right-sidebar set custom planner-board     (the right panel)

const GROUPS = {
  attention: { label: "NEEDS YOU", color: "#FF9F0A", strong: true },
  working: { label: "WORKING", color: "#0A84FF" },
  ready: { label: "READY", color: "#34C759" },
  waiting: { label: "WAITING", color: "#BF5AF2" },
  held: { label: "HELD", color: "#8E8E93" },
  done: { label: "DONE", color: "#7f7f7f66" },
};
const ORDER = ["attention", "working", "ready", "waiting", "held", "done"];

// a planner ref: gitlab!123456, cdot#1234, gitlab-org&1234, task:pay-the-invoice
const ITEM = /^([\w.\/-]+[!#&]\d+|task:[\w-]+) · (.*)$/;

const epoch = () => data.clock()?.epoch ?? 0;

function ago(secs) {
  const s = Math.max(0, Math.floor(secs));
  if (s < 60) return s + "s";
  const m = Math.floor(s / 60);
  if (m < 60) return m + "m";
  return Math.floor(m / 60) + "h";
}

// the loudest agent in the workspace: one that waits for input, then one that works, then the most recent
const RANK = { needs_input: 0, working: 1, idle: 2, ended: 3 };
const agentOf = (e) =>
  (e.w.agents ?? []).reduce((best, a) => (!best || (RANK[a.status] ?? 3) < (RANK[best.status] ?? 3) ? a : best), null);

// the state line's words are the planner's (cmux.rs, `Mirror::description`)
function groupOf(e) {
  const agent = agentOf(e)?.status;
  const s = e.state;
  if (agent === "needs_input" || /^(News:|Not judged yet|Asked for)/.test(s)) return "attention";
  if (agent === "working") return "working";
  if (s.startsWith("Done") || s.startsWith("Ignored")) return "done";
  if (s.startsWith("Held ")) return "held";
  if (s.startsWith("Waiting on ")) return "waiting";
  return "ready";
}

const spaces = computed(() =>
  (data.workspaces() ?? [])
    .map((w) => {
      const m = ITEM.exec(w.title ?? "");
      const lines = (w.description ?? "").split("\n");
      const e = { key: w.id, w, ref: m ? m[1] : null, title: m ? m[2] : w.title, state: lines[0] ?? "", action: lines[1] ?? "" };
      e.group = e.ref ? groupOf(e) : null;
      return e;
    })
    .sort((a, b) => a.w.index - b.w.index)
);
const items = computed(() => spaces().filter((e) => e.ref));
const others = computed(() => spaces().filter((e) => !e.ref));
const inGroup = (g) => () => items().filter((e) => e.group === g);

function jump(e) {
  cmux("workspace.select", { workspace_id: e.w.id });
  const a = agentOf(e);
  if (a?.surfaceId) cmux("surface.focus", { surface_id: a.surfaceId, workspace_id: e.w.id });
}

// the agent at the right edge: how long it has worked, that it waits for input, and the unread count
function agentText(e) {
  const a = agentOf(e);
  const parts = [];
  if (a?.status === "needs_input") parts.push("input");
  else if (a?.status === "working" && a.sinceEpoch) parts.push(ago(epoch() - a.sinceEpoch));
  if (e.w.unread > 0) parts.push(String(e.w.unread));
  return parts.join(" · ");
}

function itemRow(e, g) {
  const meta = GROUPS[g];
  return HStack({ spacing: 8 }, [
    Circle({ size: 7 }).fill(meta.color),
    VStack({ spacing: 1 }, [
      HStack({ spacing: 5 }, [
        Text(() => e().ref).font(11).monospaced().weight("semibold").fixedSize(),
        Text(() => e().title).font(11).lineLimit(1).truncation("tail"),
      ]),
      Text(() => e().state)
        .font(10).color(meta.strong ? meta.color : "secondary").lineLimit(1).truncation("tail"),
      Text(() => e().action).font(10).color("tertiary").lineLimit(2).truncation("tail"),
    ]),
    Spacer({ minLength: 0 }),
    Text(() => agentText(e())).font(10).monospaced().color("tertiary").layoutPriority(2),
  ])
    .paddingHorizontal(10).paddingVertical(6)
    .cornerRadius(8)
    .background(() => (e().w.selected ? "#7f7f7f2e" : meta.strong ? "#FF9F0A1a" : null))
    .hoverBackground(meta.strong ? "#FF9F0A2e" : "#7f7f7f24")
    .frame({ maxWidth: "infinity" })
    .cursor("pointer")
    .onTap(() => jump(e()))
    .contextMenu([Button("Copy ref", () => clipboard.write(e().ref))]);
}

function section(g) {
  const meta = GROUPS[g];
  const members = inGroup(g);
  return VStack({ spacing: 3 }, [
    HStack({ spacing: 6 }, [
      Text(meta.label).font(10).weight("semibold").color(() => (members().length && meta.strong ? meta.color : "tertiary")),
      Spacer(),
      Text(() => (members().length ? String(members().length) : "")).font(10).monospaced().color("tertiary"),
    ]).paddingHorizontal(10),
    ForEach({ items: members, key: (e) => e.key }, (e) => itemRow(e, g)),
    Text(() => (members().length === 0 ? "—" : "")).font(10).color("tertiary").paddingHorizontal(10),
  ]);
}

function otherRow(e) {
  const dot = () => {
    const s = agentOf(e())?.status;
    return s === "needs_input" ? "#FF9F0A" : s === "working" ? "#0A84FF" : "#7f7f7f66";
  };
  return HStack({ spacing: 8 }, [
    Circle({ size: 6 }).fill(dot),
    Text(() => e().title).font(11).lineLimit(1).truncation("tail"),
    Spacer({ minLength: 0 }),
    Text(() => agentText(e())).font(10).monospaced().color("tertiary").layoutPriority(2),
  ])
    .paddingHorizontal(10).paddingVertical(4)
    .cornerRadius(8)
    .background(() => (e().w.selected ? "#7f7f7f2e" : null))
    .hoverBackground("#7f7f7f24")
    .frame({ maxWidth: "infinity" })
    .cursor("pointer")
    .onTap(() => jump(e()));
}

sidebar(() =>
  VStack({ spacing: 10 }, [
    HStack({ spacing: 6 }, [
      Text("Planner").font(14).weight("semibold"),
      Spacer(),
      Text(() => String(items().length)).font(11).monospaced().color("tertiary"),
    ]).paddingHorizontal(10),
    ...ORDER.map(section),
    Divider(),
    VStack({ spacing: 2 }, [
      Text("OTHER").font(10).weight("semibold").color("tertiary").paddingHorizontal(10),
      ForEach({ items: others, key: (e) => e.key }, otherRow),
    ]),
    Spacer(),
  ]).paddingHorizontal(6),
  { surface: "glass" }
)
