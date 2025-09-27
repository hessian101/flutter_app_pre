# Star Music Game App - MVP + Audio Recording & Playback

## Project Overview
Create a rhythm game app that generates music from star constellation images, with high score tracking and audio recording/playback functionality.

## Core Features
- Generate rhythm game from uploaded star images
- Real-time gameplay with tap scoring (Perfect/Good/Miss)
- High score tracking with local database storage
- Audio recording during gameplay with WAV export
- Saved performance playback system

## Technical Stack
**Frontend**: Flutter or Unity
**Database**: SQLite (local storage)
**Audio**: Recording, playback, and WAV synthesis capabilities
**API**: Image processing to generate star coordinates and sound mapping

## Database Schema

### HighScore Table
```sql
CREATE TABLE HighScore (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT NOT NULL,
    score INTEGER NOT NULL,
    accuracy REAL NOT NULL,
    combo_max INTEGER NOT NULL
);
```

### SavedSong Table
```sql
CREATE TABLE SavedSong (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT NOT NULL,
    file_path TEXT NOT NULL,
    score INTEGER NOT NULL,
    accuracy REAL NOT NULL
);
```

## Screen Structure

### 1. Home Screen
- Start Game button
- Settings button
- How to Play button
- High Score Table button
- Performance List button (new)

### 2. Game Screen
- Note display and tap detection
- Real-time scoring with visual feedback
- Audio recording of tapped sounds
- Timeline-based sound synthesis for final WAV output

### 3. Results Screen
- Display final score, accuracy, and max combo
- Automatic high score saving
- User prompt for audio recording save:
  - "Save performance?" (Yes/No)
  - If Yes: Export WAV file and save to database
  - If No: Discard recording and return to home

### 4. High Score Table Screen
- Display saved scores from local database
- Show: Date, Score, Accuracy, Max Combo
- Sort options: By Date or By Score

### 5. Performance List Screen (New)
- Display saved audio performances
- Show: Date, Filename, Score, Accuracy
- Actions per item:
  - Play button (in-app audio playback)
  - Delete button (remove from storage and database)

## User Flow
1. Home → Start Game
2. Upload star image → API processing
3. Play rhythm game (with recording)
4. View results → Automatic high score save
5. Optional: Save audio performance
6. Access saved performances from Performance List

## Key Implementation Requirements

### Audio Recording System
- Record tap sounds with precise timing
- Synthesize individual sounds into single WAV file
- Support playback of saved performances
- Handle audio file management (save/delete)

### Database Operations
- Automatic high score saving after each game
- User-controlled audio performance saving
- Efficient data retrieval for list displays
- Proper cleanup when deleting saved performances

### API Integration
- Image upload and star constellation analysis
- Return star coordinates with mapped sound IDs
- Handle API response for rhythm game generation

## Development Priorities
1. Core rhythm game mechanics
2. High score tracking system  
3. Audio recording and WAV synthesis
4. Performance list and playback features
5. UI/UX polish and settings

## File Structure Suggestions
```
/lib
  /screens
    - home_screen.dart
    - game_screen.dart
    - result_screen.dart
    - highscore_screen.dart
    - performance_list_screen.dart
  /models
    - high_score.dart
    - saved_song.dart
    - star_data.dart
  /services
    - database_service.dart
    - audio_service.dart
    - api_service.dart
  /utils
    - constants.dart
    - audio_utils.dart
```

## Testing Considerations
- Audio recording quality and timing accuracy
- Database operations (CRUD for both tables)
- File system operations (WAV save/delete)
- API error handling
- Memory management for audio playback

返信やコメントは日本語にしてください。
