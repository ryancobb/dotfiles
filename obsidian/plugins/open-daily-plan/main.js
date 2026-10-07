const { Notice, Plugin } = require("obsidian");

// The work vault's planner CLI dates plans in Pacific time and files each one under its week's Monday
// (tools/planner/src/store.rs plan_path). In other vaults the command finds no plan and says so.
function planPath(now = new Date()) {
  const parts = Object.fromEntries(
    new Intl.DateTimeFormat("en-US", {
      timeZone: "America/Los_Angeles",
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
    })
      .formatToParts(now)
      .map((p) => [p.type, p.value]),
  );
  const today = `${parts.year}-${parts.month}-${parts.day}`;
  const monday = new Date(`${today}T00:00:00Z`);
  monday.setUTCDate(monday.getUTCDate() - ((monday.getUTCDay() + 6) % 7));
  return `weeklies/${monday.toISOString().slice(0, 10)}/${today}-daily-plan.md`;
}

module.exports = class OpenDailyPlan extends Plugin {
  onload() {
    this.addCommand({
      id: "open-today",
      name: "Open today's daily plan",
      callback: async () => {
        const path = planPath();
        const file = this.app.vault.getFileByPath(path);
        if (!file) {
          new Notice(`No daily plan yet: ${path}`);
          return;
        }
        await this.app.workspace.getLeaf(false).openFile(file);
      },
    });
  }
};
