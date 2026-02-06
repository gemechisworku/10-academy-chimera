# Chimera Agent Skills

**Date:** 2026-02-04  
**Version:** 1.0  
**Status:** Active

---

## Overview

This directory defines the **Skills** available to Chimera Agents. A Skill is a specific capability package that encapsulates a complete workflow for executing a particular type of task. Skills are invoked by Workers during task execution and must conform to the Chimera architecture principles:

- **MCP-Only Interface**: All external interactions must route through MCP servers
- **Atomic Execution**: Skills execute single, atomic tasks with no inter-skill communication
- **Idempotency**: Skills must be safe to retry (check for existing results before execution)
- **Confidence Scoring**: All skill outputs must include confidence_score, risk_tags, and disclosure_level
- **Tool Provenance**: Skills must track which MCP tools were used and their parameters

---

## Skill Architecture

### Skill Structure

Each skill is a self-contained module that:

1. **Accepts Input**: Structured input contract (Pydantic model)
2. **Executes Logic**: Performs the skill's core functionality via MCP tools
3. **Returns Output**: Structured output contract matching Worker Result schema
4. **Handles Errors**: Graceful error handling with retry-safe semantics

### Skill Registration

Skills are registered with the Worker service and can be invoked via task parameters:

```python
{
  "task_type": "execute_skill",
  "parameters": {
    "skill_name": "skill_transcribe_audio",
    "skill_input": { /* skill-specific input */ }
  }
}
```

---

## Critical Skills

### 1. skill_transcribe_audio

**Purpose**: Transcribes audio content (from videos, podcasts, voice messages) into text for content analysis, remixing, and accessibility.

**Use Cases**:
- Transcribe audio from downloaded YouTube videos
- Process voice messages from social platforms
- Extract dialogue from video content for remixing
- Generate captions for video posts

**Input Contract**:
```python
class TranscribeAudioInput(BaseModel):
    audio_source: str  # URL to audio file or object storage path
    source_type: Literal["url", "object_storage", "mcp_resource"]  # Source type
    language: Optional[str] = "en"  # ISO 639-1 language code (default: English)
    format: Literal["text", "srt", "vtt"] = "text"  # Output format
    speaker_diarization: bool = False  # Whether to identify different speakers
    timestamps: bool = True  # Include timestamps in output
    agent_id: str  # Required for logging and cost tracking
    task_id: str  # Required for idempotency checks
```

**Output Contract**:
```python
class TranscribeAudioOutput(BaseModel):
    result_id: UUID
    task_id: str
    agent_id: str
    artifact: dict  # {
    #   "type": "text",
    #   "content": "transcribed text content",
    #   "metadata": {
    #     "format": "text|srt|vtt",
    #     "language": "en",
    #     "duration_seconds": 120.5,
    #     "word_count": 250,
    #     "speaker_count": 1 (if diarization enabled),
    #     "timestamps": [{"start": 0.0, "end": 5.2, "text": "..."}]
    #   }
    # }
    confidence_score: float  # 0.0 to 1.0 (transcription accuracy confidence)
    risk_tags: List[str]  # e.g., ["copyright", "sensitive_language"]
    disclosure_level: Literal["automated", "assisted", "none"]  # Always "automated" for transcription
    tool_provenance: dict  # {
    #   "mcp_tool": "mcp-server-whisper/transcribe",
    #   "tool_version": "1.0.0",
    #   "parameters_used": {"language": "en", "format": "text"},
    #   "cost_estimate": 0.05  # USD
    # }
    execution_metadata: dict  # {
    #   "started_at": "2026-02-04T10:00:00Z",
    #   "completed_at": "2026-02-04T10:00:15Z",
    #   "duration_ms": 15000
    # }
```

**MCP Dependencies**:
- `mcp-server-whisper` or `mcp-server-openai` (for transcription API)
- `mcp-server-storage` (for object storage access)

**Idempotency**: Checks if transcription already exists for `task_id` before executing.

**Error Handling**: Returns structured error with retry-safe semantics if audio source is invalid or transcription fails.

---

### 2. skill_download_youtube

**Purpose**: Downloads video content from YouTube for content remixing, analysis, and repurposing.

**Use Cases**:
- Download videos for remixing into new content
- Extract audio tracks for transcription
- Analyze competitor content
- Create reaction/commentary content

**Input Contract**:
```python
class DownloadYouTubeInput(BaseModel):
    video_url: str  # YouTube video URL (full URL or video ID)
    download_type: Literal["video", "audio", "both"] = "video"  # What to download
    quality: Literal["highest", "medium", "lowest"] = "medium"  # Quality preference
    format: Optional[str] = None  # Specific format (mp4, webm, etc.) - None = auto-select
    extract_audio_format: Literal["mp3", "wav", "m4a"] = "mp3"  # If download_type includes audio
    agent_id: str  # Required for logging and cost tracking
    task_id: str  # Required for idempotency checks
    purpose: Optional[str] = None  # Purpose description for audit trail
```

**Output Contract**:
```python
class DownloadYouTubeOutput(BaseModel):
    result_id: UUID
    task_id: str
    agent_id: str
    artifact: dict  # {
    #   "type": "video|audio|both",
    #   "content": "s3://bucket/path/to/video.mp4",  # Object storage URL
    #   "metadata": {
    #     "video_id": "dQw4w9WgXcQ",
    #     "title": "Video Title",
    #     "duration_seconds": 180,
    #     "resolution": {"width": 1920, "height": 1080},
    #     "file_size": 52428800,  # bytes
    #     "mime_type": "video/mp4",
    #     "audio_url": "s3://bucket/path/to/audio.mp3"  # If audio extracted
    #   }
    # }
    confidence_score: float  # 0.0 to 1.0 (download success confidence)
    risk_tags: List[str]  # e.g., ["copyright", "age_restricted", "region_blocked"]
    disclosure_level: Literal["automated", "assisted", "none"]  # Always "automated"
    tool_provenance: dict  # {
    #   "mcp_tool": "mcp-server-youtube/download",
    #   "tool_version": "1.0.0",
    #   "parameters_used": {"quality": "medium", "format": "mp4"},
    #   "cost_estimate": 0.0  # Usually free (unless using premium service)
    # }
    execution_metadata: dict  # {
    #   "started_at": "2026-02-04T10:00:00Z",
    #   "completed_at": "2026-02-04T10:00:45Z",
    #   "duration_ms": 45000
    # }
```

**MCP Dependencies**:
- `mcp-server-youtube` (for video downloading)
- `mcp-server-storage` (for object storage upload)

**Idempotency**: Checks if video already downloaded for `task_id` before executing.

**Error Handling**: Returns structured error if video is unavailable, age-restricted, or region-blocked.

**Copyright Compliance**: Skill must check video license and add appropriate risk_tags. Downloads are for remixing/analysis only; republishing requires proper attribution.

---

### 3. skill_generate_content

**Purpose**: Generates text content (posts, replies, captions) using the agent's persona and context.

**Use Cases**:
- Generate social media posts
- Create captions for images/videos
- Draft replies to comments/mentions
- Write blog posts or articles

**Input Contract**:
```python
class GenerateContentInput(BaseModel):
    content_type: Literal["post", "reply", "caption", "article", "thread"]  # Type of content
    platform: Optional[Literal["twitter", "instagram", "tiktok", "openclaw"]] = None  # Target platform
    prompt: str  # Base prompt/instruction for content generation
    context: dict  # {
    #   "goal_description": "string",
    #   "persona_constraints": ["string"],
    #   "required_resources": ["mcp://memory/recent", "mcp://twitter/mentions/123"],
    #   "tone": "witty|professional|casual",
    #   "max_length": 280,  # Character limit (platform-specific)
    #   "include_hashtags": True,
    #   "reference_content": "string (optional)"  # Content to reference/respond to
    # }
    agent_id: str  # Required for persona loading
    task_id: str  # Required for idempotency checks
    memory_context: Optional[dict] = None  # {
    #   "episodic_memory": ["recent interactions"],
    #   "semantic_memory": ["relevant past memories"]
    # }
```

**Output Contract**:
```python
class GenerateContentOutput(BaseModel):
    result_id: UUID
    task_id: str
    agent_id: str
    artifact: dict  # {
    #   "type": "text",
    #   "content": "Generated text content",
    #   "metadata": {
    #     "content_type": "post",
    #     "platform": "twitter",
    #     "word_count": 45,
    #     "character_count": 250,
    #     "hashtags": ["#example", "#hashtag"],
    #     "mentions": ["@user"],
    #     "tone_score": 0.85  # Alignment with persona tone
    #   }
    # }
    confidence_score: float  # 0.0 to 1.0 (content quality and safety confidence)
    risk_tags: List[str]  # e.g., ["politics", "health", "finance", "sensitive_topic"]
    disclosure_level: Literal["automated", "assisted", "none"]  # Usually "automated" unless flagged
    tool_provenance: dict  # {
    #   "mcp_tool": "mcp-server-gemini/generate_text",
    #   "tool_version": "1.0.0",
    #   "parameters_used": {"model": "gemini-3-pro", "temperature": 0.7},
    #   "cost_estimate": 0.002  # USD
    # }
    execution_metadata: dict  # {
    #   "started_at": "2026-02-04T10:00:00Z",
    #   "completed_at": "2026-02-04T10:00:05Z",
    #   "duration_ms": 5000
    # }
```

**MCP Dependencies**:
- `mcp-server-gemini` or `mcp-server-claude` (for text generation)
- `mcp-server-weaviate` (for memory retrieval)
- `mcp-server-memory` (for episodic memory access)

**Idempotency**: Checks if content already generated for `task_id` before executing.

**Persona Integration**: Automatically loads agent's SOUL.md persona and injects into generation context.

**Memory Integration**: Retrieves relevant episodic and semantic memories before generation.

---

### 4. skill_generate_image

**Purpose**: Generates images using MCP image generation tools with character consistency enforcement.

**Use Cases**:
- Generate images for social media posts
- Create character-consistent visuals
- Produce campaign imagery
- Generate thumbnails for videos

**Input Contract**:
```python
class GenerateImageInput(BaseModel):
    prompt: str  # Image generation prompt
    character_reference_id: str  # REQUIRED: Character consistency lock (from character_references table)
    style: Optional[str] = None  # Style override (e.g., "photorealistic", "anime", "watercolor")
    aspect_ratio: Literal["1:1", "16:9", "9:16", "4:3", "3:4"] = "1:1"  # Image dimensions
    resolution: Literal["standard", "high", "ultra"] = "standard"  # Resolution tier
    negative_prompt: Optional[str] = None  # What to avoid in generation
    agent_id: str  # Required for character reference lookup
    task_id: str  # Required for idempotency checks
    context: Optional[dict] = None  # {
    #   "campaign_id": "string",
    #   "goal_description": "string",
    #   "reference_images": ["s3://bucket/path/to/ref.jpg"]  # Optional reference images
    # }
```

**Output Contract**:
```python
class GenerateImageOutput(BaseModel):
    result_id: UUID
    task_id: str
    agent_id: str
    artifact: dict  # {
    #   "type": "image",
    #   "content": "s3://bucket/path/to/image.jpg",  # Object storage URL
    #   "metadata": {
    #     "dimensions": {"width": 1024, "height": 1024},
    #     "file_size": 524288,  # bytes
    #     "mime_type": "image/jpeg",
    #     "character_consistency_score": 0.92,  # Validated by Judge
    #     "style": "photorealistic"
    #   }
    # }
    confidence_score: float  # 0.0 to 1.0 (image quality and character consistency confidence)
    risk_tags: List[str]  # e.g., ["nsfw", "violence", "copyright"]
    disclosure_level: Literal["automated", "assisted", "none"]  # Usually "automated"
    tool_provenance: dict  # {
    #   "mcp_tool": "mcp-server-ideogram/generate_image",
    #   "tool_version": "1.0.0",
    #   "parameters_used": {
    #     "prompt": "...",
    #     "character_reference_id": "uuid",
    #     "aspect_ratio": "1:1",
    #     "resolution": "standard"
    #   },
    #   "cost_estimate": 0.10  # USD
    # }
    execution_metadata: dict  # {
    #   "started_at": "2026-02-04T10:00:00Z",
    #   "completed_at": "2026-02-04T10:00:30Z",
    #   "duration_ms": 30000
    # }
```

**MCP Dependencies**:
- `mcp-server-ideogram` or `mcp-server-midjourney` (for image generation)
- `mcp-server-storage` (for object storage upload)
- Database access (for character_reference_id lookup)

**Character Consistency**: Automatically includes character reference ID and LoRA identifier in generation request. Judge validates character consistency using Vision-capable model.

**Idempotency**: Checks if image already generated for `task_id` before executing.

---

### 5. skill_render_video

**Purpose**: Renders videos using MCP video generation tools with tiered quality strategy.

**Use Cases**:
- Generate video content for TikTok/Instagram Reels
- Create "Living Portraits" for daily content
- Produce hero videos for campaign milestones
- Render video from scripts and images

**Input Contract**:
```python
class RenderVideoInput(BaseModel):
    script: str  # Video script/narrative
    tier: Literal["tier_1_daily", "tier_2_hero"]  # Quality tier (cost vs. quality tradeoff)
    # Tier 1: Image-to-Video (Static Image + Motion Brush) - cost-effective
    # Tier 2: Full Text-to-Video - high quality, expensive
    source_image: Optional[str] = None  # For Tier 1: Static image URL (object storage)
    style: Optional[str] = None  # Visual style (e.g., "cinematic", "vibrant", "minimal")
    duration_seconds: Optional[int] = None  # Target duration (None = auto-determine from script)
    aspect_ratio: Literal["16:9", "9:16", "1:1"] = "9:16"  # For mobile-first platforms
    agent_id: str  # Required for logging and cost tracking
    task_id: str  # Required for idempotency checks
    campaign_id: Optional[str] = None  # For budget tracking
    context: Optional[dict] = None  # {
    #   "goal_description": "string",
    #   "character_reference_id": "uuid"  # If character appears in video
    # }
```

**Output Contract**:
```python
class RenderVideoOutput(BaseModel):
    result_id: UUID
    task_id: str
    agent_id: str
    artifact: dict  # {
    #   "type": "video",
    #   "content": "s3://bucket/path/to/video.mp4",  # Object storage URL
    #   "metadata": {
    #     "duration": 30,  # seconds
    #     "resolution": {"width": 1080, "height": 1920},
    #     "file_size": 15728640,  # bytes
    #     "mime_type": "video/mp4",
    #     "tier": "tier_1_daily",
    #     "fps": 30,
    #     "rendering_job_id": "uuid"  # If async rendering
    #   }
    # }
    confidence_score: float  # 0.0 to 1.0 (video quality and script alignment confidence)
    risk_tags: List[str]  # e.g., ["nsfw", "violence", "copyright"]
    disclosure_level: Literal["automated", "assisted", "none"]  # Usually "automated"
    tool_provenance: dict  # {
    #   "mcp_tool": "mcp-server-runway/render_video",
    #   "tool_version": "1.0.0",
    #   "parameters_used": {
    #     "tier": "tier_1_daily",
    #     "script": "...",
    #     "source_image": "s3://..."
    #   },
    #   "cost_estimate": 0.50  # USD (Tier 1) or 5.00 (Tier 2)
    # }
    execution_metadata: dict  # {
    #   "started_at": "2026-02-04T10:00:00Z",
    #   "completed_at": "2026-02-04T10:05:00Z",  # Video rendering can take minutes
    #   "duration_ms": 300000
    # }
```

**MCP Dependencies**:
- `mcp-server-runway` or `mcp-server-luma` (for video generation)
- `mcp-server-storage` (for object storage upload)

**Tier Strategy**:
- **Tier 1 (Daily Content)**: Uses Image-to-Video (Static Image + Motion Brush) for cost-effective routine updates. Requires `source_image`.
- **Tier 2 (Hero Content)**: Full Text-to-Video generation for major campaign milestones. Higher cost but better quality.

**Async Rendering**: Video rendering may be async. Skill tracks `rendering_job_id` and polls for completion.

**Idempotency**: Checks if video already rendered for `task_id` before executing.

**Budget Check**: Planner must check budget before invoking Tier 2 rendering.

---

## Skill Execution Flow

### 1. Task Assignment
Worker receives task with `skill_name` and `skill_input` in parameters.

### 2. Skill Invocation
Worker loads skill module and validates input against skill's Input Contract (Pydantic).

### 3. Idempotency Check
Skill checks if result already exists for `task_id` (prevents duplicate execution).

### 4. MCP Tool Execution
Skill invokes required MCP tools to perform the work.

### 5. Result Assembly
Skill assembles output matching Output Contract with:
- `confidence_score` (0.0 to 1.0)
- `risk_tags` (list of detected risks)
- `disclosure_level` (automated/assisted/none)
- `tool_provenance` (MCP tool details and costs)

### 6. Error Handling
If execution fails, skill returns structured error with retry-safe semantics.

### 7. Judge Validation
Output is pushed to `review_queue` for Judge validation before commit.

---

## Skill Development Guidelines

### Required Components

1. **Input Model**: Pydantic model defining input contract
2. **Output Model**: Pydantic model matching Worker Result schema
3. **Execute Function**: Async function that performs the skill's work
4. **Idempotency Logic**: Check for existing results before execution
5. **Error Handling**: Structured error responses
6. **MCP Integration**: All external calls via MCP tools
7. **Cost Tracking**: Emit cost events for budget governance

### Code Structure Template

```python
from pydantic import BaseModel
from typing import Literal, List, Optional
from uuid import UUID
from datetime import datetime

class SkillNameInput(BaseModel):
    # Define input contract
    pass

class SkillNameOutput(BaseModel):
    # Define output contract matching Worker Result schema
    pass

async def execute_skill_name(
    input_data: SkillNameInput,
    mcp_client: MCPClient,
    db_client: DatabaseClient
) -> SkillNameOutput:
    """
    Execute skill_name skill.
    
    Args:
        input_data: Validated input contract
        mcp_client: MCP client for external tool access
        db_client: Database client for state/queries
    
    Returns:
        SkillNameOutput: Structured output matching Worker Result schema
    
    Raises:
        SkillExecutionError: If execution fails (retry-safe)
    """
    # 1. Idempotency check
    # 2. MCP tool invocation
    # 3. Result assembly
    # 4. Return output
    pass
```

### Testing Requirements

- Unit tests for input validation
- Integration tests with MCP mocks
- Idempotency tests (verify safe retry)
- Error handling tests
- Cost tracking verification

---

## Skill Registry

Skills are registered in the Worker service configuration:

```python
SKILL_REGISTRY = {
    "skill_transcribe_audio": {
        "module": "chimera.skills.transcribe_audio",
        "function": "execute_transcribe_audio",
        "input_model": "TranscribeAudioInput",
        "output_model": "TranscribeAudioOutput"
    },
    "skill_download_youtube": {
        "module": "chimera.skills.download_youtube",
        "function": "execute_download_youtube",
        "input_model": "DownloadYouTubeInput",
        "output_model": "DownloadYouTubeOutput"
    },
    # ... other skills
}
```

---

## Future Skills (Planned)

- `skill_analyze_sentiment`: Analyze sentiment of text content
- `skill_detect_trends`: Detect emerging trends from aggregated data
- `skill_engage_reply`: Generate and post replies to comments/mentions
- `skill_post_content`: Post content to social platforms
- `skill_execute_transaction`: Execute on-chain transactions (via CFO Judge)
- `skill_retrieve_memory`: Hierarchical memory retrieval (episodic + semantic)

---

## References

- [`specs/technical.md`](../specs/technical.md) - Worker API and Result schemas
- [`specs/functional.md`](../specs/functional.md) - Worker user stories
- [`specs/_meta.md`](../specs/_meta.md) - Architectural principles and constraints

---

**End of Skills Documentation**

