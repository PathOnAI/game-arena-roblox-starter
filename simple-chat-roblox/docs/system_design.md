# System Design - AI Space Escape Games

## Project Overview
A Roblox game featuring multiple AI-powered games (Taboo, Akinator, and Bluffing) with NPC interaction. The project uses Rojo for file management and version control.

## System Architecture Diagram
[![](https://mermaid.ink/img/pako:eNqVV9tu2zgQ_RWCRYEEkN06sRNbXSyQddptH1Jk4z6tnQdaomwisihIVC6N8-_l1SIpOomVh_ByZoYzhzNDP8OEphjGcFWhcg1-XS4KwL-PH8EVIgWY0k1JC1ywWq1f5-gJV0dz9f_2WK3uZKY54djejKS4I1o3S2VjARUMSNjRjKGK4UppnCUVKVl9vIBKSHw_CsKUxJzwYT-R437eoOa2RU3XyKB-Xk_bmY_7F23wd1SkOa7mYsyPueFTveSj2xH3TsC1i3W7YfnlACwPxPcLLSnVB5RjaTx4RPFd3JECMVppCTP1hYAr9U_eZBkpVlrKTPebwkWqJrvBjssZru5x9SaXCma4lBNFohiTBHeoVBhFZS3HISo1SlM5C-K65CjcK-QYQIgcbXJHTtioTY6WsMnZL2TI0EI2N2GhV7j5-sgzpkA5uLj-0aXE3bVcla7xxTkivbpECe7hOkEl7qGS9EvE1rToI_KJCZh1EOPf25JIIy1h4-fbwkuNvN3n9Q0uc5IghlMw40bQCndcbyEGAfdehhu8oQyH74Lemy-gnH5yIT0gi5ZQ4m9c1Hf_NbhmhBYL6N2A8CVqTZmVA6wV9QOu3mnQMNEaNCvvN3iF7vAVvceOqVcu6g1d5vQR6Fqgr6paNGvzI05bCHakWkIdyYIQgeuKPpINYU98sCkZLyzHt37_oUWBExGLGvCCDi4RQ-BbTh92CKWTFyKeIkgi7cYGer2_twtodsEDYWvAa5A5UOcEW6vvBBSJTW6rbJiAun6HYmGLfb1XbWRr1cNgu5VVlaCc_EatP23TFDo7p_S2raYY3LeaV3Df7VZBiNuaPEdU41SdGMiDcKTabU8ug2Mj62334NaCxN_QhtkCHU_eEgi59pbMq77qhrmPNL1tSLN597atphXcd7tUEOL2pBBkO60wL6cq0qZihh99SkZEoSlEDd65ZcUc_CXjJfV8awqZgFun5CoRN-phKa-AKkE39GFBrxDa7tgnkcLdKHtmFSoUa8-MAoYi3kZS5P3e6y99-UmrDe_sYrlbGPx7qZJlBw1eR96X93KmKZWGvzNW6jK13T0k3IjshVsPCDc0eyWsV0OoVPD-JCIqy3Nd4oQnEljiNbon1Lz-bAdUVb0kNVrmGFghfLW6zthTy0OSo7q-xBmo7IINMpLn8YdsIv6imlX0DscfTk9P9bj3QFK2jgfl4xdPjfoRc0XTJjda0mE2zNBBWtT72deC0sPOstr9PNA60BifZYODdehoGx3ZAOHDvFFPNhPUAR6h8UEK-HtyJ4zG7xO2VPjN2KHatmX1tqhNrMhOP5vfjqgKVNTePIdIB27VzsgtipFX6loWuwq0QTdRIy8LWwodBVbhj-zyGHmFMPLrnaazexqe1JFVEiIr2QWFX2AEN5jnKElhDJ-F-AKyNeavURjzYYoz1ORMvNtfOBQ1jM6eigTGrGpwBCvarNZm0pQprxSXBPGH_wbGGcprvlqi4n9KnTmMn-EjjHsno8_90_HpcMT_xsPJyWAUwScYTz73R3x8fnY2mZzzb_ASwd9SxaA_Gown58OT4eDkfDI8G45e_gB5ZqS2?type=png)](https://mermaid.live/edit#pako:eNqVV9tu2zgQ_RWCRYEEkN06sRNbXSyQddptH1Jk4z6tnQdaomwisihIVC6N8-_l1SIpOomVh_ByZoYzhzNDP8OEphjGcFWhcg1-XS4KwL-PH8EVIgWY0k1JC1ywWq1f5-gJV0dz9f_2WK3uZKY54djejKS4I1o3S2VjARUMSNjRjKGK4UppnCUVKVl9vIBKSHw_CsKUxJzwYT-R437eoOa2RU3XyKB-Xk_bmY_7F23wd1SkOa7mYsyPueFTveSj2xH3TsC1i3W7YfnlACwPxPcLLSnVB5RjaTx4RPFd3JECMVppCTP1hYAr9U_eZBkpVlrKTPebwkWqJrvBjssZru5x9SaXCma4lBNFohiTBHeoVBhFZS3HISo1SlM5C-K65CjcK-QYQIgcbXJHTtioTY6WsMnZL2TI0EI2N2GhV7j5-sgzpkA5uLj-0aXE3bVcla7xxTkivbpECe7hOkEl7qGS9EvE1rToI_KJCZh1EOPf25JIIy1h4-fbwkuNvN3n9Q0uc5IghlMw40bQCndcbyEGAfdehhu8oQyH74Lemy-gnH5yIT0gi5ZQ4m9c1Hf_NbhmhBYL6N2A8CVqTZmVA6wV9QOu3mnQMNEaNCvvN3iF7vAVvceOqVcu6g1d5vQR6Fqgr6paNGvzI05bCHakWkIdyYIQgeuKPpINYU98sCkZLyzHt37_oUWBExGLGvCCDi4RQ-BbTh92CKWTFyKeIkgi7cYGer2_twtodsEDYWvAa5A5UOcEW6vvBBSJTW6rbJiAun6HYmGLfb1XbWRr1cNgu5VVlaCc_EatP23TFDo7p_S2raYY3LeaV3Df7VZBiNuaPEdU41SdGMiDcKTabU8ug2Mj62334NaCxN_QhtkCHU_eEgi59pbMq77qhrmPNL1tSLN597atphXcd7tUEOL2pBBkO60wL6cq0qZihh99SkZEoSlEDd65ZcUc_CXjJfV8awqZgFun5CoRN-phKa-AKkE39GFBrxDa7tgnkcLdKHtmFSoUa8-MAoYi3kZS5P3e6y99-UmrDe_sYrlbGPx7qZJlBw1eR96X93KmKZWGvzNW6jK13T0k3IjshVsPCDc0eyWsV0OoVPD-JCIqy3Nd4oQnEljiNbon1Lz-bAdUVb0kNVrmGFghfLW6zthTy0OSo7q-xBmo7IINMpLn8YdsIv6imlX0DscfTk9P9bj3QFK2jgfl4xdPjfoRc0XTJjda0mE2zNBBWtT72deC0sPOstr9PNA60BifZYODdehoGx3ZAOHDvFFPNhPUAR6h8UEK-HtyJ4zG7xO2VPjN2KHatmX1tqhNrMhOP5vfjqgKVNTePIdIB27VzsgtipFX6loWuwq0QTdRIy8LWwodBVbhj-zyGHmFMPLrnaazexqe1JFVEiIr2QWFX2AEN5jnKElhDJ-F-AKyNeavURjzYYoz1ORMvNtfOBQ1jM6eigTGrGpwBCvarNZm0pQprxSXBPGH_wbGGcprvlqi4n9KnTmMn-EjjHsno8_90_HpcMT_xsPJyWAUwScYTz73R3x8fnY2mZzzb_ASwd9SxaA_Gown58OT4eDkfDI8G45e_gB5ZqS2)

## Directory Structure

### Server-Side (`src/server/`)
```
ServerScriptService/
└── Server/
    ├── init.server.luau           # Main server initialization
    ├── NPCChatServer.luau         # NPC chat handling and game command routing
    ├── TabooGameServer.luau       # Taboo game server logic
    ├── AkinatorGameServer.luau    # Akinator game server logic
    └── BluffingGameServer.luau    # Bluffing game server logic
```

### Client-Side (`src/client/`)
```
StarterPlayerScripts/
└── Client/
    ├── init.client.luau          # Main client initialization
    ├── NPCChatClient.luau        # NPC chat UI and interaction
    ├── GameCommandHandler.luau    # Central game command processing
    ├── TabooGameClient.luau      # Taboo game client logic
    ├── AkinatorGameClient.luau   # Akinator game client logic
    └── BluffingGameClient.luau   # Bluffing game client logic
```

### Shared Resources (`ReplicatedStorage/`)
```
ReplicatedStorage/
└── GameRemotes/
    ├── Taboo/
    │   ├── StartGame
    │   └── AskQuestion
    ├── Akinator/
    │   ├── StartGame
    │   └── AnswerQuestion
    └── Bluffing/
        ├── StartGame
        └── MakeMove
```

## Component Descriptions

### Server Components

1. **init.server.luau**
   - Creates RemoteFunction structure in ReplicatedStorage
   - Initializes all game servers
   - Sets up communication channels

2. **NPCChatServer.luau**
   - Handles NPC chat interactions
   - Routes game commands to appropriate servers
   - Manages chat events and proximity prompts
   - Special handling for Taboo game (disables normal chat)
   - Maintains normal chat for Akinator and Bluffing games

3. **Game Servers**
   - Handle game-specific logic
   - Communicate with external APIs
   - Manage game states per player
   - Process player inputs
   - Return game responses

### Client Components

1. **init.client.luau**
   - Initializes all client modules
   - Sets up necessary services
   - Manages client-side loading sequence

2. **NPCChatClient.luau**
   - Manages chat UI and display
   - Handles NPC proximity detection
   - Processes player interactions
   - Displays game messages

3. **GameCommandHandler.luau**
   - Processes game commands
   - Manages active game state
   - Routes commands to appropriate games
   - Handles game transitions

4. **Game Clients**
   - Handle game-specific UI
   - Manage local game state
   - Communicate with server via RemoteFunctions
   - Process player input

## Communication Flows

### Game Command Flow
```
Player Input → NPCChatClient → GameCommandHandler → Game Client → RemoteFunction → Game Server → API
```

### Chat Flow
```
Normal Chat: Player → NPCChatServer → NPCChatClient
Game Chat:   Player → GameCommandHandler → Game Client → Game Server → NPCChatClient
```

## Game States

### Taboo Game
- Disables normal chat when active
- Direct question/answer interaction
- API-based word guessing

### Akinator Game
- Maintains normal chat functionality
- Yes/No question format
- API-based character guessing

### Bluffing Game
- Maintains normal chat functionality
- Statement analysis
- API-based truth detection

## External Dependencies

### API Endpoints
- Taboo: `ai-space-escape-api.pathon.ai/taboo`
- Akinator: `ai-space-escape-api.pathon.ai/akinator`
- Bluffing: `ai-space-escape-api.pathon.ai/bluffing`

## Key Features

### 1. Modular Design
- Self-contained game modules
- Consistent interface patterns
- Easy addition of new games

### 2. State Management
- Centralized game state tracking
- Individual game state handling
- Clean game transitions

### 3. Error Handling
- Safe API communication
- Input validation
- State validation

### 4. User Experience
- Intuitive NPC interaction
- Clear game instructions
- Consistent feedback system

## Implementation Notes

### Server-Side
- Each game server maintains its own active games table
- NPCChatServer routes commands but doesn't manage game state
- RemoteFunctions created during initialization

### Client-Side
- GameCommandHandler manages active game state
- Game clients handle their own UI and state
- NPCChatClient handles general interaction

### Extensibility
- New games can be added by following the established pattern
- Each game requires client/server modules and RemoteFunctions
- NPCChatServer requires minimal updates for new games 