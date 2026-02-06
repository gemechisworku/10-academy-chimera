"""
Test suite for skills interface parameter validation.

These tests assert that skills/ modules accept the correct parameters
as defined in skills/README.md.

These tests SHOULD FAIL initially - they define the "empty slot" that must be filled.
"""

import pytest
from typing import Literal, Optional, List
from uuid import uuid4
from pydantic import BaseModel, ValidationError


class TestSkillsInterface:
    """Test that skills modules accept correct parameters."""
    
    def test_skill_transcribe_audio_input_contract(self):
        """
        Assert that skill_transcribe_audio accepts TranscribeAudioInput contract.
        
        Expected input (from skills/README.md):
        {
            "audio_source": "string",
            "source_type": "url" | "object_storage" | "mcp_resource",
            "language": "string (optional, default: 'en')",
            "format": "text" | "srt" | "vtt" (default: "text"),
            "speaker_diarization": "bool (default: False)",
            "timestamps": "bool (default: True)",
            "agent_id": "string (required)",
            "task_id": "string (required)"
        }
        """
        from skills.transcribe_audio import TranscribeAudioInput, execute_transcribe_audio
        
        # Valid input
        valid_input = {
            "audio_source": "https://example.com/audio.mp3",
            "source_type": "url",
            "language": "en",
            "format": "text",
            "speaker_diarization": False,
            "timestamps": True,
            "agent_id": "test_agent_123",
            "task_id": str(uuid4())
        }
        
        # Should validate successfully
        input_model = TranscribeAudioInput(**valid_input)
        assert input_model.audio_source == valid_input["audio_source"]
        assert input_model.source_type == valid_input["source_type"]
        assert input_model.language == "en"  # default
        assert input_model.agent_id == valid_input["agent_id"]
        assert input_model.task_id == valid_input["task_id"]
        
        # Test missing required fields
        with pytest.raises(ValidationError):
            TranscribeAudioInput(
                audio_source="https://example.com/audio.mp3",
                source_type="url"
                # Missing agent_id and task_id
            )
        
        # Test invalid source_type
        with pytest.raises(ValidationError):
            TranscribeAudioInput(
                audio_source="https://example.com/audio.mp3",
                source_type="invalid_type",
                agent_id="test_agent_123",
                task_id=str(uuid4())
            )
    
    def test_skill_download_youtube_input_contract(self):
        """
        Assert that skill_download_youtube accepts DownloadYouTubeInput contract.
        
        Expected input (from skills/README.md):
        {
            "video_url": "string (required)",
            "download_type": "video" | "audio" | "both" (default: "video"),
            "quality": "highest" | "medium" | "lowest" (default: "medium"),
            "format": "string (optional)",
            "extract_audio_format": "mp3" | "wav" | "m4a" (default: "mp3"),
            "agent_id": "string (required)",
            "task_id": "string (required)",
            "purpose": "string (optional)"
        }
        """
        from skills.download_youtube import DownloadYouTubeInput, execute_download_youtube
        
        # Valid input
        valid_input = {
            "video_url": "https://youtube.com/watch?v=dQw4w9WgXcQ",
            "download_type": "video",
            "quality": "medium",
            "format": "mp4",
            "extract_audio_format": "mp3",
            "agent_id": "test_agent_123",
            "task_id": str(uuid4()),
            "purpose": "Content remixing"
        }
        
        input_model = DownloadYouTubeInput(**valid_input)
        assert input_model.video_url == valid_input["video_url"]
        assert input_model.download_type == "video"
        assert input_model.quality == "medium"
        assert input_model.agent_id == valid_input["agent_id"]
        
        # Test missing required fields
        with pytest.raises(ValidationError):
            DownloadYouTubeInput(
                video_url="https://youtube.com/watch?v=dQw4w9WgXcQ"
                # Missing agent_id and task_id
            )
        
        # Test invalid download_type
        with pytest.raises(ValidationError):
            DownloadYouTubeInput(
                video_url="https://youtube.com/watch?v=dQw4w9WgXcQ",
                download_type="invalid",
                agent_id="test_agent_123",
                task_id=str(uuid4())
            )
    
    def test_skill_generate_content_input_contract(self):
        """
        Assert that skill_generate_content accepts GenerateContentInput contract.
        
        Expected input (from skills/README.md):
        {
            "content_type": "post" | "reply" | "caption" | "article" | "thread",
            "platform": "twitter" | "instagram" | "tiktok" | "openclaw" (optional),
            "prompt": "string (required)",
            "context": "dict (required)",
            "agent_id": "string (required)",
            "task_id": "string (required)",
            "memory_context": "dict (optional)"
        }
        """
        from skills.generate_content import GenerateContentInput, execute_generate_content
        
        # Valid input
        valid_input = {
            "content_type": "post",
            "platform": "twitter",
            "prompt": "Create a witty post about AI",
            "context": {
                "goal_description": "Engage audience",
                "persona_constraints": ["witty", "professional"],
                "required_resources": [],
                "tone": "witty",
                "max_length": 280
            },
            "agent_id": "test_agent_123",
            "task_id": str(uuid4()),
            "memory_context": {
                "episodic_memory": [],
                "semantic_memory": []
            }
        }
        
        input_model = GenerateContentInput(**valid_input)
        assert input_model.content_type == "post"
        assert input_model.platform == "twitter"
        assert input_model.prompt == valid_input["prompt"]
        assert input_model.agent_id == valid_input["agent_id"]
        
        # Test missing required fields
        with pytest.raises(ValidationError):
            GenerateContentInput(
                content_type="post",
                prompt="Create a post"
                # Missing context, agent_id, task_id
            )
        
        # Test invalid content_type
        with pytest.raises(ValidationError):
            GenerateContentInput(
                content_type="invalid_type",
                prompt="Create a post",
                context={},
                agent_id="test_agent_123",
                task_id=str(uuid4())
            )
    
    def test_skill_generate_image_input_contract(self):
        """
        Assert that skill_generate_image accepts GenerateImageInput contract.
        
        Expected input (from skills/README.md):
        {
            "prompt": "string (required)",
            "character_reference_id": "string (required)",
            "style": "string (optional)",
            "aspect_ratio": "1:1" | "16:9" | "9:16" | "4:3" | "3:4" (default: "1:1"),
            "resolution": "standard" | "high" | "ultra" (default: "standard"),
            "negative_prompt": "string (optional)",
            "agent_id": "string (required)",
            "task_id": "string (required)",
            "context": "dict (optional)"
        }
        """
        from skills.generate_image import GenerateImageInput, execute_generate_image
        
        # Valid input
        valid_input = {
            "prompt": "A futuristic AI character in a cyberpunk city",
            "character_reference_id": str(uuid4()),
            "style": "photorealistic",
            "aspect_ratio": "1:1",
            "resolution": "standard",
            "negative_prompt": "blurry, low quality",
            "agent_id": "test_agent_123",
            "task_id": str(uuid4()),
            "context": {
                "campaign_id": "campaign_123",
                "goal_description": "Create character image"
            }
        }
        
        input_model = GenerateImageInput(**valid_input)
        assert input_model.prompt == valid_input["prompt"]
        assert input_model.character_reference_id == valid_input["character_reference_id"]
        assert input_model.aspect_ratio == "1:1"
        assert input_model.resolution == "standard"
        assert input_model.agent_id == valid_input["agent_id"]
        
        # Test missing required fields
        with pytest.raises(ValidationError):
            GenerateImageInput(
                prompt="Create an image"
                # Missing character_reference_id, agent_id, task_id
            )
        
        # Test invalid aspect_ratio
        with pytest.raises(ValidationError):
            GenerateImageInput(
                prompt="Create an image",
                character_reference_id=str(uuid4()),
                aspect_ratio="invalid",
                agent_id="test_agent_123",
                task_id=str(uuid4())
            )
    
    def test_skill_render_video_input_contract(self):
        """
        Assert that skill_render_video accepts RenderVideoInput contract.
        
        Expected input (from skills/README.md):
        {
            "script": "string (required)",
            "tier": "tier_1_daily" | "tier_2_hero" (required),
            "source_image": "string (optional, required for tier_1_daily)",
            "style": "string (optional)",
            "duration_seconds": "int (optional)",
            "aspect_ratio": "16:9" | "9:16" | "1:1" (default: "9:16"),
            "agent_id": "string (required)",
            "task_id": "string (required)",
            "campaign_id": "string (optional)",
            "context": "dict (optional)"
        }
        """
        from skills.render_video import RenderVideoInput, execute_render_video
        
        # Valid input for tier_1_daily
        valid_input_tier1 = {
            "script": "A day in the life of an AI influencer",
            "tier": "tier_1_daily",
            "source_image": "s3://bucket/path/to/image.jpg",
            "style": "cinematic",
            "duration_seconds": 30,
            "aspect_ratio": "9:16",
            "agent_id": "test_agent_123",
            "task_id": str(uuid4()),
            "campaign_id": "campaign_123",
            "context": {
                "goal_description": "Create daily content"
            }
        }
        
        input_model = RenderVideoInput(**valid_input_tier1)
        assert input_model.script == valid_input_tier1["script"]
        assert input_model.tier == "tier_1_daily"
        assert input_model.source_image == valid_input_tier1["source_image"]
        assert input_model.aspect_ratio == "9:16"
        assert input_model.agent_id == valid_input_tier1["agent_id"]
        
        # Valid input for tier_2_hero (source_image not required)
        valid_input_tier2 = {
            "script": "Epic hero video for campaign launch",
            "tier": "tier_2_hero",
            "style": "vibrant",
            "aspect_ratio": "16:9",
            "agent_id": "test_agent_123",
            "task_id": str(uuid4())
        }
        
        input_model = RenderVideoInput(**valid_input_tier2)
        assert input_model.tier == "tier_2_hero"
        assert input_model.source_image is None
        
        # Test missing required fields
        with pytest.raises(ValidationError):
            RenderVideoInput(
                script="Create a video"
                # Missing tier, agent_id, task_id
            )
        
        # Test invalid tier
        with pytest.raises(ValidationError):
            RenderVideoInput(
                script="Create a video",
                tier="invalid_tier",
                agent_id="test_agent_123",
                task_id=str(uuid4())
            )
        
        # Test invalid aspect_ratio
        with pytest.raises(ValidationError):
            RenderVideoInput(
                script="Create a video",
                tier="tier_1_daily",
                source_image="s3://bucket/image.jpg",
                aspect_ratio="invalid",
                agent_id="test_agent_123",
                task_id=str(uuid4())
            )
    
    def test_skills_accept_mcp_client_parameter(self):
        """
        Assert that all skill execute functions accept mcp_client parameter.
        
        All skills should follow the pattern:
        async def execute_skill_name(
            input_data: SkillInput,
            mcp_client: MCPClient,
            db_client: DatabaseClient
        ) -> SkillOutput
        """
        from skills.transcribe_audio import execute_transcribe_audio
        from skills.download_youtube import execute_download_youtube
        from skills.generate_content import execute_generate_content
        from skills.generate_image import execute_generate_image
        from skills.render_video import execute_render_video
        import inspect
        
        # Check function signatures
        skills = [
            execute_transcribe_audio,
            execute_download_youtube,
            execute_generate_content,
            execute_generate_image,
            execute_render_video
        ]
        
        for skill_func in skills:
            sig = inspect.signature(skill_func)
            params = list(sig.parameters.keys())
            
            # Should have at least input_data, mcp_client, db_client
            assert len(params) >= 2, f"{skill_func.__name__} should accept at least 2 parameters"
            
            # Check for mcp_client parameter (name may vary)
            param_names = [p.lower() for p in params]
            assert any("mcp" in name or "client" in name for name in param_names), \
                f"{skill_func.__name__} should accept mcp_client parameter"

