import pytest
from app import app
@pytest.fixture
def client():
    """Set up a test client for the Flask app."""
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client
def test_home_route(client):
    """Test if the home page loads correctly."""
    response = client.get('/')
    assert response.status_code == 200
    assert b"Python POC: Pipeline Successful!" in response.data
def test_invalid_route(client):
    """Test if a non-existent page returns a 404."""
    response = client.get('/non-existent')
    assert response.status_code == 404
