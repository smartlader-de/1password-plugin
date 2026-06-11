import { readFile } from "node:fs/promises";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const pluginDir = dirname(fileURLToPath(import.meta.url));
const packageRoot = dirname(pluginDir);

export const id = "1password";

const skillDefinitions = [
  {
    toolName: "skills_1password",
    name: "1password",
    description:
      "Load the 1Password skill router for agent-safe credential workflows.",
    path: "SKILL.md",
  },
  {
    toolName: "skills_1password_setup",
    name: "1password:setup",
    description:
      "Load the 1Password setup skill for CLI/MCP onboarding and access checks.",
    path: "skills/setup/SKILL.md",
  },
  {
    toolName: "skills_1password_environments",
    name: "1password:environments",
    description:
      "Load the 1Password Environments skill for env vars, provider sync, and local runtime secrets.",
    path: "skills/environments/SKILL.md",
  },
  {
    toolName: "skills_1password_vaults_items",
    name: "1password:vaults-items",
    description:
      "Load the 1Password vaults/items skill for item, vault, document, sharing, and permission workflows.",
    path: "skills/vaults-items/SKILL.md",
  },
  {
    toolName: "skills_1password_ssh_git",
    name: "1password:ssh-git",
    description:
      "Load the 1Password SSH/Git skill for SSH keys, provider registration, Git signing, and SSH agent workflows.",
    path: "skills/ssh-git/SKILL.md",
  },
];

async function readSkill(relativePath) {
  const fullPath = join(packageRoot, relativePath);
  const content = await readFile(fullPath, "utf8");
  return { fullPath, content };
}

function createPromptSender(ctx, toolCtx) {
  return async function sendSilentPrompt(text) {
    await ctx.client.session.prompt({
      path: { id: toolCtx.sessionID },
      body: {
        agent: toolCtx.agent,
        noReply: true,
        parts: [{ type: "text", text }],
      },
    });
  };
}

function createSkillTool(ctx, definition) {
  return {
    description: definition.description,
    args: {},
    async execute(_args, toolCtx) {
      const sendSilentPrompt = createPromptSender(ctx, toolCtx);
      const rootSkill = await readSkill("SKILL.md");

      await sendSilentPrompt(`The "${definition.name}" skill is loading`);
      await sendSilentPrompt(
        `Base directory for the 1password skill collection: ${packageRoot}\n\n${rootSkill.content}`,
      );

      if (definition.path !== "SKILL.md") {
        const selectedSkill = await readSkill(definition.path);
        await sendSilentPrompt(
          `Base directory for this skill: ${dirname(selectedSkill.fullPath)}\n\n${selectedSkill.content}`,
        );
      }

      return `Loaded skill: ${definition.name}`;
    },
  };
}

export const OnePasswordPlugin = async (ctx) => {
  const tools = {};

  for (const definition of skillDefinitions) {
    tools[definition.toolName] = createSkillTool(ctx, definition);
  }

  return { tool: tools };
};

export const server = OnePasswordPlugin;
export { skillDefinitions };
export default OnePasswordPlugin;
