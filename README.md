# PostApp

<p float="middle">
  <img src="https://github.com/user-attachments/assets/5e738ce2-33b4-4ed5-a03b-487f0f7f63db" width="450">
</p>

## Features


- **Dynamic Feed**: Post descriptions with interactive "Expand/Collapse" functionality
- **Modern Concurrency**: Built entirely using async/await and Actors for thread-safe operations
- **Advanced Image Caching**: Dual-layer caching system (RAM + Disk) with actor-based thread safety
- **Self-Sizing Cells**: Dynamic cell heights using Auto Layout and UIStackView
- **Detail Views**: Full post presentation with images, metadata, and formatted dates
- **Error Handling**: Comprehensive error management with user-friendly alerts

## Architecture

### MVVM Pattern
Separates business logic from the view layer. The `PostListViewModel` handles data fetching and transforms raw DTOs into `PostItem` objects, keeping the ViewController thin and focused on UI layout.

### Project Structure

```
## Key Components

### Models
- `PostListResponse` & `Post`: API response models for the feed
- `PostDetailResponse` & `PostDetail`: Detailed post information
- `PostItem`: UI model with expanded state management

### Services
- `NetworkService`: Generic networking with async/await
- `ImageCache`: Actor-based caching with memory and disk persistence

### ViewModels
- `PostListViewModel`: Business logic, state management, and data transformation

### Views
- `PostListViewController`: Main feed with collection view and diffable data source
- `PostCell`: Dynamic cell with expandable content
- `PostDetailsViewController`: Full post presentation with image and metadata
```

## Technical Implementation

### Networking & Concurrency
- **Async/Await**: Replaced traditional completion handlers with structured concurrency for cleaner, more readable code
- **Generic Provider**: A single `performRequest<T>` method handles decoding using `convertFromSnakeCase` strategy
- **Error Propagation**: Proper error handling throughout the call chain

### Advanced UI Logic
- **Self-Sizing Cells**: Utilizes Auto Layout and UIStackView to handle dynamic text heights
- **Responsive Layout**: Scroll views and stack views for optimal content presentation

### Image Caching (Actor-based)
To prevent the same image from being downloaded multiple times, I implemented a custom `ImageCache` service:

- **Memory Cache**: Uses `NSCache` for instant retrieval
- **Disk Cache**: Uses the Caches directory for persistence across app restarts
- **Thread Safety**: Defined as an actor to ensure safe concurrent access from multiple cells


