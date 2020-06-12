# Linked Templates
 
## Goals
 
1. IaaC
 1. 100% under source control
 2. Have reusable "components"
 - Hence "Linked Templates"
 3. Have DTL Templates use same Linked Templates
2. DevOps
 1. Deploy via Release Pipelines
 2. "Real" E2E Developer experience
 - Work on local Workstation
 - Have Build & Release Pipelines
3. IT Pro Usable
 1. Try and hide complexity
 2. Full history
 
## How
 
- Research
 - Visual Studio ARG Template Deployment
 - Works but has(had?) some quirks and limitations (no DevOps)
 - Azure QuickStart Templates
 - Lots of "FUD" in sample templates
 - E.g. hardcoding GitHub gist's
 - No working script found
 - Yammer ARM Channel for Partners
 - Brian's post
- POC
 - Slightly modified version of VS provided script
 - IOW BTS1 & KISS
 
## What
 
- A GitHub Repo
 - With "nestedArtifacts" folder
 - Follow 
 
## Missing
 
- Better testability
- Better feedback
- Full DTL Integration due to DTL Bug:
 - Only 1 level of folder supported
 - Creates own storage account and copies, but does not work
 
## Feature Requests
 
1. Prescriptive & actionable Guidance 
 - Through Azure Quick Start templates?
2. Avoid need for Storage Account 
 - Direct link to GIT repo (via token?)