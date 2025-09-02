from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Node
import secrets

router = APIRouter(prefix="/nodes", tags=["nodes"])

@router.post("/request-token")
def request_token(name: str, region: str = "unknown", db: Session = Depends(get_db)):
    # create or return token for a node
    token = secrets.token_urlsafe(24)
    node = Node(name=name, region=region, token=token, is_active=False)
    db.add(node); db.commit(); db.refresh(node)
    return {"ok": True, "token": token, "node_id": node.id}
