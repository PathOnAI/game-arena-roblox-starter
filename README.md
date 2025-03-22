# roblox-game-ai-backend


I tried to reproduce the GameArena paper (https://openreview.net/forum?id=SeQ8l8xo1r), with the code provided by the team: https://github.com/lmgame-org/ai-space-escape-engine and https://github.com/lmgame-org/ai-space-escape-roblox. We provide a simple version of the game that AI researchers can plug and play in their Roblox Studio and make minimal modifications to publish a Roblox game themselves. Please note this game is a starter template for AI researchers interested in building Roblox game benchmarks for embodied AI, to get familiar with Roblox game development. It is far from the actual AI space escape game in the GameArena paper, which features a more complicated Roblox game environment. Our game environment only has a single NPC.

## Part 1: Backend

For this project, I modified the [AI Space Escape Engine](https://github.com/lmgame-org/ai-space-escape-engine) to create a production-ready backend. The key changes include:

1. **Database Migration**: Replaced the local database with AWS RDS for improved scalability and reliability
2. **Deployment Strategy**: Configured the entire backend as an AWS ECS service for better availability and easier maintenance

This approach addresses a critical challenge in Roblox development. Unlike traditional fullstack applications, Roblox requires HTTP calls to be made from the server side, and these cannot use local IP addresses. While the original project authors suggest using ngrok for local testing, this solution isn't viable for production environments.

My AWS-based implementation provides a permanent, production-ready backend service that eliminates the need for temporary tunneling solutions like ngrok, ensuring consistent availability for the Roblox application.

## Part 2: Rojo Project

For the development environment, I implemented Rojo following the approach outlined in the [AI Space Escape Roblox](https://github.com/lmgame-org/ai-space-escape-roblox) repository. This setup enables a modern development workflow with:

1. **Code in Professional Editors**: Write and manage code in VSCode/Cursor with all their productivity features
2. **Live Sync**: Automatically sync code changes to Roblox Studio using the Rojo Server
3. **Improved Version Control**: Better integration with git and other source control systems

To implement this workflow, you'll need to follow the setup instructions in the [AI Space Escape Roblox repository](https://github.com/lmgame-org/ai-space-escape-roblox), which includes installing the necessary Roblox plugins and configuring your development environment.


## Part 3. Roblox Asset File

Minimalist Roblox file featuring an AI NPC that interacts with players through three backend-defined games:
- Taboo
- Bluffing
- Akinator

The AI NPC responds dynamically to game outcomes with some actions.

## Part 4. Publish on Roblox

Publishing process:
1. Load the provided rbxl file into Roblox Studio
2. Use Studio's built-in publishing tools to make the game public

Access my published game: [AI Game Experience](https://www.roblox.com/share?code=5b49184e2a04be428927cd7fa131eabc&type=ExperienceDetails&stamp=1742631279240)

Note for researchers: My backend API is included in the code for research purposes. Use at your own risk. All data will be stored in my AWS RDS database. I may change the API address if traffic becomes excessive.