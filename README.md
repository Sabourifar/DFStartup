# ⚡ DFStartup

A one-click PowerShell tool for Windows that disables Fast Startup — the hybrid shutdown/hibernation mode causes problems on some systems.

## ✨ Features

- 🔌 Disables Windows Fast Startup with a single run — no menus, no options, just does the one thing it's for
- 🔑 Elevates itself automatically — no need to manually "Run as Administrator"

## 📋 Requirements

- 🪟 Windows 10/11 (or Windows Server 2016+)
- 💻 PowerShell 5.1 (built into Windows) or PowerShell 7+
- 🔑 Administrator rights (the script elevates itself automatically — you'll get a UAC prompt)

## 🚀 Getting started

Windows tags every file downloaded from the internet with a "Mark of the Web," and by default PowerShell blocks unsigned scripts carrying that tag. The one-time command below removes that friction permanently for your user account, so you never have to think about it again.

### 1️⃣ One-time setup (do this once, ever)

Open any PowerShell window and run:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force
```

No admin rights needed — this only affects your own user account, not the whole machine. **Trade-off, stated plainly:** this tells Windows to stop checking execution policy and Mark-of-the-Web on *any* `.ps1` script you run from now on, not just this one. If you'd rather keep more protection, use `RemoteSigned` instead of `Bypass` — but then you'll need to run `Unblock-File .\DFStartup.ps1` once per downloaded copy of the script, since `RemoteSigned` still blocks unsigned scripts carrying the Mark of the Web.

### 2️⃣ Running it

1. 📥 Download `DFStartup.ps1` from the [Releases](../../releases) page into any folder.
2. ▶️ Right-click it → **Run with PowerShell**. Do this any time you want to run the tool.
3. ✅ Approve the UAC prompt — the tool needs administrator rights to change this setting.

That one-time setup step is what makes step 2 always work cleanly, with no errors or prompts, every time you run it. 🎉

## 🎮 Usage

Just run it — there's nothing to configure. It disables Fast Startup, tells you whether it succeeded.

## 📝 Notes

- 🔁 A restart is required for the change to take effect — Fast Startup is applied at the hibernation-image level, so it won't take effect until the next full shutdown/boot cycle.
- 🛠️ Under the hood, this sets `HiberbootEnabled` to `0` under `HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power` — the same registry value Windows itself uses when you disable Fast Startup from Control Panel.

## 📄 License

MIT — see [LICENSE](LICENSE).
