<p align="center">
<img src="img/pic1_rectangle.jpg" alt="AI-SPACE-ESCAPE" width="500" align="center">
</p>

<div align="center"><h1>&nbsp;AI Space Escape</h1></div>

<p align="center">
| <a href="https://arxiv.org/pdf/2412.06394"><b>Paper</b></a> | <a href="https://lmgame.org/#/blog/ai_space_escape/"><b>Blog</b></a> | <a href="https://discord.gg/pKhAhVfY"><b>Discord</b></a>  | <a href="https://x.com/largemodelgame"><b>X</b></a> |  <a href="https://www.roblox.com/games/114904064694961/AI-Space-Escape"><b>Roblox Game</b></a>
</p>

<p align="center">
  <a href="https://opensource.org/licenses/Apache-2.0">
    <img src="https://img.shields.io/badge/License-Apache_2.0-blue.svg" alt="License">
  </a>
  <a href="https://github.com/lmgame-org/ai-space-escape-engine/issues">
    <img src="https://img.shields.io/badge/Maintained%3F-yes-green.svg" alt="Maintenance">
  </a>
  <a href="https://github.com/lmgame-org/ai-space-escape-engine/pulls">
    <img src="https://img.shields.io/badge/Contributions-welcome-brightgreen.svg?style=flat" alt="Contributions welcome">
  </a>
</p>

This repo features the backend code for the Roblox game we built, [AI Space Escape](https://www.roblox.com/games/114904064694961/AI-Space-Escape), offering an unique experience to reason with AI. We design evaluation techniques to rank state-of-the-art large language models (LLMs). Our mission is to enable engaging gameplay while evaluating a variety of large-scale AI models and systems.


## AI Space Escape Engine (Interfaced with Roblox API)

### Installation

1. Clone this repository:
```
git clone https://github.com/lmgame-org/game-arena-engine.git
cd game-arena-engine
```
2. Install dependency:
```
python -m venv ./venv
.\venv\Scripts\activate.bat

python3.11 -m venv venv
. venv/bin/activate
pip install -r requirements.txt
```

```
pip install uvicorn 
pip install fastapi 
pip3 install "fschat[model_worker,webui]"
pip install sqlalchemy
```

### Set Up API Endpoints

1. Navigate to `game-arena-engine/src/config`, fill in `YOUR_API_KEY`.

### Experience the Games

1. Launch your backend with
```
python ./src/serve.py
```

2. Use [ngrok](https://ngrok.com/) to perform port forwarding to make this accessible on WAN.


### Citation
If you find this repository helpful, Please kindly cite:
```
article{hu2024gamearena,
  title={GameArena: Evaluating LLM Reasoning through Live Computer Games},
  author={Hu, Lanxiang and Li, Qiyu and Xie, Anze and Jiang, Nan and Stoica, Ion and Jin, Haojian and Zhang, Hao},
  journal={arXiv preprint arXiv:2412.06394},
  year={2024}
}
```

## 2. API Endpoints, Curl examples
```
curl http://0.0.0.0:8500/
{"message":"Welcome to the Game Arena!"}% 

curl -X POST http://0.0.0.0:8500/taboo/start   
{"message":"Taboo game started.","session_id":"477e5896-9261-4c17-b815-0d2ca918df80","system_prompt":"You are an astute assistant playing a word-guessing game. The user will have a secret word in mind, and your objective is to guess it. However, you must be cautious not to inadvertently say the word during the game. Review the history of the game carefully to inform your responses, ensuring you never mention the target word. Keep your answers logical and aligned with the game’s rules. The user’s questions won’t explicitly include the target word. The rules are as follows:\n\n1. Respond to Questions: Each turn, the user will ask a question. Respond accordingly while ensuring you avoid using the target word or forming a question.\n\n2. Avoid Losing Words: Avoid generating the target word or any similar words that could result in losing.\n\n3. Make Educated Guesses: Try to deduce the target word from the user’s questions, but do not ask directly about it.\n\n4. Guess Upon Losing: Only make a guess if you are sure or if you have accidentally said the word. Use this format: 'My guess of the word is: ...'.\n\n5. Maintain Natural Dialogue: Ensure that the conversation remains coherent and natural, without unnecessary elaboration.\n\n6. Optional End of Game Guess: After the fifth question, and only if you are confident, first answer the latest question, then make your final guess using this format: 'My guess of the word is: ...'.\n\n7. Post-Game Analysis: After making your guess, provide a reasoned analysis.\n\n8. Keep your response as concise as possible.\n\nThe game session starts now. Let's proceed:","game_secret":"Dolphin","game_hint":null}% 

curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"user_response": "Is it something you can find in a house?"}' \
  "http://0.0.0.0:8500/taboo/ask_question?session_id=1586c73a-8ce4-45a2-bd4a-b8856f40db95"
```


## 3. Questions
1. How to connect with Roblox?
```
Yes, exactly! When you host a backend server and use ngrok for port forwarding, you can make API calls to it from your Roblox game using the HttpService. Here's how you can do it properly:

First, in your Roblox game, you'll need to enable HttpService:

luaCopygame:GetService("HttpService").HttpEnabled = true

Then you can make API calls to your backend like this:

luaCopylocal HttpService = game:GetService("HttpService")

local function callMyAPI()
    local url = "http://your-ngrok-url/endpoint"
    
    local response = HttpService:RequestAsync({
        Url = url,
        Method = "POST",  -- or "GET", depending on your needs
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = HttpService:JSONEncode({
            -- your data here
            message = "Hello from Roblox!"
        })
    })
    
    if response.Success then
        local data = HttpService:JSONDecode(response.Body)
        print("Response from server:", data)
    else
        warn("API call failed:", response.StatusCode)
    end
end
```

2. Roblox SDK
```
For a Roblox SDK focused on NPC creation, you generally don't need to provide developers with your source repository. Instead, you should provide:

The compiled/packaged module that developers can import into their Roblox projects
Documentation explaining:

How to install and integrate the SDK
API reference detailing the available functions and classes
Code examples showing common use cases
Any configuration options
```