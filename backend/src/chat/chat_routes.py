from fastapi import APIRouter, HTTPException, Query, Depends, Body
from typing import Dict, Optional, List
import uuid
import openai
import os
from sqlalchemy import desc, text
from sqlalchemy.orm import Session

# Import database models and utilities
from src.database import get_db
from src.users.user_utilities import ensure_user_exists

# Import environment variables for OpenAI
from dotenv import load_dotenv
load_dotenv()

# Set up OpenAI API key
openai.api_key = os.getenv("OPENAI_API_KEY")
OPENAI_MODEL = os.getenv("OPENAI_MODEL", "gpt-4o")

router = APIRouter(prefix="", tags=["chat"])

@router.post("/start")
def start_chat_session(
    user_id: int = Query(default=0, description="User ID (default is 0)"),
    username: str = Query(default="anonymous", description="Username (default is 'anonymous')"),
    db: Session = Depends(get_db)
):
    """Start a new chat session"""
    # Ensure user exists
    ensure_user_exists(user_id=user_id, username=username, db=db)
    
    # Generate UUID for session
    session_id = str(uuid.uuid4())
    
    # Create a new chat session with UUID
    query = """
    INSERT INTO chat_sessions (session_id, user_id)
    VALUES (:session_id, :user_id)
    RETURNING session_id;
    """
    db.execute(text(query), {"session_id": session_id, "user_id": user_id})
    db.commit()
    
    return {
        "session_id": session_id,
        "message": "Chat session started successfully"
    }

@router.post("/ask_question")
async def ask_question(
    session_id: str = Query(..., description="Session ID"),
    user_response: Dict[str, str] = Body(...),
    db: Session = Depends(get_db)
):
    """Send a message in a chat session and get AI response"""
    # Verify the session exists
    query = """
    SELECT session_id, user_id FROM chat_sessions WHERE session_id = :session_id;
    """
    result = db.execute(text(query), {"session_id": session_id}).fetchone()
    if not result:
        raise HTTPException(status_code=404, detail="Chat session not found")
    
    # Get the message from the user_response dict
    message = user_response.get('user_response')
    if not message:
        raise HTTPException(status_code=400, detail="No user response provided.")
    
    # Store user message
    user_message_query = """
    INSERT INTO chat_messages (session_id, role, content)
    VALUES (:session_id, 'user', :content)
    RETURNING id;
    """
    user_msg_id = db.execute(
        text(user_message_query), 
        {"session_id": session_id, "content": message}
    ).scalar()
    
    # Get the most recent 10 messages for context
    history_query = """
    SELECT role, content FROM chat_messages
    WHERE session_id = :session_id
    ORDER BY created_at DESC
    LIMIT 10;
    """
    recent_messages = db.execute(
        text(history_query), 
        {"session_id": session_id}
    ).fetchall()
    
    # Format messages for OpenAI (in chronological order)
    chat_messages = [
        {"role": msg.role, "content": msg.content}
        for msg in reversed(recent_messages)
    ]
    
    # Add a system message if there are no messages yet
    if not chat_messages:
        chat_messages = [{"role": "system", "content": "You are a helpful assistant."}]
    
    try:
        # Call OpenAI API
        response = openai.ChatCompletion.create(
            model=OPENAI_MODEL,
            messages=chat_messages,
            max_tokens=1024,
            temperature=0.7
        )
        
        # Get AI response content
        ai_response = response.choices[0].message.content
        tokens_used = response.usage.total_tokens
        
        # Store AI response
        ai_message_query = """
        INSERT INTO chat_messages (session_id, role, content, tokens)
        VALUES (:session_id, 'assistant', :content, :tokens)
        RETURNING id;
        """
        ai_msg_id = db.execute(
            text(ai_message_query), 
            {
                "session_id": session_id, 
                "content": ai_response,
                "tokens": tokens_used
            }
        ).scalar()
        
        db.commit()
        
        return {
            "session_id": session_id,
            "message": ai_response,
            "tokens_used": tokens_used
        }
        
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error generating response: {str(e)}")

@router.get("/{session_id}/history")
def get_chat_history(
    session_id: int,
    limit: int = Query(50, description="Maximum number of messages to return"),
    db: Session = Depends(get_db)
):
    """Get chat history for a session"""
    # Verify the session exists
    session_query = """
    SELECT id FROM chat_sessions WHERE id = :session_id;
    """
    session = db.execute(text(session_query), {"session_id": session_id}).fetchone()
    if not session:
        raise HTTPException(status_code=404, detail="Chat session not found")
    
    # Get messages
    messages_query = """
    SELECT id, role, content, created_at, tokens
    FROM chat_messages
    WHERE session_id = :session_id
    ORDER BY created_at ASC
    LIMIT :limit;
    """
    messages = db.execute(
        text(messages_query), 
        {"session_id": session_id, "limit": limit}
    ).fetchall()
    
    return {
        "session_id": session_id,
        "messages": [
            {
                "id": msg.id,
                "role": msg.role,
                "content": msg.content,
                "created_at": msg.created_at.isoformat(),
                "tokens": msg.tokens
            }
            for msg in messages
        ]
    }

@router.get("/sessions")
def get_user_sessions(
    user_id: int = Query(..., description="User ID"),
    db: Session = Depends(get_db)
):
    """Get all chat sessions for a user"""
    sessions_query = """
    SELECT id, created_at, updated_at
    FROM chat_sessions
    WHERE user_id = :user_id
    ORDER BY updated_at DESC;
    """
    sessions = db.execute(text(sessions_query), {"user_id": user_id}).fetchall()
    
    return {
        "user_id": user_id,
        "sessions": [
            {
                "id": session.id,
                "created_at": session.created_at.isoformat(),
                "updated_at": session.updated_at.isoformat()
            }
            for session in sessions
        ]
    } 