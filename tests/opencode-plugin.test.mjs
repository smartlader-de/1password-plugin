import assert from "node:assert/strict";
import { access } from "node:fs/promises";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { test } from "node:test";

import OnePasswordPlugin, {
  OnePasswordPlugin as NamedOnePasswordPlugin,
  server,
  skillDefinitions,
} from "../opencode/index.mjs";

const repoRoot = dirname(dirname(fileURLToPath(import.meta.url)));

test("OpenCode plugin exports the expected plugin function", () => {
  assert.equal(typeof OnePasswordPlugin, "function");
  assert.equal(NamedOnePasswordPlugin, OnePasswordPlugin);
  assert.equal(server, OnePasswordPlugin);
});

test("OpenCode plugin skill files exist", async () => {
  for (const definition of skillDefinitions) {
    await access(join(repoRoot, definition.path));
  }
});

test("OpenCode plugin registers all expected skill tools", async () => {
  const plugin = await OnePasswordPlugin({
    client: {
      session: {
        async prompt() {},
      },
    },
  });

  assert.deepEqual(Object.keys(plugin.tool).sort(), [
    "skills_1password",
    "skills_1password_environments",
    "skills_1password_setup",
    "skills_1password_ssh_git",
    "skills_1password_vaults_items",
  ]);

  for (const tool of Object.values(plugin.tool)) {
    assert.equal(typeof tool.description, "string");
    assert.deepEqual(tool.args, {});
    assert.equal(typeof tool.execute, "function");
  }
});

test("OpenCode skill tool silently injects root and selected skill content", async () => {
  const prompts = [];
  const plugin = await OnePasswordPlugin({
    client: {
      session: {
        async prompt(input) {
          prompts.push(input);
        },
      },
    },
  });

  const result = await plugin.tool.skills_1password_environments.execute(
    {},
    { sessionID: "session-example", agent: "build" },
  );

  assert.equal(result, "Loaded skill: 1password:environments");
  assert.equal(prompts.length, 3);
  assert.equal(prompts[0].path.id, "session-example");
  assert.equal(prompts[0].body.agent, "build");
  assert.equal(prompts[0].body.noReply, true);
  assert.match(prompts[0].body.parts[0].text, /skill is loading/);
  assert.match(prompts[1].body.parts[0].text, /# 1password/);
  assert.match(prompts[2].body.parts[0].text, /# 1password:environments/);
});
