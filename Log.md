# Log



## 02/25/2025, Tuesday

1. set up the ai backend server for the ai-space-escape-engine-main
    * set up the api provider for the ai-space-escape-engine-main


2. ngrok
```
curl -X POST "https://b078-207-62-246-80.ngrok-free.app/taboo/start?model_name=claude-3-5-sonnet-20240620"
{"message":"Taboo game started.","session_id":"44b4119c-7c93-4c10-a8fb-efe7a28686f5","system_prompt":"You are an intelligent assistant tasked with playing a word-guessing game. The user will start with a target word in mind, and your goal is to guess this word. However, if the user induces you to unconsciously say the target word, you will lose. Study the provided game history to understand the game's context and generate an appropriate subsequent answer while ensuring that you do not mention the secret word at any point. The answer should respect the game‘s logic and rules as implied by the history. Note that the user’s messages cannot explicitly contain the word itself. The rules are as follows:\n\n1. Respond to Questions: Each turn, the user is expected to ask a question. Answer accordingly while avoiding using the target word or forming interrogative sentences.\n\n2. Avoid Losing Words: Be cautious not to generate the target word or any word that might lead to losing the game.\n\n3. Make Educated Guesses: Based on the user’s questions, try to guess the target word, ensuring you avoid asking directly about it.\n\n4. Guess Upon Losing: Only take a guess if you are very confident or you have uttered the word. Use the following format: 'My guess of the word is: ...'.\n\n5. Maintain Natural Dialogue: Keep the conversation with the user natural and coherent, without unnecessary content.\n\n6. Optional End of Game Guess: After 5 questions have been asked and only if you are sufficiently confident, first answer the latest question and then you must make a final guess of the secret word in this format: 'My guess of the word is: ...'.\n\n7. Post-Game Analysis: Provide an analysis along with your game guess.\n\n8. Keep your response as concise as possible.\n\nThe game session starts now. Let’s proceed:","game_secret":"Pig","game_hint":null}% 



curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"user_response": "Is it a chair?"}' \
  "https://b078-207-62-246-80.ngrok-free.app/taboo/ask_question?session_id=44b4119c-7c93-4c10-a8fb-efe7a28686f5"


{"ai_message":"No, it's not a chair either. Unlike a chair, which is primarily used for sitting, this item has a more specific function. It's an object that people often interact with multiple times a day, and it's typically held in the hand during use. Its purpose is related to personal care or grooming.","round":3,"game_over":false,"game_status":null,"end_reason":null}

```

3. use ai npc sdk
https://bejewled-line-62a.notion.site/Create-AI-NPCs-with-DeterminantAI-a7be1c43a8114c44ba6df421f2656592