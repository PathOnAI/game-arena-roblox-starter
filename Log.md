# Log


## 02/26/2025, Wednesday
```
pip freeze > requirements_2.txt

python3.11 -m venv venv
. venv/bin/activate
pip install -r requirements.txt
```

curl http://0.0.0.0:8500/


curl -X POST "http://0.0.0.0:8500/taboo/start?model_name=claude-3-5-sonnet-20240620"

curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"user_response": "Is it something you can find in a house?"}' \
  "http://0.0.0.0:8500/taboo/ask_question?session_id=6656d1ba-bbf1-4bdc-b8ce-fdb2638b0b93"


Local Development: You can still use a .env file and docker run --env-file .env ... locally.
Production on Fargate: Move the needed environment variables (or secrets) into your ECS Task Definition or store them in AWS Secrets Manager/Parameter Store. This way, Fargate will inject them into the container at runtime.

* set up the ai backend server for the ai-space-escape-engine-main using vercel and supabase [cancelled]
  * in this repo 
  * set up the ai backend, use a database, don't use supabase for now since it is non-trivial to set up
* used aws rds for the database, and trying to use vercel for the backend deployment [has error]
  * only use vercel for the frontend deployment [done]
* deploy the backend to aws fargate
  * Step 1: Containerize your application
    * install docker
    * Dockerfile
    * build the docker image
      * docker build -t ai-space-escape-engine-backend . 
    * test the docker image locally
      * docker run -p 8500:8500 --env-file .env ai-space-escape-engine-backend
    * taboo working
  * Step 2: Push the Docker Image to Amazon ECR
  * Step 3: Set Up AWS Fargate
  * Step 4: Set Up Load Balancing (Optional)
  * Step 5: Access Your Application: Once everything is set up, you can access your application through the ALB's DNS name or the public IP of your Fargate task.


```
I now see the error messages in your updated logs, and it appears the deployment failed after the build completed. The error messages are:
Copy16:17:45.830  Failed to process build result for "src/serve.py". Data: {"type":"Lambda"}.
16:17:45.841  Error: data is too long
This is likely not directly related to having too many dependencies in your requirements.txt file, but rather to Vercel's Lambda deployment limitations. Vercel deploys serverless functions (Lambda), and there's a size limit for these functions.
The error "data is too long" suggests that your built application exceeds Vercel's size limits for Lambda functions. This can happen when:

Your application code + dependencies combined are too large
You might have large assets or models included in your deployment package
The AI components of your Roblox backend might include substantial libraries or models

For AWS Lambda (which Vercel uses), there's a deployment package size limit of 50MB for direct uploads and 250MB for layers, but Vercel might have stricter limits.
Moving to AWS Fargate as you mentioned would be a good solution since Fargate is container-based and doesn't have the same size limitations as Lambda functions. Fargate would be better suited for larger applications, especially those with extensive dependencies or ML models.
```




```
Option 1: AWS RDS (Relational Database Service)
This is the most robust enterprise solution:

Migrate your schema and data to a PostgreSQL or MySQL database on RDS:

Create an RDS instance of PostgreSQL or MySQL
Use a migration tool like SQLAlchemy-Migrate or Alembic to convert your SQLite schema
Import your data to the new database


Update your connection string:
pythonCopy# Instead of SQLite connection:
SQLALCHEMY_DATABASE_URL = "postgresql://username:password@your-rds-endpoint:5432/dbname"
# or 
SQLALCHEMY_DATABASE_URL = "mysql+pymysql://username:password@your-rds-endpoint:3306/dbname"
```


```
(venv) danqingzhang@danqings-mbp vercel-backend % python src/show_db_tables.py
Database found at: /Users/danqingzhang/Desktop/learning/roblox-game-ai-backend/vercel-backend/users.db

=== Using SQLite3 ===
Found 4 tables:

Table: game_sessions
Columns (19):
  - id: INTEGER (Primary Key)
  - session_id: VARCHAR(36)
  - user_id: INTEGER
  - username: VARCHAR
  - game_name: VARCHAR
  - state: VARCHAR(7)
  - target_phrase: VARCHAR
  - model: VARCHAR
  - share: BOOLEAN
  - history: JSON
  - timestamp: DATETIME
  - round: INTEGER
  - game_over: BOOLEAN
  - game_status: VARCHAR
  - level: INTEGER
  - system_prompt: VARCHAR
  - game_stat_change: JSON
  - total_game_time: INTEGER
  - escape_ai_room_id: VARCHAR
Total rows: 25
Sample data (up to 3 rows):
  (1, '477e5896-9261-4c17-b815-0d2ca918df80', 0, 'anonymous', 'Taboo', 'PLAYING', 'Dolphin', 'gpt-4o-2024-11-20', 0, '[]', '2025-02-18 20:57:26', 0, 0, None, 1, "You are an astute assistant playing a word-guessing game. The user will have a secret word in mind, and your objective is to guess it. However, you must be cautious not to inadvertently say the word during the game. Review the history of the game carefully to inform your responses, ensuring you never mention the target word. Keep your answers logical and aligned with the game’s rules. The user’s questions won’t explicitly include the target word. The rules are as follows:\n\n1. Respond to Questions: Each turn, the user will ask a question. Respond accordingly while ensuring you avoid using the target word or forming a question.\n\n2. Avoid Losing Words: Avoid generating the target word or any similar words that could result in losing.\n\n3. Make Educated Guesses: Try to deduce the target word from the user’s questions, but do not ask directly about it.\n\n4. Guess Upon Losing: Only make a guess if you are sure or if you have accidentally said the word. Use this format: 'My guess of the word is: ...'.\n\n5. Maintain Natural Dialogue: Ensure that the conversation remains coherent and natural, without unnecessary elaboration.\n\n6. Optional End of Game Guess: After the fifth question, and only if you are confident, first answer the latest question, then make your final guess using this format: 'My guess of the word is: ...'.\n\n7. Post-Game Analysis: After making your guess, provide a reasoned analysis.\n\n8. Keep your response as concise as possible.\n\nThe game session starts now. Let's proceed:", None, None, None)
  (2, '811efe4f-b34d-4841-a8ef-6f1b4940b3f7', 0, 'anonymous', 'Taboo', 'PLAYING', 'Bear', 'qwen-max', 0, '[]', '2025-02-18 21:02:03', 0, 0, None, 1, "You are a creative assistant engaged in a word-guessing game. The user will choose a target word, and your objective is to guess that word. Be mindful not to let the user trick you into saying the word unknowingly. Review the game history carefully to frame your responses, avoiding any mention of the target word. Ensure your responses align with the ongoing narrative and adhere strictly to the game's rules. Remember, the user’s messages will not explicitly state the word. The rules you must follow are:\n\n1. Respond to Questions: The user will ask a question each turn. Provide an answer that avoids using the target word or forming questions yourself.\n\n2. Avoid Losing Words: Do not generate the target word or any related words that could result in a loss.\n\n3. Make Educated Guesses: Based on the user’s inquiries, try to deduce the target word, but never ask directly about it.\n\n4. Guess Upon Losing: Make a guess only if you are confident or if you have accidentally said the word. Format your guess as: 'My guess of the word is: ...'.\n\n5. Maintain Natural Dialogue: Ensure the conversation flows naturally, without extraneous details.\n\n6. Optional End of Game Guess: After the fifth question, and only if confident, first answer the latest question, then make your final guess in the format: 'My guess of the word is: ...'.\n\n7. Post-Game Analysis: After your guess, provide an analysis to explain your reasoning.\n\n8. Keep your response as concise as possible.\n\nThe game session begins now. Let's start:", None, None, None)
  (3, '41bbadbf-621c-4b00-933d-45819a3ced3d', 0, 'anonymous', 'Taboo', 'PLAYING', 'Fox', 'claude-3-5-sonnet-20240620', 0, '[]', '2025-02-18 21:03:54', 0, 0, None, 1, "You are an astute assistant playing a word-guessing game. The user will have a secret word in mind, and your objective is to guess it. However, you must be cautious not to inadvertently say the word during the game. Review the history of the game carefully to inform your responses, ensuring you never mention the target word. Keep your answers logical and aligned with the game’s rules. The user’s questions won’t explicitly include the target word. The rules are as follows:\n\n1. Respond to Questions: Each turn, the user will ask a question. Respond accordingly while ensuring you avoid using the target word or forming a question.\n\n2. Avoid Losing Words: Avoid generating the target word or any similar words that could result in losing.\n\n3. Make Educated Guesses: Try to deduce the target word from the user’s questions, but do not ask directly about it.\n\n4. Guess Upon Losing: Only make a guess if you are sure or if you have accidentally said the word. Use this format: 'My guess of the word is: ...'.\n\n5. Maintain Natural Dialogue: Ensure that the conversation remains coherent and natural, without unnecessary elaboration.\n\n6. Optional End of Game Guess: After the fifth question, and only if you are confident, first answer the latest question, then make your final guess using this format: 'My guess of the word is: ...'.\n\n7. Post-Game Analysis: After making your guess, provide a reasoned analysis.\n\n8. Keep your response as concise as possible.\n\nThe game session starts now. Let's proceed:", None, None, None)

Table: user_stars
Columns (5):
  - roblox_id: INTEGER (Primary Key)
  - username: VARCHAR
  - stars: INTEGER
  - consecutive_wins: INTEGER
  - max_consecutive_wins: INTEGER
Total rows: 1
Sample data (up to 3 rows):
  (0, 'anonymous', 7, 5, 5)

Table: npc_sessions
Columns (8):
  - id: INTEGER (Primary Key)
  - session_id: VARCHAR(36)
  - username: VARCHAR
  - npc_name: VARCHAR
  - model: VARCHAR
  - history: JSON
  - system_prompt: VARCHAR
  - timestamp: DATETIME
Total rows: 0

Table: action_sessions
Columns (7):
  - id: INTEGER (Primary Key)
  - session_id: VARCHAR(36)
  - username: VARCHAR
  - model: VARCHAR
  - history: JSON
  - system_prompt: VARCHAR
  - timestamp: DATETIME
Total rows: 0
```


## 02/25/2025, Tuesday

### 3. Part 3
* debug the perception module
* debug the action generation module

### 2. Part 2
* set up the ai backend server for the ai-space-escape-engine-main using vercel and supabase
  * in this repo
* ai backend for the SDK
  * in a separate repo


### 1. Part 1

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

3. deploy to vercel

4. use ai npc sdk for chat
https://www.roblox.com/games/82289819259183/SimpleChatGame

![alt text](images/image-1.png)

5. use ai npc sdk for action
change the character name
https://www.roblox.com/games/79072648104484/SimpleActionGame


![alt text](images/image.png)

6. add other components to the game
terrain, apple, desk, chair, etc.
https://www.roblox.com/games/110910600686487/SimpleActionGame2#!/game-instances

7. use ai npc sdk to recreate the ai space escape game

