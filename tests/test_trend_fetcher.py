"""
Test suite for trend fetcher API contract validation.

These tests assert that the trend data structure matches the API contract
defined in specs/technical.md Section 2.2.3 (Detect Trends).

These tests SHOULD FAIL initially - they define the "empty slot" that must be filled.
"""

import pytest
from datetime import datetime
from typing import List, Dict, Any
from uuid import uuid4


class TestTrendFetcherAPI:
    """Test that trend fetcher returns data matching the API contract."""
    
    def test_trend_response_structure(self):
        """
        Assert that trend response matches the API contract schema.
        
        Expected structure (from specs/technical.md 2.2.3):
        {
          "trends": [
            {
              "trend_id": "string",
              "topic": "string",
              "trend_score": "float (0.0 to 1.0)",
              "source": "string",
              "sample_content": "string",
              "detected_at": "ISO8601 datetime"
            }
          ],
          "total_trends": "integer"
        }
        """
        # This will fail - trend_fetcher module doesn't exist yet
        from worker.trend_fetcher import detect_trends
        
        # Test request parameters
        request_data = {
            "agent_id": "test_agent_123",
            "platform": "twitter",
            "query": "AI influencers",
            "time_window": "24h"
        }
        
        # Execute trend detection
        response = detect_trends(**request_data)
        
        # Assert response structure
        assert isinstance(response, dict), "Response must be a dictionary"
        assert "trends" in response, "Response must contain 'trends' key"
        assert "total_trends" in response, "Response must contain 'total_trends' key"
        
        # Assert trends is a list
        assert isinstance(response["trends"], list), "'trends' must be a list"
        
        # Assert total_trends matches trends length
        assert response["total_trends"] == len(response["trends"]), \
            "'total_trends' must match length of 'trends' array"
        
        # Assert each trend object structure
        for trend in response["trends"]:
            assert isinstance(trend, dict), "Each trend must be a dictionary"
            
            # Required fields
            assert "trend_id" in trend, "Trend must have 'trend_id' field"
            assert "topic" in trend, "Trend must have 'topic' field"
            assert "trend_score" in trend, "Trend must have 'trend_score' field"
            assert "source" in trend, "Trend must have 'source' field"
            assert "sample_content" in trend, "Trend must have 'sample_content' field"
            assert "detected_at" in trend, "Trend must have 'detected_at' field"
            
            # Type assertions
            assert isinstance(trend["trend_id"], str), "'trend_id' must be a string"
            assert isinstance(trend["topic"], str), "'topic' must be a string"
            assert isinstance(trend["trend_score"], float), "'trend_score' must be a float"
            assert isinstance(trend["source"], str), "'source' must be a string"
            assert isinstance(trend["sample_content"], str), "'sample_content' must be a string"
            assert isinstance(trend["detected_at"], str), "'detected_at' must be a string (ISO8601)"
            
            # Value range assertions
            assert 0.0 <= trend["trend_score"] <= 1.0, \
                "'trend_score' must be between 0.0 and 1.0"
            
            # ISO8601 datetime format validation
            try:
                datetime.fromisoformat(trend["detected_at"].replace('Z', '+00:00'))
            except ValueError:
                pytest.fail(f"'detected_at' must be valid ISO8601 datetime, got: {trend['detected_at']}")
    
    def test_trend_response_with_empty_results(self):
        """Assert that trend response handles empty results correctly."""
        from worker.trend_fetcher import detect_trends
        
        request_data = {
            "agent_id": "test_agent_123",
            "platform": "twitter",
            "query": "nonexistent_topic_xyz_12345",
            "time_window": "1h"
        }
        
        response = detect_trends(**request_data)
        
        # Empty results should still match structure
        assert isinstance(response, dict), "Response must be a dictionary"
        assert "trends" in response, "Response must contain 'trends' key"
        assert "total_trends" in response, "Response must contain 'total_trends' key"
        assert isinstance(response["trends"], list), "'trends' must be a list"
        assert response["total_trends"] == 0, "Empty results should have total_trends = 0"
        assert len(response["trends"]) == 0, "Empty results should have empty trends array"
    
    def test_trend_response_platform_validation(self):
        """Assert that trend fetcher validates platform parameter."""
        from worker.trend_fetcher import detect_trends
        
        # Test valid platforms
        valid_platforms = ["twitter", "instagram", "tiktok"]
        
        for platform in valid_platforms:
            request_data = {
                "agent_id": "test_agent_123",
                "platform": platform,
                "time_window": "24h"
            }
            
            # Should not raise validation error
            response = detect_trends(**request_data)
            assert isinstance(response, dict), f"Platform '{platform}' should be accepted"
        
        # Test invalid platform
        with pytest.raises(ValueError, match="platform"):
            request_data = {
                "agent_id": "test_agent_123",
                "platform": "invalid_platform",
                "time_window": "24h"
            }
            detect_trends(**request_data)
    
    def test_trend_response_time_window_validation(self):
        """Assert that trend fetcher validates time_window parameter."""
        from worker.trend_fetcher import detect_trends
        
        # Test valid time windows
        valid_windows = ["1h", "24h", "7d", "30d"]
        
        for time_window in valid_windows:
            request_data = {
                "agent_id": "test_agent_123",
                "platform": "twitter",
                "time_window": time_window
            }
            
            # Should not raise validation error
            response = detect_trends(**request_data)
            assert isinstance(response, dict), f"Time window '{time_window}' should be accepted"
        
        # Test default time_window (24h)
        request_data = {
            "agent_id": "test_agent_123",
            "platform": "twitter"
            # time_window omitted - should default to "24h"
        }
        
        response = detect_trends(**request_data)
        assert isinstance(response, dict), "Default time_window should be accepted"
    
    def test_trend_response_optional_query(self):
        """Assert that trend fetcher handles optional query parameter."""
        from worker.trend_fetcher import detect_trends
        
        # With query
        request_data = {
            "agent_id": "test_agent_123",
            "platform": "twitter",
            "query": "AI trends",
            "time_window": "24h"
        }
        
        response = detect_trends(**request_data)
        assert isinstance(response, dict), "Query parameter should be accepted"
        
        # Without query (should still work)
        request_data = {
            "agent_id": "test_agent_123",
            "platform": "twitter",
            "time_window": "24h"
        }
        
        response = detect_trends(**request_data)
        assert isinstance(response, dict), "Query parameter should be optional"

