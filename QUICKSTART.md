# Quick Start: Baseline Protection in 60 Minutes

_English version of [SCHNELLSTART.md](SCHNELLSTART.md). The detailed phase
guides linked below are written in German._

For everyone who wants the most important security measures **now** and will
catch up on the six full phases later. Everything uses built-in Windows
tools – no AI, no admin expertise, no additional software.

**What this quick start does not replace:** the full
[inventory](01-bestandsaufnahme.md), the [backup plan](02-backup-plan.md)
following the 3-2-1 principle, the [repair phase](03-windows-pruefen-reparieren.md)
and the [clean-up](05-aufraeumen-optimieren.md). It is first aid, not the cure.

---

## Step 1: Back up your most important data _(15 minutes)_

Connect an external drive or a large USB stick (example: drive `E:`), then
copy the most important folders:

```powershell
robocopy "$env:USERPROFILE\Documents" "E:\QuickBackup\Documents" /E /XJ /R:1 /W:1
robocopy "$env:USERPROFILE\Desktop"   "E:\QuickBackup\Desktop"   /E /XJ /R:1 /W:1
robocopy "$env:USERPROFILE\Pictures"  "E:\QuickBackup\Pictures"  /E /XJ /R:1 /W:1
```

No admin rights required. Details and more folders: [Phase 2.2](02-backup-plan.md).

## Step 2: Create a restore point _(5 minutes)_

Windows key + R → `systempropertiesprotection` → select drive `C:` →
if needed _Configure → Turn on system protection_ → **Create…** →
name it e.g. `Before quick start`. Details: [Phase 2.3](02-backup-plan.md).

## Step 3: Run Windows Update to completion _(15 minutes + restarts)_

_Settings → Windows Update → Check for updates._ Install, restart,
**check again** – until Windows reports you are up to date.
Details: [Phase 3.1](03-windows-pruefen-reparieren.md).

## Step 4: Review the complete protection status _(10 minutes)_

_Settings → Privacy & security → Windows Security:_ open every section –
**Virus & threat protection**, **Firewall & network protection**,
**App & browser control**, **Device security**. Everything must be green;
take warnings seriously, do not switch anything off.
Details: [Phase 3.2](03-windows-pruefen-reparieren.md).

Optional as a report (read-only, no admin rights, output in German):

```powershell
pwsh -NoProfile -File .\skills\windows-pc-guru\scripts\Get-SecurityBaselineReport.ps1
```

## Step 5: Secure your browser and saved accounts _(10 minutes)_

Check for browser updates (Edge: _Menu → Help and feedback → About
Microsoft Edge_). Then enable **two-factor authentication** for your
Microsoft account if you have not already:
<https://account.microsoft.com/security>.

## Step 6: Trim autostart _(5 minutes)_

Ctrl + Shift + Esc → Task Manager → _Startup apps_ → **disable** anything
obviously unnecessary (do not uninstall, do not delete).
Details: [Phase 5.3](05-aufraeumen-optimieren.md).

---

**Afterwards:** work through the full plan in the [README](README.md) –
especially [Phase 2](02-backup-plan.md) for a real backup strategy and
[Phase 7](07-wartungsroutine.md) so the protection lasts. Track your
progress with the [progress checklist](vorlagen/fortschritts-checkliste.md).
