const { execSync } = require('node:child_process');
const readline = require('node:readline');
const fs = require('node:fs');
const path = require('node:path');
require('dotenv').config({ path: '.env.provision' });

const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
const question = (query) => new Promise((resolve) => rl.question(query, resolve));

async function main() {
    console.log("🔌 Supabase Stack Provisioning Utility");

    try {
        const serverIp = process.env.SERVER_IP || await question("Enter Server IP: ");
        const sshUser = process.env.SSH_USER || await question("Enter SSH Username: ");
        const remoteDir = process.env.REMOTE_DIR || "~/supabase-stack";

        if (!serverIp || !sshUser) throw new Error("Missing info");

        console.log(`\nDeploying to ${sshUser}@${serverIp}:${remoteDir}...\n`);

        // 1. Create a tarball of relevant files
        // We exclude volumes/db/data to avoid overwriting database data or transferring massive files
        const tarName = 'deploy-stack.tar';
        const projectRoot = path.resolve(__dirname, '..');

        console.log("📦 packaging files...");
        // Using tar command assuming it's available in git bash / wsl / powershell
        // Excludes: .git, node_modules, .env (we might want to copy .env specifically or template it)
        // Actually we SHOULD copy .env for the stack to work.
        // We assume 'tar' is in the path.
        try {
            execSync(`tar --exclude=".git" --exclude="node_modules" --exclude="volumes/db/data" --exclude="volumes/storage" -cf ${tarName} docker-compose.yml .env volumes`, {
                cwd: projectRoot,
                stdio: 'ignore'
            });
        } catch (e) {
            console.error("Failed to create tarball. Make sure 'tar' is in your path.");
            throw e;
        }

        const tarPath = path.join(projectRoot, tarName);

        // 2. SSH/SCP Operations
        // We use the temp file approach to allow password entry
        const scriptName = '_deploy_exec.sh';
        const scriptContent = `
            mkdir -p ${remoteDir}
            tar -xf /tmp/${tarName} -C ${remoteDir}
            rm /tmp/${tarName}
            rm /tmp/${scriptName}
            cd ${remoteDir}
            echo "🚀 Starting Docker Compose stack..."
            docker compose up -d --remove-orphans
        `;

        const scriptPath = path.join(projectRoot, scriptName);
        fs.writeFileSync(scriptPath, scriptContent);

        try {
            console.log("📂 Uploading stack archive (password may be asked)...");
            execSync(`scp -o StrictHostKeyChecking=no ${tarPath} ${scriptPath} ${sshUser}@${serverIp}:/tmp/`, { stdio: 'inherit' });

            console.log("🚀 Executing deployment on server (password may be asked)...");
            execSync(`ssh -o StrictHostKeyChecking=no ${sshUser}@${serverIp} "bash /tmp/${scriptName}"`, { stdio: 'inherit' });

        } finally {
            // Cleanup local
            if (fs.existsSync(tarPath)) fs.unlinkSync(tarPath);
            if (fs.existsSync(scriptPath)) fs.unlinkSync(scriptPath);
        }

        console.log("\n✅ Stack Provisioned Successfully!");

    } catch (e) {
        console.error("❌ Error:", e.message);
    } finally {
        rl.close();
    }
}

main();
